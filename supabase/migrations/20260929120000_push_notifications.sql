-- Planning notifications (plan 33). Standard Web Push, no third party (Q224): each device the
-- user allowed stores its push subscription here; database triggers pick the recipients of each
-- planning action and hand them to the send-push Edge Function (supabase/functions/send-push),
-- which writes the text in each device's app language (Q230) and delivers it through the
-- browser's push service. Nothing here changes or deletes existing data.

-- HTTP calls from the database, sent by a background worker once the transaction commits: a
-- rolled back write notifies nobody, and a failed send never fails the player's action.
create extension if not exists pg_net with schema extensions;

-- One row per device (endpoint = the browser's push address). Read-only for the app: written
-- through save_push_subscription / delete_push_subscription below, so a device used by another
-- account afterwards simply moves to that account.
create table push_subscriptions (
  endpoint text primary key check (endpoint like 'https://%'),
  user_id uuid not null references auth.users (id) on delete cascade,
  p256dh text not null,
  auth text not null,
  -- The language the app shows on this device (Q230), not the system's.
  locale text not null default 'fr' check (locale in ('fr', 'en')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index push_subscriptions_user_id_idx on push_subscriptions (user_id);

alter table push_subscriptions enable row level security;
-- No policy and no grant to authenticated: the functions below are the only way in.

-- Registers (or refreshes) this device's subscription for the caller.
create or replace function save_push_subscription(
  p_endpoint text,
  p_p256dh text,
  p_auth text,
  p_locale text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;

  insert into push_subscriptions (endpoint, user_id, p256dh, auth, locale)
  values (
    p_endpoint, auth.uid(), p_p256dh, p_auth,
    case when p_locale = 'en' then 'en' else 'fr' end
  )
  on conflict (endpoint) do update
    set user_id = excluded.user_id,
        p256dh = excluded.p256dh,
        auth = excluded.auth,
        locale = excluded.locale,
        updated_at = now();
end;
$$;

-- Forgets this device (switch turned off, sign-out). Only the caller's own row.
create or replace function delete_push_subscription(p_endpoint text)
returns void
language sql
security definer
set search_path = public
as $$
  delete from push_subscriptions where endpoint = p_endpoint and user_id = auth.uid();
$$;

revoke execute on function save_push_subscription(text, text, text, text) from public, anon;
revoke execute on function delete_push_subscription(text) from public, anon;
grant execute on function save_push_subscription(text, text, text, text) to authenticated;
grant execute on function delete_push_subscription(text) to authenticated;

-- ---------------------------------------------------------------------------------------------
-- Recipients, one function per rule (plan 33), each returning account ids. Every recipient is
-- still a member of the event's association (an ex-member can't read the event any more), and
-- the author of the action is never among them.
-- ---------------------------------------------------------------------------------------------

-- A player's answer changed: the event's person in charge, if any (Q227).
create or replace function _response_notification_recipients(p_event_id uuid, p_player_id uuid)
returns uuid[]
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(array_agg(m.user_id), '{}')
  from events e
  join players m on m.id = e.manager_player_id
  where e.id = p_event_id
    and m.user_id is not null
    and m.association_id = e.association_id
    and m.id <> p_player_id;
$$;

-- A new comment: the person in charge and the players who answered present or maybe.
create or replace function _comment_notification_recipients(p_event_id uuid, p_author_player_id uuid)
returns uuid[]
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(array_agg(distinct p.user_id), '{}')
  from events e
  join players p on p.association_id = e.association_id
  where e.id = p_event_id
    and p.user_id is not null
    and p.id <> p_author_player_id
    and (
      p.id = e.manager_player_id
      or exists (
        select 1 from event_responses r
        where r.event_id = e.id and r.player_id = p.id and r.response in ('yes', 'maybe')
      )
    );
$$;

-- The event's session started: the players who answered present, except who started it.
create or replace function _session_start_notification_recipients(p_event_id uuid, p_starter uuid)
returns uuid[]
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(array_agg(p.user_id), '{}')
  from events e
  join event_responses r on r.event_id = e.id and r.response = 'yes'
  join players p on p.id = r.player_id and p.association_id = e.association_id
  where e.id = p_event_id
    and p.user_id is not null
    and p.user_id is distinct from p_starter;
$$;

-- A new event: every member of its association but its creator.
create or replace function _new_event_notification_recipients(p_event_id uuid)
returns uuid[]
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(array_agg(p.user_id), '{}')
  from events e
  join players p on p.association_id = e.association_id
  where e.id = p_event_id
    and p.user_id is not null
    and p.user_id <> e.created_by;
$$;

-- ---------------------------------------------------------------------------------------------
-- Sending. The function's address and its call secret live in Supabase Vault (secrets named
-- push_function_url and push_function_secret, set once by the PO, docs/DEV.md), never in this
-- public repository. Without them, or without any subscribed recipient, nothing is sent.
-- ---------------------------------------------------------------------------------------------

-- The event fields every notification shows, plus the kind and the author's name.
create or replace function _notification_payload(p_kind text, p_event_id uuid, p_actor_player_id uuid)
returns jsonb
language sql
security definer
set search_path = public
stable
as $$
  select jsonb_build_object(
    'kind', p_kind,
    'event_id', e.id,
    'event_label', e.label,
    'starts_at', e.starts_at,
    'place', e.spot,
    'actor', (select name from players where id = p_actor_player_id)
  )
  from events e
  where e.id = p_event_id;
$$;

create or replace function _notify(p_user_ids uuid[], p_payload jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_url text;
  v_secret text;
begin
  if p_payload is null
    or not exists (select 1 from push_subscriptions where user_id = any(p_user_ids)) then
    return;
  end if;

  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'push_function_url';
  select decrypted_secret into v_secret from vault.decrypted_secrets where name = 'push_function_secret';
  if v_url is null or v_secret is null then
    return;
  end if;

  perform net.http_post(
    url := v_url,
    body := p_payload || jsonb_build_object('user_ids', to_jsonb(p_user_ids)),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-push-secret', v_secret
    )
  );
exception when others then
  -- A notification is a courtesy: whatever goes wrong here, the player's action goes through.
  raise warning 'push notification skipped: %', sqlerrm;
end;
$$;

-- ---------------------------------------------------------------------------------------------
-- Triggers. A cascade from a deleted event (or player) finds no event any more: no payload,
-- nothing sent -- e.g. an import replacing its events to come, whose answers go with them.
-- ---------------------------------------------------------------------------------------------

-- An answer set for the first time, changed, or withdrawn (Q226).
create or replace function event_responses_notify()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event_id uuid := case when tg_op = 'DELETE' then old.event_id else new.event_id end;
  v_player_id uuid := case when tg_op = 'DELETE' then old.player_id else new.player_id end;
  v_response text := case when tg_op = 'DELETE' then null else new.response::text end;
begin
  if tg_op = 'UPDATE' and new.response = old.response then
    return null;
  end if;

  perform _notify(
    _response_notification_recipients(v_event_id, v_player_id),
    _notification_payload('response', v_event_id, v_player_id)
      || jsonb_build_object('response', v_response, 'player_id', v_player_id)
  );
  return null;
end;
$$;

create trigger event_responses_notify_trigger
  after insert or update or delete on event_responses
  for each row execute function event_responses_notify();

-- A new comment; edits and deletions notify nobody (Q228).
create or replace function event_comments_notify()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform _notify(
    _comment_notification_recipients(new.event_id, new.author_player_id),
    _notification_payload('comment', new.event_id, new.author_player_id)
      || jsonb_build_object('excerpt', left(new.body, 100))
  );
  return null;
end;
$$;

create trigger event_comments_notify_trigger
  after insert on event_comments
  for each row execute function event_comments_notify();

-- The event's session goes from its waiting room to live.
create or replace function sessions_notify_event_start()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.event_id is not null and old.status = 'draft' and new.status = 'live' then
    perform _notify(
      _session_start_notification_recipients(new.event_id, auth.uid()),
      _notification_payload(
        'session_started', new.event_id,
        (select id from players where user_id = auth.uid())
      )
    );
  end if;
  return null;
end;
$$;

create trigger sessions_notify_event_start_trigger
  after update of status on sessions
  for each row execute function sessions_notify_event_start();

-- A new event saved in the app (Q229): only 'manual' ones, so an import of any size never
-- notifies, and only one still to come (Q236). Later edits notify nobody.
create or replace function events_notify_new()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.origin = 'manual' and new.starts_at > now() then
    perform _notify(
      _new_event_notification_recipients(new.id),
      _notification_payload(
        'new_event', new.id,
        (select id from players where user_id = new.created_by)
      )
    );
  end if;
  return null;
end;
$$;

create trigger events_notify_new_trigger
  after insert on events
  for each row execute function events_notify_new();

-- Internal helpers: never callable from the app.
revoke execute on function _response_notification_recipients(uuid, uuid) from public, anon, authenticated;
revoke execute on function _comment_notification_recipients(uuid, uuid) from public, anon, authenticated;
revoke execute on function _session_start_notification_recipients(uuid, uuid) from public, anon, authenticated;
revoke execute on function _new_event_notification_recipients(uuid) from public, anon, authenticated;
revoke execute on function _notification_payload(text, uuid, uuid) from public, anon, authenticated;
revoke execute on function _notify(uuid[], jsonb) from public, anon, authenticated;
revoke execute on function event_responses_notify() from public, anon, authenticated;
revoke execute on function event_comments_notify() from public, anon, authenticated;
revoke execute on function sessions_notify_event_start() from public, anon, authenticated;
revoke execute on function events_notify_new() from public, anon, authenticated;

-- The Edge Function reads the subscriptions with the service role.
grant select, delete on push_subscriptions to service_role;
