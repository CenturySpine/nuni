import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/authorization/authorization_repository.dart';
import 'package:nuni/features/sessions/ui/other_sessions_section.dart';
import 'package:nuni/features/sessions/ui/super_admin_outsider_banner.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool isSuperAdmin = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [isSuperAdminProvider.overrideWith((ref) => isSuperAdmin)],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ListView(children: [child])),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('OtherSessionsSection (plan 38)', () {
    Widget section({List<String> items = const ['Theirs']}) =>
        OtherSessionsSection<String>(
          entries: (ref) => AsyncData(items),
          itemBuilder: Text.new,
        );

    testWidgets('lists the other sessions by default', (tester) async {
      await _pump(tester, section());
      expect(find.text('Other sessions'), findsOneWidget);
      expect(find.text('Theirs'), findsOneWidget);
    });

    testWidgets('switched off: the heading and switch stay, the list goes', (
      tester,
    ) async {
      await _pump(tester, section());
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('See every session'), findsOneWidget);
      expect(find.text('Theirs'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('nuni.show_other_sessions'), isFalse);
    });

    testWidgets('says so when there is none', (tester) async {
      await _pump(tester, section(items: const []));
      expect(find.text('No other session for now.'), findsOneWidget);
    });
  });

  group('SuperAdminOutsiderBanner (plan 38, Q277)', () {
    const message =
        "You're not part of this session. You see and edit it with your "
        'super admin rights.';

    testWidgets('a super_admin outside the session sees it', (tester) async {
      await _pump(tester, const SuperAdminOutsiderBanner(isMember: false));
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('a super_admin taking part does not', (tester) async {
      await _pump(tester, const SuperAdminOutsiderBanner(isMember: true));
      expect(find.text(message), findsNothing);
    });

    testWidgets('anyone else does not', (tester) async {
      await _pump(
        tester,
        const SuperAdminOutsiderBanner(isMember: false),
        isSuperAdmin: false,
      );
      expect(find.text(message), findsNothing);
    });
  });
}
