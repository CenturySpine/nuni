import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// Restores the persisted session (if any) from local storage before the
/// first frame -- call and await this in `main()`, the same way the locale
/// is pre-loaded, so the router never has to show a login "flash".
Future<void> initializeSupabase() async {
  // supabase_flutter calls this the "publishable key" now; it's the same
  // value as the "anon key" on the Supabase dashboard and in env/*.json.
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );
}

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
