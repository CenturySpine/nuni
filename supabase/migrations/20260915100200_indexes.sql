-- Indexes beyond those implied by primary keys and unique constraints (plan 03).
-- sessions.code already has a unique-constraint index; not duplicated here.

create index holes_start_gix on holes using gist (start);
create index session_members_user_id_idx on session_members (user_id);
-- Denormalized session_id columns (Q35, plan 08): not covered by any unique constraint, unlike
-- teams/played_holes' (session_id, position).
create index scores_session_id_idx on scores (session_id);
create index team_players_session_id_idx on team_players (session_id);
-- Championship zone assignment (plan 15): only championship-tagged sessions are ever searched by
-- proximity (assign_championship_zone), a small and stable subset of all sessions.
create index sessions_championship_location_idx on sessions using gist (location)
  where is_championship;
-- Championship classement reads (championship_zone_results), filtered by zone and season.
create index sessions_championship_zone_season_idx
  on sessions (championship_zone_id, championship_season);
