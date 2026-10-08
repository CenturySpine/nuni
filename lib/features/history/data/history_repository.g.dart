// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(historyEntries)
final historyEntriesProvider = HistoryEntriesProvider._();

final class HistoryEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryEntry>>,
          List<HistoryEntry>,
          FutureOr<List<HistoryEntry>>
        >
    with
        $FutureModifier<List<HistoryEntry>>,
        $FutureProvider<List<HistoryEntry>> {
  HistoryEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyEntriesHash();

  @$internal
  @override
  $FutureProviderElement<List<HistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistoryEntry>> create(Ref ref) {
    return historyEntries(ref);
  }
}

String _$historyEntriesHash() => r'd330ff3d2765909459de7766ce92ddc0b844e482';

/// A super_admin's "Autres sessions" in the history (plan 38); empty for
/// anyone else, without asking the base. Read after the history itself, so
/// that whatever refreshes it (a session deleted, edited, its cover
/// changed...) refreshes these too.

@ProviderFor(otherHistoryEntries)
final otherHistoryEntriesProvider = OtherHistoryEntriesProvider._();

/// A super_admin's "Autres sessions" in the history (plan 38); empty for
/// anyone else, without asking the base. Read after the history itself, so
/// that whatever refreshes it (a session deleted, edited, its cover
/// changed...) refreshes these too.

final class OtherHistoryEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryEntry>>,
          List<HistoryEntry>,
          FutureOr<List<HistoryEntry>>
        >
    with
        $FutureModifier<List<HistoryEntry>>,
        $FutureProvider<List<HistoryEntry>> {
  /// A super_admin's "Autres sessions" in the history (plan 38); empty for
  /// anyone else, without asking the base. Read after the history itself, so
  /// that whatever refreshes it (a session deleted, edited, its cover
  /// changed...) refreshes these too.
  OtherHistoryEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherHistoryEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherHistoryEntriesHash();

  @$internal
  @override
  $FutureProviderElement<List<HistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistoryEntry>> create(Ref ref) {
    return otherHistoryEntries(ref);
  }
}

String _$otherHistoryEntriesHash() =>
    r'33d8999fc5e393aa1c56ce7547444dd33794383b';

@ProviderFor(sessionPhotos)
final sessionPhotosProvider = SessionPhotosFamily._();

final class SessionPhotosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SessionPhoto>>,
          List<SessionPhoto>,
          FutureOr<List<SessionPhoto>>
        >
    with
        $FutureModifier<List<SessionPhoto>>,
        $FutureProvider<List<SessionPhoto>> {
  SessionPhotosProvider._({
    required SessionPhotosFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionPhotosProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionPhotosHash();

  @override
  String toString() {
    return r'sessionPhotosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SessionPhoto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SessionPhoto>> create(Ref ref) {
    final argument = this.argument as String;
    return sessionPhotos(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionPhotosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionPhotosHash() => r'330c22a58ff4036954b1d022f50bafd33a2935c2';

final class SessionPhotosFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SessionPhoto>>, String> {
  SessionPhotosFamily._()
    : super(
        retry: null,
        name: r'sessionPhotosProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionPhotosProvider call(String sessionId) =>
      SessionPhotosProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionPhotosProvider';
}

/// The detail screen's data (plan 10): the exact same `session_snapshot`
/// call the live screen makes (Q36's shape, reused), wrapped with its
/// standings -- read-only here, no realtime subscription (a completed
/// session's data doesn't change under the viewer the way a live one does).

@ProviderFor(historyDetail)
final historyDetailProvider = HistoryDetailFamily._();

/// The detail screen's data (plan 10): the exact same `session_snapshot`
/// call the live screen makes (Q36's shape, reused), wrapped with its
/// standings -- read-only here, no realtime subscription (a completed
/// session's data doesn't change under the viewer the way a live one does).

final class HistoryDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<HistoryEntry?>,
          HistoryEntry?,
          FutureOr<HistoryEntry?>
        >
    with $FutureModifier<HistoryEntry?>, $FutureProvider<HistoryEntry?> {
  /// The detail screen's data (plan 10): the exact same `session_snapshot`
  /// call the live screen makes (Q36's shape, reused), wrapped with its
  /// standings -- read-only here, no realtime subscription (a completed
  /// session's data doesn't change under the viewer the way a live one does).
  HistoryDetailProvider._({
    required HistoryDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'historyDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyDetailHash();

  @override
  String toString() {
    return r'historyDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HistoryEntry?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HistoryEntry?> create(Ref ref) {
    final argument = this.argument as String;
    return historyDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyDetailHash() => r'38d542185328960b16e610c3320dc13ff9b6b805';

/// The detail screen's data (plan 10): the exact same `session_snapshot`
/// call the live screen makes (Q36's shape, reused), wrapped with its
/// standings -- read-only here, no realtime subscription (a completed
/// session's data doesn't change under the viewer the way a live one does).

final class HistoryDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HistoryEntry?>, String> {
  HistoryDetailFamily._()
    : super(
        retry: null,
        name: r'historyDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The detail screen's data (plan 10): the exact same `session_snapshot`
  /// call the live screen makes (Q36's shape, reused), wrapped with its
  /// standings -- read-only here, no realtime subscription (a completed
  /// session's data doesn't change under the viewer the way a live one does).

  HistoryDetailProvider call(String sessionId) =>
      HistoryDetailProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'historyDetailProvider';
}
