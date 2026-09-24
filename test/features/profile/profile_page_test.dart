import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/profile/data/profile_repository.dart';
import 'package:nuni/features/profile/domain/player.dart';
import 'package:nuni/features/profile/ui/profile_page.dart';
import 'package:nuni/features/stats/data/stats_repository.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('ProfilePage shows the loaded display name', (tester) async {
    const player = Player(id: 'p1', name: 'Ada', locale: 'en');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myPlayerProvider.overrideWith((ref) async => player),
          playerHistoryProvider('p1').overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Ada'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
