-- Who actually joined a session (PO, 2026-09-28): in the waiting room, the organizer must tell
-- the participants added by hand or from an event apart from those who joined themselves, by the
-- code or the QR code. `checked_in_at` is set the first time a member joins themselves; null
-- means "added, hasn't joined yet".

alter table session_members add column checked_in_at timestamptz;

-- A member who inserts their own row joins themselves: the creator in create_session, a
-- newcomer in join_session, the organizer ticking "I'm attending" (plan 29).
create or replace function session_members_check_in_self()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.user_id = auth.uid() then
    new.checked_in_at := coalesce(new.checked_in_at, now());
  end if;
  return new;
end;
$$;

create trigger session_members_check_in_self_trigger
  before insert on session_members
  for each row execute function session_members_check_in_self();

revoke execute on function session_members_check_in_self() from public, authenticated;

-- Existing sessions: only their creator is known to have joined.
update session_members sm
set checked_in_at = sm.joined_at
from sessions s
where s.id = sm.session_id and s.owner_id = sm.user_id and sm.checked_in_at is null;

-- join_session (rpc.sql), unchanged except that a member already added by the organizer or from
-- an event who joins by the code is now checked in, instead of the call doing nothing.
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
