import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../data/holes_repository.dart';
import '../domain/distance_format.dart';
import '../domain/hole.dart';

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
        padding: const EdgeInsets.all(16),
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
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: hole.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextSpan(
                      text:
                          ' · ${[l10n.holesPar(hole.par), if (hole.distanceM != null) l10n.holesDetailLength(hole.distanceM!), if (hole.distance != null) l10n.holesAway(formatDistanceM(hole.distance!))].join(' · ')}',
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              hole.visibility == HoleVisibility.public
                  ? PhosphorIcons.globe
                  : PhosphorIcons.lockSimple,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
        if (hole.description != null && hole.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(hole.description!),
        ],
        if (startUrl != null || endUrl != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (startUrl != null) Expanded(child: _Photo(url: startUrl)),
              if (startUrl != null && endUrl != null) const SizedBox(width: 8),
              if (endUrl != null) Expanded(child: _Photo(url: endUrl)),
            ],
          ),
        ],
        const SizedBox(height: 16),
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
              const SizedBox(width: 8),
            ],
            Expanded(
              child: NuniButton(
                icon: PhosphorIcons.navigationArrow,
                label: l10n.holesDetailGoThere,
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=${hole.startLat},${hole.startLng}',
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

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: AspectRatio(
      aspectRatio: 1,
      child: Image.network(url, fit: BoxFit.cover),
    ),
  );
}
