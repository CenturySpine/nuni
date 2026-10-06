-- Archive of deleted completed sessions (plan 36, Q244 to Q248): a safety net against an accident,
-- invisible in the app. Deleting a completed session first copies it, with the rows of its six
-- tables, into session_archives; restore_session_archive puts it back, by hand, from the Supabase
-- SQL editor (docs/DEV.md). A draft or live session is still deleted for good (Q245). Nothing here
-- changes or deletes existing data.

-- One row per deleted completed session, kept indefinitely (Q248). No foreign key: the session is
-- gone, and its owner or deleter may follow. Private, like legacy_player_emails and
-- push_subscriptions: no policy and no grant to anon or authenticated, super_admins included;
-- read only by the encrypted data seed export (service_role, tool/export_remote_seed.dart).
create table session_archives (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null,
  deleted_at timestamptz not null default now(),
  -- The account that deleted it; null for a deletion outside the app (SQL editor).
  deleted_by uuid,
  -- Every column of every row: {"session": {...}, "teams": [...], "team_players": [...],
  -- "session_members": [...], "played_holes": [...], "scores": [...], "session_photos": [...]}.
  data jsonb not null
);

alter table session_archives enable row level security;
revoke all on session_archives from anon, authenticated, service_role;
grant select on session_archives to service_role;

-- Before the delete, hence before its cascade: the related rows still exist. Same transaction as
-- the delete, so a failed delete leaves no archive. security definer: it reads every related row
-- and writes a closed table, whichever organizer deletes. In the base, so it covers every way of
-- deleting: the app's four screens, an SQL query, a future account deletion (Q28).
create or replace function sessions_archive_completed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into session_archives (session_id, deleted_by, data)
  values (
    old.id,
    auth.uid(),
    jsonb_build_object(
      -- The point as text, which the geography type reads back as is.
      'session', to_jsonb(old) || jsonb_build_object('location', old.location::text),
      'teams', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from teams r where r.session_id = old.id),
      'team_players',
        (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from team_players r where r.session_id = old.id),
      'session_members',
        (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from session_members r where r.session_id = old.id),
      'played_holes',
        (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from played_holes r where r.session_id = old.id),
      'scores', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from scores r where r.session_id = old.id),
      'session_photos',
        (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from session_photos r where r.session_id = old.id)
    )
  );
  return old;
end;
$$;

create trigger sessions_archive_completed_trigger
  before delete on sessions
  for each row
  when (old.status = 'completed')
  execute function sessions_archive_completed();

-- Inserts archived rows back into their table. Columns are read from the table, not listed here:
-- those the archive holds and the table still has, except the ones the base computes
-- (location_lat, location_lng). An archive taken before a later migration thus restores into the
-- new schema, an added column taking its default.
create or replace function _restore_archived_rows(
  p_table text,
  p_rows jsonb,
  p_skip_existing boolean default false
)
returns void
language plpgsql
set search_path = public
as $$
declare
  v_columns text;
begin
  if coalesce(jsonb_array_length(p_rows), 0) = 0 then
    return;
  end if;
  select string_agg(quote_ident(a.attname), ', ' order by a.attnum) into v_columns
  from pg_attribute a
  where a.attrelid = format('public.%I', p_table)::regclass
    and a.attnum > 0
    and not a.attisdropped
    and a.attgenerated = ''
    and (p_rows -> 0) ? a.attname;
  execute format(
    'insert into public.%I (%s) select %s from jsonb_populate_recordset(null::public.%I, $1)%s',
    p_table, v_columns, v_columns, p_table,
    case when p_skip_existing then ' on conflict do nothing' else '' end
  ) using p_rows;
end;
$$;

