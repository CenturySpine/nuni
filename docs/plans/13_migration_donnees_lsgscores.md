# Plan 13 — Migration des données LsgScores vers NUNI

## Statut

Étape obligatoire et critique (décision PO du 2026-09-14, Q3). Ce document est un cadre : le plan
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
  à NUNI (compte "archive" temporaire, réattribution au premier login par e-mail).
- M3 : identité Google : le même client OAuth pour les deux projets Supabase donne-t-il le même
  identifiant utilisateur ? (Non : l'UUID est propre à chaque projet Supabase ; rapprochement par
  e-mail à prévoir.)
- M4 : conservation ou non des sessions jamais terminées de l'ancienne base.
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

## Critères d'acceptation (cadre)

- Nombre de sessions, d'équipes, de trous joués et de coups identique entre les deux bases.
- Chaque ancienne session s'ouvre dans l'historique NUNI avec le même classement.
- Le script peut être rejoué sans créer de doublon.
