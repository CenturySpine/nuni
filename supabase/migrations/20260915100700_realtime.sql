-- Realtime publication (plan 03): only the tables a live session screen subscribes to (plan 08).

alter publication supabase_realtime add table sessions;
alter publication supabase_realtime add table teams;
alter publication supabase_realtime add table team_players;
alter publication supabase_realtime add table session_members;
alter publication supabase_realtime add table played_holes;
alter publication supabase_realtime add table scores;

-- A client subscribes to `teams`/`played_holes` filtered by `session_id`
-- (plan 07/08), but neither table's primary key is `session_id` (it's a
-- standalone `id`). With the default replica identity, a DELETE's "old
-- row" only carries primary-key columns, so Realtime can't evaluate a
-- `session_id` filter for it and silently drops the event -- found in
-- testing (plan 07): deleting a team never reached the waiting room, which
-- kept showing it, empty, until a manual reload. `scores` and
-- `session_members` don't need this: `session_id`/`played_hole_id` are
-- already part of their primary key, so the default identity already
-- includes them on delete.
alter table teams replica identity full;
alter table played_holes replica identity full;
