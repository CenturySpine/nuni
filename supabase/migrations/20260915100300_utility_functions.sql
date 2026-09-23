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

-- App-wide role check (plan 16), same shape as the two functions above. Not yet referenced by
-- any RLS policy: a foundation for future structuring actions to opt into individually.
create or replace function is_super_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from user_roles
    where user_id = auth.uid()
      and role = 'super_admin'
  );
$$;

-- Approved local manager of an association (plan 18), same shape as is_session_owner above:
-- used by the associations/storage policies and the edit RPC.
create or replace function is_association_manager(p_association_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from association_managers
    where association_id = p_association_id
      and user_id = auth.uid()
      and status = 'approved'
  );
$$;

-- Postgres grants EXECUTE to PUBLIC by default at creation; revoke it so only signed-in clients
-- (not anon) can call these.
revoke execute on function is_session_member(uuid) from public;
revoke execute on function is_session_owner(uuid) from public;
revoke execute on function is_super_admin() from public;
revoke execute on function is_association_manager(uuid) from public;
grant execute on function is_session_member(uuid) to authenticated;
grant execute on function is_session_owner(uuid) to authenticated;
grant execute on function is_super_admin() to authenticated;
grant execute on function is_association_manager(uuid) to authenticated;
