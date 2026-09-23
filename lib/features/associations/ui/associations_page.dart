import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/authorization/authorization_repository.dart';
import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../profile/data/profile_repository.dart';
import '../data/associations_repository.dart';
import '../domain/association.dart';
import 'association_logo.dart';

/// The associations tab (plan 18, Q85): an invitation to declare one's
/// association (or the state of my pending request), the super_admin's
/// pending requests, then every approved association -- mine first.
class AssociationsPage extends ConsumerWidget {
  const AssociationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final associationsAsync = ref.watch(associationsProvider);
    final managers = ref.watch(associationManagersProvider).value ?? const {};
    final myAssociationId = ref.watch(myPlayerProvider).value?.associationId;
    final pendingRequest = ref.watch(myPendingRequestProvider).value;
    final isSuperAdmin = ref.watch(isSuperAdminProvider).value ?? false;

    return associationsAsync.when(
      loading: () => const NuniLoading(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: NuniErrorBanner(
          message: describeError(error, l10n),
          onRetry: () => ref.invalidate(associationsProvider),
        ),
      ),
      data: (all) {
        final approved = sortForDirectory([
          for (final a in all)
            if (a.status == AssociationStatus.approved) a,
        ], myAssociationId);

        return RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(associationsProvider)
              ..invalidate(associationManagersProvider)
              ..invalidate(pendingRequestsProvider);
            await ref.read(associationsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (pendingRequest != null)
                _PendingRequestCard(association: pendingRequest)
              else
                const _DeclareCard(),
              if (isSuperAdmin) const _AdminRequestsCard(),
              const SizedBox(height: 24),
              NuniSectionHeader(
                title: l10n.associationsListTitle,
                trailing: Text(
                  '${approved.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              for (final association in approved) ...[
                NuniListCard(
                  leading: AssociationLogo(association: association),
                  title: association.name,
                  badge: association.id == myAssociationId
                      ? NuniStatusPill(
                          label: l10n.associationsMine,
                          tone: NuniTone.fairway,
                          icon: PhosphorIcons.sealCheck,
                        )
                      : null,
                  subtitle:
                      '${association.city} · '
                      '${managers[association.id]?.name ?? l10n.associationsNoManager}',
                  onTap: () => context.push('/associations/${association.id}'),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// "Votre association n'est pas dans la liste ?" (plan 18, Q85).
class _DeclareCard extends StatelessWidget {
  const _DeclareCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tone = context.nuni.primaryTone;
    return NuniCard(
      color: tone.container,
      borderColor: tone.container,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NuniIconTile(
                icon: PhosphorIcons.usersThree,
                tone: NuniTone.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.associationsDeclareTitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: tone.onContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.associationsDeclareBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          NuniButton(
            label: l10n.associationsDeclareAction,
            icon: PhosphorIcons.plus,
            onPressed: () => context.push('/associations/new'),
          ),
        ],
      ),
    );
  }
}

/// My creation request awaiting review (Q81): I can join sessions, not
/// create any, until it's approved.
class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({required this.association});

  final Association association;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tone = context.nuni.sunshine;
    return NuniCard(
      color: tone.container,
      borderColor: tone.container,
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/associations/${association.id}'),
      child: Row(
        children: [
          const NuniIconTile(
            icon: PhosphorIcons.hourglass,
            tone: NuniTone.sunshine,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.associationsPendingTitle(association.name),
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: tone.onContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.associationsPendingBody,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Super_admin only: how many requests await their review (Q86).
class _AdminRequestsCard extends ConsumerWidget {
  const _AdminRequestsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final count = ref.watch(pendingRequestsProvider).value?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: NuniListCard(
        leading: const NuniIconTile(
          icon: PhosphorIcons.shieldCheck,
          tone: NuniTone.highlight,
        ),
        title: l10n.associationsAdminPending(count),
        onTap: () => context.push('/admin/requests'),
      ),
    );
  }
}
