-- Security-definer helpers used by RLS policies, to avoid recursive policies (plan 03).

create or replace function is_session_member(p_session_id uuid)
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
  );
$$;

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
  );
$$;

-- Postgres grants EXECUTE to PUBLIC by default at creation; revoke it so only signed-in clients
-- (not anon) can call these.
revoke execute on function is_session_member(uuid) from public;
revoke execute on function is_session_owner(uuid) from public;
grant execute on function is_session_member(uuid) to authenticated;
grant execute on function is_session_owner(uuid) to authenticated;
