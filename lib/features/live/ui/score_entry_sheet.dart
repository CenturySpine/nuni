import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_chip.dart';
import '../data/live_repository.dart';

/// Inline score entry (plan 08): chips 0-9, saved immediately on tap (no
/// "Enregistrer" button). A value of 10 or more needs a numeric field --
/// for strokes it's behind an "X" chip (rarely needed); for Free's points
/// (Q7b) it's always visible next to the chips, since points up to 20 are
/// unremarkable there.
Future<void> showScoreEntrySheet(
  BuildContext context, {
  required String playedHoleId,
  required String teamId,
  required String teamLabel,
  required bool isPoints,
  int? initialValue,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => ScoreEntrySheet(
    playedHoleId: playedHoleId,
    teamId: teamId,
    teamLabel: teamLabel,
    isPoints: isPoints,
    initialValue: initialValue,
  ),
);

class ScoreEntrySheet extends ConsumerStatefulWidget {
  const ScoreEntrySheet({
    super.key,
    required this.playedHoleId,
    required this.teamId,
    required this.teamLabel,
    required this.isPoints,
    this.initialValue,
  });

  final String playedHoleId;
  final String teamId;
  final String teamLabel;
  final bool isPoints;
  final int? initialValue;

  @override
  ConsumerState<ScoreEntrySheet> createState() => _ScoreEntrySheetState();
}

class _ScoreEntrySheetState extends ConsumerState<ScoreEntrySheet> {
  final _customController = TextEditingController();
  int? _value;
  bool _saving = false;
  bool _customFieldOpen = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _customFieldOpen = widget.isPoints || (_value != null && _value! > 9);
    if (_value != null && _value! > 9) _customController.text = '$_value';
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _select(int value) async {
    setState(() {
      _value = value;
      _saving = true;
    });
    try {
      await ref
          .read(liveRepositoryProvider)
          .upsertScore(
            playedHoleId: widget.playedHoleId,
            teamId: widget.teamId,
            value: value,
          );
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _submitCustom() {
    final parsed = int.tryParse(_customController.text.trim());
    if (parsed == null || parsed < 10 || parsed > 20) return;
    _select(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          Text(widget.teamLabel, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            widget.isPoints
                ? l10n.sessionsLiveScorePointsLabel
                : l10n.sessionsLiveScoreStrokesLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var v = 0; v <= 9; v++)
                NuniChip(
                  label: '$v',
                  selected: _value == v,
                  onTap: _saving ? null : () => _select(v),
                ),
              if (!widget.isPoints)
                NuniChip(
                  label: l10n.sessionsLiveScoreMoreChip,
                  selected: _value != null && _value! > 9,
                  onTap: _saving
                      ? null
                      : () => setState(() => _customFieldOpen = true),
                ),
            ],
          ),
          if (_customFieldOpen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    autofocus: !widget.isPoints,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l10n.sessionsLiveScoreMoreFieldLabel,
                    ),
                    onSubmitted: (_) => _submitCustom(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _saving ? null : _submitCustom,
                  icon: const Icon(PhosphorIcons.check),
                ),
              ],
            ),
          ],
          if (_saving) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
