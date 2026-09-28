import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuni/core/theme/app_theme.dart';
import 'package:nuni/core/theme/phosphor_icons.dart';
import 'package:nuni/core/weather/weather_client.dart';
import 'package:nuni/features/planning/domain/event.dart';
import 'package:nuni/features/planning/ui/event_forecast_widgets.dart';
import 'package:nuni/l10n/generated/app_localizations.dart';

void main() {
  final startsAt = DateTime.now().add(const Duration(days: 2));
  final hour = startsAt.toUtc();
  final time =
      '${hour.year.toString().padLeft(4, '0')}-'
      '${hour.month.toString().padLeft(2, '0')}-'
      '${hour.day.toString().padLeft(2, '0')}T'
      '${hour.hour.toString().padLeft(2, '0')}:00';

  Event event({bool located = true, Duration? inDays}) => Event(
    id: 'e',
    associationId: 'lsg',
    createdBy: 'u',
    startsAt: inDays == null ? startsAt : DateTime.now().add(inDays),
    label: 'Thursday session',
    locationLat: located ? 45.76 : null,
    locationLng: located ? 4.83 : null,
  );

  Future<int> pump(WidgetTester tester, Widget child) async {
    var calls = 0;
    final client = WeatherClient(
      httpClient: MockClient((_) async {
        calls++;
        return http.Response(
          jsonEncode({
            'hourly': {
              'time': [time],
              'temperature_2m': [14.4],
              'precipitation_probability': [30],
              'wind_speed_10m': [12.2],
              'weather_code': [61],
            },
          }),
          200,
        );
      }),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [weatherClientProvider.overrideWithValue(client)],
        child: MaterialApp(
          theme: buildAppTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return calls;
  }

  testWidgets('the card shows the forecast icon alone', (tester) async {
    await pump(tester, EventForecastPill(event: event()));
    expect(find.byIcon(PhosphorIcons.cloudRain), findsOneWidget);
    expect(find.text('14 °C'), findsNothing);
  });

  testWidgets('the page shows temperature, rain and wind', (tester) async {
    await pump(tester, EventForecastBlock(event: event()));
    expect(find.text('Forecast at start time'), findsOneWidget);
    expect(find.text('14 °C'), findsOneWidget);
    expect(find.text('30 %'), findsOneWidget);
    expect(find.text('12 km/h'), findsOneWidget);
  });

  testWidgets('nothing, and no request, without a point or beyond 7 days', (
    tester,
  ) async {
    expect(
      await pump(tester, EventForecastBlock(event: event(located: false))),
      0,
    );
    expect(find.text('Forecast at start time'), findsNothing);
    expect(
      await pump(
        tester,
        EventForecastPill(event: event(inDays: const Duration(days: 8))),
      ),
      0,
    );
    expect(find.byIcon(PhosphorIcons.cloudRain), findsNothing);
  });
}
