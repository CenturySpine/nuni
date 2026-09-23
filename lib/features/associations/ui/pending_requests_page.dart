import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// `/admin/requests` (plan 18, decision 9, Q86): every association creation
/// request and local-manager claim awaiting a super_admin, with the
/// requester's contact details and message, to approve or refuse.
class PendingRequestsPage extends ConsumerWidget {
  const PendingRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isSuperAdmin = ref.watch(isSuperAdminProvider).value ?? false;
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.associationsAdminTitle)),
      body: !isSuperAdmin
          ? NuniEmptyState(
              icon: PhosphorIcons.shieldCheck,
              message: l10n.associationsAdminOnly,
            )
          : requestsAsync.when(
              loading: () => const NuniLoading(),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: NuniErrorBanner(
                  message: describeError(error, l10n),
                  onRetry: () => ref.invalidate(pendingRequestsProvider),
                ),
              ),
              data: (requests) => requests.isEmpty
                  ? NuniEmptyState(
                      icon: PhosphorIcons.checkCircle,
                      message: l10n.associationsAdminEmpty,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        for (final request in requests) ...[
                          _RequestCard(request: request),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
            ),
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  const _RequestCard({required this.request});

  final PendingRequest request;

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _busy = false;

  Future<void> _decide({required bool approve}) async {
    final l10n = AppLocalizations.of(context)!;
    final request = widget.request;
    if (!approve) {
      final confirmed = await NuniConfirmDialog.show(
        context,
        title: l10n.associationsAdminRefuseTitle,
        message: l10n.associationsAdminRefuseMessage(request.requesterName),
        confirmLabel: l10n.associationsAdminRefuse,
        danger: true,
      );
      if (!confirmed || !mounted) return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(associationsRepositoryProvider);
    setState(() => _busy = true);
    try {
      if (request.isCreation) {
        await repo.reviewAssociation(request.association.id, approve: approve);
      } else {
        await repo.reviewManager(request.manager.id, approve: approve);
      }
      ref
        ..invalidate(pendingRequestsProvider)
        ..invalidate(associationsProvider)
        ..invalidate(associationManagersProvider)
        ..invalidate(myPlayerProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? l10n.associationsAdminApproved
                : l10n.associationsAdminRefused,
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
    final request = widget.request;
    final association = request.association;
    final contact = request.contact;

    return NuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NuniStatusPill(
            label: request.isCreation
                ? l10n.associationsAdminKindCreation
                : l10n.associationsAdminKindClaim,
            tone: request.isCreation ? NuniTone.highlight : NuniTone.primary,
          ),
          const SizedBox(height: 10),
          Text(association.name, style: textTheme.titleMedium),
          Text(
            [
              association.city,
              if (association.shortName != null) association.shortName!,
              if (association.websiteUrl != null) association.websiteUrl!,
            ].join(' · '),
            style: textTheme.bodySmall,
          ),
          const Divider(height: 24),
          Text(
            l10n.associationsAdminRequester(request.requesterName),
            style: textTheme.titleSmall,
          ),
          if (contact != null) ...[
            const SizedBox(height: 6),
            _ContactLine(
              icon: PhosphorIcons.envelopeSimple,
              value: contact.email,
              uri: Uri(scheme: 'mailto', path: contact.email),
            ),
            _ContactLine(
              icon: PhosphorIcons.phone,
              value: contact.phone,
              uri: Uri(scheme: 'tel', path: contact.phone),
            ),
            if (contact.requestMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.nuni.surfaceMuted,
                  borderRadius: BorderRadius.circular(NuniRadius.small),
                ),
                child: Text(
                  contact.requestMessage!,
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: NuniButton(
                  label: l10n.associationsAdminRefuse,
                  variant: NuniButtonVariant.danger,
                  onPressed: _busy ? null : () => _decide(approve: false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NuniButton(
                  label: l10n.associationsAdminApprove,
                  onPressed: _busy ? null : () => _decide(approve: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.value,
    required this.uri,
  });

  final IconData icon;
  final String value;
  final Uri uri;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => launchUrl(uri),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.nuni.primaryInk),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    ),
  );
}
