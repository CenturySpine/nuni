# Plan 36 — Archive des sessions terminées supprimées

## Statut

Plan rédigé le 2026-10-05 à la demande du PO du même jour. Q244 à Q248 tranchées le même jour
(le PO a accepté toutes les suggestions). **Plan validé par le PO le 2026-10-05** (« on fera
l'implémentation demain ») ; implémentation prévue le 2026-10-06.

## Demande du PO (reformulée)

Un filet de sécurité contre les accidents, maintenant que des administrateurs et responsables
locaux commencent à manipuler l'app et à créer des sessions de test :

1. La suppression d'une session **brouillon ou en cours** reste **définitive**, comme
   aujourd'hui (sessions de test, mauvais paramétrage : fréquentes et sans conséquence).
2. La suppression d'une session **terminée** (« validée » = « terminée », Q245) garde une
   **copie de secours** complète, photos comprises.
3. Rien ne change dans l'app : la copie n'est visible de personne. En cas d'accident, la
   session est restaurée à la main par l'assistant ou le PO, dans les heures qui suivent.

Ce n'est pas une suppression logique (session masquée mais gardée dans les tables) : celle-ci
a été écartée (Q244) parce qu'elle oblige toutes les lectures de sessions, présentes et
futures, à ignorer les sessions masquées, sous peine de les voir réapparaître dans les
statistiques, le championnat ou les badges.

## Existant (constat, relevé dans le code le 2026-10-05)

- **Qui supprime** : les organisateurs de la session (créateur ou co-organisateur, règle
  `sessions_delete_owner`), depuis quatre écrans : salle d'attente (`session_room_page.dart`),
  partie en cours (`session_live_page.dart`), salle des présents (`attendance_room_view.dart`),
  fiche d'historique (`history_detail_page.dart`, qui ne montre que des sessions terminées :
  `history_snapshots` ne rend que `status = 'completed'`).
- **Ce que la base efface** : la ligne `sessions`, puis en cascade (`on delete cascade`) ses six
  tables liées : `teams`, `team_players`, `session_members`, `played_holes`, `scores`,
  `session_photos`.
- **Photos** : elles ne se gèrent que depuis la fiche d'historique. Avant de supprimer la
  session, cette fiche efface les fichiers du stockage, photo et miniature
  (`deleteSessionWithPhotos`, `history_repository.dart`). Les trois autres écrans ne touchent
  pas au stockage.
- **Aucune trace n'est gardée** : seule la sauvegarde manuelle (`tool/export_remote_seed.dart`)
  contient une session supprimée, si elle a été faite entre la fin et la suppression de la
  session.
