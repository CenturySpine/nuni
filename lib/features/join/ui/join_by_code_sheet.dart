import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import 'qr_scan_page.dart';

/// "Join a session" from inside the app (home, an event's page): asks for
/// the code, typed or scanned, then goes through `/join/:code`, the same
/// flow as the invite link.
Future<void> promptJoinSession(BuildContext context) async {
  final code = await showJoinByCodeSheet(context);
  if (code != null && context.mounted) {
    context.push('/join/${code.toUpperCase()}');
  }
}

/// "Rejoindre avec un code" (plan 09, Q14): manual entry, or a QR code
/// scanned by the app itself (PO, 2026-09-29) -- the phone's own camera
/// app opens the link outside the installed app. Returns the trimmed code,
/// or null if dismissed -- the caller pushes `/join/:code`, same flow as
/// the link.
Future<String?> showJoinByCodeSheet(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _JoinByCodeSheet(),
    );

class _JoinByCodeSheet extends StatefulWidget {
  const _JoinByCodeSheet();

  @override
  State<_JoinByCodeSheet> createState() => _JoinByCodeSheetState();
}

class _JoinByCodeSheetState extends State<_JoinByCodeSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final code = value.trim();
    if (code.isEmpty) return;
    Navigator.of(context).pop(code);
  }

  Future<void> _scan() async {
    final code = await showQrScanPage(context);
    if (code != null && mounted) Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.homeJoinTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          NuniButton(
            variant: NuniButtonVariant.secondary,
            icon: PhosphorIcons.qrCode,
            label: l10n.joinScanAction,
            onPressed: _scan,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(labelText: l10n.homeJoinCodeLabel),
            onSubmitted: _submit,
          ),
          const SizedBox(height: 16),
          NuniButton(
            label: l10n.homeJoinAction,
            onPressed: () => _submit(_controller.text),
          ),
        ],
      ),
    );
  }
}
