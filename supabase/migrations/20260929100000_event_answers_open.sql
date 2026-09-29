-- Answers to an event stay open after it starts (PO, 2026-09-29): closing them at the start
-- time (Q157) served no purpose, and kept a latecomer from saying they came. The guard now only
-- stamps updated_at.
create or replace function event_responses_guard()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    return old;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

-- Whether [p_event_id] has a session, not completed, the caller hasn't joined (PO, 2026-09-29):
-- the event page then offers "Join the session" to its attendees. A session still in its
-- waiting room is invisible to non-members (can_read_session), hence this security definer
-- function, which tells whether one exists and nothing else, and only to the event's
-- association members.
create or replace function event_has_joinable_session(p_event_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from sessions s
    join events e on e.id = s.event_id
    where s.event_id = p_event_id
      and s.status <> 'completed'
      and is_association_member(e.association_id)
      and not is_session_member(s.id)
  );
$$;

revoke execute on function event_has_joinable_session(uuid) from public;
grant execute on function event_has_joinable_session(uuid) to authenticated;
