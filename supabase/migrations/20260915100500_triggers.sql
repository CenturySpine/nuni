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
begin
  if new.team_id is distinct from old.team_id then
    select status into v_status from sessions where id = new.session_id;
    if v_status <> 'draft' then
      raise exception 'teams_frozen_after_start' using errcode = 'P0001';
    end if;
  end if;
  return new;
end;
$$;

create trigger session_members_guard_frozen_teams_trigger
  before update on session_members
  for each row execute function session_members_guard_frozen_teams();

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

create trigger associations_set_updated_at
  before update on associations
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
