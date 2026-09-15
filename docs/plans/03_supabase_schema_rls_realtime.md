# Plan 03 — Backend Supabase : projet, schéma, RLS, RPC, stockage, temps réel

## Objectif

Créer le backend NUNI sur Supabase avec un modèle de données conçu pour la nouvelle app
(sessions géolocalisées, trous publics/privés, adhésion aux sessions), des politiques d'accès
fondées sur l'appartenance à une session, et un temps réel ciblé par session. Tout est versionné
en migrations SQL dans le dépôt.

## Prérequis

Plan 02 (le CLI Supabase est une dépendance npm du dépôt).

## Décisions retenues

- Q2 tranchée : projet Supabase `nuni` déjà créé, URL `https://zlxfmovibepgdmxacbpj.supabase.co`,
  référence de projet `zlxfmovibepgdmxacbpj` (à utiliser pour `npx supabase link`), région
  West EU (Paris).
- Migrations gérées par `npx supabase db diff` / `db push`, dossier `supabase/migrations`.
  Développement local possible avec `npx supabase start` (Docker) mais non obligatoire ; le
  développement direct contre le projet distant est accepté pour un projet solo.
- Extensions : `postgis` (proximité des trous), `pgcrypto` (codes de session).
- Q6 tranchée : modes de scoring et modes de jeu = énumérations Postgres (`scoring_mode`,
  `game_mode`) miroir des enums Dart ; libellés traduits dans l'app. Pas de table `scoring_modes`.
- Q7 tranchée : `scoring_mode` = `stroke_play`, `match_play`, `redistribution`, `free` (nouveau
  mode Libre : la valeur saisie est directement le nombre de points, classement décroissant ;
  paramètres en Q7b, sens du classement porté par `sessions.ranking_direction`). `game_mode` =
  `individual`, `scramble`, `greensome`, `best_ball`. La colonne
  `scores.strokes` est renommée `scores.value` : coups dans les trois premiers modes, points en
  mode Libre.
- Q4 tranchée : lien utilisateur ↔ joueur par colonne `players.user_id` (nullable, unique), pas de
  table de lien. Les notions restent séparées : un joueur existe sans utilisateur.
- Q5 tranchée : équipes via table de jointure `team_players` ; la taille (1 en individuel, 2 en
  équipe) est une règle applicative, vérifiée aussi par la RPC de création.
- Auth : profil créé par trigger sur `auth.users` (plus de "ensureUserRow" côté client).
- Temps réel : abonnement `postgres_changes` filtré par `session_id` (et non plus un flux sur la
  table entière), tables ajoutées à la publication `supabase_realtime`. Le calcul des scores et
  du classement reste en Dart (pur, testé) : la base ne stocke que les coups.
- Stockage : buckets `avatars`, `holes`, `session-photos` en lecture publique (chemins non
  devinables, UUID), écriture authentifiée limitée au propriétaire du préfixe. Plus d'URL signées
  ni de favori encodé dans le nom de fichier : la photo de couverture est une colonne.

## Modèle de données cible

```
profiles            id uuid PK = auth.users.id, display_name, avatar_url, locale text, created_at
players             id uuid PK, name text, avatar_url, created_by uuid → profiles,
                    user_id uuid null unique → profiles ("ce joueur, c'est moi"), created_at
holes               id uuid PK, owner_id uuid → profiles, name, description, par int (défaut 3),
                    distance_m int null, start geography(Point,4326) NOT NULL,
                    photo_start_path, photo_end_path, visibility hole_visibility (public|private),
                    created_at, updated_at
sessions            id uuid PK, code text unique (6 car. A-Z0-9, généré), owner_id → profiles,
                    status session_status (draft|live|completed), kind session_kind
                    (individual|team), scoring_mode scoring_mode,
                    ranking_direction ranking_direction (asc|desc, Q7b : libre en mode `free`,
                    déduit du mode sinon), city text null, zone text null,
                    location geography(Point) null, started_at, ended_at null, weather jsonb null,
                    comment text null, cover_photo_id uuid null, created_at
teams               id uuid PK, session_id → sessions (cascade), position int
team_players        team_id → teams (cascade), player_id → players, PK(team_id, player_id)
session_members     session_id → sessions (cascade), user_id → profiles, team_id → teams null
                    (null = dans le pool, pas encore affecté ; Q15), role member_role
                    (owner|player), joined_at, PK(session_id, user_id)
played_holes        id uuid PK, session_id → sessions (cascade), hole_id → holes, game_mode
                    game_mode, position int, created_at, unique(session_id, position)
scores              played_hole_id → played_holes (cascade), team_id → teams (cascade),
                    value int check 0..20 (coups, ou points en mode Libre), updated_by → profiles,
                    updated_at,
                    PK(played_hole_id, team_id)
session_photos      id uuid PK, session_id → sessions (cascade), storage_path text,
                    uploaded_by → profiles, created_at
```

