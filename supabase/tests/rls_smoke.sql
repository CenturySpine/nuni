-- RLS/RPC smoke test (plan 03, step 5). No local Docker in this project: run manually against
-- the linked remote project with a role that owns the schema (bypasses RLS for the fixture setup
-- and cleanup) --
--   npx supabase db query --linked -f supabase/tests/rls_smoke.sql
-- Creates disposable fixture data (auth.users, a session, a hole), exercises policies and
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

-- A hole owned by the session owner (every hole is public since plan 26, Q110), par 4 so the
-- played hole's copied par is distinguishable from the free-hole default of 3.
insert into holes (id, owner_id, name, par, start)
values ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Smoke hole', 4,
        st_setsrid(st_makepoint(2.35, 48.85), 4326)::geography);

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
create table test_events (name text primary key, id uuid);
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
-- An event already started takes no more answers.
insert into events (starts_at, label) values (now() - interval '1 hour', 'Smoke past');
insert into test_events select 'past', id from events where label = 'Smoke past';
do $$
begin
  insert into event_responses (event_id, player_id, response)
  select (select id from test_events where name = 'past'),
    (select id from players where user_id = 'a0000000-0000-0000-0000-000000000007'), 'yes';
  insert into test_results (test, passed) values ('no_answer_after_start', false);
exception when others then
  insert into test_results (test, passed) values ('no_answer_after_start', sqlerrm = 'event_started');
end $$;
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
    'ranking_direction', 'asc', 'event_id', (select id from test_events where name = 'today')));
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
  'ranking_direction', 'asc', 'event_id', (select id from test_events where name = 'today')));
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

-- ===== Plan 27: local admins and partners =====
-- Association 1: manager (9) names deputy (10); owner (1) is a plain member, fan (7) a second
-- admin who renounces; foreign (8) belongs to association 2.
create table test_plan27 as
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
-- "start the session"...
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
  'ranking_direction', 'asc', 'event_id', (select id from test_events where name = 'today')));
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

-- ===== Verdict =====
select * from test_results order by n;

-- ===== Cleanup =====
delete from sessions where event_id in (select id from test_events);
delete from events where association_id in ('c0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002');
delete from sessions where id in (select session_id from test_ids);
delete from holes where cloned_from in (select private_hole from test_ids);
delete from holes where id in (select private_hole from test_ids);
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
drop table test_ids;
drop table test_events;
drop table test_results;
