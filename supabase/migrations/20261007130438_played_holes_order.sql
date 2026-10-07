-- Holes prepared and ordered before the game (plan 37, avenant, Q263 to Q269). Holes can already
-- be written by the organizers before "Start" (played_holes_owner_write has no status condition);
-- this adds the order: the display direction, shared by everyone in the session; moving a hole
-- to another place in the course, which renumbers the holes in between; and, when the session
-- is completed, removing the holes nobody scored. Nothing here changes or deletes existing data:
-- every existing session keeps today's display (most recent hole on top).

-- A played hole's identity is its id (scores point to it); its place in the course is
-- played_holes.position, which is also the number shown ("Hole 3"). The display direction is
-- separate: false (the default) shows the most recent hole on top, as before; true shows hole 1
-- on top (Q267). Written by the organizers, through sessions_update_owner.
alter table sessions add column holes_ascending boolean not null default false;

-- session_snapshot (rpc.sql), unchanged except for "published" (plan 37) and "holes_ascending".
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
        'tags', to_jsonb(s.tags),
        'city', s.city,
        'zone', s.zone,
        'spot_id', s.spot_id,
        'location_lat', s.location_lat,
        'location_lng', s.location_lng,
        'weather', s.weather,
        'comment', s.comment,
        'title', s.title,
        'cover_photo_id', s.cover_photo_id,
        'is_championship', s.is_championship,
        'association_id', s.association_id,
        'championship_season', s.championship_season,
        'published', s.published,
        'holes_ascending', s.holes_ascending,
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

-- Renumbers a session's played holes 1, 2, 3... in the order of [p_ids] (every hole of the
-- session, once each). The unique (session_id, position) constraint isn't deferrable, so the
-- places go through negative values first. Not callable by the app.
create or replace function _renumber_played_holes(p_session_id uuid, p_ids uuid[])
returns void
language sql
set search_path = public
as $$
  update played_holes ph set position = -o.rn
  from unnest(p_ids) with ordinality as o(id, rn)
  where ph.id = o.id and ph.session_id = p_session_id;
  update played_holes set position = -position where session_id = p_session_id and position < 0;
$$;

revoke execute on function _renumber_played_holes(uuid, uuid[]) from public, anon, authenticated;

-- Moves a played hole to place [p_position] of its session's course (1 = the first hole), the
-- holes in between shifting by one (Q265, Q267): its number changes with its place, never its
-- identity nor its scores. The session's organizers only, super_admins included (Q262), until
-- the session is completed (Q269). A place out of range puts it first or last.
create or replace function move_played_hole(p_played_hole_id uuid, p_position int)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session sessions;
  v_ids uuid[];
  v_place int;
begin
  select s.* into v_session
  from sessions s
  join played_holes ph on ph.session_id = s.id
  where ph.id = p_played_hole_id;
  if v_session.id is null or not is_session_owner(v_session.id) then
    raise exception 'not_owner' using errcode = 'P0001';
  end if;
  if v_session.status = 'completed' then
    raise exception 'session_completed' using errcode = 'P0001';
  end if;

  -- Two organizers moving at once: one waits for the other.
  perform 1 from played_holes where session_id = v_session.id for update;

  select coalesce(array_agg(id order by position), '{}') into v_ids
  from played_holes
  where session_id = v_session.id and id <> p_played_hole_id;
  v_place := greatest(1, least(coalesce(p_position, 1), cardinality(v_ids) + 1));
  v_ids := v_ids[1:v_place - 1] || p_played_hole_id || v_ids[v_place:];

  perform _renumber_played_holes(v_session.id, v_ids);
end;
$$;

revoke execute on function move_played_hole(uuid, int) from public, anon;
grant execute on function move_played_hole(uuid, int) to authenticated;

-- When a session is completed (Q266): the holes nobody scored, prepared but never played, are
-- removed -- a hole counts as played everywhere (holes count, the hole's history) -- and the
-- others renumbered 1, 2, 3... without gaps (Q269). A hole one team scored is kept. In the base,
-- so it holds for every way of ending a session. security definer: whichever organizer ends it.
create or replace function sessions_drop_unplayed_holes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_ids uuid[];
begin
  delete from played_holes ph
  where ph.session_id = new.id
    and not exists (select 1 from scores sc where sc.played_hole_id = ph.id);

  select coalesce(array_agg(id order by position), '{}') into v_ids
  from played_holes
  where session_id = new.id;
  perform _renumber_played_holes(new.id, v_ids);
  return null;
end;
$$;

create trigger sessions_drop_unplayed_holes_trigger
  after update of status on sessions
  for each row
  when (new.status = 'completed' and old.status is distinct from 'completed')
  execute function sessions_drop_unplayed_holes();

revoke execute on function sessions_drop_unplayed_holes() from public, authenticated;
