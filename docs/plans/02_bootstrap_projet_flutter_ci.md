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
- CI GitHub Actions : `subosito/flutter-action` (lit `.fvmrc`), étapes `pub get`, `analyze`,
  `test`, `build web --release`, artefact `build/web`. Déploiement Vercel ajouté au plan 11.

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
8. Workflow `.github/workflows/ci.yml` : sur push `main` et PR → analyze, test, build web, upload
   artefact.
9. Premier commit et push sur `main` ; protection de branche légère (PR obligatoire, CI verte)
   via `gh api` ou l'interface GitHub.
10. `AGENTS.md` à la racine : instructions pour les assistants de code (convention multi-outils),
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

## Livrables

- Dépôt avec squelette, CI verte, tag de départ, `AGENTS.md` (+ `CLAUDE.md` qui l'importe).
- `docs/DEV.md` : comment lancer en local (`flutter run -d chrome --dart-define-from-file=env/dev.json`),
  générer le code (`dart run build_runner build -d`), lancer les tests.

## Critères d'acceptation

- `flutter run -d chrome` affiche la page d'accueil provisoire.
- Le workflow CI passe sur `main`.
- Aucun secret dans l'historique git.

## Questions PO liées

Aucune bloquante. Q17 (mode de build Vercel) est traitée au plan 11 mais influence la présence
d'un job de déploiement dans `ci.yml`.
