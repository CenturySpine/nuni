# Plan 02 — Bootstrap du projet Flutter web, structure du dépôt, CI

## Objectif

Disposer d'un squelette Flutter web propre, committé sur `main`, avec une intégration continue
qui analyse, teste et construit le site. Ce sont les "premiers commits techniques" qui permettent
de lier le dépôt GitHub au futur projet Vercel (plan 11).

## Prérequis

Plan 01 terminé.

## Décisions retenues

- Flutter stable épinglé (FVM), Dart 3, cible `web` uniquement (`flutter create --platforms web`).
- Nom de package Dart : `nuni`. Titre affiché : "NUNI", sous-titre "Never Up, Never In".
- Architecture par fonctionnalité (feature-first), simple et plate :
  ```
  lib/
    main.dart, app.dart
    core/        (config, supabase client, thème, i18n, routeur, utilitaires)
    features/
      auth/  profile/  holes/  sessions/  live/  join/  history/  exports/
      <feature>/ data/ (repositories, DTO)  domain/ (modèles, règles)  ui/ (écrans, widgets)
    shared/      (widgets communs)
  test/          (mêmes sous-dossiers)
  ```
- Gestion d'état : Riverpod (avec `riverpod_generator`) — standard actuel, testable, adapté aux
  flux temps réel. Alternative équivalente : Bloc ; non retenue pour limiter le code cérémonial.
- Navigation : `go_router` (nécessaire pour les liens profonds `/join/CODE`, `/session/ID`).
- Modèles immuables : `freezed` + `json_serializable`.
- Supabase : `supabase_flutter`.
- Qualité : `flutter_lints` (règles par défaut + `very_good_analysis` non retenu pour rester
  simple), `dart format` en pré-commit via un hook léger ou simplement en CI.
- Configuration par environnement : `--dart-define-from-file` (`env/dev.json`, `env/prod.json`),
  fichiers ignorés par git, gabarit `env/example.json` committé.
- CI GitHub Actions **minimale** (Q17, PO 2026-09-15) : un seul workflow `ci.yml`, un seul job,
  déclenché par tout push (toutes branches), avec `subosito/flutter-action@v2` et
  `flutter-version-file: .fvmrc` (lecture de `.fvmrc` prise en charge par l'action, vérifié le
  2026-09-15 dans son README), étapes `pub get`, `analyze`, `test`, `build web --release`. Pas d'artefact : le déploiement
  Vercel (plan 11) est ajouté à ce même job juste après ce plan. Annulation automatique d'un run
  remplacé par un push plus récent sur la même branche (`concurrency`). Les modifications limitées
  à `docs/**` et aux `*.md` ne déclenchent pas le workflow.
- Pas de protection de branche, pas de PR obligatoire (Q17) : le PO pousse directement sur `main` ;
  la coche rouge du workflow et la notification GitHub sont le seul garde-fou. Les branches
  `claude/...` se fusionnent librement (bouton GitHub ou fusion locale).

## Étapes

1. `flutter create --platforms web --org org.centuryspine --project-name nuni .` dans le dépôt,
   puis nettoyage du code de démo.
2. `.gitignore` Flutter standard + `env/*.json` (sauf `example.json`) + `.fvm/` (garder `.fvmrc`).
3. Dépendances initiales dans `pubspec.yaml` :
   - runtime : `flutter_riverpod`, `riverpod_annotation`, `go_router`, `supabase_flutter`,
     `freezed_annotation`, `json_annotation`, `intl`, `flutter_localizations`.
   - dev : `build_runner`, `riverpod_generator`, `freezed`, `json_serializable`, `flutter_lints`,
     `mocktail`.
   - Les paquets propres à chaque fonctionnalité (géoloc, images, PDF, QR) sont ajoutés dans les
     plans concernés, pas ici.
4. `package.json` minimal à la racine avec `supabase` et `vercel` en devDependencies (versions
   fixes) pour que `npx supabase` et `npx vercel` soient reproductibles.
5. `web/index.html` et `web/manifest.json` : titre NUNI, description, couleur de thème provisoire,
   icônes provisoires (le logo définitif arrive au plan 11).
