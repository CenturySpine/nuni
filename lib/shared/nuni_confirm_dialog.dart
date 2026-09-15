import 'package:flutter/material.dart';

/// The app's only confirmation dialog shape (session deletion, account
/// deletion, leaving a session, ...). `danger: true` styles the confirm
/// button on the error colour.
class NuniConfirmDialog {
  const NuniConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool danger = false,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final locale = MaterialLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel ?? locale.cancelButtonLabel),
          ),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel ?? locale.okButtonLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
