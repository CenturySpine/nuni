# Plan 16 — Rôles applicatifs (super_admin / player)

## Objectif

Poser un mécanisme générique de rôle applicatif, distinct des rôles au sein d'une session
(`session_members.role`, owner/player), pour que certaines actions structurantes de l'app puissent
un jour être réservées à un compte "super admin" plutôt qu'à personne. Aucune action existante
n'est modifiée par ce plan : c'est une fondation, pas une fonctionnalité visible.

## Prérequis

Aucun : ce plan ne touche que le socle `auth.users`, déjà en place depuis l'étape 3.

## Contexte

Aucun compte n'a aujourd'hui de droit élevé dans NUNI. Le besoin concret qui a fait surgir la
demande : le plan 13 (migration LsgScores, M5) prévoyait que seul le script de migration, exécuté
avec la clé service, puisse marquer rétroactivement d'anciennes sessions importées comme
"championnat" — parce qu'aucun rôle applicatif n'existait pour le faire autrement. Le PO a demandé
de poser la brique générique une fois pour toutes plutôt que de contourner au cas par cas.

## Décisions retenues (validées par le PO le 2026-09-22)

- **Q46** — Le rôle est lié à `auth.users`, pas à `players` : cohérent avec le reste du modèle
  d'accès (`is_session_owner`/`is_session_member` vérifient déjà `auth.uid()`, jamais un
  `player_id`) ; `players.user_id` peut être vide (joueur importé de LsgScores), donc un rôle posé
  là retomberait de toute façon sur l'utilisateur authentifié dans ce cas.
- **Q47** — Stockage en type énuméré Postgres `app_role` (`player`, `super_admin`) + une seule
  table de lien `user_roles(user_id, role)`, pas une table catalogue à deux lignes : même famille
  que `member_role` (owner/player par session), déjà en place ; AGENTS.md interdit explicitement
  une table de référence pour un ensemble de valeurs fixe et connu d'avance (déjà appliqué à
  `scoring_mode`/`game_mode`). Seule l'exception (`super_admin`) est stockée ; l'absence de ligne
  vaut `player` implicite.
- Seul le compte `bruno.chappe@gmail.com` (id auth `667e1434-75e2-4eb7-b122-ed8681905cea`) est
  `super_admin`, au lancement.
- Portée volontairement limitée à la fondation : aucune politique RLS existante n'est modifiée,
  aucun écran n'est construit. Les futures actions structurantes (par ex. plan 13 M5) s'appuieront
  sur `is_super_admin()` au moment où elles seront détaillées, chacune au cas par cas.

## Modèle de données

Migrations éditées (fichiers thématiques existants, règle 8 AGENTS.md — aucun nouveau fichier), et
**préavis au PO avant de reconstruire le schéma distant** (même règle) :

- `20260915100000_extensions_and_enums.sql` : `create type app_role as enum ('player',
  'super_admin');` — distinct de `member_role` (rôle dans une session).
- `20260915100100_tables.sql` : `user_roles (user_id uuid primary key references auth.users(id),
  role app_role not null default 'player', created_at timestamptz not null default now())`. Aucun
  trigger sur `auth.users` ne l'alimente (contrairement à `players`) : un compte absent de cette
  table est un `player` implicite, pas de ligne à créer à chaque inscription.
- `20260915100300_utility_functions.sql` : fonction `security definer` `is_super_admin() returns
  boolean` — même gabarit que `is_session_member`/`is_session_owner` (`stable`, `set search_path =
  public`, exécution révoquée à `PUBLIC` puis regrantée à `authenticated`). Pas encore référencée
  par une politique RLS existante.
- `20260915100400_rls.sql` : RLS activée sur `user_roles`, `grant select` à `authenticated`,
  politique `user_roles_select_self` (`user_id = auth.uid()`) — un compte lit seulement sa propre
  ligne. **Aucune politique ni `GRANT` d'écriture pour `authenticated`** : la table n'est jamais
  modifiable depuis l'app, seulement en accès direct à la base avec la clé service — aucune
  élévation de droit possible par un client, même compromis.
- `20260915100200_indexes.sql` : inchangé, la clé primaire couvre le seul motif de lecture (sa
  propre ligne).
- `20260915100500_triggers.sql`, `..._rpc.sql`, `..._realtime.sql`, `..._storage.sql` : inchangés.

Seed obligatoire, pas optionnel (contrairement à `remote_seed.sql`) : `user_roles` vit dans le
schéma `public`, donc vidée à chaque reconstruction (règle 8, AGENTS.md), comme `players`. Nouveau
script committé `supabase/seed_super_admin.sql`, idempotent (`on conflict do nothing`), posant
`bruno.chappe@gmail.com` en `super_admin`. Ajouté à la procédure de reconstruction de
`docs/DEV.md`, juste après l'étape "recréer la fiche players" (`backfill_players.sql`), avant
l'étape optionnelle `remote_seed.sql`.

## Miroir applicatif (Dart)

Nouveau module transverse `lib/core/authorization/` (comme `core/theme`, `core/router` — pas
rattaché à une seule feature) :

- `app_role.dart` — enum `AppRole { player, superAdmin }`, miroir de l'enum Postgres (même
  convention que les autres enums, Q6).
- `authorization_repository.dart` — sur le modèle de
  `lib/features/profile/data/profile_repository.dart` (`fetchMyPlayer`/`myPlayer`) : lit sa propre
  ligne dans `user_roles` (RLS la limite déjà à soi-même), retombe sur `AppRole.player` si aucune
  ligne. Provider Riverpod `myAppRoleProvider`, et `isSuperAdminProvider` dérivé pour un usage
  direct dans un futur `if` d'écran.

Aucun écran ni composant construit dans ce plan : rien dans l'app ne consomme encore ce rôle,
c'est une fondation pour une fonctionnalité future.

## Étapes (développement)

1. Migrations : enum, table, fonction, RLS (liste ci-dessus) — **préavis PO puis reconstruction du
   schéma distant** (règle 8 AGENTS.md), `docs/reference/modele_de_donnees.md` mis à jour en même
   temps.
2. `supabase/seed_super_admin.sql` + mise à jour de `docs/DEV.md`.
3. `lib/core/authorization/` : enum + repository + providers.
4. `fvm flutter analyze` et `fvm flutter test`.

## Critères d'acceptation

- Après reconstruction et seed : seul `bruno.chappe@gmail.com` a une ligne `super_admin` dans
  `user_roles` ; tout autre compte n'a aucune ligne (donc `player` implicite).
- `is_super_admin()` suit exactement le même gabarit de sécurité que
  `is_session_owner()`/`is_session_member()`.
- Aucune politique RLS existante modifiée, aucun écran ni comportement visible changé : seuls les
  fichiers listés ci-dessus changent.
- `fvm flutter analyze` sans avertissement, tests verts, build Vercel vert (définition de
  "terminé", AGENTS.md). Pas de nouvelles chaînes ARB : aucun texte visible ajouté par ce plan.

## Questions PO liées

Q46 et Q47 — voir [QUESTIONS_PO.md](../QUESTIONS_PO.md). Toutes deux tranchées.
