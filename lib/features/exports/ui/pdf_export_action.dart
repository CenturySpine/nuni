import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../history/domain/history_entry.dart';
import '../../sessions/ui/scoring_mode_label.dart';
import '../domain/pdf_export.dart';

/// "Exporter en PDF" (plan 10): builds the document then hands it to
/// `printing`, which is exactly why that package was picked over generating
/// straight to bytes and rolling a download/share path by hand -- it
/// already opens the browser's native download or share flow on any
/// platform this PWA runs on.
Future<void> exportSessionPdf(
  BuildContext context,
  HistoryEntry entry, {
  required String Function(String path) photoUrl,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toString();
  final session = entry.snapshot.session;

  final titleParts = [
    if (session.city != null && session.city!.isNotEmpty) session.city!,
    if (session.zone != null && session.zone!.isNotEmpty) session.zone!,
  ];

  String? durationLine;
  final duration = entry.duration;
  if (duration != null) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    durationLine = l10n.historyExportDuration(hours, minutes);
  }

  String? weatherLine;
  final weather = session.weather;
  if (weather != null) {
    weatherLine = l10n.historyExportWeather(
      weather.temperatureC.round(),
      weather.windKph.round(),
    );
  }

  final labels = PdfExportLabels(
    title: titleParts.isEmpty ? session.code : titleParts.join(' · '),
    dateLine: session.startedAt == null
        ? ''
        : DateFormat.yMMMd(locale)
              .add_Hm()
              .format(session.startedAt!.toLocal()),
    durationLine: durationLine,
    scoringModeLine: scoringModeLabel(l10n, session.scoringMode),
    weatherLine: weatherLine,
    comment: session.comment,
    rankingTitle: l10n.sessionsLiveRankingTitle,
    strokesUnit: l10n.sessionsLiveStrokesValue(0),
    pointsUnit: l10n.sessionsLivePointsValue(0),
    footer: l10n.historyExportFooter,
    teamHeader: l10n.historyExportTeamHeader,
    totalHeader: l10n.historyExportTotalHeader,
  );

  Uint8List? coverBytes;
  final coverPath = session.coverPhotoPath;
  if (coverPath != null) {
    try {
      final response = await http
          .get(Uri.parse(photoUrl(coverPath)))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) coverBytes = response.bodyBytes;
    } catch (_) {
      // Best-effort: the PDF is still useful without the cover photo.
    }
  }

  final bytes = await buildSessionPdf(
    entry: entry,
    labels: labels,
    coverPhotoBytes: coverBytes,
  );

  await Printing.sharePdf(bytes: bytes, filename: 'nuni-${session.code}.pdf');
}
