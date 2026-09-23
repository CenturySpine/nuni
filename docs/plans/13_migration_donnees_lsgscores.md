# Plan 13 — Migration des données LsgScores vers NUNI

## Statut

**Clôturé par le PO le 2026-09-23** : étapes 1 à 3 livrées et testées. Pas de retrait de
l'ancienne app prévu ; un plan dédié sera ouvert si c'est un jour décidé.

Historique : Étape obligatoire et critique (décision PO du 2026-09-14, Q3). Ce document est un cadre : le plan
détaillé est rédigé après l'étape 12, quand le modèle cible a été éprouvé par l'usage. Rien de ce
qui suit n'est figé, sauf l'objectif.

## Objectif

Importer dans NUNI l'intégralité des sessions existantes de LsgScores (sessions, équipes,
joueurs, trous, trous joués, coups, photos de session) de façon vérifiable, rejouable et sans
perte, puis retirer l'ancienne app.

## Ce que le schéma NUNI prévoit déjà (plan 03)

- Colonnes `legacy_id` sur `players`, `holes`, `sessions`, `teams`, `played_holes` : chaque ligne
  importée porte l'identifiant d'origine, ce qui rend l'import idempotent (ré-exécution sans
  doublon) et permet un rapprochement ligne à ligne pour la vérification.
- `sessions.city` et `sessions.zone` en texte libre : reçoivent le nom de l'ancienne ville et de
  l'ancienne zone de jeu.
- Modes de scoring et de jeu en énumérations : correspondance directe par identifiant (1 → Stroke
  Play, 2 → Match Play, 3 → Redistribution ; modes de jeu 1 à 4).

## Correspondances connues

| Ancienne table | Cible NUNI | Remarques |
|---|---|---|
| `players` + `user_player_link` | `players` (`user_id` renseigné quand l'ancien lien existait et que l'utilisateur est rapproché par e-mail) | avatars recopiés de bucket à bucket |
| `holes` | `holes` | position de départ inconnue : voir question M1 |
| `sessions` | `sessions` (status `completed`, ou `live` si `isongoing`) | `datetime`, `enddatetime`, `weatherdata` (même structure JSON), `comment` |
| `teams` (player1/player2) | `teams` + `team_players` | ordre = ordre d'id |
| `played_holes` | `played_holes` | position conservée |
| `played_hole_scores` | `scores` | `updated_by` = propriétaire de la session |
| Storage `sessions/<id>/` | `session_photos` + bucket `session-photos` | `fav_` → `cover_photo_id` |
| `app_user` | `players.user_id` (pas de table `profiles`, retirée le 2026-09-16) | seulement pour les utilisateurs qui se reconnectent à NUNI ; l'UUID auth ne se reporte pas d'un projet Supabase à l'autre (confirmé le 2026-09-16, cf. plan 03), donc `user_id` reste `null` tant que la personne ne s'est pas reconnectée elle-même, sauf si on choisit de pré-provisionner des comptes (question à trancher au plan 13) |
| `cities`, `game_zones` | texte sur `sessions` | tables non reprises |
| `scoring_modes`, `app_versions`, `app_roles` | — | abandonnées |

## Approche technique envisagée

- Script Dart autonome (`tool/migrate_lsgscores.dart`) lisant l'ancien projet via l'API REST avec
  la clé service et écrivant dans NUNI via la clé service, par lots, avec journal et rapport de
  contrôle (comptes par table avant/après, totaux de coups par session identiques). Alternative :
  `postgres_fdw` ou export/import SQL ; le script Dart réutilise les modèles de l'app et reste
  lisible.
