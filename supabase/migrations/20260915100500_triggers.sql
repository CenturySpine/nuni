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
begin
  v_display_name := coalesce(
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'name',
    split_part(new.email, '@', 1)
  );
  v_avatar_url := new.raw_user_meta_data ->> 'avatar_url';
  v_locale := coalesce(left(new.raw_user_meta_data ->> 'locale', 2), 'fr');

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

-- None of the functions above are meant to be called directly (trigger-only, or an internal
-- helper); Postgres grants EXECUTE to PUBLIC by default at creation, so revoke it explicitly.
-- (handle_new_user and the "returns trigger" functions can't be invoked via RPC anyway, but
-- revoking keeps the default deny consistent and satisfies the security linter.)
revoke execute on function handle_new_user() from public, authenticated;
revoke execute on function set_updated_at() from public, authenticated;
revoke execute on function generate_session_code() from public, authenticated;
revoke execute on function sessions_set_code() from public, authenticated;
revoke execute on function team_players_guard_single_team() from public, authenticated;
revoke execute on function session_members_guard_frozen_teams() from public, authenticated;
