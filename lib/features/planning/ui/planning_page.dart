import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../profile/data/profile_repository.dart';
import '../data/events_repository.dart';
import '../data/planning_rights.dart';
import '../domain/event.dart';
import '../domain/planning.dart';
import 'event_widgets.dart';

/// The Planning tab (plan 23): my association's events only -- no calendar
/// grid -- in date order, a heading per year and per month, past events
/// included but faded, opened on the next event (Q159, Q162).
class PlanningPage extends ConsumerWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final player = ref.watch(myPlayerProvider).value;
    final associationId = player?.associationId;
    final planning = ref.watch(myPlanningProvider);

    if (player != null && associationId == null) {
      return NuniEmptyState(
        icon: PhosphorIcons.calendarDots,
        message: l10n.planningNoAssociation,
        action: NuniButton(
          label: l10n.sessionsCreateSeeAssociations,
          onPressed: () => context.go('/associations'),
        ),
      );
    }

    final canImport =
        associationId != null &&
        (ref.watch(canModeratePlanningProvider(associationId)).value ?? false);

    // Own Scaffold, inside the shell's, only for the floating button: the
    // shell already provides the app bar.
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'planning-new',
        onPressed: () => context.push('/planning/new'),
        icon: const Icon(PhosphorIcons.plus),
        label: Text(l10n.planningNewEvent),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myPlanningProvider.future),
        child: planning.when(
          data: (events) => _PlanningList(
            events: events,
            myPlayerId: player?.id,
            header: canImport
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.push('/planning/import'),
                      icon: const Icon(PhosphorIcons.fileArrowUp, size: 18),
                      label: Text(l10n.planningImportAction),
                    ),
                  )
                : null,
          ),
          loading: () => const NuniLoading(),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [NuniErrorBanner(message: describeError(error, l10n))],
          ),
        ),
      ),
    );
  }
}

class _PlanningList extends StatefulWidget {
  const _PlanningList({
    required this.events,
    required this.myPlayerId,
    this.header,
  });

  final List<Event> events;
  final String? myPlayerId;
  final Widget? header;

  @override
  State<_PlanningList> createState() => _PlanningListState();
}

class _PlanningListState extends State<_PlanningList> {
  final _nextKey = GlobalKey();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    // Opens on the next event, past ones above it (Q162). Every card is
    // built (a Column, not a lazy list), so the next one always has a
    // context to scroll to.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _nextKey.currentContext;
      if (_scrolled || target == null || !target.mounted) return;
      _scrolled = true;
      Scrollable.ensureVisible(
        target,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();

    if (widget.events.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          ?widget.header,
          const SizedBox(height: 48),
          NuniEmptyState(
            icon: PhosphorIcons.calendarDots,
            message: l10n.planningEmpty,
            action: NuniButton(
              label: l10n.planningEmptyAction,
              icon: PhosphorIcons.plus,
              onPressed: () => context.push('/planning/new'),
            ),
          ),
        ],
      );
    }

    final next = nextEvent(widget.events, now);
    final children = <Widget>[?widget.header];
    int? year;
    for (final month in groupByMonth(widget.events)) {
      if (month.year != year) {
        year = month.year;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
            child: Text(
              '$year',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }
      final monthName = DateFormat.MMMM(locale)
          .format(DateTime(month.year, month.month));
      children.add(
        NuniSectionHeader(
          title: toBeginningOfSentenceCase(monthName, locale),
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
        ),
      );
      for (final event in month.events) {
        children.add(
          Padding(
            key: event.id == next?.id ? _nextKey : null,
            padding: const EdgeInsets.only(bottom: 10),
            child: EventCard(
              event: event,
              myResponse: event.responseOf(widget.myPlayerId),
              faded: isEventPast(event, now),
              onTap: () => context.push('/planning/${event.id}'),
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      // Room at the bottom for the floating button.
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
