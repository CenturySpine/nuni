-- Triggers (plan 03).

-- Linked player created at sign-up (Q24): no client-side onboarding, no "claim" flow. No
-- separate profile row -- players is the account-facing table too (2026-09-16).
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_display_name text;
  v_avatar_url text;
  v_locale text;
  v_legacy_player_id uuid;
begin
  v_display_name := coalesce(
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'name',
    split_part(new.email, '@', 1)
  );
  v_avatar_url := new.raw_user_meta_data ->> 'avatar_url';
  v_locale := coalesce(left(new.raw_user_meta_data ->> 'locale', 2), 'fr');

  -- A player imported from LsgScores with this e-mail (plan 13, Q64): the new account takes
  -- over that player (its name and photo stay as imported, editable in the profile) instead of
  -- getting a second one, and joins every imported session that player played in, on their team.
  select lpe.player_id into v_legacy_player_id
  from legacy_player_emails lpe
  join players p on p.id = lpe.player_id
  where lpe.email = lower(new.email)
    and p.user_id is null;

  if v_legacy_player_id is not null then
    update players set user_id = new.id, locale = v_locale where id = v_legacy_player_id;
    insert into session_members (session_id, user_id, team_id, role)
    select tp.session_id, new.id, tp.team_id, 'player'
    from team_players tp
    where tp.player_id = v_legacy_player_id
    on conflict (session_id, user_id) do nothing;
    delete from legacy_player_emails where player_id = v_legacy_player_id;
    return new;
  end if;

  insert into players (name, avatar_url, locale, created_by, user_id)
  values (v_display_name, v_avatar_url, v_locale, new.id, new.id);

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- updated_at maintenance.
create or replace function set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger holes_set_updated_at
  before update on holes
  for each row execute function set_updated_at();

create trigger scores_set_updated_at
  before update on scores
  for each row execute function set_updated_at();

-- Session code generation: 6 characters, A-Z/2-9 without ambiguous glyphs (0/O, 1/I).
create or replace function generate_session_code()
returns text
language plpgsql
set search_path = public
as $$
declare
  v_chars text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  v_code text;
  v_exists boolean;
begin
  loop
    v_code := '';
    for i in 1..6 loop
      v_code := v_code || substr(v_chars, floor(random() * length(v_chars) + 1)::int, 1);
    end loop;
    select exists (select 1 from sessions where code = v_code) into v_exists;
    exit when not v_exists;
  end loop;
  return v_code;
end;
$$;

create or replace function sessions_set_code()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.code is null then
    new.code := generate_session_code();
  end if;
  return new;
end;
$$;

create trigger sessions_set_code_trigger
  before insert on sessions
  for each row execute function sessions_set_code();

-- Guard: a player cannot be on two teams of the same session.
create or replace function team_players_guard_single_team()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_session_id uuid;
  v_conflict boolean;
begin
  select session_id into v_session_id from teams where id = new.team_id;

  select exists (
    select 1
    from team_players tp
    join teams t on t.id = tp.team_id
    where tp.player_id = new.player_id
      and t.session_id = v_session_id
      and tp.team_id <> new.team_id
  ) into v_conflict;

  if v_conflict then
    raise exception 'player_already_in_another_team' using errcode = 'P0001';
  end if;

  return new;
end;
$$;

create trigger team_players_guard_single_team_trigger
  before insert on team_players
  for each row execute function team_players_guard_single_team();

-- Guard: teams are frozen once the session has left draft (Q15), regardless of who updates
-- session_members (owner update policy allows role changes, e.g. promoting a co-organizer,
-- after the session has gone live).
create or replace function session_members_guard_frozen_teams()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_status session_status;
  v_scoring scoring_mode;
begin
  if new.team_id is distinct from old.team_id then
    select status, scoring_mode into v_status, v_scoring from sessions where id = new.session_id;
    -- A session without scores (plan 29) has no teams to freeze: its single team is its list of
    -- attendees, editable while it isn't completed (session_members_owner_update).
    if v_status <> 'draft' and v_scoring is not null then
      raise exception 'teams_frozen_after_start' using errcode = 'P0001';
    end if;
  end if;
  return new;
end;
$$;

