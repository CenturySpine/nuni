// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'libre_ranking_direction_pref.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The last "plus haut / plus bas gagne" choice for the Libre scoring mode
/// (Q7b: "le dernier choix est proposé par défaut"), remembered on the
/// device -- same pattern as `HolesRadius`. Defaults to `desc` ("le plus
/// haut gagne", Q7b's own default) on first use.

@ProviderFor(LibreRankingDirectionPref)
final libreRankingDirectionPrefProvider = LibreRankingDirectionPrefProvider._();

/// The last "plus haut / plus bas gagne" choice for the Libre scoring mode
/// (Q7b: "le dernier choix est proposé par défaut"), remembered on the
/// device -- same pattern as `HolesRadius`. Defaults to `desc` ("le plus
/// haut gagne", Q7b's own default) on first use.
final class LibreRankingDirectionPrefProvider
    extends
        $AsyncNotifierProvider<LibreRankingDirectionPref, RankingDirection> {
  /// The last "plus haut / plus bas gagne" choice for the Libre scoring mode
  /// (Q7b: "le dernier choix est proposé par défaut"), remembered on the
  /// device -- same pattern as `HolesRadius`. Defaults to `desc` ("le plus
  /// haut gagne", Q7b's own default) on first use.
  LibreRankingDirectionPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libreRankingDirectionPrefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libreRankingDirectionPrefHash();

  @$internal
  @override
  LibreRankingDirectionPref create() => LibreRankingDirectionPref();
}

String _$libreRankingDirectionPrefHash() =>
    r'56160a77ed5a20cde8b340d48fa58c3eddeaef43';

/// The last "plus haut / plus bas gagne" choice for the Libre scoring mode
/// (Q7b: "le dernier choix est proposé par défaut"), remembered on the
/// device -- same pattern as `HolesRadius`. Defaults to `desc` ("le plus
/// haut gagne", Q7b's own default) on first use.

abstract class _$LibreRankingDirectionPref
    extends $AsyncNotifier<RankingDirection> {
  FutureOr<RankingDirection> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<RankingDirection>, RankingDirection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RankingDirection>, RankingDirection>,
              AsyncValue<RankingDirection>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
