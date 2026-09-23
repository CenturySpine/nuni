import '../../../l10n/generated/app_localizations.dart';
import '../domain/played_hole.dart';

/// A played hole's display name: the directory hole's name, a free hole's
/// label, or "Free hole" (plan 17, Q57). Always shown after the hole's
/// position in the session ("Hole 3 · Free hole"), which keeps several
/// unlabelled free holes distinguishable.
String playedHoleName(AppLocalizations l10n, PlayedHole playedHole) =>
    playedHole.customName ?? l10n.sessionsLiveFreeHole;
