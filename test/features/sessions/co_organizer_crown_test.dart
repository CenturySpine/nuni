import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/theme/phosphor_icons.dart';
import 'package:nuni/features/sessions/domain/session_member.dart';
import 'package:nuni/features/sessions/ui/co_organizer_crown.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('CoOrganizerCrown (plan 37, Q271)', () {
    testWidgets('a participant: an outlined crown names them', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        CoOrganizerCrown(
          role: MemberRole.player,
          locked: false,
          onToggle: () => tapped = true,
        ),
      );
      expect(find.byIcon(PhosphorIcons.crown), findsOneWidget);
      expect(find.byTooltip('Make co-organizer'), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    });

    testWidgets('a co-organizer: a filled crown takes the role back', (
      tester,
    ) async {
      var tapped = false;
      await _pump(
        tester,
        CoOrganizerCrown(
          role: MemberRole.owner,
          locked: false,
          onToggle: () => tapped = true,
        ),
      );
      expect(find.byIcon(PhosphorIcons.crownFill), findsOneWidget);
      expect(find.byTooltip('Remove co-organizer'), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    });

    testWidgets('the creator or oneself: filled, not a button', (tester) async {
      await _pump(
        tester,
        CoOrganizerCrown(role: MemberRole.owner, locked: true, onToggle: () {}),
      );
      expect(find.byIcon(PhosphorIcons.crownFill), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
    });
  });
}
