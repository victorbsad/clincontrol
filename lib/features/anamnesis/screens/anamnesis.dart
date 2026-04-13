import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../data/models/anamnesis.dart';
import '../../../data/models/client.dart';
import '../../../data/database/db_helper.dart';
import '../../../core/constants/anamnesis_field_specs.dart';

class AnamnesisScreen extends StatefulWidget {
  final Client client;

  const AnamnesisScreen({required this.client});

  @override
  State<AnamnesisScreen> createState() => _AnamnesisScreenState();
}

class _AnamnesisScreenState extends State<AnamnesisScreen> {
  late DbHelper dbHelper;
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, bool> _checkboxValues = {};
  final Map<String, String?> _enumValues = {}; // Para rastrear valores de enum

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();

    // Inicializa estado dos checkboxes e enums
    for (var field in fields) {
      if (field['type'] == 'bool') {
        _checkboxValues[field['key']] = false;
      } else if (field['type'] == 'enum') {
        _enumValues[field['key']] = null;
      }
    }
  }

  final List<Map<String, dynamic>> fields = [
    // ========== MOTIVO DA VISITA ==========
    {'key': 'visitReasonOption', 'label': 'Motivo da Visita', 'type': 'enum'},
    {'key': 'visitReasonOther', 'label': 'Outro Motivo', 'type': 'text', 'dependsOn': 'visitReasonOption', 'dependsOnValue': 'outro'},

    // ========== HISTÓRICO ESTÉTICO ==========
    {'key': 'hadAestheticTreatment', 'label': 'Fez Tratamento Estético?', 'type': 'bool'},
    {'key': 'aestheticTreatmentType', 'label': 'Tipo de Tratamento Estético', 'type': 'text', 'dependsOn': 'hadAestheticTreatment'},
    {'key': 'keloidScarring', 'label': 'Tendência a Cicatrizes Queloides?', 'type': 'bool'},
    {'key': 'scarringComment', 'label': 'Observações sobre Cicatrização', 'type': 'text', 'dependsOn': 'keloidScarring'},
    {'key': 'usesMedication', 'label': 'Usa Medicação?', 'type': 'bool'},
    {'key': 'medicationType', 'label': 'Tipo de Medicação', 'type': 'text', 'dependsOn': 'usesMedication'},
    {'key': 'isotretinoin6Months', 'label': 'Usou Isotretinoína nos últimos 6 meses?', 'type': 'bool'},
    {'key': 'isotretinoin6MonthsComment', 'label': 'Observações sobre Isotretinoína', 'type': 'text', 'dependsOn': 'isotretinoin6Months'},

    // ========== HISTÓRICO MÉDICO ==========
    {'key': 'hadMedicalTreatment', 'label': 'Fez Tratamento Médico?', 'type': 'bool'},
    {'key': 'healthProblemType', 'label': 'Tipo de Problema de Saúde', 'type': 'text', 'dependsOn': 'hadMedicalTreatment'},
    {'key': 'thrombosis', 'label': 'Teve Trombose?', 'type': 'bool'},
    {'key': 'thrombosisLocation', 'label': 'Localização da Trombose', 'type': 'text', 'dependsOn': 'thrombosis'},
    {'key': 'hadSurgery', 'label': 'Fez Cirurgia?', 'type': 'bool'},
    {'key': 'surgeryType', 'label': 'Tipo de Cirurgia', 'type': 'text', 'dependsOn': 'hadSurgery'},
    {'key': 'hasOncologicalHistory', 'label': 'Histórico de Câncer?', 'type': 'bool'},
    {'key': 'oncologicalComment', 'label': 'Observações sobre Câncer', 'type': 'text', 'dependsOn': 'hasOncologicalHistory'},
    {'key': 'infectiousDiseaseHistory', 'label': 'Histórico de Doença Infecciosa?', 'type': 'bool'},
    {'key': 'infectiousDiseaseType', 'label': 'Tipo de Doença Infecciosa', 'type': 'text', 'dependsOn': 'infectiousDiseaseHistory'},

    // ========== HÁBITOS DE VIDA ==========
    {'key': 'exercisesRegularly', 'label': 'Pratica Exercício Regularmente?', 'type': 'bool'},
    {'key': 'exerciseType', 'label': 'Tipo de Exercício', 'type': 'text', 'dependsOn': 'exercisesRegularly'},
    {'key': 'balancedDiet', 'label': 'Segue Alimentação Balanceada?', 'type': 'bool'},
    {'key': 'dietComment', 'label': 'Observações sobre Dieta', 'type': 'text', 'dependsOn': 'balancedDiet'},
    {'key': 'drinks2LitersWater', 'label': 'Bebe 2 litros de Água?', 'type': 'bool'},
    {'key': 'waterIntakeAmount', 'label': 'Quantidade de Água Ingerida', 'type': 'text', 'dependsOn': 'drinks2LitersWater'},
    {'key': 'consumesAlcohol', 'label': 'Consome Álcool?', 'type': 'bool'},
    {'key': 'alcoholFrequency', 'label': 'Frequência de Álcool', 'type': 'enum', 'dependsOn': 'consumesAlcohol'},
    {'key': 'alcoholFrequencyOther', 'label': 'Outra Frequência de Álcool', 'type': 'text', 'dependsOn': 'alcoholFrequency', 'dependsOnValue': 'outro'},
    {'key': 'usesDrugs', 'label': 'Usa Drogas?', 'type': 'bool'},
    {'key': 'drugType', 'label': 'Tipo de Droga', 'type': 'text', 'dependsOn': 'usesDrugs'},
    {'key': 'hormoneImbalance', 'label': 'Desequilíbrio Hormonal?', 'type': 'bool'},
    {'key': 'hormoneImbalanceType', 'label': 'Tipo de Desequilíbrio Hormonal', 'type': 'text', 'dependsOn': 'hormoneImbalance'},

    // ========== FUMO ==========
    {'key': 'smokingStatus', 'label': 'Status de Fumo', 'type': 'enum'},
    {'key': 'smokingDuration', 'label': 'Duração do Fumo', 'type': 'text', 'dependsOn': 'smokingStatus', 'dependsOnValue': '!nunca'},

    // ========== SONO & INTESTINO ==========
    {'key': 'sleepsWell', 'label': 'Dorme Bem?', 'type': 'bool'},
    {'key': 'sleepHours', 'label': 'Horas de Sono', 'type': 'number'},
    {'key': 'regularBowelMovements', 'label': 'Evacuação Regular?', 'type': 'bool'},
    {'key': 'bowelComment', 'label': 'Observações sobre Evacuação', 'type': 'text', 'dependsOn': 'regularBowelMovements'},

    // ========== PRESSÃO ARTERIAL ==========
    {'key': 'hypertensionStatus', 'label': 'Hipertensão?', 'type': 'enum'},
    {'key': 'hypotensionStatus', 'label': 'Hipotensão?', 'type': 'enum'},

    // ========== CONDIÇÕES MÉDICAS ==========
    {'key': 'hasDiabetes', 'label': 'Tem Diabetes?', 'type': 'bool'},
    {'key': 'diabetesControlled', 'label': 'Diabetes Controlada?', 'type': 'bool', 'dependsOn': 'hasDiabetes'},
    {'key': 'hasCardiacCondition', 'label': 'Doença Cardíaca?', 'type': 'bool'},
    {'key': 'cardiacConditionType', 'label': 'Tipo de Doença Cardíaca', 'type': 'text', 'dependsOn': 'hasCardiacCondition'},
    {'key': 'hasDepression', 'label': 'Depressão?', 'type': 'bool'},
    {'key': 'depressionTreatment', 'label': 'Tratamento para Depressão', 'type': 'text', 'dependsOn': 'hasDepression'},
    {'key': 'hasEpilepsy', 'label': 'Epilepsia?', 'type': 'bool'},
    {'key': 'epilepsyComment', 'label': 'Observações sobre Epilepsia', 'type': 'text', 'dependsOn': 'hasEpilepsy'},
    {'key': 'hasDentalImplants', 'label': 'Implante Dental?', 'type': 'bool'},
    {'key': 'dentalImplantLocation', 'label': 'Localização do Implante Dental', 'type': 'text', 'dependsOn': 'hasDentalImplants'},
    {'key': 'hasDentures', 'label': 'Prótese Dentária?', 'type': 'bool'},
    {'key': 'denturesComment', 'label': 'Observações sobre Prótese', 'type': 'text', 'dependsOn': 'hasDentures'},

    // ========== LENTES DE CONTATO ==========
    {'key': 'wearsContactLenses', 'label': 'Usa Lentes de Contato?', 'type': 'bool'},
    {'key': 'contactLensesComment', 'label': 'Observações sobre Lentes', 'type': 'text', 'dependsOn': 'wearsContactLenses'},

    // ========== ÁCIDOS & COSMÉTICOS ==========
    {'key': 'usesAcids', 'label': 'Usa Ácidos?', 'type': 'bool'},
    {'key': 'acidType', 'label': 'Tipo de Ácido', 'type': 'text', 'dependsOn': 'usesAcids'},
    {'key': 'usesCosmeticProducts', 'label': 'Usa Produtos Cosméticos?', 'type': 'bool'},
    {'key': 'cosmeticProductTypes', 'label': 'Tipo de Produto Cosmético', 'type': 'text', 'dependsOn': 'usesCosmeticProducts'},
    {'key': 'usesSunscreen', 'label': 'Usa Protetor Solar?', 'type': 'bool'},
    {'key': 'sunscreenType', 'label': 'Tipo de Protetor Solar', 'type': 'text', 'dependsOn': 'usesSunscreen'},

    // ========== FREQUÊNCIA DE PROTETOR SOLAR ==========
    {'key': 'sunscreenFrequency', 'label': 'Frequência de Protetor Solar', 'type': 'enum', 'dependsOn': 'usesSunscreen'},
    {'key': 'sunscreenFrequencyOther', 'label': 'Outra Frequência de Protetor', 'type': 'text', 'dependsOn': 'sunscreenFrequency', 'dependsOnValue': 'outro'},

    // ========== SOL & MAQUIAGEM ==========
    {'key': 'exposedToSun', 'label': 'Exposto ao Sol?', 'type': 'bool'},
    {'key': 'sunExposureFrequency', 'label': 'Frequência de Exposição Solar', 'type': 'enum', 'dependsOn': 'exposedToSun'},
    {'key': 'sunExposureFrequencyOther', 'label': 'Outra Frequência de Exposição', 'type': 'text', 'dependsOn': 'sunExposureFrequency', 'dependsOnValue': 'outro'},
    {'key': 'hasPermanentMakeup', 'label': 'Maquiagem Permanente?', 'type': 'bool'},
    {'key': 'permanentMakeupLocation', 'label': 'Localização da Maquiagem Permanente', 'type': 'text', 'dependsOn': 'hasPermanentMakeup'},

    // ========== TOXINA BOTULÍNICA ==========
    {'key': 'usedBotulinum', 'label': 'Usou Toxina Botulínica?', 'type': 'bool'},
    {'key': 'botulinumLocation', 'label': 'Localização da Toxina Botulínica', 'type': 'text', 'dependsOn': 'usedBotulinum'},

    // ========== ALERGIAS ==========
    {'key': 'hasAllergies', 'label': 'Tem Alergias?', 'type': 'bool'},
    {'key': 'allergiesDetails', 'label': 'Detalhes das Alergias', 'type': 'text', 'dependsOn': 'hasAllergies'},

    // ========== GESTAÇÃO ==========
    {'key': 'isPregnant', 'label': 'Grávida?', 'type': 'bool'},
    {'key': 'pregnancyMonths', 'label': 'Meses de Gestação', 'type': 'number', 'dependsOn': 'isPregnant'},

    // ========== FILHOS ==========
    {'key': 'hasChildren', 'label': 'Tem Filhos?', 'type': 'bool'},
    {'key': 'numberOfChildren', 'label': 'Quantidade de Filhos', 'type': 'number', 'dependsOn': 'hasChildren'},

    // ========== CICLO MENSTRUAL ==========
    {'key': 'regularMenstrualCycle', 'label': 'Ciclo Menstrual Regular?', 'type': 'bool'},
    {'key': 'menstrualCycleComment', 'label': 'Observações sobre Ciclo Menstrual', 'type': 'text', 'dependsOn': 'regularMenstrualCycle'},

    // ========== HERPES & CONTRACEPTIVOS ==========
    {'key': 'hasHerpesHistory', 'label': 'Histórico de Herpes?', 'type': 'bool'},
    {'key': 'herpesDuration', 'label': 'Duração do Herpes', 'type': 'text', 'dependsOn': 'hasHerpesHistory'},
    {'key': 'usesContraceptive', 'label': 'Usa Contraceptivo?', 'type': 'bool'},
    {'key': 'contraceptiveType', 'label': 'Tipo de Contraceptivo', 'type': 'text', 'dependsOn': 'usesContraceptive'},

    // ========== HORMÔNIOS ==========
    {'key': 'takesHormones', 'label': 'Toma Hormônios?', 'type': 'bool'},
    {'key': 'hormoneType', 'label': 'Tipo de Hormônio', 'type': 'text', 'dependsOn': 'takesHormones'},

    // ========== AUTORIZAÇÃO DE FOTOS ==========
    {'key': 'authorizedForPhotos', 'label': 'Autoriza Fotos?', 'type': 'bool'},
    {'key': 'photoAuthorizationComment', 'label': 'Observações sobre Autorização', 'type': 'text', 'dependsOn': 'authorizedForPhotos'},

    // ========== ESTRÓGÊNIO ==========
    {'key': 'estrogenComment', 'label': 'Observações sobre Estrógênio', 'type': 'text'},

    // ========== PELE OLEOSA ==========
    {'key': 'oilySkinSensitive', 'label': 'Pele Oleosa Sensível?', 'type': 'bool'},
    {'key': 'oilySkinResistant', 'label': 'Pele Oleosa Resistente?', 'type': 'bool'},
    {'key': 'oilySkinPigmented', 'label': 'Pele Oleosa Pigmentada?', 'type': 'bool'},
    {'key': 'oilySkinNonPigmented', 'label': 'Pele Oleosa Não Pigmentada?', 'type': 'bool'},
    {'key': 'oilySkinFirm', 'label': 'Pele Oleosa Firme?', 'type': 'bool'},
    {'key': 'oilySkinWrinkled', 'label': 'Pele Oleosa Enrugada?', 'type': 'bool'},

    // ========== PELE SECA ==========
    {'key': 'drySkinSensitive', 'label': 'Pele Seca Sensível?', 'type': 'bool'},
    {'key': 'drySkinResistant', 'label': 'Pele Seca Resistente?', 'type': 'bool'},
    {'key': 'drySkinPigmented', 'label': 'Pele Seca Pigmentada?', 'type': 'bool'},
    {'key': 'drySkinNonPigmented', 'label': 'Pele Seca Não Pigmentada?', 'type': 'bool'},
    {'key': 'drySkinFirm', 'label': 'Pele Seca Firme?', 'type': 'bool'},
    {'key': 'drySkinWrinkled', 'label': 'Pele Seca Enrugada?', 'type': 'bool'},

    // ========== PELE MISTA ==========
    {'key': 'combinationSkinSensitive', 'label': 'Pele Mista Sensível?', 'type': 'bool'},
    {'key': 'combinationSkinResistant', 'label': 'Pele Mista Resistente?', 'type': 'bool'},
    {'key': 'combinationSkinPigmented', 'label': 'Pele Mista Pigmentada?', 'type': 'bool'},
    {'key': 'combinationSkinNonPigmented', 'label': 'Pele Mista Não Pigmentada?', 'type': 'bool'},
    {'key': 'combinationSkinFirm', 'label': 'Pele Mista Firme?', 'type': 'bool'},
    {'key': 'combinationSkinWrinkled', 'label': 'Pele Mista Enrugada?', 'type': 'bool'},

    // ========== ANÁLISE DE ACNE ==========
    {'key': 'hasComedo', 'label': 'Tem Acne Comedônica?', 'type': 'bool'},
    {'key': 'hasPustule', 'label': 'Tem Acne Pustulosa?', 'type': 'bool'},
    {'key': 'hasPapule', 'label': 'Tem Acne Papulosa?', 'type': 'bool'},
    {'key': 'hasNodule', 'label': 'Tem Acne Nodular?', 'type': 'bool'},
    {'key': 'hasHyperkeratinization', 'label': 'Tem Hiperqueratinização?', 'type': 'bool'},
    {'key': 'hasMilium', 'label': 'Tem Milium?', 'type': 'bool'},
    {'key': 'hasMicrocyst', 'label': 'Tem Microcisto?', 'type': 'bool'},
    {'key': 'hasInflammatoryAcne', 'label': 'Tem Acne Inflamatória?', 'type': 'bool'},
    {'key': 'hasNonInflammatoryAcne', 'label': 'Tem Acne Não Inflamatória?', 'type': 'bool'},

    // ========== LESÕES DERMATOLÓGICAS ==========
    {'key': 'hasTelangiectasiaNevus', 'label': 'Tem Nevus Telangiectásico?', 'type': 'bool'},
    {'key': 'hasActinicKeratosis', 'label': 'Tem Queratose Actínica?', 'type': 'bool'},
    {'key': 'hasMelanocyticNevus', 'label': 'Tem Nevus Melanocítico?', 'type': 'bool'},
    {'key': 'hasDermatosisPapulosa', 'label': 'Tem Dermatose Papulosa?', 'type': 'bool'},
    {'key': 'hasPapilloma', 'label': 'Tem Papiloma?', 'type': 'bool'},
    {'key': 'hasAcrochordion', 'label': 'Tem Acrocórdio?', 'type': 'bool'},
    {'key': 'hasOtherLesions', 'label': 'Tem Outras Lesões?', 'type': 'bool'},

    // ========== DISCROMIAS ==========
    {'key': 'hasInflammatoryHyperpigmentation', 'label': 'Tem Hiperpigmentação Inflamatória?', 'type': 'bool'},
    {'key': 'hasPhotoaging', 'label': 'Tem Fotoenvelhecimento?', 'type': 'bool'},
    {'key': 'hasMelasma', 'label': 'Tem Melasma?', 'type': 'bool'},
    {'key': 'hasFreckles', 'label': 'Tem Sardas?', 'type': 'bool'},
    {'key': 'hasOrbicularHyperpigmentation', 'label': 'Tem Hiperpigmentação Orbicular?', 'type': 'bool'},
    {'key': 'hasHypochromia', 'label': 'Tem Hipocromia?', 'type': 'bool'},
    {'key': 'chromaticAbnormalityJustification', 'label': 'Observações sobre Discromias', 'type': 'text'},

    // ========== FOTOTIPO ==========
    {'key': 'skinPhototype', 'label': 'Fototipo', 'type': 'enum'},

    // ========== OUTRAS CONDIÇÕES DERMATOLÓGICAS ==========
    {'key': 'hasDermatitis', 'label': 'Tem Dermatite?', 'type': 'bool'},
    {'key': 'hasPsoriasis', 'label': 'Tem Psoríase?', 'type': 'bool'},

    // ========== TRATAMENTO ==========
    {'key': 'treatmentIndicated', 'label': 'Tratamento Indicado', 'type': 'text'},

    // ========== PRESCRIÇÃO ==========
    {'key': 'cosmeticPrescription', 'label': 'Prescrição Cosmética', 'type': 'text'},
  ];

  /// Remove dados vazios, nulos de formulário, mas mantém checkboxes (true/false)
  Map<String, dynamic> _getCleanedFormData() {
    final cleanedData = <String, dynamic>{};

    _formData.forEach((key, value) {
      // Mantém checkboxes com true ou false
      if (value is bool) {
        cleanedData[key] = value;
        return;
      }

      // Pula null
      if (value == null) return;

      // Pula strings vazias
      if (value is String && value.trim().isEmpty) return;

      // Se chegou aqui, mantém o valor
      cleanedData[key] = value;
    });

    return cleanedData;
  }

  /// Retorna lista de campos obrigatórios (dropdowns) não preenchidos
  List<String> _getMissingRequiredFields() {
    final missing = <String>[];

    for (var field in fields) {
      // Apenas verifica enums (campos obrigatórios)
      if (field['type'] != 'enum') continue;

      // Verifica se o campo deve ser exibido
      if (!_shouldShowField(field)) continue;

      // Verifica se foi preenchido
      final value = _enumValues[field['key']];
      if (value == null || value.isEmpty) {
        missing.add(field['label']);
      }
    }

    return missing;
  }

  /// Mostra dialog com campos obrigatórios não preenchidos
  void _showMissingFieldsDialog(List<String> missingFields) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campos Obrigatórios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por favor, preencha os seguintes campos:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: missingFields
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(
                          bottom: entry.key < missingFields.length - 1 ? 8 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void saveData() async {
    // Verifica campos obrigatórios (dropdowns) não preenchidos
    final missingFields = _getMissingRequiredFields();

    if (missingFields.isNotEmpty) {
      _showMissingFieldsDialog(missingFields);
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Limpa dados vazios antes de enviar
      final cleanedData = _getCleanedFormData();

      if (cleanedData.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preencha pelo menos um campo da anamnese'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      await dbHelper.insertAnamnesis(
        Anamnesis(
          clientId: widget.client.id!,
          answers: cleanedData,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anamnese de ${widget.client.name} salva com sucesso!'),
        ),
      );

      Navigator.pop(context);
    }
  }

  /// Verifica se um campo deve ser exibido baseado em suas dependências
  bool _shouldShowField(Map<String, dynamic> field) {
    final dependsOn = field['dependsOn'] as String?;
    final dependsOnValue = field['dependsOnValue'] as String?;
    
    // Se não tem dependência, sempre mostra
    if (dependsOn == null) return true;
    
    // Se tem dependsOnValue, verifica o valor
    if (dependsOnValue != null) {
      // Suporte para negação: "!value" significa diferente de value
      if (dependsOnValue.startsWith('!')) {
        final excludeValue = dependsOnValue.substring(1);
        if (_enumValues.containsKey(dependsOn)) {
          return _enumValues[dependsOn] != excludeValue;
        }
        return false;
      }
      
      // Caso normal: valor deve ser exatamente igual
      if (_enumValues.containsKey(dependsOn)) {
        return _enumValues[dependsOn] == dependsOnValue;
      }
      return false;
    }
    
    // Lógica original quando não há dependsOnValue
    // Verifica se o campo dependente é um checkbox (bool) ativo
    if (_checkboxValues.containsKey(dependsOn)) {
      return _checkboxValues[dependsOn] ?? false;
    }
    
    // Verifica se o campo dependente é um enum com valor selecionado
    if (_enumValues.containsKey(dependsOn)) {
      return _enumValues[dependsOn] != null && _enumValues[dependsOn]!.isNotEmpty;
    }
    
    // Verifica se o campo dependente é um texto/outra coisa preenchido
    if (_formData.containsKey(dependsOn)) {
      final value = _formData[dependsOn];
      return value != null && value.toString().isNotEmpty;
    }
    
    // Se não encontrou, não mostra
    return false;
  }

  /// Retorna as opções de enum para cada campo
  List<String> _getEnumValues(String fieldKey) {
    switch (fieldKey) {
      // Motivo da Visita
      case 'visitReasonOption':
        return AnamnesisFieldSpecs.visitReasonEnumValues;
      
      // Fumo
      case 'smokingStatus':
        return AnamnesisFieldSpecs.smokingStatusEnumValues;
      
      // Frequências
      case 'alcoholFrequency':
      case 'sunscreenFrequency':
      case 'sunExposureFrequency':
        return AnamnesisFieldSpecs.frequencyEnumValues;
      
      // Pressão Arterial
      case 'hypertensionStatus':
      case 'hypotensionStatus':
        return AnamnesisFieldSpecs.yesNoEnumValues;
      
      // Fototipo
      case 'skinPhototype':
        return AnamnesisFieldSpecs.skinPhototypeEnumValues;
      
      default:
        return [];
    }
  }

  /// Converte valores de enum para texto legível em português
  String _humanizeEnumValue(String fieldKey, String value) {
    const translations = {
      // Motivo da Visita
      'avaliacao_inicial': 'Avaliação Inicial',
      'acne': 'Acne',
      'melasma': 'Melasma',
      'manchas': 'Manchas',
      'rugas': 'Rugas',
      'oleosidade': 'Oleosidade',
      'sensibilidade': 'Sensibilidade',
      'manutencao': 'Manutenção',
      'outro': 'Outro',
      
      // Fumo
      'nunca': 'Nunca',
      'ex_fumante': 'Ex-Fumante',
      'sim': 'Sim',
      
      // Frequências
      'raro': 'Raro',
      'semanal': 'Semanal',
      'diario': 'Diário',
      
      // Pressão Arterial
      'nao': 'Não',
      'compensada': 'Compensada',
      'descompensada': 'Descompensada',
      
      // Fototipo
      'I': 'Tipo I',
      'II': 'Tipo II',
      'III': 'Tipo III',
      'IV': 'Tipo IV',
      'V': 'Tipo V',
      'VI': 'Tipo VI',
    };
    
    return translations[value] ?? value;
  }

  /// Retorna o hintText apropriado para cada campo
  String _getHintText(String fieldKey) {
    final hints = {
      'maritalStatus': 'Ex: Solteira',
      'nationality': 'Ex: Brasileira',
      'address': 'Ex: Rua Exemplo, 123 - Bairro',
      'phone': 'Ex: (54) 99999-1234',
      'whatsapp': 'Ex: (54) 99999-1234',
      'email': 'Ex: nome@email.com',
      'dateOfBirth': 'Ex: 1994-05-20',
      'age': 'Ex: 31',
      'profession': 'Ex: Esteticista',
      'sleepHours': 'Ex: 8',
    };
    return hints[fieldKey] ?? '';
  }

  /// InputDecoration padrão reutilizável
  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      hintText: hint.isNotEmpty ? hint : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.purple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Widget customizado para dropdown com melhor estilo visual e validação
  Widget _buildEnumDropdownWithValidation({
    required String fieldKey,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: value,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Obrigatório selecionar uma opção';
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: state.hasError ? Colors.red : Colors.grey,
                      width: state.hasError ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildEnumDropdown(
                    fieldKey: fieldKey,
                    label: label,
                    value: state.value,
                    items: items,
                    onChanged: (newVal) {
                      state.didChange(newVal);
                      _enumValues[fieldKey] = newVal;
                      _formData[fieldKey] = newVal;
                      onChanged(newVal);
                    },
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 16),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Widget customizado para dropdown com melhor estilo visual
  Widget _buildEnumDropdown({
    required String fieldKey,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButton2<String>(
      isExpanded: true,
      underline: SizedBox.shrink(),
      value: value,
      hint: Text(
        'Selecione',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  _humanizeEnumValue(fieldKey, item),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
      buttonStyleData: ButtonStyleData(
        height: 50,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.expand_more),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(6),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
        offset: const Offset(0, 5),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anamnese - ${widget.client.name}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            //Dados do cliente em read-only
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome: ${widget.client.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Telefone: ${widget.client.phone}'),
                    if (widget.client.email.isNotEmpty)
                      Text('Email: ${widget.client.email}'),
                    if (widget.client.dateOfBirth.isNotEmpty)
                      Text('Data de Nascimento: ${widget.client.dateOfBirth}'),
                    if (widget.client.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Notas: ${widget.client.notes}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            ...fields.expand((field) {
              // Verifica se o campo deve ser exibido baseado em dependências
              if (!_shouldShowField(field)) {
                return []; // Não renderiza o campo
              }

              final widgets = <Widget>[];

              if (field['type'] == 'bool') {
                widgets.add(
                  CheckboxListTile(
                    title: Text(field['label']),
                    value: _checkboxValues[field['key']] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _checkboxValues[field['key']] = value ?? false;
                        // Sempre salva true ou false
                        _formData[field['key']] = value ?? false;
                      });
                    },
                  ),
                );
              } else if (field['type'] == 'number') {
                widgets.add(
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _buildInputDecoration(
                      field['label'],
                      _getHintText(field['key']),
                    ),
                    onSaved: (value) {
                      if (value?.isNotEmpty ?? false) {
                        _formData[field['key']] = int.tryParse(value!) ?? 0;
                      }
                    },
                  ),
                );
              } else if (field['type'] == 'enum') {
                final enumValues = _getEnumValues(field['key']);
                
                widgets.add(
                  _buildEnumDropdownWithValidation(
                    fieldKey: field['key'],
                    label: field['label'],
                    value: _enumValues[field['key']],
                    items: enumValues,
                    onChanged: (value) {
                      setState(() {
                        _enumValues[field['key']] = value;
                        _formData[field['key']] = value;
                      });
                    },
                  ),
                );
              } else {
                // Text fields with special handling for phone, email, multiline
                bool isPhone = field['key'] == 'phone' || 
                              field['key'] == 'whatsapp';
                bool isEmail = field['key'] == 'email';
                int maxLines = field['key'] == 'address' ? 2 : 1;

                widgets.add(
                  TextFormField(
                    keyboardType: isEmail 
                        ? TextInputType.emailAddress
                        : isPhone 
                            ? TextInputType.phone 
                            : TextInputType.text,
                    maxLines: maxLines,
                    decoration: _buildInputDecoration(
                      field['label'],
                      _getHintText(field['key']),
                    ),
                    validator: isEmail ? (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final email = value.trim();
                      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                      if (!emailRegex.hasMatch(email)) {
                        return 'Email inválido';
                      }
                      return null;
                    } : null,
                    onSaved: (value) {
                      if (value?.isNotEmpty ?? false) {
                        _formData[field['key']] = value;
                      }
                    },
                  ),
                );
              }

              // Adiciona espaçamento entre campos
              widgets.add(const SizedBox(height: 20));

              return widgets;
            }).toList(),

            ElevatedButton(
              onPressed: saveData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Salvar Anamnese'),
            ),
          ],
        ),
      ),
    );
  }
}
