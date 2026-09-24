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
