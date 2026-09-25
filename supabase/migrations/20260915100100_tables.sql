-- Tables for the NUNI schema (plan 03).
-- legacy_id columns prepare the LsgScores import (plan 13): nullable, unique, unused until then.

-- Associations (plan 18): the club a player belongs to and a session is played for; a
-- championship is one association's season (Q77). A player's creation request stays 'pending'
-- until a super_admin approves it (Q81: only an approved association can own sessions). The
-- initial list (Q84) is supabase/associations_seed.sql. "location" places the city (Q83): the
-- first-sign-in screen suggests the nearest association from it.
create table associations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (btrim(name) <> ''),
  -- Abbreviation shown in tight spots (championship card): "LSG", "SGO"...
  short_name text,
  city text not null check (btrim(city) <> ''),
  location geography(point, 4326) not null,
  -- Plain numeric columns PostgREST can return as-is, same reasoning as holes.start_lat below.
  location_lat double precision generated always as (st_y(location::geometry)) stored,
  location_lng double precision generated always as (st_x(location::geometry)) stored,
  website_url text,
  -- Path in the "association-logos" bucket; empty until a local manager uploads one.
  logo_path text,
  -- Partners (plan 27: sponsors or collaborators), in the order the manager chose (Q176): a JSON
  -- array of {"label", "url"?}, the link optional (Q175), at most 20. Written by
  -- update_association, which checks each entry.
  partners jsonb not null default '[]'::jsonb
    check (jsonb_typeof(partners) = 'array' and jsonb_array_length(partners) <= 20),
  status association_status not null default 'pending',
  -- Null for the initial list, seeded rather than requested.
  created_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  reviewed_by uuid references auth.users (id),
  reviewed_at timestamptz
);

-- No separate "profiles" table: with Q24 (players are only ever created by the
-- sign-up trigger, never claimed or created ad hoc), a profile and its linked
-- player were always 1:1 and kept in sync on every save -- pure duplication.
-- "players" IS the account-facing table; auth.users is referenced directly
-- (standard practice, not fragile: Supabase manages that table, but it's a
-- normal foreign key target). Decision: PO, 2026-09-16.
create table players (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  avatar_url text,
  locale text not null default 'fr',
  -- Null = not chosen yet: the app asks at the next opening (plan 18), unless the player has a
  -- creation request pending (Q81). Only ever an approved association (guard in triggers.sql).
  association_id uuid references associations (id),
  created_by uuid not null references auth.users (id),
  user_id uuid unique references auth.users (id),
  legacy_id bigint unique,
  -- Whether the statistics and badges sections show on the player's public page (plans 19 and
  -- 21, Q108). Display only (Q133): the sessions and scores they're computed from stay readable
  -- by every signed-in account either way (player_history, rpc.sql).
  stats_public boolean not null default true,
  badges_public boolean not null default true,
  created_at timestamptz not null default now()
);

-- LsgScores e-mail of an imported player who has no NUNI account yet (plan 13, Q64): at sign-up,
-- handle_new_user (triggers.sql) links the new account to this player instead of creating a
-- second one, then deletes the row. Private: no grant to anon/authenticated at all, only the
-- import script (service_role) and the security-definer trigger touch it -- the one accepted
-- exception to "no user<->player link table" (AGENTS.md), since it links no account and empties
-- itself as people sign up. Stored lower-cased.
create table legacy_player_emails (
  player_id uuid primary key references players (id) on delete cascade,
  email text not null unique
);

-- App-wide role, distinct from session_members.role (plan 16). Only exceptions are stored: a
-- user with no row here is an implicit 'player' -- no trigger populates one at sign-up, unlike
-- players. Bootstrapped by supabase/seed_super_admin.sql, mandatory after every reconstruction
-- (rule 8, AGENTS.md) since this table lives in "public" like players.
create table user_roles (
  user_id uuid primary key references auth.users (id),
  role app_role not null default 'player',
  created_at timestamptz not null default now()
);

