import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_share.dart';
import '../../join/domain/join_link.dart';

/// "Inviter" (plan 09): code in large type, a QR code encoding the invite
/// link, "copy link" and "share" (Web Share API via share_plus, falling
/// back to copying the link when unavailable -- e.g. desktop Chrome without
/// a share target).
class InviteSheet extends StatelessWidget {
  const InviteSheet({super.key, required this.code});

  final String code;

  static Future<void> show(BuildContext context, String code) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => InviteSheet(code: code),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final link = joinUrl(code).toString();

    return SingleChildScrollView(
      // The sheet's content (QR + code + two buttons) can exceed a short
      // viewport's height (found in testing: a fixed-height Column
      // overflowed by ~90px on a 700px-tall window) -- scrollable instead
      // of a hard height budget.
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.sessionsInviteTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                // QR codes need a plain white quiet zone to scan reliably.
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(NuniRadius.card),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: QrImageView(data: link, size: 200),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              code,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(letterSpacing: 6, color: context.nuni.primaryInk),
            ),
            const SizedBox(height: 20),
            NuniButton(
              variant: NuniButtonVariant.secondary,
              icon: PhosphorIcons.copy,
              label: l10n.sessionsInviteCopyLink,
              onPressed: () => copyAndConfirm(
                context,
                text: link,
                copiedMessage: l10n.sessionsInviteLinkCopied,
              ),
            ),
            const SizedBox(height: 12),
            NuniButton(
              icon: PhosphorIcons.shareNetwork,
              label: l10n.sessionsInviteShare,
              onPressed: () => shareOrCopy(
                context,
                text: link,
                copiedMessage: l10n.sessionsInviteLinkCopied,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
