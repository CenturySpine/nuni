-- Draft sessions (plan 37, Q253 to Q262): a session prepared out of sight, seen only by its
-- creator and co-organizers (and super_admins), that can't be played until it is picked when
-- creating a session -- the only way it gets published. And a super_admin may change anything in
-- any session (Q262). Nothing here changes or deletes existing data: every existing session is
-- published (the new column's default).

-- "Published" rather than "draft": status 'draft' already names the waiting room ("Preparing"),
-- and a draft session in this sense is a different thing ("Draft" in the app).
alter table sessions add column published boolean not null default true;

-- A draft stays in its waiting room (Q261): start_session and "End" fail on it. Hence never
-- completed, so it never reaches statistics, records, badges or the championship, which only read
-- completed sessions -- no filter to write there, now or later (Q255).
alter table sessions add constraint sessions_draft_not_started
  check (published or status = 'draft');

-- A draft has no event (Q257): an event has a single session that its attendees join by its
-- code, so a hidden one would block "Start the session" for everyone. It is linked to the event
-- when picked for it (publish_session). Hence never seen by event_session nor notifications.
alter table sessions add constraint sessions_draft_without_event
  check (published or event_id is null);

-- Published for good (Q256): no way back to a draft for a signed-in caller. No signed-in caller
-- (SQL editor, seed replay, plan 36's restore): anything goes, like the other sessions guards.
create or replace function sessions_guard_published()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.uid() is not null then
    raise exception 'cannot_unpublish' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger sessions_te_guard_published_trigger
  before update of published on sessions
  for each row
  when (old.published and not new.published)
  execute function sessions_guard_published();

revoke execute on function sessions_guard_published() from public, authenticated;

-- Organizer of a session: a member with the 'owner' role (the creator or a co-organizer) -- or a
-- super_admin, who may change anything in any session (Q262) without becoming a member. Every
-- write policy of the session's tables and of its photos' storage, and start_session,
-- update_session, set_session_tags, set_session_report, follow. What needs the actual role in
-- the session (joining a draft, the drafts offered at creation) reads session_members.role.
create or replace function is_session_owner(p_session_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from session_members
    where session_id = p_session_id
      and user_id = auth.uid()
      and role = 'owner'
  )
    or is_super_admin();
$$;

-- Who may read a session and everything in it (plan 26, decision 12): its participants, every
-- member of its association once it has started (even without playing -- read-only, the write
-- policies are unchanged; a waiting room stays its participants' own, Q132), and super_admins
-- (Q130). A draft (plan 37): its organizers only -- creator, co-organizers, super_admins (Q254).
create or replace function can_read_session(p_session_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select case
    when exists (select 1 from sessions where id = p_session_id and not published)
      then is_session_owner(p_session_id)
    else is_session_member(p_session_id)
      or exists (
        select 1
        from sessions s
        join players p on p.association_id = s.association_id
        where s.id = p_session_id
          and s.status <> 'draft'
          and p.user_id = auth.uid()
      )
      or is_super_admin()
  end;
$$;

-- The members who answered "present" to an event join its session's waiting room, like
-- participants added by the organizer (plan 23, Q164): shared by create_session and
-- publish_session. Not callable by the app.
create or replace function _add_event_attendees(p_session_id uuid, p_event_id uuid)
returns void
language sql
set search_path = public
as $$
  insert into session_members (session_id, user_id, team_id, role)
  select p_session_id, p.user_id, null, 'player'
  from event_responses r
  join players p on p.id = r.player_id
  where r.event_id = p_event_id
    and r.response = 'yes'
    and p.user_id is not null
  on conflict (session_id, user_id) do nothing;
$$;

revoke execute on function _add_event_attendees(uuid, uuid) from public, anon, authenticated;

-- create_session (rpc.sql), unchanged except for the "draft" key (plan 37) and the attendees
-- of an event now added by _add_event_attendees. payload shape:
-- {
--   "kind": "individual"|"team"?, "scoring_mode": "..."?, "ranking_direction": "asc"|"desc"?,
--   "tags": ["training"|"simulator"|"association_life", ...]?,
--   "spot_id": uuid?, "zone": text?, "location": {"lat": number, "lng": number}?, "city": text?,
--   "comment": text?, "teams": [{"position": int, "player_ids": [uuid, ...]}, ...]?,
--   "event_id": uuid?, "title": text?, "started_at": timestamptz?, "ended_at": timestamptz?,
--   "draft": boolean?
-- }
-- A draft (plan 37) is never started from an event (Q257): "draft" with "event_id" is refused.
-- See rpc.sql for the rest: a session entered afterwards, without scoring mode, from an event,
-- and its spot.
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
  v_spot_id uuid := (payload ->> 'spot_id')::uuid;
  v_scoring scoring_mode := (payload ->> 'scoring_mode')::scoring_mode;
  v_zone text := nullif(btrim(payload ->> 'zone'), '');
  v_started timestamptz := (payload ->> 'started_at')::timestamptz;
  v_ended timestamptz := (payload ->> 'ended_at')::timestamptz;
  v_draft boolean := coalesce((payload ->> 'draft')::boolean, false);
begin
  if v_spot_id is null and (v_scoring is not null or v_zone is null) then
    raise exception 'spot_required' using errcode = 'P0001';
  end if;
  if not _valid_schedule(v_started, v_ended) then
    raise exception 'invalid_schedule' using errcode = 'P0001';
  end if;
  if v_draft and payload ->> 'event_id' is not null then
    raise exception 'draft_with_event' using errcode = 'P0001';
  end if;

  insert into sessions (
    owner_id, kind, scoring_mode, ranking_direction, tags, spot_id, zone, city, location, comment,
    event_id, title, started_at, ended_at, published
  ) values (
    auth.uid(),
    case when v_scoring is not null then (payload ->> 'kind')::session_kind end,
    v_scoring,
    case when v_scoring is not null then (payload ->> 'ranking_direction')::ranking_direction end,
    coalesce(
      (
        select array_agg(distinct t.value::session_tag order by t.value::session_tag)
        from jsonb_array_elements_text(coalesce(payload -> 'tags', '[]'::jsonb)) as t(value)
      ),
      '{}'
    ),
    v_spot_id,
    case when v_spot_id is null then v_zone end,
    nullif(btrim(payload ->> 'city'), ''),
    coalesce(
      case when jsonb_typeof(payload -> 'location') = 'object'
        then _payload_point(payload -> 'location')
      end,
      (select location from spots where id = v_spot_id)
    ),
    nullif(btrim(payload ->> 'comment'), ''),
    (payload ->> 'event_id')::uuid,
    nullif(btrim(payload ->> 'title'), ''),
    v_started,
    v_ended,
    not v_draft
  )
  returning * into v_session;

  if v_scoring is null then
    insert into teams (session_id, position) values (v_session.id, 1);
  end if;

  insert into session_members (session_id, user_id, team_id, role)
  values (v_session.id, auth.uid(), null, 'owner');

  if v_session.event_id is not null then
    perform _add_event_attendees(v_session.id, v_session.event_id);
  end if;

  for v_team in
    select * from jsonb_array_elements(coalesce(payload -> 'teams', '[]'::jsonb))
    where v_scoring is not null
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

-- join_session (20260928100000_session_members_checked_in.sql), unchanged except for drafts
-- (plan 37, Q260): only a member already named co-organizer gets in (checked in, as before);
-- anyone else, super_admins included (they read and change it without joining), is refused
-- with 'draft_session' and nothing is written.
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

  if not v_session.published and not exists (
    select 1 from session_members
    where session_id = v_session.id and user_id = auth.uid() and role = 'owner'
  ) then
    raise exception 'draft_session' using errcode = 'P0001';
  end if;

  if exists (
    select 1 from session_members where session_id = v_session.id and user_id = auth.uid()
  ) then
    update session_members set checked_in_at = now()
    where session_id = v_session.id and user_id = auth.uid() and checked_in_at is null;
    return v_session;
  end if;

  select id into v_player_id from players where user_id = auth.uid();
  if v_player_id is null then
    raise exception 'no linked player for the current user' using errcode = 'P0001';
  end if;

  -- A session without scores (plan 29): session_members_place_attendee (triggers.sql) puts the
  -- newcomer on its single team, among the attendees.
  if v_session.scoring_mode is null then
    insert into session_members (session_id, user_id, team_id, role)
    values (v_session.id, auth.uid(), null, 'player');
    return v_session;
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

-- Publishes a draft (plan 37, Q256, Q259): the only way, called when the draft is picked to
-- create a session. Its organizers only (super_admins included). With an event ("Start the
-- session", Q257): linked to it in the same update -- sessions_guard_event (triggers.sql,
-- 20260929110000) checks the caller may start that event, today's and of the same association,
-- and that it has no session yet -- then its "present" members join the waiting room, exactly as
-- for a new session. No notification: the attendees are told when it starts, as always.
create or replace function publish_session(p_session_id uuid, p_event_id uuid default null)
returns sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session sessions;
begin
  select * into v_session from sessions where id = p_session_id;
  if v_session.id is null or not is_session_owner(p_session_id) then
    raise exception 'not_owner' using errcode = 'P0001';
  end if;
  if v_session.published then
    raise exception 'already_published' using errcode = 'P0001';
  end if;

  update sessions set published = true, event_id = p_event_id
  where id = p_session_id
  returning * into v_session;

  if p_event_id is not null then
    perform _add_event_attendees(p_session_id, p_event_id);
  end if;

  return v_session;
end;
$$;

revoke execute on function publish_session(uuid, uuid) from public, anon;
grant execute on function publish_session(uuid, uuid) to authenticated;
