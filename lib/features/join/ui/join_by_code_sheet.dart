import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';

/// "Rejoindre avec un code" (plan 09, Q14): manual entry, for when the code
/// wasn't received as a link or a QR. Returns the trimmed code, or null if
/// dismissed -- the caller pushes `/join/:code`, same flow as the link.
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeJoinTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
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
