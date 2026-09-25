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
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_grouped_list.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../../shared/nuni_status_pill.dart';
import '../../players/data/players_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player.dart';
import '../data/association_choice_skip_pref.dart';
import '../data/associations_repository.dart';
import '../domain/association.dart';
import 'admin_picker_sheet.dart';
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
/// remove its manager or delete it (super_admin, Q89) -- then its partners
/// and local admins (plan 27: named by the manager or a super_admin), then
/// its members, alphabetically, each opening their public page.
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

  /// Q146: a player goes back to no association; a local manager can't
  /// (the button isn't offered).
  Future<void> _leave({required bool iAmAdmin}) async {
    final l10n = AppLocalizations.of(context)!;
    final association = widget.association;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.associationsLeaveConfirmTitle(association.name),
      // A local admin may leave (Q171), and loses the role with it.
      message: iAmAdmin
          ? '${l10n.associationsLeaveConfirmMessage} '
                '${l10n.associationsLeaveAdminNote}'
          : l10n.associationsLeaveConfirmMessage,
      confirmLabel: l10n.associationsLeave,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      await ref.read(associationsRepositoryProvider).leave();
      // Leaving is a choice: don't bring the first sign-in choice back.
      await ref.read(associationChoiceSkippedProvider.notifier).skip();
      ref
        ..invalidate(myPlayerProvider)
        ..invalidate(associationAdminsProvider);
    }, l10n.associationsLeft(association.name));
  }

  Future<void> _addAdmin(List<Player> candidates) async {
    final l10n = AppLocalizations.of(context)!;
    final player = await showAdminPickerSheet(context, candidates);
    if (player == null || !mounted) return;
    await _run(() async {
      await ref
          .read(associationsRepositoryProvider)
          .addAdmin(widget.association.id, player.id);
      ref.invalidate(associationAdminsProvider);
    }, l10n.associationsAdminAdded(player.name));
  }

  /// Removed by the manager or a super_admin, or renounced by the admin
  /// themself (Q170).
  Future<void> _removeAdmin(Player admin, {required bool isMe}) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: isMe
          ? l10n.associationsAdminRenounceTitle
          : l10n.associationsAdminRemoveTitle(admin.name),
      message: isMe
          ? l10n.associationsAdminRenounceMessage
          : l10n.associationsAdminRemoveMessage,
      confirmLabel: isMe
          ? l10n.associationsAdminRenounce
          : l10n.associationsAdminRemove,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      await ref
          .read(associationsRepositoryProvider)
          .removeAdmin(widget.association.id, admin.id);
      ref.invalidate(associationAdminsProvider);
    }, isMe ? l10n.associationsAdminRenounced : l10n.associationsAdminRemoved);
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
    // A local manager stays in the association they manage (Q146): they
    // can neither leave it nor switch to another one.
    final iManageMine = myRows.any(
      (row) =>
          row.associationId == player?.associationId &&
          row.status == AssociationManagerStatus.approved,
    );
    final myPendingClaim = myRows.any(
      (row) =>
          row.associationId == association.id &&
          row.status == AssociationManagerStatus.pending,
    );
    final adminIds =
        ref.watch(associationAdminsProvider).value?[association.id] ??
        const <String>{};
    final iAmAdmin = player != null && adminIds.contains(player.id);
    final canNameAdmins = isApproved && (iAmManager || isSuperAdmin);

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
        if (association.partners.isNotEmpty) ...[
          const SizedBox(height: 16),
          NuniSectionHeader(title: l10n.associationsPartnersTitle),
          NuniGroupedList(
            children: [
              for (final partner in association.partners)
                ListTile(
                  title: Text(partner.label),
                  trailing: partner.url == null
                      ? null
                      : const Icon(PhosphorIcons.arrowSquareOut, size: 18),
                  onTap: partner.url == null
                      ? null
                      : () => openAssociationWebsite(partner.url!),
                ),
            ],
          ),
        ],
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
        _Admins(
          associationId: association.id,
          adminIds: adminIds,
          managerUserId: manager?.userId,
          myPlayerId: player?.id,
          canName: canNameAdmins,
          busy: _busy,
          onAdd: _addAdmin,
          onRemove: _removeAdmin,
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
        if (isApproved && !isMine && !iManageMine) ...[
          NuniButton(
            label: l10n.associationsJoin,
            icon: PhosphorIcons.userPlus,
            onPressed: _busy ? null : _join,
          ),
          const SizedBox(height: 10),
        ],
        if (isMine && !iManageMine) ...[
          NuniButton(
            label: l10n.associationsLeave,
            variant: NuniButtonVariant.secondary,
            icon: PhosphorIcons.signOut,
            onPressed: _busy ? null : () => _leave(iAmAdmin: iAmAdmin),
          ),
          const SizedBox(height: 10),
        ],
        if (iManageMine && (isMine || isApproved)) ...[
          Text(
            isMine
                ? l10n.associationsManagerCantLeave
                : l10n.associationsManagerCantSwitch,
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
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
        if (isSuperAdmin) ...[
          NuniButton(
            label: l10n.associationsDelete,
            variant: NuniButtonVariant.danger,
            icon: PhosphorIcons.trash,
            onPressed: _busy ? null : _delete,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 14),
        _Members(associationId: association.id),
      ],
    );
  }
}

