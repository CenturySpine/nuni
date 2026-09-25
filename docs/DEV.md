# Développer NUNI en local

Prérequis : plan 01 (FVM, Flutter 3.47.4 stable, Node, CLIs GitHub / Supabase / Vercel).

## Première fois

```powershell
fvm install                      # lit .fvmrc et installe la version épinglée (3.47.4)
fvm flutter pub get              # dépendances + génération des traductions (lib/l10n/generated)
npm install                      # CLIs supabase et vercel épinglées (npx supabase, npx vercel)
Copy-Item env/example.json env/dev.json   # puis renseigner SUPABASE_URL et SUPABASE_ANON_KEY
```

`env/dev.json` et `env/prod.json` sont ignorés par git. Ne jamais committer une clé.

## Au quotidien

```powershell
fvm flutter run -d chrome --web-port 3000 --dart-define-from-file=env/dev.json   # port fixe : URL de retour Google/Supabase
fvm dart run build_runner build -d                               # régénérer freezed / riverpod / json
fvm dart format lib test                                         # formater (la CI refuse un fichier non formaté)
fvm flutter analyze --fatal-infos                                # aucune remarque tolérée
fvm flutter test                                                 # tests unitaires et widgets
fvm flutter build web --release --no-web-resources-cdn --dart-define-from-file=env/prod.json
```

Le build web produit `build/web/`, qui contient `version.json` (numéro de build lu par le bandeau de
mise à jour, plan 11). `--no-web-resources-cdn` fait servir le moteur de rendu CanvasKit depuis le
site lui-même au lieu d'un serveur Google (Q22) ; sans cette option, la page reste blanche dès que
ce serveur est inaccessible.

Pour vérifier le site construit sans Flutter : `python -m http.server 8765` dans `build/web`, puis
ouvrir http://127.0.0.1:8765/.

## Traductions

Les chaînes visibles sont dans `lib/l10n/app_en.arb` (référence, avec les descriptions) et
`lib/l10n/app_fr.arb`. Le code Dart est généré dans `lib/l10n/generated/` par `flutter pub get`
(dossier ignoré par git). Une chaîne ajoutée dans un seul fichier fait échouer l'analyse.

## Build et déploiement

Vercel est relié au dépôt GitHub. À chaque push sur `main`, il exécute `tool/vercel_build.sh` d'après `vercel.json` : installation de la
version Flutter de `.fvmrc`, `pub get`, analyze, test, build web. Un commit qui casse l'analyse ou
un test n'est pas déployé et le commit GitHub porte une coche rouge. `main` va en production sur
`nuni.centuryspine.org` ; pas de prévisualisation sur ce projet. `SUPABASE_URL` et `SUPABASE_ANON_KEY`
sont des variables d'environnement du projet Vercel. Pas de GitHub Actions.

Reproduire le build Vercel en local (Linux, macOS ou Git Bash) : `bash tool/vercel_build.sh`,
avec `FLUTTER_DIR` pointant sur un SDK déjà installé pour éviter le téléchargement.

## Supabase : modifier le schéma avant la première mise en service

Règle (AGENTS.md, point 8) : tant que `main` n'a pas été mis en service, `supabase/migrations`
n'est pas un historique à préserver mais le schéma courant. Un changement modifie directement le
fichier thématique existant (`..._tables.sql`, `..._rls.sql`, etc.), sans ajouter de nouveau
fichier. Le CLI suit les migrations déjà appliquées par nom de fichier, pas par contenu : éditer
un fichier déjà poussé sans le rejouer désynchronise le projet distant du dépôt. Il faut donc
reconstruire le schéma distant depuis zéro à chaque changement — **toujours prévenir le PO avant
de le faire**, même si c'est sans risque tant qu'aucune donnée réelle n'existe.

Procédure (projet distant `nuni`, pas de Docker local) :