- **Migration en deux temps (décision PO, 2026-09-22), qui répond à M1 :**
  1. Import des trous seuls (`holes`, `start` laissé `null` — inconnu à l'import, comme prévu par
     le schéma). Le PO repositionne ensuite chaque trou hérité à sa vraie position, à la main, dans
     l'écran d'édition de trou déjà existant (plan 06) — pas de nouvel écran, pas de géocodage
     automatique à construire.
  2. Import des sessions et du reste (`teams`, `played_holes`, `scores`, `session_photos`) une
     fois cette étape terminée, pas avant. Une session important n'a jamais eu de position GPS
     propre dans l'ancienne app (position saisie à la création, absente de LsgScores) : le script
     calcule `sessions.location` comme le centre géométrique des trous distincts qu'elle référence
     (via `played_holes.hole_id`), une fois ceux-ci repositionnés. Une session dont tous les trous
     référencés sont restés sans position reste elle-même sans position (comportement normal,
     déjà prévu ailleurs dans l'app : Q11/plan 07, "position refusée, champ vide facultatif").
     Conséquence utile pour le plan 15 (championnat) : une fois `location` renseignée, le
     rattachement automatique à une zone de championnat (rayon de 15 km, Q44) s'applique aux
     sessions importées exactement comme aux sessions créées dans NUNI, sans mécanisme
     particulier à écrire pour elles.
- Exécution à blanc sur une copie (branche Supabase ou projet temporaire), puis en production
  pendant une fenêtre sans session en direct.
- Vérification : pour chaque ancienne session, le classement recalculé par NUNI doit être identique
  à l'export PDF de l'ancienne app.

## Questions à ouvrir au moment du plan détaillé

- M1 ☑ — Position de départ des anciens trous : résolue ci-dessus (2026-09-22), migration en deux
  temps, repositionnement manuel dans l'app entre les deux.
- M2 : propriétaire des données importées quand l'ancien utilisateur ne s'est pas encore connecté
  à NUNI. Détaillé à l'étape 2 (2026-09-23) : toutes les sessions ont été créées par le PO ; les
  joueurs sans compte sont traités par Q64.
- M3 ☑ — identité Google : le même client OAuth pour les deux projets Supabase donne-t-il le même
  identifiant utilisateur ? (Non : l'UUID est propre à chaque projet Supabase ; rapprochement par
  e-mail, appliqué à l'étape 2.)
- M4 ☑ — sans objet : aucune session LsgScores n'est en cours (profil du 2026-09-23).
- M5 ☑ — Marquage rétroactif de sessions importées comme "championnat" (demande PO, 2026-09-22,
  plan 15) : la règle normale de l'app ("seul le créateur peut taguer une session") ne peut pas
  s'appliquer telle quelle à une session importée dont le propriétaire réel ne s'est pas encore
  reconnecté à NUNI (M2).
  Réponse PO (2026-09-22, Q48) : action côté app protégée par `is_super_admin()` (plan 16),
  plutôt qu'un script de migration à clé service. Détail technique à écrire lors du plan détaillé :
  une RPC `security definer` dédiée (même famille que `championship_zone_results`), réservée à
  `is_super_admin()`, posant `is_championship = true` sur une session choisie par le PO. Le
  rattachement à une zone se fait alors par le même mécanisme automatique que toute session
  championnat (ci-dessus), à condition que l'étape 1 (repositionnement des trous) soit terminée
  avant l'étape 2 (import des sessions). Avantage sur le script à clé service : le PO peut
  retagger depuis l'app à tout moment (pas seulement pendant la fenêtre de migration), et le même
  mécanisme sert pour toute correction future, pas seulement l'import initial.

## Étape 1 — Import des trous (validée le 2026-09-23 ; livrée et testée par le PO le même jour)

Résultat du premier import (2026-09-23) : 17 trous (zone INSA, Lyon), 25 photos sur 26 copiées
(la photo de départ de l'ancien trou 6, « Fireman #1 », n'existe plus dans le stockage de
LsgScores). Rejeu immédiat : 0 trou inséré, 0 photo copiée. Repositionnement manuel en cours par
le PO.

État des décisions : Q49 à Q55 retenues (2026-09-23). La demande de « trou
générique » (Q56–Q59) fait l'objet du plan 17, livré avec cette étape pour ne reconstruire la
base distante qu'une fois.

Demande PO (2026-09-23) : commencer par les trous seuls ; l'import doit être rejouable à
l'identique après une reconstruction de la base (AGENTS.md point 8). Le PO accepte qu'une
reconstruction efface les repositionnements manuels faits entre-temps (les trous sont réimportés
sans position).

### Données source (ancien dépôt, lecture seule)

`public.holes` de LsgScores (`supabase/sql/schema_15_11_2025.sql`) : `id bigint`, `name`,
`gamezoneid` (→ `game_zones.name`, `cities`), `description`, `distance int`, `par`,
`startphotouri` / `endphotouri` (URL publiques complètes du bucket `Holes`), `user_id` (UUID auth
de l'ancien projet, sans équivalent dans NUNI). Tous les trous étaient lisibles par tout
utilisateur connecté (`holes_select_auth ... using (true)`).

### Correspondance

| LsgScores | NUNI `holes` | Règle |
|---|---|---|
| `id` | `legacy_id` | clé d'idempotence |
| `name`, `description`, `par` | idem | recopie directe |
| `distance` | `distance_m` | recopie directe (mètres) |
| — | `start`, `end_point`, `path` | `null` (Q49) ; posés à la main par le PO dans l'écran d'édition existant |
| `user_id` | `owner_id` | compte du PO (Q50) |
| — | `visibility` | `public` (Q51) |
| `startphotouri`, `endphotouri` | `photo_start_path`, `photo_end_path` | photo recopiée dans le bucket `holes` de NUNI sous `<id du PO>/legacy-<legacy_id>/start.<ext>` / `end.<ext>` (Q52 ; dans le dossier du propriétaire, seul dossier où les règles du stockage le laissent remplacer la photo depuis l'app) |
| `gamezoneid` | — | non stocké ; reporté dans le rapport d'import pour aider le repositionnement (Q53) |

Tous les trous sont importés, pas seulement ceux du PO : les sessions de l'étape 2 les
référencent.

### Outil (Q54)

Script Dart autonome `tool/migrate_lsgscores.dart`, sous-commande `holes` :

1. Lit les trous et zones de l'ancien projet par l'API REST (clé service de l'ancien projet).
2. Pour chaque photo : si l'objet `<id du PO>/legacy-<legacy_id>/...` n'existe pas déjà dans le bucket
   `holes` de NUNI, la télécharge depuis l'URL publique et la dépose. Le stockage survit à une
   reconstruction du schéma : un rejeu ne retélécharge rien.
3. Insère les trous dans NUNI (clé service NUNI) par lot, en `upsert` sur `legacy_id` avec
   « ignorer les doublons » (Q55) : un trou déjà importé n'est jamais modifié par un rejeu.
4. Écrit un rapport (`build/migration/holes_report.csv`, dossier ignoré par git) : `legacy_id`,
   nom, zone et ville d'origine, présent/inséré/ignoré, photos copiées ; et affiche les comptes
   (source, insérés, déjà présents).

Droits : les tables NUNI n'accordent rien par défaut au rôle « service » (constaté le 2026-09-23 au
premier import à blanc, « permission denied for table user_roles ») ; `..._rls.sql` lui accorde le
strict nécessaire au script (lecture de `user_roles`, lecture et insertion dans `holes`).

Secrets dans `env/migration.json` (déjà ignoré par `env/*.json`) : URL + clé service de l'ancien
projet, URL + clé service de NUNI. Aucune donnée ni clé dans le dépôt public.

Commande : `fvm dart run tool/migrate_lsgscores.dart holes` (`--env <fichier>` pour un autre fichier
de clés, `--dry-run` pour tout lire et produire le rapport sans rien écrire dans NUNI). Gabarit des
clés : `env/migration.example.json` (committé, sans valeur).
Ajoutée comme étape 7 (optionnelle) de la procédure de reconstruction de `docs/DEV.md`.

### Changements dans l'app (conséquence de Q49)

- Schéma : `holes.start` devient nullable (fichier `..._tables.sql`, reconstruction du schéma
  distant, PO prévenu avant). `holes_nearby` exclut déjà naturellement les trous sans position
  (distance nulle) : à vérifier et tester.
- Modèles `Hole` et `PlayedHole` : `startLat` / `startLng` deviennent nullables.
- Liste « Mes trous » : un trou sans position s'affiche avec la mention « Position à définir »
  (EN/FR) ; il n'apparaît pas sur la carte ni dans « Autour de moi ».
- Fiche détail : lien Google Maps masqué sans position.
- Formulaire d'édition : position vide au chargement, obligatoire à l'enregistrement (déjà le cas
  à la création).
- La création d'un trou dans l'app exige toujours une position : seul l'import en produit sans.

### Critères d'acceptation de l'étape 1

- Nombre de trous NUNI avec `legacy_id` = nombre de trous LsgScores.
- Deuxième exécution immédiate : 0 inséré, 0 photo copiée, aucune erreur.
- Après reconstruction du schéma + rejeu : mêmes trous, photos affichées sans nouvel envoi.
- Un trou importé apparaît dans « Mes trous » du PO avec « Position à définir », s'édite, et après
  enregistrement d'une position apparaît dans « Autour de moi ».
- `flutter analyze` sans remarque, tests verts (dont `Hole.fromJson` sans position), chaînes EN/FR.

## Étape 2 — Import des sessions (validée le 2026-09-23 ; livrée et testée par le PO le même jour)

Décisions : Q62 à Q71 retenues (2026-09-23) ; Q63 avec une variante du PO : on continue à
reconstruire la base, les trous réels étant conservés par le seed (`supabase/remote_seed.sql`,
régénéré depuis la base par `tool/export_remote_seed.dart`, fait le 2026-09-23).

Prérequis vérifié le 2026-09-23 (lecture seule des deux bases) : les 17 trous joués dans LsgScores
existent dans NUNI, 16 ont une position ; le 17e est « Generic », converti en trou libre (Q62).

### Données source (profil du 2026-09-23, lecture seule)

- 7 sessions, toutes terminées (aucune en cours : M4 sans objet), toutes créées par le compte du PO,
  toutes à Lyon, zone « INSA ». 2 en équipes, 5 individuelles ; 6 en Stroke Play, 1 en Match Play.
- 29 équipes (1 ou 2 joueurs), 44 trous joués (modes de jeu 1, 2 et 3), 181 scores (2 à 10 coups).
- 14 fiches joueurs, dont 10 ont joué au moins une partie. Parmi ces 10, 3 correspondent (même
  adresse e-mail) à un compte NUNI existant ; 7 n'ont pas de compte NUNI, dont 2 sans adresse e-mail
  connue dans LsgScores.
- Horaires stockés en texte sans fuseau (`2025-09-02T18:55:00`) ; météo stockée comme une chaîne
  JSON au format OpenWeatherMap (`description`, `iconCode` « 01d », `temperature`, `windSpeedKmh`),
  différent du format NUNI (`temperature_c`, `wind_kph`, `code` WMO).
- Photos : bucket privé `Sessions`, dossier `<id session>/`, 14 fichiers ; le préfixe `fav_`
  désigne la photo de couverture (une par session).

Correction du cadre ci-dessus : la météo n'a pas « la même structure JSON » (voir Q69).

### Correspondance

| LsgScores | NUNI | Règle |
|---|---|---|
| `sessions.id` | `sessions.legacy_id` | clé d'idempotence |
| `user_id` (propriétaire) | `owner_id` | compte NUNI du PO (rapproché par e-mail, M3) |
| `datetime`, `enddatetime` | `started_at`, `ended_at` | heure locale de Paris (Q68) |
| `sessiontype` | `kind` | `INDIVIDUAL` → `individual`, `TEAM` → `team` |
| `scoringmodeid` | `scoring_mode`, `ranking_direction` | 1 → `stroke_play`/`asc`, 2 → `match_play`/`desc`, 3 → `redistribution`/`desc` |
| `cityid`, `gamezoneid` | `city`, `zone` | noms en texte (« Lyon », « INSA »), espaces retirés |
| — | `location` | centre des trous positionnés de la session (déjà prévu, M1) |
| `weatherdata` | `weather` | conversion de format (Q69) |
| `comment` | `comment` | recopie (toutes vides aujourd'hui) |
| `isongoing` | `status` | `completed` (aucune session en cours) |
| — | `is_championship` | `false` à l'import ; marquage ensuite par le PO depuis l'app (Q71) |
| `teams` (player1, player2) | `teams` + `team_players` | `legacy_id` = id d'équipe ; position = ordre des id |
| `players` | `players` | voir Q64 à Q66 |
| `played_holes` | `played_holes` | `legacy_id`, position conservée ; mode de jeu 1 → `individual`, 2 → `scramble`, 3 → `greensome`, 4 → `best_ball` ; trou 32 « Generic » → trou libre sans libellé (Q62) |
| `played_hole_scores` | `scores` | `value` = coups ; `updated_by` = propriétaire |
| — | `session_members` | propriétaire + joueurs ayant un compte NUNI (Q67) |
| Storage `Sessions/<id>/*` | bucket `session-photos` + `session_photos` | `<id session NUNI>/<nom d'origine>` ; `fav_` → `cover_photo_id` (Q70) |

### Outil

Nouvelle sous-commande `fvm dart run tool/migrate_lsgscores.dart sessions [--dry-run]`, même
fichier de clés que l'étape 1.

1. Contrôle préalable (affiché aussi en `--dry-run`) : chaque trou joué, sauf « Generic », doit
   exister dans NUNI ; les trous sans position sont listés. Arrêt si un trou manque.
2. Joueurs : rapprochement par e-mail avec les comptes NUNI, création des autres (Q64 à Q66).
3. Par session, dans l'ordre : session, équipes, membres d'équipe, membres de session, trous joués,
   scores, photos. Chaque niveau est idempotent (`legacy_id` ou clé naturelle, doublons ignorés) :
   un rejeu après une interruption complète ce qui manque sans rien dupliquer ni écraser.
4. Trou « Generic » : exclu de l'import des trous (`excludedLegacyHoleIds` dans le script, fait
   le 2026-09-23) et absent du seed ; il disparaît de NUNI à la reconstruction qui précède
   l'import des sessions, sans suppression à faire à la main.
5. Rapport `build/migration/sessions_report.csv` et contrôles : nombres de sessions (7), équipes
   (29), trous joués (44), scores (181), photos (14) identiques des deux côtés ; total de coups par
   équipe identique à LsgScores.

Droits : le rôle « service » reçoit la lecture et l'insertion sur `sessions`, `teams`,
`team_players`, `session_members`, `played_holes`, `scores`, `session_photos`, `players`,
`legacy_player_emails`. Les e-mails des comptes NUNI sont lus par l'API d'administration des
comptes (clé service), jamais depuis l'app.

Identifiants stables (conséquence de Q63, les reconstructions continuent) : les identifiants NUNI
des sessions, équipes, trous joués et joueurs importés sont dérivés de l'identifiant LsgScores
(UUID v5, toujours le même pour une même ligne d'origine). Une reconstruction suivie d'un rejeu
redonne exactement les mêmes identifiants : les photos de session, rangées sous l'identifiant
de la session (Q70), sont retrouvées sans nouvelle copie, et les sessions et joueurs pourront
ensuite rejoindre le seed comme les trous (souhait du PO, 2026-09-23).

Ordre d'exécution : régénérer et committer le seed des trous (`tool/export_remote_seed.dart`),
prévenir le PO, reconstruire la base (schéma de l'étape 2 inclus), rejouer les seeds, puis
`migrate_lsgscores.dart sessions --dry-run`, puis l'import réel.

### Changements dans l'app

- Marquage « championnat » par le super_admin (Q71) : RPC `set_session_championship(p_session_id,
  p_value)` (`security definer`, réservée à `is_super_admin()`), et interrupteur « Session de
  championnat » dans le détail d'une session de l'historique, visible du super_admin seul. Le
  rattachement à une zone reste celui du déclencheur existant (plan 15).
  **Constat à l'implémentation (2026-09-23), confirmé par le PO : rien à coder.** l'historique a déjà
  une fiche d'édition de session (plan 10/15) avec l'interrupteur « championnat », ouverte au
  propriétaire de la session. Q67 fait du PO le propriétaire de toutes les sessions importées :
  il peut donc déjà les marquer sans nouvelle RPC ni nouvel écran.
- Rattachement automatique à la première connexion (Q64) : table privée, déclencheur d'inscription
  modifié.

### Résultat de l'import (2026-09-23)

Base reconstruite puis import : contrôles du script tous OK (7 sessions, 29 équipes, 44 trous
joués, 181 scores, totaux de coups par équipe identiques), 14 photos, 7 couvertures, 7 sessions
localisées, 1 trou libre (session 219). 7 joueurs importés (6 avec photo) ; 3 joueurs rapprochés
d'un compte NUNI existant ; 5 e-mails en attente de rattachement, 2 joueurs sans e-mail. Rejeu
immédiat : rien d'inséré, rien de copié. Incident corrigé en cours de route : le déclencheur qui
génère le code de session appelle `generate_session_code`, non exécutable par le rôle « service » ;
droit ajouté dans `..._triggers.sql` et appliqué à l'identique sur la base.

### Critères d'acceptation de l'étape 2

- Comptes identiques entre les deux bases (sessions, équipes, trous joués, scores, photos).
- Chaque session s'ouvre dans l'historique NUNI du PO avec le même classement que dans LsgScores
  (vérification visuelle du PO, session par session).
- Rejeu immédiat : rien d'inséré, rien de copié, aucune erreur.
- Les 7 sessions ont une position (centre de leurs trous positionnés) ; la session 219 affiche un
  trou libre.
- `flutter analyze` sans remarque, tests verts, chaînes EN/FR.

## Étape 3 — Sauvegarde des données par seed (validée le 2026-09-23 ; livrée et vérifiée le même jour)

Contrôle complet du 2026-09-23 : export avec le mot de passe du PO, déchiffrement vérifié avant
toute écriture, reconstruction de la base, rejeu dans l'ordre de `docs/DEV.md`. Empreinte (nombre
de lignes et hachage du contenu) identique avant/après pour les 13 tables : joueurs (14), trous
(19), e-mails de rattachement (5), sessions (7), regroupement en zones de championnat (4 sessions
marquées, mêmes regroupements), équipes (29), membres d'équipe (36), membres de session (18),
trous joués (44), scores (181), photos (14), rôles (1), zones (1, identifiant régénéré comme
prévu). Classements identiques par construction (mêmes données, mêmes regroupements).

Demande PO (2026-09-23) : après la migration, rejouer après une reconstruction les trous, sessions
et championnats actuels, comme les trous le sont déjà (Q63).

- `tool/export_remote_seed.dart` produit, en plus du seed des trous, un seed des données : fiches
  joueurs (toutes, y compris celles liées à un compte, avec leur identifiant et leur nom modifié),
  sessions, équipes, membres d'équipe, membres de session, trous joués, scores, photos de session
  (lignes seulement, les fichiers restent dans le stockage), e-mails de rattachement (Q64).
  Emplacement (Q73) : `supabase/data_seed.sql.enc`, chiffré par `openssl` (AES-256, PBKDF2,
  600 000 itérations) et committé ; mot de passe dans `env/seed.json` (ignoré par git) et dans le
  KeePass du PO. La copie en clair n'existe que le temps du chiffrement ou du rejeu, dans `build/`
  (ignoré par git). Aller-retour chiffrement/déchiffrement et syntaxe du SQL vérifiés le
  2026-09-23 avec un mot de passe jetable (fichiers de test supprimés ensuite).
- Championnats : aucune table à sauvegarder. Les zones sont recalculées par le déclencheur existant
  quand les sessions marquées sont réinsérées ; elles le sont dans leur ordre de création d'origine
  (`created_at` conservé), ce qui redonne exactement les mêmes regroupements et donc les mêmes
  classements. Seuls les identifiants internes des zones changent (invisibles pour l'utilisateur).
  Saison et code de session sont conservés (le code est fourni, la saison est recalculée à
  l'identique).
- Procédure de reconstruction (`docs/DEV.md`) : le seed des données est rejoué avant
  `backfill_players.sql`, pour que chaque compte retrouve sa fiche d'origine (même identifiant, nom
  modifié conservé) au lieu d'en recevoir une nouvelle ; le backfill ne complète que les comptes
  créés depuis le dernier export. L'import LsgScores (étapes 7 et 8) devient une voie de secours.
- Règle : régénérer les seeds avant toute reconstruction (déjà écrite pour les trous, AGENTS.md).
- Vérification : export, reconstruction, rejeu, puis comparaison des nombres de lignes par table et
  des classements de championnat avant/après.

## Critères d'acceptation (cadre)

- Nombre de sessions, d'équipes, de trous joués et de coups identique entre les deux bases.
- Chaque ancienne session s'ouvre dans l'historique NUNI avec le même classement.
- Le script peut être rejoué sans créer de doublon.

## Retrait de l'ancienne app (décision PO du 2026-09-23)

Reporté : l'ancien projet LsgScores (app et base Supabase) est conservé tel quel pendant les
travaux sur NUNI. Il ne coûte rien, ne gêne pas, et sert de sauvegarde de secours (le script
d'import peut en restaurer trous et sessions, étape 8 de `docs/DEV.md`). Son retrait sera décidé
plus tard par le PO.
