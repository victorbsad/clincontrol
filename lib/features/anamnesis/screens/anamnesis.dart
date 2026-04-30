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
        _enumValues[field['key']] = field['defaultValue'] as String?;
      }
    }
  }

  final List<Map<String, dynamic>> fields = [
    // ========== MOTIVO DA VISITA ==========
    {'key': 'visitReasonInitialEvaluation', 'label': 'Avaliação Inicial', 'type': 'bool', 'section': 'MOTIVO DA VISITA'},
    {'key': 'visitReasonAcne', 'label': 'Acne', 'type': 'bool', 'section': 'MOTIVO DA VISITA'},
    {'key': 'visitReasonMelasma', 'label': 'Melasma', 'type': 'bool', 'section': 'MOTIVO DA VISITA'},
    {'key': 'visitReasonSpots', 'label': 'Manchas', 'type': 'bool', 'section': 'MOTIVO DA VISITA'},
    {'key': 'visitReasonWrinkles', 'label': 'Rugas', 'type': 'bool', 'section': 'MOTIVO DA VISITA'},
    {'key': 'visitReasonOiliness', 'label': 'Oleosidade', 'type': 'bool', 'section': 'MOTIVO DA VISITA'},
    {'key': 'visitReasonSensitivity', 'label': 'Sensibilidade', 'type': 'bool', 'section': 'MOTIVO DA VISITA'},
    {'key': 'visitReasonMaintenance', 'label': 'Manutenção', 'type': 'bool', 'section': 'MOTIVO DA VISITA'},
    {'key': 'visitReasonOther', 'label': 'Outro Motivo', 'type': 'text', 'section': 'MOTIVO DA VISITA'},

    // ========== HISTÓRICO ESTÉTICO ==========
    {'key': 'hadAestheticTreatment', 'label': 'Fez Tratamento Estético?', 'type': 'bool', 'section': 'HISTÓRICO ESTÉTICO'},
    {'key': 'aestheticTreatmentType', 'label': 'Tipo de Tratamento Estético', 'type': 'text', 'dependsOn': 'hadAestheticTreatment', 'section': 'HISTÓRICO ESTÉTICO'},
    {'key': 'keloidScarring', 'label': 'Tendência a Cicatrizes Queloides?', 'type': 'bool', 'section': 'HISTÓRICO ESTÉTICO'},
    {'key': 'scarringComment', 'label': 'Observações sobre Cicatrização', 'type': 'text', 'dependsOn': 'keloidScarring', 'section': 'HISTÓRICO ESTÉTICO'},
    {'key': 'usesMedication', 'label': 'Usa Medicação?', 'type': 'bool', 'section': 'HISTÓRICO ESTÉTICO'},
    {'key': 'medicationType', 'label': 'Tipo de Medicação', 'type': 'text', 'dependsOn': 'usesMedication', 'section': 'HISTÓRICO ESTÉTICO'},
    {'key': 'isotretinoin6Months', 'label': 'Usou Isotretinoína nos últimos 6 meses?', 'type': 'bool', 'section': 'HISTÓRICO ESTÉTICO'},
    {'key': 'isotretinoin6MonthsComment', 'label': 'Observações sobre Isotretinoína', 'type': 'text', 'dependsOn': 'isotretinoin6Months', 'section': 'HISTÓRICO ESTÉTICO'},

    // ========== HISTÓRICO MÉDICO ==========
    {'key': 'hadMedicalTreatment', 'label': 'Fez Tratamento Médico?', 'type': 'bool', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'healthProblemType', 'label': 'Tipo de Problema de Saúde', 'type': 'text', 'dependsOn': 'hadMedicalTreatment', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'thrombosis', 'label': 'Teve Trombose?', 'type': 'bool', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'thrombosisLocation', 'label': 'Localização da Trombose', 'type': 'text', 'dependsOn': 'thrombosis', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'hadSurgery', 'label': 'Fez Cirurgia?', 'type': 'bool', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'surgeryType', 'label': 'Tipo de Cirurgia', 'type': 'text', 'dependsOn': 'hadSurgery', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'hasOncologicalHistory', 'label': 'Histórico de Câncer?', 'type': 'bool', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'oncologicalComment', 'label': 'Observações sobre Câncer', 'type': 'text', 'dependsOn': 'hasOncologicalHistory', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'infectiousDiseaseHistory', 'label': 'Histórico de Doença Infecciosa?', 'type': 'bool', 'section': 'HISTÓRICO MÉDICO'},
    {'key': 'infectiousDiseaseType', 'label': 'Tipo de Doença Infecciosa', 'type': 'text', 'dependsOn': 'infectiousDiseaseHistory', 'section': 'HISTÓRICO MÉDICO'},

    // ========== HÁBITOS DE VIDA ==========
    {'key': 'exercisesRegularly', 'label': 'Pratica Exercício Regularmente?', 'type': 'bool', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'exerciseType', 'label': 'Tipo de Exercício', 'type': 'text', 'dependsOn': 'exercisesRegularly', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'balancedDiet', 'label': 'Segue Alimentação Balanceada?', 'type': 'bool', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'dietComment', 'label': 'Observações sobre Dieta', 'type': 'text', 'dependsOn': 'balancedDiet', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'drinks2LitersWater', 'label': 'Bebe 2 litros de Água?', 'type': 'bool', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'waterIntakeAmount', 'label': 'Quantidade de Água Ingerida', 'type': 'text', 'dependsOn': 'drinks2LitersWater', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'consumesAlcohol', 'label': 'Consome Álcool?', 'type': 'bool', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'alcoholFrequency', 'label': 'Frequência de Álcool', 'type': 'enum', 'dependsOn': 'consumesAlcohol', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'alcoholFrequencyOther', 'label': 'Outra Frequência de Álcool', 'type': 'text', 'dependsOn': 'alcoholFrequency', 'dependsOnValue': 'outro', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'usesDrugs', 'label': 'Usa Drogas?', 'type': 'bool', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'drugType', 'label': 'Tipo de Droga', 'type': 'text', 'dependsOn': 'usesDrugs', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'hormoneImbalance', 'label': 'Desequilíbrio Hormonal?', 'type': 'bool', 'section': 'HÁBITOS DE VIDA'},
    {'key': 'hormoneImbalanceType', 'label': 'Tipo de Desequilíbrio Hormonal', 'type': 'text', 'dependsOn': 'hormoneImbalance', 'section': 'HÁBITOS DE VIDA'},

    // ========== FUMO ==========
    {'key': 'smokingStatus', 'label': 'Fumante?', 'type': 'enum', 'section': 'TABAGISMO', 'defaultValue': 'nao'},
    {'key': 'smokingDuration', 'label': 'Quanto tempo?', 'type': 'text', 'dependsOn': 'smokingStatus', 'dependsOnValue': '!nao', 'section': 'TABAGISMO'},

    // ========== SONO & INTESTINO ==========
    {'key': 'sleepsWell', 'label': 'Dorme Bem?', 'type': 'bool', 'section': 'SONO & INTESTINO'},
    {'key': 'sleepHours', 'label': 'Horas de Sono', 'type': 'number', 'section': 'SONO & INTESTINO'},
    {'key': 'regularBowelMovements', 'label': 'Evacuação Regular?', 'type': 'bool', 'section': 'SONO & INTESTINO'},
    {'key': 'bowelComment', 'label': 'Observações sobre Evacuação', 'type': 'text', 'dependsOn': 'regularBowelMovements', 'section': 'SONO & INTESTINO'},

    // ========== PRESSÃO ARTERIAL ==========
    {'key': 'hypertensionStatus', 'label': 'Hipertensão?', 'type': 'enum', 'section': 'PRESSÃO ARTERIAL', 'defaultValue': 'nao'},
    {'key': 'hypotensionStatus', 'label': 'Hipotensão?', 'type': 'enum', 'section': 'PRESSÃO ARTERIAL', 'defaultValue': 'nao'},

    // ========== CONDIÇÕES MÉDICAS ==========
    {'key': 'hasDiabetes', 'label': 'Tem Diabetes?', 'type': 'bool', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'diabetesControlled', 'label': 'Diabetes Controlada?', 'type': 'bool', 'dependsOn': 'hasDiabetes', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'hasCardiacCondition', 'label': 'Doença Cardíaca?', 'type': 'bool', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'cardiacConditionType', 'label': 'Tipo de Doença Cardíaca', 'type': 'text', 'dependsOn': 'hasCardiacCondition', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'hasDepression', 'label': 'Depressão?', 'type': 'bool', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'depressionTreatment', 'label': 'Tratamento para Depressão', 'type': 'text', 'dependsOn': 'hasDepression', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'hasEpilepsy', 'label': 'Epilepsia?', 'type': 'bool', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'epilepsyComment', 'label': 'Observações sobre Epilepsia', 'type': 'text', 'dependsOn': 'hasEpilepsy', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'hasDentalImplants', 'label': 'Implante Dental?', 'type': 'bool', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'dentalImplantLocation', 'label': 'Localização do Implante Dental', 'type': 'text', 'dependsOn': 'hasDentalImplants', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'hasDentures', 'label': 'Prótese Dentária?', 'type': 'bool', 'section': 'CONDIÇÕES MÉDICAS'},
    {'key': 'denturesComment', 'label': 'Observações sobre Prótese', 'type': 'text', 'dependsOn': 'hasDentures', 'section': 'CONDIÇÕES MÉDICAS'},

    // ========== LENTES DE CONTATO ==========
    {'key': 'wearsContactLenses', 'label': 'Lentes de Contato?', 'type': 'bool', 'section': 'LENTES DE CONTATO'},
    {'key': 'contactLensesComment', 'label': 'Observações sobre Lentes', 'type': 'text', 'dependsOn': 'wearsContactLenses', 'section': 'LENTES DE CONTATO'},

    // ========== ÁCIDOS & COSMÉTICOS ==========
    {'key': 'usesAcids', 'label': 'Ácidos?', 'type': 'bool', 'section': 'ÁCIDOS & COSMÉTICOS'},
    {'key': 'acidType', 'label': 'Tipo de Ácido', 'type': 'text', 'dependsOn': 'usesAcids', 'section': 'ÁCIDOS & COSMÉTICOS'},
    {'key': 'usesCosmeticProducts', 'label': 'Produtos Cosméticos?', 'type': 'bool', 'section': 'ÁCIDOS & COSMÉTICOS'},
    {'key': 'cosmeticProductTypes', 'label': 'Tipo de Produto Cosmético', 'type': 'text', 'dependsOn': 'usesCosmeticProducts', 'section': 'ÁCIDOS & COSMÉTICOS'},
    {'key': 'usesSunscreen', 'label': 'Protetor Solar?', 'type': 'bool', 'section': 'ÁCIDOS & COSMÉTICOS'},
    {'key': 'sunscreenType', 'label': 'Tipo de Protetor Solar', 'type': 'text', 'dependsOn': 'usesSunscreen', 'section': 'ÁCIDOS & COSMÉTICOS'},

    // ========== FREQUÊNCIA DE PROTETOR SOLAR ==========
    {'key': 'sunscreenFrequency', 'label': 'Frequência de Protetor Solar', 'type': 'enum', 'dependsOn': 'usesSunscreen', 'section': 'PROTETOR SOLAR'},
    {'key': 'sunscreenFrequencyOther', 'label': 'Outra Frequência de Protetor', 'type': 'text', 'dependsOn': 'sunscreenFrequency', 'dependsOnValue': 'outro', 'section': 'PROTETOR SOLAR'},

    // ========== SOL & MAQUIAGEM ==========
    {'key': 'exposedToSun', 'label': 'Exposto ao Sol?', 'type': 'bool', 'section': 'SOL & MAQUIAGEM'},
    {'key': 'sunExposureFrequency', 'label': 'Frequência de Exposição Solar', 'type': 'enum', 'dependsOn': 'exposedToSun', 'section': 'SOL & MAQUIAGEM'},
    {'key': 'sunExposureFrequencyOther', 'label': 'Outra Frequência de Exposição', 'type': 'text', 'dependsOn': 'sunExposureFrequency', 'dependsOnValue': 'outro', 'section': 'SOL & MAQUIAGEM'},
    {'key': 'hasPermanentMakeup', 'label': 'Maquiagem Permanente?', 'type': 'bool', 'section': 'SOL & MAQUIAGEM'},
    {'key': 'permanentMakeupLocation', 'label': 'Localização da Maquiagem Permanente', 'type': 'text', 'dependsOn': 'hasPermanentMakeup', 'section': 'SOL & MAQUIAGEM'},

    // ========== TOXINA BOTULÍNICA ==========
    {'key': 'usedBotulinum', 'label': 'Usou Toxina Botulínica?', 'type': 'bool', 'section': 'TOXINA BOTULÍNICA'},
    {'key': 'botulinumLocation', 'label': 'Localização da Toxina Botulínica', 'type': 'text', 'dependsOn': 'usedBotulinum', 'section': 'TOXINA BOTULÍNICA'},

    // ========== ALERGIAS ==========
    {'key': 'hasAllergies', 'label': 'Tem Alergias?', 'type': 'bool', 'section': 'ALERGIAS'},
    {'key': 'allergiesDetails', 'label': 'Detalhes das Alergias', 'type': 'text', 'dependsOn': 'hasAllergies', 'section': 'ALERGIAS'},

    // ========== GESTAÇÃO ==========
    {'key': 'isPregnant', 'label': 'Grávida?', 'type': 'bool', 'section': 'GESTAÇÃO'},
    {'key': 'pregnancyMonths', 'label': 'Meses de Gestação', 'type': 'number', 'dependsOn': 'isPregnant', 'section': 'GESTAÇÃO'},

    // ========== FILHOS ==========
    {'key': 'hasChildren', 'label': 'Tem Filhos?', 'type': 'bool', 'section': 'FILHOS'},
    {'key': 'numberOfChildren', 'label': 'Quantidade de Filhos', 'type': 'number', 'dependsOn': 'hasChildren', 'section': 'FILHOS'},

    // ========== CICLO MENSTRUAL ==========
    {'key': 'regularMenstrualCycle', 'label': 'Ciclo Menstrual Regular?', 'type': 'bool', 'section': 'CICLO MENSTRUAL'},
    {'key': 'menstrualCycleComment', 'label': 'Observações sobre Ciclo Menstrual', 'type': 'text', 'dependsOn': 'regularMenstrualCycle', 'section': 'CICLO MENSTRUAL'},

    // ========== HERPES & CONTRACEPTIVOS ==========
    {'key': 'hasHerpesHistory', 'label': 'Histórico de Herpes?', 'type': 'bool', 'section': 'SAÚDE REPRODUTIVA'},
    {'key': 'herpesDuration', 'label': 'Duração do Herpes', 'type': 'text', 'dependsOn': 'hasHerpesHistory', 'section': 'SAÚDE REPRODUTIVA'},
    {'key': 'usesContraceptive', 'label': 'Contraceptivo?', 'type': 'bool', 'section': 'SAÚDE REPRODUTIVA'},
    {'key': 'contraceptiveType', 'label': 'Tipo de Contraceptivo', 'type': 'text', 'dependsOn': 'usesContraceptive', 'section': 'SAÚDE REPRODUTIVA'},

    // ========== HORMÔNIOS ==========
    {'key': 'takesHormones', 'label': 'Toma Hormônios?', 'type': 'bool', 'section': 'HORMÔNIOS'},
    {'key': 'hormoneType', 'label': 'Tipo de Hormônio', 'type': 'text', 'dependsOn': 'takesHormones', 'section': 'HORMÔNIOS'},

    // ========== AUTORIZAÇÃO DE FOTOS ==========
    {'key': 'authorizedForPhotos', 'label': 'Autoriza Fotos?', 'type': 'bool', 'section': 'FOTOS'},
    {'key': 'photoAuthorizationComment', 'label': 'Observações sobre Autorização', 'type': 'text', 'dependsOn': 'authorizedForPhotos', 'section': 'FOTOS'},

    // ========== ESTRÓGÊNIO ==========
    {'key': 'estrogenComment', 'label': 'Observações sobre Estrógênio', 'type': 'text', 'section': 'HORMÔNIOS'},

    // ========== PELE OLEOSA ==========
    {'key': 'oilySkinSensitive', 'label': 'Sensível?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - OLEOSA'},
    {'key': 'oilySkinResistant', 'label': 'Resistente?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - OLEOSA'},
    {'key': 'oilySkinPigmented', 'label': 'Pigmentada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - OLEOSA'},
    {'key': 'oilySkinNonPigmented', 'label': 'Não Pigmentada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - OLEOSA'},
    {'key': 'oilySkinFirm', 'label': 'Firme?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - OLEOSA'},
    {'key': 'oilySkinWrinkled', 'label': 'Oleosa Enrugada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - OLEOSA'},

    // ========== PELE SECA ==========
    {'key': 'drySkinSensitive', 'label': 'Sensível?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - SECA'},
    {'key': 'drySkinResistant', 'label': 'Resistente?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - SECA'},
    {'key': 'drySkinPigmented', 'label': 'Pigmentada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - SECA'},
    {'key': 'drySkinNonPigmented', 'label': 'Não Pigmentada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - SECA'},
    {'key': 'drySkinFirm', 'label': 'Firme?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - SECA'},
    {'key': 'drySkinWrinkled', 'label': 'Enrugada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - SECA'},

    // ========== PELE MISTA ==========
    {'key': 'combinationSkinSensitive', 'label': 'Sensível?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - MISTA'},
    {'key': 'combinationSkinResistant', 'label': 'Resistente?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - MISTA'},
    {'key': 'combinationSkinPigmented', 'label': 'Pigmentada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - MISTA'},
    {'key': 'combinationSkinNonPigmented', 'label': 'Não Pigmentada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - MISTA'},
    {'key': 'combinationSkinFirm', 'label': 'Firme?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - MISTA'},
    {'key': 'combinationSkinWrinkled', 'label': 'Enrugada?', 'type': 'bool', 'section': 'ANÁLISE DE PELE - MISTA'},

    // ========== ANÁLISE DE ACNE ==========
    {'key': 'hasComedo', 'label': 'Acne Comedônica?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},
    {'key': 'hasPustule', 'label': 'Acne Pustulosa?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},
    {'key': 'hasPapule', 'label': 'Acne Papulosa?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},
    {'key': 'hasNodule', 'label': 'Acne Nodular?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},
    {'key': 'hasHyperkeratinization', 'label': 'Hiperqueratinização?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},
    {'key': 'hasMilium', 'label': 'Milium?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},
    {'key': 'hasMicrocyst', 'label': 'Microcisto?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},
    {'key': 'hasInflammatoryAcne', 'label': 'Acne Inflamatória?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},
    {'key': 'hasNonInflammatoryAcne', 'label': 'Acne Não Inflamatória?', 'type': 'bool', 'section': 'ANÁLISE DE ACNE'},

    // ========== LESÕES DERMATOLÓGICAS ==========
    {'key': 'hasTelangiectasiaNevus', 'label': 'Nevus Telangiectásico?', 'type': 'bool', 'section': 'LESÕES DERMATOLÓGICAS'},
    {'key': 'hasActinicKeratosis', 'label': 'Queratose Actínica?', 'type': 'bool', 'section': 'LESÕES DERMATOLÓGICAS'},
    {'key': 'hasMelanocyticNevus', 'label': 'Nevus Melanocítico?', 'type': 'bool', 'section': 'LESÕES DERMATOLÓGICAS'},
    {'key': 'hasDermatosisPapulosa', 'label': 'Dermatose Papulosa?', 'type': 'bool', 'section': 'LESÕES DERMATOLÓGICAS'},
    {'key': 'hasPapilloma', 'label': 'Papiloma?', 'type': 'bool', 'section': 'LESÕES DERMATOLÓGICAS'},
    {'key': 'hasAcrochordion', 'label': 'Acrocórdio?', 'type': 'bool', 'section': 'LESÕES DERMATOLÓGICAS'},
    {'key': 'hasOtherLesions', 'label': 'Outras Lesões?', 'type': 'bool', 'section': 'LESÕES DERMATOLÓGICAS'},

    // ========== DISCROMIAS ==========
    {'key': 'hasInflammatoryHyperpigmentation', 'label': 'Hiperpigmentação Inflamatória?', 'type': 'bool', 'section': 'DISCROMIAS'},
    {'key': 'hasPhotoaging', 'label': 'Fotoenvelhecimento?', 'type': 'bool', 'section': 'DISCROMIAS'},
    {'key': 'hasMelasma', 'label': 'Melasma?', 'type': 'bool', 'section': 'DISCROMIAS'},
    {'key': 'hasFreckles', 'label': 'Sardas?', 'type': 'bool', 'section': 'DISCROMIAS'},
    {'key': 'hasOrbicularHyperpigmentation', 'label': 'Hiperpigmentação Orbicular?', 'type': 'bool', 'section': 'DISCROMIAS'},
    {'key': 'hasHypochromia', 'label': 'Hipocromia?', 'type': 'bool', 'section': 'DISCROMIAS'},
    {'key': 'chromaticAbnormalityJustification', 'label': 'Observações sobre Discromias', 'type': 'text', 'section': 'DISCROMIAS'},

    // ========== FOTOTIPO ==========
    {'key': 'skinPhototype', 'label': 'Fototipo', 'type': 'enum', 'section': 'FOTOTIPO', 'defaultValue': 'I'},

    // ========== OUTRAS CONDIÇÕES DERMATOLÓGICAS ==========
    {'key': 'hasDermatitis', 'label': 'Dermatite?', 'type': 'bool', 'section': 'CONDIÇÕES DERMATOLÓGICAS'},
    {'key': 'hasPsoriasis', 'label': 'Psoríase?', 'type': 'bool', 'section': 'CONDIÇÕES DERMATOLÓGICAS'},

    // ========== TRATAMENTO ==========
    {'key': 'treatmentIndicated', 'label': 'Tratamento Indicado', 'type': 'text', 'section': 'PLANO TERAPÊUTICO'},

    // ========== PRESCRIÇÃO ==========
    {'key': 'cosmeticPrescription', 'label': 'Prescrição Cosmética', 'type': 'text', 'section': 'PLANO TERAPÊUTICO'},
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
      
      // Fumante
      'nao': 'Não',
      'ex_fumante': 'Ex-Fumante',
      'sim': 'Sim',
      
      // Frequências
      'raro': 'Raro',
      'semanal': 'Semanal',
      'diario': 'Diário',
      
      // Pressão Arterial
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

  /// Agrupa campos por seção
  Map<String, List<Map<String, dynamic>>> _groupFieldsBySection() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    
    for (var field in fields) {
      if (!_shouldShowField(field)) continue;
      
      final section = field['section'] as String? ?? 'Outros';
      if (!grouped.containsKey(section)) {
        grouped[section] = [];
      }
      grouped[section]!.add(field);
    }
    
    return grouped;
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
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      hintText: hint.isNotEmpty ? hint : null,
      hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.purple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: false,
      counterText: '',
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
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
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
                    borderRadius: BorderRadius.circular(8),
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
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  _humanizeEnumValue(fieldKey, item),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      buttonStyleData: ButtonStyleData(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.expand_more, size: 20),
        iconSize: 20,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
        height: 38,
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  /// Constrói os campos agrupados por seção com visual agradável
  List<Widget> _buildGroupedFields() {
    final grouped = _groupFieldsBySection();
    final widgets = <Widget>[];

    for (final section in grouped.keys) {
      // Adiciona título da seção
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4),
          child: Text(
            section,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );

      // Renderiza os campos da seção em um Card
      widgets.add(
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Colors.purple,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: grouped[section]!.expand((field) {
                return _buildFieldWidget(field);
              }).toList(),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// Constrói um checkbox customizado com visual melhorado
  Widget _buildCustomCheckbox({
    required String label,
    required String fieldKey,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovering = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              decoration: BoxDecoration(
                color: isHovering
                    ? Colors.purple.withValues(alpha: 0.08)
                    : Colors.transparent,
                border: Border.all(
                  color: isHovering
                      ? Colors.purple.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: value,
                      onChanged: onChanged,
                      side: BorderSide(
                        color: Colors.purple.withValues(alpha: 0.7),
                        width: 2,
                      ),
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.purple;
                        }
                        return Colors.transparent;
                      }),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói o widget para um campo individual
  List<Widget> _buildFieldWidget(Map<String, dynamic> field) {
    final widgets = <Widget>[];

    if (field['type'] == 'bool') {
      widgets.add(
        _buildCustomCheckbox(
          label: field['label'],
          fieldKey: field['key'],
          value: _checkboxValues[field['key']] ?? false,
          onChanged: (value) {
            setState(() {
              _checkboxValues[field['key']] = value ?? false;
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
      bool isPhone = field['key'] == 'phone' || field['key'] == 'whatsapp';
      bool isEmail = field['key'] == 'email';
      int? maxLines = field['key'] == 'address' ? 3 : null;

      var decoration = _buildInputDecoration(
        field['label'],
        _getHintText(field['key']),
      );

      widgets.add(
        TextFormField(
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : isPhone
                  ? TextInputType.phone
                  : TextInputType.text,
          maxLines: maxLines,
          minLines: 1,
          maxLength: 500,
          decoration: decoration,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$currentLength/$maxLength',
                style: TextStyle(
                  fontSize: 12,
                  color: currentLength == maxLength
                      ? Colors.red
                      : Colors.grey[600],
                  fontWeight: currentLength == maxLength ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
          validator: isEmail
              ? (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final email = value.trim();
                  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(email)) {
                    return 'Email inválido';
                  }
                  return null;
                }
              : null,
          onSaved: (value) {
            if (value?.isNotEmpty ?? false) {
              _formData[field['key']] = value;
            }
          },
        ),
      );
    }

    // Adiciona espaçamento entre campos dentro da seção
    if (widgets.isNotEmpty) {
      widgets.add(const SizedBox(height: 4));
    }

    return widgets;
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

            ..._buildGroupedFields(),

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
