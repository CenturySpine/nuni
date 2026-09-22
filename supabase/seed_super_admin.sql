-- Mandatory post-reconstruction seed (plan 16), unlike supabase/remote_seed.sql which is
-- optional test data. "user_roles" lives in the "public" schema, so a schema reconstruction
-- (AGENTS.md point 8) wipes it like "players" -- without replaying this script, nobody has the
-- "super_admin" role after a reconstruction. Idempotent ("on conflict do nothing"), run with the
-- service key (npx supabase db query --linked), right after supabase/backfill_players.sql -- see
-- docs/DEV.md.
--
-- Owner is the PO's own auth.users row (bruno.chappe@gmail.com), untouched by a reconstruction
-- (only the public schema is rebuilt), so this id stays valid across replays.

insert into user_roles (user_id, role)
values ('667e1434-75e2-4eb7-b122-ed8681905cea', 'super_admin')
on conflict (user_id) do nothing;
