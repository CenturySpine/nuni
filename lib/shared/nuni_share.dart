import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../core/web/web_share_support.dart';

/// Shares [text] through the phone's share sheet (WhatsApp, SMS, mail...),
/// or copies it when the browser has none (most desktop browsers), then
/// says so with [copiedMessage] (plan 09's invitation, plan 23's events).
///
/// Checks for the Web Share API *before* calling share_plus, rather than
/// letting it try and fall back on its own: on a browser without the API,
/// share_plus's web fallback throws in a way that doesn't surface as a
/// catchable Dart exception (found in testing: an unhandled promise
/// rejection) -- pre-checking sidesteps that path entirely.
Future<void> shareOrCopy(
  BuildContext context, {
  required String text,
  required String copiedMessage,
}) async {
  if (!isWebShareSupported) {
    await copyAndConfirm(context, text: text, copiedMessage: copiedMessage);
    return;
  }
  try {
    final result = await SharePlus.instance.share(ShareParams(text: text));
    if (result.status == ShareResultStatus.unavailable && context.mounted) {
      await copyAndConfirm(context, text: text, copiedMessage: copiedMessage);
    }
  } catch (_) {
    if (context.mounted) {
      await copyAndConfirm(context, text: text, copiedMessage: copiedMessage);
    }
  }
}

/// Copies [text] to the clipboard and confirms with [copiedMessage].
Future<void> copyAndConfirm(
  BuildContext context, {
  required String text,
  required String copiedMessage,
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(copiedMessage)));
  }
}
