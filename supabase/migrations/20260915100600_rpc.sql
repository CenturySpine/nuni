-- RPC functions (plan 03).
-- create_session's payload shape and start_session's "individual" team-creation logic are a
-- provisional contract: plan 07 (creation session et equipes) is not planned yet, and may need to
-- adjust this function when that plan is written. Cheap to change: nothing depends on it yet.

-- Public + my private holes within radius_m of (lat, lng), nearest first.
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
  visibility hole_visibility,
  owner_id uuid,
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
    h.photo_start_path, h.photo_end_path, h.visibility, h.owner_id,
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
        'hole', jsonb_build_object(
          'id', h.id,
          'name', h.name,
          'par', h.par,
          'start_lat', h.start_lat,
          'start_lng', h.start_lng,
          'visibility', h.visibility
        ),
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
      join holes h on h.id = ph.hole_id
      where ph.session_id = p_session_id
    )
  );
$$;

revoke execute on function session_snapshot(uuid) from public;
grant execute on function session_snapshot(uuid) to authenticated;

-- Every completed session the caller is a member of, most recently started first, each shaped
-- exactly like a single `session_snapshot` call (plan 10) -- reused as-is rather than duplicating
-- the nested query above, so the client parses history entries with the same `LiveSessionSnapshot`
-- model and the same tested `computeStandings` it already uses for the live screen. Simpler than
-- a slimmer summary-only shape at this app's scale (a personal history, not a public feed).
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
    and is_session_member(s.id);
$$;

revoke execute on function history_snapshots() from public;
grant execute on function history_snapshots() to authenticated;

-- Adds a played hole (owner-only -- RLS `played_holes_owner_write`): appends at the next
-- position. A plain client-side insert would need a "next position" round trip first (like
-- `_nextTeamPosition` in the Dart repository) and would race two owners adding at once; doing
-- both in one statement server-side avoids that race and keeps the RLS-only client mutations
-- pattern for everything that doesn't need it (score upserts, played-hole deletion, closing a
-- session all stay plain table calls -- see sessions_repository.dart).
create or replace function add_played_hole(p_session_id uuid, p_hole_id uuid, p_game_mode game_mode)
returns played_holes
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_row played_holes;
begin
  insert into played_holes (session_id, hole_id, game_mode, position)
  values (
    p_session_id,
    p_hole_id,
    p_game_mode,
    (select coalesce(max(position), 0) + 1 from played_holes where session_id = p_session_id)
  )
  returning * into v_row;

  return v_row;
end;
$$;

revoke execute on function add_played_hole(uuid, uuid, game_mode) from public;
grant execute on function add_played_hole(uuid, uuid, game_mode) to authenticated;
