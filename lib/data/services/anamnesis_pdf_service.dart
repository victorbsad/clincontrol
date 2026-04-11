import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/anamnesis_keys.dart';
import '../models/anamnesis.dart';
import '../models/client.dart';
import 'pdf/anamnesis_pdf_history_section.dart';
import 'pdf/anamnesis_pdf_layout.dart';
import 'pdf/anamnesis_pdf_styles.dart';
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
              _value(answers, AnamnesisKeys.maritalStatus),
              'Nacionalidade',
              _value(answers, AnamnesisKeys.nationality),
            ),
            _line('Endereço completo', _value(answers, AnamnesisKeys.address)),
            _pairLine(
              'Telefone',
              _value(answers, AnamnesisKeys.phone),
              'WhatsApp',
              _value(answers, AnamnesisKeys.whatsapp),
            ),
            _line('Email', _value(answers, AnamnesisKeys.email)),
            _pairLine(
              'Data de nascimento',
              _formatDate(_value(answers, AnamnesisKeys.dateOfBirth)),
              'Idade',
              _value(answers, AnamnesisKeys.age),
            ),
            _line('Profissão', _value(answers, AnamnesisKeys.profession)),
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
          _buildSection('Avaliação da Pele', [
            _buildSubSection('BIOTIPO CUTÂNEO', [
              _buildSubSection('Pele Oleosa (Lipídica)', [
                _pairLine(
                  'Sensível',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.oilySkinSensitive,
                  ),
                  'Resistente',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.oilySkinResistant,
                  ),
                ),
                _pairLine(
                  'Pigmentada',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.oilySkinPigmented,
                  ),
                  'Não pigmentada',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.oilySkinNonPigmented,
                  ),
                ),
                _pairLine(
                  'Firme',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinFirm),
                  'Propensa à rugas',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.oilySkinWrinkled,
                  ),
                ),
              ]),
              pw.SizedBox(height: 8),
              _buildSubSection('Pele Seca (Alípica)', [
                _pairLine(
                  'Sensível',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.drySkinSensitive,
                  ),
                  'Resistente',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.drySkinResistant,
                  ),
                ),
                _pairLine(
                  'Pigmentada',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.drySkinPigmented,
                  ),
                  'Não pigmentada',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.drySkinNonPigmented,
                  ),
                ),
                _pairLine(
                  'Firme',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.drySkinFirm),
                  'Propensa à rugas',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.drySkinWrinkled),
                ),
              ]),
              pw.SizedBox(height: 8),
              _buildSubSection('Pele Mista', [
                _pairLine(
                  'Sensível',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.combinationSkinSensitive,
                  ),
                  'Resistente',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.combinationSkinResistant,
                  ),
                ),
                _pairLine(
                  'Pigmentada',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.combinationSkinPigmented,
                  ),
                  'Não pigmentada',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.combinationSkinNonPigmented,
                  ),
                ),
                _pairLine(
                  'Firme',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.combinationSkinFirm,
                  ),
                  'Propensa à rugas',
                  _checkboxSymbolForKey(
                    answers,
                    AnamnesisKeys.combinationSkinWrinkled,
                  ),
                ),
              ]),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('ANÁLISE DETALHADA DA PELE', [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildSubSection('Pele com acne', [
                      _wrapBullets(
                        [
                          'Comedão',
                          'Pústula',
                          'Pápula',
                          'Nódulo',
                          'Hiperqueratinização',
                          'Mílium',
                          'Microcisto',
                          'Acne Inflamatória',
                          'Acne Não Inflamatória',
                        ],
                        [
                          _getAnswer(answers, AnamnesisKeys.hasComedo),
                          _getAnswer(answers, AnamnesisKeys.hasPustule),
                          _getAnswer(answers, AnamnesisKeys.hasPapule),
                          _getAnswer(answers, AnamnesisKeys.hasNodule),
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasHyperkeratinization,
                          ),
                          _getAnswer(answers, AnamnesisKeys.hasMilium),
                          _getAnswer(answers, AnamnesisKeys.hasMicrocyst),
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasInflammatoryAcne,
                          ),
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasNonInflammatoryAcne,
                          ),
                        ],
                      ),
                    ]),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _buildSubSection('Lesoes dermatologicas', [
                      _wrapBullets(
                        [
                          'Telangiectasia/ Nevo',
                          'Queratose Actínica',
                          'Nevo Melanocítico',
                          'Dermatose Papulosa Nigra',
                          'Papiloma',
                          'Acrocórdon',
                        ],
                        [
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasTelangiectasiaNevus,
                          ),
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasActinicKeratosis,
                          ),
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasMelanocyticNevus,
                          ),
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasDermatosisPapulosa,
                          ),
                          _getAnswer(answers, AnamnesisKeys.hasPapilloma),
                          _getAnswer(answers, AnamnesisKeys.hasAcrochordion),
                        ],
                      ),
                      _line(
                        'Outras',
                        _value(answers, AnamnesisKeys.hasOtherLesions),
                      ),
                    ]),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _buildSubSection('Dicromias', [
                      _wrapBullets(
                        [
                          'Hiperpimentação inflamatória',
                          'Fotoenvelhecimento',
                          'Melasma',
                          'Efelides',
                          'Hiperpigmentação orbicular',
                          'Hipocromia',
                        ],
                        [
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasInflammatoryHyperpigmentation,
                          ),
                          _getAnswer(answers, AnamnesisKeys.hasPhotoaging),
                          _getAnswer(answers, AnamnesisKeys.hasMelasma),
                          _getAnswer(answers, AnamnesisKeys.hasFreckles),
                          _getAnswer(
                            answers,
                            AnamnesisKeys.hasOrbicularHyperpigmentation,
                          ),
                          _getAnswer(answers, AnamnesisKeys.hasHypochromia),
                        ],
                      ),
                      _line(
                        'Por quê? Quanto tempo?',
                        _value(
                          answers,
                          AnamnesisKeys.chromaticAbnormalityJustification,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('FOTOTIPO', [
              _line(
                'FOTOTIPO - REATIVIDADE A LUZ ULTRAVIOLETA (Escala Fitzpatrick)',
                _value(answers, AnamnesisKeys.skinPhototype),
              ),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('OUTROS', [
              _pairLine(
                'DERMATITE',
                _checkboxSymbolForKey(answers, AnamnesisKeys.hasDermatitis),
                'PSORIASE',
                _checkboxSymbolForKey(answers, AnamnesisKeys.hasPsoriasis),
              ),
              pw.SizedBox(height: 6),
              _line(
                'TRATAMENTO INDICADO',
                _value(answers, AnamnesisKeys.treatmentIndicated),
              ),
              pw.SizedBox(height: 6),
              _line(
                'NUMERO DE SESSOES',
                _value(answers, AnamnesisKeys.numberOfSessions),
              ),
              pw.SizedBox(height: 6),
              _subTitle('CONTROLE PROCEDIMENTOS'),
              _tableHeader(['Sessão', 'Data', 'Tratamento']),
              _tableRow(
                '1ª',
                _value(answers, AnamnesisKeys.session1Date),
                _value(answers, AnamnesisKeys.session1),
              ),
              _tableRow(
                '2ª',
                _value(answers, AnamnesisKeys.session2Date),
                _value(answers, AnamnesisKeys.session2),
              ),
              _tableRow(
                '3ª',
                _value(answers, AnamnesisKeys.session3Date),
                _value(answers, AnamnesisKeys.session3),
              ),
              _tableRow(
                '4ª',
                _value(answers, AnamnesisKeys.session4Date),
                _value(answers, AnamnesisKeys.session4),
              ),
              _tableRow(
                '5ª',
                _value(answers, AnamnesisKeys.session5Date),
                _value(answers, AnamnesisKeys.session5),
              ),
              _tableRow(
                '6ª',
                _value(answers, AnamnesisKeys.session6Date),
                _value(answers, AnamnesisKeys.session6),
              ),
              _tableRow(
                '7ª',
                _value(answers, AnamnesisKeys.session7Date),
                _value(answers, AnamnesisKeys.session7),
              ),
              _tableRow(
                '8ª',
                _value(answers, AnamnesisKeys.session8Date),
                _value(answers, AnamnesisKeys.session8),
              ),
              _tableRow(
                '9ª',
                _value(answers, AnamnesisKeys.session9Date),
                _value(answers, AnamnesisKeys.session9),
              ),
              _tableRow(
                '10ª',
                _value(answers, AnamnesisKeys.session10Date),
                _value(answers, AnamnesisKeys.session10),
              ),
            ]),
            pw.SizedBox(height: 14),
            _buildSubSection('PRESCRICAO COSMETICA (home care)', [
              _line('', _value(answers, AnamnesisKeys.cosmeticPrescription)),
            ]),
          ]),
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

  String _motivoVisitaLine(Map<String, dynamic> answers) {
    return _value(answers, AnamnesisKeys.visitReason);
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
