-- Backfills a "players" row for every existing auth.users row that doesn't
-- have one, mirroring handle_new_user() (20260915100500_triggers.sql)
-- exactly. Required after every schema reconstruction (AGENTS.md point 8,
-- docs/DEV.md): the trigger only fires on new auth.users inserts, not
-- retroactively, so an account that signed up before the reconstruction
-- loses its linked player the moment "players" is dropped and recreated.
-- Idempotent: only inserts for a user_id with no existing row.
insert into players (name, avatar_url, locale, created_by, user_id)
select
  coalesce(
    u.raw_user_meta_data ->> 'full_name',
    u.raw_user_meta_data ->> 'name',
    split_part(u.email, '@', 1)
  ),
  u.raw_user_meta_data ->> 'avatar_url',
  coalesce(left(u.raw_user_meta_data ->> 'locale', 2), 'fr'),
  u.id,
  u.id
from auth.users u
where not exists (select 1 from players p where p.user_id = u.id);