create table holes (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id),
  name text not null,
  description text,
  par int not null default 3,
  distance_m int,
  -- Nullable only for holes imported from LsgScores (plan 13, Q49), which never had a position:
  -- the PO sets it by hand afterwards. The app itself always writes one (the form requires it).
  -- A null start keeps the hole out of holes_nearby (st_dwithin on null is never true).
  start geography(point, 4326),
  -- Plain numeric columns PostgREST can return as-is: selecting "start" directly
  -- would come back as WKB hex, unusable client-side without a spatial function.
  start_lat double precision generated always as (st_y(start::geometry)) stored,
  start_lng double precision generated always as (st_x(start::geometry)) stored,
  -- Target point (PO, 2026-09-16): optional, prepares a future path line
  -- between start and end. Not used by holes_nearby (proximity is start-only).
  -- Named "end_point", not "end": END is a reserved SQL keyword.
  end_point geography(point, 4326),
  end_lat double precision generated always as (st_y(end_point::geometry)) stored,
  end_lng double precision generated always as (st_x(end_point::geometry)) stored,
  -- Ordered waypoints of the walk from start to end (PO, 2026-09-18), drawn as
  -- a line on the hole's map. Display-only, never queried spatially (unlike
  -- start/end_point above), so a plain jsonb array of {"lat":.., "lng":..}
  -- is simpler here than a PostGIS linestring plus a GeoJSON-extraction column.
  path jsonb,
  photo_start_path text,
  photo_end_path text,
  -- Every hole is public (plan 26, Q110): visible to and playable by everyone, editable by its
  -- owner only. The hole it was cloned from (plan 26, Q120), null for an original; kept apart so
  -- a clone doesn't count as a new hole for the "Bâtisseur" badges (plan 21).
  cloned_from uuid references holes (id) on delete set null,
  legacy_id bigint unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Local managers of an association (plan 18): one row per claim, kept after a decision for the
-- record. At most one approved manager per association (Q78, unique index in indexes.sql). The
-- requester of an association creation gets a 'pending' row too, approved together with the
-- association (Q82). Readable by everyone (the association page shows the manager's name); the
-- contact details live apart, in association_manager_contacts.
create table association_managers (
  id uuid primary key default gen_random_uuid(),
  association_id uuid not null references associations (id) on delete cascade,
  user_id uuid not null references auth.users (id),
  status association_manager_status not null default 'pending',
  requested_at timestamptz not null default now(),
  reviewed_by uuid references auth.users (id),
  reviewed_at timestamptz
);

-- A manager's e-mail and phone, and the message of their claim (plan 18): never public. A table
-- of its own rather than hidden columns on association_managers, so an ordinary list query can't
-- expose them by mistake and the access rule stays one simple policy (the manager themself, or a
-- super_admin). An association creation request is always a claim too (Q82), so its message
-- lives here as well.
create table association_manager_contacts (
  manager_id uuid primary key references association_managers (id) on delete cascade,
  email text not null check (btrim(email) <> ''),
  phone text not null check (btrim(phone) <> ''),
  -- Free text from the requester to the super_admin (Q86).
  request_message text
);

-- Local admins of an association (plan 27): members named by its local manager or a super_admin,
-- with the manager's day-to-day rights (is_association_staff) but not the editing of the
-- association itself. No limit on their number (Q173); readable by everyone, like the manager
-- (Q174). A row goes away when its player leaves the association (Q171, triggers.sql) or
-- renounces (Q170); it stays when the manager is revoked (Q172). Written only through the
-- add/remove RPCs of rpc.sql.
create table association_admins (
  association_id uuid not null references associations (id) on delete cascade,
  player_id uuid not null references players (id) on delete cascade,
  appointed_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (association_id, player_id)
);

create table sessions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  owner_id uuid not null references auth.users (id),
  status session_status not null default 'draft',
  kind session_kind not null,
  scoring_mode scoring_mode not null,
  ranking_direction ranking_direction not null,
  city text,
  zone text,
  location geography(point, 4326),
  -- Plain numeric columns PostgREST can return as-is, same reasoning as
  -- holes.start_lat/start_lng above.
  location_lat double precision generated always as (st_y(location::geometry)) stored,
  location_lng double precision generated always as (st_x(location::geometry)) stored,
  started_at timestamptz,
  ended_at timestamptz,
  weather jsonb,
  comment text,
  cover_photo_id uuid,
  -- The creator's association when the session was created (plan 18), set by a trigger
  -- (triggers.sql), never by the client; frozen afterwards except by a super_admin (Q80). Also
  -- the championship this session counts for when tagged (Q77).
  association_id uuid not null references associations (id),
  -- Championship tagging (plan 15): posed by the creator (is_championship), the season computed
  -- by a trigger (triggers.sql) -- never posed by the client.
  is_championship boolean not null default false,
  -- "September Y to August Y+1" season, derived from when the session was played -- never typed
  -- in. NOT a generated column, unlike location_lat/location_lng above: Postgres requires a
  -- generated column's expression to be IMMUTABLE, and extracting year/month from a timestamptz
  -- is only STABLE (it depends on the session's TimeZone setting) -- confirmed the hard way,
  -- `create table` refused with "generation expression is not immutable" (SQLSTATE 42P17).
  -- Recomputed instead on every insert/update by a trigger -- the client never writes it
  -- directly.
  championship_season text,
  -- The planning event this session was started from (plan 23, Q160), if any: a shortcut only,
  -- the session is otherwise like any other. Foreign key added below, once events exists; set
  -- by create_session and guarded by sessions_guard_event (triggers.sql).
  event_id uuid,
  legacy_id bigint unique,
  created_at timestamptz not null default now()
);

create table teams (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references sessions (id) on delete cascade,
  position int not null,
  legacy_id bigint unique,
  unique (session_id, position)
);

-- session_id is denormalized from teams.session_id (Q35, plan 08): team_players has no session
-- column of its own, so a realtime subscription can't filter it by session_id without one.
-- Populated by a trigger (triggers.sql), never set by the client.
create table team_players (
  team_id uuid not null references teams (id) on delete cascade,
  player_id uuid not null references players (id),
  session_id uuid not null references sessions (id) on delete cascade,
  primary key (team_id, player_id)
);

create table session_members (
  session_id uuid not null references sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id),
  team_id uuid references teams (id) on delete set null,
  role member_role not null default 'player',
  joined_at timestamptz not null default now(),
  primary key (session_id, user_id)
);

