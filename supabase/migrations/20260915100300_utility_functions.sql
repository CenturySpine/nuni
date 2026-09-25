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

-- Local manager or local admin of an association (plan 27): the people who run it day to day
-- -- championship tagging, the planning's moderation, import and "start the session". Editing
-- the association itself (and naming admins) stays is_association_manager alone.
create or replace function is_association_staff(p_association_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select is_association_manager(p_association_id)
    or exists (
      select 1
      from association_admins aa
      join players p on p.id = aa.player_id
      where aa.association_id = p_association_id
        and p.user_id = auth.uid()
    );
$$;

-- Who may read a session and everything in it (plan 26, decision 12): its participants, every
-- member of its association once it has started (even without playing -- read-only, the write
-- policies are unchanged; a draft's waiting room stays its participants' own, Q132), and
-- super_admins (Q130: kept as a fallback right, the app lists nothing more for them).
create or replace function can_read_session(p_session_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select is_session_member(p_session_id)
    or exists (
      select 1
      from sessions s
      join players p on p.association_id = s.association_id
      where s.id = p_session_id
        and s.status <> 'draft'
        and p.user_id = auth.uid()
    )
    or is_super_admin();
$$;

-- Member of an association (plan 23): the caller's player belongs to it. Reads, answers and
-- comments of the planning are open to members only; super_admins are checked apart.
create or replace function is_association_member(p_association_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from players
    where user_id = auth.uid()
      and association_id = p_association_id
  );
$$;

-- Who may edit or delete an event (plan 23, Q151 and Q161): its creator, its designated person
-- in charge, the association's local manager or admins (plan 27), a super_admin.
create or replace function can_manage_event(p_event_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from events e
    left join players p on p.id = e.manager_player_id
    where e.id = p_event_id
      and (
        e.created_by = auth.uid()
        or p.user_id = auth.uid()
        or is_association_staff(e.association_id)
        or is_super_admin()
      )
  );
$$;

-- Postgres grants EXECUTE to PUBLIC by default at creation; revoke it so only signed-in clients
-- (not anon) can call these.
revoke execute on function is_session_member(uuid) from public;
revoke execute on function is_session_owner(uuid) from public;
revoke execute on function is_super_admin() from public;
revoke execute on function is_association_manager(uuid) from public;
revoke execute on function is_association_staff(uuid) from public;
revoke execute on function can_read_session(uuid) from public;
grant execute on function is_session_member(uuid) to authenticated;
grant execute on function is_session_owner(uuid) to authenticated;
grant execute on function is_super_admin() to authenticated;
grant execute on function is_association_manager(uuid) to authenticated;
grant execute on function is_association_staff(uuid) to authenticated;
grant execute on function can_read_session(uuid) to authenticated;
revoke execute on function is_association_member(uuid) from public;
revoke execute on function can_manage_event(uuid) from public;
grant execute on function is_association_member(uuid) to authenticated;
grant execute on function can_manage_event(uuid) to authenticated;
