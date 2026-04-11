import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/anamnesis.dart';
import '../../models/client.dart';
import 'anamnesis_pdf_styles.dart';

typedef PdfSafeText = String Function(String value);
typedef DateFormatter = String Function(DateTime date);
typedef CheckboxFormatter = String Function(dynamic value);

class AnamnesisPdfLayout {
  const AnamnesisPdfLayout._();

  static pw.Widget buildHeader({
    required Client client,
    required Anamnesis anamnesis,
    required PdfSafeText pdfSafe,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ficha de Avaliacao Facial', style: AnamnesisPdfStyles.title),
                pw.SizedBox(height: 8),
                pw.Text(pdfSafe('Cliente: ${client.name}')),
                pw.Text(pdfSafe('Gerado em: ${anamnesis.createdAt.toLocal()}')),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          _buildLogoPlaceholder(),
        ],
      ),
    );
  }

  static pw.Widget buildSection(String title, List<pw.Widget> lines) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: AnamnesisPdfStyles.subTitle),
          pw.SizedBox(height: 8),
          ...lines,
        ],
      ),
    );
  }

  static pw.Widget buildSubSection(String title, List<pw.Widget> lines) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...lines,
        ],
      ),
    );
  }

  static pw.Widget line({
    required String label,
    required String value,
    required PdfSafeText pdfSafe,
  }) {
    final displayValue = value.isEmpty ? 'NAO' : value;
    final normalizedLabel = label.trim();
    final text = normalizedLabel.isEmpty
        ? displayValue
        : '$normalizedLabel: $displayValue';

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Text(pdfSafe(text), style: AnamnesisPdfStyles.text),
    );
  }

  static pw.Widget subTitle(String title, PdfSafeText pdfSafe) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
      child: pw.Text(pdfSafe(title), style: AnamnesisPdfStyles.subTitle),
    );
  }

  static pw.Widget pairLine({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              '$leftLabel: ${leftValue.isEmpty ? 'NAO' : leftValue}',
              style: AnamnesisPdfStyles.text,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              '$rightLabel: ${rightValue.isEmpty ? 'NAO' : rightValue}',
              style: AnamnesisPdfStyles.text,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget wrapBullets({
    required List<String> labels,
    required List<dynamic> values,
    required CheckboxFormatter checkboxSymbol,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: List.generate(labels.length, (index) {
          final value = checkboxSymbol(values[index]);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              '${labels[index]}: $value',
              style: AnamnesisPdfStyles.text,
            ),
          );
        }),
      ),
    );
  }

  static pw.Widget tableHeader(List<String> columns) {
    return pw.Row(
      children: columns
          .map(
            (column) => pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey600),
                  ),
                ),
                child: pw.Text(
                  column,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  static pw.Widget tableRow({
    required String session,
    required String date,
    required String treatment,
    required PdfSafeText pdfSafe,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text(pdfSafe(session), style: AnamnesisPdfStyles.text)),
        pw.Expanded(
          child: pw.Text(
            pdfSafe(date.isEmpty ? 'NAO' : date),
            style: AnamnesisPdfStyles.text,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            pdfSafe(treatment.isEmpty ? 'NAO' : treatment),
            style: AnamnesisPdfStyles.text,
          ),
        ),
      ],
    );
  }

  static pw.Widget buildSignatureSection({
    required Client client,
    required DateFormatter formatDate,
    required PdfSafeText pdfSafe,
  }) {
    final currentDate = formatDate(DateTime.now());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Assinatura da Paciente:',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 60),
        pw.Container(width: double.infinity, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 6),
        pw.Text(pdfSafe('Nome: ${client.name}'), style: AnamnesisPdfStyles.text),
        pw.SizedBox(height: 2),
        pw.Text(pdfSafe('Data: $currentDate'), style: AnamnesisPdfStyles.text),
      ],
    );
  }

  static pw.Widget _buildLogoPlaceholder() {
    return pw.Container(
      width: 80,
      height: 80,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Center(
        child: pw.Text(
          '[Logo]',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ),
    );
  }
}
