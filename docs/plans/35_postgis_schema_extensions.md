# Plan 35 — Réinstaller PostGIS dans le schéma `extensions`

## Statut

Plan rédigé le 2026-09-29 à la demande du PO du même jour. Q241 et Q242 tranchées le
2026-09-30 : le PO fixera le moment au lancement ; répétition sur la production retenue.
**Plan validé par le PO le 2026-09-30.**

## Demande du PO (reformulée)

Corriger nous-mêmes, sans passer par le support Supabase, l'erreur de sécurité relevée par
l'audit du 2026-09-29 : sauvegarder les positions, supprimer PostGIS, le réinstaller dans le
bon schéma, restaurer les positions et corriger les fonctions qui s'en servent.

## Existant (constat, relevé sur la production le 2026-09-29)

**La cause.** La première migration (`20260915100000_extensions_and_enums.sql`, ligne 3) crée
PostGIS par `create extension if not exists postgis;` sans schéma : l'extension (version 3.3.7)
est dans `public`, le seul schéma que l'API de Supabase expose. Sa table `spatial_ref_sys`
(définitions des systèmes de coordonnées, dont le GPS, SRID 4326) y est donc lisible **et
modifiable** par `anon` et `authenticated` : droits vérifiés, et une insertion faite en tant
qu'`anon` dans une transaction annulée a franchi le contrôle des droits. Quelqu'un muni de la
clé publique de l'app pourrait effacer la ligne 4326 et casser toute fonction de position. Ces
droits ont été accordés par `supabase_admin`, compte interne de Supabase : notre migration
`20260929130000_spatial_ref_sys_read_only.sql`, qui les retirait, s'est appliquée sans effet.
PostGIS ne se déplace pas d'un schéma à l'autre (`extrelocatable = false`), d'où ce plan.
Nos autres extensions (`pgcrypto`, `pg_net`, `uuid-ossp`) sont déjà dans `extensions`, schéma
que l'API n'expose pas ; c'est l'emplacement que recommande la documentation de Supabase.

**Ce qui dépend de PostGIS** (inventaire complet par le catalogue de la base, `pg_depend`) :

| Objet | Détail |
|---|---|
| 6 colonnes `geography(Point,4326)` | `associations.location` (obligatoire), `events.location`, `holes.start`, `holes.end_point`, `sessions.location`, `spots.location` |
| 12 colonnes calculées | `…_lat` / `…_lng` de chacune (`st_y` / `st_x`), lues par l'app et par `tool/export_remote_seed.dart` |
| 1 index | `holes_start_gix` (gist sur `holes.start`, recherche des trous proches) |
| 1 contrainte | `spots_check` (emplacement variable ⇒ pas de point) |
| 1 déclencheur | `spots_propagate_trigger` (`after update of name, city, location on spots`) |
| 1 fonction qui rend un `geography` | `_payload_point(jsonb)`, appelée par les RPC d'association et de spot |
| 3 fonctions qui appellent PostGIS | `holes_nearby`, `request_association`, `session_snapshot` |
| Publication temps réel | `sessions` (toutes colonnes, sans liste figée) |

Aucune vue, aucune politique RLS, aucun droit posé colonne par colonne ne touche ces colonnes.
Toutes nos fonctions (85) portent `set search_path = public` : une fois PostGIS dans
`extensions`, celles qui l'appellent ne trouveraient plus ses fonctions sans correction.

**Volume** : 6 associations, 36 événements, 9 sessions, 5 spots et 19 trous ont un point (base
de 24 Mo). L'opération prend quelques secondes.