create trigger session_members_guard_frozen_teams_trigger
  before update on session_members
  for each row execute function session_members_guard_frozen_teams();

-- Attendees of a session without scores (plan 29, Q194): the players of its single team, created
-- with the session (create_session). Whoever joins it -- added by the organizer, by code, from
-- the event's "present" answers, or the organizer themself at creation -- is placed on that team
-- straight away. Only for a signed-in write: a seed replay carries its own team_id, and an
-- organizer who left the attendees keeps team_id null.
create or replace function session_members_place_attendee()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.team_id is null and auth.uid() is not null then
    select t.id into new.team_id
    from sessions s
    join teams t on t.session_id = s.id
    where s.id = new.session_id and s.scoring_mode is null
    order by t.position
    limit 1;
  end if;
  return new;
end;
$$;

create trigger session_members_place_attendee_trigger
  before insert on session_members
  for each row execute function session_members_place_attendee();

-- Keeps the single team's players in step with its members' team_id in a session without scores
-- (plan 29): a member placed on the team is an attendee, one taken off it or removed is not.
-- security definer: team_players is otherwise writable by the owner in draft only, while the
-- attendees change until the session is completed, including through join_session.
create or replace function session_members_sync_attendance()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session_id uuid := case when tg_op = 'DELETE' then old.session_id else new.session_id end;
  v_user_id uuid := case when tg_op = 'DELETE' then old.user_id else new.user_id end;
  v_player_id uuid;
begin
  if not exists (select 1 from sessions where id = v_session_id and scoring_mode is null) then
    return null;
  end if;
  select id into v_player_id from players where user_id = v_user_id;
  if v_player_id is null then
    return null;
  end if;

  if tg_op <> 'INSERT' and old.team_id is not null
    and (tg_op = 'DELETE' or new.team_id is distinct from old.team_id) then
    delete from team_players where team_id = old.team_id and player_id = v_player_id;
  end if;
  if tg_op <> 'DELETE' and new.team_id is not null
    and (tg_op = 'INSERT' or new.team_id is distinct from old.team_id) then
    insert into team_players (team_id, player_id) values (new.team_id, v_player_id)
    on conflict do nothing;
  end if;
  return null;
end;
$$;

create trigger session_members_sync_attendance_trigger
  after insert or update of team_id or delete on session_members
  for each row execute function session_members_sync_attendance();

-- Denormalized session_id (Q35, plan 08): populated from the parent row so scores and
-- team_players can be realtime-filtered by session_id like teams/played_holes already are.
-- "before insert or update" (not insert-only) because scores is written via upsert (plan 08's
-- inline score entry): on a conflict, Postgres runs the UPDATE branch with the client-supplied
-- NEW row, which never carries session_id -- only a trigger that also fires on update
-- re-derives it every time. team_players is insert-only in practice but the same trigger shape
-- costs nothing extra and stays consistent.
create or replace function team_players_set_session_id()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  select session_id into new.session_id from teams where id = new.team_id;
  return new;
end;
$$;

create trigger team_players_set_session_id_trigger
  before insert or update on team_players
  for each row execute function team_players_set_session_id();

create or replace function scores_set_session_id()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  select session_id into new.session_id from played_holes where id = new.played_hole_id;
  return new;
end;
$$;

create trigger scores_set_session_id_trigger
  before insert or update on scores
  for each row execute function scores_set_session_id();

-- Par of a played hole (plan 26, Q118): when the insert carries none, a directory hole takes
-- its own current par (a copy, frozen afterwards). A free hole has no par to copy: the app must
-- send one (decision 5), otherwise the insert is refused -- except with no signed-in caller
-- (seed replay, LsgScores import), where a free hole played before plan 26 gets 3 (Q122).
create or replace function played_holes_set_par()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.par is null then
    if new.hole_id is not null then
      select par into new.par from holes where id = new.hole_id;
    elsif auth.uid() is null then
      new.par := 3;
    else
      raise exception 'par_required' using errcode = 'P0001';
    end if;
  end if;
  return new;
end;
$$;

create trigger played_holes_set_par_trigger
  before insert on played_holes
  for each row execute function played_holes_set_par();

