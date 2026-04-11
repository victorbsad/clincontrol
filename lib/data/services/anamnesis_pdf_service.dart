import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/anamnesis_enums.dart';
import '../../core/constants/anamnesis_keys.dart';
import '../models/anamnesis.dart';
import '../models/client.dart';
import 'pdf/anamnesis_pdf_history_section.dart';
import 'pdf/anamnesis_pdf_layout.dart';
import 'pdf/anamnesis_pdf_skin_section.dart';
import 'pdf/pdf_theme_provider.dart';

class AnamnesisPdfService {
  const AnamnesisPdfService();

  Future<Uint8List> generate({
    required Client client,
    required Anamnesis anamnesis,
  }) async {
    final document = pw.Document(theme: await PdfThemeProvider.loadTheme());
    final answers = anamnesis.answers;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildHeader(client, anamnesis),
          pw.SizedBox(height: 16),
          _buildSection('DADOS PESSOAIS', [
            _line('Nome', client.name),
            _pairLine(
              'Estado civil',
              _clientValue(client.maritalStatus),
              'Nacionalidade',
              _clientValue(client.nationality),
            ),
            _line('Endereço completo', _clientValue(client.address)),
            _pairLine(
              'Telefone',
              _clientValue(client.phone),
              'WhatsApp',
              _clientValue(client.whatsapp),
            ),
            _line('Email', _clientValue(client.email)),
            _pairLine(
              'Data de nascimento',
              _formatDate(_clientValue(client.dateOfBirth)),
              'Idade',
              _clientValue(client.age),
            ),
            _line('Profissão', _clientValue(client.profession)),
            _line('Motivo da visita', _motivoVisitaLine(answers)),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('HISTÓRICO', [..._historicoRows(answers)]),
          pw.SizedBox(height: 20),
          pw.Text(
            '*Uso de estrogênio - não pode usar eletrolifting.',
            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
          ),
          pw.SizedBox(height: 20),
          pw.NewPage(),
          pw.SizedBox(height: 12),
          _buildSection('Avaliação da Pele', _skinSectionRows(answers)),
          pw.SizedBox(height: 20),
          _buildSignatureSection(client),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _buildHeader(Client client, Anamnesis anamnesis) {
    return AnamnesisPdfLayout.buildHeader(
      client: client,
      anamnesis: anamnesis,
      pdfSafe: _pdfSafe,
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> lines) {
    return AnamnesisPdfLayout.buildSection(title, lines);
  }

  pw.Widget _buildSubSection(String title, List<pw.Widget> lines) {
    return AnamnesisPdfLayout.buildSubSection(title, lines);
  }

  pw.Widget _line(String label, String value) {
    return AnamnesisPdfLayout.line(
      label: label,
      value: value,
      pdfSafe: _pdfSafe,
    );
  }

  pw.Widget _subTitle(String title) {
    return AnamnesisPdfLayout.subTitle(title, _pdfSafe);
  }

  pw.Widget _pairLine(
    String leftLabel,
    String leftValue,
    String rightLabel,
    String rightValue,
  ) {
    return AnamnesisPdfLayout.pairLine(
      leftLabel: leftLabel,
      leftValue: leftValue,
      rightLabel: rightLabel,
      rightValue: rightValue,
    );
  }

  List<pw.Widget> _historicoRows(Map<String, dynamic> answers) {
    return AnamnesisPdfHistorySection.build(answers);
  }

  List<pw.Widget> _skinSectionRows(Map<String, dynamic> answers) {
    return AnamnesisPdfSkinSection.build(
      answers: answers,
      buildSubSection: _buildSubSection,
      pairLine: _pairLine,
      line: _line,
      subTitle: _subTitle,
      wrapBullets: _wrapBullets,
      tableHeader: _tableHeader,
      tableRow: _tableRow,
      value: _value,
      getAnswer: _getAnswer,
      checkboxSymbolForKey: _checkboxSymbolForKey,
    );
  }

  String _motivoVisitaLine(Map<String, dynamic> answers) {
    final raw =
        answers[AnamnesisKeys.visitReasonOption]?.toString().trim() ?? '';
    if (raw == AnamnesisVisitReasonOption.other.canonical) {
      return _value(answers, AnamnesisKeys.visitReasonOther);
    }
    if (raw.isEmpty) return 'NÃO';
    return AnamnesisEnumHumanizer.humanize(
      AnamnesisKeys.visitReasonOption,
      raw,
    );
  }

  String _clientValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'NÃO';
    return trimmed;
  }

  pw.Widget _wrapBullets(List<String> labels, List<dynamic> values) {
    return AnamnesisPdfLayout.wrapBullets(
      labels: labels,
      values: values,
      checkboxSymbol: _checkboxSymbol,
    );
  }

  pw.Widget _tableHeader(List<String> columns) {
    return AnamnesisPdfLayout.tableHeader(columns);
  }

  pw.Widget _tableRow(String session, String date, String treatment) {
    return AnamnesisPdfLayout.tableRow(
      session: session,
      date: date,
      treatment: treatment,
      pdfSafe: _pdfSafe,
    );
  }

  String _value(Map<String, dynamic> answers, String key) {
    final value = answers[key];
    if (value == null) return 'NÃO';
    if (value is String && value.trim().isEmpty) return 'NÃO';
    return value.toString();
  }

  dynamic _getAnswer(Map<String, dynamic> answers, String key) {
    return answers[key];
  }

  String _checkboxSymbolForKey(Map<String, dynamic> answers, String key) {
    final value = answers[key];
    return _checkboxSymbol(value);
  }

  String _checkboxSymbol(dynamic value) {
    if (value == null) return '[ ]';
    if (value is bool) return value ? '[x]' : '[ ]';

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return '[ ]';

    if (normalized == 'true' ||
        normalized == 'sim' ||
        normalized == 'yes' ||
        normalized == 'selecionado') {
      return '[x]';
    }

    if (normalized == 'false' ||
        normalized == 'nao' ||
        normalized == 'não' ||
        normalized == 'no' ||
        normalized == 'não selecionado') {
      return '[ ]';
    }

    return '[ ]';
  }

  String _formatDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'NÃO') return value;

    final brazilianDateMatch = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (brazilianDateMatch.hasMatch(trimmed)) {
      return trimmed;
    }

    final dateOnlyMatch = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})$',
    ).firstMatch(trimmed);
    if (dateOnlyMatch != null) {
      return '${dateOnlyMatch.group(3)}/${dateOnlyMatch.group(2)}/${dateOnlyMatch.group(1)}';
    }

    try {
      final parsed = DateTime.parse(trimmed);
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      final year = parsed.year.toString().padLeft(4, '0');
      return '$day/$month/$year';
    } catch (_) {
      return value;
    }
  }

  String _pdfSafe(String value) {
    return value
        .replaceAll('\u00A0', ' ')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('’', "'")
        .replaceAll('•', '-')
        .replaceAll('☐', '[ ]')
        .replaceAll('☑', '[x]')
        .replaceAll('✓', 'v');
  }

  pw.Widget _buildSignatureSection(Client client) {
    return AnamnesisPdfLayout.buildSignatureSection(
      client: client,
      formatDate: _formatBrazilianDate,
      pdfSafe: _pdfSafe,
    );
  }

  String _formatBrazilianDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
