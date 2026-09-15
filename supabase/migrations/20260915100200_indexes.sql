-- Indexes beyond those implied by primary keys and unique constraints (plan 03).
-- sessions.code already has a unique-constraint index; not duplicated here.

create index holes_start_gix on holes using gist (start);
create index session_members_user_id_idx on session_members (user_id);
