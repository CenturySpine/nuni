-- Indexes beyond those implied by primary keys and unique constraints (plan 03).
-- sessions.code already has a unique-constraint index; not duplicated here.

create index holes_start_gix on holes using gist (start);
create index session_members_user_id_idx on session_members (user_id);
-- Denormalized session_id columns (Q35, plan 08): not covered by any unique constraint, unlike
-- teams/played_holes' (session_id, position).
create index scores_session_id_idx on scores (session_id);
create index team_players_session_id_idx on team_players (session_id);
-- Championship classement reads (championship_association_results, plan 18), filtered by
-- association and season.
create index sessions_championship_association_season_idx
  on sessions (association_id, championship_season)
  where is_championship;
-- Q78: at most one approved local manager per association; one open claim per person and
-- association.
create unique index association_managers_one_approved_idx
  on association_managers (association_id) where status = 'approved';
create unique index association_managers_one_pending_claim_idx
  on association_managers (association_id, user_id) where status = 'pending';
-- Plan 27: a player's admin rows (is_association_staff, the leave trigger); the primary key
-- already covers the lookup by association.
create index association_admins_player_idx on association_admins (player_id);
-- Q81: one creation request waiting at a time per person.
create unique index associations_one_pending_request_idx
  on associations (created_by) where status = 'pending';
-- Association planning (plan 23): an association's events by date, a thread in order, the
-- sessions started from an event.
create index events_association_starts_at_idx on events (association_id, starts_at);
create index event_comments_event_created_at_idx on event_comments (event_id, created_at);
create index sessions_event_id_idx on sessions (event_id) where event_id is not null;
-- Spots (plan 28): one name per association, ignoring case and surrounding spaces (Q183); the
-- sessions and events of a spot, for its usage count and spots_propagate (triggers.sql).
create unique index spots_association_name_idx on spots (association_id, lower(btrim(name)));
create index sessions_spot_id_idx on sessions (spot_id) where spot_id is not null;
create index events_spot_id_idx on events (spot_id) where spot_id is not null;