-- Championship flag of a session (plan 26, decision 11; plan 27): only a super_admin, the approved
-- local manager or an admin of the session's association sets or clears it, through
-- set_session_championship (rpc.sql). Any other signed-in write (the organizer's own update,
-- create_session) keeps the previous value -- same silent guard as association_id below. No
-- signed-in caller (seed replay, LsgScores import): the row keeps what it carries (Q131).
create or replace function sessions_guard_championship()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_previous boolean := case when tg_op = 'INSERT' then false else old.is_championship end;
begin
  if new.is_championship is distinct from v_previous
    and auth.uid() is not null
    and not is_super_admin()
    and not is_association_staff(new.association_id) then
    new.is_championship := v_previous;
  end if;
  return new;
end;
$$;

-- Association and championship season of a session (plans 15 and 18), both trigger-owned,
-- never settable by the client (same principle as team_players.session_id above).
--   1. Season: recomputed from scratch on every row, so an edited start date (plan 10) moves a
--      session to the season it actually belongs to. Done here rather than as a generated
--      column: see tables.sql's comment on championship_season for why extract() on a
--      timestamptz can't be an IMMUTABLE generated expression.
--   2. Association: at creation, the creator's association (plan 18), which must be approved --
--      a player without one, or whose creation request is still pending, can't create a session
--      (Q81). A row inserted with no signed-in caller (seed replay, LsgScores import) keeps the
--      association it carries, or takes its owner's if it carries none. Afterwards frozen (Q80):
--      only a super_admin changes it, through set_session_association (rpc.sql).
create or replace function sessions_set_association_and_season()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_played_at timestamptz;
  v_month int;
  v_year int;
begin
  v_played_at := coalesce(new.started_at, new.created_at);
  v_month := extract(month from (v_played_at at time zone 'utc'));
  v_year := extract(year from (v_played_at at time zone 'utc'));
  new.championship_season := case
    when v_month >= 9 then v_year || '-' || (v_year + 1)
    else (v_year - 1) || '-' || v_year
  end;

  if tg_op = 'INSERT' then
    if new.association_id is null or auth.uid() is not null then
      select p.association_id into new.association_id
      from players p
      join associations a on a.id = p.association_id and a.status = 'approved'
      where p.user_id = new.owner_id;
    end if;
    if new.association_id is null then
      raise exception 'association_required' using errcode = 'P0001';
    end if;
  elsif new.association_id is distinct from old.association_id
    and auth.uid() is not null
    and not is_super_admin() then
    new.association_id := old.association_id;
  end if;

  return new;
end;
$$;

create trigger sessions_set_association_and_season_trigger
  before insert or update on sessions
  for each row execute function sessions_set_association_and_season();

-- After sessions_set_association_and_season_trigger (triggers fire in name order): the guard
-- needs the association the insert just received.
create trigger sessions_ta_guard_championship_trigger
  before insert or update on sessions
  for each row execute function sessions_guard_championship();

-- A player joins only an approved association (plan 18, Q79/Q81): a pending request can't be
-- joined, even by its own requester, who is attached by approve_association at approval time.
create or replace function players_guard_association()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.association_id is distinct from old.association_id
    and new.association_id is not null
    and not exists (
      select 1 from associations where id = new.association_id and status = 'approved'
    ) then
    raise exception 'association_not_approved' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger players_guard_association_trigger
  before update on players
  for each row execute function players_guard_association();

-- A local admin who leaves their association, or switches to another one, is no longer its
-- admin (plan 27, Q171), whatever the way out (leaving, joining another, delete_association).
-- security definer: the player updating their own row has no right on association_admins.
create or replace function players_drop_association_admin()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from association_admins
  where player_id = new.id
    and association_id is distinct from new.association_id;
  return null;
end;
$$;

create trigger players_drop_association_admin_trigger
  after update of association_id on players
  for each row
  when (old.association_id is distinct from new.association_id)
  execute function players_drop_association_admin();

create trigger associations_set_updated_at
  before update on associations
  for each row execute function set_updated_at();

-- Association planning (plan 23). An app write runs as "authenticated"; the import RPC
-- (import_events, security definer) and the seed replay run as the schema owner, and are trusted
-- to set what the app may not: the association, the origin, the creator.