- **Les déclencheurs sont déjà prêts pour une réinsertion** : sans utilisateur connecté (requête
  lancée depuis l'éditeur SQL de Supabase ou la ligne de commande), ceux de `sessions` et de ses
  tables gardent les valeurs fournies (association, code, championnat, natures, présence,
  `checked_in_at`). C'est le chemin qu'emprunte déjà la relecture des seeds ; la restauration
  l'emprunte aussi.
- **Qui lit les sessions terminées** : statistiques, records, badges et championnat ne lisent
  que des sessions terminées (`eligible_session.dart`). Supprimer une session non terminée ne
  modifie donc l'historique de personne : le critère de la demande protège exactement les
  données qui comptent.

## Ce qui change pour l'utilisateur

**Rien de visible.** Mêmes boutons, mêmes droits, même message de confirmation (« Cette action
est définitive ») : pour celui qui supprime, la suppression reste définitive ; seul
l'administrateur peut ramener une session terminée, à la demande (Q246).

En cas d'accident sur une session terminée : le PO (ou la personne concernée, par lui) le
signale ; la restauration (une commande) remet la session à l'identique pour tous ses
participants : équipes, participants et leur présence, trous joués et leur par, scores, photos
et photo de couverture, natures, championnat, compte rendu, météo, lien avec l'événement quand
c'est encore possible. Elle réapparaît dans l'historique, les statistiques, les badges et le
championnat au prochain affichage (tous calculés à l'affichage, rien n'est à recalculer). La
restauration n'envoie aucune notification.

## Décisions techniques

1. **Table privée `session_archives`** : une ligne par session terminée supprimée.
   `id`, `session_id` (sans clé étrangère : la session n'existe plus), `deleted_at`,
   `deleted_by` (le compte qui a supprimé ; vide pour une suppression hors app), `data` (la
   session et ses six tables liées, en JSON : un objet pour la session, un tableau par table).
   Sécurité de niveau ligne (RLS) activée, aucune règle, aucun droit pour `anon` et
   `authenticated` : illisible depuis l'app, `super_admin` compris, sur le modèle de
   `legacy_player_emails` et `push_subscriptions`. Lecture accordée à `service_role` pour la
   sauvegarde (point 6).
2. **Déclencheur `sessions_archive_completed`** : `before delete on sessions`, seulement
   `when (old.status = 'completed')`. Il s'exécute avant la cascade, quand les lignes liées
   existent encore, et dans la même transaction que la suppression : si la suppression échoue,
   l'archive disparaît avec elle. La fonction est `security definer` (elle s'exécute avec les
   droits de son auteur, pas de celui qui supprime) : elle doit lire toutes les lignes liées et
   écrire dans une table fermée, quel que soit l'organisateur qui supprime. Parce qu'elle vit
   en base, la règle couvre tous les chemins de suppression : les quatre écrans, une requête SQL,
   une future suppression de compte (Q28). Une session brouillon ou en cours n'est jamais
   archivée.
3. **Photos gardées** (Q247) : la fiche d'historique n'efface plus les fichiers photo d'une
   session terminée qu'elle supprime. Si par extrême la fiche affiche une session non terminée
   (adresse saisie à la main), elle garde son comportement actuel et efface les fichiers. Les
   lignes `session_photos` sont dans l'archive ; les fichiers restent à leur place dans le
   stockage, miniatures comprises, et la restauration les retrouve tels quels.
4. **Restauration : fonction `restore_session_archive(p_session_id uuid)`**, écrite et testée
   dans cette étape (Q246). Exécutable seulement par le rôle d'administration de la base
   (éditeur SQL du tableau de bord Supabase, ou `npx supabase db query --linked`) : droit
   d'exécution retiré à `public`, `anon` et `authenticated`. Elle :
   - réinsère dans l'ordre : session (sans photo de couverture), `teams`, `session_members`,
     `team_players`, `played_holes`, `scores`, `session_photos`, puis la photo de couverture.
     Les colonnes calculées par la base (`location_lat`, `location_lng`) ne sont pas
     réinsérées. `team_players` est réinséré avec `on conflict do nothing` : pour une session
     sans Parcours, un déclencheur recrée déjà ces lignes à l'insertion des participants ;
   - gère trois conflits, peu coûteux à traiter :
     - **code de session réattribué** à une autre session entre-temps (de l'ordre d'une chance
       sur un milliard) : un nouveau code est tiré ;
     - **événement qui a déjà une autre session** (une seule par événement, Q223), ou
       événement supprimé : la session revient sans lien avec l'événement ;
     - **spot supprimé** : la session revient sans lien avec le spot ; le nom du lieu et la
       ville restent, ce sont des copies (Q182) ;
   - **refuse** la restauration, sans rien modifier, si un trou, un compte, un joueur ou
     l'association de la session a disparu entre-temps, avec un message qui nomme l'élément
     manquant. Cas jugé improbable : la restauration se fait dans les heures qui suivent (PO,
     Q246) ;
   - tout se fait en une transaction : un échec ne laisse aucune ligne à moitié restaurée ;
   - une fois la session restaurée, sa ligne d'archive est supprimée (une nouvelle suppression
     créerait une nouvelle archive).
5. **Conservation indéfinie** (Q248) : une archive pèse quelques Ko sans ses photos, qui
   restent dans le stockage. Aucune purge automatique.
6. **Sauvegarde** : `tool/export_remote_seed.dart` exporte `session_archives` dans le seed
   **chiffré** (`supabase/data_seed.sql.enc`), parce que l'archive contient des données
   personnelles (comptes, scores, comptes rendus). Sans cela, l'archive elle-même ne serait dans
   aucune sauvegarde.