-- Puts a deleted completed session back as it was, for all its participants (Q246): run by hand
-- by the database administrator (SQL editor, or npx supabase db query --linked), never by the app.
-- With no signed-in caller, the triggers keep the values given (association, code, championship,
-- natures, check-ins), as for a seed replay, and no notification goes out. One call, one
-- transaction: on any error nothing is kept and the archive stays. Returns what had to change.
--   Settled: a code given to another session meanwhile (a new one is drawn), an event gone or
--   with another session meanwhile (one per event, Q223), a spot gone (zone and city keep the
--   place's name, Q182): the session comes back without the link.
--   Refused: a hole, account, player or the association gone meanwhile, the message naming it.
create or replace function restore_session_archive(p_session_id uuid)
returns jsonb
language plpgsql
set search_path = public
as $$
declare
  v_archive session_archives;
  v_session jsonb;
  v_new_code boolean := false;
  v_event_unlinked boolean := false;
  v_spot_unlinked boolean := false;
  v_missing text;
begin
  select * into v_archive
  from session_archives
  where session_id = p_session_id
  order by deleted_at desc
  limit 1;
  if not found then
    raise exception 'archive_not_found' using errcode = 'P0001';
  end if;
  if exists (select 1 from sessions where id = p_session_id) then
    raise exception 'session_exists' using errcode = 'P0001';
  end if;

  -- The cover photo is set once the photos are back (foreign key).
  v_session := (v_archive.data -> 'session') || '{"cover_photo_id": null}';

  if exists (select 1 from sessions where code = v_session ->> 'code') then
    -- sessions_set_code draws a new one.
    v_session := v_session || '{"code": null}';
    v_new_code := true;
  end if;
  if (v_session ->> 'event_id') is not null and (
    not exists (select 1 from events where id = (v_session ->> 'event_id')::uuid)
    or exists (select 1 from sessions where event_id = (v_session ->> 'event_id')::uuid)
  ) then
    v_session := v_session || '{"event_id": null}';
    v_event_unlinked := true;
  end if;
  if (v_session ->> 'spot_id') is not null
    and not exists (select 1 from spots where id = (v_session ->> 'spot_id')::uuid) then
    v_session := v_session || '{"spot_id": null}';
    v_spot_unlinked := true;
  end if;

  begin
    perform _restore_archived_rows('sessions', jsonb_build_array(v_session));
    perform _restore_archived_rows('teams', v_archive.data -> 'teams');
    perform _restore_archived_rows('session_members', v_archive.data -> 'session_members');
    -- Already back for a session without scores: session_members_sync_attendance recreated them
    -- from its attendees.
    perform _restore_archived_rows('team_players', v_archive.data -> 'team_players', true);
    perform _restore_archived_rows('played_holes', v_archive.data -> 'played_holes');
    perform _restore_archived_rows('scores', v_archive.data -> 'scores');
    perform _restore_archived_rows('session_photos', v_archive.data -> 'session_photos');
  exception when foreign_key_violation then
    -- E.g. 'Key (hole_id)=(...) is not present in table "holes".'
    get stacked diagnostics v_missing = pg_exception_detail;
    raise exception 'restore_refused: %', v_missing using errcode = 'P0001';
  end;

  update sessions
  set cover_photo_id = (v_archive.data -> 'session' ->> 'cover_photo_id')::uuid
  where id = p_session_id;
  delete from session_archives where id = v_archive.id;

  return jsonb_build_object(
    'session_id', p_session_id,
    'code', (select code from sessions where id = p_session_id),
    'new_code', v_new_code,
    'event_unlinked', v_event_unlinked,
    'spot_unlinked', v_spot_unlinked
  );
end;
$$;

-- Postgres and Supabase's default privileges grant EXECUTE at creation: none of these is for the
-- app, and the restore is for the database administrator only.
revoke execute on function sessions_archive_completed() from public, anon, authenticated;
revoke execute on function _restore_archived_rows(text, jsonb, boolean)
  from public, anon, authenticated, service_role;
revoke execute on function restore_session_archive(uuid)
  from public, anon, authenticated, service_role;
