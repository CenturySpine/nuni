import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_providers.dart';
import 'app_role.dart';

part 'authorization_repository.g.dart';

class AuthorizationRepository {
  AuthorizationRepository(this._client);

  final SupabaseClient _client;

  /// `user_roles` only stores exceptions (plan 16): a row-less account is an
  /// implicit [AppRole.player].
  Future<AppRole> fetchMyRole() async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from('user_roles')
        .select('role')
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return AppRole.player;
    return appRoleFromPostgresValue(row['role'] as String);
  }
}

final authorizationRepositoryProvider = Provider<AuthorizationRepository>(
  (ref) => AuthorizationRepository(ref.watch(supabaseClientProvider)),
);

@riverpod
Future<AppRole> myAppRole(Ref ref) =>
    ref.watch(authorizationRepositoryProvider).fetchMyRole();

@riverpod
Future<bool> isSuperAdmin(Ref ref) async =>
    (await ref.watch(myAppRoleProvider.future)) == AppRole.superAdmin;
