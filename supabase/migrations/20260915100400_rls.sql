-- Row level security policies (plan 03).
-- Every policy targets "authenticated": the app requires Google sign-in for all table access;
-- only storage objects (plan storage.sql) are readable anonymously.

alter table user_roles enable row level security;
alter table players enable row level security;
alter table holes enable row level security;
alter table sessions enable row level security;
alter table teams enable row level security;
alter table team_players enable row level security;
alter table session_members enable row level security;
alter table played_holes enable row level security;
alter table scores enable row level security;
alter table session_photos enable row level security;

-- Table privileges: RLS only filters rows, it doesn't grant the underlying operation. Supabase's
-- default "grant to anon/authenticated/service_role" only applies to objects created by specific
-- roles (verified: tables created by our migration role got none of it, confirmed by running the
-- app's own queries impersonated as authenticated and hitting "permission denied"). No table
-- grants anything to anon: the app requires sign-in throughout.
grant select on user_roles to authenticated;
grant select, update on players to authenticated;
grant select, insert, update, delete on holes to authenticated;
grant select, insert, update, delete on sessions to authenticated;
grant select, insert, update, delete on teams to authenticated;
grant select, insert, update, delete on team_players to authenticated;
grant select, insert, update, delete on session_members to authenticated;
grant select, insert, update, delete on played_holes to authenticated;
grant select, insert, update, delete on scores to authenticated;
grant select, insert, update, delete on session_photos to authenticated;

-- user_roles: a user reads only their own row (can I see admin-only UI?), never anyone else's.
-- No insert/update/delete policy or grant at all (plan 16): the table is only ever written by
-- direct database access with the service key (bootstrap, or any future promotion) -- no
-- escalation path exists through the app, even from a compromised client.
create policy "user_roles_select_self" on user_roles for select to authenticated
  using (user_id = (select auth.uid()));

-- players: shared read-only directory, write by the linked user only. No client insert/delete
-- (Q24: created by the trigger at sign-up, or by the plan 13 import). This is also the
-- account-facing table (name, avatar, locale) -- no separate "profiles" table, see tables.sql.
create policy "players_select" on players for select to authenticated
  using (true);

create policy "players_update_self" on players for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- holes: public holes, my own holes, or (Q13) holes played in a session I'm a member of.
create policy "holes_select" on holes for select to authenticated
  using (
    visibility = 'public'
    or owner_id = (select auth.uid())
    or exists (
      select 1
      from played_holes ph
      where ph.hole_id = holes.id
        and is_session_member(ph.session_id)
    )
  );

create policy "holes_insert_self" on holes for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "holes_update_owner" on holes for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "holes_delete_owner" on holes for delete to authenticated
  using (owner_id = (select auth.uid()));

-- sessions: read by members, insert by the author, modify/delete by the owner
-- (owner = a session_members row with role 'owner': the creator or a promoted co-organizer).
create policy "sessions_select" on sessions for select to authenticated
  using (is_session_member(id));

create policy "sessions_insert_self" on sessions for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "sessions_update_owner" on sessions for update to authenticated
  using (is_session_owner(id))
  with check (is_session_owner(id));

create policy "sessions_delete_owner" on sessions for delete to authenticated
  using (is_session_owner(id));

-- teams: read by members, write by the owner while the session is still draft (Q15).
create policy "teams_select" on teams for select to authenticated
  using (is_session_member(session_id));

create policy "teams_owner_draft_write" on teams for all to authenticated
  using (
    is_session_owner(session_id)
    and exists (select 1 from sessions s where s.id = session_id and s.status = 'draft')
  )
  with check (
    is_session_owner(session_id)
    and exists (select 1 from sessions s where s.id = session_id and s.status = 'draft')
  );

-- team_players: same rule as teams, scoped through the team's session.
create policy "team_players_select" on team_players for select to authenticated
  using (
    is_session_member((select t.session_id from teams t where t.id = team_id))
  );

create policy "team_players_owner_draft_write" on team_players for all to authenticated
  using (
    exists (
      select 1 from teams t
      where t.id = team_id
        and is_session_owner(t.session_id)
        and exists (select 1 from sessions s where s.id = t.session_id and s.status = 'draft')
    )
  )
  with check (
    exists (
      select 1 from teams t
      where t.id = team_id
        and is_session_owner(t.session_id)
        and exists (select 1 from sessions s where s.id = t.session_id and s.status = 'draft')
    )
  );

-- session_members: read by members. Self-service join is done through join_session (security
-- definer, bypasses RLS). The owner manages membership directly: add a participant while draft
-- (Q26), reassign team_id while draft or promote a co-organizer's role at any time before
-- completion (team_id itself is frozen after draft by the session_members_guard_frozen_teams
-- trigger, regardless of who performs the update), remove a member at any time. A member can
-- leave on their own while the session is still draft.
create policy "session_members_select" on session_members for select to authenticated
  using (is_session_member(session_id));

create policy "session_members_owner_add_draft" on session_members for insert to authenticated
  with check (
    is_session_owner(session_id)
    and exists (select 1 from sessions s where s.id = session_id and s.status = 'draft')
  );

create policy "session_members_owner_update" on session_members for update to authenticated
  using (
    is_session_owner(session_id)
    and exists (select 1 from sessions s where s.id = session_id and s.status <> 'completed')
  )
  with check (
    is_session_owner(session_id)
    and exists (select 1 from sessions s where s.id = session_id and s.status <> 'completed')
  );

create policy "session_members_self_leave_draft" on session_members for delete to authenticated
  using (
    user_id = (select auth.uid())
    and exists (select 1 from sessions s where s.id = session_id and s.status = 'draft')
  );

create policy "session_members_owner_remove" on session_members for delete to authenticated
  using (is_session_owner(session_id));

-- played_holes: read by members, write by the owner (added/removed while the session is live).
create policy "played_holes_select" on played_holes for select to authenticated
  using (is_session_member(session_id));

create policy "played_holes_owner_write" on played_holes for all to authenticated
  using (is_session_owner(session_id))
  with check (is_session_owner(session_id));

-- scores (Q8): read by members. The owner/co-organizer writes any team's score; a member writes
-- only the score of the team they are rattached to (session_members.team_id). A member cannot
-- delete a score directly: removing one goes through the owner deleting the played_hole (cascade),
-- covered by the owner policy below.
create policy "scores_select" on scores for select to authenticated
  using (
    is_session_member((select ph.session_id from played_holes ph where ph.id = played_hole_id))
  );

create policy "scores_owner_write" on scores for all to authenticated
  using (
    is_session_owner((select ph.session_id from played_holes ph where ph.id = played_hole_id))
  )
  with check (
    is_session_owner((select ph.session_id from played_holes ph where ph.id = played_hole_id))
  );

create policy "scores_member_own_team_insert" on scores for insert to authenticated
  with check (
    exists (
      select 1 from played_holes ph
      join session_members sm on sm.session_id = ph.session_id
      where ph.id = played_hole_id
        and sm.user_id = (select auth.uid())
        and sm.team_id = scores.team_id
    )
  );

create policy "scores_member_own_team_update" on scores for update to authenticated
  using (
    exists (
      select 1 from played_holes ph
      join session_members sm on sm.session_id = ph.session_id
      where ph.id = played_hole_id
        and sm.user_id = (select auth.uid())
        and sm.team_id = scores.team_id
    )
  )
  with check (
    exists (
      select 1 from played_holes ph
      join session_members sm on sm.session_id = ph.session_id
      where ph.id = played_hole_id
        and sm.user_id = (select auth.uid())
        and sm.team_id = scores.team_id
    )
  );

-- session_photos: read by members, write by the session owner.
create policy "session_photos_select" on session_photos for select to authenticated
  using (is_session_member(session_id));

create policy "session_photos_owner_write" on session_photos for all to authenticated
  using (is_session_owner(session_id))
  with check (is_session_owner(session_id));
