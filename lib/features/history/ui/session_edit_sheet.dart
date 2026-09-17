import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/weather/weather_client.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../sessions/data/sessions_repository.dart';
import '../../sessions/domain/session.dart';
import '../data/history_repository.dart';
import '../domain/schedule_validation.dart';

/// "Modifier" (plan 10, creator only): date, start/end time and comment.
/// Weather is recaptured only when the start date/time actually changes
/// (PO, 2026-09-17) -- an end-time-only edit, or saving with the same
/// start, leaves the weather already captured at kick-off untouched.
Future<bool?> showSessionEditSheet(BuildContext context, Session session) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SessionEditSheet(session: session),
    );

class SessionEditSheet extends ConsumerStatefulWidget {
  const SessionEditSheet({super.key, required this.session});

  final Session session;

  @override
  ConsumerState<SessionEditSheet> createState() => _SessionEditSheetState();
}

class _SessionEditSheetState extends ConsumerState<SessionEditSheet> {
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late final TextEditingController _commentController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final startedAt = (widget.session.startedAt ?? DateTime.now()).toLocal();
    final endedAt = (widget.session.endedAt ?? startedAt).toLocal();
    _date = DateTime(startedAt.year, startedAt.month, startedAt.day);
    _startTime = TimeOfDay.fromDateTime(startedAt);
    _endTime = TimeOfDay.fromDateTime(endedAt);
    _commentController = TextEditingController(text: widget.session.comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  DateTime get _newStartedAt => DateTime(
    _date.year,
    _date.month,
    _date.day,
    _startTime.hour,
    _startTime.minute,
  );

  DateTime get _newEndedAt => DateTime(
    _date.year,
    _date.month,
    _date.day,
    _endTime.hour,
    _endTime.minute,
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final newStartedAt = _newStartedAt;
    final newEndedAt = _newEndedAt;

    final scheduleError = validateSchedule(
      startedAt: newStartedAt,
      endedAt: newEndedAt,
      now: DateTime.now(),
    );
    if (scheduleError != null) {
      setState(() => _error = _scheduleErrorMessage(l10n, scheduleError));
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final comment = _commentController.text.trim();
      await ref
          .read(sessionsRepositoryProvider)
          .updateSchedule(
            sessionId: widget.session.id,
            startedAt: newStartedAt,
            endedAt: newEndedAt,
            comment: comment.isEmpty ? null : comment,
          );

      // Minute-granular: `newStartedAt` is built from a date + a `TimeOfDay`
      // (no seconds), but the original `startedAt` carries the sub-second
      // precision Postgres stored it with -- comparing the two directly
      // would treat every save as a "start changed" even when the picked
      // date and time both match exactly what was already there.
      final originalStartedAt = widget.session.startedAt?.toLocal();
      final startChanged =
          originalStartedAt == null ||
          !DateTime(
            originalStartedAt.year,
            originalStartedAt.month,
            originalStartedAt.day,
            originalStartedAt.hour,
            originalStartedAt.minute,
          ).isAtSameMomentAs(newStartedAt);
      if (startChanged) {
        final lat = widget.session.locationLat;
        final lng = widget.session.locationLng;
        if (lat != null && lng != null) {
          final weather = await ref
              .read(weatherClientProvider)
              .fetchArchive(lat: lat, lng: lng, date: newStartedAt);
          if (weather != null) {
            await ref
                .read(sessionsRepositoryProvider)
                .attachWeather(widget.session.id, weather);
          }
        }
      }

      ref.invalidate(historyDetailProvider(widget.session.id));
      ref.invalidate(historyEntriesProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      setState(() {
        _error = describeError(error, l10n);
        _saving = false;
      });
    }
  }

  String _scheduleErrorMessage(AppLocalizations l10n, ScheduleError error) =>
      switch (error) {
        ScheduleError.startInFuture => l10n.historyEditStartInFuture,
        ScheduleError.endInFuture => l10n.historyEditEndInFuture,
        ScheduleError.endBeforeStart => l10n.historyEditEndBeforeStart,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.historyEditTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.historyEditDateLabel),
            subtitle: Text(DateFormat.yMMMd(locale).format(_date)),
            onTap: _saving ? null : _pickDate,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.historyEditStartTimeLabel),
            subtitle: Text(_startTime.format(context)),
            onTap: _saving ? null : _pickStartTime,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.historyEditEndTimeLabel),
            subtitle: Text(_endTime.format(context)),
            onTap: _saving ? null : _pickEndTime,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.historyEditCommentLabel,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          NuniButton(label: l10n.commonSave, onPressed: _saving ? null : _save),
        ],
      ),
    );
  }
}