6. Page d'accueil provisoire "NUNI — Never Up, Never In" (sert de preuve de déploiement).
7. `analysis_options.yaml` (flutter_lints), un test widget de fumée.
8. Workflow `.github/workflows/ci.yml` : sur tout push (hors `docs/**` et `*.md`) → `pub get`,
   analyze, test, build web. Le déploiement est ajouté au plan 11, étape 1.
9. Premier commit et push sur `main`. Aucune protection de branche (Q17).
10. `AGENTS.md` à la racine (créé par anticipation le 2026-09-15 à la demande du PO ; à compléter à
    cette étape avec les commandes réelles) : instructions pour les assistants de code (convention multi-outils),
    et `CLAUDE.md` réduit à une ligne d'import `@AGENTS.md` pour que Claude Code lise le même
    fichier. Contenu prévu, court et factuel :
    - ce qu'est NUNI en trois lignes, et le renvoi vers `docs/plans/00_plan_ensemble.md`,
      `docs/QUESTIONS_PO.md` et `docs/design/PALETTE.md` ;
    - règle de travail : plans validés avant implémentation ; tout doute devient une question
      dans `QUESTIONS_PO.md` avec une suggestion technique, jamais une décision silencieuse ;
      priorité aux fonctionnalités, simplicité ;
    - ton des échanges avec le PO : factuel et synthétique ; pas d'excuses, pas de complaisance,
      pas de flatterie ; toujours supposer que le PO ne connaît pas la technique : expliquer les
      conséquences d'un choix en termes d'usage, pas de mécanique interne, et développer une
      notion technique en une phrase la première fois qu'elle apparaît ; une suggestion par
      question, argumentée par la technique et l'état de l'art, jamais par une préférence ;
      annoncer ce qui a été fait, ce qui ne l'a pas été et pourquoi, sans hedging ;
    - pas de contournement par défaut : quand une action échoue faute de droits, de
      configuration ou de prérequis, demander d'abord au PO de faire l'action nécessaire pour
      procéder proprement (élévation, réglage système, création d'un compte ou d'un jeton) ;
      un contournement n'est mis en œuvre que si cette voie échoue, et il est alors documenté
      comme tel dans le plan concerné ;
    - ancien dépôt LsgScores (`C:\Users\bruno\repos\LsgSessionsScores`, app Android de
      référence ; la web app `web-guest` ne fait pas foi) : consultable en **lecture seule**,
      uniquement pour instruire une question avant de la poser au PO (comprendre le comportement
      existant, citer le fichier concerné). Interdits absolus : y écrire, et s'en servir pour
      répondre soi-même à une question ou prendre une décision sans intervention du PO. Ce que
      faisait l'ancienne app est une information, jamais une réponse ;
    - commandes : lancer (`fvm flutter run -d chrome --dart-define-from-file=env/dev.json`),
      générer (`dart run build_runner build -d`), analyser, tester, construire, migrations
      Supabase (`npx supabase db push`) ;
    - conventions de code : architecture feature-first (`core/`, `features/<x>/{data,domain,ui}`,
      `shared/`), Riverpod + go_router + freezed, commentaires en anglais, chaînes visibles
      toujours dans les ARB EN et FR (jamais en dur), aucune `Color(0x…)` hors `core/theme`,
      palette active uniquement via `activePalette` ;
    - interdits : secrets dans le dépôt (`env/*.json` ignorés), réglage de thème exposé à
      l'utilisateur, table de modes de scoring en base, table de lien user↔joueur ;
    - définition de "terminé" : `analyze` sans avertissement, tests verts, CI verte, chaînes
      traduites dans les deux langues.
    Le fichier est relu et mis à jour à la fin de chaque étape du plan d'ensemble.
11. Créer une release "v0.0.0-bootstrap" (tag) pour marquer le point de départ.

## Journal d'exécution (2026-09-15)

