import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../profile/data/profile_repository.dart';
import '../data/events_repository.dart';
import '../data/planning_rights.dart';
import '../domain/ics/ics_parser.dart';
import 'event_widgets.dart';

/// `/planning/import` (plan 23, decision 14): the local manager (or a
/// super_admin) imports an agenda file into their own association, never
/// another one (PO, 2026-09-25). The file is read on the device; the events
/// found are listed, all ticked, before anything is saved. A new import
/// replaces the previous import's coming events after a warning, never the
/// members' own (Q155, Q163).
class EventImportPage extends ConsumerStatefulWidget {
  const EventImportPage({super.key});

  @override
  ConsumerState<EventImportPage> createState() => _EventImportPageState();
}

class _EventImportPageState extends ConsumerState<EventImportPage> {
  String? _fileName;
  List<IcsEvent>? _events;
  final _selected = <int>{};
  bool _busy = false;

  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['ics', 'zip'],
      withData: true,
    );
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    try {
      final now = DateTime.now();
      final events = [
        for (final text in icsTextsFromFile(file.name, bytes))
          ...parseIcs(text, now: now),
      ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      setState(() {
        _fileName = file.name;
        _events = events;
        _selected
          ..clear()
          ..addAll(List.generate(events.length, (i) => i));
      });
    } catch (_) {
      _snack(l10n.planningImportReadError);
    }
  }

  Future<void> _import(String associationId) async {
    final l10n = AppLocalizations.of(context)!;
    final chosen = [
      for (final (index, event) in (_events ?? const <IcsEvent>[]).indexed)
        if (_selected.contains(index)) event,
    ];
    if (chosen.isEmpty) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(eventsRepositoryProvider);
      final preview = await repo.importPreview();
      if (preview.events > 0 && mounted) {
        final confirmed = await NuniConfirmDialog.show(
          context,
          title: l10n.planningImportReplaceTitle,
          message: l10n.planningImportReplaceWarning(
            preview.events,
            preview.responses,
            preview.comments,
          ),
          confirmLabel: l10n.planningImportSubmit(chosen.length),
          danger: true,
        );
        if (!confirmed) return;
      }
      final created = await repo.importEvents(
        chosen,
        untitledLabel: l10n.planningImportUntitled,
      );
      ref
        ..invalidate(myPlanningProvider)
        ..invalidate(eventLabelSuggestionsProvider(associationId));
      if (mounted) {
        _snack(l10n.planningImportDone(created));
        context.go('/planning');
      }
    } catch (error) {
      if (mounted) _snack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final associationId = ref.watch(myPlayerProvider).value?.associationId;
    final allowed =
        associationId != null &&
        (ref.watch(canModeratePlanningProvider(associationId)).value ?? false);
    final events = _events;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.planningImportTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          NuniCard(
            child: Text(l10n.planningImportHelp, style: textTheme.bodyMedium),
          ),
          const SizedBox(height: 16),
          NuniButton(
            variant: NuniButtonVariant.secondary,
            icon: PhosphorIcons.fileArrowUp,
            label: _fileName ?? l10n.planningImportPick,
            onPressed: _busy ? null : _pick,
          ),
          if (events != null) ...[
            const SizedBox(height: 16),
            if (events.isEmpty)
              NuniEmptyState(
                icon: PhosphorIcons.calendarBlank,
                message: l10n.planningImportNone,
              )
            else ...[
              Text(
                l10n.planningImportFound(events.length),
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              for (final (index, event) in events.indexed)
                CheckboxListTile(
                  value: _selected.contains(index),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (checked) => setState(
                    () => checked ?? false
                        ? _selected.add(index)
                        : _selected.remove(index),
                  ),
                  title: Text(event.label ?? l10n.planningImportUntitled),
                  subtitle: Text(
                    [
                      eventDateTimeLabel(context, event.startsAt),
                      ?event.spot,
                    ].join(' · '),
                  ),
                ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: events == null || events.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: NuniButton(
                  label: l10n.planningImportSubmit(_selected.length),
                  onPressed: _busy || !allowed || _selected.isEmpty
                      ? null
                      : () => _import(associationId),
                ),
              ),
            ),
    );
  }
}
