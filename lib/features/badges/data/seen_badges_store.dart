import 'package:shared_preferences/shared_preferences.dart';

import '../domain/badge.dart';

/// What this device already showed of the signed-in player's badges (plan
/// 21, "Annonce d'un nouveau badge"): the badges announced in a sheet, and
/// the ones seen in the badges section (the others wear "New"). Per device
/// and per account; a new phone or a cleared browser announces them once
/// more -- avoiding that would need a table, against "no badge stored".
class SeenBadgesStore {
  const SeenBadgesStore(this.userId);

  final String userId;

  String get _announcedKey => 'badges.announced.$userId';
  String get _viewedKey => 'badges.viewed.$userId';

  /// Null the very first time: the player has never been told about any
  /// badge on this device (Q97, announced all at once).
  Future<Set<BadgeId>?> announced() => _read(_announcedKey);

  Future<void> markAnnounced(Iterable<BadgeId> ids) => _add(_announcedKey, ids);

  /// Badges already seen in the section; empty the first time.
  Future<Set<BadgeId>> viewed() async => await _read(_viewedKey) ?? {};

  Future<void> markViewed(Iterable<BadgeId> ids) => _add(_viewedKey, ids);

  static Future<Set<BadgeId>?> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(key);
    if (names == null) return null;
    final byName = {for (final id in BadgeId.values) id.name: id};
    return {for (final name in names) ?byName[name]};
  }

  static Future<void> _add(String key, Iterable<BadgeId> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final names = {...?prefs.getStringList(key), for (final id in ids) id.name};
    await prefs.setStringList(key, names.toList());
  }
}
