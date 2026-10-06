-- RLS/RPC smoke test (plan 03, step 5). No local Docker in this project: run manually against
-- the linked remote project with a role that owns the schema (bypasses RLS for the fixture setup
-- and cleanup) --
--   npx supabase db query --linked -f supabase/tests/rls_smoke.sql
-- Creates disposable fixture data (auth.users, a session, a hole), exercises policies and
-- RPCs by impersonating each user via SET ROLE authenticated + request.jwt.claims, records
-- pass/fail into test_results, deletes everything it created, then prints a one-line verdict
-- (the command only shows the last statement's rows, Q250): not_passed must be empty and
-- leftovers 0. The work tables (test_*) are temporary: they go away with the connection.

create temp table test_results (n int generated always as identity, test text, passed boolean);
grant select, insert on test_results to authenticated;

-- ===== Fixture (as the invoking privileged role: bypasses RLS) =====
insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values
  ('a0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'owner@smoke.nuni', '{"full_name":"Smoke Owner"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'member1@smoke.nuni', '{"full_name":"Smoke Member1"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'member2@smoke.nuni', '{"full_name":"Smoke Member2"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'outsider@smoke.nuni', '{"full_name":"Smoke Outsider"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'joiner@smoke.nuni', '{"full_name":"Smoke Joiner"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin@smoke.nuni', '{"full_name":"Smoke Admin"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'fan@smoke.nuni', '{"full_name":"Smoke Fan"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'foreign@smoke.nuni', '{"full_name":"Smoke Foreign"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'manager@smoke.nuni', '{"full_name":"Smoke Manager"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'deputy@smoke.nuni', '{"full_name":"Smoke Deputy"}', now(), now());

-- An approved association for the session owner (plan 18: creating a session requires one); the
-- other fixture users have none. "admin" is a super_admin, to exercise the review RPCs.
insert into associations (id, name, city, location, status)
values ('c0000000-0000-0000-0000-000000000001', 'Smoke Asso', 'Smokeville',
        st_setsrid(st_makepoint(2.35, 48.85), 4326)::geography, 'approved');
update players set association_id = 'c0000000-0000-0000-0000-000000000001'
where user_id = 'a0000000-0000-0000-0000-000000000001';
insert into user_roles (user_id, role) values ('a0000000-0000-0000-0000-000000000006', 'super_admin');
-- Plan 26: "fan" belongs to the session's association without playing in it, "manager" is its
-- local manager from test 7 on (not playing either), "foreign" belongs to another association,
-- "deputy" is a plain member until plan 27 names them local admin.
insert into associations (id, name, city, location, status)
values ('c0000000-0000-0000-0000-000000000002', 'Smoke Other', 'Othertown',
        st_setsrid(st_makepoint(4.0, 45.0), 4326)::geography, 'approved');
update players set association_id = 'c0000000-0000-0000-0000-000000000001'
where user_id in ('a0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000009',
                  'a0000000-0000-0000-0000-000000000010');
update players set association_id = 'c0000000-0000-0000-0000-000000000002'
where user_id = 'a0000000-0000-0000-0000-000000000008';
-- Plan 28: one spot in each association; every new session needs one.
insert into spots (id, association_id, name, city, location)
values
  ('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Smoke Park',
   'Smokeville', st_setsrid(st_makepoint(2.36, 48.86), 4326)::geography),
  ('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'Smoke Other Park',
   'Othertown', st_setsrid(st_makepoint(4.01, 45.01), 4326)::geography);

-- A hole owned by the session owner (every hole is public since plan 26, Q110), par 4 so the
-- played hole's copied par is distinguishable from the free-hole default of 3.
insert into holes (id, owner_id, name, par, start)
values ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Smoke hole', 4,
        st_setsrid(st_makepoint(2.35, 48.85), 4326)::geography);

create temp table test_ids as
select
  'a0000000-0000-0000-0000-000000000001'::uuid as owner_user,
  'a0000000-0000-0000-0000-000000000002'::uuid as member1_user,
  'a0000000-0000-0000-0000-000000000003'::uuid as member2_user,
  'a0000000-0000-0000-0000-000000000004'::uuid as outsider_user,
  'a0000000-0000-0000-0000-000000000005'::uuid as joiner_user,
  'b0000000-0000-0000-0000-000000000001'::uuid as private_hole,
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000002') as member1_player,
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000003') as member2_player,
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000005') as joiner_player;
grant select on test_ids to authenticated;

-- ===== As the owner: create a team session via the real RPC =====
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';

select create_session(jsonb_build_object(
  'kind', 'team',
  'spot_id', 'd0000000-0000-0000-0000-000000000001',
  'scoring_mode', 'stroke_play',
  'ranking_direction', 'asc',
  'teams', jsonb_build_array(
    jsonb_build_object('position', 1, 'player_ids', jsonb_build_array((select member1_player from test_ids))),
    jsonb_build_object('position', 2, 'player_ids', jsonb_build_array((select member2_player from test_ids)))
  )
));

reset role;
reset request.jwt.claims;

alter table test_ids add column session_id uuid, add column team1_id uuid, add column team2_id uuid, add column played_hole_id uuid, add column session_code text;
update test_ids set session_id = (select id from sessions where owner_id = (select owner_user from test_ids));
update test_ids set session_code = (select code from sessions where id = (select session_id from test_ids));
update test_ids set team1_id = (select id from teams where session_id = (select session_id from test_ids) and position = 1);
update test_ids set team2_id = (select id from teams where session_id = (select session_id from test_ids) and position = 2);

insert into played_holes (session_id, hole_id, game_mode, position)
select session_id, private_hole, 'scramble', 1 from test_ids;
update test_ids set played_hole_id = (
  select id from played_holes where session_id = (select session_id from test_ids) and position = 1
);

-- member1 and member2 join by code: join_session finds their player already in team_players
-- (from create_session's payload) and attaches them to the matching team.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
select join_session((select session_code from test_ids));
reset role;
reset request.jwt.claims;

set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000003","role":"authenticated"}';
select join_session((select session_code from test_ids));
reset role;
reset request.jwt.claims;

insert into test_results (test, passed)
select 'join_session_member1_attached_to_team1',
  (select team_id from session_members where session_id = (select session_id from test_ids) and user_id = (select member1_user from test_ids))
    = (select team1_id from test_ids);

-- Joining by the code checks the member in; the creator is checked in from the start
-- (session_members_check_in_self, 2026-09-28).
insert into test_results (test, passed)
select 'join_session_checks_member_in',
  (select checked_in_at is not null from session_members
   where session_id = (select session_id from test_ids) and user_id = (select member1_user from test_ids));
insert into test_results (test, passed)
select 'creator_checked_in',
  (select checked_in_at is not null from session_members
   where session_id = (select session_id from test_ids) and user_id = (select owner_user from test_ids));

-- ===== Test 1: a non-member cannot read the session =====
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000004","role":"authenticated"}';
insert into test_results (test, passed)
select 'outsider_cannot_read_session',
  (select count(*) from sessions where id = (select session_id from test_ids)) = 0;
insert into test_results (test, passed)
select 'everyone_reads_every_hole',
  (select count(*) from holes where id = (select private_hole from test_ids)) = 1;
reset role;
reset request.jwt.claims;

-- ===== Test 2: a member can read the session; the played hole copied the hole's par =====
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
insert into test_results (test, passed)
select 'member_can_read_session',
  (select count(*) from sessions where id = (select session_id from test_ids)) = 1;
insert into test_results (test, passed)
select 'played_hole_par_copied_from_hole',
  (select par from played_holes where id = (select played_hole_id from test_ids)) = 4;
reset role;
reset request.jwt.claims;

-- ===== Test 3: a member writes their own team's score, not the other team's =====
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
with ins as (
  insert into scores (played_hole_id, team_id, value)
  select played_hole_id, team1_id, 4 from test_ids
  returning 1
)
insert into test_results (test, passed)
select 'member_can_insert_own_team_score', count(*) = 1 from ins;

do $probe$
begin
  begin
    insert into scores (played_hole_id, team_id, value)
    select played_hole_id, team2_id, 4 from test_ids;
    insert into test_results (test, passed) values ('member_cannot_insert_other_team_score', false);
  exception when others then
    insert into test_results (test, passed) values ('member_cannot_insert_other_team_score', true);
  end;
end;
$probe$;
reset role;
reset request.jwt.claims;

-- ===== Test 4: the owner can write any team's score (Q8) =====
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
insert into scores (played_hole_id, team_id, value)
select played_hole_id, team2_id, 5 from test_ids
on conflict (played_hole_id, team_id) do update set value = excluded.value;
insert into test_results (test, passed)
select 'owner_can_write_any_team_score',
  (select value from scores where played_hole_id = (select played_hole_id from test_ids) and team_id = (select team2_id from test_ids)) = 5;
reset role;
reset request.jwt.claims;

-- ===== Test 5: join_session attaches the joiner to the team holding their linked player =====
insert into team_players (team_id, player_id)
select team1_id, joiner_player from test_ids;

set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000005","role":"authenticated"}';
select join_session((select session_code from test_ids));
reset role;
reset request.jwt.claims;

insert into test_results (test, passed)
select 'join_session_attaches_correct_team',
  (select team_id from session_members where session_id = (select session_id from test_ids) and user_id = (select joiner_user from test_ids))
    = (select team1_id from test_ids);

-- ===== Test 6: associations (plan 18) =====
insert into test_results (test, passed)
select 'session_takes_owner_association',
  (select association_id from sessions where id = (select session_id from test_ids))
    = 'c0000000-0000-0000-0000-000000000001';

-- A player with no association can't create a session (Q81).
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000004","role":"authenticated"}';
do $$
begin
  perform create_session('{"kind":"individual","scoring_mode":"stroke_play","ranking_direction":"asc","spot_id":"d0000000-0000-0000-0000-000000000001"}');
  insert into test_results (test, passed) values ('no_association_cannot_create_session', false);
exception when others then
  insert into test_results (test, passed)
  values ('no_association_cannot_create_session', sqlerrm = 'association_required');
end $$;

-- The outsider asks for a new association: pending, visible to them, contacts readable by them.
select request_association(jsonb_build_object(
  'name', 'Smoke Pending', 'city', 'Smoketown', 'location', jsonb_build_object('lat', 45.0, 'lng', 4.0),
  'email', 'outsider@smoke.nuni', 'phone', '0600000000', 'message', 'Please'
));
insert into test_results (test, passed)
select 'requester_sees_own_pending_association',
  (select count(*) from associations where name = 'Smoke Pending' and status = 'pending') = 1;
insert into test_results (test, passed)
select 'requester_reads_own_contacts',
  (select count(*) from association_manager_contacts) = 1;

-- Nobody joins a pending association, not even its requester (Q81).
do $$
begin
  update players set association_id = (select id from associations where name = 'Smoke Pending')
  where user_id = 'a0000000-0000-0000-0000-000000000004';
  insert into test_results (test, passed) values ('cannot_join_pending_association', false);
exception when others then
  insert into test_results (test, passed)
  values ('cannot_join_pending_association', sqlerrm = 'association_not_approved');
end $$;

-- No direct write on the association tables: RPCs only.
do $$
begin
  insert into associations (name, city, location, status)
  values ('Sneaky', 'X', st_setsrid(st_makepoint(0, 0), 4326)::geography, 'approved');
  insert into test_results (test, passed) values ('no_direct_association_insert', false);
exception when insufficient_privilege then
  insert into test_results (test, passed) values ('no_direct_association_insert', true);
end $$;
reset role;
reset request.jwt.claims;

-- The session owner claims the local manager role of their association.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
select claim_association_manager(
  'c0000000-0000-0000-0000-000000000001', 'owner@smoke.nuni', '0611111111', 'I run it'
);
-- The session's association is frozen for its owner (Q80): the update is silently reverted.
update sessions set association_id = (select id from associations where name = 'Smoke Pending')
where id = (select session_id from test_ids);
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'session_association_frozen_for_owner',
  (select association_id from sessions where id = (select session_id from test_ids))
    = 'c0000000-0000-0000-0000-000000000001';

-- Another player sees neither the pending request, nor the claim, nor any contact detail, and
-- can't approve or edit anything.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
insert into test_results (test, passed)
select 'other_player_cannot_see_pending_association',
  (select count(*) from associations where name = 'Smoke Pending') = 0;
insert into test_results (test, passed)
select 'other_player_cannot_see_pending_claim',
  (select count(*) from association_managers where association_id = 'c0000000-0000-0000-0000-000000000001') = 0;
insert into test_results (test, passed)
select 'other_player_cannot_read_contacts',
  (select count(*) from association_manager_contacts) = 0;
do $$
begin
  perform review_association((select id from associations where name = 'Smoke Pending' limit 1), true);
  insert into test_results (test, passed) values ('player_cannot_review', false);
exception when others then
  insert into test_results (test, passed) values ('player_cannot_review', sqlerrm = 'not_super_admin');
end $$;
do $$
begin
  perform update_association('c0000000-0000-0000-0000-000000000001', '{"name":"Hijacked"}');
  insert into test_results (test, passed) values ('non_manager_cannot_edit', false);
exception when others then
  insert into test_results (test, passed) values ('non_manager_cannot_edit', sqlerrm = 'not_association_manager');
end $$;
reset role;
reset request.jwt.claims;

-- The super_admin approves both: the requester joins their new association as its manager.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000006","role":"authenticated"}';
insert into test_results (test, passed)
select 'super_admin_reads_all_pending_contacts',
  (select count(*) from association_manager_contacts c
   join association_managers am on am.id = c.manager_id
   where am.user_id in ('a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000004')) = 2;
select review_association((select id from associations where name = 'Smoke Pending'), true);
select review_association_manager(
  (select id from association_managers
   where association_id = 'c0000000-0000-0000-0000-000000000001' and status = 'pending'),
  true
);
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'approval_attaches_requester',
  (select p.association_id from players p where p.user_id = 'a0000000-0000-0000-0000-000000000004')
    = (select id from associations where name = 'Smoke Pending');

-- The approved manager edits their association; others now see the manager, still no contacts.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
select update_association('c0000000-0000-0000-0000-000000000001', '{"short_name":"SMK"}');
reset role;
reset request.jwt.claims;
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
insert into test_results (test, passed)
select 'manager_edit_applied_and_public',
  (select short_name from associations where id = 'c0000000-0000-0000-0000-000000000001') = 'SMK';
insert into test_results (test, passed)
select 'approved_manager_public_contacts_private',
  (select count(*) from association_managers where association_id = 'c0000000-0000-0000-0000-000000000001') = 1
  and (select count(*) from association_manager_contacts) = 0;
reset role;
reset request.jwt.claims;

-- Deleting an association (Q89): super_admin only, never one that has sessions.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
do $$
begin
  perform delete_association((select id from associations where name = 'Smoke Pending'));
  insert into test_results (test, passed) values ('player_cannot_delete_association', false);
exception when others then
  insert into test_results (test, passed)
  values ('player_cannot_delete_association', sqlerrm = 'not_super_admin');
end $$;
reset role;
reset request.jwt.claims;

set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000006","role":"authenticated"}';
do $$
begin
  perform delete_association('c0000000-0000-0000-0000-000000000001');
  insert into test_results (test, passed) values ('association_with_sessions_not_deleted', false);
exception when others then
  insert into test_results (test, passed)
  values ('association_with_sessions_not_deleted', sqlerrm = 'association_has_sessions');
end $$;
select delete_association((select id from associations where name = 'Smoke Pending'));
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'deleted_association_detaches_members',
  (select count(*) from associations where name = 'Smoke Pending') = 0
  and (select association_id from players where user_id = 'a0000000-0000-0000-0000-000000000004') is null;

-- ===== Test 7: association visibility, championship tagging, par and clones (plan 26) =====
-- From here the local manager is "manager", who doesn't play: the owner's approved claim from
-- test 6 is revoked, so the owner is a plain organizer again.
update association_managers set status = 'revoked'
where association_id = 'c0000000-0000-0000-0000-000000000001' and status = 'approved';
insert into association_managers (association_id, user_id, status)
values ('c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000009', 'approved');
-- A draft (waiting room) stays with its participants (plan 26, decision 19)...
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000007","role":"authenticated"}';
insert into test_results (test, passed)
select 'association_member_cannot_read_draft',
  (select count(*) from sessions where id = (select session_id from test_ids)) = 0;
reset role;
reset request.jwt.claims;
-- ...until it starts.
update sessions set status = 'live', started_at = now() where id = (select session_id from test_ids);
-- A member of the session's association who didn't play reads it, cannot score.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000007","role":"authenticated"}';
insert into test_results (test, passed)
select 'association_member_reads_session',
  (select count(*) from sessions where id = (select session_id from test_ids)) = 1
  and (select count(*) from played_holes where session_id = (select session_id from test_ids)) = 1
  and (select count(*) from scores where session_id = (select session_id from test_ids)) >= 1
  and (select count(*) from teams where session_id = (select session_id from test_ids)) = 2;
do $probe$
begin
  begin
    update scores set value = 1 where session_id = (select session_id from test_ids);
    insert into test_results (test, passed)
    select 'association_member_cannot_score',
      not exists (select 1 from scores where session_id = (select session_id from test_ids) and value = 1);
  exception when others then
    insert into test_results (test, passed) values ('association_member_cannot_score', true);
  end;
end;
$probe$;
reset role;
reset request.jwt.claims;

-- A member of another association who didn't play doesn't see it.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'other_association_cannot_read_session',
  (select count(*) from sessions where id = (select session_id from test_ids)) = 0
  and (select count(*) from played_holes where session_id = (select session_id from test_ids)) = 0;
reset role;
reset request.jwt.claims;

-- The super_admin keeps a fallback read right (Q130).
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000006","role":"authenticated"}';
insert into test_results (test, passed)
select 'super_admin_reads_any_session',
  (select count(*) from sessions where id = (select session_id from test_ids)) = 1;
reset role;
reset request.jwt.claims;

-- The organizer can no longer tag the championship, neither directly nor through the RPC.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
update sessions set is_championship = true where id = (select session_id from test_ids);
insert into test_results (test, passed)
select 'organizer_update_keeps_championship_flag',
  not (select is_championship from sessions where id = (select session_id from test_ids));
do $$
begin
  perform set_session_championship((select session_id from test_ids), true);
  insert into test_results (test, passed) values ('organizer_cannot_tag_championship', false);
exception when others then
  insert into test_results (test, passed)
  values ('organizer_cannot_tag_championship', sqlerrm = 'not_championship_manager');
end $$;

-- A free hole needs a par from the app; a directory hole takes an explicit par and a comment.
do $$
begin
  perform add_played_hole((select session_id from test_ids), null, 'individual');
  insert into test_results (test, passed) values ('free_hole_without_par_refused', false);
exception when others then
  insert into test_results (test, passed)
  values ('free_hole_without_par_refused', sqlerrm = 'par_required');
end $$;
select add_played_hole((select session_id from test_ids), (select private_hole from test_ids),
  'individual', null, 6, '  from the bench  ');
insert into test_results (test, passed)
select 'played_hole_par_and_comment_set',
  exists (
    select 1 from played_holes
    where session_id = (select session_id from test_ids) and position = 2
      and par = 6 and comment = 'from the bench'
  );
select add_played_hole((select session_id from test_ids), null, 'individual', 'Test', 5);
insert into test_results (test, passed)
select 'free_hole_with_par_added',
  exists (
    select 1 from played_holes
    where session_id = (select session_id from test_ids) and position = 3
      and hole_id is null and par = 5
  );
reset role;
reset request.jwt.claims;

-- The local manager tags it without playing; the organizer's later updates keep the flag.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
select set_session_championship((select session_id from test_ids), true);
reset role;
reset request.jwt.claims;
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
update sessions set comment = 'x', is_championship = false where id = (select session_id from test_ids);
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'manager_tags_championship',
  (select is_championship from sessions where id = (select session_id from test_ids));

-- Anyone clones any hole and owns the clone; only the owner edits the original.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
select clone_hole((select private_hole from test_ids));
insert into test_results (test, passed)
select 'clone_owned_by_caller',
  exists (
    select 1 from holes
    where cloned_from = (select private_hole from test_ids)
      and owner_id = (select member1_user from test_ids)
      and name = 'Clone - Smoke hole' and par = 4
  );
update holes set name = 'Hijacked' where id = (select private_hole from test_ids);
insert into test_results (test, passed)
select 'non_owner_cannot_edit_hole',
  (select name from holes where id = (select private_hole from test_ids)) = 'Smoke hole';
reset role;
reset request.jwt.claims;

-- Once completed, the session is in the history of its association's members only (Q129).
update sessions set status = 'completed', ended_at = now() where id = (select session_id from test_ids);
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000007","role":"authenticated"}';
insert into test_results (test, passed)
select 'history_lists_association_sessions', jsonb_array_length(history_snapshots()) = 1;
reset role;
reset request.jwt.claims;
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'history_hides_other_association_sessions', jsonb_array_length(history_snapshots()) = 0;
reset role;
reset request.jwt.claims;

-- ===== Plan 19: a player's history, readable by everyone (Q133) =====
-- member1 hides their statistics: a display choice only, the history stays readable.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
update players set stats_public = false where user_id = (select member1_user from test_ids);
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'player_can_hide_own_stats',
  (select not stats_public from players where id = (select member1_player from test_ids));
-- "foreign" (another association) reads member1's history: the completed session, without the
-- members' accounts or the session comment.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'player_history_readable_by_anyone',
  jsonb_array_length(player_history((select member1_player from test_ids))) = 1
  and jsonb_array_length(player_history((select member1_player from test_ids))->0->'members') = 0
  and not (player_history((select member1_player from test_ids))->0->'session' ? 'comment');
-- ...but cannot change member1's switches.
update players set stats_public = true, badges_public = false
where id = (select member1_player from test_ids);
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'player_cannot_change_others_switches',
  (select not stats_public and badges_public from players where id = (select member1_player from test_ids));
-- A player with no completed session has an empty history.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'player_history_empty_without_sessions',
  jsonb_array_length(player_history((select id from players where user_id = 'a0000000-0000-0000-0000-000000000008'))) = 0;
reset role;
reset request.jwt.claims;

-- ===== Plan 20: a hole's history, common to every association (Q95) =====
-- "foreign" (another association) reads the session the hole was played in, stripped like
-- player_history (no session or played-hole comment, no members).
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'holes_history_readable_by_anyone',
  jsonb_array_length(holes_history(array[(select private_hole from test_ids)])) = 1
  and jsonb_array_length(holes_history(array[(select private_hole from test_ids)])->0->'members') = 0
  and not (holes_history(array[(select private_hole from test_ids)])->0->'session' ? 'comment')
  and not exists (
    select 1 from jsonb_array_elements(holes_history(array[(select private_hole from test_ids)])->0->'played_holes') ph
    where ph ? 'comment'
  );
-- A clone has its own statistics (Q135): never played, empty history.
insert into test_results (test, passed)
select 'holes_history_empty_for_unplayed_clone',
  jsonb_array_length(holes_history(array[(select id from holes where cloned_from = (select private_hole from test_ids) limit 1)])) = 0;
-- Several holes in one call, each session once (plan 21).
insert into test_results (test, passed)
select 'holes_history_each_session_once',
  jsonb_array_length(holes_history(array[
    (select private_hole from test_ids),
    (select id from holes where cloned_from = (select private_hole from test_ids) limit 1)
  ])) = 1;
reset role;
reset request.jwt.claims;

-- ===== Plan 21: a player's contributions (builder badges, family H), readable by anyone =====
-- The owner created the hole and the completed session without playing in it.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'player_contributions_readable_by_anyone',
  (select c->'holes'->0->>'id' = (select private_hole from test_ids)::text
      and not (c->'holes'->0->>'cloned')::boolean
      and jsonb_array_length(c->'sessions') = 1
      and jsonb_array_length(c->'sessions'->0->'members') = 0
      and jsonb_array_length(c->'photos') = 0
   from (select player_contributions((select id from players where user_id = (select owner_user from test_ids))) c) x);
-- member1's clone is marked as such (Q120); member1 created no session.
insert into test_results (test, passed)
select 'player_contributions_clone_marked',
  (select jsonb_array_length(c->'holes') = 1
      and (c->'holes'->0->>'cloned')::boolean
      and jsonb_array_length(c->'sessions') = 0
   from (select player_contributions((select member1_player from test_ids)) c) x);
reset role;
reset request.jwt.claims;
-- The shared stripping helper is not callable by the app.
insert into test_results (test, passed)
select 'stats_snapshot_not_callable',
  not has_function_privilege('authenticated', 'stats_snapshot(uuid)', 'execute')
  and not has_function_privilege('anon', 'stats_snapshot(uuid)', 'execute');

-- ===== Plan 23: association planning (events, answers, comments, import, start a session) =====
-- Association 1: owner (1), fan (7), manager (9, local manager since test 7); "foreign" (8) is in
-- association 2; "admin" (6) is a super_admin.
create temp table test_events (name text primary key, id uuid);
grant select, insert on test_events to authenticated;

-- A member creates an event: the base sets its association, creator and origin, whatever is sent.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000007","role":"authenticated"}';
insert into events (association_id, created_by, starts_at, label, origin)
values ('c0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001',
        now() + interval '2 days', 'Smoke event', 'imported');
insert into test_events select 'future', id from events where label = 'Smoke event';
insert into test_results (test, passed)
select 'member_creates_event_in_own_association',
  (select association_id = 'c0000000-0000-0000-0000-000000000001'
      and created_by = 'a0000000-0000-0000-0000-000000000007'
      and origin = 'manual'
   from events where id = (select id from test_events where name = 'future'));
-- An event without a label is refused.
do $$
begin
  insert into events (starts_at, label) values (now() + interval '1 day', ' ');
  insert into test_results (test, passed) values ('event_without_label_refused', false);
exception when others then
  insert into test_results (test, passed) values ('event_without_label_refused', true);
end $$;
-- The member answers for themself, and comments.
insert into event_responses (event_id, player_id, response)
select (select id from test_events where name = 'future'),
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000007'), 'yes';
insert into event_comments (event_id, author_player_id, body)
select (select id from test_events where name = 'future'),
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000007'),
  'See https://example.org';
reset role;
reset request.jwt.claims;

-- A member of another association sees nothing of it and cannot answer.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'other_association_cannot_read_event',
  (select count(*) from events where id = (select id from test_events where name = 'future')) = 0
  and (select count(*) from event_responses where event_id = (select id from test_events where name = 'future')) = 0
  and (select count(*) from event_comments where event_id = (select id from test_events where name = 'future')) = 0;
do $$
begin
  insert into event_responses (event_id, player_id, response)
  select (select id from test_events where name = 'future'),
    (select id from players where user_id = 'a0000000-0000-0000-0000-000000000008'), 'yes';
  insert into test_results (test, passed) values ('other_association_cannot_answer', false);
exception when others then
  insert into test_results (test, passed) values ('other_association_cannot_answer', true);
end $$;
reset role;
reset request.jwt.claims;

-- Another member reads it all, cannot answer for someone else, nor edit the event or the comment.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
insert into test_results (test, passed)
select 'member_reads_event_answers_comments',
  (select count(*) from events where id = (select id from test_events where name = 'future')) = 1
  and (select count(*) from event_responses where event_id = (select id from test_events where name = 'future')) = 1
  and (select count(*) from event_comments where event_id = (select id from test_events where name = 'future')) = 1;
do $$
begin
  insert into event_responses (event_id, player_id, response)
  select (select id from test_events where name = 'future'),
    (select id from players where user_id = 'a0000000-0000-0000-0000-000000000009'), 'no';
  insert into test_results (test, passed) values ('member_cannot_answer_for_another', false);
exception when others then
  insert into test_results (test, passed) values ('member_cannot_answer_for_another', true);
end $$;
update events set label = 'Hacked' where id = (select id from test_events where name = 'future');
update event_comments set body = 'Hacked' where event_id = (select id from test_events where name = 'future');
insert into test_results (test, passed)
select 'member_cannot_edit_others_event_or_comment',
  (select label from events where id = (select id from test_events where name = 'future')) = 'Smoke event'
  and (select body from event_comments where event_id = (select id from test_events where name = 'future')) <> 'Hacked';
-- ...and cannot import.
do $$
begin
  perform import_events('[]'::jsonb);
  insert into test_results (test, passed) values ('member_cannot_import', false);
exception when others then
  insert into test_results (test, passed) values ('member_cannot_import', sqlerrm = 'not_association_manager');
end $$;
reset role;
reset request.jwt.claims;

-- The author edits their comment, which is marked edited.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000007","role":"authenticated"}';
update event_comments set body = 'See you there'
where event_id = (select id from test_events where name = 'future');
insert into test_results (test, passed)
select 'author_edits_comment',
  (select body = 'See you there' and edited_at is not null
   from event_comments where event_id = (select id from test_events where name = 'future'));
-- An event already started still takes answers (PO, 2026-09-29).
insert into events (starts_at, label) values (now() - interval '1 hour', 'Smoke past');
insert into test_events select 'past', id from events where label = 'Smoke past';
insert into event_responses (event_id, player_id, response)
select (select id from test_events where name = 'past'),
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000007'), 'yes';
insert into test_results (test, passed)
select 'answer_after_start', exists (
  select 1 from event_responses where event_id = (select id from test_events where name = 'past'));
-- An event happening today, "fan" in charge, to start a session from.
insert into events (starts_at, label, manager_player_id)
select now() + interval '1 hour', 'Smoke today', id
from players where user_id = 'a0000000-0000-0000-0000-000000000007';
insert into test_events select 'today', id from events where label = 'Smoke today';
insert into event_responses (event_id, player_id, response)
select (select id from test_events where name = 'today'), id, 'yes'
from players where user_id = 'a0000000-0000-0000-0000-000000000007';
reset role;
reset request.jwt.claims;

-- The local manager edits the event, deletes the comment (moderation) and imports twice: the
-- second import replaces the first one's events, never the members' own.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
update events set label = 'Smoke event renamed' where id = (select id from test_events where name = 'future');
delete from event_comments where event_id = (select id from test_events where name = 'future');
insert into test_results (test, passed)
select 'local_manager_edits_event_and_moderates',
  (select label from events where id = (select id from test_events where name = 'future')) = 'Smoke event renamed'
  and (select count(*) from event_comments where event_id = (select id from test_events where name = 'future')) = 0;
insert into test_results (test, passed)
select 'first_import_creates',
  import_events(jsonb_build_array(
    jsonb_build_object('label', 'Imported A', 'starts_at', now() + interval '3 days', 'spot', 'Park',
                       'location', jsonb_build_object('lat', 45.7, 'lng', 4.8)),
    jsonb_build_object('label', 'Imported B', 'starts_at', now() + interval '4 days')
  )) = '{"deleted": 0, "created": 2}'::jsonb;
insert into test_results (test, passed)
select 'import_preview_counts_imported_future_events',
  (import_events_preview() ->> 'events')::int = 2;
insert into test_results (test, passed)
select 'reimport_replaces_imported_only',
  import_events(jsonb_build_array(
    jsonb_build_object('label', 'Imported C', 'starts_at', now() + interval '5 days')
  )) = '{"deleted": 2, "created": 1}'::jsonb
  and (select count(*) from events
       where association_id = 'c0000000-0000-0000-0000-000000000001' and origin = 'manual') = 3;
reset role;
reset request.jwt.claims;

-- An import always targets the importer's own association (PO, 2026-09-25): a super_admin who
-- belongs to none cannot import anywhere.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000006","role":"authenticated"}';
do $$
begin
  perform import_events('[]'::jsonb);
  insert into test_results (test, passed) values ('import_only_into_own_association', false);
exception when others then
  insert into test_results (test, passed)
  values ('import_only_into_own_association', sqlerrm = 'association_required');
end $$;
reset role;
reset request.jwt.claims;

-- Starting a session from today's event: refused to a plain member, done by its person in
-- charge, with the members who answered "present" already in the waiting room.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
insert into event_responses (event_id, player_id, response)
select (select id from test_events where name = 'today'), id, 'yes'
from players where user_id = 'a0000000-0000-0000-0000-000000000001';
do $$
begin
  perform create_session(jsonb_build_object('kind', 'individual', 'scoring_mode', 'stroke_play',
    'ranking_direction', 'asc', 'spot_id', 'd0000000-0000-0000-0000-000000000001',
    'event_id', (select id from test_events where name = 'today')));
  insert into test_results (test, passed) values ('member_cannot_start_session_from_event', false);
exception when others then
  insert into test_results (test, passed)
  values ('member_cannot_start_session_from_event', sqlerrm = 'event_not_startable');
end $$;
reset role;
reset request.jwt.claims;
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000007","role":"authenticated"}';
select create_session(jsonb_build_object('kind', 'individual', 'scoring_mode', 'stroke_play',
  'ranking_direction', 'asc', 'spot_id', 'd0000000-0000-0000-0000-000000000001',
    'event_id', (select id from test_events where name = 'today')));
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'person_in_charge_starts_session_from_event',
  (select count(*) from sessions where event_id = (select id from test_events where name = 'today')) = 1
  and exists (
    select 1 from session_members sm
    join sessions s on s.id = sm.session_id
    where s.event_id = (select id from test_events where name = 'today')
      and sm.user_id = 'a0000000-0000-0000-0000-000000000001'
  );
-- One session per event (PO, 2026-09-29): its person in charge can't start a second one; the
-- event tells its members whether they're in it, and tells a foreigner nothing.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000007","role":"authenticated"}';
do $$
begin
  perform create_session(jsonb_build_object('kind', 'individual', 'scoring_mode', 'stroke_play',
    'ranking_direction', 'asc', 'spot_id', 'd0000000-0000-0000-0000-000000000001',
    'event_id', (select id from test_events where name = 'today')));
  insert into test_results (test, passed) values ('one_session_per_event', false);
exception when others then
  insert into test_results (test, passed) values ('one_session_per_event', sqlerrm = 'event_has_session');
end $$;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
insert into test_results (test, passed)
select 'event_session_member',
  (select is_member and status = 'draft'
   from event_session((select id from test_events where name = 'today')));
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000010","role":"authenticated"}';
insert into test_results (test, passed)
select 'event_session_other_member',
  (select not is_member from event_session((select id from test_events where name = 'today')));
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'event_session_not_for_foreigner',
  not exists (select 1 from event_session((select id from test_events where name = 'today')));
reset role;
reset request.jwt.claims;

-- ===== Plan 27: local admins and partners =====
-- Association 1: manager (9) names deputy (10); owner (1) is a plain member, fan (7) a second
-- admin who renounces; foreign (8) belongs to association 2.
create temp table test_plan27 as
select
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000010') as deputy_player,
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000007') as fan_player,
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000008') as foreign_player,
  (select id from players where user_id = 'a0000000-0000-0000-0000-000000000009') as manager_player;
grant select on test_plan27 to authenticated;

-- A plain member names nobody.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
do $$
begin
  perform add_association_admin('c0000000-0000-0000-0000-000000000001', (select deputy_player from test_plan27));
  insert into test_results (test, passed) values ('member_cannot_name_admin', false);
exception when others then
  insert into test_results (test, passed) values ('member_cannot_name_admin', sqlerrm = 'not_association_manager');
end $$;
reset role;
reset request.jwt.claims;

-- The manager names two members; neither a member of another association nor themself.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
select add_association_admin('c0000000-0000-0000-0000-000000000001', (select deputy_player from test_plan27));
select add_association_admin('c0000000-0000-0000-0000-000000000001', (select fan_player from test_plan27));
insert into test_results (test, passed)
select 'manager_names_admins',
  (select count(*) from association_admins where association_id = 'c0000000-0000-0000-0000-000000000001') = 2;
do $$
begin
  perform add_association_admin('c0000000-0000-0000-0000-000000000001', (select foreign_player from test_plan27));
  insert into test_results (test, passed) values ('admin_must_be_member', false);
exception when others then
  insert into test_results (test, passed) values ('admin_must_be_member', sqlerrm = 'player_not_member');
end $$;
do $$
begin
  perform add_association_admin('c0000000-0000-0000-0000-000000000001', (select manager_player from test_plan27));
  insert into test_results (test, passed) values ('manager_cannot_be_admin', false);
exception when others then
  insert into test_results (test, passed) values ('manager_cannot_be_admin', sqlerrm = 'player_is_manager');
end $$;
-- Partners: kept in order, trimmed, the link optional; an empty label is refused.
select update_association('c0000000-0000-0000-0000-000000000001', jsonb_build_object('partners',
  jsonb_build_array(
    jsonb_build_object('label', ' Bakery ', 'url', 'bakery.example'),
    jsonb_build_object('label', 'Town hall', 'url', '  ')
  )));
insert into test_results (test, passed)
select 'manager_sets_partners',
  (select partners from associations where id = 'c0000000-0000-0000-0000-000000000001')
    = '[{"label": "Bakery", "url": "bakery.example"}, {"label": "Town hall"}]'::jsonb;
do $$
begin
  perform update_association('c0000000-0000-0000-0000-000000000001', jsonb_build_object('partners',
    jsonb_build_array(jsonb_build_object('label', ' ', 'url', 'x.example'))));
  insert into test_results (test, passed) values ('partner_without_label_refused', false);
exception when others then
  insert into test_results (test, passed) values ('partner_without_label_refused', sqlerrm = 'invalid_partners');
end $$;
do $$
begin
  perform update_association('c0000000-0000-0000-0000-000000000001', jsonb_build_object('partners',
    (select jsonb_agg(jsonb_build_object('label', 'P' || i)) from generate_series(1, 21) i)));
  insert into test_results (test, passed) values ('more_than_20_partners_refused', false);
exception when others then
  insert into test_results (test, passed) values ('more_than_20_partners_refused', true);
end $$;
reset role;
reset request.jwt.claims;

-- Everyone reads the admins and the partners, even from another association.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'admins_and_partners_public',
  (select count(*) from association_admins where association_id = 'c0000000-0000-0000-0000-000000000001') = 2
  and (select jsonb_array_length(partners) from associations where id = 'c0000000-0000-0000-0000-000000000001') = 2;
reset role;
reset request.jwt.claims;

-- A plain member removes nobody; an admin renounces on their own.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
do $$
begin
  perform remove_association_admin('c0000000-0000-0000-0000-000000000001', (select deputy_player from test_plan27));
  insert into test_results (test, passed) values ('member_cannot_remove_admin', false);
exception when others then
  insert into test_results (test, passed) values ('member_cannot_remove_admin', sqlerrm = 'not_association_manager');
end $$;
reset role;
reset request.jwt.claims;
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000007","role":"authenticated"}';
select remove_association_admin('c0000000-0000-0000-0000-000000000001', (select fan_player from test_plan27));
insert into test_results (test, passed)
select 'admin_renounces',
  not exists (select 1 from association_admins where player_id = (select fan_player from test_plan27));
reset role;
reset request.jwt.claims;

-- The admin has the manager's day-to-day rights: championship, any event, moderation, import,
-- "start the session" (the event's first session deleted: it may then be started again)...
delete from sessions where event_id = (select id from test_events where name = 'today');
insert into event_comments (event_id, author_player_id, body)
values ((select id from test_events where name = 'future'), (select fan_player from test_plan27), 'Fan comment');
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000010","role":"authenticated"}';
select set_session_championship((select session_id from test_ids), false);
update events set label = 'Smoke event by deputy' where id = (select id from test_events where name = 'future');
delete from event_comments where event_id = (select id from test_events where name = 'future');
insert into test_results (test, passed)
select 'admin_tags_championship_edits_event_and_moderates',
  not (select is_championship from sessions where id = (select session_id from test_ids))
  and (select label from events where id = (select id from test_events where name = 'future')) = 'Smoke event by deputy'
  and (select count(*) from event_comments where event_id = (select id from test_events where name = 'future')) = 0;
insert into test_results (test, passed)
select 'admin_imports', (import_events_preview() ->> 'events')::int = 1;
select create_session(jsonb_build_object('kind', 'individual', 'scoring_mode', 'stroke_play',
  'ranking_direction', 'asc', 'spot_id', 'd0000000-0000-0000-0000-000000000001',
    'event_id', (select id from test_events where name = 'today')));
insert into test_results (test, passed)
select 'admin_starts_session_from_event',
  exists (
    select 1 from sessions
    where event_id = (select id from test_events where name = 'today')
      and owner_id = 'a0000000-0000-0000-0000-000000000010'
  );
-- ...but neither edits the association (nor its logo) nor names anyone.
do $$
begin
  perform update_association('c0000000-0000-0000-0000-000000000001', '{"name": "Hacked"}'::jsonb);
  insert into test_results (test, passed) values ('admin_cannot_edit_association', false);
exception when others then
  insert into test_results (test, passed) values ('admin_cannot_edit_association', sqlerrm = 'not_association_manager');
end $$;
do $$
begin
  insert into storage.objects (bucket_id, name)
  values ('association-logos', 'c0000000-0000-0000-0000-000000000001/deputy.jpg');
  insert into test_results (test, passed) values ('admin_cannot_upload_logo', false);
exception when others then
  insert into test_results (test, passed) values ('admin_cannot_upload_logo', true);
end $$;
do $$
begin
  perform add_association_admin('c0000000-0000-0000-0000-000000000001', (select fan_player from test_plan27));
  insert into test_results (test, passed) values ('admin_cannot_name_admin', false);
exception when others then
  insert into test_results (test, passed) values ('admin_cannot_name_admin', sqlerrm = 'not_association_manager');
end $$;
-- Leaving the association ends the role (Q171), and the rights with it.
update players set association_id = null where user_id = 'a0000000-0000-0000-0000-000000000010';
insert into test_results (test, passed)
select 'leaving_association_drops_admin',
  not exists (select 1 from association_admins where player_id = (select deputy_player from test_plan27))
  and not is_association_staff('c0000000-0000-0000-0000-000000000001');
reset role;
reset request.jwt.claims;
drop table test_plan27;

-- ===== Plan 28: spots =====
-- Owner (1) is a plain member of association 1, manager (9) its local manager, foreign (8) belongs
-- to association 2: they read association 1's spots too, but write none.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000008","role":"authenticated"}';
insert into test_results (test, passed)
select 'spots_read_by_everyone',
  exists (select 1 from spots where association_id = 'c0000000-0000-0000-0000-000000000001')
  and exists (select 1 from spots where association_id = 'c0000000-0000-0000-0000-000000000002');
do $$
begin
  perform create_spot('c0000000-0000-0000-0000-000000000001',
    '{"name": "Intruder", "location": {"lat": 48.8, "lng": 2.3}}'::jsonb);
  insert into test_results (test, passed) values ('outsider_cannot_create_spot', false);
exception when others then
  insert into test_results (test, passed) values ('outsider_cannot_create_spot', sqlerrm = 'not_association_member');
end $$;
reset role;
reset request.jwt.claims;

set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
-- The "+" of the session form: a name and a point; a member's description is dropped (Q180).
select create_spot('c0000000-0000-0000-0000-000000000001',
  '{"name": " Quick spot ", "description": "ignored", "location": {"lat": 48.87, "lng": 2.37}}'::jsonb);
insert into test_results (test, passed)
select 'member_quick_creates_spot',
  exists (
    select 1 from spots
    where association_id = 'c0000000-0000-0000-0000-000000000001'
      and name = 'Quick spot' and description is null and location_lat is not null
      and created_by = 'a0000000-0000-0000-0000-000000000001'
  );
do $$
begin
  perform create_spot('c0000000-0000-0000-0000-000000000001',
    '{"name": "quick SPOT", "location": {"lat": 48.8, "lng": 2.3}}'::jsonb);
  insert into test_results (test, passed) values ('spot_name_unique_ignoring_case', false);
exception when others then
  insert into test_results (test, passed) values ('spot_name_unique_ignoring_case', sqlerrm = 'spot_name_taken');
end $$;
do $$
begin
  perform create_spot('c0000000-0000-0000-0000-000000000001', '{"name": "Nowhere"}'::jsonb);
  insert into test_results (test, passed) values ('spot_requires_point', false);
exception when others then
  insert into test_results (test, passed) values ('spot_requires_point', sqlerrm = 'spot_location_required');
end $$;
do $$
begin
  perform update_spot('d0000000-0000-0000-0000-000000000001', '{"name": "Hacked"}'::jsonb);
  insert into test_results (test, passed) values ('member_cannot_edit_spot', false);
exception when others then
  insert into test_results (test, passed) values ('member_cannot_edit_spot', sqlerrm = 'not_association_manager');
end $$;
do $$
begin
  perform delete_spot('d0000000-0000-0000-0000-000000000001');
  insert into test_results (test, passed) values ('member_cannot_delete_spot', false);
exception when others then
  insert into test_results (test, passed) values ('member_cannot_delete_spot', sqlerrm = 'not_association_manager');
end $$;
-- A session needs a spot of its own association, whose name and city it copies (Q184).
do $$
begin
  perform create_session('{"kind":"individual","scoring_mode":"stroke_play","ranking_direction":"asc"}');
  insert into test_results (test, passed) values ('session_requires_spot', false);
exception when others then
  insert into test_results (test, passed) values ('session_requires_spot', sqlerrm = 'spot_required');
end $$;
do $$
begin
  perform create_session('{"kind":"individual","scoring_mode":"stroke_play","ranking_direction":"asc","spot_id":"d0000000-0000-0000-0000-000000000002"}');
  insert into test_results (test, passed) values ('session_spot_of_own_association', false);
exception when others then
  insert into test_results (test, passed) values ('session_spot_of_own_association', sqlerrm = 'spot_not_in_association');
end $$;
select create_session(jsonb_build_object('kind', 'individual', 'scoring_mode', 'stroke_play',
  'ranking_direction', 'asc', 'spot_id', 'd0000000-0000-0000-0000-000000000001', 'comment', 'plan28'));
insert into test_results (test, passed)
select 'session_copies_spot',
  exists (
    select 1 from sessions
    where comment = 'plan28' and spot_id = 'd0000000-0000-0000-0000-000000000001'
      and zone = 'Smoke Park' and city = 'Smokeville' and location_lat is not null
  );
-- An event may be linked to a spot (its name and point copied) or keep a free place.
insert into events (starts_at, label, spot_id)
values (now() + interval '10 days', 'Plan 28 linked', 'd0000000-0000-0000-0000-000000000001');
insert into events (starts_at, label, spot)
values (now() + interval '11 days', 'Plan 28 free', 'Christmas restaurant');
insert into test_results (test, passed)
select 'event_spot_linked_or_free',
  exists (
    select 1 from events
    where label = 'Plan 28 linked' and spot = 'Smoke Park' and location_lat is not null
  )
  and exists (
    select 1 from events where label = 'Plan 28 free' and spot = 'Christmas restaurant' and spot_id is null
  );
reset role;
reset request.jwt.claims;

-- The manager renames the spot: sessions and events follow; deletes it: they keep the name (Q182).
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
select update_spot('d0000000-0000-0000-0000-000000000001',
  '{"name": "Smoke Garden", "description": "By the fountain", "city": "Smokecity"}'::jsonb);
-- Checked as the privileged role: the session is a draft, which only its participants read
-- (plan 26), not the manager who renamed the spot.
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'rename_spot_propagates',
  (select zone || '|' || city from sessions where comment = 'plan28') = 'Smoke Garden|Smokecity'
  and (select spot from events where label = 'Plan 28 linked') = 'Smoke Garden'
  and (select description from spots where id = 'd0000000-0000-0000-0000-000000000001') = 'By the fountain';
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
do $$
begin
  perform update_spot('d0000000-0000-0000-0000-000000000001', '{"location": null}'::jsonb);
  insert into test_results (test, passed) values ('spot_point_cannot_be_removed', false);
exception when others then
  insert into test_results (test, passed) values ('spot_point_cannot_be_removed', sqlerrm = 'spot_location_required');
end $$;
select delete_spot('d0000000-0000-0000-0000-000000000001');
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'delete_spot_keeps_names',
  (select spot_id is null and zone = 'Smoke Garden' from sessions where comment = 'plan28')
  and (select spot_id is null and spot = 'Smoke Garden' from events where label = 'Plan 28 linked');
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
-- A spot with a variable location (Q186): no point, each event and session keeps its own.
select create_spot('c0000000-0000-0000-0000-000000000001', jsonb_build_object(
  'name', 'Surprise', 'variable_location', true, 'location', jsonb_build_object('lat', 1, 'lng', 1)));
insert into events (starts_at, label, spot_id, location)
select now() + interval '13 days', 'Plan 28 surprise', id,
  st_setsrid(st_makepoint(2.30, 48.80), 4326)::geography
from spots where name = 'Surprise' and association_id = 'c0000000-0000-0000-0000-000000000001';
insert into test_results (test, passed)
select 'variable_spot_keeps_event_point',
  (select location_lat is null and variable_location from spots where name = 'Surprise' and association_id = 'c0000000-0000-0000-0000-000000000001')
  and (select round(location_lat::numeric, 2) from events where label = 'Plan 28 surprise') = 48.80;
reset role;
reset request.jwt.claims;
-- A plain member can't make a spot variable: theirs keeps its point.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
select create_session(jsonb_build_object('kind', 'individual', 'scoring_mode', 'stroke_play',
  'ranking_direction', 'asc', 'spot_id', (select id from spots where name = 'Surprise' and association_id = 'c0000000-0000-0000-0000-000000000001'),
  'city', 'Smoketown', 'location', jsonb_build_object('lat', 48.81, 'lng', 2.31),
  'comment', 'plan28 surprise'));
insert into test_results (test, passed)
select 'variable_spot_session_keeps_its_point_and_city',
  exists (
    select 1 from sessions
    where comment = 'plan28 surprise' and zone = 'Surprise' and city = 'Smoketown'
      and round(location_lat::numeric, 2) = 48.81
  );
do $$
begin
  perform create_spot('c0000000-0000-0000-0000-000000000001',
    '{"name": "Member variable", "variable_location": true}'::jsonb);
  insert into test_results (test, passed) values ('member_cannot_create_variable_spot', false);
exception when others then
  insert into test_results (test, passed)
  values ('member_cannot_create_variable_spot', sqlerrm = 'spot_location_required');
end $$;
reset role;
reset request.jwt.claims;
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
-- An imported place named like a spot (ignoring case) is linked to it.
select import_events(jsonb_build_array(jsonb_build_object(
  'label', 'Plan 28 import', 'starts_at', now() + interval '12 days', 'spot', 'QUICK SPOT')));
insert into test_results (test, passed)
select 'import_links_spot_by_name',
  (select s.name from events e join spots s on s.id = e.spot_id where e.label = 'Plan 28 import')
    = 'Quick spot';
reset role;
reset request.jwt.claims;

-- ===== Plan 29: session natures =====
-- The owner creates a training without scores at a free place: no scorecard, the tag kept, and
-- the organizer is its first attendee.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
select create_session(jsonb_build_object('tags', jsonb_build_array('training', 'training'),
  'kind', 'individual', 'zone', 'Smoke gym', 'city', 'Smoketown',
  'location', jsonb_build_object('lat', 48.82, 'lng', 2.32), 'comment', 'plan29 training'));
insert into test_results (test, passed)
select 'no_scores_session_created',
  exists (
    select 1 from sessions s
    join team_players tp on tp.session_id = s.id
    join players p on p.id = tp.player_id and p.user_id = s.owner_id
    where s.comment = 'plan29 training' and s.scoring_mode is null and s.kind is null
      and s.ranking_direction is null and s.tags = '{training}' and s.zone = 'Smoke gym'
      and s.spot_id is null and round(s.location_lat::numeric, 2) = 48.82
  );
do $$
begin
  perform create_session('{"zone": "Nowhere"}'::jsonb);
  insert into test_results (test, passed) values ('session_needs_a_nature', false);
exception when others then
  insert into test_results (test, passed)
  values ('session_needs_a_nature', sqlerrm like '%sessions_has_nature%');
end $$;
do $$
begin
  perform create_session('{"tags": ["association_life"]}'::jsonb);
  insert into test_results (test, passed) values ('no_scores_session_needs_a_place', false);
exception when others then
  insert into test_results (test, passed)
  values ('no_scores_session_needs_a_place', sqlerrm = 'spot_required');
end $$;
-- A scorecard still needs a spot, even with a place name.
do $$
begin
  perform create_session('{"kind": "individual", "scoring_mode": "stroke_play",
    "ranking_direction": "asc", "zone": "Nowhere"}'::jsonb);
  insert into test_results (test, passed) values ('scored_session_needs_a_spot', false);
exception when others then
  insert into test_results (test, passed)
  values ('scored_session_needs_a_spot', sqlerrm = 'spot_required');
end $$;
-- A scored training and a scored simulator session on the association's spot.
select create_session(jsonb_build_object('kind', 'individual', 'scoring_mode', 'stroke_play',
  'ranking_direction', 'asc', 'tags', jsonb_build_array('training'),
  'spot_id', (select id from spots where name = 'Quick spot' and association_id = 'c0000000-0000-0000-0000-000000000001'),
  'comment', 'plan29 scored training'));
select create_session(jsonb_build_object('kind', 'individual', 'scoring_mode', 'stroke_play',
  'ranking_direction', 'asc', 'tags', jsonb_build_array('simulator'),
  'spot_id', (select id from spots where name = 'Quick spot' and association_id = 'c0000000-0000-0000-0000-000000000001'),
  'comment', 'plan29 simulator'));
reset role;
reset request.jwt.claims;

create temp table test_p29 as
select
  (select id from sessions where comment = 'plan29 training') as training,
  (select code from sessions where comment = 'plan29 training') as training_code,
  (select id from sessions where comment = 'plan29 scored training') as scored_training,
  (select id from sessions where comment = 'plan29 simulator') as simulator;
grant select on test_p29 to authenticated;

-- Attendees: added by the organizer, or by code, they're on the single team; the organizer may
-- step out of it and stay the organizer.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
insert into session_members (session_id, user_id, role)
select training, 'a0000000-0000-0000-0000-000000000002', 'player' from test_p29;
reset role;
reset request.jwt.claims;
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000003","role":"authenticated"}';
select join_session((select training_code from test_p29));
reset role;
reset request.jwt.claims;
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
update session_members set team_id = null
where session_id = (select training from test_p29) and user_id = 'a0000000-0000-0000-0000-000000000001';
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'no_scores_attendees_on_single_team',
  (select count(*) from team_players where session_id = (select training from test_p29)) = 2
  and (select count(*) from teams where session_id = (select training from test_p29)) = 1
  and exists (
    select 1 from team_players tp join players p on p.id = tp.player_id
    where tp.session_id = (select training from test_p29)
      and p.user_id = 'a0000000-0000-0000-0000-000000000003'
  )
  and exists (
    select 1 from session_members
    where session_id = (select training from test_p29)
      and user_id = 'a0000000-0000-0000-0000-000000000001' and role = 'owner' and team_id is null
  );

-- A participant added by the organizer hasn't joined yet; opening the session checks them in
-- (check_in_session, Q218).
insert into test_results (test, passed)
select 'added_member_not_checked_in',
  (select checked_in_at is null from session_members
   where session_id = (select training from test_p29)
     and user_id = 'a0000000-0000-0000-0000-000000000002');
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
select check_in_session((select training from test_p29));
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'check_in_session_checks_self_in',
  (select checked_in_at is not null from session_members
   where session_id = (select training from test_p29)
     and user_id = 'a0000000-0000-0000-0000-000000000002');

-- Completed straight from the draft; its tags stay free for the organizer, never all removed.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
update sessions set status = 'completed', started_at = now(), ended_at = now()
where id = (select training from test_p29);
select set_session_tags((select training from test_p29), '{simulator,association_life}');
insert into test_results (test, passed)
select 'no_scores_tags_free',
  (select tags from sessions where id = (select training from test_p29))
    = '{simulator,association_life}'::session_tag[];
do $$
begin
  perform set_session_tags((select training from test_p29), '{}');
  insert into test_results (test, passed) values ('no_scores_keeps_a_tag', false);
exception when others then
  insert into test_results (test, passed)
  values ('no_scores_keeps_a_tag', sqlerrm = 'session_nature_required');
end $$;

-- The scorecard and "simulator" with a scorecard are frozen.
do $$
begin
  update sessions set scoring_mode = 'match_play', ranking_direction = 'desc'
  where id = (select scored_training from test_p29);
  insert into test_results (test, passed) values ('scorecard_frozen', false);
exception when others then
  insert into test_results (test, passed) values ('scorecard_frozen', sqlerrm = 'session_nature_frozen');
end $$;
do $$
begin
  perform set_session_tags((select simulator from test_p29), '{}');
  insert into test_results (test, passed) values ('scored_simulator_frozen', false);
exception when others then
  insert into test_results (test, passed)
  values ('scored_simulator_frozen', sqlerrm = 'session_nature_frozen');
end $$;
-- A simulator session plays free holes only.
do $$
begin
  perform add_played_hole((select simulator from test_p29), (select private_hole from test_ids),
    'individual');
  insert into test_results (test, passed) values ('simulator_free_holes_only', false);
exception when others then
  insert into test_results (test, passed)
  values ('simulator_free_holes_only', sqlerrm = 'simulator_free_holes_only');
end $$;
-- "Training" with a scorecard: the organizer until the session is completed...
select set_session_tags((select scored_training from test_p29), '{}');
select set_session_tags((select scored_training from test_p29), '{training}');
update sessions set status = 'completed', started_at = now(), ended_at = now()
where id = (select scored_training from test_p29);
do $$
begin
  perform set_session_tags((select scored_training from test_p29), '{}');
  insert into test_results (test, passed) values ('scored_training_locked_for_organizer', false);
exception when others then
  insert into test_results (test, passed)
  values ('scored_training_locked_for_organizer', sqlerrm = 'session_tag_locked');
end $$;
reset role;
reset request.jwt.claims;
-- ...the local manager at any time; never on a championship session.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
do $$
begin
  perform set_session_championship((select scored_training from test_p29), true);
  insert into test_results (test, passed) values ('training_not_championship', false);
exception when others then
  insert into test_results (test, passed)
  values ('training_not_championship', sqlerrm = 'not_game_session');
end $$;
select set_session_tags((select scored_training from test_p29), '{association_life}');
select set_session_championship((select scored_training from test_p29), true);
do $$
begin
  perform set_session_tags((select scored_training from test_p29), '{training}');
  insert into test_results (test, passed) values ('championship_refuses_training', false);
exception when others then
  insert into test_results (test, passed)
  values ('championship_refuses_training', sqlerrm = 'championship_session');
end $$;
select set_session_report((select training from test_p29), '  Great session  ');
insert into test_results (test, passed)
select 'staff_edits_tags_and_report',
  (select tags = '{association_life}' and is_championship from sessions
   where id = (select scored_training from test_p29))
  and (select comment from sessions where id = (select training from test_p29)) = 'Great session';
reset role;
reset request.jwt.claims;
-- Someone else changes neither.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000004","role":"authenticated"}';
do $$
begin
  perform set_session_tags((select training from test_p29), '{training}');
  insert into test_results (test, passed) values ('outsider_cannot_tag', false);
exception when others then
  insert into test_results (test, passed)
  values ('outsider_cannot_tag', sqlerrm = 'not_session_manager');
end $$;
reset role;
reset request.jwt.claims;

-- ===== Plan 31: one form to create and edit a session =====
-- A session entered afterwards keeps its past start and end, even once started; never a future
-- start.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
select create_session(jsonb_build_object('tags', jsonb_build_array('association_life'),
  'zone', 'Smoke hall', 'title', '  General assembly  ', 'comment', 'plan31 past',
  'started_at', now() - interval '10 days', 'ended_at', now() - interval '10 days' + interval '2 hours'));
select start_session((select id from sessions where comment = 'plan31 past'));
insert into test_results (test, passed)
select 'past_session_keeps_its_dates',
  (select title = 'General assembly' and status = 'live'
     and started_at < now() - interval '9 days'
     and ended_at - started_at = interval '2 hours'
   from sessions where comment = 'plan31 past');
do $$
begin
  perform create_session(jsonb_build_object('tags', jsonb_build_array('training'),
    'zone', 'Future hall', 'started_at', now() + interval '1 day'));
  insert into test_results (test, passed) values ('no_future_start', false);
exception when others then
  insert into test_results (test, passed) values ('no_future_start', sqlerrm = 'invalid_schedule');
end $$;
-- The organizer edits name, place, dates, tags and report in one call.
select update_session((select training from test_p29), jsonb_build_object(
  'title', 'Putting clinic', 'comment', 'Edited report',
  'tags', jsonb_build_array('training'),
  'place', jsonb_build_object('zone', 'Other gym', 'city', 'Othercity',
    'location', jsonb_build_object('lat', 48.9, 'lng', 2.4)),
  'started_at', now() - interval '3 days', 'ended_at', now() - interval '3 days' + interval '1 hour'));
insert into test_results (test, passed)
select 'organizer_edits_everything',
  (select title = 'Putting clinic' and comment = 'Edited report' and tags = '{training}'
     and zone = 'Other gym' and city = 'Othercity' and spot_id is null
     and round(location_lat::numeric, 1) = 48.9 and started_at < now() - interval '2 days'
   from sessions where id = (select training from test_p29));
-- A session with a scorecard keeps a spot; the scorecard itself never changes.
do $$
begin
  perform update_session((select scored_training from test_p29),
    '{"place": {"zone": "Somewhere"}}'::jsonb);
  insert into test_results (test, passed) values ('scored_session_keeps_a_spot', false);
exception when others then
  insert into test_results (test, passed)
  values ('scored_session_keeps_a_spot', sqlerrm = 'spot_required');
end $$;
do $$
begin
  perform update_session((select training from test_p29),
    jsonb_build_object('started_at', now() - interval '1 hour', 'ended_at', now() - interval '2 hours'));
  insert into test_results (test, passed) values ('edit_end_after_start', false);
exception when others then
  insert into test_results (test, passed) values ('edit_end_after_start', sqlerrm = 'invalid_schedule');
end $$;
reset role;
reset request.jwt.claims;
-- The local manager changes tags and report, not the name, place or dates (Q209).
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000009","role":"authenticated"}';
select update_session((select training from test_p29),
  '{"tags": ["training", "association_life"], "comment": "Staff report"}'::jsonb);
do $$
begin
  perform update_session((select training from test_p29), '{"title": "Staff title"}'::jsonb);
  insert into test_results (test, passed) values ('staff_cannot_rename', false);
exception when others then
  insert into test_results (test, passed) values ('staff_cannot_rename', sqlerrm = 'not_session_owner');
end $$;
insert into test_results (test, passed)
select 'staff_edits_tags_and_report_in_form',
  (select tags = '{training,association_life}' and comment = 'Staff report'
     and title = 'Putting clinic'
   from sessions where id = (select training from test_p29));
reset role;
reset request.jwt.claims;
drop table test_p29;

-- ===== Plan 36: archive of deleted completed sessions =====
-- A completed game session carrying everything an archive must keep, written like a seed replay
-- (no signed-in caller: the values given are kept): an event, two teams, a participant who never
-- joined, a directory hole with its own par and a free hole, scores, two photos and a cover,
-- championship, tags, title, report and weather. Its spot and hole are its own, deleted later to
-- test the restore's conflicts.
insert into spots (id, association_id, name, city, location)
values ('d0000000-0000-0000-0000-000000000036', 'c0000000-0000-0000-0000-000000000001', 'P36 Park',
        'P36 City', st_setsrid(st_makepoint(2.37, 48.87), 4326)::geography);
insert into holes (id, owner_id, name, par, start)
values ('b0000000-0000-0000-0000-000000000036', 'a0000000-0000-0000-0000-000000000001', 'P36 hole', 4,
        st_setsrid(st_makepoint(2.37, 48.87), 4326)::geography);
insert into events (association_id, created_by, starts_at, label)
values ('c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
        now() - interval '3 hours', 'Smoke p36');
insert into test_events select 'p36', id from events where label = 'Smoke p36';
insert into sessions (id, owner_id, status, kind, scoring_mode, ranking_direction, tags, title,
  spot_id, location, started_at, ended_at, weather, comment, association_id, is_championship, event_id)
values ('36000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'completed',
  'team', 'stroke_play', 'asc', '{association_life}', 'P36 cup', 'd0000000-0000-0000-0000-000000000036',
  st_setsrid(st_makepoint(2.371, 48.871), 4326)::geography, now() - interval '2 hours',
  now() - interval '1 hour', '{"code": 2, "temperature": 18.5}', 'P36 report',
  'c0000000-0000-0000-0000-000000000001', true, (select id from test_events where name = 'p36'));
insert into teams (id, session_id, position)
values ('36000000-0000-0000-0001-000000000001', '36000000-0000-0000-0000-000000000001', 1),
       ('36000000-0000-0000-0001-000000000002', '36000000-0000-0000-0000-000000000001', 2);
insert into team_players (team_id, player_id)
select '36000000-0000-0000-0001-000000000001'::uuid, id from players
where user_id in ('a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002')
union all
select '36000000-0000-0000-0001-000000000002'::uuid, id from players
where user_id = 'a0000000-0000-0000-0000-000000000003';
insert into session_members (session_id, user_id, team_id, role, checked_in_at)
values ('36000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
        '36000000-0000-0000-0001-000000000001', 'owner', now() - interval '2 hours'),
       ('36000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002',
        '36000000-0000-0000-0001-000000000001', 'player', now() - interval '2 hours'),
       ('36000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003',
        '36000000-0000-0000-0001-000000000002', 'player', null);
insert into played_holes (id, session_id, hole_id, label, par, comment, game_mode, position)
values ('36000000-0000-0000-0002-000000000001', '36000000-0000-0000-0000-000000000001',
        'b0000000-0000-0000-0000-000000000036', null, 5, 'P36 windy', 'scramble', 1),
       ('36000000-0000-0000-0002-000000000002', '36000000-0000-0000-0000-000000000001',
        null, 'P36 free', 3, null, 'best_ball', 2);
insert into scores (played_hole_id, team_id, value, updated_by)
select ph::uuid, t::uuid, v, 'a0000000-0000-0000-0000-000000000001'::uuid
from (values
  ('36000000-0000-0000-0002-000000000001', '36000000-0000-0000-0001-000000000001', 4),
  ('36000000-0000-0000-0002-000000000001', '36000000-0000-0000-0001-000000000002', 6),
  ('36000000-0000-0000-0002-000000000002', '36000000-0000-0000-0001-000000000001', 3),
  ('36000000-0000-0000-0002-000000000002', '36000000-0000-0000-0001-000000000002', 2)
) s(ph, t, v);
insert into session_photos (id, session_id, storage_path, uploaded_by)
values ('36000000-0000-0000-0003-000000000001', '36000000-0000-0000-0000-000000000001',
        '36000000-0000-0000-0000-000000000001/p36-a.jpg', 'a0000000-0000-0000-0000-000000000001'),
       ('36000000-0000-0000-0003-000000000002', '36000000-0000-0000-0000-000000000001',
        '36000000-0000-0000-0000-000000000001/p36-b.jpg', 'a0000000-0000-0000-0000-000000000002');
update sessions set cover_photo_id = '36000000-0000-0000-0003-000000000002'
where id = '36000000-0000-0000-0000-000000000001';
-- A draft and a live session of the same organizer (no spot: plan 28's tests deleted Smoke Park).
insert into sessions (id, owner_id, status, kind, scoring_mode, ranking_direction, association_id)
values ('36000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'draft',
        'individual', 'stroke_play', 'asc', 'c0000000-0000-0000-0000-000000000001'),
       ('36000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'live',
        'individual', 'stroke_play', 'asc', 'c0000000-0000-0000-0000-000000000001');
insert into session_members (session_id, user_id, role)
values ('36000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'owner'),
       ('36000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'owner');

-- Every row of a session, table by table, to compare before and after.
create function pg_temp.test_p36_rows(p_session uuid)
returns table (t text, row_data jsonb)
language sql
as $$
  select 'sessions', (select jsonb_agg(to_jsonb(r)) from sessions r where r.id = p_session)
  union all select 'teams', (select jsonb_agg(to_jsonb(r) order by r.position)
    from teams r where r.session_id = p_session)
  union all select 'team_players', (select jsonb_agg(to_jsonb(r) order by r.team_id, r.player_id)
    from team_players r where r.session_id = p_session)
  union all select 'session_members', (select jsonb_agg(to_jsonb(r) order by r.user_id)
    from session_members r where r.session_id = p_session)
  union all select 'played_holes', (select jsonb_agg(to_jsonb(r) order by r.position)
    from played_holes r where r.session_id = p_session)
  union all select 'scores', (select jsonb_agg(to_jsonb(r) order by r.played_hole_id, r.team_id)
    from scores r where r.session_id = p_session)
  union all select 'session_photos', (select jsonb_agg(to_jsonb(r) order by r.id)
    from session_photos r where r.session_id = p_session);
$$;
-- "full": the session above; "training": plan 29's session without scores, completed, with two
-- attendees on its single team and its organizer off it.
create temp table test_p36 as
select 'full' as s, '36000000-0000-0000-0000-000000000001'::uuid as session_id, r.t, r.row_data
from pg_temp.test_p36_rows('36000000-0000-0000-0000-000000000001') r
union all
select 'training', s.id, r.t, r.row_data
from sessions s, pg_temp.test_p36_rows(s.id) r
where s.title = 'Putting clinic';
grant select on test_p36 to authenticated;

-- The organizer deletes all three: only the completed one is archived, with every row.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
delete from sessions
where id in ('36000000-0000-0000-0000-000000000001', '36000000-0000-0000-0000-000000000002',
             '36000000-0000-0000-0000-000000000003');
reset role;
reset request.jwt.claims;
insert into test_results (test, passed)
select 'draft_and_live_deleted_for_good',
  not exists (select 1 from sessions
              where id in ('36000000-0000-0000-0000-000000000002', '36000000-0000-0000-0000-000000000003'))
  and not exists (select 1 from session_archives
                  where session_id in ('36000000-0000-0000-0000-000000000002',
                                       '36000000-0000-0000-0000-000000000003'));
insert into test_results (test, passed)
select 'completed_session_archived_on_delete',
  not exists (select 1 from sessions where id = '36000000-0000-0000-0000-000000000001')
  and not exists (select 1 from teams where session_id = '36000000-0000-0000-0000-000000000001')
  and (select count(*) from session_archives where session_id = '36000000-0000-0000-0000-000000000001') = 1
  and (select deleted_by from session_archives where session_id = '36000000-0000-0000-0000-000000000001')
    = 'a0000000-0000-0000-0000-000000000001'
  and (select bool_and(jsonb_array_length(a.data -> b.t) = jsonb_array_length(b.row_data))
       from test_p36 b
       join session_archives a on a.session_id = b.session_id
       where b.s = 'full' and b.t <> 'sessions')
  and (select data -> 'session' ->> 'comment' from session_archives
       where session_id = '36000000-0000-0000-0000-000000000001') = 'P36 report';

-- No account reads the archive nor restores, whatever its role.
set role authenticated;
do $$
declare
  v_user record;
begin
  for v_user in
    select * from (values
      ('organizer', 'a0000000-0000-0000-0000-000000000001'),
      ('member', 'a0000000-0000-0000-0000-000000000002'),
      ('super_admin', 'a0000000-0000-0000-0000-000000000006')
    ) u(label, id)
  loop
    perform set_config('request.jwt.claims',
      jsonb_build_object('sub', v_user.id, 'role', 'authenticated')::text, false);
    begin
      perform count(*) from session_archives;
      insert into test_results (test, passed) values (v_user.label || '_cannot_read_archives', false);
    exception when insufficient_privilege then
      insert into test_results (test, passed) values (v_user.label || '_cannot_read_archives', true);
    end;
    begin
      perform restore_session_archive('36000000-0000-0000-0000-000000000001');
      insert into test_results (test, passed) values (v_user.label || '_cannot_restore', false);
    exception when insufficient_privilege then
      insert into test_results (test, passed) values (v_user.label || '_cannot_restore', true);
    end;
  end loop;
end $$;
reset role;
reset request.jwt.claims;

-- Restored with nothing changed meanwhile: every row back as it was (check-ins, cover photo,
-- championship, tags and report included), the event and spot kept, the archive gone.
do $$
begin
  insert into test_results (test, passed)
  select 'restore_settles_nothing_unchanged',
    r @> '{"new_code": false, "event_unlinked": false, "spot_unlinked": false}'
  from restore_session_archive('36000000-0000-0000-0000-000000000001') r;
exception when others then
  insert into test_results (test, passed) values ('restore_settles_nothing_unchanged: ' || sqlerrm, false);
end $$;
insert into test_results (test, passed)
select 'restore_puts_every_row_back',
  (select bool_and(a.row_data is not distinct from b.row_data) and count(*) = 7
   from test_p36 b
   join pg_temp.test_p36_rows('36000000-0000-0000-0000-000000000001') a using (t)
   where b.s = 'full')
  and not exists (select 1 from session_archives where session_id = '36000000-0000-0000-0000-000000000001');

-- Deleted again; meanwhile its code goes to another session, which is also linked to its event,
-- and its spot is deleted: it comes back with a new code, without event nor spot, its place kept.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
delete from sessions where id = '36000000-0000-0000-0000-000000000001';
reset role;
reset request.jwt.claims;
insert into sessions (id, code, owner_id, status, kind, scoring_mode, ranking_direction,
  association_id, event_id)
values ('36000000-0000-0000-0000-000000000004',
        (select row_data -> 0 ->> 'code' from test_p36 where s = 'full' and t = 'sessions'),
        'a0000000-0000-0000-0000-000000000001', 'draft', 'individual', 'stroke_play', 'asc',
        'c0000000-0000-0000-0000-000000000001', (select id from test_events where name = 'p36'));
delete from spots where id = 'd0000000-0000-0000-0000-000000000036';
do $$
begin
  insert into test_results (test, passed)
  select 'restore_settles_code_event_spot',
    r @> '{"new_code": true, "event_unlinked": true, "spot_unlinked": true}'
    and r ->> 'code' <> (select row_data -> 0 ->> 'code' from test_p36 where s = 'full' and t = 'sessions')
  from restore_session_archive('36000000-0000-0000-0000-000000000001') r;
exception when others then
  insert into test_results (test, passed) values ('restore_settles_code_event_spot: ' || sqlerrm, false);
end $$;
insert into test_results (test, passed)
select 'restore_after_conflicts_keeps_the_rest',
  (select bool_and(case when t = 'sessions'
                     then (a.row_data -> 0) - 'code' - 'event_id' - 'spot_id'
                          = (b.row_data -> 0) - 'code' - 'event_id' - 'spot_id'
                     else a.row_data is not distinct from b.row_data end)
   from test_p36 b
   join pg_temp.test_p36_rows('36000000-0000-0000-0000-000000000001') a using (t)
   where b.s = 'full')
  and (select event_id is null and spot_id is null and zone = 'P36 Park' and city = 'P36 City'
       from sessions where id = '36000000-0000-0000-0000-000000000001');

-- Deleted again, then its hole is deleted: the restore is refused, naming the hole, and changes
-- nothing.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
delete from sessions where id = '36000000-0000-0000-0000-000000000001';
reset role;
reset request.jwt.claims;
delete from holes where id = 'b0000000-0000-0000-0000-000000000036';
do $$
begin
  perform restore_session_archive('36000000-0000-0000-0000-000000000001');
  insert into test_results (test, passed) values ('restore_refused_hole_gone', false);
exception when others then
  insert into test_results (test, passed)
  values ('restore_refused_hole_gone', sqlerrm like 'restore_refused:%"holes"%');
end $$;
insert into test_results (test, passed)
select 'refused_restore_changes_nothing',
  not exists (select 1 from sessions where id = '36000000-0000-0000-0000-000000000001')
  and not exists (select 1 from teams where session_id = '36000000-0000-0000-0000-000000000001')
  and not exists (select 1 from session_members where session_id = '36000000-0000-0000-0000-000000000001')
  and (select count(*) from session_archives where session_id = '36000000-0000-0000-0000-000000000001') = 1;

-- A session without scores: its attendees' team rows, recreated by the base from its members,
-- come back once, not twice.
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}';
delete from sessions where id = (select distinct session_id from test_p36 where s = 'training');
reset role;
reset request.jwt.claims;
do $$
begin
  perform restore_session_archive((select distinct session_id from test_p36 where s = 'training'));
exception when others then
  insert into test_results (test, passed) values ('no_scores_restore: ' || sqlerrm, false);
end $$;
insert into test_results (test, passed)
select 'no_scores_session_restored_without_duplicates',
  (select bool_and(a.row_data is not distinct from b.row_data) and count(*) = 7
   from test_p36 b
   join pg_temp.test_p36_rows(b.session_id) a using (t)
   where b.s = 'training')
  and (select jsonb_array_length(row_data) from test_p36 where s = 'training' and t = 'team_players') = 2;
drop table test_p36;
drop function pg_temp.test_p36_rows(uuid);

-- ===== Cleanup =====
delete from sessions where event_id in (select id from test_events);
delete from events where association_id in ('c0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002');
delete from sessions where id in (select session_id from test_ids);
delete from sessions where association_id in ('c0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002');
-- The completed ones deleted above, and by plan 36's tests, were archived (plan 36).
delete from session_archives
where data -> 'session' ->> 'association_id'
  in ('c0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002');
delete from holes where cloned_from in (select private_hole from test_ids);
delete from holes where id in (select private_hole from test_ids)
  or id = 'b0000000-0000-0000-0000-000000000036';
delete from association_managers where association_id = 'c0000000-0000-0000-0000-000000000001';
delete from players where user_id in (
  select owner_user from test_ids union select member1_user from test_ids union select member2_user from test_ids
  union select outsider_user from test_ids union select joiner_user from test_ids
  union select 'a0000000-0000-0000-0000-000000000006'::uuid
  union select 'a0000000-0000-0000-0000-000000000007'::uuid
  union select 'a0000000-0000-0000-0000-000000000008'::uuid
  union select 'a0000000-0000-0000-0000-000000000009'::uuid
  union select 'a0000000-0000-0000-0000-000000000010'::uuid
);
delete from associations where id in ('c0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002') or name = 'Smoke Pending';
delete from user_roles where user_id = 'a0000000-0000-0000-0000-000000000006';
delete from auth.users where id in (
  select owner_user from test_ids union select member1_user from test_ids union select member2_user from test_ids
  union select outsider_user from test_ids union select joiner_user from test_ids
  union select 'a0000000-0000-0000-0000-000000000006'::uuid
  union select 'a0000000-0000-0000-0000-000000000007'::uuid
  union select 'a0000000-0000-0000-0000-000000000008'::uuid
  union select 'a0000000-0000-0000-0000-000000000009'::uuid
  union select 'a0000000-0000-0000-0000-000000000010'::uuid
);

-- ===== Verdict =====
-- The last statement, the only one whose rows the command shows (Q250): not_passed must be empty
-- and leftovers 0 (fixture data the cleanup above missed).
select count(*) as tests,
       count(*) filter (where passed) as passed,
       coalesce(jsonb_agg(test order by n) filter (where passed is not true), '[]'::jsonb) as not_passed,
       (select count(*) from auth.users where email like '%@smoke.nuni')
         + (select count(*) from associations
            where id in ('c0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002')
               or name = 'Smoke Pending')
         + (select count(*) from session_archives
            where data -> 'session' ->> 'association_id'
              in ('c0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002'))
         as leftovers
from test_results;
