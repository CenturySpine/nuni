-- Remote seed data: the PO's own test holes on the real "nuni" project
-- (captured 2026-09-16), replayed after a schema reconstruction (AGENTS.md
-- point 8, docs/DEV.md) so they come back without re-creating or
-- re-uploading anything -- their photos already sit in the "holes" storage
-- bucket, which a reconstruction never touches (only the schema is rebuilt).
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
  id, owner_id, name, description, par, distance_m, start, end_point,
  photo_start_path, photo_end_path, visibility
) values
  (
    '06087cb2-ad31-4a39-b4d3-1a6a0ee7d2f4',
    '667e1434-75e2-4eb7-b122-ed8681905cea',
    'The pitt',
    null,
    3,
    null,
    'SRID=4326;POINT(4.8768488642246 45.7831346172624)',
    'SRID=4326;POINT(4.87635171881572 45.7837527893506)',
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
    null,
    'SRID=4326;POINT(4.87501595915676 45.7836064391064)',
    'SRID=4326;POINT(4.8753618197528 45.7830861738637)',
    '667e1434-75e2-4eb7-b122-ed8681905cea/daaed027-d844-48de-a558-a9d966a2e6f2/start.jpg',
    '667e1434-75e2-4eb7-b122-ed8681905cea/daaed027-d844-48de-a558-a9d966a2e6f2/end.jpg',
    'public'
  )
on conflict (id) do nothing;
