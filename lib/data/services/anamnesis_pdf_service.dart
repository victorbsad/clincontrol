import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/anamnesis.dart';
import '../models/client.dart';

class AnamnesisPdfService {
  const AnamnesisPdfService();

  Future<Uint8List> generate({
    required Client client,
    required Anamnesis anamnesis,
  }) async {
    final document = pw.Document();
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
            _pairLine('Estado civil', _value(answers, 'estadoCivil'), 'Nacionalidade', _value(answers, 'nacionalidade')),
            _line('Endereço completo', _value(answers, 'endereco')),
            _pairLine('Telefone', _value(answers, 'telefone'), 'WhatsApp', _value(answers, 'whatsapp')),
            _line('Email', _value(answers, 'email')),
            _pairLine('Data de nascimento', _formatDate(_value(answers, 'dataNascimento')), 'Idade', _value(answers, 'idade')),
            _line('Profissão', _value(answers, 'profissao')),
            _line('Motivo da visita', _motivoVisitaLine(answers)),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('HISTÓRICO', [
            ..._historicoRows(answers),
          ]),
          pw.SizedBox(height: 20),
          pw.Text('*Uso de Estrogênio - não pode usar eletrolifting.', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
          pw.SizedBox(height: 20),
          pw.NewPage(),
          pw.SizedBox(height: 12),
          _buildSection('Avaliação da Pele', [
            _buildSubSection('BIOTIPO CUTÂNEO', [
              _buildSubSection('Pele Oleosa (Lipídica)', [
                _pairLine('Sensível', _checkboxSymbol(answers['peleOleosaSensivel']), 'Resistente', _checkboxSymbol(answers['peleOleosaResistente'])),
                _pairLine('Pigmentada', _checkboxSymbol(answers['peleOleosaPigmentada']), 'Não pigmentada', _checkboxSymbol(answers['peleOleosaNaoPigmentada'])),
                _pairLine('Firme', _checkboxSymbol(answers['peleOleosaFirme']), 'Propensa à rugas', _checkboxSymbol(answers['peleOleosaRugas'])),
              ]),
              pw.SizedBox(height: 8),
              _buildSubSection('Pele Seca (Alípica)', [
                _pairLine('Sensível', _checkboxSymbol(answers['peleSecaSensivel']), 'Resistente', _checkboxSymbol(answers['peleSecaResistente'])),
                _pairLine('Pigmentada', _checkboxSymbol(answers['peleSecaPigmentada']), 'Não pigmentada', _checkboxSymbol(answers['peleSecaNaoPigmentada'])),
                _pairLine('Firme', _checkboxSymbol(answers['peleSecaFirme']), 'Propensa à rugas', _checkboxSymbol(answers['peleSecaRugas'])),
              ]),
              pw.SizedBox(height: 8),
              _buildSubSection('Pele Mista', [
                _pairLine('Sensível', _checkboxSymbol(answers['peleMistaSensivel']), 'Resistente', _checkboxSymbol(answers['peleMistaResistente'])),
                _pairLine('Pigmentada', _checkboxSymbol(answers['peleMistaPigmentada']), 'Não pigmentada', _checkboxSymbol(answers['peleMistaNaoPigmentada'])),
                _pairLine('Firme', _checkboxSymbol(answers['peleMistaFirme']), 'Propensa à rugas', _checkboxSymbol(answers['peleMistaRugas'])),
              ]),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('ANÁLISE DETALHADA DA PELE', [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildSubSection('Pele com acne', [
                      _wrapBullets(['Comedão', 'Pústula', 'Pápula', 'Nódulo', 'Hiperqueratinização', 'Mílium', 'Microcisto', 'Acne Inflamatória', 'Acne Não Inflamatória'], [
                        answers['comedao'],
                        answers['pustula'],
                        answers['papula'],
                        answers['nodulo'],
                        answers['hiperqueratinizacao'],
                        answers['milium'],
                        answers['microcisto'],
                        answers['acneInflamatoria'],
                        answers['acneNaoInflamatoria'],
                      ]),
                    ]),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _buildSubSection('Lesoes dermatologicas', [
                      _wrapBullets(['Telangiectasia/ Nevo', 'Queratose Actínica', 'Nevo Melanocítico', 'Dermatose Papulosa Nigra', 'Papiloma', 'Acrocórdon'], [
                        answers['telangiectasiaNevo'],
                        answers['queratoseActinica'],
                        answers['nevoMelanocitico'],
                        answers['dermatosePapulosaNigra'],
                        answers['papiloma'],
                        answers['acrocordon'],
                      ]),
                      _line('Outras', _value(answers, 'outrasLesoes')),
                    ]),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _buildSubSection('Dicromias', [
                      _wrapBullets(['Hiperpimentação inflamatória', 'Fotoenvelhecimento', 'Melasma', 'Efelides', 'Hiperpigmentação orbicular', 'Hipocromia'], [
                        answers['hiperpigmentacaoInflamatoria'],
                        answers['fotoenvelhecimento'],
                        answers['melasma'],
                        answers['efelides'],
                        answers['hiperpigmentacaoOrbicular'],
                        answers['hipocromia'],
                      ]),
                      _line('Por quê? Quanto tempo?', _value(answers, 'discromiaJustificativa')),
                    ]),
                  ),
                ],
              ),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('FOTOTIPO', [
              _line('FOTOTIPO - REATIVIDADE A LUZ ULTRAVIOLETA (Escala Fitzpatrick)', _value(answers, 'fototipo')),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('OUTROS', [
              _pairLine('DERMATITE', _checkboxSymbol(answers['dermatite']), 'PSORIASE', _checkboxSymbol(answers['psoriase'])),
              pw.SizedBox(height: 6),
              _line('TRATAMENTO INDICADO', _value(answers, 'tratamentoIndicado')),
              pw.SizedBox(height: 6),
              _line('NUMERO DE SESSOES', _value(answers, 'numeroSessoes')),
              pw.SizedBox(height: 6),
              _subTitle('CONTROLE PROCEDIMENTOS'),
              _tableHeader(['Sessão', 'Data', 'Tratamento']),
              _tableRow('1ª', _value(answers, 'sessao1Data'), _value(answers, 'sessao1')),
              _tableRow('2ª', _value(answers, 'sessao2Data'), _value(answers, 'sessao2')),
              _tableRow('3ª', _value(answers, 'sessao3Data'), _value(answers, 'sessao3')),
              _tableRow('4ª', _value(answers, 'sessao4Data'), _value(answers, 'sessao4')),
              _tableRow('5ª', _value(answers, 'sessao5Data'), _value(answers, 'sessao5')),
              _tableRow('6ª', _value(answers, 'sessao6Data'), _value(answers, 'sessao6')),
              _tableRow('7ª', _value(answers, 'sessao7Data'), _value(answers, 'sessao7')),
              _tableRow('8ª', _value(answers, 'sessao8Data'), _value(answers, 'sessao8')),
              _tableRow('9ª', _value(answers, 'sessao9Data'), _value(answers, 'sessao9')),
              _tableRow('10ª', _value(answers, 'sessao10Data'), _value(answers, 'sessao10')),
            ]),
            pw.SizedBox(height: 14),
            _buildSubSection('PRESCRICAO COSMETICA (home care)', [
              _line('', _value(answers, 'prescricaoCosmetica')),
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
                pw.Text('Ficha de Avaliação Facial', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(_pdfSafe('Cliente: ${client.name}')),
                pw.Text(_pdfSafe('Gerado em: ${anamnesis.createdAt.toLocal()}')),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          _buildLogoPlaceholder(),
        ],
      ),
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> lines) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...lines,
        ],
      ),
    );
  }

  pw.Widget _buildSubSection(String title, List<pw.Widget> lines) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ...lines,
        ],
      ),
    );
  }

  pw.Widget _line(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Text(_pdfSafe('$label: ${value.isEmpty ? 'NÃO' : value}'), style: const pw.TextStyle(fontSize: 9)),
    );
  }

  pw.Widget _subTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
      child: pw.Text(
        _pdfSafe(title),
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pairLine(String leftLabel, String leftValue, String rightLabel, String rightValue) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text('$leftLabel: ${leftValue.isEmpty ? 'NÃO' : leftValue}', style: const pw.TextStyle(fontSize: 9))),
          pw.SizedBox(width: 12),
          pw.Expanded(child: pw.Text('$rightLabel: ${rightValue.isEmpty ? 'NÃO' : rightValue}', style: const pw.TextStyle(fontSize: 9))),
        ],
      ),
    );
  }

  pw.Widget _stackedQuestion(String label, String value, String subLabel, String subValue) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$label: ${value.isEmpty ? 'NÃO' : value}', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 2),
          pw.Text('$subLabel: ${subValue.isEmpty ? 'NÃO' : subValue}', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  List<pw.Widget> _historicoRows(Map<String, dynamic> answers) {
    final alergiasText = _value(answers, 'alergias');

    final rows = <pw.Widget>[
      _yesNoRow(
        _yesNoQuestion('Já fez algum tratamento estético ou dermatológico?', answers['tratamentoEstetico'], 'Qual?', _value(answers, 'qualTratamentoEstetico')),
        _yesNoQuestion('Problema de cicatrização ou Quelóide?', answers['cicatrizacaoQuelóide'], 'Comente:', _value(answers, 'cicatrizacaoComentario')),
      ),
      _yesNoRow(
        _yesNoQuestion('Faz uso de algum medicamento?', answers['usaMedicamento'], 'Qual?', _value(answers, 'qualMedicamento')),
        _yesNoQuestion('Usou Isotretinoína (Roacutan) nos últimos 6 meses?', answers['isotretinoina6m'], '', _value(answers, 'isotretinoina6mObs')),
      ),
      _yesNoRow(
        _yesNoQuestion('Tratamento médico ou problema de saúde?', answers['tratamentoMedico'], 'Qual?', _value(answers, 'qualProblemaSaude')),
        _yesNoQuestion('Apresenta trombose ou tromboflebite?', answers['trombose'], 'Local?', _value(answers, 'localTrombose')),
      ),
      _yesNoRow(
        _yesNoQuestion('Já fez alguma cirurgia?', answers['cirurgia'], 'Qual?', _value(answers, 'qualCirurgia')),
        _yesNoQuestion('Antecedentes oncológicos?', answers['oncologico'], '', _value(answers, 'oncologicoObs')),
      ),
      _yesNoRow(
        _yesNoQuestion('Doença infectocontagiosa?', answers['infectocontagiosa'], 'Qual?', _value(answers, 'qualInfectocontagiosa')),
        _yesNoQuestion('Pratica algum esporte?', answers['esporte'], '', _value(answers, 'esporteObs')),
      ),
      _yesNoRow(
        _yesNoQuestion('Alimentação balanceada?', answers['alimentacaoBalanceada'], '', _value(answers, 'alimentacaoObs')),
        _yesNoQuestion('Ingere no mínimo 2 litros de água por dia?', answers['agua2l'], 'Quantos litros?', _value(answers, 'quantosLitrosAgua')),
      ),
      _yesNoRow(
        _yesNoQuestion('Faz uso de bebida alcoólica?', answers['alcool'], 'Frequência?', _value(answers, 'frequenciaAlcool')),
        _yesNoQuestion('Faz uso de substâncias químicas ou entorpecentes?', answers['drogas'], 'Qual?', _value(answers, 'qualSubstancia')),
      ),
      _yesNoRow(
        _yesNoQuestion('Distúrbio hormonal?', answers['disturbioHormonal'], 'Qual?', _value(answers, 'qualDisturbioHormonal')),
        _yesNoQuestion('Dorme bem?', answers['dormeBem'], 'Horas de sono:', _value(answers, 'horasSono')),
      ),
      _yesNoRow(
        _yesNoQuestion('Funcionamento intestinal regular?', answers['intestinoRegular'], '', _value(answers, 'intestinoObs')),
        _yesNoQuestion('Diabetes?', answers['diabetes'], 'Compensada/descompensada?', _value(answers, 'diabetesCompensada')),
      ),
      _yesNoRow(
        _yesNoQuestion('Tem problemas cardíacos?', answers['cardiaco'], 'Qual?', _value(answers, 'qualCardiaco')),
        _yesNoQuestion('Depressão?', answers['depressao'], 'Faz tratamento?', _value(answers, 'tratamentoDepressao')),
      ),
      _yesNoRow(
        _yesNoQuestion('Portador de Epilepsia?', answers['epilepsia'], '', _value(answers, 'epilepsiaObs')),
        _yesNoQuestion('Possui placas e pinos metálicos na face?', answers['placasPinos'], 'Onde?', _value(answers, 'ondePlacasPinos')),
      ),
      _yesNoRow(
        _yesNoQuestion('Próteses dentárias?', answers['protesesDentarias'], '', _value(answers, 'protesesObs')),
        _yesNoQuestion('Faz uso de lentes de contato?', answers['lentesContato'], '', _value(answers, 'lentesObs')),
      ),
      _yesNoRow(
        _yesNoQuestion('Já fez ou faz uso de ácidos na pele?', answers['acidosPele'], 'Qual?', _value(answers, 'qualAcido')),
        _yesNoQuestion('Faz uso de cosméticos?', answers['cosmeticos'], 'Quais?', _value(answers, 'quaisCosmeticos')),
      ),
      _yesNoRow(
        _yesNoQuestion('Faz uso de protetor solar?', answers['protetorSolar'], 'Qual?', '${_value(answers, 'qualProtetorSolar')} Frequência? ${_value(answers, 'frequenciaProtetorSolar')}'),
        _yesNoQuestion('Costuma tomar sol?', answers['tomaSol'], 'Frequência?', _value(answers, 'frequenciaSol')),
      ),
      _yesNoRow(
        _yesNoQuestion('Fez maquiagem definitiva?', answers['maquiagemDefinitiva'], 'Local?', _value(answers, 'localMaquiagemDefinitiva')),
        _yesNoQuestion('Fez aplicação de Metacril ou Toxina Botulínica?', answers['toxinaBotulinica'], 'Local?', _value(answers, 'localToxina')),
      ),
      _yesNoRow(
        _yesNoQuestion('Alergias? (alimentar, cheiro, respiratória, corantes, medicamentos, etc)', _hasMeaningfulValue(alergiasText), 'Especificar:', alergiasText),
        _yesNoQuestion('Gestante?', answers['gestante'], 'Quantos meses?', _value(answers, 'mesesGestacao')),
      ),
      _yesNoRow(
        _yesNoQuestion('Filhos?', answers['filhos'], 'Quantos?', _value(answers, 'quantidadeFilhos')),
        _yesNoQuestion('Ciclo menstrual regular?', answers['cicloRegular'], 'Obs.:', _value(answers, 'obsCiclo')),
      ),
      _yesNoRow(
        _yesNoQuestion('Já teve herpes?', answers['herpes'], 'A quanto tempo?', _value(answers, 'tempoHerpes')),
        _yesNoQuestion('Faz uso de anticoncepcional?', answers['anticoncepcional'], 'Qual?', _value(answers, 'qualAnticoncepcional')),
      ),
      _yesNoRow(
        _yesNoQuestion('Faz uso de hormônio?*', answers['hormonio'], 'Qual?', _value(answers, 'qualHormônio')),
        _yesNoQuestion('Autoriza divulgação de foto antes/após tratamento?', answers['autorizacaoFoto'], '', _value(answers, 'autorizacaoFotoObs')),
      ),
      _subTitle('Fuma ou Fumou'),
      _stackedQuestion('Fuma', _value(answers, 'fumaOuFumou'), 'Quanto tempo?', _value(answers, 'tempoTabagismo')),
      _pressureQuestion(answers),
    ];

    return rows;
  }

  pw.Widget _yesNoRow(pw.Widget left, pw.Widget right) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: left),
          pw.SizedBox(width: 12),
          pw.Expanded(child: right),
        ],
      ),
    );
  }

  pw.Widget _yesNoQuestion(String question, dynamic rawAnswer, String commentLabel, String commentValue) {
    final selection = _toYesNoSelection(rawAnswer);
    final isYes = selection == true;
    final text = isYes ? 'SIM' : 'NÃO';
    final hasComment = _hasMeaningfulValue(commentValue);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          question,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
        if (isYes && commentLabel.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(
              _pdfSafe('$commentLabel ${hasComment ? commentValue : 'NÃO INFORMADO'}'),
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
      ],
    );
  }

  String _motivoVisitaLine(Map<String, dynamic> answers) {
    return _value(answers, 'motivoVisita');
  }

  pw.Widget _wrapBullets(List<String> labels, List<dynamic> values) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: List.generate(labels.length, (index) {
          final value = _checkboxSymbol(values[index]);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text('${labels[index]}: $value', style: const pw.TextStyle(fontSize: 9)),
          );
        }),
      ),
    );
  }

  pw.Widget _tableHeader(List<String> columns) {
    return pw.Row(
      children: columns
          .map(
            (column) => pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey600)),
                ),
                child: pw.Text(column, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _tableRow(String session, String date, String treatment) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text(_pdfSafe(session), style: const pw.TextStyle(fontSize: 9))),
        pw.Expanded(child: pw.Text(_pdfSafe(date.isEmpty ? 'NÃO' : date), style: const pw.TextStyle(fontSize: 9))),
        pw.Expanded(child: pw.Text(_pdfSafe(treatment.isEmpty ? 'NÃO' : treatment), style: const pw.TextStyle(fontSize: 9))),
      ],
    );
  }

  String _value(Map<String, dynamic> answers, String key) {
    final value = answers[key];
    if (value == null) return 'NÃO';
    if (value is String && value.trim().isEmpty) return 'NÃO';
    return value.toString();
  }

  bool? _toYesNoSelection(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized == 'sim' || normalized == 'true' || normalized == 'yes') return true;
    if (normalized == 'não' || normalized == 'nao' || normalized == 'false' || normalized == 'no') return false;
    return null;
  }

  bool _hasMeaningfulValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (normalized == 'não' || normalized == 'nao') return false;
    return true;
  }

  String _checkboxSymbol(dynamic value) {
    if (value == null) return '[ ]';
    if (value is bool) return value ? '[x]' : '[ ]';

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return '[ ]';

    if (normalized == 'true' || normalized == 'sim' || normalized == 'yes' || normalized == 'selecionado') {
      return '[x]';
    }

    if (normalized == 'false' || normalized == 'nao' || normalized == 'não' || normalized == 'no' || normalized == 'não selecionado') {
      return '[ ]';
    }

    return '[ ]';
  }

  String _formatDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'NÃO') return value;

    final dateOnlyMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(trimmed);
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

  pw.Widget _buildLogoPlaceholder() {
    return pw.Container(
      width: 80,
      height: 80,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Center(
        child: pw.Text('[Logo]', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ),
    );
  }

  pw.Widget _buildSignatureSection(Client client) {
    final currentDate = _formatBrazilianDate(DateTime.now());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Assinatura da Paciente:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 60),
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 6),
        pw.Text(_pdfSafe('Nome: ${client.name}'), style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 2),
        pw.Text(_pdfSafe('Data: $currentDate'), style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  String _formatBrazilianDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  pw.Widget _pressureQuestion(Map<String, dynamic> answers) {
    final pressureValue = _value(answers, 'pressao');
    final pressureStatus = _value(answers, 'pressaoCompensada');
    final hasPressure = pressureValue.isNotEmpty && pressureValue != 'NÃO';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Hipertensão ou Hipotensão?', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        if (hasPressure) ...[
          pw.Text(_pdfSafe(pressureValue), style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 2),
          pw.Text(_pdfSafe('Compensada/descompensada: $pressureStatus'), style: const pw.TextStyle(fontSize: 9)),
        ] else
          pw.Text('NÃO', style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }
}