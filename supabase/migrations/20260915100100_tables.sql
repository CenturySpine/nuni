-- Tables for the NUNI schema (plan 03).
-- legacy_id columns prepare the LsgScores import (plan 13): nullable, unique, unused until then.

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
  created_by uuid not null references auth.users (id),
  user_id uuid unique references auth.users (id),
  legacy_id bigint unique,
  created_at timestamptz not null default now()
);

create table holes (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id),
  name text not null,
  description text,
  par int not null default 3,
  distance_m int,
  start geography(point, 4326) not null,
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
  photo_start_path text,
  photo_end_path text,
  visibility hole_visibility not null default 'public',
  legacy_id bigint unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
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
  hole_id uuid not null references holes (id),
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
