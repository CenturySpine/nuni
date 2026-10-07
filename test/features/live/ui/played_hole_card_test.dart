import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/theme/phosphor_icons.dart';
import 'package:nuni/features/live/domain/game_mode.dart';
import 'package:nuni/features/live/domain/played_hole.dart';
import 'package:nuni/features/live/ui/played_hole_card.dart';
import 'package:nuni/features/sessions/domain/scoring_mode.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';
import 'package:nuni/shared/nuni_icon_tile.dart';

void main() {
  Widget buildCard({String? comment}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PlayedHoleCard(
          playedHole: PlayedHole(
            id: 'ph1',
            position: 1,
            gameMode: GameMode.individual,
            par: 4,
            label: 'atelier 1',
            comment: comment,
            scores: const [],
          ),
          teams: const [],
          scoringMode: ScoringMode.strokePlay,
          canEditTeam: (_) => false,
          onScoreSubmit: (_, _, _) async {},
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );
  }

  testWidgets(
    'leading icon tile, title and action buttons align at the top even with a long comment',
    (tester) async {
      await tester.pumpWidget(
        buildCard(
          comment:
              'un\nlong\ncommentaire qui prend\nbeaucoup de place\nen hauteur',
        ),
      );
      await tester.pumpAndSettle();

      final tileTop = tester.getTopLeft(find.byType(NuniIconTile)).dy;
      final titleTop = tester.getTopLeft(find.textContaining('atelier 1')).dy;
      final gearButtonTop = tester
          .getTopLeft(find.widgetWithIcon(IconButton, PhosphorIcons.gear))
          .dy;
      final trashButtonTop = tester
          .getTopLeft(find.widgetWithIcon(IconButton, PhosphorIcons.trash))
          .dy;

      // The tile, title column, and action buttons all start at the top of the header Row.
      expect(tileTop, equals(titleTop));
      expect(tileTop, equals(gearButtonTop));
      expect(tileTop, equals(trashButtonTop));
    },
  );

  testWidgets(
    'adding a long comment does not push down the leading tile or action buttons',
    (tester) async {
      await tester.pumpWidget(buildCard(comment: null));
      await tester.pumpAndSettle();

      final tileTopNoComment = tester.getTopLeft(find.byType(NuniIconTile)).dy;
      final buttonTopNoComment = tester
          .getTopLeft(find.widgetWithIcon(IconButton, PhosphorIcons.gear))
          .dy;

      await tester.pumpWidget(
        buildCard(comment: 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6'),
      );
      await tester.pumpAndSettle();

      final tileTopWithComment = tester
          .getTopLeft(find.byType(NuniIconTile))
          .dy;
      final buttonTopWithComment = tester
          .getTopLeft(find.widgetWithIcon(IconButton, PhosphorIcons.gear))
          .dy;

      expect(tileTopWithComment, equals(tileTopNoComment));
      expect(buttonTopWithComment, equals(buttonTopNoComment));
    },
  );
}