-- An event written by the app belongs to its creator's association, is 'manual', and keeps its
-- association, origin and creator afterwards. Its person in charge, when set, is a member of that
-- association. Its spot, when set (plan 28), is one of that association's, and its name and point
-- are copied onto the event.
create or replace function events_guard()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_spot spots;
begin
  if current_user = 'authenticated' then
    if tg_op = 'INSERT' then
      new.created_by := auth.uid();
      new.origin := 'manual';
      select association_id into new.association_id from players where user_id = auth.uid();
      if new.association_id is null then
        raise exception 'association_required' using errcode = 'P0001';
      end if;
    else
      new.association_id := old.association_id;
      new.origin := old.origin;
      new.created_by := old.created_by;
      new.created_at := old.created_at;
    end if;
  end if;

  if new.manager_player_id is not null and not exists (
    select 1 from players
    where id = new.manager_player_id and association_id = new.association_id
  ) then
    raise exception 'manager_not_member' using errcode = 'P0001';
  end if;

  if new.spot_id is not null then
    select * into v_spot from spots where id = new.spot_id;
    if not found or v_spot.association_id <> new.association_id then
      raise exception 'spot_not_in_association' using errcode = 'P0001';
    end if;
    new.spot := v_spot.name;
    new.location := coalesce(v_spot.location, new.location);
  end if;

  if tg_op = 'UPDATE' then
    new.updated_at := now();
  end if;
  return new;
end;
$$;

create trigger events_guard_trigger
  before insert or update on events
  for each row execute function events_guard();

-- An answer is set, changed or withdrawn only until the event starts (Q157). A cascade from a
-- deleted event finds no event any more and goes through.
create or replace function event_responses_guard()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_starts_at timestamptz;
begin
  select starts_at into v_starts_at
  from events
  where id = case when tg_op = 'DELETE' then old.event_id else new.event_id end;

  if found and v_starts_at <= now() and current_user = 'authenticated' then
    raise exception 'event_started' using errcode = 'P0001';
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger event_responses_guard_trigger
  before insert or update or delete on event_responses
  for each row execute function event_responses_guard();

-- Editing a comment changes its text only, and marks it edited (Q166).
create or replace function event_comments_guard_update()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.event_id := old.event_id;
  new.author_player_id := old.author_player_id;
  new.created_at := old.created_at;
  if new.body is distinct from old.body then
    new.edited_at := now();
  else
    new.edited_at := old.edited_at;
  end if;
  return new;
end;
$$;

create trigger event_comments_guard_update_trigger
  before update on event_comments
  for each row execute function event_comments_guard_update();

-- A session is linked to the event it was started from (Q164) only by the event's person in
-- charge, the local manager or admins or a super_admin, for an event of the session's own association
-- happening today (within a day of now, whatever the time zone). Unlinking is free. After
-- sessions_ta_guard_championship_trigger (name order): needs the association already set.
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
  return new;
end;
$$;

create trigger sessions_tb_guard_event_trigger
  before insert or update on sessions
  for each row execute function sessions_guard_event();

-- Spots (plan 28). A session's spot is one of its association's; while it's set, the session's
-- zone and city are the spot's name and city (Q182, Q184), recopied on every write so they can
-- never drift apart. The session's point stays where it was created (weather, "Explorer" badges).
-- After sessions_tb_guard_event_trigger (name order): needs the association already set.
create or replace function sessions_copy_spot()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_spot spots;
begin
  if new.spot_id is not null then
    select * into v_spot from spots where id = new.spot_id;
    if not found or v_spot.association_id <> new.association_id then
      raise exception 'spot_not_in_association' using errcode = 'P0001';
    end if;
    new.zone := v_spot.name;
    new.city := coalesce(v_spot.city, new.city);
  end if;
  return new;
end;
$$;

create trigger sessions_tc_copy_spot_trigger
  before insert or update on sessions
  for each row execute function sessions_copy_spot();