create table played_holes (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references sessions (id) on delete cascade,
  -- Null = generic "free hole" (plan 17, Q56): played on the spot without any row in the hole
  -- directory; its displayed name comes from the app's translations, plus the optional label.
  hole_id uuid references holes (id),
  -- Optional name typed when adding a free hole (Q57); only ever set when hole_id is null.
  label text,
  -- The par for this session (plan 26, Q118): copied from the hole's own par when added, then
  -- editable by the organizer (a harder or easier variant), and required for a free hole. Never
  -- follows later edits of the hole, so past sessions keep their par. Filled by
  -- played_holes_set_par (triggers.sql) when not supplied.
  par int not null check (par between 1 and 10),
  -- Optional note for this hole in this session only (plan 26), never the hole's description.
  comment text,
  game_mode game_mode not null,
  position int not null,
  legacy_id bigint unique,
  created_at timestamptz not null default now(),
  unique (session_id, position)
);

-- session_id is denormalized from played_holes.session_id (Q35, plan 08), same reasoning and
-- population mechanism as team_players.session_id above.
create table scores (
  played_hole_id uuid not null references played_holes (id) on delete cascade,
  team_id uuid not null references teams (id) on delete cascade,
  session_id uuid not null references sessions (id) on delete cascade,
  value int not null check (value between 0 and 20),
  updated_by uuid references auth.users (id),
  updated_at timestamptz not null default now(),
  primary key (played_hole_id, team_id)
);

create table session_photos (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references sessions (id) on delete cascade,
  storage_path text not null,
  uploaded_by uuid references auth.users (id),
  created_at timestamptz not null default now()
);

alter table sessions
  add constraint sessions_cover_photo_id_fkey
  foreign key (cover_photo_id) references session_photos (id) on delete set null;

-- Association planning (plan 23): what an association plans -- game sessions, but also its
-- Christmas dinner or general assembly (Q160), hence a table of its own rather than a session
-- status. Only the start is stored (no end time); spot and point are optional, so an event can
-- open for answers before its place is decided (Q150). The spot is plain text: the reusable list
-- of spots and labels is read from what the association already used (Q147, Q148), no table.
create table events (
  id uuid primary key default gen_random_uuid(),
  -- The creator's association, set by events_set_defaults (triggers.sql) for an event typed in
  -- the app; the target association for an import (import_events, rpc.sql).
  association_id uuid not null references associations (id) on delete cascade,
  created_by uuid not null references auth.users (id),
  -- The person in charge, defaulting to the creator's player; optional.
  manager_player_id uuid references players (id) on delete set null,
  starts_at timestamptz not null,
  label text not null check (btrim(label) <> ''),
  spot text check (spot is null or btrim(spot) <> ''),
  location geography(point, 4326),
  -- Plain numeric columns PostgREST can return as-is, same reasoning as holes.start_lat.
  location_lat double precision generated always as (st_y(location::geometry)) stored,
  location_lng double precision generated always as (st_x(location::geometry)) stored,
  description text,
  color event_color,
  -- Never typed: 'manual' for any event written by the app, 'imported' only through
  -- import_events (Q155).
  origin event_origin not null default 'manual',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- A member's answer to an event (Q157): their own only, until the event starts.
create table event_responses (
  event_id uuid not null references events (id) on delete cascade,
  player_id uuid not null references players (id) on delete cascade,
  response event_response not null,
  updated_at timestamptz not null default now(),
  primary key (event_id, player_id)
);

-- An event's comment thread (plan 23): linear, no reply nor mention. edited_at stays null until
-- its author edits it (the app then shows "edited", Q166).
create table event_comments (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events (id) on delete cascade,
  author_player_id uuid not null references players (id) on delete cascade,
  body text not null check (btrim(body) <> '' and char_length(body) <= 2000),
  created_at timestamptz not null default now(),
  edited_at timestamptz
);

alter table sessions
  add constraint sessions_event_id_fkey
  foreign key (event_id) references events (id) on delete set null;
