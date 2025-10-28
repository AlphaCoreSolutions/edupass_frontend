// lib/core/utils/pdf_helper.dart
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../state/app_state.dart';
import '../../l10n/app_localizations.dart';

Future<void> generateDismissalPdf({
  required BuildContext context,
  required StudentApi student,
  required PickupRequestApi request,
}) async {
  final appState = context.read<AppState>();
  final tr = AppLocalizations.of(context)!;

  // Resolve names from lookups
  final requestTypeName = appState.detailName(request.requestTypeId);
  final statusName = appState.detailName(request.statusId);
  final reasonName = request.reasonId != null
      ? appState.detailName(request.reasonId!)
      : null;
  final genderName = appState.detailName(student.genderId);

  // ✅ Resolve requestedBy name via AppState helper (fallback to ID)
  final requestedByName =
      appState.userNameById(request.requestedById) ??
      '#${request.requestedById}';

  // Arabic font
  final fontData = await rootBundle.load(
    'lib/assets/fonts/Cairo-VariableFont_slnt,wght.ttf',
  );
  final arabicFont = pw.Font.ttf(fontData);

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Vision CIT EduPass',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  tr.dismissalCardTitle,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1.2),
              pw.SizedBox(height: 16),

              // Student info
              _rowText(arabicFont, '${tr.studentName}: ${student.name}'),
              _rowText(arabicFont, '${tr.grade}: ${student.grade}'),
              _rowText(arabicFont, '${tr.nationalId}: ${student.idNumber}'),
              _rowText(arabicFont, '${tr.gender}: $genderName'),
              if (student.imagePath != null && student.imagePath!.isNotEmpty)
                _rowText(arabicFont, '${tr.photo}: ${student.imagePath}'),

              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 12),

              // Request details
              _rowText(arabicFont, '${tr.requestType}: $requestTypeName'),
              _rowText(arabicFont, '${tr.requestedBy}: $requestedByName'),
              _rowText(
                arabicFont,
                '${tr.requestTime}: ${_formatDate(request.time)}',
              ),
              _rowText(arabicFont, '${tr.currentStatus}: $statusName'),
              if (request.exitTime != null)
                _rowText(
                  arabicFont,
                  '${tr.exit}: ${_formatDate(request.exitTime!)}',
                ),
              if (reasonName != null)
                _rowText(arabicFont, '${tr.reason}: $reasonName'),

              pw.SizedBox(height: 18),

              if (request.attachmentUrl != null &&
                  request.attachmentUrl!.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey700),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    '${tr.attachment}: ${request.attachmentUrl}',
                    style: pw.TextStyle(font: arabicFont, fontSize: 12),
                  ),
                ),

              pw.SizedBox(height: 24),

              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      tr.qrCodeLabel,
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: request.id.toString(),
                      width: 120,
                      height: 120,
                    ),
                  ],
                ),
              ),

              pw.Spacer(),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 6),
              pw.Text(
                '${tr.pdfDisclaimerLine1}\n${tr.pdfDisclaimerLine2}',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

pw.Widget _rowText(pw.Font font, String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 4),
  child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 14)),
);

String _formatDate(DateTime time) {
  final y = time.year.toString();
  final m = time.month.toString().padLeft(2, '0');
  final d = time.day.toString().padLeft(2, '0');
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');
  return '$y/$m/$d - $hh:$mm';
}