Réalisé depuis la session Claude Code web (conteneur Linux, Flutter 3.47.4 téléchargé et vérifié
par empreinte SHA-256, même version que le poste du PO) sur la branche
`claude/github-actions-vercel-flutter-ed5oji`.

- Squelette généré par `flutter create --platforms web --org org.centuryspine --project-name
  nuni`, seuls `web/`, `.metadata` et la base de `pubspec.yaml` / `analysis_options.yaml` sont
  repris ; le code de démo n'entre pas dans le dépôt.
- `.fvmrc` épingle `3.47.4` (et non `stable`, pour que la CI et le poste compilent la même
  version). Sur le poste : `fvm install` lit ce fichier.
- Dépendances de la liste ci-dessus ajoutées par `flutter pub add` (versions résolues dans
  `pubspec.lock`, committé), plus `cupertino_icons` (police d'icônes attendue par une dépendance,
  sinon avertissement au build).
- Traductions dès le départ : `l10n.yaml`, `lib/l10n/app_en.arb` et `app_fr.arb`, code généré
  dans `lib/l10n/generated/` par `flutter pub get` (dossier ignoré par git).
- Palette : `lib/core/theme/palettes.dart` avec 03-B active ; les quatre autres variantes viables
  sont ajoutées au plan 04. Thème provisoire `lib/core/theme/app_theme.dart`.
- Page d'accueil provisoire `lib/features/home/ui/home_page.dart`, routeur `go_router` à une
  route, `ProviderScope` Riverpod dans `main.dart`.
- `analysis_options.yaml` : `flutter_lints` + modes stricts de l'analyseur + `prefer_single_quotes`.
  Test de fumée `test/app_test.dart`.
- CI `.github/workflows/ci.yml` : un job, tout push hors docs, `pub get`, `dart format
  --set-exit-if-changed`, `analyze --fatal-infos`, `test`, `build web --release` avec
  `env/prod.json` écrit depuis les secrets (vides jusqu'au plan 11).
- `package.json` + `package-lock.json` : `supabase` 2.117.0 et `vercel` 59.17.0 épinglés.
- Vérifié dans le conteneur : format OK, `analyze --fatal-infos` sans remarque, test vert,
  `build web --release` en 61 s, `build/web/version.json` = `0.1.0+1`.
- Constat au premier affichage du site construit (servi en local, Chromium sans accès à Google) :
  page blanche, parce que le build charge par défaut le moteur de rendu CanvasKit depuis
  `www.gstatic.com`. Corrigé par `--no-web-resources-cdn` (CanvasKit servi depuis le site,
  copie déjà présente dans `build/web/canvaskit/`), question Q22 ouverte avec cette hypothèse
  appliquée. Capture après correction : `docs/reference/plan02_home.png`.
- Étape 9 adaptée : premier push sur la branche de session, fusion dans `main` par le PO (les
  branches `claude/...` ne poussent pas sur `main`). Étape 11 (tag `v0.0.0-bootstrap`) : à poser
  par le PO sur le commit de fusion dans `main`.

## Livrables

- Dépôt avec squelette, CI verte, tag de départ, `AGENTS.md` (+ `CLAUDE.md` qui l'importe).
- `docs/DEV.md` : comment lancer en local (`flutter run -d chrome --dart-define-from-file=env/dev.json`),
  générer le code (`dart run build_runner build -d`), lancer les tests.

## Critères d'acceptation

- [ ] `flutter run -d chrome` affiche la page d'accueil provisoire (à constater par le PO sur son
  poste ; dans le conteneur, la page construite a été servie et capturée, voir
  `docs/reference/plan02_home.png`).
- [x] Le workflow CI passe : run n° 1 vert sur la branche de session en 3 min 15 s
  (https://github.com/CenturySpine/nuni/actions/runs/34936093556), dont 65 s d'installation de
  Flutter sans cache ; il passera sur `main` à la fusion.
- [x] Aucun secret dans l'historique git.

## Questions PO liées

Aucune. Q17 est tranchée (2026-09-15) : Actions compile, Vercel héberge, push direct sur `main`.
Le déploiement s'ajoute au job de `ci.yml` au plan 11, étape 1.
