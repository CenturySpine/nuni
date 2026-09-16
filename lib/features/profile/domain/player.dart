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
    @JsonKey(name: 'user_id') String? userId,
  }) = _Player;

  factory Player.fromJson(Map<String, Object?> json) => _$PlayerFromJson(json);
}
