import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  bool get isSignedIn => _client.auth.currentSession != null;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Redirect flow (plan 05): popups are blocked in PWAs installed on iOS,
  /// so this is the only option, not a stylistic choice. Returns to the
  /// current origin, which must be in the Supabase project's allow-list
  /// (already true for localhost:3000 and nuni.centuryspine.org, plan 03).
  Future<void> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: Uri.base.origin,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);
