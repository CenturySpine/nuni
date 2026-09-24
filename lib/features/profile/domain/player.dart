import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Mirrors the `players` table (plan 03): the linked player is the one
/// where `user_id = auth.uid()`, created alongside sign-up (Q24 -- no other
/// way to get a player, no onboarding "c'est moi"). Also the account-facing
/// row (name, avatar, locale): there is no separate "profiles" table --
/// with Q24, a profile and its linked player were always 1:1 and kept in
/// sync on every save, so keeping them apart was pure duplication (PO,
/// 2026-09-16).
@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    required String locale,
    // Null = not chosen yet (plan 18): the app asks before anything else,
    // unless a creation request of mine is pending (Q81).
    @JsonKey(name: 'association_id') String? associationId,
    @JsonKey(name: 'user_id') String? userId,
    // Whether the statistics and badges sections show on the public page
    // (plans 19 and 21, Q108) -- display only, the data stays readable (Q133).
    @JsonKey(name: 'stats_public') @Default(true) bool statsPublic,
    @JsonKey(name: 'badges_public') @Default(true) bool badgesPublic,
  }) = _Player;

  factory Player.fromJson(Map<String, Object?> json) => _$PlayerFromJson(json);
}
