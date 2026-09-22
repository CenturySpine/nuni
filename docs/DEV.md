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
# 1. Supprimer les objets créés par les migrations (tables, types, fonctions, politiques de
#    stockage). Ne touche pas aux droits Supabase sur le schéma "public" lui-même, ni aux
#    buckets (leur suppression directe en SQL est bloquée par Supabase ; les recréer est sans
#    effet grâce à "on conflict do nothing").
npx supabase db query --linked -f chemin/vers/reset.sql

# 2. Vider l'historique des migrations pour que le CLI les rejoue toutes.
npx supabase db query --linked "delete from supabase_migrations.schema_migrations where version like '2026%';"

# 3. Repousser les fichiers modifiés depuis zéro.
npx supabase db push

# 4. Obligatoire : recréer la fiche "players" de chaque compte Google déjà inscrit
#    (supabase/backfill_players.sql, committé). La table "players" est recréée vide comme les
#    autres ; le déclencheur qui la peuple ne s'exécute qu'à l'inscription, jamais rétroactivement
#    — sans cette étape, tout compte inscrit avant la reconstruction perd sa fiche (nom, avatar,
#    langue) et la page Profil casse pour lui. Sans effet si la fiche existe déjà.
npx supabase db query --linked -f supabase/backfill_players.sql

# 5. Obligatoire : reposer le rôle "super_admin" du PO (supabase/seed_super_admin.sql, committé,
#    plan 16). La table "user_roles" est recréée vide comme les autres — sans cette étape,
#    personne n'a de droit élevé après une reconstruction. Sans effet si la ligne existe déjà.
npx supabase db query --linked -f supabase/seed_super_admin.sql

# 6. Optionnel : rejouer les trous de test du PO sur le projet distant (supabase/remote_seed.sql,
#    committé — différent de supabase/seed.sql, qui reste local-Docker uniquement, cf. son
#    en-tête). Sans effet si les lignes existent déjà ("on conflict do nothing").
npx supabase db query --linked -f supabase/remote_seed.sql
```

`auth.users` (les comptes Google eux-mêmes) n'est jamais touché par cette procédure : seul le
schéma applicatif (`public`, tables/fonctions/types/politiques de stockage) est reconstruit. C'est
justement pour ça que l'étape 4 est nécessaire : les comptes survivent, mais leur fiche `players`
liée ne survit pas telle quelle.

Le contenu de `reset.sql` (liste des `drop table/function/type ... cascade` et `drop policy on
storage.objects`) se déduit des fichiers de migration au moment du changement ; il n'est pas
committé (fichier de travail temporaire).

Après la mise en service, cette procédure disparaît : les migrations redeviennent additives, plus
jamais d'édition d'un fichier déjà appliqué en production.
