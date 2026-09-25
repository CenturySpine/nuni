-- Row level security policies (plan 03).
-- Every policy targets "authenticated": the app requires Google sign-in for all table access;
-- only storage objects (plan storage.sql) are readable anonymously.

alter table user_roles enable row level security;
alter table associations enable row level security;
alter table association_managers enable row level security;
alter table association_manager_contacts enable row level security;
alter table association_admins enable row level security;
alter table spots enable row level security;
alter table players enable row level security;
alter table holes enable row level security;
alter table sessions enable row level security;
alter table teams enable row level security;
alter table team_players enable row level security;
alter table session_members enable row level security;
alter table played_holes enable row level security;
alter table scores enable row level security;
alter table session_photos enable row level security;
alter table events enable row level security;
alter table event_responses enable row level security;
alter table event_comments enable row level security;
-- No policy at all: unreachable from the app (plan 13, Q64), see tables.sql.
alter table legacy_player_emails enable row level security;

-- Table privileges: RLS only filters rows, it doesn't grant the underlying operation. Supabase's
-- default "grant to anon/authenticated/service_role" only applies to objects created by specific
-- roles (verified: tables created by our migration role got none of it, confirmed by running the
-- app's own queries impersonated as authenticated and hitting "permission denied"). No table
-- grants anything to anon: the app requires sign-in throughout.
grant select on user_roles to authenticated;
-- Associations (plan 18): read-only for the app; every write goes through the security-definer
-- RPCs of rpc.sql (request, claim, edit, review), which check who may do what.
grant select on associations to authenticated;
grant select on association_managers to authenticated;
grant select on association_manager_contacts to authenticated;
grant select on association_admins to authenticated;
-- Spots (plan 28): same principle, written only through the spot RPCs of rpc.sql.
grant select on spots to authenticated;
grant select, update on players to authenticated;
grant select, insert, update, delete on holes to authenticated;
grant select, insert, update, delete on sessions to authenticated;
grant select, insert, update, delete on teams to authenticated;
grant select, insert, update, delete on team_players to authenticated;
grant select, insert, update, delete on session_members to authenticated;
grant select, insert, update, delete on played_holes to authenticated;
grant select, insert, update, delete on scores to authenticated;
grant select, insert, update, delete on session_photos to authenticated;
-- Association planning (plan 23): what each may do is decided by the policies below.
grant select, insert, update, delete on events to authenticated;
grant select, insert, update, delete on event_responses to authenticated;
grant select, insert, update, delete on event_comments to authenticated;
-- service_role (bypasses RLS, but not table privileges, same reason as above): only what the
-- LsgScores import script (tool/migrate_lsgscores.dart, plan 13) and the remote-seed export
-- (tool/export_remote_seed.dart) need -- read what's already there, insert what's missing, and
-- set a session's cover photo once its photos exist. Never a delete.
grant select on user_roles to service_role;
grant select on associations to service_role;
grant select on association_managers to service_role;
grant select on association_manager_contacts to service_role;
grant select on association_admins to service_role;
grant select on spots to service_role;
grant select, insert on holes to service_role;
grant select, insert on players to service_role;
grant select, insert on legacy_player_emails to service_role;
grant select, insert, update on sessions to service_role;
grant select, insert on teams to service_role;
grant select, insert on team_players to service_role;
grant select, insert on session_members to service_role;
grant select, insert on played_holes to service_role;
grant select, insert on scores to service_role;
grant select, insert on session_photos to service_role;
-- Read by the remote-seed export only (plan 23).
grant select on events to service_role;
grant select on event_responses to service_role;
grant select on event_comments to service_role;

-- user_roles: a user reads only their own row (can I see admin-only UI?), never anyone else's.
-- No insert/update/delete policy or grant at all (plan 16): the table is only ever written by
-- direct database access with the service key (bootstrap, or any future promotion) -- no
-- escalation path exists through the app, even from a compromised client.
create policy "user_roles_select_self" on user_roles for select to authenticated
  using (user_id = (select auth.uid()));

-- associations (plan 18): approved ones are the public directory; a pending or rejected request
-- is visible only to its requester and to super_admins (who review it).
create policy "associations_select" on associations for select to authenticated
  using (
    status = 'approved'
    or created_by = (select auth.uid())
    or is_super_admin()
  );

-- association_managers: an approved manager is public (the page shows their name); a claim is
-- visible only to its author and to super_admins. Nothing private on this table: contact
-- details and the claim's message are in association_manager_contacts.
create policy "association_managers_select" on association_managers for select to authenticated
  using (
    status = 'approved'
    or user_id = (select auth.uid())
    or is_super_admin()
  );

-- association_admins (plan 27): public, like the approved manager (Q174) -- a name, nothing
-- private. Written only by the add/remove RPCs.
create policy "association_admins_select" on association_admins for select to authenticated
  using (true);

-- association_manager_contacts: never public -- the manager (or claimant) themself and
-- super_admins only.
create policy "association_manager_contacts_select" on association_manager_contacts
  for select to authenticated
  using (
    is_super_admin()
    or exists (
      select 1 from association_managers am
      where am.id = manager_id
        and am.user_id = (select auth.uid())
    )
  );

-- players: shared read-only directory, write by the linked user only. No client insert/delete
-- (Q24: created by the trigger at sign-up, or by the plan 13 import). This is also the
-- account-facing table (name, avatar, locale) -- no separate "profiles" table, see tables.sql.
create policy "players_select" on players for select to authenticated
  using (true);

create policy "players_update_self" on players for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- holes: every hole is public (plan 26, Q110) -- read by everyone, written by its owner only.
create policy "holes_select" on holes for select to authenticated
  using (true);

create policy "holes_insert_self" on holes for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "holes_update_owner" on holes for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "holes_delete_owner" on holes for delete to authenticated
  using (owner_id = (select auth.uid()));

-- sessions: read by members and by every member of the session's association (plan 26,
-- can_read_session), insert by the author, modify/delete by the owner (owner = a session_members
-- row with role 'owner': the creator or a promoted co-organizer). The championship flag is
-- guarded apart (triggers.sql): only a local manager or a super_admin changes it.
create policy "sessions_select" on sessions for select to authenticated
  using (can_read_session(id));

