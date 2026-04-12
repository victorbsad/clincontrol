import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/client.dart';
import '../models/session.dart';
import 'pdf/pdf_theme_provider.dart';

class SessionHistoryPdfService {
  const SessionHistoryPdfService();

  Future<Uint8List> generate({
    required Client client,
    required List<Session> sessions,
  }) async {
    final document = pw.Document(theme: await PdfThemeProvider.loadTheme());

    final orderedSessions = [...sessions]
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalAmount = orderedSessions.fold<double>(
      0,
      (acc, session) => acc + session.amount,
    );
    final scheduledCount = orderedSessions
      .where((session) => session.status == Session.statusScheduled)
      .length;
    final paidCount = orderedSessions
      .where((session) => session.status == Session.statusPaid)
      .length;
    final canceledCount = orderedSessions
      .where((session) => session.status == Session.statusCanceled)
      .length;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'Historico de Sessoes de Atendimento',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Cliente: ${client.name}'),
          pw.Text('Telefone: ${client.phone.isEmpty ? '-' : client.phone}'),
          pw.Text('Total de sessoes: ${orderedSessions.length}'),
          pw.Text('Agendadas: $scheduledCount'),
          pw.Text('Sessoes pagas: $paidCount'),
          pw.Text('Canceladas: $canceledCount'),
          pw.Text('Valor total: R\$ ${_formatCurrency(totalAmount)}'),
          pw.SizedBox(height: 12),
          if (orderedSessions.isEmpty)
            pw.Text('Nenhuma sessao cadastrada para este cliente.')
          else
            _buildSessionsTable(orderedSessions),
          pw.SizedBox(height: 14),
          pw.Text(
            'Gerado em ${_formatNow(DateTime.now())}',
            style: pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _buildSessionsTable(List<Session> sessions) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(72),
        2: const pw.FlexColumnWidth(),
        3: const pw.FixedColumnWidth(68),
        4: const pw.FixedColumnWidth(92),
        5: const pw.FixedColumnWidth(60),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _cell('N', isHeader: true),
            _cell('Data', isHeader: true),
            _cell('Procedimento', isHeader: true),
            _cell('Status', isHeader: true),
            _cell('Observacoes', isHeader: true),
            _cell('Valor', isHeader: true),
          ],
        ),
        ...sessions.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isEven ? PdfColors.white : PdfColors.grey100,
            ),
            children: [
              _cell('${index + 1}'),
              _cell(_formatDate(session.date)),
              _cell(session.procedure),
              _cell(session.status),
              _cell(session.notes.isEmpty ? '-' : session.notes),
              _cell('R\$ ${_formatCurrency(session.amount)}'),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(isoDate);
    if (match == null) return isoDate;
    return '${match.group(3)}/${match.group(2)}/${match.group(1)}';
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatNow(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
