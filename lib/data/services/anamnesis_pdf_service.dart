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
          _buildSection('Dados pessoais', [
            _line('Nome', client.name),
            _line('Estado civil', _value(answers, 'estadoCivil')),
            _line('Nacionalidade', _value(answers, 'nacionalidade')),
            _line('Endereço completo', _value(answers, 'endereco')),
            _line('Telefone', _value(answers, 'telefone')),
            _line('WhatsApp', _value(answers, 'whatsapp')),
            _line('Email', _value(answers, 'email')),
            _line('Data de nascimento', _formatDate(_value(answers, 'dataNascimento'))),
            _line('Idade', _value(answers, 'idade')),
            _line('Profissão', _value(answers, 'profissao')),
            _line('Motivo da visita', _value(answers, 'motivoVisita')),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('Histórico', [
            _yesNo('Tratamento estético ou dermatológico', answers['tratamentoEstetico']),
            _yesNo('Problema de cicatrização ou quelóide', answers['cicatrizacaoQuelóide']),
            _line('Comentário cicatrização', _value(answers, 'cicatrizacaoComentario')),
            _yesNo('Uso de medicamento', answers['usaMedicamento']),
            _line('Qual medicamento', _value(answers, 'qualMedicamento')),
            _yesNo('Uso de isotretinoína nos últimos 6 meses', answers['isotretinoina6m']),
            _yesNo('Tratamento médico ou problema de saúde', answers['tratamentoMedico']),
            _line('Qual problema de saúde', _value(answers, 'qualProblemaSaude')),
            _yesNo('Trombose ou tromboflebite', answers['trombose']),
            _line('Local trombose', _value(answers, 'localTrombose')),
            _yesNo('Cirurgia prévia', answers['cirurgia']),
            _line('Qual cirurgia', _value(answers, 'qualCirurgia')),
            _yesNo('Antecedentes oncológicos', answers['oncologico']),
            _yesNo('Doença infectocontagiosa', answers['infectocontagiosa']),
            _line('Qual doença infectocontagiosa', _value(answers, 'qualInfectocontagiosa')),
            _yesNo('Pratica esporte', answers['esporte']),
            _yesNo('Alimentação balanceada', answers['alimentacaoBalanceada']),
            _yesNo('Ingere 2 litros de água por dia', answers['agua2l']),
            _line('Quantos litros', _value(answers, 'quantosLitrosAgua')),
            _yesNo('Uso de bebida alcoólica', answers['alcool']),
            _line('Frequência bebida alcoólica', _value(answers, 'frequenciaAlcool')),
            _yesNo('Uso de substâncias químicas ou entorpecentes', answers['drogas']),
            _line('Qual substância', _value(answers, 'qualSubstancia')),
            _yesNo('Distúrbio hormonal', answers['disturbioHormonal']),
            _line('Qual distúrbio hormonal', _value(answers, 'qualDisturbioHormonal')),
            _line('Fuma / fumou', _value(answers, 'fumaOuFumou')),
            _line('Tempo de tabagismo', _value(answers, 'tempoTabagismo')),
            _yesNo('Dorme bem', answers['dormeBem']),
            _line('Horas de sono', _value(answers, 'horasSono')),
            _yesNo('Funcionamento intestinal regular', answers['intestinoRegular']),
            _yesNo('Hipertensão / hipotensão', answers['pressao']),
            _line('Pressão compensada/descompensada', _value(answers, 'pressaoCompensada')),
            _yesNo('Diabetes', answers['diabetes']),
            _line('Diabetes compensada/descompensada', _value(answers, 'diabetesCompensada')),
            _yesNo('Problemas cardíacos', answers['cardiaco']),
            _line('Qual problema cardíaco', _value(answers, 'qualCardiaco')),
            _yesNo('Depressão', answers['depressao']),
            _yesNo('Faz tratamento para depressão', answers['tratamentoDepressao']),
            _yesNo('Epilepsia', answers['epilepsia']),
            _yesNo('Placas e pinos metálicos na face', answers['placasPinos']),
            _line('Onde', _value(answers, 'ondePlacasPinos')),
            _yesNo('Próteses dentárias', answers['protesesDentarias']),
            _yesNo('Uso de lentes de contato', answers['lentesContato']),
            _yesNo('Uso de ácidos na pele', answers['acidosPele']),
            _line('Qual ácido', _value(answers, 'qualAcido')),
            _yesNo('Uso de cosméticos', answers['cosmeticos']),
            _line('Quais cosméticos', _value(answers, 'quaisCosmeticos')),
            _yesNo('Uso de protetor solar', answers['protetorSolar']),
            _line('Qual protetor', _value(answers, 'qualProtetorSolar')),
            _line('Frequência protetor solar', _value(answers, 'frequenciaProtetorSolar')),
            _yesNo('Costuma tomar sol', answers['tomaSol']),
            _line('Frequência exposição ao sol', _value(answers, 'frequenciaSol')),
            _yesNo('Maquiagem definitiva', answers['maquiagemDefinitiva']),
            _line('Local maquiagem definitiva', _value(answers, 'localMaquiagemDefinitiva')),
            _yesNo('Metacril ou toxina botulínica', answers['toxinaBotulinica']),
            _line('Local metacril/toxina', _value(answers, 'localToxina')),
            _line('Alergias', _value(answers, 'alergias')),
            _yesNo('Gestante', answers['gestante']),
            _line('Quantos meses', _value(answers, 'mesesGestacao')),
            _yesNo('Filhos', answers['filhos']),
            _line('Quantos filhos', _value(answers, 'quantidadeFilhos')),
            _yesNo('Ciclo menstrual regular', answers['cicloRegular']),
            _line('Observação ciclo menstrual', _value(answers, 'obsCiclo')), 
            _yesNo('Já teve herpes', answers['herpes']),
            _line('Há quanto tempo', _value(answers, 'tempoHerpes')),
            _yesNo('Uso de anticoncepcional', answers['anticoncepcional']),
            _line('Qual anticoncepcional', _value(answers, 'qualAnticoncepcional')),
            _yesNo('Uso de hormônio', answers['hormonio']),
            _line('Qual hormônio', _value(answers, 'qualHormônio')),
            _yesNo('Autoriza divulgação de foto antes/depois', answers['autorizacaoFoto']),
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
      child: pw.Text('$label: $value', style: const pw.TextStyle(fontSize: 9)),
    );
  }

  pw.Widget _yesNo(String label, dynamic value) {
    return _line(label, _yesNoValue(value));
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

  String _formatDate(String value) {
    if (value == 'NÃO') return value;
    return value;
  }
}