create policy "sessions_insert_self" on sessions for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "sessions_update_owner" on sessions for update to authenticated
  using (is_session_owner(id))
  with check (is_session_owner(id));

create policy "sessions_delete_owner" on sessions for delete to authenticated
  using (is_session_owner(id));

-- teams: read like the session (can_read_session), write by the owner while draft (Q15).
create policy "teams_select" on teams for select to authenticated
  using (can_read_session(session_id));

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
  using (can_read_session(session_id));

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
  using (can_read_session(session_id));

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

-- played_holes: read like the session, write by the owner (added/removed while the session is
-- live; par and comment editable at any time, plan 26, Q121).
create policy "played_holes_select" on played_holes for select to authenticated
  using (can_read_session(session_id));

create policy "played_holes_owner_write" on played_holes for all to authenticated
  using (is_session_owner(session_id))
  with check (is_session_owner(session_id));

-- scores (Q8): read like the session. The owner/co-organizer writes any team's score; a member writes
-- only the score of the team they are rattached to (session_members.team_id). A member cannot
-- delete a score directly: removing one goes through the owner deleting the played_hole (cascade),
-- covered by the owner policy below.
create policy "scores_select" on scores for select to authenticated
  using (can_read_session(session_id));

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

-- session_photos: read like the session, write by the session owner.
create policy "session_photos_select" on session_photos for select to authenticated
  using (can_read_session(session_id));

create policy "session_photos_owner_write" on session_photos for all to authenticated
  using (is_session_owner(session_id))
  with check (is_session_owner(session_id));

-- events (plan 23): the planning of an association is read by its members (and super_admins);
-- any member adds an event to their own association (events_set_defaults, triggers.sql, sets
-- it); its creator, person in charge, local manager or a super_admin edits or deletes it
-- (can_manage_event, Q151 and Q161). Imports go through import_events (rpc.sql).
create policy "events_select" on events for select to authenticated
  using (is_association_member(association_id) or is_super_admin());

create policy "events_insert_member" on events for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and is_association_member(association_id)
  );

create policy "events_update_manager" on events for update to authenticated
  using (can_manage_event(id))
  with check (can_manage_event(id));

create policy "events_delete_manager" on events for delete to authenticated
  using (can_manage_event(id));

-- event_responses (Q157): read by the members of the event's association; each member writes
-- their own answer only. The "until the event starts" rule is a trigger (triggers.sql).
create policy "event_responses_select" on event_responses for select to authenticated
  using (
    exists (
      select 1 from events e
      where e.id = event_id
        and (is_association_member(e.association_id) or is_super_admin())
    )
  );

create policy "event_responses_write_self" on event_responses for all to authenticated
  using (
    exists (select 1 from players p where p.id = player_id and p.user_id = (select auth.uid()))
  )
  with check (
    exists (select 1 from players p where p.id = player_id and p.user_id = (select auth.uid()))
    and exists (
      select 1 from events e
      where e.id = event_id and is_association_member(e.association_id)
    )
  );

-- event_comments (Q166): read and written by the members of the event's association, as
-- themselves; edited by their author only; deleted by their author, the local manager or admins, a
-- super_admin (moderation).
create policy "event_comments_select" on event_comments for select to authenticated
  using (
    exists (
      select 1 from events e
      where e.id = event_id
        and (is_association_member(e.association_id) or is_super_admin())
    )
  );

create policy "event_comments_insert_member" on event_comments for insert to authenticated
  with check (
    exists (
      select 1 from players p where p.id = author_player_id and p.user_id = (select auth.uid())
    )
    and exists (
      select 1 from events e
      where e.id = event_id and is_association_member(e.association_id)
    )
  );

create policy "event_comments_update_author" on event_comments for update to authenticated
  using (
    exists (
      select 1 from players p where p.id = author_player_id and p.user_id = (select auth.uid())
    )
  )
  with check (
    exists (
      select 1 from players p where p.id = author_player_id and p.user_id = (select auth.uid())
    )
  );

create policy "event_comments_delete" on event_comments for delete to authenticated
  using (
    exists (
      select 1 from players p where p.id = author_player_id and p.user_id = (select auth.uid())
    )
    or is_super_admin()
    or exists (
      select 1 from events e
      where e.id = event_id and is_association_staff(e.association_id)
    )
  );

-- spots (plan 28): read by every signed-in account, like the association itself (PO,
-- 2026-09-25: the "Spots" screen is open to anyone, read-only outside the association), as long
-- as the association is approved; its members and super_admins read them in any case. No write
-- policy: the RPCs of rpc.sql decide.
create policy "spots_select" on spots for select to authenticated
  using (
    exists (select 1 from associations a where a.id = association_id and a.status = 'approved')
    or is_association_member(association_id)
    or is_super_admin()
  );
