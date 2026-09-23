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
import '../data/holes_repository.dart';
import '../domain/distance_format.dart';
import '../domain/hole.dart';
import 'hole_photo_thumb.dart';

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
    return SafeArea(
      child: Padding(
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
            NuniStatusPill(
              label: hole.visibility == HoleVisibility.public
                  ? l10n.holesFormVisibilityPublic
                  : l10n.holesFormVisibilityPrivate,
              icon: hole.visibility == HoleVisibility.public
                  ? PhosphorIcons.globe
                  : PhosphorIcons.lockSimple,
              tone: NuniTone.neutral,
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
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PhotoWithCaption(
                url: endUrl,
                caption: l10n.holesFormPhotoEnd,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (isOwner) ...[
              Expanded(
                child: NuniButton(
                  variant: NuniButtonVariant.secondary,
                  icon: PhosphorIcons.pencilSimple,
                  label: l10n.holesDetailEdit,
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push('/holes/${hole.id}');
                  },
                ),
              ),
              if (hole.hasPosition) const SizedBox(width: 10),
            ],
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
      ],
    );
  }
}

class _PhotoWithCaption extends StatelessWidget {
  const _PhotoWithCaption({required this.url, required this.caption});

  final String? url;
  final String caption;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      HolePhotoThumb(url: url, iconSize: 32),
      const SizedBox(height: 6),
      Text(caption, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
