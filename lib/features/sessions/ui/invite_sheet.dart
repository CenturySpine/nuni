import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../core/web/web_share_support.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
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

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyLink(BuildContext context, String link) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) _showSnack(context, l10n.sessionsInviteLinkCopied);
  }

  /// Checks for the Web Share API *before* calling share_plus, rather than
  /// letting it try and fall back on its own: on a browser without the API
  /// (most desktop browsers), share_plus's web fallback throws in a way
  /// that doesn't surface as a catchable Dart exception (found in testing:
  /// an unhandled promise rejection) -- pre-checking sidesteps that path
  /// entirely. The PO's call is "repli copie" (plan 09).
  Future<void> _share(BuildContext context, String link) async {
    if (!isWebShareSupported) {
      await _copyLink(context, link);
      return;
    }
    try {
      final result = await SharePlus.instance.share(ShareParams(text: link));
      if (result.status == ShareResultStatus.unavailable && context.mounted) {
        await _copyLink(context, link);
      }
    } catch (_) {
      if (context.mounted) await _copyLink(context, link);
    }
  }

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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: QrImageView(data: link, size: 200),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              code,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(letterSpacing: 4),
            ),
            const SizedBox(height: 20),
            NuniButton(
              variant: NuniButtonVariant.secondary,
              icon: PhosphorIcons.copy,
              label: l10n.sessionsInviteCopyLink,
              onPressed: () => _copyLink(context, link),
            ),
            const SizedBox(height: 12),
            NuniButton(
              icon: PhosphorIcons.shareNetwork,
              label: l10n.sessionsInviteShare,
              onPressed: () => _share(context, link),
            ),
          ],
        ),
      ),
    );
  }
}
