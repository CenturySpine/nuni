-- Plan 37, the PO's requests after trying it (Q270, Q271). Nothing here changes or deletes
-- existing data.

-- Q270: a session created without "Draft" may become one later, but only while it is still in
-- its waiting room and linked to no event (Q257: an event's session stays visible to its
-- attendees). Replaces the "published for good" guard of 20261007081311_session_drafts.sql,
-- whose trigger (old.published and not new.published) is unchanged. Publishing still only goes
-- through publish_session (Q256). No signed-in caller (SQL editor, seed replay): anything goes.
create or replace function sessions_guard_published()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.uid() is not null and (old.status <> 'draft' or old.event_id is not null) then
    raise exception 'cannot_unpublish' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

-- Q271: co-organizers are named and their role taken back by the organizers
-- (session_members_owner_update, unchanged), whether they have joined or not -- but the
-- session's creator always stays an organizer. No signed-in caller: anything goes.
create or replace function session_members_guard_creator()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.uid() is not null
    and exists (
      select 1 from sessions where id = old.session_id and owner_id = old.user_id
    ) then
    raise exception 'creator_stays_organizer' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger session_members_guard_creator_trigger
  before update of role on session_members
  for each row
  when (old.role = 'owner' and new.role <> 'owner')
  execute function session_members_guard_creator();

revoke execute on function session_members_guard_creator() from public, authenticated;
