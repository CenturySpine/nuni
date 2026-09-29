-- A participant added by the organizer or from an event who opens the session from their home
-- has joined it too (Q218, PO 2026-09-28), like one who used the code. Members can't update
-- their own session_members row (owner-only policy), hence this security definer function,
-- which only ever touches the caller's own row, and only before the session is completed.
create or replace function check_in_session(p_session_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update session_members set checked_in_at = now()
  where session_id = p_session_id
    and user_id = auth.uid()
    and checked_in_at is null
    and exists (select 1 from sessions where id = p_session_id and status <> 'completed');
$$;

revoke execute on function check_in_session(uuid) from public;
grant execute on function check_in_session(uuid) to authenticated;
