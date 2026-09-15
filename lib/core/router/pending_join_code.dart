import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_join_code.g.dart';

/// The join code from `/join/:code`, remembered across the redirect to
/// `/login` so plan 09 can pick it back up once the user is signed in.
@riverpod
class PendingJoinCode extends _$PendingJoinCode {
  @override
  String? build() => null;

  void set(String? code) => state = code;
}
