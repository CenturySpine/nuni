import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/ranking_direction.dart';

part 'libre_ranking_direction_pref.g.dart';

const _prefsKey = 'nuni.libre_ranking_direction';

/// The last "plus haut / plus bas gagne" choice for the Libre scoring mode
/// (Q7b: "le dernier choix est proposé par défaut"), remembered on the
/// device -- same pattern as `HolesRadius`. Defaults to `desc` ("le plus
/// haut gagne", Q7b's own default) on first use.
@riverpod
class LibreRankingDirectionPref extends _$LibreRankingDirectionPref {
  @override
  Future<RankingDirection> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey) == 'asc'
        ? RankingDirection.asc
        : RankingDirection.desc;
  }

  Future<void> set(RankingDirection direction) async {
    state = AsyncData(direction);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, direction.name);
  }
}
