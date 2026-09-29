import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_repository.dart';
import '../data/notifications_controller.dart';
import '../data/web_push.dart';

/// Mounted once above every page (`app.dart`), like the badge announcer
/// (plan 33):
/// - the first touch in the app brings up the phone's permission window,
///   once per device (Q235);
/// - this device's subscription follows the account signed in and the
///   app's language (Q230), and is re-checked whenever the app shows again;
/// - a notification touched while NUNI is open opens its event's page.
class NotificationsGate extends ConsumerStatefulWidget {
  const NotificationsGate({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<NotificationsGate> createState() => _NotificationsGateState();
}

class _NotificationsGateState extends ConsumerState<NotificationsGate> {
  late final AppLifecycleListener _lifecycle;
  late final StreamSubscription<AuthState> _auth;
  late final StreamSubscription<String> _opens;
  String? _locale;

  NotificationsController get _controller =>
      ref.read(notificationsControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onShow: () {
        _controller.refresh();
        unawaited(_controller.sync());
      },
    );
    _auth = ref.read(authRepositoryProvider).onAuthStateChange.listen((change) {
      if (change.event == AuthChangeEvent.signedIn ||
          change.event == AuthChangeEvent.initialSession) {
        unawaited(_controller.sync());
      }
    });
    _opens = notificationOpens().listen(widget.router.push);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (locale != _locale) {
      _locale = locale;
      unawaited(_controller.sync(locale));
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(_auth.cancel());
    unawaited(_opens.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerUp: (_) => unawaited(_controller.askOnFirstTouch()),
    child: widget.child,
  );
}
