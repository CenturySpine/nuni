-- Notification recipients smoke test (plan 33). Same procedure as rls_smoke.sql: run manually
-- against the linked remote project, after the migration 20260929120000_push_notifications --
--   npx supabase db query --linked -f supabase/tests/notifications_smoke.sql
-- Creates disposable fixture data, checks who each rule notifies and the subscription RPCs,
-- prints the results, then deletes everything it created. Every row must have passed = true.
-- Sends nothing: no fixture account has a subscription when the triggers fire.

create table if not exists notif_results (n int generated always as identity, test text, passed boolean);
grant select, insert on notif_results to authenticated;

-- Leftovers of an interrupted run, if any.
truncate notif_results;
drop table if exists notif_ids;
delete from push_subscriptions where endpoint = 'https://push.example/notif-smoke';
delete from events where association_id = 'd1000000-0000-0000-0000-000000000001';
delete from players where user_id::text like 'b1000000-0000-0000-0000-00000000000%';
delete from associations where id in ('d1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002');
delete from auth.users where id::text like 'b1000000-0000-0000-0000-00000000000%';

-- ===== Fixture (privileged role: bypasses RLS) =====
-- manager, present, maybe, absent, silent (no answer) belong to the association; other to
-- another one.
insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values
  ('b1000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'manager@notif.nuni', '{"full_name":"Notif Manager"}', now(), now()),
  ('b1000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'present@notif.nuni', '{"full_name":"Notif Present"}', now(), now()),
  ('b1000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'maybe@notif.nuni', '{"full_name":"Notif Maybe"}', now(), now()),
  ('b1000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'absent@notif.nuni', '{"full_name":"Notif Absent"}', now(), now()),
  ('b1000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'silent@notif.nuni', '{"full_name":"Notif Silent"}', now(), now()),
  ('b1000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'other@notif.nuni', '{"full_name":"Notif Other"}', now(), now());

insert into associations (id, name, city, location, status)
values
  ('d1000000-0000-0000-0000-000000000001', 'Notif Asso', 'Notifville',
   st_setsrid(st_makepoint(2.35, 48.85), 4326)::geography, 'approved'),
  ('d1000000-0000-0000-0000-000000000002', 'Notif Other', 'Othertown',
   st_setsrid(st_makepoint(4.0, 45.0), 4326)::geography, 'approved');

update players set association_id = 'd1000000-0000-0000-0000-000000000001'
where user_id in (
  'b1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000002',
  'b1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000004',
  'b1000000-0000-0000-0000-000000000005'
);
update players set association_id = 'd1000000-0000-0000-0000-000000000002'
where user_id = 'b1000000-0000-0000-0000-000000000006';

create temp table notif_ids as
select
  (select id from players where user_id = 'b1000000-0000-0000-0000-000000000001') as manager,
  (select id from players where user_id = 'b1000000-0000-0000-0000-000000000002') as present,
  (select id from players where user_id = 'b1000000-0000-0000-0000-000000000003') as maybe,
  (select id from players where user_id = 'b1000000-0000-0000-0000-000000000004') as absent,
  'e1000000-0000-0000-0000-000000000001'::uuid as event;
grant select on notif_ids to authenticated;

insert into events (id, association_id, created_by, manager_player_id, starts_at, label, origin)
select event, 'd1000000-0000-0000-0000-000000000001'::uuid, 'b1000000-0000-0000-0000-000000000001'::uuid,
       manager, now() + interval '2 days', 'Notif outing', 'manual'::event_origin
from notif_ids;

insert into event_responses (event_id, player_id, response)
select event, present, 'yes'::event_response from notif_ids
union all select event, maybe, 'maybe'::event_response from notif_ids
union all select event, absent, 'no'::event_response from notif_ids;

-- Sorted, for comparison.
create or replace function pg_temp.sorted(p uuid[]) returns uuid[] language sql as $$
  select coalesce(array_agg(u order by u), '{}') from unnest(p) u;
$$;

-- ===== 1. A player's answer: the person in charge only, never themselves =====
insert into notif_results (test, passed)
select '1a response -> manager',
       _response_notification_recipients(event, present) = array['b1000000-0000-0000-0000-000000000001'::uuid]
from notif_ids;
insert into notif_results (test, passed)
select '1b manager''s own answer -> nobody',
       _response_notification_recipients(event, manager) = '{}'::uuid[]
from notif_ids;

-- ===== 2. A comment: manager + present + maybe, never the author, never absent/silent =====
insert into notif_results (test, passed)
select '2a comment by present -> manager, maybe',
       pg_temp.sorted(_comment_notification_recipients(event, present)) = pg_temp.sorted(array[
         'b1000000-0000-0000-0000-000000000001'::uuid, 'b1000000-0000-0000-0000-000000000003'])
from notif_ids;
insert into notif_results (test, passed)
select '2b comment by manager -> present, maybe',
       pg_temp.sorted(_comment_notification_recipients(event, manager)) = pg_temp.sorted(array[
         'b1000000-0000-0000-0000-000000000002'::uuid, 'b1000000-0000-0000-0000-000000000003'])
from notif_ids;
insert into event_responses (event_id, player_id, response)
select event, manager, 'yes'::event_response from notif_ids;
insert into notif_results (test, passed)
select '2c manager also present -> once',
       (select count(*) from unnest(_comment_notification_recipients(event, absent)) u
        where u = 'b1000000-0000-0000-0000-000000000001') = 1
from notif_ids;
delete from event_responses
where event_id = 'e1000000-0000-0000-0000-000000000001' and player_id = (select manager from notif_ids);

-- ===== 3. Session started: present only, not the starter =====
insert into notif_results (test, passed)
select '3a started by manager -> present',
       _session_start_notification_recipients(event, 'b1000000-0000-0000-0000-000000000001')
         = array['b1000000-0000-0000-0000-000000000002'::uuid]
from notif_ids;
insert into notif_results (test, passed)
select '3b started by present -> nobody',
       _session_start_notification_recipients(event, 'b1000000-0000-0000-0000-000000000002') = '{}'::uuid[]
from notif_ids;

-- ===== 4. New event: every member of its association but its creator =====
insert into notif_results (test, passed)
select '4 new event -> members but creator and other association',
       pg_temp.sorted(_new_event_notification_recipients(event)) = pg_temp.sorted(array[
         'b1000000-0000-0000-0000-000000000002'::uuid, 'b1000000-0000-0000-0000-000000000003',
         'b1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000005'])
from notif_ids;

-- ===== 5. No person in charge (Q227), and a player who left the association =====
update events set manager_player_id = null where id = 'e1000000-0000-0000-0000-000000000001';
insert into notif_results (test, passed)
select '5a no manager: answer -> nobody',
       _response_notification_recipients(event, present) = '{}'::uuid[]
from notif_ids;
insert into notif_results (test, passed)
select '5b no manager: comment -> maybe only',
       _comment_notification_recipients(event, present) = array['b1000000-0000-0000-0000-000000000003'::uuid]
from notif_ids;
update players set association_id = null where user_id = 'b1000000-0000-0000-0000-000000000003';
insert into notif_results (test, passed)
select '5c ex-member not notified',
       _comment_notification_recipients(event, present) = '{}'::uuid[]
from notif_ids;
update players set association_id = 'd1000000-0000-0000-0000-000000000001'
where user_id = 'b1000000-0000-0000-0000-000000000003';
update events set manager_player_id = (select manager from notif_ids)
where id = 'e1000000-0000-0000-0000-000000000001';

-- ===== 6. The app's writes go through with the triggers in place =====
set role authenticated;
set request.jwt.claims = '{"sub":"b1000000-0000-0000-0000-000000000002","role":"authenticated"}';
update event_responses set response = 'maybe'
where event_id = 'e1000000-0000-0000-0000-000000000001'
  and player_id = (select present from notif_ids);
delete from event_responses
where event_id = 'e1000000-0000-0000-0000-000000000001'
  and player_id = (select present from notif_ids);
insert into event_responses (event_id, player_id, response)
select event, present, 'yes'::event_response from notif_ids;
insert into event_comments (event_id, author_player_id, body)
select event, present, 'Smoke comment' from notif_ids;
insert into events (starts_at, label) values (now() + interval '3 days', 'Notif second outing');
insert into notif_results (test, passed) values ('6 answer, comment, event written', true);

-- ===== 7. Subscriptions: only through the RPCs, a device follows its last account =====
select save_push_subscription('https://push.example/notif-smoke', 'key', 'secret', 'en');
reset role;
reset request.jwt.claims;
insert into notif_results (test, passed)
select '7a saved for present, in English',
       exists (select 1 from push_subscriptions
               where endpoint = 'https://push.example/notif-smoke'
                 and user_id = 'b1000000-0000-0000-0000-000000000002' and locale = 'en');

set role authenticated;
set request.jwt.claims = '{"sub":"b1000000-0000-0000-0000-000000000005","role":"authenticated"}';
select save_push_subscription('https://push.example/notif-smoke', 'key', 'secret', 'fr');
do $$
begin
  perform 1 from push_subscriptions;
  insert into notif_results (test, passed) values ('7b table closed to the app', false);
exception when insufficient_privilege then
  insert into notif_results (test, passed) values ('7b table closed to the app', true);
end;
$$;
reset role;
reset request.jwt.claims;
insert into notif_results (test, passed)
select '7c same device, next account',
       exists (select 1 from push_subscriptions
               where endpoint = 'https://push.example/notif-smoke'
                 and user_id = 'b1000000-0000-0000-0000-000000000005' and locale = 'fr');

set role authenticated;
set request.jwt.claims = '{"sub":"b1000000-0000-0000-0000-000000000002","role":"authenticated"}';
select delete_push_subscription('https://push.example/notif-smoke');
reset role;
reset request.jwt.claims;
insert into notif_results (test, passed)
select '7d someone else''s device not deleted',
       exists (select 1 from push_subscriptions where endpoint = 'https://push.example/notif-smoke');

set role authenticated;
set request.jwt.claims = '{"sub":"b1000000-0000-0000-0000-000000000005","role":"authenticated"}';
select delete_push_subscription('https://push.example/notif-smoke');
reset role;
reset request.jwt.claims;
insert into notif_results (test, passed)
select '7e own device deleted',
       not exists (select 1 from push_subscriptions where endpoint = 'https://push.example/notif-smoke');

-- ===== Results =====
select n, test, passed from notif_results order by n;

-- ===== Cleanup =====
delete from push_subscriptions where endpoint = 'https://push.example/notif-smoke';
delete from events where association_id = 'd1000000-0000-0000-0000-000000000001';
delete from players where user_id::text like 'b1000000-0000-0000-0000-00000000000%';
delete from associations where id in ('d1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002');
delete from auth.users where id::text like 'b1000000-0000-0000-0000-00000000000%';
drop table notif_ids;
drop table notif_results;
