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

-- Championship zone assignment (plan 15, Q44): looks for an existing championship session
-- within 15 km of the one it's called for that already has a zone; reuses it if found,
-- otherwise founds a new zone. security definer: must see every championship session
-- regardless of the caller's own membership (sessions RLS is member-only), same reasoning as
-- is_session_member/is_session_owner above. Called only from the trigger below -- not meant to
-- be invoked directly by a client, but granted to authenticated anyway (same gabarit) since the
-- trigger runs as the authenticated caller, not as this function's owner.
create or replace function assign_championship_zone(p_session sessions)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_zone_id uuid;
begin
  select championship_zone_id into v_zone_id
  from sessions
  where is_championship
    and championship_zone_id is not null
    and id <> p_session.id
    and st_dwithin(location, p_session.location, 15000)
  order by created_at
  limit 1;

  if v_zone_id is null then
    insert into championship_zones default values returning id into v_zone_id;
  end if;

  return v_zone_id;
end;
$$;

-- Displayed name of a championship zone (Q41): the most frequent "city" text among its member
-- sessions, deduced at read time -- never stored (see championship_zones above). security
-- definer: reads across every session of the zone, not just the caller's own, same reasoning as
-- assign_championship_zone. Used both by the classement screen and by the tagging confirmation
-- at session creation/settings.
create or replace function championship_zone_label(p_zone_id uuid)
returns text
language sql
security definer
stable
set search_path = public
as $$
  select city
  from sessions
  where championship_zone_id = p_zone_id
    and city is not null
  group by city
  order by count(*) desc
  limit 1;
$$;

-- Postgres grants EXECUTE to PUBLIC by default at creation; revoke it so only signed-in clients
-- (not anon) can call these.
revoke execute on function is_session_member(uuid) from public;
revoke execute on function is_session_owner(uuid) from public;
revoke execute on function is_super_admin() from public;
revoke execute on function assign_championship_zone(sessions) from public;
revoke execute on function championship_zone_label(uuid) from public;
grant execute on function is_session_member(uuid) to authenticated;
grant execute on function is_session_owner(uuid) to authenticated;
grant execute on function is_super_admin() to authenticated;
grant execute on function assign_championship_zone(sessions) to authenticated;
grant execute on function championship_zone_label(uuid) to authenticated;
