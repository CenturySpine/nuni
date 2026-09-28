import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/live/data/live_repository.dart';
import '../../features/sessions/data/sessions_repository.dart';

/// Re-reads the sessions once the app is visible again (PO, 2026-09-28).
///
/// Home's lists are read once and kept by the bottom-nav stack, and a
/// phone kills the realtime connection of an app left in the background:
/// a participant coming back could find neither the session they joined on
/// home nor a working session screen. Showing the app again reloads home's
/// session lists and re-opens every session screen's realtime feed from
/// scratch; the screens keep their current content while it reloads.
class ResumeRefresher extends ConsumerStatefulWidget {
  const ResumeRefresher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ResumeRefresher> createState() => _ResumeRefresherState();
}

class _ResumeRefresherState extends ConsumerState<ResumeRefresher> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onShow: _refresh);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  void _refresh() {
    ref
      ..invalidate(myOngoingSessionsProvider)
      ..invalidate(myRecentSessionsProvider)
      ..invalidate(associationLiveSessionsProvider)
      ..invalidate(sessionRoomProvider)
      ..invalidate(liveSessionProvider);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
