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
| `app_user` | `profiles` | seulement pour les utilisateurs qui se reconnectent à NUNI (même identité Google → même UUID auth si le fournisseur est partagé ; sinon rapprochement par e-mail) |
| `cities`, `game_zones` | texte sur `sessions` | tables non reprises |
| `scoring_modes`, `app_versions`, `app_roles` | — | abandonnées |

## Approche technique envisagée

- Script Dart autonome (`tool/migrate_lsgscores.dart`) lisant l'ancien projet via l'API REST avec
  la clé service et écrivant dans NUNI via la clé service, par lots, avec journal et rapport de
  contrôle (comptes par table avant/après, totaux de coups par session identiques). Alternative :
  `postgres_fdw` ou export/import SQL ; le script Dart réutilise les modèles de l'app et reste
  lisible.
- Exécution à blanc sur une copie (branche Supabase ou projet temporaire), puis en production
  pendant une fenêtre sans session en direct.
- Vérification : pour chaque ancienne session, le classement recalculé par NUNI doit être identique
  à l'export PDF de l'ancienne app.

## Questions à ouvrir au moment du plan détaillé

- M1 : position de départ des anciens trous (saisie manuelle dans NUNI après import, ou `start`
  nullable pour les trous hérités avec proposition de géolocalisation à la première utilisation).
- M2 : propriétaire des données importées quand l'ancien utilisateur ne s'est pas encore connecté
  à NUNI (compte "archive" temporaire, réattribution au premier login par e-mail).
- M3 : identité Google : le même client OAuth pour les deux projets Supabase donne-t-il le même
  identifiant utilisateur ? (Non : l'UUID est propre à chaque projet Supabase ; rapprochement par
  e-mail à prévoir.)
- M4 : conservation ou non des sessions jamais terminées de l'ancienne base.

## Critères d'acceptation (cadre)

- Nombre de sessions, d'équipes, de trous joués et de coups identique entre les deux bases.
- Chaque ancienne session s'ouvre dans l'historique NUNI avec le même classement.
- Le script peut être rejoué sans créer de doublon.
