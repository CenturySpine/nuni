import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';

/// The "Powered by Lyon Street Golf" / "Propulsé par Lyon Street Golf" mention,
/// linking to https://lyonstreetgolf.fr/.
/// Displayed above legal footer links (login, settings) and on the About page.
class NuniPoweredBy extends StatefulWidget {
  const NuniPoweredBy({super.key});

  static final Uri websiteUri = Uri.parse('https://lyonstreetgolf.fr/');

  @override
  State<NuniPoweredBy> createState() => _NuniPoweredByState();
}

class _NuniPoweredByState extends State<NuniPoweredBy> {
  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()
      ..onTap = () => launchUrl(
        NuniPoweredBy.websiteUri,
        mode: LaunchMode.externalApplication,
      );
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final baseStyle = textTheme.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final linkStyle = baseStyle?.copyWith(
      color: context.nuni.primaryInk,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: context.nuni.primaryInk,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: l10n.poweredByPrefix),
          TextSpan(
            text: l10n.poweredByAssociation,
            style: linkStyle,
            recognizer: _recognizer,
            mouseCursor: SystemMouseCursors.click,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
