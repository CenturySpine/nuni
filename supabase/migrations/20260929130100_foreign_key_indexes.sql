-- Covering indexes for the foreign keys flagged by the Supabase performance
-- advisor (unindexed_foreign_keys): joins, RLS lookups and cascades on the
-- referenced rows no longer scan the whole referencing table.
create index if not exists association_admins_appointed_by_idx on association_admins (appointed_by);
create index if not exists association_managers_reviewed_by_idx on association_managers (reviewed_by);
create index if not exists association_managers_user_id_idx on association_managers (user_id);
create index if not exists associations_reviewed_by_idx on associations (reviewed_by);
create index if not exists event_comments_author_player_id_idx on event_comments (author_player_id);
create index if not exists event_responses_player_id_idx on event_responses (player_id);
create index if not exists events_created_by_idx on events (created_by);
create index if not exists events_manager_player_id_idx on events (manager_player_id);
create index if not exists holes_cloned_from_idx on holes (cloned_from);
create index if not exists holes_owner_id_idx on holes (owner_id);
create index if not exists played_holes_hole_id_idx on played_holes (hole_id);
create index if not exists players_association_id_idx on players (association_id);
create index if not exists players_created_by_idx on players (created_by);
create index if not exists scores_team_id_idx on scores (team_id);
create index if not exists scores_updated_by_idx on scores (updated_by);
create index if not exists session_members_team_id_idx on session_members (team_id);
create index if not exists session_photos_session_id_idx on session_photos (session_id);
create index if not exists session_photos_uploaded_by_idx on session_photos (uploaded_by);
create index if not exists sessions_cover_photo_id_idx on sessions (cover_photo_id);
create index if not exists sessions_owner_id_idx on sessions (owner_id);
create index if not exists spots_created_by_idx on spots (created_by);
create index if not exists team_players_player_id_idx on team_players (player_id);
