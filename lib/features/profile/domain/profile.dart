import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Mirrors the `profiles` table (plan 03): one row per signed-in user,
/// created by the `handle_new_user` trigger at sign-up.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    required String locale,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);
}
