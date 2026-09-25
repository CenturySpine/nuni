import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/shared/nuni_linked_text.dart';

void main() {
  testWidgets('shows the text as typed, web and e-mail addresses tappable', (
    tester,
  ) async {
    const text =
        'Infos sur https://nuni.centuryspine.org, www.meteofrance.com ou '
        'contact@example.org.';
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NuniLinkedText(text))),
    );

    final rich = tester.widget<RichText>(
      find.descendant(
        of: find.byType(NuniLinkedText),
        matching: find.byType(RichText),
      ),
    );
    final root = rich.text as TextSpan;
    expect(root.toPlainText(), text);

    final links = <String?>[];
    root.visitChildren((span) {
      if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
        links.add(span.text);
      }
      return true;
    });
    expect(links, [
      'https://nuni.centuryspine.org',
      'www.meteofrance.com',
      'contact@example.org',
    ]);
  });
}
