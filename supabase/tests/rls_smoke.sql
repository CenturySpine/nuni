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
  ('a0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'joiner@smoke.nuni', '{"full_name":"Smoke Joiner"}', now(), now());

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

-- ===== Verdict =====
select * from test_results order by n;

-- ===== Cleanup =====
delete from sessions where id in (select session_id from test_ids);
delete from holes where id in (select private_hole from test_ids);
delete from players where user_id in (
  select owner_user from test_ids union select member1_user from test_ids union select member2_user from test_ids
  union select outsider_user from test_ids union select joiner_user from test_ids
);
delete from auth.users where id in (
  select owner_user from test_ids union select member1_user from test_ids union select member2_user from test_ids
  union select outsider_user from test_ids union select joiner_user from test_ids
);
drop table test_ids;
drop table test_results;
