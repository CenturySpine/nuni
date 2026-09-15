-- Development seed data (plan 03, step 4). Loaded by `supabase start` + `supabase db reset`
-- (local Docker workflow; NOT applied to the remote "nuni" project, which stays empty until real
-- users sign in). Hole names/descriptions/par below are real, pulled read-only from the LsgScores
-- database (INSA Lyon zone) at the PO's suggestion (2026-09-15) -- the old app never geolocated
-- holes, so coordinates are invented, jittered around the real INSA Lyon campus. Player identities
-- are generic placeholders, not the real LsgScores players, since this file lives in a public repo.

insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'dev1@nuni.test', '{"full_name":"Joueur Un"}', now(), now()),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'dev2@nuni.test', '{"full_name":"Joueuse Deux"}', now(), now());

-- Public holes around INSA Lyon, owned by dev user 1.
insert into holes (owner_id, name, description, par, start, visibility)
values
  ('00000000-0000-0000-0000-000000000001', 'Radioactive', null, 3, st_setsrid(st_makepoint(4.8710, 45.7825), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Pitch back', null, 3, st_setsrid(st_makepoint(4.8712, 45.7828), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'The cage', null, 3, st_setsrid(st_makepoint(4.8715, 45.7822), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Fireman #1', null, 5, st_setsrid(st_makepoint(4.8708, 45.7830), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Cool down man', null, 3, st_setsrid(st_makepoint(4.8717, 45.7826), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Rhino peekaboo', 'Rhino depuis le spot sous la caméra, vers la grande fresque bleue', 4, st_setsrid(st_makepoint(4.8713, 45.7820), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Knock knock', null, 3, st_setsrid(st_makepoint(4.8706, 45.7824), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'The pitt', null, 3, st_setsrid(st_makepoint(4.8719, 45.7831), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Touch my ball', null, 3, st_setsrid(st_makepoint(4.8709, 45.7818), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Fireman #2', null, 3, st_setsrid(st_makepoint(4.8721, 45.7823), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Rhino ahead', 'Rhino depuis les bancs en béton juste au-dessus du départ du pitt', 3, st_setsrid(st_makepoint(4.8704, 45.7827), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'The gauss', 'Plaque d''égout sur la partie en béton, départ dans l''herbe de l''autre côté de la rampe descendante', 3, st_setsrid(st_makepoint(4.8716, 45.7833), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Generic', null, 3, st_setsrid(st_makepoint(4.8711, 45.7816), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Saint Exupéry', null, 3, st_setsrid(st_makepoint(4.8723, 45.7828), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'L''arche perdue', null, 3, st_setsrid(st_makepoint(4.8702, 45.7821), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'On fire', null, 3, st_setsrid(st_makepoint(4.8714, 45.7835), 4326)::geography, 'public'),
  ('00000000-0000-0000-0000-000000000001', 'Bike trash', null, 3, st_setsrid(st_makepoint(4.8707, 45.7814), 4326)::geography, 'public');

-- One live individual session (both dev users playing solo, one team each), first two holes
-- already scored -- mirrors the end state create_session()+start_session() would produce.
insert into sessions (owner_id, status, kind, scoring_mode, ranking_direction, city, zone, started_at)
values ('00000000-0000-0000-0000-000000000001', 'live', 'individual', 'stroke_play', 'asc', 'Lyon', 'INSA', now());

insert into teams (session_id, position)
select id, 1 from sessions where owner_id = '00000000-0000-0000-0000-000000000001' and status = 'live';
insert into teams (session_id, position)
select id, 2 from sessions where owner_id = '00000000-0000-0000-0000-000000000001' and status = 'live';

insert into team_players (team_id, player_id)
select t.id, p.id
from teams t
join sessions s on s.id = t.session_id and s.owner_id = '00000000-0000-0000-0000-000000000001' and s.status = 'live'
join players p on p.user_id = '00000000-0000-0000-0000-000000000001'
where t.position = 1;

insert into team_players (team_id, player_id)
select t.id, p.id
from teams t
join sessions s on s.id = t.session_id and s.owner_id = '00000000-0000-0000-0000-000000000001' and s.status = 'live'
join players p on p.user_id = '00000000-0000-0000-0000-000000000002'
where t.position = 2;

insert into session_members (session_id, user_id, team_id, role)
select s.id, '00000000-0000-0000-0000-000000000001', t.id, 'owner'
from sessions s
join teams t on t.session_id = s.id and t.position = 1
where s.owner_id = '00000000-0000-0000-0000-000000000001' and s.status = 'live';

insert into session_members (session_id, user_id, team_id, role)
select s.id, '00000000-0000-0000-0000-000000000002', t.id, 'player'
from sessions s
join teams t on t.session_id = s.id and t.position = 2
where s.owner_id = '00000000-0000-0000-0000-000000000001' and s.status = 'live';

insert into played_holes (session_id, hole_id, game_mode, position)
select s.id, h.id, 'individual', 1
from sessions s, holes h
where s.owner_id = '00000000-0000-0000-0000-000000000001' and s.status = 'live' and h.name = 'Radioactive';

insert into played_holes (session_id, hole_id, game_mode, position)
select s.id, h.id, 'individual', 2
from sessions s, holes h
where s.owner_id = '00000000-0000-0000-0000-000000000001' and s.status = 'live' and h.name = 'Pitch back';

insert into scores (played_hole_id, team_id, value)
select ph.id, t.id, case t.position when 1 then 3 else 4 end
from played_holes ph
join sessions s on s.id = ph.session_id and s.owner_id = '00000000-0000-0000-0000-000000000001' and s.status = 'live'
join teams t on t.session_id = s.id
where ph.position = 1;

insert into scores (played_hole_id, team_id, value)
select ph.id, t.id, case t.position when 1 then 2 else 3 end
from played_holes ph
join sessions s on s.id = ph.session_id and s.owner_id = '00000000-0000-0000-0000-000000000001' and s.status = 'live'
join teams t on t.session_id = s.id
where ph.position = 2;
