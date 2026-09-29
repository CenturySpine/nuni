-- One session per event (PO, 2026-09-29): the first person allowed to start the event's session
-- does so; from then on everyone, managers included, joins it by its code or QR code. Once that
-- session is deleted, the event may be started again. Completed, it stays the event's session.

-- The guard of sessions_guard_event (triggers.sql), plus the refusal of a second session.
create or replace function sessions_guard_event()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_previous uuid := case when tg_op = 'INSERT' then null else old.event_id end;
begin
  if new.event_id is not null
    and new.event_id is distinct from v_previous
    and auth.uid() is not null
    and not exists (
      select 1
      from events e
      left join players p on p.id = e.manager_player_id
      where e.id = new.event_id
        and e.association_id = new.association_id
        and e.starts_at between now() - interval '24 hours' and now() + interval '24 hours'
        and (
          p.user_id = auth.uid()
          or is_association_staff(e.association_id)
          or is_super_admin()
        )
    ) then
    raise exception 'event_not_startable' using errcode = 'P0001';
  end if;

  if new.event_id is not null
    and new.event_id is distinct from v_previous
    and exists (select 1 from sessions where event_id = new.event_id and id <> new.id) then
    raise exception 'event_has_session' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

-- The same rule, held even by two people starting the session at the same instant.
create unique index sessions_event_id_key on sessions (event_id) where event_id is not null;

-- The event's session as the caller may know it (PO, 2026-09-29), or no row without one: its
-- status and whether the caller is in it. A session still in its waiting room is invisible to
-- non-members (can_read_session), hence this security definer function; it tells nothing more,
-- and only to the event's association members. Replaces event_has_joinable_session.
create or replace function event_session(p_event_id uuid)
returns table (status session_status, is_member boolean)
language sql
security definer
set search_path = public
stable
as $$
  select s.status, is_session_member(s.id)
  from sessions s
  join events e on e.id = s.event_id
  where s.event_id = p_event_id
    and (is_association_member(e.association_id) or is_super_admin());
$$;

revoke execute on function event_session(uuid) from public;
grant execute on function event_session(uuid) to authenticated;

drop function if exists event_has_joinable_session(uuid);
