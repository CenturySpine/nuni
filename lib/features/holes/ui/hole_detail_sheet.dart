import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../stats/ui/hole_stats_section.dart';
import '../data/holes_repository.dart';
import '../domain/distance_format.dart';
import '../domain/hole.dart';
import 'hole_photo_thumb.dart';
import '../../../shared/nuni_photo_viewer.dart';

/// The "fiche en lecture" (plan 06): a read-only bottom sheet reached by
/// tapping a hole in the list or on the map. Editing has its own route
/// (`/holes/:id`) instead of living in this sheet.
Future<void> showHoleDetailSheet(BuildContext context, String holeId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => HoleDetailSheet(holeId: holeId),
  );
}

class HoleDetailSheet extends ConsumerWidget {
  const HoleDetailSheet({super.key, required this.holeId});

  final String holeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final holeAsync = ref.watch(holeByIdProvider(holeId));
    // Scrollable: the statistics (plan 20) make the sheet taller than
    // the screen.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: holeAsync.when(
          loading: () => const SizedBox(height: 200, child: NuniLoading()),
          error: (error, _) => NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(holeByIdProvider(holeId)),
          ),
          data: (hole) => _HoleDetailContent(hole: hole),
        ),
      ),
    );
  }
}

class _HoleDetailContent extends ConsumerWidget {
  const _HoleDetailContent({required this.hole});

  final Hole hole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.watch(holesRepositoryProvider);
    final ownerId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final isOwner = hole.ownerId == ownerId;
    final startUrl = hole.photoStartPath == null
        ? null
        : repo.photoUrl(hole.photoStartPath!);
    final endUrl = hole.photoEndPath == null
        ? null
        : repo.photoUrl(hole.photoEndPath!);
    // Tapping a photo opens both, original size, in the full-screen viewer
    // (plan 30, Q203).
    final viewerUrls = [?startUrl, ?endUrl];
    void openViewer(String url) => NuniPhotoViewer.show(
      context,
      urls: viewerUrls,
      initialIndex: viewerUrls.indexOf(url),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hole.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            NuniStatusPill(
              label: l10n.holesPar(hole.par),
              tone: NuniTone.fairway,
            ),
            if (hole.distanceM != null)
              NuniStatusPill(
                label: l10n.holesDetailLength(hole.distanceM!),
                tone: NuniTone.neutral,
              ),
            if (hole.distance != null)
              NuniStatusPill(
                label: l10n.holesAway(formatDistanceM(hole.distance!)),
                icon: PhosphorIcons.navigationArrow,
              ),
            if (!hole.hasPosition)
              NuniStatusPill(
                label: l10n.holesPositionToSet,
                tone: NuniTone.highlight,
              ),
          ],
        ),
        if (hole.description != null && hole.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            hole.description!,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        // Both slots always shown, a placeholder standing in for a missing
        // photo (PO, 2026-09-23).
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PhotoWithCaption(
                url: startUrl,
                caption: l10n.holesFormPhotoStart,
                onTap: startUrl == null ? null : () => openViewer(startUrl),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PhotoWithCaption(
                url: endUrl,
                caption: l10n.holesFormPhotoEnd,
                onTap: endUrl == null ? null : () => openViewer(endUrl),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            // Same route for both: a non-owner gets the form read-only
            // (PO, 2026-09-24), map and path included.
            Expanded(
              child: NuniButton(
                variant: NuniButtonVariant.secondary,
                icon: isOwner ? PhosphorIcons.pencilSimple : PhosphorIcons.eye,
                label: isOwner ? l10n.holesDetailEdit : l10n.holesDetailView,
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push('/holes/${hole.id}');
                },
              ),
            ),
            if (hole.hasPosition) const SizedBox(width: 10),
            // No "go there" for a hole imported without a position (plan 13).
            if (hole.hasPosition)
              Expanded(
                child: NuniButton(
                  icon: PhosphorIcons.navigationArrow,
                  label: l10n.holesDetailGoThere,
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${hole.startLat!},${hole.startLng!}',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _CloneButton(hole: hole),
        // Below the actions, so they stay in view when the sheet opens.
        const SizedBox(height: 24),
        HoleStatsSection(holeId: hole.id, par: hole.par),
      ],
    );
  }
}

/// "Cloner ce trou" (plan 26, decision 2): anyone, the owner included, makes
/// their own copy ("Clone - " + its name, photos copied, Q119), then lands on its
/// edit form to adapt it.
class _CloneButton extends ConsumerStatefulWidget {
  const _CloneButton({required this.hole});

  final Hole hole;

  @override
  ConsumerState<_CloneButton> createState() => _CloneButtonState();
}

class _CloneButtonState extends ConsumerState<_CloneButton> {
  bool _cloning = false;

  Future<void> _clone() async {
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _cloning = true);
    try {
      final cloneId = await ref
          .read(holesRepositoryProvider)
          .cloneHole(widget.hole);
      ref
        ..invalidate(myHolesProvider)
        ..invalidate(nearbyHolesProvider);
      navigator.pop();
      unawaited(router.push('/holes/$cloneId'));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(describeError(error, l10n))),
      );
      if (mounted) setState(() => _cloning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: NuniButton(
        variant: NuniButtonVariant.secondary,
        icon: PhosphorIcons.copy,
        label: l10n.holesDetailClone,
        onPressed: _cloning ? null : _clone,
      ),
    );
  }
}

class _PhotoWithCaption extends StatelessWidget {
  const _PhotoWithCaption({
    required this.url,
    required this.caption,
    this.onTap,
  });

  final String? url;
  final String caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      HolePhotoThumb(url: url, iconSize: 32, onTap: onTap),
      const SizedBox(height: 6),
      Text(caption, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
