import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/authorization/authorization_repository.dart';
import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../profile/data/profile_repository.dart';
import '../data/associations_repository.dart';
import '../domain/association.dart';
import 'association_logo.dart';
import 'claim_manager_sheet.dart';

/// Opens an association's website, adding the scheme if it was typed
/// without one ("lyonstreetgolf.fr").
Future<void> openAssociationWebsite(String url) => launchUrl(
  Uri.parse(url.contains('://') ? url : 'https://$url'),
  mode: LaunchMode.externalApplication,
);

/// `/associations/:id` (plan 18): the association's public card, and the
/// actions that apply to the viewer -- join it (Q79), claim its local
/// manager role (decision 7, Q78), edit it (its manager or a super_admin),
/// remove its manager or delete it (super_admin, Q89).
class AssociationDetailPage extends ConsumerWidget {
  const AssociationDetailPage({super.key, required this.associationId});

  final String associationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final associationAsync = ref.watch(associationByIdProvider(associationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.associationsDetailTitle)),
      body: associationAsync.when(
        loading: () => const NuniLoading(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(associationsProvider),
          ),
        ),
        data: (association) => association == null
            ? NuniEmptyState(
                icon: PhosphorIcons.usersThree,
                message: l10n.associationsNotFound,
              )
            : _Detail(association: association),
      ),
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.association});

  final Association association;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(describeError(error, l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context)!;
    final association = widget.association;
    final hasOne = ref.read(myPlayerProvider).value?.associationId != null;
    if (hasOne) {
      final confirmed = await NuniConfirmDialog.show(
        context,
        title: l10n.associationsJoinConfirmTitle(association.name),
        message: l10n.associationsJoinConfirmMessage,
        confirmLabel: l10n.associationsJoin,
      );
      if (!confirmed || !mounted) return;
    }
    await _run(() async {
      await ref.read(associationsRepositoryProvider).join(association.id);
      ref.invalidate(myPlayerProvider);
    }, l10n.associationsJoined(association.name));
  }

  Future<void> _revoke(ManagerSummary manager) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.associationsRevokeTitle,
      message: l10n.associationsRevokeMessage(
        manager.name,
        widget.association.name,
      ),
      confirmLabel: l10n.associationsRevoke,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      await ref
          .read(associationsRepositoryProvider)
          .revokeManager(manager.managerId);
      ref.invalidate(associationManagersProvider);
    }, l10n.associationsRevoked);
  }

  /// Refused by the server while the association has sessions (Q89): their
  /// scores and championships belong to other players too.
  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final association = widget.association;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.associationsDeleteTitle(association.name),
      message: l10n.associationsDeleteMessage,
      confirmLabel: l10n.associationsDelete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(associationsRepositoryProvider).delete(association.id);
      ref
        ..invalidate(associationsProvider)
        ..invalidate(associationManagersProvider)
        ..invalidate(pendingRequestsProvider)
        ..invalidate(myPlayerProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.associationsDeleted(association.name))),
      );
      router.go('/associations');
    } on PostgrestException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.message == 'association_has_sessions'
                ? l10n.associationsDeleteHasSessions
                : describeError(error, l10n),
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(describeError(error, l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final association = widget.association;
    final manager = ref
        .watch(associationManagersProvider)
        .value?[association.id];
    final player = ref.watch(myPlayerProvider).value;
    final myRows = ref.watch(myManagerRowsProvider).value ?? const [];
    final isSuperAdmin = ref.watch(isSuperAdminProvider).value ?? false;
    final myUserId = player?.userId;

    final isApproved = association.status == AssociationStatus.approved;
    final isMine = player?.associationId == association.id;
    final iAmManager = manager != null && manager.userId == myUserId;
    final myPendingClaim = myRows.any(
      (row) =>
          row.associationId == association.id &&
          row.status == AssociationManagerStatus.pending,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        NuniCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AssociationLogo(association: association, size: 88),
              const SizedBox(height: 14),
              Text(
                association.name,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (association.shortName != null) ...[
                const SizedBox(height: 2),
                Text(
                  association.shortName!,
                  style: textTheme.titleSmall?.copyWith(
                    color: context.nuni.primaryInk,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  NuniStatusPill(
                    label: association.city,
                    tone: NuniTone.neutral,
                    icon: PhosphorIcons.mapPinLine,
                  ),
                  if (isMine)
                    NuniStatusPill(
                      label: l10n.associationsMine,
                      tone: NuniTone.fairway,
                      icon: PhosphorIcons.sealCheck,
                    ),
                  if (association.status == AssociationStatus.pending)
                    NuniStatusPill(
                      label: l10n.associationsStatusPending,
                      tone: NuniTone.sunshine,
                      icon: PhosphorIcons.hourglass,
                    ),
                  if (association.status == AssociationStatus.rejected)
                    NuniStatusPill(
                      label: l10n.associationsStatusRejected,
                      tone: NuniTone.danger,
                    ),
                ],
              ),
              if (association.websiteUrl != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      openAssociationWebsite(association.websiteUrl!),
                  icon: const Icon(PhosphorIcons.globeSimple, size: 18),
                  label: Text(l10n.associationsWebsite),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        NuniCard(
          child: Row(
            children: [
              Icon(PhosphorIcons.shieldCheck, color: context.nuni.primaryInk),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.associationsManagerLabel,
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      manager?.name ?? l10n.associationsNoManager,
                      style: textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (myPendingClaim) ...[
          const SizedBox(height: 12),
          NuniStatusPill(
            label: l10n.associationsClaimPending,
            tone: NuniTone.sunshine,
            icon: PhosphorIcons.hourglass,
          ),
        ],
        const SizedBox(height: 20),
        if (isApproved && !isMine) ...[
          NuniButton(
            label: l10n.associationsJoin,
            icon: PhosphorIcons.userPlus,
            onPressed: _busy ? null : _join,
          ),
          const SizedBox(height: 10),
        ],
        if (isApproved && manager == null && !myPendingClaim) ...[
          NuniButton(
            label: l10n.associationsClaim,
            variant: NuniButtonVariant.secondary,
            icon: PhosphorIcons.shieldCheck,
            onPressed: _busy
                ? null
                : () => showClaimManagerSheet(context, association),
          ),
          const SizedBox(height: 10),
        ],
        if (iAmManager || isSuperAdmin) ...[
          NuniButton(
            label: l10n.associationsEdit,
            variant: NuniButtonVariant.secondary,
            icon: PhosphorIcons.pencilSimple,
            onPressed: _busy
                ? null
                : () => context.push('/associations/${association.id}/edit'),
          ),
          const SizedBox(height: 10),
        ],
        if (isSuperAdmin && manager != null) ...[
          NuniButton(
            label: l10n.associationsRevoke,
            variant: NuniButtonVariant.danger,
            onPressed: _busy ? null : () => _revoke(manager),
          ),
          const SizedBox(height: 10),
        ],
        if (isSuperAdmin)
          NuniButton(
            label: l10n.associationsDelete,
            variant: NuniButtonVariant.danger,
            icon: PhosphorIcons.trash,
            onPressed: _busy ? null : _delete,
          ),
      ],
    );
  }
}
