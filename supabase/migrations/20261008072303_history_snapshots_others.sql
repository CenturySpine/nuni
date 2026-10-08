-- Every completed session of everyone in a super_admin's history (plan 38, Q274): the ones
-- history_snapshots (rpc.sql) leaves out, shown under "Other sessions". Adds one function,
-- changes nothing else, no data touched.

-- The exact complement of history_snapshots among completed sessions: neither the caller's
-- association's (an absent association on either side counts as different) nor one they are a
-- member of. Same shape, so the client reads it with the same LiveSessionSnapshot model and the
-- same tested computeStandings. Empty for anyone but a super_admin: every other account could
-- only read sessions history_snapshots already returns anyway (can_read_session), and the app
-- only calls it for a super_admin. security invoker, like history_snapshots: the read policies
-- apply.
create or replace function history_snapshots_others()
returns jsonb
language sql
security invoker
stable
set search_path = public
as $$
  select coalesce(jsonb_agg(session_snapshot(s.id) order by s.started_at desc nulls last), '[]'::jsonb)
  from sessions s
  where is_super_admin()
    and s.status = 'completed'
    and not is_session_member(s.id)
    and not coalesce(
      s.association_id = (select p.association_id from players p where p.user_id = auth.uid()),
      false
    );
$$;

revoke execute on function history_snapshots_others() from public, anon;
grant execute on function history_snapshots_others() to authenticated;
