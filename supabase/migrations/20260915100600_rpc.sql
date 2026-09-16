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
