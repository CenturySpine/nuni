import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_photo.freezed.dart';
part 'session_photo.g.dart';

/// Mirrors the `session_photos` table (plan 03, used from plan 10).
@freezed
abstract class SessionPhoto with _$SessionPhoto {
  const factory SessionPhoto({
    required String id,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'storage_path') required String storagePath,
    @JsonKey(name: 'uploaded_by') String? uploadedBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SessionPhoto;

  factory SessionPhoto.fromJson(Map<String, Object?> json) =>
      _$SessionPhotoFromJson(json);
}
