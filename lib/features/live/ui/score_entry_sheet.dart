import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_chip.dart';

/// Inline score entry (plan 08): chips 0-9, plus a value of 10 or more --
/// for strokes it's behind an "X" chip (rarely needed); for Free's points
/// (Q7b) it's always visible next to the chips, since points up to 20 are
/// unremarkable there. Picking a value closes the sheet immediately (PO
/// feedback, 2026-09-17: the drawer used to stay open after a tap) and
/// returns it -- the caller is the one that actually saves it (plan 08's
/// "enregistrement immédiat"), so it can show its own error handling on a
/// context that outlives this sheet.
Future<int?> showScoreEntrySheet(
  BuildContext context, {
  required String teamLabel,
  required bool isPoints,
  int? initialValue,
}) => showModalBottomSheet<int>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => ScoreEntrySheet(
    teamLabel: teamLabel,
    isPoints: isPoints,
    initialValue: initialValue,
  ),
);

class ScoreEntrySheet extends StatefulWidget {
  const ScoreEntrySheet({
    super.key,
    required this.teamLabel,
    required this.isPoints,
    this.initialValue,
  });

  final String teamLabel;
  final bool isPoints;
  final int? initialValue;

  @override
  State<ScoreEntrySheet> createState() => _ScoreEntrySheetState();
}

class _ScoreEntrySheetState extends State<ScoreEntrySheet> {
  final _customController = TextEditingController();
  bool _customFieldOpen = false;

  @override
  void initState() {
    super.initState();
    _customFieldOpen = widget.isPoints || (widget.initialValue ?? 0) > 9;
    if ((widget.initialValue ?? 0) > 9) {
      _customController.text = '${widget.initialValue}';
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _submitCustom() {
    final parsed = int.tryParse(_customController.text.trim());
    if (parsed == null || parsed < 10 || parsed > 20) return;
    Navigator.of(context).pop(parsed);
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
                  selected: widget.initialValue == v,
                  onTap: () => Navigator.of(context).pop(v),
                ),
              if (!widget.isPoints)
                NuniChip(
                  label: l10n.sessionsLiveScoreMoreChip,
                  selected: (widget.initialValue ?? 0) > 9,
                  onTap: () => setState(() => _customFieldOpen = true),
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
                  onPressed: _submitCustom,
                  icon: const Icon(PhosphorIcons.check),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
