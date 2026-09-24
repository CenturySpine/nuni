-- RPC functions (plan 03).
-- create_session's payload shape and start_session's "individual" team-creation logic are a
-- provisional contract: plan 07 (creation session et equipes) is not planned yet, and may need to
-- adjust this function when that plan is written. Cheap to change: nothing depends on it yet.

-- Holes within radius_m of (lat, lng), nearest first -- every hole is public (plan 26, Q110).
-- security invoker: relies entirely on the holes RLS policy for visibility.
create or replace function holes_nearby(p_lat double precision, p_lng double precision, p_radius_m int)
returns table (
  id uuid,
  name text,
  description text,
  par int,
  distance_m int,
  start_lat double precision,
  start_lng double precision,
  end_lat double precision,
  end_lng double precision,
  photo_start_path text,
  photo_end_path text,
  owner_id uuid,
  cloned_from uuid,
  distance double precision
)
language sql
security invoker
stable
set search_path = public
as $$
  select
    h.id, h.name, h.description, h.par, h.distance_m,
    h.start_lat, h.start_lng, h.end_lat, h.end_lng,
    h.photo_start_path, h.photo_end_path, h.owner_id, h.cloned_from,
    st_distance(h.start, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography) as distance
  from holes h
  where st_dwithin(h.start, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography, p_radius_m)
  order by distance;
$$;

revoke execute on function holes_nearby(double precision, double precision, int) from public;
grant execute on function holes_nearby(double precision, double precision, int) to authenticated;

-- Join a session by its code (Q15 / plan 09): security definer because discovery by code must
-- not depend on a raw SELECT on sessions (RLS there is membership-only).
create or replace function join_session(p_code text)
returns sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session sessions;
  v_player_id uuid;
  v_team_id uuid;
begin
  select * into v_session from sessions where code = upper(p_code);

  if v_session.id is null or v_session.status = 'completed' then
    raise exception 'session_unavailable' using errcode = 'P0001';
  end if;

  if exists (
    select 1 from session_members where session_id = v_session.id and user_id = auth.uid()
  ) then
    return v_session;
  end if;

  select id into v_player_id from players where user_id = auth.uid();
  if v_player_id is null then
    raise exception 'no linked player for the current user' using errcode = 'P0001';
  end if;

  if not exists (select 1 from teams where session_id = v_session.id) then
    insert into session_members (session_id, user_id, team_id, role)
    values (v_session.id, auth.uid(), null, 'player');
    return v_session;
  end if;

  select tp.team_id into v_team_id
  from team_players tp
  join teams t on t.id = tp.team_id
  where t.session_id = v_session.id and tp.player_id = v_player_id;

  if v_team_id is null then
    raise exception 'not_in_team' using errcode = 'P0001';
  end if;

  insert into session_members (session_id, user_id, team_id, role)
  values (v_session.id, auth.uid(), v_team_id, 'player');

  return v_session;
end;
$$;

revoke execute on function join_session(text) from public;
grant execute on function join_session(text) to authenticated;

-- Create a draft session, optionally with teams (Q24: every player_id must already be linked
-- to a user). payload shape:
-- {
--   "kind": "individual"|"team", "scoring_mode": "...", "ranking_direction": "asc"|"desc",
--   "city": text?, "zone": text?, "location": {"lat": number, "lng": number}?, "comment": text?,
--   "teams": [{"position": int, "player_ids": [uuid, ...]}, ...]?
-- }
create or replace function create_session(payload jsonb)
returns sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session sessions;
  v_team jsonb;
  v_team_id uuid;
  v_player_id uuid;
begin
  insert into sessions (
    owner_id, kind, scoring_mode, ranking_direction, city, zone, location, comment
  ) values (
    auth.uid(),
    (payload ->> 'kind')::session_kind,
    (payload ->> 'scoring_mode')::scoring_mode,
    (payload ->> 'ranking_direction')::ranking_direction,
    payload ->> 'city',
    payload ->> 'zone',
    case when payload -> 'location' is not null
      then st_setsrid(
        st_makepoint(
          (payload -> 'location' ->> 'lng')::double precision,
          (payload -> 'location' ->> 'lat')::double precision
        ),
        4326
      )::geography
      else null
    end,
    payload ->> 'comment'
  )
  returning * into v_session;

  insert into session_members (session_id, user_id, team_id, role)
  values (v_session.id, auth.uid(), null, 'owner');

  for v_team in select * from jsonb_array_elements(coalesce(payload -> 'teams', '[]'::jsonb))
  loop
    insert into teams (session_id, position)
    values (v_session.id, (v_team ->> 'position')::int)
    returning id into v_team_id;

    for v_player_id in
      select value::uuid from jsonb_array_elements_text(coalesce(v_team -> 'player_ids', '[]'::jsonb))
    loop
      if not exists (select 1 from players where id = v_player_id and user_id is not null) then
        raise exception 'player_not_linked' using errcode = 'P0001';
      end if;

      insert into team_players (team_id, player_id) values (v_team_id, v_player_id);
    end loop;
  end loop;

  return v_session;
