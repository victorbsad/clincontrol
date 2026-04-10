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
            _subTitle('Já fez algum tratamento estético ou dermatológico?'),
            _pairLine('Resposta', _yesNoValue(answers['tratamentoEstetico']), 'Qual?', _value(answers, 'qualTratamentoEstetico')),
            _subTitle('Problema de cicatrização ou Quelóide?'),
            _pairLine('Resposta', _yesNoValue(answers['cicatrizacaoQuelóide']), 'Comente:', _value(answers, 'cicatrizacaoComentario')),
            _subTitle('Faz uso de algum medicamento?'),
            _pairLine('Resposta', _yesNoValue(answers['usaMedicamento']), 'Qual?', _value(answers, 'qualMedicamento')),
            _subTitle('Usou Isotretinoína (Roacutan) nos últimos 6 meses?'),
            _pairLine('Resposta', _yesNoValue(answers['isotretinoina6m']), '', _value(answers, 'isotretinoina6mObs')),
            _subTitle('Tratamento médico ou problema de saúde?'),
            _pairLine('Resposta', _yesNoValue(answers['tratamentoMedico']), 'Qual?', _value(answers, 'qualProblemaSaude')),
            _subTitle('Apresenta trombose ou tromboflebite?'),
            _pairLine('Resposta', _yesNoValue(answers['trombose']), 'Local?', _value(answers, 'localTrombose')),
            _subTitle('Já fez alguma cirurgia?'),
            _pairLine('Resposta', _yesNoValue(answers['cirurgia']), 'Qual?', _value(answers, 'qualCirurgia')),
            _subTitle('Antecedentes oncológicos?'),
            _pairLine('Resposta', _yesNoValue(answers['oncologico']), '', _value(answers, 'oncologicoObs')),
            _subTitle('Doença infectocontagiosa?'),
            _pairLine('Resposta', _yesNoValue(answers['infectocontagiosa']), 'Qual?', _value(answers, 'qualInfectocontagiosa')),
            _subTitle('Pratica algum esporte?'),
            _pairLine('Resposta', _yesNoValue(answers['esporte']), '', _value(answers, 'esporteObs')),
            _subTitle('Alimentação balanceada?'),
            _pairLine('Resposta', _yesNoValue(answers['alimentacaoBalanceada']), '', _value(answers, 'alimentacaoObs')),
            _subTitle('Ingere no mínimo 2 litros de água por dia?'),
            _pairLine('Resposta', _yesNoValue(answers['agua2l']), 'Quantos litros?', _value(answers, 'quantosLitrosAgua')),
            _subTitle('Faz uso de bebida alcoólica?'),
            _pairLine('Resposta', _yesNoValue(answers['alcool']), 'Frequência?', _value(answers, 'frequenciaAlcool')),
            _subTitle('Faz uso de substâncias químicas ou entorpecentes?'),
            _pairLine('Resposta', _yesNoValue(answers['drogas']), 'Qual?', _value(answers, 'qualSubstancia')),
            _subTitle('Distúrbio hormonal'),
            _pairLine('Resposta', _yesNoValue(answers['disturbioHormonal']), 'Qual?', _value(answers, 'qualDisturbioHormonal')),
            _subTitle('Fuma ou Fumou'),
            _pairLine('Fuma', _value(answers, 'fumaOuFumou'), 'Quanto tempo?', _value(answers, 'tempoTabagismo')),
            _subTitle('Dorme bem?'),
            _pairLine('Resposta', _yesNoValue(answers['dormeBem']), 'Horas de sono:', _value(answers, 'horasSono')),
            _subTitle('Funcionamento intestinal regular?'),
            _pairLine('Resposta', _yesNoValue(answers['intestinoRegular']), '', _value(answers, 'intestinoObs')),
            _subTitle('Hipertensão ou Hipotensão?'),
            _pairLine('Resposta', _value(answers, 'pressao'), 'compensada ou descompensada?', _value(answers, 'pressaoCompensada')),
            _subTitle('Diabetes?'),
            _pairLine('Resposta', _yesNoValue(answers['diabetes']), 'compensada ou descompensada?', _value(answers, 'diabetesCompensada')),
            _subTitle('Tem problemas cardíacos?'),
            _pairLine('Resposta', _yesNoValue(answers['cardiaco']), 'Qual?', _value(answers, 'qualCardiaco')),
            _subTitle('Depressão?'),
            _pairLine('Resposta', _yesNoValue(answers['depressao']), 'Faz tratamento?', _value(answers, 'tratamentoDepressao')),
            _subTitle('Portador de Epilepsia?'),
            _pairLine('Resposta', _yesNoValue(answers['epilepsia']), '', _value(answers, 'epilepsiaObs')),
            _subTitle('Possui placas e pinos metálicos na face?'),
            _pairLine('Resposta', _yesNoValue(answers['placasPinos']), 'Onde?', _value(answers, 'ondePlacasPinos')),
            _subTitle('Próteses dentárias?'),
            _pairLine('Resposta', _yesNoValue(answers['protesesDentarias']), '', _value(answers, 'protesesObs')),
            _subTitle('Faz uso de lentes de contato?'),
            _pairLine('Resposta', _yesNoValue(answers['lentesContato']), '', _value(answers, 'lentesObs')),
            _subTitle('Já fez ou faz uso de ácidos na pele?'),
            _pairLine('Resposta', _yesNoValue(answers['acidosPele']), 'Qual?', _value(answers, 'qualAcido')),
            _subTitle('Faz uso de cosméticos?'),
            _pairLine('Resposta', _yesNoValue(answers['cosmeticos']), 'Quais?', _value(answers, 'quaisCosmeticos')),
            _subTitle('Faz uso de protetor solar?'),
            _pairLine('Resposta', _yesNoValue(answers['protetorSolar']), 'Qual?', '${_value(answers, 'qualProtetorSolar')} Frequência? ${_value(answers, 'frequenciaProtetorSolar')}'),
            _subTitle('Costuma tomar sol?'),
            _pairLine('Resposta', _yesNoValue(answers['tomaSol']), 'Frequência?', _value(answers, 'frequenciaSol')),
            _subTitle('Fez maquiagem definitiva?'),
            _pairLine('Resposta', _yesNoValue(answers['maquiagemDefinitiva']), 'Local?', _value(answers, 'localMaquiagemDefinitiva')),
            _subTitle('Fez aplicação de Metacril ou Toxina Botulínica?'),
            _pairLine('Resposta', _yesNoValue(answers['toxinaBotulinica']), 'Local?', _value(answers, 'localToxina')),
            _subTitle('Alergias? (alimentar, cheiro, respiratória, corantes, medicamentos, etc)'),
            _pairLine('Resposta', _value(answers, 'alergias'), 'Especificar:', _value(answers, 'alergias')),
            _subTitle('Gestante?'),
            _pairLine('Resposta', _yesNoValue(answers['gestante']), 'Quantos meses?', _value(answers, 'mesesGestacao')),
            _subTitle('Filhos?'),
            _pairLine('Resposta', _yesNoValue(answers['filhos']), 'Quantos?', _value(answers, 'quantidadeFilhos')),
            _subTitle('Ciclo menstrual regular?'),
            _pairLine('Resposta', _yesNoValue(answers['cicloRegular']), 'Obs.:', _value(answers, 'obsCiclo')),
            _subTitle('Já teve herpes?'),
            _pairLine('Resposta', _yesNoValue(answers['herpes']), 'A quanto tempo?', _value(answers, 'tempoHerpes')),
            _subTitle('Faz uso de anticoncepcional?'),
            _pairLine('Resposta', _yesNoValue(answers['anticoncepcional']), 'Qual?', _value(answers, 'qualAnticoncepcional')),
            _subTitle('Faz uso de hormônio?*'),
            _pairLine('Resposta', _yesNoValue(answers['hormonio']), 'Qual?', _value(answers, 'qualHormônio')),
            _subTitle('Autoriza divulgação de foto antes/após tratamento?'),
            _pairLine('Resposta', _yesNoValue(answers['autorizacaoFoto']), '', _value(answers, 'autorizacaoFotoObs')),
            _line('*Uso de Estrogênio – não pode usar eletrolifting .', _value(answers, 'estrogenioObs')),
          ]),
          pw.NewPage(),
          pw.SizedBox(height: 12),
          _buildSection('Avaliação da Pele', [
            _subTitle('BIOTIPO CUTÂNEO'),
            _subTitle('Pele Oleosa (Lipídica)'),
            _pairLine('Sensível', _optionValue(answers['peleOleosaSensivel']), 'Resistente', _optionValue(answers['peleOleosaResistente'])),
            _pairLine('Pigmentada', _optionValue(answers['peleOleosaPigmentada']), 'Não pigmentada', _optionValue(answers['peleOleosaNaoPigmentada'])),
            _pairLine('Firme', _optionValue(answers['peleOleosaFirme']), 'Propensa à rugas', _optionValue(answers['peleOleosaRugas'])),
            _subTitle('Pele Seca (Alípica)'),
            _pairLine('Sensível', _optionValue(answers['peleSecaSensivel']), 'Resistente', _optionValue(answers['peleSecaResistente'])),
            _pairLine('Pigmentada', _optionValue(answers['peleSecaPigmentada']), 'Não pigmentada', _optionValue(answers['peleSecaNaoPigmentada'])),
            _pairLine('Firme', _optionValue(answers['peleSecaFirme']), 'Propensa à rugas', _optionValue(answers['peleSecaRugas'])),
            _subTitle('Pele mista'),
            _pairLine('Sensível', _optionValue(answers['peleMistaSensivel']), 'Resistente', _optionValue(answers['peleMistaResistente'])),
            _pairLine('Pigmentada', _optionValue(answers['peleMistaPigmentada']), 'Não pigmentada', _optionValue(answers['peleMistaNaoPigmentada'])),
            _pairLine('Firme', _optionValue(answers['peleMistaFirme']), 'Propensa à rugas', _optionValue(answers['peleMistaRugas'])),
            _subTitle('ANÁLISE DETALHADA DA PELE'),
            _subTitle('Pele com acne'),
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
            _subTitle('Lesões dermatológicas'),
            _wrapBullets(['Telangiectasia/ Nevo', 'Queratose Actínica', 'Nevo Melanocítico', 'Dermatose Papulosa Nigra', 'Papiloma', 'Acrocórdon'], [
              answers['telangiectasiaNevo'],
              answers['queratoseActinica'],
              answers['nevoMelanocitico'],
              answers['dermatosePapulosaNigra'],
              answers['papiloma'],
              answers['acrocordon'],
            ]),
            _line('Outras', _value(answers, 'outrasLesoes')),
            _subTitle('Discromias'),
            _wrapBullets(['Hiperpimentação inflamatória', 'Fotoenvelhecimento', 'Melasma', 'Efelides', 'Hiperpigmentação orbicular', 'Hipocromia'], [
              answers['hiperpigmentacaoInflamatoria'],
              answers['fotoenvelhecimento'],
              answers['melasma'],
              answers['efelides'],
              answers['hiperpigmentacaoOrbicular'],
              answers['hipocromia'],
            ]),
            _line('Por quê? Quanto tempo?', _value(answers, 'discromiaJustificativa')),
            _line('FOTOTIPO – REATIVIDADE À LUZ ULTRAVIOLETA (Escala Fitzpatrick)', _value(answers, 'fototipo')),
            _pairLine('OUTROS: DERMATITE', _optionValue(answers['dermatite']), 'PSORIASE', _optionValue(answers['psoriase'])),
            _line('TRATAMENTO INDICADO', _value(answers, 'tratamentoIndicado')),
            _line('NÚMERO DE SESSÕES', _value(answers, 'numeroSessoes')),
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
            _line('PRESCRIÇÃO COSMÉTICA (home care)', _value(answers, 'prescricaoCosmetica')),
          ]),
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
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Ficha de Avaliação Facial', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Cliente: ${client.name}'),
          pw.Text('Gerado em: ${anamnesis.createdAt.toLocal()}'),
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

  pw.Widget _line(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Text('$label: ${value.isEmpty ? 'NÃO' : value}', style: const pw.TextStyle(fontSize: 9)),
    );
  }

  pw.Widget _subTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pairLine(String leftLabel, String leftValue, String rightLabel, String rightValue) {
    if (leftLabel == 'Resposta') {
      final selection = _toYesNoSelection(leftValue);
      final inferredSelection = selection ?? (_hasMeaningfulValue(rightValue) ? true : null);
      final isYes = inferredSelection == true;
      final isNo = inferredSelection == false;
      final comment = _hasMeaningfulValue(rightValue) ? rightValue : '';

      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'SIM: ${isYes ? 'X' : ''}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    'NÃO: ${isNo ? 'X' : ''}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            ),
            if (isYes && rightLabel.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2),
                child: pw.Text(
                  '$rightLabel ${comment.isEmpty ? 'NÃO INFORMADO' : comment}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
          ],
        ),
      );
    }

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

  String _motivoVisitaLine(Map<String, dynamic> answers) {
    return _value(answers, 'motivoVisita');
  }

  pw.Widget _wrapBullets(List<String> labels, List<dynamic> values) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Wrap(
        spacing: 10,
        runSpacing: 4,
        children: List.generate(labels.length, (index) {
          final value = _optionValue(values[index]);
          return pw.Text('${labels[index]}: $value', style: const pw.TextStyle(fontSize: 9));
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
        pw.Expanded(child: pw.Text(session, style: const pw.TextStyle(fontSize: 9))),
        pw.Expanded(child: pw.Text(date.isEmpty ? 'NÃO' : date, style: const pw.TextStyle(fontSize: 9))),
        pw.Expanded(child: pw.Text(treatment.isEmpty ? 'NÃO' : treatment, style: const pw.TextStyle(fontSize: 9))),
      ],
    );
  }

  String _value(Map<String, dynamic> answers, String key) {
    final value = answers[key];
    if (value == null) return 'NÃO';
    if (value is String && value.trim().isEmpty) return 'NÃO';
    return value.toString();
  }

  String _yesNoValue(dynamic value) {
    if (value == null) return 'NÃO';
    if (value is bool) return value ? 'SIM' : 'NÃO';
    final text = value.toString().trim().toLowerCase();
    if (text.isEmpty) return 'NÃO';
    if (text == 'true' || text == 'sim' || text == 'yes') return 'SIM';
    if (text == 'false' || text == 'nao' || text == 'não' || text == 'no') return 'NÃO';
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

  String _optionValue(dynamic value) {
    if (value == null) return 'Não selecionado';
    if (value is bool) return value ? 'Selecionado' : 'Não selecionado';

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return 'Não selecionado';

    if (normalized == 'true' || normalized == 'sim' || normalized == 'yes' || normalized == 'selecionado') {
      return 'Selecionado';
    }

    if (normalized == 'false' || normalized == 'nao' || normalized == 'não' || normalized == 'no' || normalized == 'não selecionado') {
      return 'Não selecionado';
    }

    return value.toString();
  }

  String _formatDate(String value) {
    if (value == 'NÃO') return value;
    return value;
  }
}