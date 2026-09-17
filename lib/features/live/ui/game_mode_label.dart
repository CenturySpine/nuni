import '../../../l10n/generated/app_localizations.dart';
import '../domain/game_mode.dart';

String gameModeLabel(AppLocalizations l10n, GameMode mode) => switch (mode) {
  GameMode.individual => l10n.sessionsLiveGameModeIndividual,
  GameMode.scramble => l10n.sessionsLiveGameModeScramble,
  GameMode.greensome => l10n.sessionsLiveGameModeGreensome,
  GameMode.bestBall => l10n.sessionsLiveGameModeBestBall,
};