Tables abandonnées par rapport à l'ancienne app : `cities`, `game_zones`, `scoring_modes`,
`app_versions`, `app_roles`.

Préparation de la migration (Q3, plan 13) : colonne `legacy_id bigint null unique` sur `players`,
`holes`, `sessions`, `teams`, `played_holes`, pour importer les données LsgScores de façon
idempotente (re-exécutable) et traçable. `sessions.city` et `sessions.zone` en texte libre
accueillent directement les anciens noms de ville et de zone. `holes.start` est obligatoire dans
le modèle cible ; l'import posera la position lors du plan 13 (voir la question qui y sera
ouverte), ce qui peut justifier de rendre `start` nullable avec une contrainte "obligatoire pour
les trous créés depuis l'app" — décision prise au plan 13, la migration SQL correspondante
restant triviale.

## Règles d'accès (RLS) cibles

- `profiles` : lecture par tout utilisateur authentifié ; écriture par soi-même.
- `players` : lecture par tout authentifié (référentiel partagé) ; insertion par tout authentifié ;
  modification par le créateur ou par l'utilisateur lié (`user_id = auth.uid()`) ; réclamer un
  joueur ("c'est moi") = mise à jour de `user_id` autorisée seulement si la colonne est nulle et
  si je n'ai pas déjà un joueur ; suppression par le créateur si le joueur n'est lié à personne et
  n'apparaît dans aucune équipe.
- `holes` : lecture si `visibility = public` ou propriétaire, ou (H Q13) si le trou a été joué dans
  une session dont je suis membre ; écriture propriétaire.
- `sessions` : lecture par les membres ; insertion par l'auteur ; modification et suppression par
  le propriétaire. La découverte par code passe par une fonction (voir RPC), pas par un SELECT
  ouvert.
- `teams`, `team_players` : lecture par les membres de la session ; écriture par le propriétaire
  tant que `sessions.status = draft` (équipes figées au démarrage, Q15). `played_holes` : lecture
  par les membres ; écriture par le propriétaire.
- `session_members` : lecture par les membres ; insertion de soi-même via RPC `join_session` ;
  suppression de soi-même tant que la session est en `draft` ; le propriétaire peut retirer un
  membre à tout moment.
- `scores` : lecture par les membres ; écriture (Q8 tranchée) par le propriétaire ou un
  co-organisateur de la session pour toute équipe, et par un membre pour l'équipe à laquelle il
  est rattaché (`session_members.team_id`).
- `session_photos` : lecture par les membres ; écriture par le propriétaire de la session.
- Fonctions `is_session_member(session_id)` et `is_session_owner(session_id)` en `security
  definer` pour éviter les politiques récursives.

## Fonctions (RPC)

- `holes_nearby(lat, lng, radius_m)` → trous publics + mes trous privés dans le rayon, avec la
  distance, triés par distance (index GiST sur `start`).
