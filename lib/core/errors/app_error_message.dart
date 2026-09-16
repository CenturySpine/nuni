import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/generated/app_localizations.dart';

/// Maps a caught error to one of the app's three standard banner messages
/// (plan 05): session expired, access denied (RLS), or a generic failure
/// (network/offline included -- Flutter web has no reliable, dependency-free
/// way to tell "offline" apart from any other failed request, and the retry
/// action is the same either way).
String describeError(Object error, AppLocalizations l10n) {
  if (error is AuthException) return l10n.errorSessionExpired;
  if (error is PostgrestException && error.code == '42501') {
    return l10n.errorAccessDenied;
  }
  return l10n.errorGeneric;
}
