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

## Journal d'exécution (2026-09-14)

- Les installeurs winget de Git, GitHub CLI et Node exigent l'élévation administrateur, que le
  terminal de Claude ne peut pas valider : ils ont été lancés par le PO dans un PowerShell
  administrateur. Résultat : Git 2.55.0, GitHub CLI 2.100.0, Node 24.19.0 (npm 11.17.0).
- FVM absent de winget → binaire GitHub 4.3.1 dans `%LOCALAPPDATA%\fvm\bin`.
- Vercel CLI 59.17.0 installé par `npm install -g vercel` (sans élévation).
- Chrome 153 déjà présent.
- PATH utilisateur complété : `%APPDATA%\npm`, `%LOCALAPPDATA%\fvm\bin`, `%USERPROFILE%\fvm\default\bin`.

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