- `join_session(code)` → applique les trois cas de Q15 (plan 09) : session introuvable ou
  `completed` → erreur `session_unavailable` ; déjà membre → retourne la session ; aucune équipe
  → insère le membre dans le pool (`team_id null`, rôle `player`) ; mon joueur lié dans une équipe
  → insère le membre rattaché à cette équipe ; équipes existantes sans mon joueur → erreur
  `not_in_team`, rien n'est inséré. Exige un joueur lié (`players.user_id = auth.uid()`), sinon
  erreur `no_player`.
- `create_session(payload jsonb)` → session en `draft` avec équipes facultatives (plan 07).
- `start_session(session_id)` → propriétaire seulement, `status = draft`, au moins une équipe,
  aucun membre du pool non affecté (H Q25, erreur listant les noms), rattache chaque membre à
  l'équipe de son joueur, passe en `live` avec `started_at`.
- Plus de `set_my_team` : le joueur ne choisit jamais son équipe (Q15).
- `delete_my_account()` → purge ordonnée des données de l'utilisateur puis suppression du compte
  auth (via `auth.admin` dans une Edge Function, ou fonction SQL `security definer` supprimant
  `auth.users` — à choisir à l'implémentation ; l'Edge Function est la voie documentée).
- Triggers : création de profil à l'inscription, `updated_at`, génération du `code` de session,
  garde "une seule équipe par membre".

## Étapes

1. Projet Supabase `nuni` déjà créé. Fait par le PO le 2026-09-15 (Q20) : client Google "Nuni
   PWA" avec l'URI de redirection `https://zlxfmovibepgdmxacbpj.supabase.co/auth/v1/callback`,
   fournisseur Google activé dans Supabase avec identifiant et secret. Terminé le même jour par
   le PO : écran de consentement (Branding : nom "Nuni - Street Golf Scoring App", e-mail
   d'assistance, page d'accueil `https://nuni.centuryspine.org`, confidentialité `/privacy`,
   conditions `/legal`, domaine autorisé `centuryspine.org`, pas de logo pour éviter la validation
   Google), Audience publiée "En production", type Externe (portées de base seulement, aucune
   validation requise) ; Supabase URL Configuration : Site URL `https://nuni.centuryspine.org`,
   Redirect URLs `https://nuni.centuryspine.org/**` et `http://localhost:3000/**` (en local, l'app
   est lancée avec `--web-port 3000`). Les pages `/privacy` et `/legal` sont livrées au plan 04.
2. `npx supabase init`, `npx supabase link --project-ref zlxfmovibepgdmxacbpj`.
3. Migrations, une par thème, dans l'ordre : extensions et enums → tables → index (GiST,
   `sessions.code`, `session_members.user_id`) → fonctions utilitaires → RLS → RPC → triggers →
   publication realtime → buckets et politiques storage.
4. Jeu de données de développement (`supabase/seed.sql`) : 2 profils fictifs, quelques trous
   publics autour d'un point connu, une session live.
5. Tests des politiques : scripts SQL `supabase/tests/*.sql` avec `set role authenticated` et
   `request.jwt.claims` pour vérifier qu'un non-membre ne lit pas une session, qu'un membre ne
   modifie pas le score d'une autre équipe, etc. Exécutés en CI si le développement local Docker
   est mis en place, sinon manuellement.
6. Générer les types Dart ? Non : les modèles sont écrits à la main avec `freezed` (le générateur
   de types Supabase cible TypeScript). Documenter le mapping colonne ↔ champ dans chaque
   repository.
7. `docs/reference/modele_de_donnees.md` : schéma final et diagramme (mermaid).

## Livrables

- Projet Supabase opérationnel, migrations et seed dans le dépôt, tests RLS.
- Documentation du modèle et des RPC.

## Critères d'acceptation

- `npx supabase db push` sur un projet vide reconstruit tout le schéma sans erreur.
- Les tests RLS passent.
- Un abonnement realtime filtré sur une session reçoit les insertions de `scores` de cette session
  et pas celles d'une autre.

## Questions PO liées

Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q13. Jalon de validation 1 du plan d'ensemble à la fin de ce plan.