end;
$$;

revoke execute on function create_session(jsonb) from public;
grant execute on function create_session(jsonb) to authenticated;

-- Start a draft session (owner only): individual sessions get one team per participant;
-- team sessions require every participant to already be assigned (Q25). Then locks the session
-- into "live".
create or replace function start_session(p_session_id uuid)
returns sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session sessions;
  v_member record;
  v_team_id uuid;
  v_unassigned text;
begin
  select * into v_session from sessions where id = p_session_id;

  if v_session.id is null or not is_session_owner(p_session_id) then
    raise exception 'not_owner' using errcode = 'P0001';
  end if;

  if v_session.status <> 'draft' then
    raise exception 'invalid_status' using errcode = 'P0001';
  end if;

  if v_session.kind = 'individual' then
    if not exists (select 1 from session_members where session_id = p_session_id) then
      raise exception 'no_participants' using errcode = 'P0001';
    end if;

    for v_member in
      select sm.user_id, p.id as player_id
      from session_members sm
      join players p on p.user_id = sm.user_id
      where sm.session_id = p_session_id and sm.team_id is null
    loop
      insert into teams (session_id, position)
      values (
        p_session_id,
        (select coalesce(max(position), 0) + 1 from teams where session_id = p_session_id)
      )
      returning id into v_team_id;

      insert into team_players (team_id, player_id) values (v_team_id, v_member.player_id);

      update session_members set team_id = v_team_id
      where session_id = p_session_id and user_id = v_member.user_id;
    end loop;
  else
    if not exists (select 1 from teams where session_id = p_session_id) then
      raise exception 'no_teams' using errcode = 'P0001';
    end if;

    select string_agg(p.name, ', ') into v_unassigned
    from session_members sm
    join players p on p.user_id = sm.user_id
    where sm.session_id = p_session_id and sm.team_id is null;

    if v_unassigned is not null then
      raise exception 'unassigned_participants: %', v_unassigned using errcode = 'P0001';
    end if;
  end if;

  update sessions set status = 'live', started_at = now()
  where id = p_session_id
  returning * into v_session;

  return v_session;
end;
$$;

revoke execute on function start_session(uuid) from public;
grant execute on function start_session(uuid) to authenticated;

