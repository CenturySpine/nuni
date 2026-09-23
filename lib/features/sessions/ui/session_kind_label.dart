import '../../../l10n/generated/app_localizations.dart';
import '../domain/session_kind.dart';

/// "Individual" / "Team", shown on every session tile (home, history --
/// PO, 2026-09-23).
String sessionKindLabel(AppLocalizations l10n, SessionKind kind) =>
    switch (kind) {
      SessionKind.individual => l10n.sessionKindIndividual,
      SessionKind.team => l10n.sessionKindTeam,
    };
