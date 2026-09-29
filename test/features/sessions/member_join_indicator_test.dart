import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/theme/app_theme.dart';
import 'package:nuni/features/sessions/domain/session_member.dart';
import 'package:nuni/features/sessions/ui/member_join_indicator.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

void main() {
  SessionMember member(String userId, {bool joined = false}) => SessionMember(
    sessionId: 's',
    userId: userId,
    role: MemberRole.player,
    checkedInAt: joined ? DateTime(2026, 9, 28) : null,
  );

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );

  testWidgets('a member who joined by the code is told apart', (tester) async {
    await pump(tester, MemberJoinIcon(member: member('a', joined: true)));
    expect(find.byTooltip('A rejoint'), findsOneWidget);
    expect(find.text('A rejoint'), findsNothing);
  });

  testWidgets('a member only added has not joined yet', (tester) async {
    await pump(tester, MemberJoinIcon(member: member('a')));
    expect(find.byTooltip('Ajouté · pas encore rejoint'), findsOneWidget);
    expect(find.text('Ajouté · pas encore rejoint'), findsNothing);
  });

  testWidgets('the header counts who joined', (tester) async {
    await pump(
      tester,
      JoinedCountPill(
        members: [member('a', joined: true), member('b'), member('c')],
      ),
    );
    expect(find.text('1 sur 3 ont rejoint'), findsOneWidget);
  });

  test('checked_in_at is read from the row', () {
    final row = SessionMember.fromJson({
      'session_id': 's',
      'user_id': 'u',
      'team_id': null,
      'role': 'player',
      'checked_in_at': '2026-09-28T10:00:00+00:00',
    });
    expect(row.hasJoined, isTrue);
    expect(
      SessionMember.fromJson({
        'session_id': 's',
        'user_id': 'u',
        'role': 'player',
      }).hasJoined,
      isFalse,
    );
  });
}
