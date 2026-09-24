import '../badge.dart';
import '../badge_facts.dart';
import 'tracker.dart';

/// WMO weather codes (plan 21, "Pluie", "Neige"): drizzle and rain 51 to
/// 67, showers 80 to 82 (thunderstorms don't count); snow 71 to 77, snow
/// showers 85 and 86.
bool isRain(int code) =>
    (code >= 51 && code <= 67) || (code >= 80 && code <= 82);
bool isSnow(int code) => (code >= 71 && code <= 77) || code == 85 || code == 86;

/// I. Playing conditions at the start of the session (weather recorded
/// then; a session without weather doesn't count for I1 to I4 and I8),
/// its local start time (Q115, Q125) and its length (Q112).
List<BadgeResult> conditionBadges(BadgeFacts facts) {
  final rain = BadgeTracker(BadgeId.rain);
  final frosty = BadgeTracker(BadgeId.frosty);
  final heatwave = BadgeTracker(BadgeId.heatwave);
  final gust = BadgeTracker(BadgeId.gust);
  final nightOwl = BadgeTracker(BadgeId.nightOwl);
  final earlyBird = BadgeTracker(BadgeId.earlyBird);
  final marathon = BadgeTracker(BadgeId.marathon);
  final snow = BadgeTracker(BadgeId.snow);

  for (final session in facts.sessions) {
    if (session.session.weather case final weather?) {
      if (isRain(weather.code)) rain.hit(session);
      if (isSnow(weather.code)) snow.hit(session);
      if (weather.temperatureC < 3) frosty.hit(session);
      if (weather.temperatureC > 30) heatwave.hit(session);
      if (weather.windKph > 30) gust.hit(session);
    }
    final hour = session.date.hour;
    if (hour >= 21) nightOwl.hit(session);
    if (hour < 9) earlyBird.hit(session);
    if (session.holes.length >= 9) marathon.hit(session);
  }

  return [
    rain,
    frosty,
    heatwave,
    gust,
    nightOwl,
    earlyBird,
    marathon,
    snow,
  ].results();
}
