import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';

/// Free text whose web addresses and e-mail addresses are tappable (plan 23:
/// event descriptions and comments). A web link opens in a new tab, an
/// e-mail address in the mail app.
class NuniLinkedText extends StatefulWidget {
  const NuniLinkedText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<NuniLinkedText> createState() => _NuniLinkedTextState();
}

class _NuniLinkedTextState extends State<NuniLinkedText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _onTap(Uri uri) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () => launchUrl(uri, mode: LaunchMode.externalApplication);
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final base = widget.style ?? DefaultTextStyle.of(context).style;
    final linkStyle = base.copyWith(
      color: context.nuni.primaryInk,
      decoration: TextDecoration.underline,
      decorationColor: context.nuni.primaryInk,
    );
    // Only "http(s)://" and "www." addresses: a loose match would also take
    // "tee.shot" for a link. E-mail addresses are looked for first, so that
    // "name@example.org" is never read as a web address. What is shown is
    // always the text as typed (`originText`), never a rewritten address.
    final elements = linkify(
      widget.text,
      options: const LinkifyOptions(humanize: false),
      linkifiers: const [EmailLinkifier(), UrlLinkifier()],
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final element in elements)
            ...switch (element) {
              EmailElement(:final emailAddress) => [
                TextSpan(
                  text: element.originText,
                  style: linkStyle,
                  recognizer: _onTap(Uri(scheme: 'mailto', path: emailAddress)),
                ),
              ],
              UrlElement() => _urlSpans(element, linkStyle),
              _ => [TextSpan(text: element.originText)],
            },
        ],
      ),
    );
  }

  /// A web address without the punctuation that ends a sentence after it
  /// ("see https://x.org, then..."), which the matcher keeps in the link.
  List<TextSpan> _urlSpans(UrlElement element, TextStyle linkStyle) {
    var shown = element.originText;
    var url = element.url;
    var tail = '';
    while (shown.isNotEmpty && ',;:!?)'.contains(shown[shown.length - 1])) {
      tail = shown[shown.length - 1] + tail;
      shown = shown.substring(0, shown.length - 1);
      if (url.isNotEmpty) url = url.substring(0, url.length - 1);
    }
    return [
      TextSpan(
        text: shown,
        style: linkStyle,
        recognizer: _onTap(
          Uri.parse(url.contains('://') ? url : 'https://$url'),
        ),
      ),
      if (tail.isNotEmpty) TextSpan(text: tail),
    ];
  }
}
