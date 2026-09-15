# AGENTS.md — instructions pour les assistants de code

Ce fichier s'adresse à tout assistant de code (Claude Code, Codex, Copilot, etc.) qui travaille
dans ce dépôt. `CLAUDE.md` l'importe tel quel. Il est relu et mis à jour à la fin de chaque
étape du plan d'ensemble.

## Le projet en trois lignes

NUNI ("Never Up, Never In") est une PWA Flutter de scoring collaboratif de sessions de street
golf, adossée à Supabase, hébergée sur Vercel (nuni.centuryspine.org). C'est un recodage des
fonctionnalités de l'app Android LsgScores, pas un portage à l'identique.

Documents de référence, à lire avant d'agir :
- `docs/plans/00_plan_ensemble.md` : les étapes ordonnées, chacune avec son plan détaillé.
- `docs/QUESTIONS_PO.md` : toutes les décisions prises et les questions ouvertes.
- `docs/design/PALETTE.md` : palettes et décision de thème.
- `docs/reference/features_lsgscores_android.md` : inventaire fonctionnel de l'ancienne app.

## Règles de travail

1. **Plans avant code.** On n'implémente qu'une étape dont le plan a été validé par le product
   owner (PO), dans l'ordre du plan d'ensemble.
2. **Tout doute devient une question au PO**, écrite dans `docs/QUESTIONS_PO.md` avec une
   suggestion argumentée par la technique, les patterns et l'état de l'art Flutter/Supabase,
   jamais par une préférence. Aucune décision silencieuse. Tant qu'une question est ouverte, le
   plan applique la suggestion comme hypothèse et le dit.
3. **Pas de contournement par défaut.** Quand une action échoue faute de droits, de configuration
   ou de prérequis, demander d'abord au PO de faire l'action propre (élévation, réglage système,
   jeton, compte). Un contournement n'est mis en œuvre que si cette voie échoue, avec l'accord du
   PO, et il est documenté comme tel dans le plan concerné.
4. **Ancien dépôt LsgScores** (`C:\Users\bruno\repos\LsgSessionsScores`, app Android de référence ;
   la web app `web-guest` ne fait pas foi) : consultable en **lecture seule**, uniquement pour
   instruire une question avant de la poser (comprendre le comportement existant, citer le
   fichier). Interdits absolus : y écrire, et s'en servir pour répondre soi-même à une question
   ou décider sans le PO. Ce que faisait l'ancienne app est une information, jamais une réponse.
5. **Priorité aux fonctionnalités, pas à la technique.** Simplicité partout. Toute brique
   technique peut être remplacée si elle simplifie.
6. **Terminal de l'assistant :** ses écritures dans le profil utilisateur (`AppData`,
   `%USERPROFILE%\fvm`) peuvent être isolées dans un bac à sable et invisibles du système du PO ;
   ses écritures dans le dépôt et le registre sont réelles. Ne jamais conclure qu'un outil est
   installé sur le poste à partir d'une vérification faite depuis ce terminal ; demander au PO de
   vérifier ou d'installer depuis le sien. Recharger le PATH depuis le registre avant d'appeler
   git, gh, node, npx.

## Ton des échanges avec le PO

- Factuel et synthétique. Pas d'excuses, pas de complaisance, pas de flatterie.
- Toujours supposer que le PO ne connaît pas la technique : expliquer les conséquences d'un choix
  en termes d'usage, pas de mécanique interne ; développer une notion technique en une phrase la
  première fois qu'elle apparaît.
- Une suggestion par question, argumentée par la technique et l'état de l'art.
- Annoncer ce qui a été fait, ce qui ne l'a pas été et pourquoi, sans hedging. Si une
  vérification n'a pas pu être faite, le dire en premier.
- Terminer chaque message par la liste des points en attente du PO, indépendants les uns des
  autres, sans en redemander un déjà tranché.
