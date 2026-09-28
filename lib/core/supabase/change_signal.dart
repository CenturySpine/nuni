import 'dart:async';

/// A realtime `.stream()` used only as a "something changed" signal, that
/// survives the connection dropping.
///
/// A phone putting the app in the background kills its websocket: the
/// Supabase stream then reports a channel error, or simply closes, and
/// never delivers anything again (found live, 2026-09-28: a participant's
/// waiting room stuck, or showing an error, after a while in the
/// background). Instead of passing that error on to the screen, this
/// re-opens the stream after [retryDelay] and calls [onChange] so the
/// caller re-reads what it may have missed.
class ChangeSignal {
  ChangeSignal(
    this._open,
    this._onChange, {
    this.retryDelay = const Duration(seconds: 3),
  }) {
    _listen();
  }

  final Stream<Object?> Function() _open;
  final void Function() _onChange;
  final Duration retryDelay;

  StreamSubscription<Object?>? _subscription;
  Timer? _retry;
  var _cancelled = false;

  void _listen() {
    _subscription = _open().listen(
      (_) => _onChange(),
      onError: (Object _, StackTrace _) => _reopenLater(),
      onDone: _reopenLater,
    );
  }

  void _reopenLater() {
    if (_cancelled || (_retry?.isActive ?? false)) return;
    final dead = _subscription;
    _subscription = null;
    unawaited(dead?.cancel());
    _retry = Timer(retryDelay, () {
      if (_cancelled) return;
      _listen();
      _onChange();
    });
  }

  Future<void> cancel() async {
    _cancelled = true;
    _retry?.cancel();
    await _subscription?.cancel();
  }
}
