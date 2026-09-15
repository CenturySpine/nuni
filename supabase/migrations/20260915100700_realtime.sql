-- Realtime publication (plan 03): only the tables a live session screen subscribes to (plan 08).

alter publication supabase_realtime add table sessions;
alter publication supabase_realtime add table teams;
alter publication supabase_realtime add table team_players;
alter publication supabase_realtime add table session_members;
alter publication supabase_realtime add table played_holes;
alter publication supabase_realtime add table scores;