-- One JSON snapshot of a live session (plan 08, Q36): the session, its teams (with their
-- players, via team_players -- the frozen-after-draft roster, Q15), its played holes (with the
-- hole's own display fields and every team's raw entered value for that hole), and its members
-- (for the "who's the owner" / "promote a co-organizer" / "which team is mine" lookups the
-- screen needs). security invoker: relies entirely on the same RLS policies as every other read
-- (sessions/teams/team_players/played_holes/scores/session_members _select), so a non-member
-- gets an empty/partial result rather than an error -- same behavior as reading the tables
-- directly. Called fresh on every realtime "something changed" event on any of those tables
-- (Q36), never patched locally client-side.
create or replace function session_snapshot(p_session_id uuid)
returns jsonb
language sql
security invoker
stable
set search_path = public
as $$
  select jsonb_build_object(
    -- Explicit field list, not to_jsonb(s): matches the Dart Session model
    -- exactly (session.dart) and skips the geography-typed `location`
    -- column, whose to_jsonb output is an opaque WKB string the client
    -- never reads.
    'session', (
      select jsonb_build_object(
        'id', s.id,
        'code', s.code,
        'owner_id', s.owner_id,
        'status', s.status,
        'kind', s.kind,
        'scoring_mode', s.scoring_mode,
        'ranking_direction', s.ranking_direction,
        'city', s.city,
        'zone', s.zone,
        'location_lat', s.location_lat,
        'location_lng', s.location_lng,
        'weather', s.weather,
        'comment', s.comment,
        'cover_photo_id', s.cover_photo_id,
        'is_championship', s.is_championship,
        'association_id', s.association_id,
        'championship_season', s.championship_season,
        -- The cover photo's storage path, not just its id: the client
        -- builds the public URL from a path (plan 10), and joining it here
        -- once is simpler than a separate `session_photos` lookup per card
        -- in the history list.
        'cover_photo_path', (
          select sp.storage_path from session_photos sp where sp.id = s.cover_photo_id
        ),
        'created_at', s.created_at,
        'started_at', s.started_at,
        'ended_at', s.ended_at
      )
      from sessions s where s.id = p_session_id
    ),
    'members', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'user_id', sm.user_id,
        'team_id', sm.team_id,
        'role', sm.role,
        'player_name', p.name
      )), '[]'::jsonb)
      from session_members sm
      join players p on p.user_id = sm.user_id
      where sm.session_id = p_session_id
    ),
    'teams', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'id', t.id,
        'position', t.position,
        'players', (
          select coalesce(jsonb_agg(jsonb_build_object(
            'player_id', pl.id,
            'name', pl.name
          ) order by pl.name), '[]'::jsonb)
          from team_players tp
          join players pl on pl.id = tp.player_id
          where tp.team_id = t.id
        )
      ) order by t.position), '[]'::jsonb)
      from teams t
      where t.session_id = p_session_id
    ),
    'played_holes', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'id', ph.id,
        'position', ph.position,
        'game_mode', ph.game_mode,
        'label', ph.label,
        'par', ph.par,
        'comment', ph.comment,
        -- null for a generic "free hole" (plan 17): no row in the hole directory.
        'hole', case when h.id is null then null else jsonb_build_object(
          'id', h.id,
          'name', h.name,
          'par', h.par,
          'start_lat', h.start_lat,
          'start_lng', h.start_lng
        ) end,
        'scores', (
          select coalesce(jsonb_agg(jsonb_build_object(
            'team_id', sc.team_id,
            'value', sc.value,
            'updated_by', sc.updated_by,
            'updated_at', sc.updated_at
          )), '[]'::jsonb)
          from scores sc
          where sc.played_hole_id = ph.id
        )
      ) order by ph.position), '[]'::jsonb)
      from played_holes ph
      left join holes h on h.id = ph.hole_id
      where ph.session_id = p_session_id
    )
  );
$$;

revoke execute on function session_snapshot(uuid) from public;
grant execute on function session_snapshot(uuid) to authenticated;

-- The history tab (plan 10, reshaped by plan 26, Q129): every completed session of the caller's
-- association -- played in or not, can_read_session lets its members read it -- plus the ones
-- the caller played in elsewhere (as a visitor), most recently started first. Each is shaped
-- exactly like a single `session_snapshot` call, reused as-is rather than duplicating the nested
-- query above, so the client parses history entries with the same `LiveSessionSnapshot` model and
-- the same tested `computeStandings` it already uses for the live screen; the client works out
-- "I played in it" from the teams' players. Simpler than a slimmer summary-only shape at this
-- app's scale.
create or replace function history_snapshots()
returns jsonb
language sql
security invoker
stable
set search_path = public
as $$
  select coalesce(jsonb_agg(session_snapshot(s.id) order by s.started_at desc nulls last), '[]'::jsonb)
  from sessions s
  where s.status = 'completed'
    and (
      is_session_member(s.id)
      or s.association_id = (select p.association_id from players p where p.user_id = auth.uid())
    );
$$;

revoke execute on function history_snapshots() from public;
grant execute on function history_snapshots() to authenticated;

-- Every completed, championship-tagged session of one association/season (plans 15 and 18, Q77),
-- shaped exactly like a single
-- `session_snapshot` call (plan 15, same reasoning as history_snapshots above): the client
-- computes each session's standings with the same tested `computeStandings`, then folds ranking
-- and attendance points into a season total in Dart (AGENTS.md: classement calculated in Dart,
-- the base only stores entered values). security definer, unlike history_snapshots: exposes
-- sessions regardless of the caller's own membership, restricted instead to sessions explicitly
-- marked championship and completed for this association/season -- a session that isn't marked
-- stays invisible to non-members, RLS unchanged for it.
create or replace function championship_association_results(p_association_id uuid, p_season text)
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(jsonb_agg(session_snapshot(s.id) order by s.started_at desc nulls last), '[]'::jsonb)
  from sessions s
  where s.is_championship
    and s.status = 'completed'
    and s.association_id = p_association_id
    and s.championship_season = p_season;
