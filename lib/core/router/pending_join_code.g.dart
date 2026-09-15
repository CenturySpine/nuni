// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_join_code.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The join code from `/join/:code`, remembered across the redirect to
/// `/login` so plan 09 can pick it back up once the user is signed in.

@ProviderFor(PendingJoinCode)
final pendingJoinCodeProvider = PendingJoinCodeProvider._();

/// The join code from `/join/:code`, remembered across the redirect to
/// `/login` so plan 09 can pick it back up once the user is signed in.
final class PendingJoinCodeProvider
    extends $NotifierProvider<PendingJoinCode, String?> {
  /// The join code from `/join/:code`, remembered across the redirect to
  /// `/login` so plan 09 can pick it back up once the user is signed in.
  PendingJoinCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingJoinCodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingJoinCodeHash();

  @$internal
  @override
  PendingJoinCode create() => PendingJoinCode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingJoinCodeHash() => r'954db18f11d784cfd8a2cbd9637de650ee4929ef';

/// The join code from `/join/:code`, remembered across the redirect to
/// `/login` so plan 09 can pick it back up once the user is signed in.

abstract class _$PendingJoinCode extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
