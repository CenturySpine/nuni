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
- `docs/design/PALETTE.md` : palette, typographie et règles d'usage des composants.
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
7. **`main` uniquement, pas de branche, pas de pull request.** Quand un commit est fait, c'est
   directement sur `main` : le PO travaille seul, aucune autre branche n'est poussée sur GitHub
   sauf demande explicite du PO. Si l'outil (Claude Code web) impose une branche de session
   `claude/...`, on ne la pousse pas ; si elle a été créée malgré tout, on la supprime sur GitHub
   une fois `main` à jour. Raison : Vercel construit chaque branche poussée, et une branche
   parallèle ne sert à rien à une personne seule. Aucune protection de branche (Q17).
   **"Petits pas, souvent" décrit le rythme auquel le PO pousse une fois qu'il a vu et accepté un
   résultat — ce n'est pas un feu vert pour committer sans lui demander (règle 2026-09-16
   ci-dessous, déjà présente dans les Interdits mais mal appliquée en pratique : ne pas la
   relâcher au prétexte de petits pas fréquents).**
7bis. **Jamais de commit ni de push sans demande explicite du PO, pour aucune tâche, aucune
   dérogation** (rappel renforcé le 2026-09-16 après une dérive où l'assistant committait après
   presque chaque petit ajustement). La dernière étape d'une tâche est de tester dans le
   navigateur intégré, puis de laisser le PO tester et donner son retour. Le commit/push est une
   étape séparée, déclenchée uniquement par une demande explicite du PO dans son message, jamais
   déduite d'une habitude prise plus tôt dans la conversation.
