import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:nuni/shared/nuni_legal_footer.dart';
import 'package:nuni/shared/nuni_powered_by.dart';

void main() {
  Widget buildApp(Widget child, [Locale locale = const Locale('fr')]) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('NuniPoweredBy', () {
    testWidgets('renders French mention correctly', (tester) async {
      await tester.pumpWidget(
        buildApp(const NuniPoweredBy(), const Locale('fr')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Propulsé par '), findsOneWidget);
      expect(find.textContaining('Lyon Street Golf'), findsOneWidget);
    });

    testWidgets('renders English mention correctly', (tester) async {
      await tester.pumpWidget(
        buildApp(const NuniPoweredBy(), const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Powered by '), findsOneWidget);
      expect(find.textContaining('Lyon Street Golf'), findsOneWidget);
    });
  });

  group('NuniLegalFooter', () {
    testWidgets('renders powered by mention above the 3 legal links', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(const NuniLegalFooter(), const Locale('fr')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NuniPoweredBy), findsOneWidget);
      expect(find.text('Mentions légales'), findsOneWidget);
      expect(find.text('Confidentialité'), findsOneWidget);
      expect(find.text('À propos'), findsOneWidget);

      final poweredByTop = tester.getTopLeft(find.byType(NuniPoweredBy)).dy;
      final legalLinkTop = tester.getTopLeft(find.text('Mentions légales')).dy;
      expect(poweredByTop, lessThan(legalLinkTop));
    });
  });
}