**Côté app, rien ne change** : elle lit les colonnes `…_lat` / `…_lng` (mêmes noms après
l'opération) et écrit des points sous forme de texte `SRID=4326;POINT(lng lat)`, que Postgres
convertit quel que soit le schéma de PostGIS. Les seeds insèrent en nommant les colonnes. Les
tests SQL (`rls_smoke.sql`, `notifications_smoke.sql`) appellent `st_setsrid` sans schéma, et le
rôle `postgres` qui les joue cherche déjà dans `public, extensions` : ils passent tels quels.

## Ce qui change pour l'utilisateur

Rien de visible. Pendant les quelques secondes de l'opération, une action dans l'app peut
échouer et doit être refaite (Q241). Après, plus personne ne peut modifier les systèmes de
coordonnées depuis l'extérieur, et l'audit Supabase ne signale plus d'erreur.

## Décisions techniques

1. **Sauvegarde, trois niveaux.**
   - Avant : `fvm dart run tool/export_remote_seed.dart` (règle 8), qui contient tous les
     points sous forme de texte.
   - Dans la migration, avant toute suppression : table `_postgis_backup` (table, identifiant,
     colonne, point au format texte EWKT), sans aucun droit pour `anon` ni `authenticated`, RLS
     activé. Elle survit à l'opération et n'est supprimée que par une migration suivante, une
     fois le PO satisfait.
   - Pendant : les 6 colonnes ne sont jamais supprimées. Elles sont converties en texte EWKT
     sur place (`alter column … type text using st_asewkt(…)`), puis reconverties en
     `extensions.geography(Point,4326)`. Les données ne quittent pas leur ligne, et ces
     colonnes gardent leur place dans la table.
2. **Une seule migration, en une seule transaction** : tout réussit ou rien n'est appliqué.
   Ordre :
   1. remplir `_postgis_backup` ;
   2. supprimer ce qui empêche la conversion : les 12 colonnes calculées, l'index
      `holes_start_gix`, le déclencheur `spots_propagate_trigger`, la fonction `_payload_point` ;
   3. convertir les 6 colonnes en texte ;
   4. `drop extension postgis` **sans** `cascade` : si un objet oublié en dépend encore,
      l'opération s'arrête et la transaction est annulée, au lieu de le supprimer en silence ;
   5. `create extension postgis with schema extensions` ;
   6. reconvertir les 6 colonnes en `extensions.geography(Point,4326)`, remettre
      `not null` sur `associations.location` ;
   7. recréer les 12 colonnes calculées (mêmes noms, mêmes formules, noms de fonctions
      préfixés par `extensions.`), l'index, le déclencheur, `_payload_point` avec
      `set search_path = public, extensions` et ses droits d'origine ;
   8. `alter function … set search_path = public, extensions` pour `holes_nearby`,
      `request_association` et `session_snapshot` (réglage seul, corps inchangé) ;
   9. contrôle final dans un bloc `do` : chaque point relu est comparé à `_postgis_backup`, et
      le nombre de points par colonne à celui d'avant. Au moindre écart, erreur, donc
      annulation de toute la transaction ;
   10. `notify pgrst, 'reload schema'` pour que l'API relise la structure.
   Les colonnes calculées recréées se placent en fin de table : sans effet, l'app, l'API et les
   seeds désignent les colonnes par leur nom.
3. **Répétition générale sur la production, annulée** (Q242) : le même script, encadré par
   `begin; … rollback;` et suivi de vérifications (appel de `holes_nearby`, de `_payload_point`,
   droits sur `extensions.spatial_ref_sys`), joué par `npx supabase db query --linked`. Il
   prouve sur les vraies données et avec les vrais droits de Supabase que la suppression et la
   réinstallation sont permises au rôle `postgres`, sans rien garder. Tables verrouillées
   quelques secondes, comme pour l'opération réelle.
4. **Fichiers existants inchangés** (règle 8). La migration sans effet `20260929130000` reste ;
   un commentaire de la nouvelle migration dit qu'elle la remplace.
5. **`AGENTS.md` et `docs/DEV.md`** : toute future extension se crée
   `with schema extensions` ; une fonction qui appelle PostGIS porte
   `set search_path = public, extensions`.

## Prérequis du PO

- Le moment, fixé par le PO au lancement (Q241), pour la répétition comme pour l'opération ;
  l'assistant vérifie juste avant chacune qu'aucune session n'est en cours
  (`status = 'live'`).
- `env/migration.json` et `env/seed.json` présents sur le poste pour l'export des seeds.

## Étapes

1. Export des seeds (décision 1).
2. Écriture de la migration (`npx supabase migration new postgis_to_extensions_schema`).
3. Répétition annulée sur la production (décision 3), résultats consignés dans ce plan. En cas
   d'échec (par exemple suppression refusée au rôle `postgres`), arrêt et retour au PO avec la
   voie du support Supabase (règle 3).
4. Résumé au PO de ce que change la migration (règle 8), puis `npx supabase db push` au moment
   convenu.
5. Vérifications : `rls_smoke.sql` et `notifications_smoke.sql` verts,
   `npx supabase db advisors --linked` sans erreur ni avertissement PostGIS, droits
   d'écriture d'`anon` absents sur `extensions.spatial_ref_sys` et table absente de l'API.
6. Essai dans l'app : trous proches, fiche d'un trou avec départ et arrivée, carte d'un spot,
   création d'un spot avec point, événement avec lieu, création de session.
7. Après validation du PO : migration de suppression de `_postgis_backup`.

## Hors périmètre

- Politiques multiples et autres alertes de performance de l'audit : laissées en l'état
  (décision du 2026-09-29).
- Déplacement des autres extensions : déjà dans `extensions`.

## Critères d'acceptation

- [ ] Seeds exportés avant l'opération.
- [ ] Répétition annulée réussie sur la production, consignée.
- [ ] PostGIS dans le schéma `extensions` ; `public.spatial_ref_sys` n'existe plus.
- [ ] Chaque point identique à la sauvegarde, même nombre de points par colonne.
- [ ] `db advisors` : plus d'erreur `rls_disabled_in_public`, plus d'avertissement
      `extension_in_public` ni de fonction PostGIS exécutable par `anon`.
- [ ] `rls_smoke.sql` et `notifications_smoke.sql` verts.
- [ ] Parcours de l'étape 6 essayés dans l'app, puis par le PO.
- [ ] `AGENTS.md` et `docs/DEV.md` à jour ; `_postgis_backup` supprimée après validation.

## Questions PO liées

Q241 (moment de l'opération), Q242 (répétition sur la production).