8. **Migrations Supabase avant la première mise en service.** Tant que `main` n'a pas été mis en
   service, `supabase/migrations` n'est pas un historique à préserver mais le schéma courant :
   aucune donnée en base n'est vitale, ce sont toujours des données de test. Un changement de
   schéma, RLS, RPC, trigger, etc. modifie directement le fichier thématique existant concerné,
   n'ajoute pas de nouveau fichier. Comme le CLI Supabase suit les migrations déjà appliquées par
   nom de fichier (pas par contenu), éditer un fichier déjà poussé sans le rejouer désynchronise
   le projet distant : il faut reconstruire le schéma distant depuis zéro (procédure dans
   `docs/DEV.md`). **Toujours prévenir le PO avant de lancer cette reconstruction**, même si elle
   est sans risque à ce stade. Après la mise en service, on repasse en migrations additives
   normales (plus jamais d'édition d'un fichier déjà appliqué en production).
   **Exception, données réelles conservées par seed (Q63, 2026-09-23) :** les trous importés de
   LsgScores et repositionnés à la main (et ceux créés depuis dans l'app) sont des données à
   garder, comme les joueurs, sessions, scores et championnats (Q73). Avant toute reconstruction,
   régénérer les seeds depuis la base (`fvm dart run tool/export_remote_seed.dart` :
   `supabase/remote_seed.sql` en clair pour les trous, `supabase/data_seed.sql.enc` chiffré pour
   le reste, mot de passe dans `env/seed.json`), relire le diff, le committer avec l'accord du
   PO, puis les rejouer après la reconstruction (étapes 0, 5 et 6 de `docs/DEV.md`). Ne jamais
   committer une copie déchiffrée du seed des données (noms, e-mails, photos de personnes).

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
- **Toute demande adressée au PO énonce son objectif.** Quand l'assistant demande au PO de faire
  quelque chose (commande, réglage, vérification, réponse), il dit toujours à quoi cela sert : ce
  que cela permet ou vérifie, et ce qui se passe si ce n'est pas fait. Une demande sans but
  explicite est interdite.
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
fvm flutter run -d chrome --web-port 3000 --dart-define-from-file=env/dev.json   # port fixe (retour auth)
fvm dart run build_runner build -d                # génération freezed / riverpod / json
fvm dart format lib test
fvm flutter analyze --fatal-infos
fvm flutter test
fvm flutter build web --release --no-web-resources-cdn --dart-define-from-file=env/prod.json
npx supabase db push                              # migrations vers le projet nuni
npx supabase db diff -f <nom>                     # nouvelle migration depuis les changements
```

Environnement : `env/dev.json` et `env/prod.json` (ignorés par git) contiennent `SUPABASE_URL`
et `SUPABASE_ANON_KEY` ; `env/example.json` est le gabarit committé. À chaque push, Vercel
exécute `tool/vercel_build.sh` (installe Flutter, `pub get`, analyze, test, build web) ; pas de
GitHub Actions (Q17).

## Conventions de code

- Architecture feature-first : `lib/core/` (config, client Supabase, thème, i18n, routeur),
  `lib/features/<feature>/{data,domain,ui}`, `lib/shared/` (widgets communs), `test/` en miroir.
- État : Riverpod (`riverpod_generator`). Navigation : `go_router`. Modèles : `freezed` +
  `json_serializable`. Backend : `supabase_flutter`.
- Langues, règle stricte (PO, 2026-09-15) : **tout ce qui est technique est en anglais** : code,
  identifiants, commentaires, messages de commit, noms de fichiers et de branches, scripts,
  configuration, journaux, textes d'erreur techniques, `README.md`. **Seuls restent en français** :
  les plans et documents de `docs/` (`docs/DEV.md` compris) et les échanges avec le PO. Les
  chaînes visibles par l'utilisateur existent dans les deux langues (ARB).
- Chaînes visibles par l'utilisateur : toujours dans les fichiers ARB `app_en.arb` et `app_fr.arb`,
  jamais en dur. Une fonctionnalité n'est terminée que si ses chaînes existent dans les deux
  langues.
- Couleurs : aucune `Color(0x…)` hors `lib/core/theme/`. Les palettes sont dans
  `core/theme/palettes.dart` (liste `allPalettes` : six palettes, orange "NUNI Sunset" par défaut ;
  Q74, Q76). L'utilisateur choisit la sienne dans les réglages
  (`PaletteController`, mémorisée sur l'appareil) ; les écrans lisent les couleurs par
  `Theme.of(context).colorScheme` ou `context.nuni` (accents), jamais en dur, pour suivre ce
  choix. Toute nouvelle palette reprend les mêmes rôles et passe le test de contraste.
- Composants : les contrôles sont stylés une seule fois, dans `core/theme/app_theme.dart` ; les
  écrans assemblent les widgets de `lib/shared/` (`NuniButton`, `NuniCard`, `NuniListCard`,
  `NuniSectionHeader`, `NuniSegmented`, `NuniChip`, `NuniStatusPill`, `NuniIconTile`,
  `NuniAvatar`, `NuniRankBadge`, `NuniGroupedList`, `NuniHero`…) au lieu de recréer un style.
  Galerie de tous les composants : `/dev/theme` (builds debug uniquement, sans connexion).
- Modes de scoring et de jeu : énumérations dans le code, miroir des enums Postgres. Pas de table
  de référence en base.
- Lien utilisateur ↔ joueur : colonne `players.user_id` (nullable, unique). Pas de table de lien.
  Tout joueur créé par l'app est lié dès l'inscription (trigger) ; pas de joueur créé à la volée,
  pas de réclamation de fiche (Q24). `user_id` nul = joueur importé de LsgScores, non
  sélectionnable dans une nouvelle session.
- Associations (plan 18) : un joueur appartient à au plus une association
  (`players.association_id`, proposée à la première connexion, jamais imposée ; il peut la
  quitter, sauf s'il en est le responsable local, Q146 ; sans association, il rejoint des
  sessions mais n'en crée pas), chaque session à celle de son créateur (posée par un
  déclencheur, figée), et un championnat = une association × une saison (plus de zones
  géographiques, Q77). Les tables d'associations sont en lecture seule pour l'app : toute écriture
  passe par les RPC `security definer` de `rpc.sql` (demande, revendication, modification,
  validation par `super_admin`). Le mail et le téléphone des responsables vivent dans
  `association_manager_contacts`, jamais lisible au-delà du responsable et des `super_admin`.
- Équipes : table de jointure `team_players` ; la taille d'équipe est une règle applicative.
- Trous (plan 26) : tous publics (plus de visibilité), modifiables par leur seul auteur,
  clonables (`holes.cloned_from`). Le par d'un trou joué est `played_holes.par` (copié du trou à
  l'ajout, modifiable par l'organisateur, obligatoire pour un trou libre) : tout calcul le lit,
  jamais `holes.par`.
- Sessions (plan 26) : lisibles par leurs participants et, une fois démarrées, par tous les
  membres de leur association (`can_read_session`), en lecture seule pour ces derniers. Le
  marquage « championnat » est réservé au responsable local et au `super_admin`
  (`set_session_championship`) ; l'organisateur ne peut plus le changer.
- Calcul des scores et du classement en Dart, testé unitairement ; la base ne stocke que les
  valeurs saisies.
- Badges (plan 21) : calculés en Dart à chaque affichage (`lib/features/badges/domain/`, une
  règle par famille dans `rules/`), jamais stockés en base. Seule la mémoire des badges déjà
  annoncés ou vus vit sur l'appareil (`SeenBadgesStore`). L'annonce passe par `BadgeAnnouncer`,
  monté une fois dans `app.dart`. Toute icône de badge est une constante de
  `phosphor_icons.dart` (`badge…` et `badge…Fill`), sinon la version publiée ne l'embarque pas.
- Statistiques, records et badges (plans 19 à 21) : seulement les **sessions éligibles**,
  terminées, d'au moins 3 joueurs et d'au moins 3 trous joués (Q117, Q123). Définition écrite
  une seule fois dans `lib/features/stats/domain/`. Le classement d'une session n'est pas
  concerné. L'historique d'un joueur se lit par la RPC `player_history`, celui d'un trou par
  `holes_history` (un ou plusieurs trous ; commun à toutes les associations, Q95 ; un clone a
  le sien, Q135), les contributions d'un compte (badges « Bâtisseur ») par
  `player_contributions`, toutes ouvertes à tout compte connecté. Record et roi du trou : une
  seule implémentation, le rejeu `HoleReplay` de `hole_stats.dart`, lu par la fiche trou et
  par les badges J ; `players.stats_public` et `players.badges_public` ne décident que de l'affichage
  sur la fiche publique, jamais de l'accès aux données (Q133).
- Temps réel : abonnements Supabase filtrés par session, jamais sur une table entière.

## Interdits

- Secrets dans le dépôt (clés Supabase, jetons, identifiants OAuth). Le dépôt est **public**.
- Table `scoring_modes`, table de lien user↔joueur, tables villes/zones comme prérequis d'une
  session (l'association, plan 18, n'est pas un référentiel géographique : sa ville n'est qu'un
  texte et un point pour la suggestion). Seule exception acceptée (Q64, 2026-09-23) : `legacy_player_emails`, table privée
  (aucun droit pour l'app) qui ne sert qu'à rattacher un joueur importé de LsgScores à son compte
  à l'inscription, et se vide au fur et à mesure.
- Écrire dans l'ancien dépôt LsgScores.
- Commit ou push sans que le PO l'ait demandé ou accordé.
- Protection de branche ou PR obligatoire sur `main` (Q17) : le PO pousse directement sur `main`.

## Définition de "terminé"

`fvm flutter analyze` sans avertissement, tests verts, build Vercel vert sur le commit (Vercel
compile, Q17), chaînes traduites EN et FR,
critères d'acceptation du plan de l'étape cochés, plan et `QUESTIONS_PO.md` à jour, ce fichier
relu.
