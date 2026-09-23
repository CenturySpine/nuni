-- The initial associations (plan 18, Q84), approved, with no local manager and no logo yet.
-- Replayed after every schema reconstruction (docs/DEV.md), before the data seed: players and
-- sessions reference these ids. Fixed ids so that reference stays valid across replays; Lyon
-- Street Golf holds the whole history from before plan 18.
-- Position and website from the French associations map of the Federation
-- (streetgolf.fr/federation, public file from nynjas.golf, 2026-09-23); no personal data taken
-- from it. Edits made in the app by a local manager are saved by the data seed, which updates
-- these rows. Without effect if the rows already exist.
insert into associations (id, name, short_name, city, location, website_url, status) values
  ('5a000000-0000-4000-8000-000000000001', 'Lyon Street Golf', 'LSG', 'Lyon',
   'SRID=4326;POINT(4.8459 45.749)', 'https://lyonstreetgolf.fr', 'approved'),
  ('5a000000-0000-4000-8000-000000000002', 'Street Golf à l''Ouest', 'SGO', 'Morlaix',
   'SRID=4326;POINT(-3.82737 48.57749)', 'https://streetgolfalouest.com', 'approved'),
  ('5a000000-0000-4000-8000-000000000003', 'Wild Shrimp Crew', null, 'Grenoble',
   'SRID=4326;POINT(5.72452 45.18852)', null, 'approved'),
  ('5a000000-0000-4000-8000-000000000004', 'Médiéballes', null, 'Laon',
   'SRID=4326;POINT(3.627079 49.55878)', null, 'approved'),
  ('5a000000-0000-4000-8000-000000000005', 'Urban Green Lille', null, 'Lille',
   'SRID=4326;POINT(3.05725 50.62925)', null, 'approved'),
  ('5a000000-0000-4000-8000-000000000006', 'Strasbourg Street Golf', null, 'Strasbourg',
   'SRID=4326;POINT(7.72756 48.5403)', null, 'approved')
on conflict (id) do nothing;
