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

## Photos : miniatures et réduction (plan 30)

Chaque photo de trou ou de session a une miniature de 256 px rangée à côté d'elle
(`<chemin>.thumb.jpg`), créée par l'app à l'envoi et lue par les listes. Pour les photos
envoyées avant le plan 30, lancer une fois le script de reprise, après la mise en ligne de
l'app du plan 30. Il crée les miniatures manquantes et réduit à 1600 px les photos plus
larges (celles importées de LsgScores). Relançable sans effet de bord ; le stockage survit
aux reconstructions du schéma, donc inutile de le relancer après l'une d'elles.
Nécessite `env/migration.json` (clé service NUNI).

```powershell
fvm dart run tool/backfill_photo_thumbnails.dart --dry-run   # compte sans rien écrire
fvm dart run tool/backfill_photo_thumbnails.dart
```

## Supabase : modifier le schéma (migrations additives, depuis la version 1.0.0)

Depuis le 2026-09-27 (version 1.0.0, décision du PO), la base de production contient des
données réelles et **n'est plus jamais reconstruite**. Les fichiers déjà présents dans
`supabase/migrations` sont appliqués en production : **ne plus jamais les modifier**. Tout
changement de schéma, de RLS, de RPC ou de déclencheur passe par un **nouveau** fichier de
migration, qui modifie l'existant (`alter table`, `create or replace function`, `drop ... if
exists`, `create policy`...).

```powershell
# 1. Créer la migration (nom en anglais, horodaté par le CLI).
npx supabase migration new add_something

# 2. L'écrire, la relire, et prévenir le PO de ce qu'elle change pour les utilisateurs.
#    Si elle transforme ou supprime des données : sauvegarder d'abord (étape 3).

# 3. Sauvegarde des données réelles (toujours utile avant une migration qui touche des données) :
#    supabase/remote_seed.sql (trous, en clair) et supabase/data_seed.sql.enc (le reste,
#    chiffré). Nécessite env/migration.json et env/seed.json. Ne jamais committer une copie
#    déchiffrée.
fvm dart run tool/export_remote_seed.dart

# 4. Appliquer : le CLI ne pousse que les migrations pas encore appliquées.
npx supabase db push

# 5. Vérifier les droits : crée des données de test jetables, les supprime à la fin ; chaque
#    ligne du résultat doit avoir passed = true.
npx supabase db query --linked -f supabase/tests/rls_smoke.sql
```

Une migration qui modifie une fonction reprend sa définition complète (`create or replace`) ;
une fonction dont la signature change se supprime d'abord (`drop function if exists
public.<nom>(<paramètres>)`). Les commentaires restent en anglais, comme le code.

L'ancienne procédure de reconstruction complète (avant 1.0.0) figure dans l'historique git de ce
fichier ; elle ne doit plus être utilisée.
