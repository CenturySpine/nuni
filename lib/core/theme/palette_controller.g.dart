// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palette_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The colour set the app is currently drawn with, chosen by the user in
/// the settings (PO, 2026-09-23, Q76). Per device, like the language.

@ProviderFor(PaletteController)
final paletteControllerProvider = PaletteControllerProvider._();

/// The colour set the app is currently drawn with, chosen by the user in
/// the settings (PO, 2026-09-23, Q76). Per device, like the language.
final class PaletteControllerProvider
    extends $NotifierProvider<PaletteController, Palette> {
  /// The colour set the app is currently drawn with, chosen by the user in
  /// the settings (PO, 2026-09-23, Q76). Per device, like the language.
  PaletteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paletteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paletteControllerHash();

  @$internal
  @override
  PaletteController create() => PaletteController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Palette value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Palette>(value),
    );
  }
}

String _$paletteControllerHash() => r'3d9017bc2237faa409d59af0f648a0fb68d9d613';

/// The colour set the app is currently drawn with, chosen by the user in
/// the settings (PO, 2026-09-23, Q76). Per device, like the language.

abstract class _$PaletteController extends $Notifier<Palette> {
  Palette build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Palette, Palette>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Palette, Palette>,
              Palette,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
