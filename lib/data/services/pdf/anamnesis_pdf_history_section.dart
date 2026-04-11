import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/anamnesis_keys.dart';
import 'anamnesis_pdf_styles.dart';

class AnamnesisPdfHistorySection {
  const AnamnesisPdfHistorySection._();

  static List<pw.Widget> build(Map<String, dynamic> answers) {
    final alergiasText = _value(answers, AnamnesisKeys.hasAllergies);

    return [
      _yesNoRow(
        _yesNoQuestion(
          'Já fez algum tratamento estético ou dermatológico?',
          answers[AnamnesisKeys.hadAestheticTreatment],
          'Qual?',
          _value(answers, AnamnesisKeys.aestheticTreatmentType),
        ),
        _yesNoQuestion(
          'Problema de cicatrização ou Quelóide?',
          answers[AnamnesisKeys.keloidScarring],
          'Comente:',
          _value(answers, AnamnesisKeys.scarringComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Faz uso de algum medicamento?',
          answers[AnamnesisKeys.usesMedication],
          'Qual?',
          _value(answers, AnamnesisKeys.medicationType),
        ),
        _yesNoQuestion(
          'Usou Isotretinoína (Roacutan) nos últimos 6 meses?',
          answers[AnamnesisKeys.isotretinoin6Months],
          '',
          _value(answers, AnamnesisKeys.isotretinoin6MonthsComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Tratamento médico ou problema de saúde?',
          answers[AnamnesisKeys.hadMedicalTreatment],
          'Qual?',
          _value(answers, AnamnesisKeys.healthProblemType),
        ),
        _yesNoQuestion(
          'Apresenta trombose ou tromboflebite?',
          answers[AnamnesisKeys.thrombosis],
          'Local?',
          _value(answers, AnamnesisKeys.thrombosisLocation),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Já fez alguma cirurgia?',
          answers[AnamnesisKeys.hadSurgery],
          'Qual?',
          _value(answers, AnamnesisKeys.surgeryType),
        ),
        _yesNoQuestion(
          'Antecedentes oncológicos?',
          answers[AnamnesisKeys.hasOncologicalHistory],
          '',
          _value(answers, AnamnesisKeys.oncologicalComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Doença infectocontagiosa?',
          answers[AnamnesisKeys.infectiousDiseaseHistory],
          'Qual?',
          _value(answers, AnamnesisKeys.infectiousDiseaseType),
        ),
        _yesNoQuestion(
          'Pratica algum esporte?',
          answers[AnamnesisKeys.exercisesRegularly],
          '',
          _value(answers, AnamnesisKeys.exerciseType),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Alimentação balanceada?',
          answers[AnamnesisKeys.balancedDiet],
          '',
          _value(answers, AnamnesisKeys.dietComment),
        ),
        _yesNoQuestion(
          'Ingere no mínimo 2 litros de água por dia?',
          answers[AnamnesisKeys.drinks2LitersWater],
          'Quantos litros?',
          _value(answers, AnamnesisKeys.waterIntakeAmount),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Faz uso de bebida alcoólica?',
          answers[AnamnesisKeys.consumesAlcohol],
          'Frequência?',
          _value(answers, AnamnesisKeys.alcoholFrequency),
        ),
        _yesNoQuestion(
          'Faz uso de substâncias químicas ou entorpecentes?',
          answers[AnamnesisKeys.usesDrugs],
          'Qual?',
          _value(answers, AnamnesisKeys.drugType),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Distúrbio hormonal?',
          answers[AnamnesisKeys.hormoneImbalance],
          'Qual?',
          _value(answers, AnamnesisKeys.hormoneImbalanceType),
        ),
        _yesNoQuestion(
          'Dorme bem?',
          answers[AnamnesisKeys.sleepsWell],
          'Horas de sono:',
          _value(answers, AnamnesisKeys.sleepHours),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Funcionamento intestinal regular?',
          answers[AnamnesisKeys.regularBowelMovements],
          '',
          _value(answers, AnamnesisKeys.bowelComment),
        ),
        _yesNoQuestion(
          'Diabetes?',
          answers[AnamnesisKeys.hasDiabetes],
          'Compensada/descompensada?',
          _value(answers, AnamnesisKeys.diabetesControlled),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Tem problemas cardíacos?',
          answers[AnamnesisKeys.hasCardiacCondition],
          'Qual?',
          _value(answers, AnamnesisKeys.cardiacConditionType),
        ),
        _yesNoQuestion(
          'Depressão?',
          answers[AnamnesisKeys.hasDepression],
          'Faz tratamento?',
          _value(answers, AnamnesisKeys.depressionTreatment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Portador de Epilepsia?',
          answers[AnamnesisKeys.hasEpilepsy],
          '',
          _value(answers, AnamnesisKeys.epilepsyComment),
        ),
        _yesNoQuestion(
          'Possui placas e pinos metálicos na face?',
          answers[AnamnesisKeys.hasDentalImplants],
          'Onde?',
          _value(answers, AnamnesisKeys.dentalImplantLocation),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Próteses dentárias?',
          answers[AnamnesisKeys.hasDentures],
          '',
          _value(answers, AnamnesisKeys.denturesComment),
        ),
        _yesNoQuestion(
          'Faz uso de lentes de contato?',
          answers[AnamnesisKeys.wearsContactLenses],
          '',
          _value(answers, AnamnesisKeys.contactLensesComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Já fez ou faz uso de ácidos na pele?',
          answers[AnamnesisKeys.usesAcids],
          'Qual?',
          _value(answers, AnamnesisKeys.acidType),
        ),
        _yesNoQuestion(
          'Faz uso de cosméticos?',
          answers[AnamnesisKeys.usesCosmeticProducts],
          'Quais?',
          _value(answers, AnamnesisKeys.cosmeticProductTypes),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Faz uso de protetor solar?',
          answers[AnamnesisKeys.usesSunscreen],
          'Qual?',
          '${_value(answers, AnamnesisKeys.sunscreenType)} Frequência? ${_value(answers, AnamnesisKeys.sunscreenFrequency)}',
        ),
        _yesNoQuestion(
          'Costuma tomar sol?',
          answers[AnamnesisKeys.exposedToSun],
          'Frequência?',
          _value(answers, AnamnesisKeys.sunExposureFrequency),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Fez maquiagem definitiva?',
          answers[AnamnesisKeys.hasPermanentMakeup],
          'Local?',
          _value(answers, AnamnesisKeys.permanentMakeupLocation),
        ),
        _yesNoQuestion(
          'Fez aplicação de Metacril ou Toxina Botulínica?',
          answers[AnamnesisKeys.usedBotulinum],
          'Local?',
          _value(answers, AnamnesisKeys.botulinumLocation),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Alergias? (alimentar, cheiro, respiratória, corantes, medicamentos, etc)',
          _hasMeaningfulValue(alergiasText),
          'Especificar:',
          alergiasText,
        ),
        _yesNoQuestion(
          'Gestante?',
          answers[AnamnesisKeys.isPregnant],
          'Quantos meses?',
          _value(answers, AnamnesisKeys.pregnancyMonths),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Filhos?',
          answers[AnamnesisKeys.hasChildren],
          'Quantos?',
          _value(answers, AnamnesisKeys.numberOfChildren),
        ),
        _yesNoQuestion(
          'Ciclo menstrual regular?',
          answers[AnamnesisKeys.regularMenstrualCycle],
          'Obs.:',
          _value(answers, AnamnesisKeys.menstrualCycleComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Já teve herpes?',
          answers[AnamnesisKeys.hasHerpesHistory],
          'A quanto tempo?',
          _value(answers, AnamnesisKeys.herpesDuration),
        ),
        _yesNoQuestion(
          'Faz uso de anticoncepcional?',
          answers[AnamnesisKeys.usesContraceptive],
          'Qual?',
          _value(answers, AnamnesisKeys.contraceptiveType),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Faz uso de hormônio?*',
          answers[AnamnesisKeys.takesHormones],
          'Qual?',
          _value(answers, AnamnesisKeys.hormoneType),
        ),
        _yesNoQuestion(
          'Autoriza divulgação de foto antes/após tratamento?',
          answers[AnamnesisKeys.authorizedForPhotos],
          '',
          _value(answers, AnamnesisKeys.photoAuthorizationComment),
        ),
      ),
      _subTitle('Fuma ou Fumou'),
      _stackedQuestion(
        'Fuma',
        _value(answers, AnamnesisKeys.smokeOrSmoked),
        'Quanto tempo?',
        _value(answers, AnamnesisKeys.smokingDuration),
      ),
      _pressureQuestion(answers),
    ];
  }

  static pw.Widget _yesNoRow(pw.Widget left, pw.Widget right) {
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

  static pw.Widget _yesNoQuestion(
    String question,
    dynamic rawAnswer,
    String commentLabel,
    String commentValue,
  ) {
    final selection = _toYesNoSelection(rawAnswer);
    final isYes = selection == true;
    final text = isYes ? 'SIM' : 'NÃO';
    final hasComment = _hasMeaningfulValue(commentValue);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(question, style: AnamnesisPdfStyles.bold),
        pw.SizedBox(height: 2),
        pw.Text(text, style: AnamnesisPdfStyles.text),
        if (isYes && commentLabel.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(
              _pdfSafe(
                '$commentLabel ${hasComment ? commentValue : 'NÃO INFORMADO'}',
              ),
              style: AnamnesisPdfStyles.text,
            ),
          ),
      ],
    );
  }

  static pw.Widget _subTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
      child: pw.Text(_pdfSafe(title), style: AnamnesisPdfStyles.subTitle),
    );
  }

  static pw.Widget _stackedQuestion(
    String label,
    String value,
    String subLabel,
    String subValue,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label: ${value.isEmpty ? 'NÃO' : value}',
            style: AnamnesisPdfStyles.text,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '$subLabel: ${subValue.isEmpty ? 'NÃO' : subValue}',
            style: AnamnesisPdfStyles.text,
          ),
        ],
      ),
    );
  }

  static pw.Widget _pressureQuestion(Map<String, dynamic> answers) {
    final pressureValue = _value(answers, AnamnesisKeys.bloodPressure);
    final pressureStatus = _value(
      answers,
      AnamnesisKeys.bloodPressureControlled,
    );
    final hasPressure = pressureValue.isNotEmpty && pressureValue != 'NÃO';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Hipertensão ou Hipotensão?',
          style: AnamnesisPdfStyles.bold,
        ),
        pw.SizedBox(height: 2),
        if (hasPressure) ...[
          pw.Text(_pdfSafe(pressureValue), style: AnamnesisPdfStyles.text),
          pw.SizedBox(height: 2),
          pw.Text(
            _pdfSafe('Compensada/descompensada: $pressureStatus'),
            style: AnamnesisPdfStyles.text,
          ),
        ] else
          pw.Text('NÃO', style: AnamnesisPdfStyles.text),
      ],
    );
  }

  static String _value(Map<String, dynamic> answers, String key) {
    final value = answers[key];
    if (value == null) return 'NÃO';
    if (value is String && value.trim().isEmpty) return 'NÃO';
    return value.toString();
  }

  static bool? _toYesNoSelection(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized == 'sim' || normalized == 'true' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'nao' || normalized == 'não' || normalized == 'false' || normalized == 'no') {
      return false;
    }
    return null;
  }

  static bool _hasMeaningfulValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (normalized == 'nao' || normalized == 'não') return false;
    return true;
  }

  static String _pdfSafe(String value) {
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
}
