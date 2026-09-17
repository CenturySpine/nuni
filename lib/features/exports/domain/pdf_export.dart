import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../history/domain/history_entry.dart';
import 'session_export_model.dart';

/// Renders a completed session as a single A4 page (plan 10): header, one
/// column per played hole, totals, ranking, optional cover photo, footer.
/// [labels] carries every already-localized string this needs -- kept out
/// of the `pdf` package's own call tree so the caller (which has
/// `AppLocalizations`) stays the only place that resolves translations.
class PdfExportLabels {
  const PdfExportLabels({
    required this.title,
    required this.dateLine,
    required this.durationLine,
    required this.scoringModeLine,
    required this.weatherLine,
    required this.comment,
    required this.rankingTitle,
    required this.strokesUnit,
    required this.pointsUnit,
    required this.footer,
    required this.teamHeader,
    required this.totalHeader,
  });

  final String title;
  final String dateLine;
  final String? durationLine;
  final String scoringModeLine;
  final String? weatherLine;
  final String? comment;
  final String rankingTitle;
  final String strokesUnit;
  final String pointsUnit;
  final String footer;
  final String teamHeader;
  final String totalHeader;
}

Future<Uint8List> buildSessionPdf({
  required HistoryEntry entry,
  required PdfExportLabels labels,
  Uint8List? coverPhotoBytes,
}) async {
  final model = buildExportModel(entry);
  // The `pdf` package's built-in base-14 fonts only cover plain ASCII (see
  // the "no Unicode support" warning it logs otherwise) -- useless for
  // French accents or the em dash in the footer. Noto Sans, fetched once
  // through `printing`'s Google Fonts helper (cached after the first call),
  // covers both.
  final regularFont = await PdfGoogleFonts.notoSansRegular();
  final boldFont = await PdfGoogleFonts.notoSansBold();
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
  );

  String cell(int? strokes, int? points) {
    if (model.showStrokes && model.showPoints) {
      return '${strokes ?? '-'} (${points ?? '-'})';
    }
    if (model.showPoints) return '${points ?? '-'}';
    return '${strokes ?? '-'}';
  }

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    labels.title,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(labels.dateLine),
                  if (labels.durationLine != null)
                    pw.Text(labels.durationLine!),
                  pw.Text(labels.scoringModeLine),
                  if (labels.weatherLine != null) pw.Text(labels.weatherLine!),
                ],
              ),
              if (coverPhotoBytes != null)
                pw.Container(
                  width: 90,
                  height: 90,
                  decoration: pw.BoxDecoration(
                    image: pw.DecorationImage(
                      image: pw.MemoryImage(coverPhotoBytes),
                      fit: pw.BoxFit.cover,
                    ),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
          if (labels.comment != null) ...[
            pw.SizedBox(height: 6),
            pw.Text(labels.comment!, style: const pw.TextStyle(fontSize: 10)),
          ],
          pw.SizedBox(height: 14),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.2),
              for (var i = 0; i < model.holes.length; i++)
                i + 1: const pw.FlexColumnWidth(1),
              model.holes.length + 1: const pw.FlexColumnWidth(1.1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _headerCell(labels.teamHeader),
                  for (final hole in model.holes)
                    _headerCell('${hole.position}'),
                  _headerCell(labels.totalHeader),
                ],
              ),
              for (final team in model.teams)
                pw.TableRow(
                  children: [
                    _cell(team.playerNames, alignLeft: true),
                    for (final hole in model.holes)
                      _cell(
                        cell(
                          team.strokesByHoleId[hole.id],
                          team.pointsByHoleId[hole.id],
                        ),
                      ),
                    _cell(
                      cell(team.totalStrokes, team.totalPoints),
                      bold: true,
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            labels.rankingTitle,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          for (final team in model.teams)
            pw.Text(
              '${team.position}. ${team.playerNames} — '
              '${cell(team.totalStrokes, team.totalPoints)}',
            ),
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey400),
          pw.Text(
            labels.footer,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

pw.Widget _headerCell(String text) => pw.Padding(
  padding: const pw.EdgeInsets.all(4),
  child: pw.Text(
    text,
    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    textAlign: pw.TextAlign.center,
  ),
);

pw.Widget _cell(String text, {bool alignLeft = false, bool bold = false}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
      ),
    );
