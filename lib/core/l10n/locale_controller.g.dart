// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The language the app is currently displayed in. `null` means "follow the
/// browser", matching [MaterialApp.locale]'s own contract.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// The language the app is currently displayed in. `null` means "follow the
/// browser", matching [MaterialApp.locale]'s own contract.
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, Locale?> {
  /// The language the app is currently displayed in. `null` means "follow the
  /// browser", matching [MaterialApp.locale]'s own contract.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeControllerHash() => r'5234ffbd3578d9394e6e9144e084c6ffeb4f4863';

/// The language the app is currently displayed in. `null` means "follow the
/// browser", matching [MaterialApp.locale]'s own contract.

abstract class _$LocaleController extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
