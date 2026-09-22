-- Remote seed data: the PO's own test holes on the real "nuni" project
-- (captured 2026-09-16, refreshed 2026-09-18, refreshed again 2026-09-22 --
-- added 4 holes created since the previous refresh and the "path" waypoints
-- and "distance_m" columns, absent from the file until now), replayed after
-- a schema reconstruction (AGENTS.md point 8, docs/DEV.md) so they come back
-- without re-creating or re-uploading anything -- their photos already sit
-- in the "holes" storage bucket, which a reconstruction never touches (only
-- the schema is rebuilt).
--
-- Distinct from supabase/seed.sql: that file is local-Docker-only dev
-- fixture data (fake auth.users, never applied to the remote project). This
-- one is remote-only, applied by hand (not wired into supabase/config.toml's
-- "db.seed", which only fires on "db reset" against a local Postgres this
-- project doesn't have) -- see docs/DEV.md.
--
-- Owner is the PO's own auth.users row, untouched by a reconstruction (only
-- the public schema is rebuilt), so this id stays valid across replays.

insert into holes (
  id, owner_id, name, description, par, distance_m, start, end_point, path,
  photo_start_path, photo_end_path, visibility
) values
  (
    '06087cb2-ad31-4a39-b4d3-1a6a0ee7d2f4',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'The pitt',
    null,
    3,
    78,
    'SRID=4326;POINT(4.876858426222355 45.7831520708852)',
    'SRID=4326;POINT(4.87635171881572 45.7837527893506)',
    null,
    '667e1434-75e2-4eb7-b122-ed8681905cea/06087cb2-ad31-4a39-b4d3-1a6a0ee7d2f4/start.jpg',
    '667e1434-75e2-4eb7-b122-ed8681905cea/06087cb2-ad31-4a39-b4d3-1a6a0ee7d2f4/end.jpg',
    'public'
  ),
  (
    'daaed027-d844-48de-a558-a9d966a2e6f2',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'Radioactive',
    null,
    3,
    62,
    'SRID=4326;POINT(4.875039049667782 45.783600291649165)',
    'SRID=4326;POINT(4.8753618197528 45.7830861738637)',
    null,
    '667e1434-75e2-4eb7-b122-ed8681905cea/daaed027-d844-48de-a558-a9d966a2e6f2/start.jpg',
    '667e1434-75e2-4eb7-b122-ed8681905cea/daaed027-d844-48de-a558-a9d966a2e6f2/end.jpg',
    'public'
  ),
  (
    '2f00c11c-e17a-47db-a4a8-bfebcc5876dc',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'Fireman',
    'Cible : la borne incendie au coin du bâtiment.',
    5,
    96,
    'SRID=4326;POINT(4.8746818096186 45.7829806944945)',
    'SRID=4326;POINT(4.87394148037389 45.7835148886843)',
    '[{"lat":45.783343229221856,"lng":4.873883638692008},{"lat":45.78350923597959,"lng":4.873903084707325}]',
    null,
    '667e1434-75e2-4eb7-b122-ed8681905cea/2f00c11c-e17a-47db-a4a8-bfebcc5876dc/end.jpg',
    'public'
  ),
  (
    '34dbccbc-d93b-4236-98c1-14c2445c7a05',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'Bonsaï /Lippman',
    'Partie haute du petit lampadaire',
    4,
    78,
    'SRID=4326;POINT(4.867558956328733 45.78173645048707)',
    'SRID=4326;POINT(4.86766861064648 45.7821855570447)',
    '[{"lat":45.78198027404653,"lng":4.867235082976916}]',
    null,
    null,
    'public'
  ),
  (
    'a669b6df-ad02-47f1-9109-cdaff47e6184',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'Rhino',
    'Départ sous la caméra',
    5,
    92,
    'SRID=4326;POINT(4.87382337716388 45.783434261894755)',
    'SRID=4326;POINT(4.8747574981562 45.7833642213676)',
    '[{"lat":45.78327958212272,"lng":4.874090922964235},{"lat":45.783460085427734,"lng":4.874729288709779}]',
    '667e1434-75e2-4eb7-b122-ed8681905cea/1789718803051000-109432351/start.jpg',
    '667e1434-75e2-4eb7-b122-ed8681905cea/1789718803051000-109432351/end.jpg',
    'public'
  ),
  (
    'e29b8ed3-7308-44b0-9fad-37f58f15954b',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'Cryo',
    null,
    5,
    90,
    'SRID=4326;POINT(4.867228447589157 45.782218234613964)',
    'SRID=4326;POINT(4.867825239094969 45.78255867171052)',
    '[{"lat":45.78238137171374,"lng":4.867890406950802},{"lat":45.78259961135625,"lng":4.867748161337153}]',
    null,
    null,
    'public'
  ),
  (
    '99591ec1-4910-494a-a675-366440c9d437',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'Touch my ball',
    null,
    3,
    90,
    'SRID=4326;POINT(4.876139852754907 45.78331142732143)',
    'SRID=4326;POINT(4.876914366780222 45.78391210294158)',
    null,
    null,
    null,
    'public'
  ),
  (
    '40a1adc2-b3de-4a82-a174-b76c255c0085',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'L''arche perdue',
    'Cible: passer sous l''arche attache vélo la plus à droite quand on regarde le batiment',
    5,
    88,
    'SRID=4326;POINT(4.875084453810908 45.78302905232422)',
    'SRID=4326;POINT(4.875628780359423 45.783590515153044)',
    '[{"lat":45.78344185440675,"lng":4.875444846860191},{"lat":45.78360458750863,"lng":4.875710385552666}]',
    null,
    null,
    'public'
  ),
  (
    '832d5ce4-1119-4e21-96f4-1f40c48bb98b',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'The cage',
    'Départ sur les dalles blanches
cible: la cage métallique rouillée.
Hors zone:
- Transformateur grillagé
- Plantes autour de la cage',
    3,
    80,
    'SRID=4326;POINT(4.874779884646659 45.78356145409582)',
    'SRID=4326;POINT(4.874679761042212 45.782847910910185)',
    null,
    null,
    null,
    'public'
  )
on conflict (id) do nothing;