```powershell
# 0. AVANT la reconstruction, obligatoire depuis le 2026-09-23 (Q63, Q73) : sauvegarder les
#    données réelles de la base en seeds, relire le diff et committer (avec l'accord du PO).
#    Produit supabase/remote_seed.sql (trous, en clair) et supabase/data_seed.sql.enc (joueurs,
#    sessions, équipes, trous joués, scores, photos de session, planning (événements, réponses,
#    commentaires, plan 23), administrateurs locaux (plan 27), e-mails de rattachement : chiffré,
#    le dépôt est public). Nécessite env/migration.json (clé service NUNI) et env/seed.json (mot
#    de passe du seed, gabarit env/seed.example.json, conservé aussi dans le KeePass du PO).
fvm dart run tool/export_remote_seed.dart

# 1. Supprimer les objets créés par les migrations (tables, types, fonctions, politiques de
#    stockage). Ne touche pas aux droits Supabase sur le schéma "public" lui-même, ni aux
#    buckets (leur suppression directe en SQL est bloquée par Supabase ; les recréer est sans
#    effet grâce à "on conflict do nothing").
npx supabase db query --linked -f chemin/vers/reset.sql

# 2. Vider l'historique des migrations pour que le CLI les rejoue toutes.
npx supabase db query --linked "delete from supabase_migrations.schema_migrations where version like '2026%';"

# 3. Repousser les fichiers modifiés depuis zéro.
npx supabase db push

# 4. Obligatoire : reposer le rôle "super_admin" du PO (supabase/seed_super_admin.sql, committé,
#    plan 16). La table "user_roles" est recréée vide comme les autres — sans cette étape,
#    personne n'a de droit élevé après une reconstruction. Sans effet si la ligne existe déjà.
npx supabase db query --linked -f supabase/seed_super_admin.sql

# 5. Obligatoire : rejouer les trous réels (supabase/remote_seed.sql, étape 0 ; différent de
#    supabase/seed.sql, qui reste local-Docker uniquement). Avant l'étape 6 : les trous joués
#    des sessions y font référence. Sans effet si les lignes existent déjà.
npx supabase db query --linked -f supabase/remote_seed.sql

# 5b. Obligatoire (plan 18) : rejouer les associations de départ (supabase/associations_seed.sql,
#    committé, données publiques). Avant l'étape 6 : joueurs et sessions y font référence.
npx supabase db query --linked -f supabase/associations_seed.sql

# 6. Obligatoire : rejouer les données (associations créées ou modifiées dans l'app,
#    responsables et leurs coordonnées, joueurs, sessions, championnats...) AVANT l'étape 7,
#    pour que chaque compte retrouve sa fiche d'origine (même identifiant, nom modifié conservé).
#    Déchiffrer dans build/ (ignoré par git), rejouer, puis effacer la copie en clair. Le
#    championnat d'une session est son association (plan 18), rejouée telle quelle ; la saison est
#    recalculée par la base. Sans effet si les lignes existent déjà (les associations de départ
#    sont mises à jour, pour garder les modifications faites dans l'app).
fvm dart run tool/export_remote_seed.dart --decrypt
npx supabase db query --linked -f build/seed/data_seed.sql
Remove-Item build/seed/data_seed.sql

# 6b. Une seule fois, à la reconstruction qui crée la table des spots (plan 28, Q185) : reprendre
#    les lieux saisis avant le plan 28 (zones des sessions, lieux des événements) en spots, et y
#    rattacher sessions et événements. Liste relue par le PO avant. Sans effet si rejoué ; inutile
#    ensuite, les spots faisant partie du seed de l'étape 6.
npx supabase db query --linked -f supabase/spots_backfill.sql

# 7. Obligatoire : créer la fiche "players" des comptes inscrits depuis le dernier export
#    (sans association : l'app leur demande d'en choisir une à la prochaine ouverture)
#    (supabase/backfill_players.sql, committé). Le déclencheur qui la peuple ne s'exécute qu'à
#    l'inscription, jamais rétroactivement ; sans effet pour un compte qui a déjà sa fiche.
npx supabase db query --linked -f supabase/backfill_players.sql

# 8. Secours seulement (tant que l'ancien projet LsgScores existe) : réimporter trous et sessions
#    de LsgScores si le seed est perdu ou illisible. Après les étapes 5 et 6, n'insèrent rien
#    (identifiants stables, « Generic » exclu). Nécessite env/migration.json.
fvm dart run tool/migrate_lsgscores.dart holes
fvm dart run tool/migrate_lsgscores.dart sessions
```

`auth.users` (les comptes Google eux-mêmes) n'est jamais touché par cette procédure : seul le
schéma applicatif (`public`, tables/fonctions/types/politiques de stockage) est reconstruit. C'est
justement pour ça que les étapes 6 et 7 sont nécessaires : les comptes survivent, mais leur fiche `players`
liée ne survit pas telle quelle.

Le contenu de `reset.sql` (liste des `drop table/function/type ... cascade` et `drop policy on
storage.objects`) se déduit des fichiers de migration au moment du changement ; il n'est pas
committé (fichier de travail temporaire).

**Règle d'écriture de `reset.sql` (PO, 2026-09-25) : une ligne par objet, chaque objet nommé.**
Relever les noms dans les migrations (`create table`, `create or replace function`, `create
type`, `create policy ... on storage.objects`, le déclencheur `on_auth_user_created` sur
`auth.users`) et écrire un `drop ... if exists <nom> cascade;` pour chacun. **Jamais de boucle
qui supprime « tout ce qui existe »** (par exemple un bloc `do $$ ... for r in select ... from
pg_proc ... loop execute 'drop function ...'`). Deux raisons :
- une liste nommée ne supprime que ce que les migrations recréent : rien d'autre dans la base
  (fonction d'une extension, objet ajouté à la main) ne peut partir par erreur ;
- le contrôle automatique des permissions de Claude Code refuse une suppression en masse sans
  liste (motif « Cloud Storage Mass Delete », constaté le 2026-09-25 au plan 27), alors qu'il
  a toujours accepté les listes nommées des reconstructions précédentes.
Une fonction du schéma sans surcharge se supprime par son seul nom (`drop function if exists
public.<nom> cascade;`) ; si deux fonctions portent le même nom, écrire leurs paramètres.
Quand une migration supprime ou renomme un objet, ajouter aussi son **ancien** nom à la liste
de la reconstruction qui suit, sinon il reste dans la base.

Après la mise en service, cette procédure disparaît : les migrations redeviennent additives, plus
jamais d'édition d'un fichier déjà appliqué en production.
