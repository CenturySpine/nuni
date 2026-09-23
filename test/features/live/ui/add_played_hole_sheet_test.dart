import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/holes/data/holes_repository.dart';
import 'package:nuni/features/live/ui/add_played_hole_sheet.dart';
import 'package:nuni/features/sessions/domain/session_kind.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

class _FixedHolesRadius extends HolesRadius {
  @override
  Future<int> build() async => holesRadiusDefaultM;
}

void main() {
  testWidgets(
    'offers "Free hole" with no position and no hole nearby, then asks for '
    'an optional name (plan 17)',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myPositionProvider.overrideWith((ref) async => null),
            holesRadiusProvider.overrideWith(() => _FixedHolesRadius()),
            nearbyHolesProvider.overrideWith((ref, radiusM) async => const []),
            myHolesProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AddPlayedHoleSheet(
                sessionId: 's1',
                kind: SessionKind.individual,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No holes within 1.0 km.'), findsOneWidget);
      expect(find.text('Free hole'), findsOneWidget);

      await tester.tap(find.text('Free hole'));
      await tester.pumpAndSettle();

      expect(find.text('Name (optional)'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    },
  );
}
