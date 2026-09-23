import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../data/associations_repository.dart';
import '../domain/association.dart';

/// "Je suis le responsable local" (plan 18, decision 7): e-mail and phone
/// (never public) plus a free message to the super_admin, who approves.
Future<void> showClaimManagerSheet(
  BuildContext context,
  Association association,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _ClaimManagerSheet(association: association),
);

class _ClaimManagerSheet extends ConsumerStatefulWidget {
  const _ClaimManagerSheet({required this.association});

  final Association association;

  @override
  ConsumerState<_ClaimManagerSheet> createState() => _ClaimManagerSheetState();
}

class _ClaimManagerSheetState extends ConsumerState<_ClaimManagerSheet> {
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();
  bool _submitted = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [_email, _phone]) {
      controller.addListener(() {
        if (_submitted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _submitted = true);
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    if (!email.contains('@') || phone.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(associationsRepositoryProvider)
          .claimManager(
            associationId: widget.association.id,
            email: email,
            phone: phone,
            message: _message.text.trim(),
          );
      ref.invalidate(myManagerRowsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.associationsClaimSent)),
      );
    } on PostgrestException catch (error) {
      final message = switch (error.message) {
        'association_has_manager' => l10n.associationsErrorHasManager,
        'claim_already_pending' => l10n.associationsErrorClaimPending,
        _ => describeError(error, l10n),
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(describeError(error, l10n))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = _email.text.trim();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.associationsClaimTitle(widget.association.name),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.associationsClaimIntro,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.associationsFieldEmail,
                errorText: !_submitted
                    ? null
                    : email.isEmpty
                    ? l10n.associationsFieldRequired
                    : (email.contains('@')
                          ? null
                          : l10n.associationsEmailInvalid),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.associationsFieldPhone,
                errorText: _submitted && _phone.text.trim().isEmpty
                    ? l10n.associationsFieldRequired
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _message,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: l10n.associationsFieldMessage,
                helperText: l10n.associationsFieldMessageHelp,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.associationsContactPrivate,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            NuniButton(
              label: l10n.associationsClaimSubmit,
              onPressed: _sending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