- **Aucun "point à vérifier" laissé en suspens.** Trois cas seulement, et la formulation dit
  lequel : (a) l'assistant peut vérifier lui-même, alors il vérifie avant d'écrire et rapporte le
  résultat et sa source ; (b) la vérification exige un prérequis du PO (droit, jeton, réglage,
  action sur son poste), alors il demande ce prérequis explicitement, en disant ce qu'il vérifiera
  ensuite ; (c) c'est une décision du PO, alors c'est une question, avec un point d'interrogation,
  dans la liste des points en attente. Une phrase dont le lecteur ne sait pas si c'est une
  question ou une affirmation, ni qui doit agir, est interdite.

## Commandes

Détail dans `docs/DEV.md`. Flutter 3.47.4 stable épinglé par `.fvmrc`.

```powershell
fvm install                                       # installe la version de .fvmrc
fvm flutter pub get                               # dépendances + génération l10n
fvm flutter run -d chrome --dart-define-from-file=env/dev.json
fvm dart run build_runner build -d                # génération freezed / riverpod / json
fvm dart format lib test
fvm flutter analyze --fatal-infos
fvm flutter test
fvm flutter build web --release --no-web-resources-cdn --dart-define-from-file=env/prod.json
npx supabase db push                              # migrations vers le projet nuni
npx supabase db diff -f <nom>                     # nouvelle migration depuis les changements
```

Environnement : `env/dev.json` et `env/prod.json` (ignorés par git) contiennent `SUPABASE_URL`
et `SUPABASE_ANON_KEY` ; `env/example.json` est le gabarit committé. La CI (`ci.yml`) enchaîne
`pub get`, format, analyze, test, build web à chaque push.

## Conventions de code

- Architecture feature-first : `lib/core/` (config, client Supabase, thème, i18n, routeur),
  `lib/features/<feature>/{data,domain,ui}`, `lib/shared/` (widgets communs), `test/` en miroir.
- État : Riverpod (`riverpod_generator`). Navigation : `go_router`. Modèles : `freezed` +
  `json_serializable`. Backend : `supabase_flutter`.
- Commentaires et identifiants de code en anglais. Documentation et échanges avec le PO en
  français.
- Chaînes visibles par l'utilisateur : toujours dans les fichiers ARB `app_en.arb` et `app_fr.arb`,
  jamais en dur. Une fonctionnalité n'est terminée que si ses chaînes existent dans les deux
  langues.
- Couleurs : aucune `Color(0x…)` hors `lib/core/theme/`. Les palettes sont dans
  `core/theme/palettes.dart` ; la palette active est désignée par la constante `activePalette`
  (03-B "Urban claire"). Pas de réglage de thème exposé à l'utilisateur.
- Modes de scoring et de jeu : énumérations dans le code, miroir des enums Postgres. Pas de table
  de référence en base.
- Lien utilisateur ↔ joueur : colonne `players.user_id` (nullable, unique). Pas de table de lien.
- Équipes : table de jointure `team_players` ; la taille d'équipe est une règle applicative.
- Calcul des scores et du classement en Dart, testé unitairement ; la base ne stocke que les
  valeurs saisies.
- Temps réel : abonnements Supabase filtrés par session, jamais sur une table entière.

## Interdits

- Secrets dans le dépôt (clés Supabase, jetons, identifiants OAuth). Le dépôt est **public**.
- Réglage de thème ou de palette exposé à l'utilisateur.
- Table `scoring_modes`, table de lien user↔joueur, tables villes/zones comme prérequis d'une
  session.
- Écrire dans l'ancien dépôt LsgScores.
- Commit ou push sans que le PO l'ait demandé ou accordé.
- Protection de branche ou PR obligatoire sur `main` (Q17) : le PO pousse directement sur `main`.

## Définition de "terminé"

`fvm flutter analyze` sans avertissement, tests verts, workflow `ci.yml` vert sur le commit (GitHub
Actions compile et livre à Vercel, Q17), chaînes traduites EN et FR,
critères d'acceptation du plan de l'étape cochés, plan et `QUESTIONS_PO.md` à jour, ce fichier
relu.