$$;

revoke execute on function championship_association_results(uuid, text) from public;
grant execute on function championship_association_results(uuid, text) to authenticated;

-- A completed session shaped like a `session_snapshot` call, stripped of what statistics never
-- read: session and played-hole comments, the cover photo, the members' accounts. Shared by
-- player_history (plan 19) and hole_history (plan 20); not callable by the app itself, only
-- through those two.
create or replace function stats_snapshot(p_session_id uuid)
returns jsonb
language sql
security invoker
stable
set search_path = public
as $$
  select jsonb_set(
    jsonb_set(
      snap #- '{session,comment}' #- '{session,cover_photo_id}' #- '{session,cover_photo_path}',
      '{members}', '[]'::jsonb
    ),
    '{played_holes}',
    (
      select coalesce(jsonb_agg(ph - 'comment' order by (ph->>'position')::int), '[]'::jsonb)
      from jsonb_array_elements(snap->'played_holes') ph
    )
  )
  from (select session_snapshot(p_session_id) as snap) s;
$$;

revoke execute on function stats_snapshot(uuid) from public, anon, authenticated;

-- Every completed session one player played in (plan 19; plan 21 builds on it), shaped like a
-- `session_snapshot` call so the client reuses `LiveSessionSnapshot` and `computeStandings`,
-- oldest first. security definer, same reasoning as championship_association_results: a
-- player's statistics must be the same whoever looks, and RLS only shows a session to its
-- participants and association. Deliberately no check on players.stats_public /
-- badges_public (Q133): hiding them is a display choice, the sessions and scores behind them
-- stay readable. Which sessions count ("eligible", Q117/Q123) is decided in Dart, written once
-- (lib/features/stats/domain/).
create or replace function player_history(p_player_id uuid)
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(jsonb_agg(stats_snapshot(s.id) order by coalesce(s.started_at, s.created_at)), '[]'::jsonb)
  from sessions s
  where s.status = 'completed'
    and exists (
      select 1 from team_players tp where tp.session_id = s.id and tp.player_id = p_player_id
    );
$$;

revoke execute on function player_history(uuid) from public;
grant execute on function player_history(uuid) to authenticated;

-- Every completed session one directory hole was played in (plan 20), oldest first, same shape
-- and same security definer reasoning as player_history: a hole's statistics and record are
-- common to every association (Q95), while RLS only shows a session to its own association.
-- A clone is another hole with its own statistics (Q135): only hole_id matches.
create or replace function hole_history(p_hole_id uuid)
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(jsonb_agg(stats_snapshot(s.id) order by coalesce(s.started_at, s.created_at)), '[]'::jsonb)
  from sessions s
  where s.status = 'completed'
    and exists (
      select 1 from played_holes ph where ph.session_id = s.id and ph.hole_id = p_hole_id
    );
$$;

revoke execute on function hole_history(uuid) from public;
grant execute on function hole_history(uuid) to authenticated;

-- Adds a played hole (owner-only -- RLS `played_holes_owner_write`): appends at the next
-- position. A plain client-side insert would need a "next position" round trip first (like
-- `_nextTeamPosition` in the Dart repository) and would race two owners adding at once; doing
-- both in one statement server-side avoids that race and keeps the RLS-only client mutations
-- pattern for everything that doesn't need it (score upserts, played-hole deletion, closing a
-- session all stay plain table calls -- see sessions_repository.dart).
-- A null p_hole_id adds a generic "free hole" (plan 17), with an optional label (blank = none);
-- the label is ignored for a hole from the directory.
create or replace function add_played_hole(
  p_session_id uuid,
  p_hole_id uuid,
  p_game_mode game_mode,
  p_label text default null,
  p_par int default null,
  p_comment text default null
)
returns played_holes
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_row played_holes;
begin
  insert into played_holes (session_id, hole_id, label, par, comment, game_mode, position)
  values (
    p_session_id,
    p_hole_id,
    case when p_hole_id is null then nullif(btrim(p_label), '') end,
    p_par,
    nullif(btrim(p_comment), ''),
    p_game_mode,
    (select coalesce(max(position), 0) + 1 from played_holes where session_id = p_session_id)
  )
  returning * into v_row;

  return v_row;
