-- Indexes beyond those implied by primary keys and unique constraints (plan 03).
-- sessions.code already has a unique-constraint index; not duplicated here.

create index holes_start_gix on holes using gist (start);
create index session_members_user_id_idx on session_members (user_id);
-- Denormalized session_id columns (Q35, plan 08): not covered by any unique constraint, unlike
-- teams/played_holes' (session_id, position).
create index scores_session_id_idx on scores (session_id);
create index team_players_session_id_idx on team_players (session_id);
