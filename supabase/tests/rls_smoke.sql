-- RLS/RPC smoke test (plan 03, step 5). No local Docker in this project: run manually against
-- the linked remote project with a role that owns the schema (bypasses RLS for the fixture setup
-- and cleanup) --
--   npx supabase db query --linked -f supabase/tests/rls_smoke.sql
-- Creates disposable fixture data (auth.users, a session, a private hole), exercises policies and
-- RPCs by impersonating each user via SET ROLE authenticated + request.jwt.claims, records
-- pass/fail into test_results, prints it, then deletes everything it created. Every row in the
-- final SELECT must have passed = true.

create table if not exists test_results (n int generated always as identity, test text, passed boolean);
grant select, insert on test_results to authenticated;

-- ===== Fixture (as the invoking privileged role: bypasses RLS) =====
insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values
  ('a0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'owner@smoke.nuni', '{"full_name":"Smoke Owner"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'member1@smoke.nuni', '{"full_name":"Smoke Member1"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'member2@smoke.nuni', '{"full_name":"Smoke Member2"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'outsider@smoke.nuni', '{"full_name":"Smoke Outsider"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'joiner@smoke.nuni', '{"full_name":"Smoke Joiner"}', now(), now()),
  ('a0000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin@smoke.nuni', '{"full_name":"Smoke Admin"}', now(), now());

-- An approved association for the session owner (plan 18: creating a session requires one); the
-- other fixture users have none. "admin" is a super_admin, to exercise the review RPCs.
insert into associations (id, name, city, location, status)
values ('c0000000-0000-0000-0000-000000000001', 'Smoke Asso', 'Smokeville',
        st_setsrid(st_makepoint(2.35, 48.85), 4326)::geography, 'approved');
update players set association_id = 'c0000000-0000-0000-0000-000000000001'
where user_id = 'a0000000-0000-0000-0000-000000000001';
insert into user_roles (user_id, role) values ('a0000000-0000-0000-0000-000000000006', 'super_admin');

-- a private hole owned by the session owner (NOT by the "outsider" test user, otherwise the
-- outsider would see it via plain ownership and the Q13 test would prove nothing): tests Q13
-- (visible to session members once played, still invisible to a non-member).
insert into holes (id, owner_id, name, par, start, visibility)
values ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Smoke private hole', 3,
        st_setsrid(st_makepoint(2.35, 48.85), 4326)::geography, 'private');

create table test_ids as
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

-- ===== Test 1: a non-member cannot read the session =====
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000004","role":"authenticated"}';
insert into test_results (test, passed)
select 'outsider_cannot_read_session',
  (select count(*) from sessions where id = (select session_id from test_ids)) = 0;
insert into test_results (test, passed)
select 'outsider_cannot_read_played_hole_via_q13',
  (select count(*) from holes where id = (select private_hole from test_ids)) = 0;
reset role;
reset request.jwt.claims;

-- ===== Test 2: a member can read the session and, via Q13, the private hole played in it =====
set role authenticated;
set request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002","role":"authenticated"}';
insert into test_results (test, passed)
select 'member_can_read_session',
  (select count(*) from sessions where id = (select session_id from test_ids)) = 1;
insert into test_results (test, passed)
select 'member_can_read_private_hole_played_in_session_q13',
  (select count(*) from holes where id = (select private_hole from test_ids)) = 1;
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
  perform create_session('{"kind":"individual","scoring_mode":"stroke_play","ranking_direction":"asc"}');
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

-- ===== Verdict =====
select * from test_results order by n;

-- ===== Cleanup =====
delete from sessions where id in (select session_id from test_ids);
delete from holes where id in (select private_hole from test_ids);
delete from players where user_id in (
  select owner_user from test_ids union select member1_user from test_ids union select member2_user from test_ids
  union select outsider_user from test_ids union select joiner_user from test_ids
  union select 'a0000000-0000-0000-0000-000000000006'::uuid
);
delete from associations where id = 'c0000000-0000-0000-0000-000000000001' or name = 'Smoke Pending';
delete from user_roles where user_id = 'a0000000-0000-0000-0000-000000000006';
delete from auth.users where id in (
  select owner_user from test_ids union select member1_user from test_ids union select member2_user from test_ids
  union select outsider_user from test_ids union select joiner_user from test_ids
  union select 'a0000000-0000-0000-0000-000000000006'::uuid
);
drop table test_ids;
drop table test_results;