end;
$$;

revoke execute on function add_played_hole(uuid, uuid, game_mode, text, int, text) from public;
grant execute on function add_played_hole(uuid, uuid, game_mode, text, int, text) to authenticated;

-- Clones a hole for the caller (plan 26, decision 2): same fields, the caller as owner, the name
-- prefixed "Clone - " (same in every language), and cloned_from pointing at the original (Q120).
-- No photo paths: the app copies the original's photos into the caller's own storage folder,
-- then sets them on the clone like any owner edit (Q119). security invoker: the holes insert
-- policy already requires owner_id = the caller.
create or replace function clone_hole(p_hole_id uuid)
returns holes
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_row holes;
begin
  insert into holes (
    owner_id, name, description, par, distance_m, start, end_point, path, cloned_from
  )
  select auth.uid(), 'Clone - ' || h.name, h.description, h.par, h.distance_m, h.start,
    h.end_point, h.path, h.id
  from holes h
  where h.id = p_hole_id
  returning * into v_row;

  if v_row.id is null then
    raise exception 'hole_not_found' using errcode = 'P0001';
  end if;
  return v_row;
end;
$$;

revoke execute on function clone_hole(uuid) from public;
grant execute on function clone_hole(uuid) to authenticated;

-- Tags or untags a session for the championship (plan 26, decision 11): a super_admin or the
-- approved local manager of the session's association, at any time, played in or not. security
-- definer: such a caller is usually not the session's owner, whom sessions_update_owner
-- requires; sessions_guard_championship (triggers.sql) then lets the change through for them.
create or replace function set_session_championship(p_session_id uuid, p_value boolean)
returns sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session sessions;
begin
  select * into v_session from sessions where id = p_session_id;
  if v_session.id is null then
    raise exception 'session_not_found' using errcode = 'P0001';
  end if;
  if not (is_super_admin() or is_association_manager(v_session.association_id)) then
    raise exception 'not_championship_manager' using errcode = 'P0001';
  end if;

  update sessions set is_championship = p_value
  where id = p_session_id
  returning * into v_session;
  return v_session;
end;
$$;

revoke execute on function set_session_championship(uuid, boolean) from public;
grant execute on function set_session_championship(uuid, boolean) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- Associations (plan 18). The tables are read-only for the app (rls.sql): every write is one of
-- these security-definer functions, each checking who may do it. Errors are plain codes the app
-- translates (P0001, same convention as the session RPCs above).
-- ---------------------------------------------------------------------------------------------

-- Point from a {"lat": number, "lng": number} object, as the payloads below send it.
create or replace function _payload_point(p_point jsonb)
returns geography
language sql
immutable
set search_path = public
as $$
  select st_setsrid(
    st_makepoint((p_point ->> 'lng')::double precision, (p_point ->> 'lat')::double precision),
    4326
  )::geography;
$$;

-- Asks for a new association (decision 8): created 'pending' with its requester as its pending
-- local manager (Q82). The requester stays in their current association (or none) until a
-- super_admin approves (Q81). payload:
-- { "name": text, "short_name": text?, "city": text, "location": {"lat", "lng"},
--   "website_url": text?, "email": text, "phone": text, "message": text? }
create or replace function request_association(payload jsonb)
returns associations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_association associations;
  v_manager_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not_signed_in' using errcode = 'P0001';
  end if;
  if exists (select 1 from associations where created_by = auth.uid() and status = 'pending') then
    raise exception 'request_already_pending' using errcode = 'P0001';
  end if;

  insert into associations (name, short_name, city, location, website_url, created_by)
  values (
    btrim(payload ->> 'name'),
    nullif(btrim(payload ->> 'short_name'), ''),
    btrim(payload ->> 'city'),
    _payload_point(payload -> 'location'),
    nullif(btrim(payload ->> 'website_url'), ''),
    auth.uid()
  )
  returning * into v_association;

  insert into association_managers (association_id, user_id)
  values (v_association.id, auth.uid())
  returning id into v_manager_id;

  insert into association_manager_contacts (manager_id, email, phone, request_message)
  values (
    v_manager_id,
    btrim(payload ->> 'email'),
    btrim(payload ->> 'phone'),
    nullif(btrim(payload ->> 'message'), '')
  );

  return v_association;
