-- Extensions and enum types for the NUNI schema (plan 03).

create extension if not exists postgis;
create extension if not exists pgcrypto;

create type session_status as enum ('draft', 'live', 'completed');
create type session_kind as enum ('individual', 'team');
create type scoring_mode as enum ('stroke_play', 'match_play', 'redistribution', 'free');
create type ranking_direction as enum ('asc', 'desc');
create type game_mode as enum ('individual', 'scramble', 'greensome', 'best_ball');
create type member_role as enum ('owner', 'player');
-- App-wide role (plan 16), distinct from member_role (session-scoped owner/player).
create type app_role as enum ('player', 'super_admin');
-- Associations (plan 18): a creation request or a local-manager claim waits for a super_admin.
create type association_status as enum ('pending', 'approved', 'rejected');
create type association_manager_status as enum ('pending', 'approved', 'rejected', 'revoked');
-- Association planning (plan 23): a member's answer to an event, the fixed hues an event may be
-- drawn in (Q149: only the name is stored, the app owns the actual colour), and how the event was
-- created (Q155: a new import replaces the imported ones, never the members' own).
create type event_response as enum ('yes', 'no', 'maybe');
create type event_color as enum ('red', 'orange', 'yellow', 'green', 'teal', 'blue', 'purple', 'pink');
create type event_origin as enum ('manual', 'imported');