7. **Une seule migration**, additive : nouvelle table, nouveau déclencheur, nouvelle fonction.
   Elle ne transforme ni ne supprime aucune donnée existante : pas de sauvegarde préalable
   obligatoire (règle 8), mais le PO est prévenu avant le `db push`. Les nouvelles fonctions
   n'appellent pas PostGIS : le plan est indépendant du plan 35, dans un ordre comme dans
   l'autre.
8. **Documentation** : `docs/DEV.md` gagne une section « Restaurer une session supprimée » :
   la requête qui liste les archives (date, auteur de la suppression, nom ou lieu, date de la
   session) et la commande de restauration.

## Étapes

1. Migration `<horodatage>_session_archives.sql` (`npx supabase migration new
   session_archives`) : table, droits, fonction et déclencheur d'archive, fonction de
   restauration.
2. `history_repository.dart` / `history_detail_page.dart` : ne plus effacer les fichiers photo
   d'une session terminée.
3. `tool/export_remote_seed.dart` : export de `session_archives` dans le seed chiffré.
4. `supabase/tests/rls_smoke.sql` : section « plan 36 » (tests ci-dessous).
5. `docs/DEV.md` : section de restauration. `AGENTS.md` : une ligne dans les conventions
   (archive des sessions terminées, illisible par l'app).
6. `fvm dart format`, `fvm flutter analyze --fatal-infos`, `fvm flutter test`.
7. Annonce au PO de ce que change la migration, puis, sur son accord : `npx supabase db push`
   et `rls_smoke.sql`. Les lance celui des deux qui a accès à la base : la session cloud de
   l'assistant n'a ni `env/migration.json` ni projet Supabase lié (constaté le 2026-10-05).

## Tests (`rls_smoke.sql`, section plan 36)

- Supprimer une session **brouillon**, puis une session **en cours** : aucune archive.
- Terminer une session de test complète (équipes, participants dont un non venu, trous joués,
  scores, photo et photo de couverture, lien avec un événement, championnat, compte rendu),
  la supprimer en tant qu'organisateur : une archive, `deleted_by` = l'organisateur, autant de
  lignes archivées que de lignes supprimées dans chaque table.
- En tant que compte connecté (organisateur, membre, `super_admin`) : lecture de
  `session_archives` et appel de la restauration refusés.
- Restaurer : chaque table retrouve exactement ses lignes d'avant (comparaison ligne à ligne,
  `checked_in_at`, `cover_photo_id`, `is_championship`, `tags` et `comment` compris) ; l'archive
  est supprimée.
- Session **sans Parcours** terminée : suppression et restauration sans doublon dans
  `team_players`.
- Conflits : code repris par une autre session → nouveau code ; événement qui a déjà une autre
  session → restaurée sans lien ; trou supprimé entre-temps → refus, aucune ligne insérée,
  archive intacte.

## Critères d'acceptation

- [ ] Supprimer une session brouillon ou en cours : comportement inchangé, rien d'archivé.
- [ ] Supprimer une session terminée, depuis n'importe quel écran : archive complète, fichiers
      photo gardés dans le stockage.
- [ ] L'archive est illisible depuis l'app, pour tout compte.
- [ ] La restauration remet la session à l'identique, photos comprises, pour tous ses
      participants ; l'archive est retirée.
- [ ] Code réattribué, événement déjà pris et spot supprimé sont gérés ; un trou ou un compte
      manquant fait échouer la restauration sans rien modifier.
- [ ] La sauvegarde chiffrée contient les archives.
- [ ] `flutter analyze` sans avertissement, tests verts, `rls_smoke.sql` entièrement vert,
      build Vercel vert.
- [ ] `docs/DEV.md` documente la restauration ; `AGENTS.md` relu et mis à jour.
- [ ] Essai par le PO : supprimer une session terminée de test, demander sa restauration,
      vérifier qu'elle revient avec ses scores et ses photos.

## Hors périmètre

- Aucun écran de restauration ni de corbeille dans l'app (Q244).
- Suppression isolée d'une photo, d'un trou joué, d'une équipe, d'un participant : pas
  archivée, définitive comme aujourd'hui.
- Suppression d'un événement, d'un trou, d'un spot, d'une association : inchangée.
- Qui peut supprimer une session terminée : inchangé (organisateurs de la session).