end;
$$;

-- Claims the local manager role of an approved association that has none (decision 7, Q78).
create or replace function claim_association_manager(
  p_association_id uuid,
  p_email text,
  p_phone text,
  p_message text default null
)
returns association_managers
language plpgsql
security definer
set search_path = public
as $$
declare
  v_manager association_managers;
begin
  if auth.uid() is null then
    raise exception 'not_signed_in' using errcode = 'P0001';
  end if;
  if not exists (select 1 from associations where id = p_association_id and status = 'approved') then
    raise exception 'association_not_approved' using errcode = 'P0001';
  end if;
  if exists (
    select 1 from association_managers
    where association_id = p_association_id and status = 'approved'
  ) then
    raise exception 'association_has_manager' using errcode = 'P0001';
  end if;
  if exists (
    select 1 from association_managers
    where association_id = p_association_id and user_id = auth.uid() and status = 'pending'
  ) then
    raise exception 'claim_already_pending' using errcode = 'P0001';
  end if;

  insert into association_managers (association_id, user_id)
  values (p_association_id, auth.uid())
  returning * into v_manager;

  insert into association_manager_contacts (manager_id, email, phone, request_message)
  values (v_manager.id, btrim(p_email), btrim(p_phone), nullif(btrim(p_message), ''));

  return v_manager;
end;
$$;

-- Edits an association (decision 7): its approved local manager, or a super_admin. Only the keys
-- present in the payload change; an empty short_name/website_url/logo_path clears it. "email" /
-- "phone" update the caller's own contact details as that association's manager. payload:
-- { "name"?, "short_name"?, "city"?, "location"?: {"lat", "lng"}, "website_url"?, "logo_path"?,
--   "email"?, "phone"? }
create or replace function update_association(p_association_id uuid, payload jsonb)
returns associations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_association associations;
begin
  if not (is_association_manager(p_association_id) or is_super_admin()) then
    raise exception 'not_association_manager' using errcode = 'P0001';
  end if;

  update associations set
    name = case when payload ? 'name' then btrim(payload ->> 'name') else name end,
    short_name = case
      when payload ? 'short_name' then nullif(btrim(payload ->> 'short_name'), '')
      else short_name
    end,
    city = case when payload ? 'city' then btrim(payload ->> 'city') else city end,
    location = case
      when payload ? 'location' then _payload_point(payload -> 'location')
      else location
    end,
    website_url = case
      when payload ? 'website_url' then nullif(btrim(payload ->> 'website_url'), '')
      else website_url
    end,
    logo_path = case
      when payload ? 'logo_path' then nullif(btrim(payload ->> 'logo_path'), '')
      else logo_path
    end
  where id = p_association_id
  returning * into v_association;

  if payload ? 'email' or payload ? 'phone' then
    update association_manager_contacts c set
      email = case when payload ? 'email' then btrim(payload ->> 'email') else c.email end,
      phone = case when payload ? 'phone' then btrim(payload ->> 'phone') else c.phone end
    from association_managers am
    where am.id = c.manager_id
      and am.association_id = p_association_id
      and am.user_id = auth.uid()
      and am.status = 'approved';
  end if;

  return v_association;
end;
$$;

