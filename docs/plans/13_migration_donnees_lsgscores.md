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

## Critères d'acceptation (cadre)

- Nombre de sessions, d'équipes, de trous joués et de coups identique entre les deux bases.
- Chaque ancienne session s'ouvre dans l'historique NUNI avec le même classement.
- Le script peut être rejoué sans créer de doublon.
