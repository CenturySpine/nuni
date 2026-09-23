import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../holes/data/holes_repository.dart';
import '../../holes/domain/distance_format.dart';
import '../../holes/domain/hole.dart';
import '../../sessions/domain/session_kind.dart';
import '../data/live_repository.dart';
import '../domain/game_mode.dart';
import 'game_mode_info_sheet.dart';
import 'game_mode_label.dart';

enum _Mode { nearby, mine }

/// "Ajouter un trou" (plan 08, owner-only): pick a hole nearby or from
/// "all my holes" (same directory as the Holes tab, plan 06), or create one
/// on the spot, or play a generic "free hole" (plan 17) -- then choose its
/// game mode and add it to the session.
Future<void> showAddPlayedHoleSheet(
  BuildContext context, {
  required String sessionId,
  required SessionKind kind,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => AddPlayedHoleSheet(sessionId: sessionId, kind: kind),
);

class AddPlayedHoleSheet extends ConsumerStatefulWidget {
  const AddPlayedHoleSheet({
    super.key,
    required this.sessionId,
    required this.kind,
  });

  final String sessionId;
  final SessionKind kind;

  @override
  ConsumerState<AddPlayedHoleSheet> createState() => _AddPlayedHoleSheetState();
}

class _AddPlayedHoleSheetState extends ConsumerState<AddPlayedHoleSheet> {
  _Mode _mode = _Mode.nearby;
  final _searchController = TextEditingController();
  String _query = '';
  int? _draggingRadiusM;
  Hole? _selectedHole;
  // Generic "free hole" picked instead of a directory hole (plan 17).
  bool _freeHole = false;
  final _labelController = TextEditingController();
  late GameMode _gameMode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _gameMode = widget.kind == SessionKind.individual
        ? GameMode.individual
        : GameMode.scramble;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _createHoleHere() async {
    final id = await context.push<String>('/holes/new');
    if (id == null || !mounted) return;
    final hole = await ref.read(holesRepositoryProvider).fetchById(id);
    ref.invalidate(nearbyHolesProvider);
    ref.invalidate(myHolesProvider);
    if (mounted) setState(() => _selectedHole = hole);
  }

  Future<void> _submit() async {
    final hole = _selectedHole;
    if (hole == null && !_freeHole) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(liveRepositoryProvider)
          .addPlayedHole(
            sessionId: widget.sessionId,
            holeId: hole?.id,
            gameMode: _gameMode,
            label: _freeHole ? _labelController.text : null,
          );
      if (mounted) Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: _selectedHole != null
            ? _buildGameModeStep(context, l10n, _selectedHole!.name)
            : _freeHole
            ? _buildGameModeStep(context, l10n, l10n.sessionsLiveFreeHole)
            : _buildPicker(context, l10n),
      ),
    );
  }

  Widget _buildPicker(BuildContext context, AppLocalizations l10n) {
    final committedRadiusM =
        ref.watch(holesRadiusProvider).value ?? holesRadiusDefaultM;
    final displayRadiusM = _draggingRadiusM ?? committedRadiusM;
    final holesAsync = _mode == _Mode.nearby
        ? ref.watch(nearbyHolesProvider(committedRadiusM))
        : ref.watch(myHolesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sessionsLiveAddHoleTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            NuniChip(
              label: l10n.holesModeNearby,
              selected: _mode == _Mode.nearby,
              onTap: () => setState(() => _mode = _Mode.nearby),
            ),
            const SizedBox(width: 8),
            NuniChip(
              label: l10n.holesModeMine,
              selected: _mode == _Mode.mine,
              onTap: () => setState(() => _mode = _Mode.mine),
            ),
          ],
        ),
        if (_mode == _Mode.nearby) ...[
          const SizedBox(height: 4),
          Slider(
            value: displayRadiusM.toDouble(),
            min: holesRadiusMinM.toDouble(),
            max: holesRadiusMaxM.toDouble(),
            divisions: (holesRadiusMaxM - holesRadiusMinM) ~/ holesRadiusStepM,
            label: formatDistanceM(displayRadiusM.toDouble()),
            onChanged: (value) =>
                setState(() => _draggingRadiusM = value.round()),
            onChangeEnd: (value) {
              setState(() => _draggingRadiusM = null);
              ref.read(holesRadiusProvider.notifier).set(value.round());
            },
          ),
        ],
        const SizedBox(height: 4),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: l10n.sessionsLiveAddHoleSearchLabel,
            prefixIcon: const Icon(PhosphorIcons.mapPin),
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 8),
        NuniButton(
          variant: NuniButtonVariant.secondary,
          icon: PhosphorIcons.plus,
          label: l10n.sessionsLiveAddHoleCreateHere,
          onPressed: _createHoleHere,
        ),
        const SizedBox(height: 8),
        // Always offered, whatever the position, radius or search (plan 17).
        ListTile(
          tileColor: Theme.of(context).colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: const Icon(PhosphorIcons.golf),
          title: Text(l10n.sessionsLiveFreeHole),
          subtitle: Text(l10n.sessionsLiveFreeHoleHint),
          onTap: () => setState(() => _freeHole = true),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: holesAsync.when(
            loading: () => const NuniLoading(),
            error: (error, _) => NuniErrorBanner(
              message: describeError(error, l10n),
              onRetry: () => ref.invalidate(
                _mode == _Mode.nearby
                    ? nearbyHolesProvider(committedRadiusM)
                    : myHolesProvider,
              ),
            ),
            data: (holes) {
              final filtered = _query.isEmpty
                  ? holes
                  : [
                      for (final hole in holes)
                        if (hole.name.toLowerCase().contains(
                          _query.toLowerCase(),
                        ))
                          hole,
                    ];
              if (filtered.isEmpty) {
                return NuniEmptyState(
                  icon: PhosphorIcons.mapPin,
                  message: _mode == _Mode.nearby
                      ? l10n.holesNoneNearby(
                          formatDistanceM(committedRadiusM.toDouble()),
                        )
                      : l10n.holesNoneMine,
                );
              }
              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final hole = filtered[index];
                  return ListTile(
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(hole.name),
                    subtitle: Text(l10n.holesPar(hole.par)),
                    trailing: hole.distance == null
                        ? null
                        : Text(formatDistanceM(hole.distance!)),
                    onTap: () => setState(() => _selectedHole = hole),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameModeStep(
    BuildContext context,
    AppLocalizations l10n,
    String title,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(PhosphorIcons.caretRight),
              onPressed: () => setState(() {
                _selectedHole = null;
                _freeHole = false;
              }),
              tooltip: l10n.commonBack,
            ),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_freeHole) ...[
          TextField(
            controller: _labelController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.sessionsLiveFreeHoleLabelField,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (widget.kind == SessionKind.team) ...[
          Row(
            children: [
              Text(
                l10n.sessionsLiveAddHoleGameModeLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              IconButton(
                icon: const Icon(PhosphorIcons.info, size: 18),
                tooltip: l10n.sessionsLiveAddHoleGameModeLabel,
                onPressed: () => showGameModeInfoSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in [
                GameMode.scramble,
                GameMode.greensome,
                GameMode.bestBall,
              ])
                NuniChip(
                  label: gameModeLabel(l10n, mode),
                  selected: _gameMode == mode,
                  onTap: () => setState(() => _gameMode = mode),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        NuniButton(
          label: l10n.sessionsLiveAddHoleSubmit,
          onPressed: _saving ? null : _submit,
        ),
      ],
    );
  }
}
