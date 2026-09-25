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
-- kept showing it, empty, until a manual reload. `session_members` doesn't
-- need this: `session_id` is already part of its primary key, so the
-- default identity already includes it on delete. `scores` and
-- `team_players` are the same case as teams/played_holes: their new
-- `session_id` column (Q35, plan 08) isn't part of their primary key
-- either, so a DELETE's old-row image needs the same widening.
alter table teams replica identity full;
alter table played_holes replica identity full;
alter table scores replica identity full;
alter table team_players replica identity full;

-- An event's open detail page follows its comment thread live (plan 23, Q166), subscribed
-- filtered by event_id -- same widening as above, so a deleted comment reaches it too.
alter publication supabase_realtime add table event_comments;
alter table event_comments replica identity full;