-- Approves or refuses an association creation request (decision 9, super_admin only). Approval
-- also approves its requester as local manager and moves them into it (Q82); refusal closes both
-- and leaves the requester where they were (the choice screen shows again if that's nowhere).
create or replace function review_association(p_association_id uuid, p_approve boolean)
returns associations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_association associations;
begin
  if not is_super_admin() then
    raise exception 'not_super_admin' using errcode = 'P0001';
  end if;

  update associations
  set status = case when p_approve then 'approved' else 'rejected' end::association_status,
      reviewed_by = auth.uid(),
      reviewed_at = now()
  where id = p_association_id and status = 'pending'
  returning * into v_association;

  if v_association.id is null then
    raise exception 'request_not_pending' using errcode = 'P0001';
  end if;

  update association_managers
  set status = case when p_approve then 'approved' else 'rejected' end::association_manager_status,
      reviewed_by = auth.uid(),
      reviewed_at = now()
  where association_id = p_association_id
    and user_id = v_association.created_by
    and status = 'pending';

  if p_approve then
    update players set association_id = p_association_id
    where user_id = v_association.created_by;
  end if;

  return v_association;
end;
$$;

-- Approves or refuses a local-manager claim (decision 7, super_admin only). Approval fails if the
-- association already has an approved manager (Q78: revoke that one first).
create or replace function review_association_manager(p_manager_id uuid, p_approve boolean)
returns association_managers
language plpgsql
security definer
set search_path = public
as $$
declare
  v_manager association_managers;
begin
  if not is_super_admin() then
    raise exception 'not_super_admin' using errcode = 'P0001';
  end if;

  select * into v_manager from association_managers where id = p_manager_id;
  if v_manager.id is null or v_manager.status <> 'pending' then
    raise exception 'request_not_pending' using errcode = 'P0001';
  end if;
  if p_approve and exists (
    select 1 from association_managers
    where association_id = v_manager.association_id and status = 'approved'
  ) then
    raise exception 'association_has_manager' using errcode = 'P0001';
  end if;

  update association_managers
  set status = case when p_approve then 'approved' else 'rejected' end::association_manager_status,
      reviewed_by = auth.uid(),
      reviewed_at = now()
  where id = p_manager_id
  returning * into v_manager;

  return v_manager;
end;
$$;

-- Removes an approved local manager (Q78, super_admin only), which reopens the claim.
create or replace function revoke_association_manager(p_manager_id uuid)
returns association_managers
language plpgsql
security definer
set search_path = public
as $$
declare
  v_manager association_managers;
begin
  if not is_super_admin() then
    raise exception 'not_super_admin' using errcode = 'P0001';
  end if;

  update association_managers
  set status = 'revoked', reviewed_by = auth.uid(), reviewed_at = now()
  where id = p_manager_id and status = 'approved'
  returning * into v_manager;

  if v_manager.id is null then
    raise exception 'manager_not_approved' using errcode = 'P0001';
  end if;
  return v_manager;
end;
$$;

-- Corrects the association of a session (Q80, super_admin only): the one way past the freeze of
-- sessions_set_association_and_season (triggers.sql).
create or replace function set_session_association(p_session_id uuid, p_association_id uuid)
returns sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session sessions;
begin
  if not is_super_admin() then
    raise exception 'not_super_admin' using errcode = 'P0001';
  end if;
  if not exists (select 1 from associations where id = p_association_id and status = 'approved') then
    raise exception 'association_not_approved' using errcode = 'P0001';
  end if;

  update sessions set association_id = p_association_id
  where id = p_session_id
  returning * into v_session;
  return v_session;
end;
$$;

revoke execute on function _payload_point(jsonb) from public;
revoke execute on function request_association(jsonb) from public;
revoke execute on function claim_association_manager(uuid, text, text, text) from public;
revoke execute on function update_association(uuid, jsonb) from public;
revoke execute on function review_association(uuid, boolean) from public;
revoke execute on function review_association_manager(uuid, boolean) from public;
revoke execute on function revoke_association_manager(uuid) from public;
revoke execute on function set_session_association(uuid, uuid) from public;
grant execute on function request_association(jsonb) to authenticated;
grant execute on function claim_association_manager(uuid, text, text, text) to authenticated;
grant execute on function update_association(uuid, jsonb) to authenticated;
grant execute on function review_association(uuid, boolean) to authenticated;
grant execute on function review_association_manager(uuid, boolean) to authenticated;
grant execute on function revoke_association_manager(uuid) to authenticated;
grant execute on function set_session_association(uuid, uuid) to authenticated;

-- Deletes an association (super_admin only, PO 2026-09-23, Q89). Refused while it has sessions:
-- they carry other players' scores and championships, which deleting would erase. Its members
-- fall back to "no association" (the app asks them to choose again); its managers and their
-- contact details go with it (cascade). Its logo files are removed by the app afterwards.
create or replace function delete_association(p_association_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not is_super_admin() then
    raise exception 'not_super_admin' using errcode = 'P0001';
  end if;
  if exists (select 1 from sessions where association_id = p_association_id) then
    raise exception 'association_has_sessions' using errcode = 'P0001';
  end if;

  update players set association_id = null where association_id = p_association_id;
  delete from associations where id = p_association_id;
end;
$$;

revoke execute on function delete_association(uuid) from public;
grant execute on function delete_association(uuid) to authenticated;
