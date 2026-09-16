import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Mirrors the `players` table (plan 03): the linked player is the one
/// where `user_id = auth.uid()`, created alongside the profile at sign-up
/// (Q24 -- no other way to get a player, no onboarding "c'est moi").
@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'user_id') String? userId,
  }) = _Player;

  factory Player.fromJson(Map<String, Object?> json) => _$PlayerFromJson(json);
}
