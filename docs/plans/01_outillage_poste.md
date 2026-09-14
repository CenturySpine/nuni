# Plan 01 — Outillage du poste de travail

## Objectif

Rendre le poste Windows 11 capable de développer, tester et déployer une PWA Flutter adossée à
Supabase, et de piloter GitHub, Supabase et Vercel en ligne de commande.

## État constaté (2026-09-14)

Aucun des outils suivants n'est présent sur le PATH ni dans Program Files : git, flutter, dart,
node, npm, java, gh, supabase, vercel, code. Seul `winget` est disponible. Chrome semble installé
(dossier Google dans Program Files, à confirmer). Aucun SDK Android ni Java n'est nécessaire :
la cible est le web uniquement.

Le dépôt `C:\Users\bruno\repos\nuni` est un clone vide (aucun commit, branche `main`, remote
`origin` = https://github.com/CenturySpine/nuni.git).

## Décisions retenues

- Installation par `winget` partout où un paquet fiable existe (Git, GitHub CLI, Node LTS, VS Code,
  FVM).
- Q19 tranchée : Flutter via FVM, version épinglée dans le dépôt (`.fvmrc`), canal `stable`.
- Supabase CLI installé via npm en dépendance de développement (`npx supabase`), ce qui évite un
  gestionnaire supplémentaire (Scoop) et fixe la version dans le dépôt.
- Vercel CLI via npm global.
- Éditeur : VS Code avec l'extension Flutter (optionnel, mais recommandé pour le debug web).

## Journal d'exécution (2026-09-14 → 2026-09-15)

- Les installeurs winget de Git, GitHub CLI et Node exigent l'élévation administrateur, que le
  terminal de Claude ne peut pas valider : lancés par le PO dans un PowerShell administrateur.
  Résultat réel : Git 2.55.0, GitHub CLI 2.100.0, Node 24.19.0 (npm 11.17.0).
- FVM absent de winget (la 4e commande n'a rien installé).
- Réglages faits par le PO : stratégie d'exécution PowerShell `RemoteSigned` (CurrentUser),
  Mode développeur Windows activé (requis par les liens symboliques de FVM), `gh auth login`
  (CenturySpine), `npx supabase login`.
- Constat important : le terminal de Claude s'exécute dans un bac à sable. Les écritures dans le
  profil utilisateur (`AppData`, `%USERPROFILE%\fvm`) y sont isolées et n'atteignent pas le
  système du PO ; les écritures dans le dépôt et dans le registre (PATH utilisateur) sont
  réelles. Conséquence : l'installation de Vercel CLI (`npm install -g`), du binaire FVM et de
  Flutter (`fvm install stable`) faite depuis ce terminal n'existe pas sur le poste, bien que
  `flutter doctor` et une compilation web de test aient réussi dans le bac à sable. Vérifié par le
  PO avec `Test-Path` depuis son propre terminal.
- PATH utilisateur (réel) complété : `%APPDATA%\npm`, `%LOCALAPPDATA%\fvm\bin`,
  `%USERPROFILE%\fvm\default\bin`.
- 2026-09-15 : le PO a installé depuis son terminal Vercel CLI 59.17.0 (`npm install -g vercel`), le
  binaire FVM 4.3.1, Flutter 3.47.4 stable (`fvm install stable --setup`, `fvm global stable`), et fait
  `vercel login`. `flutter doctor -v` réel archivé dans `docs/reference/flutter_doctor.txt` :
  Flutter et Chrome verts, Android et Visual Studio en croix (hors périmètre web).
- **Étape 1 close le 2026-09-15.** Le critère `flutter run -d chrome` sera constaté à l'étape 2 sur
  le vrai squelette plutôt que sur une app de test.

## Étapes

1. Git et GitHub CLI
   ```powershell
   winget install --id Git.Git -e
   winget install --id GitHub.cli -e
   ```
   Rouvrir un terminal, puis `git --version`, `gh --version`, `gh auth login` (navigateur),
   `git config --global user.name` / `user.email`.
2. Node LTS (pour Vercel CLI et Supabase CLI)
   ```powershell
   winget install --id OpenJS.NodeJS.LTS -e
   ```
   Vérifier `node --version`, `npm --version`.
3. Flutter
   - Option retenue (Q19) : FVM. Constat du 2026-09-14 : FVM n'est pas publié sur winget ;
     installation par le binaire officiel des releases GitHub (`fvm-<version>-windows-x64.zip`,
     ~4 Mo) extrait dans `%LOCALAPPDATA%\fvm\bin`, sans droits administrateur. Puis
     `fvm install stable --setup`, `fvm global stable`, et dans le dépôt `fvm use stable`.
     Ajouter `%LOCALAPPDATA%\fvm\bin` et `%USERPROFILE%\fvm\default\bin` au PATH utilisateur
     pour disposer de `fvm`, `flutter` et `dart` globalement.
   - Option de repli : télécharger l'archive stable depuis flutter.dev, décompresser dans
     `C:\dev\flutter`, ajouter `C:\dev\flutter\bin` au PATH.
   - `flutter doctor` : seules les lignes Flutter, Chrome et VS Code doivent être vertes ; ignorer
     Android toolchain, Visual Studio et Android Studio (non requis pour le web).
   - `flutter config --enable-web` si nécessaire (activé par défaut sur stable).
4. Chrome : vérifier `flutter devices` liste "Chrome (web)". Sinon `winget install Google.Chrome`.
5. Vercel CLI
   ```powershell
   npm install -g vercel
   vercel login
   ```
6. Supabase CLI : installé à l'étape 2 du plan 02 en dépendance npm du dépôt ; ici seulement
   `npx supabase --version` pour valider que npx fonctionne. `npx supabase login` (jeton
   d'accès personnel généré sur le tableau de bord Supabase).
7. VS Code (optionnel)
   ```powershell
   winget install --id Microsoft.VisualStudioCode -e
   code --install-extension Dart-Code.flutter
   ```
8. Secrets : aucun secret dans le dépôt. Les clés Supabase (URL, clé anon) seront passées à
   Flutter par `--dart-define-from-file=env/dev.json` (fichier ignoré par git) et par secrets
   GitHub Actions en CI.

## Livrables

- Tous les outils répondent depuis un nouveau terminal PowerShell.
- `flutter doctor -v` archivé dans `docs/reference/flutter_doctor.txt` (sans données sensibles).
- Comptes connectés : `gh auth status`, `vercel whoami`, `npx supabase projects list`.

## Critères d'acceptation

- `flutter create --platforms web /tmp/probe && cd /tmp/probe && flutter run -d chrome` affiche
  l'app de démonstration dans Chrome.
- `gh repo view CenturySpine/nuni` fonctionne.

## Questions PO liées

- Q19 (FVM ou archive).