/// The local admins (plan 27), public like the manager (Q174): each can
/// renounce (Q170); the manager and a super_admin add and remove them.
/// Hidden when there are none, except for those who can name one.
class _Admins extends ConsumerWidget {
  const _Admins({
    required this.associationId,
    required this.adminIds,
    required this.managerUserId,
    required this.myPlayerId,
    required this.canName,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
  });

  final String associationId;
  final Set<String> adminIds;
  final String? managerUserId;
  final String? myPlayerId;
  final bool canName;
  final bool busy;
  final void Function(List<Player> candidates) onAdd;
  final void Function(Player admin, {required bool isMe}) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final members =
        ref.watch(associationPlayersProvider(associationId)).value ??
        const <Player>[];
    final admins = [
      for (final member in members)
        if (adminIds.contains(member.id)) member,
    ];
    if (admins.isEmpty && !canName) return const SizedBox.shrink();
    final candidates = [
      for (final member in members)
        if (!adminIds.contains(member.id) && member.userId != managerUserId)
          member,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NuniSectionHeader(title: l10n.associationsAdminsTitle),
          if (canName) ...[
            Text(l10n.associationsAdminsHelp, style: textTheme.bodySmall),
            const SizedBox(height: 8),
          ],
          if (admins.isEmpty)
            NuniCard(
              child: Text(
                l10n.associationsAdminsEmpty,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            NuniGroupedList(
              children: [
                for (final admin in admins)
                  ListTile(
                    leading: NuniAvatar(
                      name: admin.name,
                      imageUrl: admin.avatarUrl,
                      size: 36,
                    ),
                    title: Text(admin.name),
                    trailing: canName && admin.id != myPlayerId
                        ? TextButton(
                            onPressed: busy
                                ? null
                                : () => onRemove(admin, isMe: false),
                            child: Text(l10n.associationsAdminRemove),
                          )
                        : null,
                    onTap: () => context.push('/players/${admin.id}'),
                  ),
              ],
            ),
          for (final admin in admins)
            if (admin.id == myPlayerId) ...[
              const SizedBox(height: 10),
              NuniButton(
                label: l10n.associationsAdminRenounce,
                variant: NuniButtonVariant.secondary,
                onPressed: busy ? null : () => onRemove(admin, isMe: true),
              ),
            ],
          if (canName) ...[
            const SizedBox(height: 10),
            NuniButton(
              label: l10n.associationsAdminAdd,
              variant: NuniButtonVariant.secondary,
              icon: PhosphorIcons.userPlus,
              onPressed: busy ? null : () => onAdd(candidates),
            ),
          ],
        ],
      ),
    );
  }
}

/// The association's players who have an account, alphabetically; a tap
/// opens the player's public page (plan 26, volet C).
class _Members extends ConsumerWidget {
  const _Members({required this.associationId});

  final String associationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final membersAsync = ref.watch(associationPlayersProvider(associationId));
    final count = membersAsync.value?.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NuniSectionHeader(
          title: l10n.associationsMembersTitle,
          trailing: count == null
              ? null
              : Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
        membersAsync.when(
          loading: () =>
              const Padding(padding: EdgeInsets.all(16), child: NuniLoading()),
          error: (error, _) => NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () =>
                ref.invalidate(associationPlayersProvider(associationId)),
          ),
          data: (players) => players.isEmpty
              ? NuniCard(
                  child: Text(
                    l10n.associationsMembersEmpty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : NuniGroupedList(
                  children: [
                    for (final player in players)
                      ListTile(
                        leading: NuniAvatar(
                          name: player.name,
                          imageUrl: player.avatarUrl,
                          size: 36,
                        ),
                        title: Text(player.name),
                        trailing: const Icon(PhosphorIcons.caretRight),
                        onTap: () => context.push('/players/${player.id}'),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
