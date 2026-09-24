import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_chip.dart';
import '../data/live_repository.dart';
import '../domain/played_hole.dart';
import 'played_hole_label.dart';

/// Allowed par values of a played hole (plan 26, Q118), mirroring the
/// `played_holes.par` check constraint.
const playedHoleParValues = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

/// The par of a played hole, picked among [playedHoleParValues] (plan 26).
/// [value] null means none chosen yet -- the case of a free hole, whose par
/// has no default (decision 5).
class PlayedHoleParPicker extends StatelessWidget {
  const PlayedHoleParPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.officialPar,
  });

  final int? value;
  final ValueChanged<int>? onChanged;

  /// The directory hole's own par, recalled under the label when set.
  final int? officialPar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.sessionsPlayedHoleParLabel, style: textTheme.labelLarge),
        if (officialPar != null)
          Text(
            l10n.sessionsPlayedHoleParHint(officialPar!),
            style: textTheme.bodySmall,
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final par in playedHoleParValues)
              NuniChip(
                label: '$par',
                selected: value == par,
                onTap: onChanged == null ? null : () => onChanged!(par),
              ),
          ],
        ),
      ],
    );
  }
}

/// The optional note of a played hole for this session (plan 26).
class PlayedHoleCommentField extends StatelessWidget {
  const PlayedHoleCommentField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: l10n.sessionsPlayedHoleCommentLabel,
        hintText: l10n.sessionsPlayedHoleCommentHint,
      ),
    );
  }
}

/// "Modifier" on a played hole (plan 26, Q121, organizer only): its par and
/// comment for this session, during the session or later from the history.
/// Returns true once saved.
Future<bool?> showPlayedHoleSettingsSheet(
  BuildContext context,
  PlayedHole playedHole,
) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => PlayedHoleSettingsSheet(playedHole: playedHole),
);

class PlayedHoleSettingsSheet extends ConsumerStatefulWidget {
  const PlayedHoleSettingsSheet({super.key, required this.playedHole});

  final PlayedHole playedHole;

  @override
  ConsumerState<PlayedHoleSettingsSheet> createState() =>
      _PlayedHoleSettingsSheetState();
}

class _PlayedHoleSettingsSheetState
    extends ConsumerState<PlayedHoleSettingsSheet> {
  late int _par;
  late final TextEditingController _commentController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _par = widget.playedHole.par;
    _commentController = TextEditingController(text: widget.playedHole.comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(liveRepositoryProvider)
          .updatePlayedHole(
            playedHoleId: widget.playedHole.id,
            par: _par,
            comment: _commentController.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
        setState(() => _saving = false);
      }
    }
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
          Text(
            l10n.sessionsLiveHoleLabel(
              widget.playedHole.position,
              playedHoleName(l10n, widget.playedHole),
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          PlayedHoleParPicker(
            value: _par,
            officialPar: widget.playedHole.hole?.par,
            onChanged: _saving ? null : (par) => setState(() => _par = par),
          ),
          const SizedBox(height: 16),
          PlayedHoleCommentField(controller: _commentController),
          const SizedBox(height: 20),
          NuniButton(label: l10n.commonSave, onPressed: _saving ? null : _save),
        ],
      ),
    );
  }
}
