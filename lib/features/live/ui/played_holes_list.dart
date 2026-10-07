import 'package:flutter/material.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_section_header.dart';
import '../domain/hole_order.dart';
import '../domain/played_hole.dart';

/// "Holes" above a session's played holes (plan 37), with the order
/// switch for its organizers (Q267): hole 1 on top, or the most recent on
/// top. The label says the order shown; a tap flips it for everyone.
class HolesOrderHeader extends StatelessWidget {
  const HolesOrderHeader({super.key, required this.ascending, this.onInvert});

  final bool ascending;

  /// Null for who can't change it: the header then only shows the title.
  final VoidCallback? onInvert;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NuniSectionHeader(
      title: l10n.sessionsHolesTitle,
      trailing: onInvert == null
          ? null
          : Tooltip(
              message: l10n.sessionsHolesInvert,
              child: TextButton.icon(
                icon: const Icon(PhosphorIcons.arrowsDownUp, size: 18),
                label: Text(
                  ascending
                      ? l10n.sessionsHolesOrderFirstOnTop
                      : l10n.sessionsHolesOrderLatestOnTop,
                ),
                onPressed: onInvert,
              ),
            ),
    );
  }
}

/// A session's played holes as a sliver (plan 37), in the order the session
/// shows them ([holesInDisplayOrder]); its organizers ([canReorder]) drag a
/// hole by its handle and drop it between two others (Q265). The new order
/// shows at once, until the session's next snapshot carries it; [onMove]
/// answers false when the move failed, which puts the order back.
class PlayedHolesSliver extends StatefulWidget {
  const PlayedHolesSliver({
    super.key,
    required this.holes,
    required this.ascending,
    required this.canReorder,
    required this.onMove,
    required this.itemBuilder,
  });

  final List<PlayedHole> holes;
  final bool ascending;
  final bool canReorder;
  final Future<bool> Function(String playedHoleId, int place) onMove;

  /// One hole's card; [dragHandle] is null when it can't be moved.
  final Widget Function(
    BuildContext context,
    PlayedHole hole,
    Widget? dragHandle,
  )
  itemBuilder;

  @override
  State<PlayedHolesSliver> createState() => _PlayedHolesSliverState();
}

class _PlayedHolesSliverState extends State<PlayedHolesSliver> {
  /// The order just dropped, shown until the next snapshot.
  List<String>? _pending;

  static String _signature(List<PlayedHole> holes) =>
      [for (final hole in holes) '${hole.id}:${hole.position}'].join(',');

  @override
  void didUpdateWidget(PlayedHolesSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signature(oldWidget.holes) != _signature(widget.holes) ||
        oldWidget.ascending != widget.ascending) {
      _pending = null;
    }
  }

  List<PlayedHole> get _shown {
    final ordered = holesInDisplayOrder(
      widget.holes,
      ascending: widget.ascending,
    );
    final pending = _pending;
    if (pending == null || pending.length != ordered.length) return ordered;
    final byId = {for (final hole in ordered) hole.id: hole};
    final shown = [for (final id in pending) ?byId[id]];
    return shown.length == ordered.length ? shown : ordered;
  }

  /// [newIndex] is where the hole now stands in the list shown
  /// (`onReorderItem`).
  Future<void> _reorder(
    List<PlayedHole> shown,
    int oldIndex,
    int newIndex,
  ) async {
    // Dropped back where it was: nothing to move.
    if (newIndex == oldIndex) return;
    final moved = shown[oldIndex];
    final place = coursePlaceForDrop(
      count: shown.length,
      shownIndex: newIndex,
      ascending: widget.ascending,
    );
    final ids = [for (final hole in shown) hole.id]
      ..removeAt(oldIndex)
      ..insert(newIndex, moved.id);
    setState(() => _pending = ids);
    final ok = await widget.onMove(moved.id, place);
    if (!ok && mounted) setState(() => _pending = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shown = _shown;

    Widget item(BuildContext context, int index, {required bool movable}) {
      final hole = shown[index];
      final handle = movable
          ? ReorderableDragStartListener(
              index: index,
              child: Tooltip(
                message: l10n.sessionsHolesMove,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    PhosphorIcons.dotsSixVertical,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : null;
      return Padding(
        key: ValueKey(hole.id),
        padding: const EdgeInsets.only(bottom: 12),
        child: widget.itemBuilder(context, hole, handle),
      );
    }

    if (!widget.canReorder || shown.length < 2) {
      return SliverList.builder(
        itemCount: shown.length,
        itemBuilder: (context, index) => item(context, index, movable: false),
      );
    }
    return SliverReorderableList(
      itemCount: shown.length,
      itemBuilder: (context, index) => item(context, index, movable: true),
      onReorderItem: (oldIndex, newIndex) =>
          _reorder(shown, oldIndex, newIndex),
      proxyDecorator: (child, index, animation) =>
          Material(type: MaterialType.transparency, child: child),
    );
  }
}