-- A session's natures after its creation (plan 29, Q193, Q197), whoever writes (the organizer's
-- own update, or set_session_tags for the staff). Nothing depending on them is stored, so a change
-- breaks no data; it only changes what the players see. Three kinds:
--   - frozen: the scorecard (scoring mode, format, direction) and "simulator" on a session with a
--     scorecard (it decides which holes are offered);
--   - free: "association life", and "training" or "simulator" without a scorecard (badges L only);
--   - sensitive: "training" on a session with a scorecard (it takes the session in or out of the
--     statistics, records and badges A to K): the organizer until the session is completed, the
--     local staff and super_admins at any time.
-- No signed-in caller (seed replay): anything goes.
create or replace function sessions_guard_nature()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_changed session_tag[];
begin
  if auth.uid() is null then
    return new;
  end if;
  if new.scoring_mode is distinct from old.scoring_mode
    or new.kind is distinct from old.kind
    or new.ranking_direction is distinct from old.ranking_direction then
    raise exception 'session_nature_frozen' using errcode = 'P0001';
  end if;

  -- Tags added or removed.
  select coalesce(array_agg(t), '{}') into v_changed
  from (
    (select unnest(new.tags) except select unnest(old.tags))
    union
    (select unnest(old.tags) except select unnest(new.tags))
  ) changed(t);

  if old.scoring_mode is not null then
    if 'simulator' = any (v_changed) then
      raise exception 'session_nature_frozen' using errcode = 'P0001';
    end if;
    if 'training' = any (v_changed)
      and old.status = 'completed'
      and not is_super_admin()
      and not is_association_staff(old.association_id) then
      raise exception 'session_tag_locked' using errcode = 'P0001';
    end if;
  end if;
  -- Clearer than the sessions_championship_game check failing: untag the championship first.
  if new.is_championship and new.tags && array['training', 'simulator']::session_tag[] then
    raise exception 'championship_session' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger sessions_td_guard_nature_trigger
  before update on sessions
  for each row execute function sessions_guard_nature();

-- A renamed or moved spot shows its new name, city and point everywhere it's used (Q182): its
-- sessions and events are rewritten, their own triggers above recopying from the spot. A deleted
-- spot leaves them their last copy (on delete set null). security definer: the staff member
-- editing the spot may not have written those sessions and events themselves.
create or replace function spots_propagate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update sessions set spot_id = spot_id where spot_id = new.id;
  update events set spot_id = spot_id where spot_id = new.id;
  return null;
end;
$$;

create trigger spots_propagate_trigger
  after update of name, city, location on spots
  for each row execute function spots_propagate();

create trigger spots_set_updated_at
  before update on spots
  for each row execute function set_updated_at();

-- None of the functions above are meant to be called directly (trigger-only, or an internal
-- helper); Postgres grants EXECUTE to PUBLIC by default at creation, so revoke it explicitly.
-- (handle_new_user and the "returns trigger" functions can't be invoked via RPC anyway, but
-- revoking keeps the default deny consistent and satisfies the security linter.)
revoke execute on function handle_new_user() from public, authenticated;
revoke execute on function set_updated_at() from public, authenticated;
revoke execute on function generate_session_code() from public, authenticated;
-- ...except for the LsgScores import script (plan 13): sessions_set_code runs as the inserting
-- role (not security definer), so a session inserted with the service key calls this directly.
grant execute on function generate_session_code() to service_role;
revoke execute on function sessions_set_code() from public, authenticated;
revoke execute on function team_players_guard_single_team() from public, authenticated;
revoke execute on function session_members_guard_frozen_teams() from public, authenticated;
revoke execute on function team_players_set_session_id() from public, authenticated;
revoke execute on function scores_set_session_id() from public, authenticated;
revoke execute on function sessions_set_association_and_season() from public, authenticated;
revoke execute on function players_guard_association() from public, authenticated;
revoke execute on function players_drop_association_admin() from public, authenticated;
revoke execute on function played_holes_set_par() from public, authenticated;
revoke execute on function sessions_guard_championship() from public, authenticated;
revoke execute on function events_guard() from public, authenticated;
revoke execute on function event_responses_guard() from public, authenticated;
revoke execute on function event_comments_guard_update() from public, authenticated;
revoke execute on function sessions_guard_event() from public, authenticated;
revoke execute on function sessions_copy_spot() from public, authenticated;
revoke execute on function sessions_guard_nature() from public, authenticated;
revoke execute on function session_members_place_attendee() from public, authenticated;
revoke execute on function session_members_sync_attendance() from public, authenticated;
revoke execute on function spots_propagate() from public, authenticated;
