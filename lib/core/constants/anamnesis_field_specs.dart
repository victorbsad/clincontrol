import 'anamnesis_keys.dart';

enum AnamnesisValueType {
  boolean,
  integer,
  decimal,
  date,
  text,
  enumValue,
  json,
}

class AnamnesisFieldSpec {
  final AnamnesisValueType valueType;
  final bool required;
  final List<String> enumValues;

  const AnamnesisFieldSpec({
    required this.valueType,
    this.required = false,
    this.enumValues = const [],
  });
}

class AnamnesisFieldSpecs {
  const AnamnesisFieldSpecs._();

  static const List<String> yesNoEnumValues = [
    'nao',
    'compensada',
    'descompensada',
  ];

  static const List<String> smokingStatusEnumValues = [
    'nao',
    'ex_fumante',
    'sim',
  ];

  static const List<String> frequencyEnumValues = [
    'nunca',
    'raro',
    'semanal',
    'diario',
    'outro',
  ];

  static const List<String> visitReasonEnumValues = [
    'avaliacao_inicial',
    'acne',
    'melasma',
    'manchas',
    'rugas',
    'oleosidade',
    'sensibilidade',
    'manutencao',
    'outro',
  ];

  static const List<String> skinPhototypeEnumValues = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
  ];

  static const Set<String> _booleanKeys = {
    AnamnesisKeys.hadAestheticTreatment,
    AnamnesisKeys.keloidScarring,
    AnamnesisKeys.usesMedication,
    AnamnesisKeys.isotretinoin6Months,
    AnamnesisKeys.hadMedicalTreatment,
    AnamnesisKeys.thrombosis,
    AnamnesisKeys.hadSurgery,
    AnamnesisKeys.hasOncologicalHistory,
    AnamnesisKeys.infectiousDiseaseHistory,
    AnamnesisKeys.exercisesRegularly,
    AnamnesisKeys.balancedDiet,
    AnamnesisKeys.drinks2LitersWater,
    AnamnesisKeys.consumesAlcohol,
    AnamnesisKeys.usesDrugs,
    AnamnesisKeys.hormoneImbalance,
    AnamnesisKeys.sleepsWell,
    AnamnesisKeys.regularBowelMovements,
    AnamnesisKeys.hasDiabetes,
    AnamnesisKeys.hasCardiacCondition,
    AnamnesisKeys.hasDepression,
    AnamnesisKeys.hasEpilepsy,
    AnamnesisKeys.hasDentalImplants,
    AnamnesisKeys.hasDentures,
    AnamnesisKeys.wearsContactLenses,
    AnamnesisKeys.usesAcids,
    AnamnesisKeys.usesCosmeticProducts,
    AnamnesisKeys.usesSunscreen,
    AnamnesisKeys.exposedToSun,
    AnamnesisKeys.hasPermanentMakeup,
    AnamnesisKeys.usedBotulinum,
    AnamnesisKeys.hasAllergies,
    AnamnesisKeys.isPregnant,
    AnamnesisKeys.hasChildren,
    AnamnesisKeys.regularMenstrualCycle,
    AnamnesisKeys.hasHerpesHistory,
    AnamnesisKeys.usesContraceptive,
    AnamnesisKeys.takesHormones,
    AnamnesisKeys.authorizedForPhotos,
    AnamnesisKeys.oilySkinSensitive,
    AnamnesisKeys.oilySkinResistant,
    AnamnesisKeys.oilySkinPigmented,
    AnamnesisKeys.oilySkinNonPigmented,
    AnamnesisKeys.oilySkinFirm,
    AnamnesisKeys.oilySkinWrinkled,
    AnamnesisKeys.drySkinSensitive,
    AnamnesisKeys.drySkinResistant,
    AnamnesisKeys.drySkinPigmented,
    AnamnesisKeys.drySkinNonPigmented,
    AnamnesisKeys.drySkinFirm,
    AnamnesisKeys.drySkinWrinkled,
    AnamnesisKeys.combinationSkinSensitive,
    AnamnesisKeys.combinationSkinResistant,
    AnamnesisKeys.combinationSkinPigmented,
    AnamnesisKeys.combinationSkinNonPigmented,
    AnamnesisKeys.combinationSkinFirm,
    AnamnesisKeys.combinationSkinWrinkled,
    AnamnesisKeys.hasComedo,
    AnamnesisKeys.hasPustule,
    AnamnesisKeys.hasPapule,
    AnamnesisKeys.hasNodule,
    AnamnesisKeys.hasHyperkeratinization,
    AnamnesisKeys.hasMilium,
    AnamnesisKeys.hasMicrocyst,
    AnamnesisKeys.hasInflammatoryAcne,
    AnamnesisKeys.hasNonInflammatoryAcne,
    AnamnesisKeys.hasTelangiectasiaNevus,
    AnamnesisKeys.hasActinicKeratosis,
    AnamnesisKeys.hasMelanocyticNevus,
    AnamnesisKeys.hasDermatosisPapulosa,
    AnamnesisKeys.hasPapilloma,
    AnamnesisKeys.hasAcrochordion,
    AnamnesisKeys.hasInflammatoryHyperpigmentation,
    AnamnesisKeys.hasPhotoaging,
    AnamnesisKeys.hasMelasma,
    AnamnesisKeys.hasFreckles,
    AnamnesisKeys.hasOrbicularHyperpigmentation,
    AnamnesisKeys.hasHypochromia,
    AnamnesisKeys.hasDermatitis,
    AnamnesisKeys.hasPsoriasis,
    AnamnesisKeys.visitReasonInitialEvaluation,
    AnamnesisKeys.visitReasonAcne,
    AnamnesisKeys.visitReasonMelasma,
    AnamnesisKeys.visitReasonSpots,
    AnamnesisKeys.visitReasonWrinkles,
    AnamnesisKeys.visitReasonOiliness,
    AnamnesisKeys.visitReasonSensitivity,
    AnamnesisKeys.visitReasonMaintenance,
  };

  static const Set<String> _integerKeys = {
    AnamnesisKeys.pregnancyMonths,
    AnamnesisKeys.numberOfChildren,
  };

  static const Set<String> _decimalKeys = {
    AnamnesisKeys.waterIntakeAmount,
    AnamnesisKeys.sleepHours,
  };

  static const Set<String> _dateKeys = {
    AnamnesisKeys.dateOfBirth,
    AnamnesisKeys.updatedAt,
  };

  static const Map<String, AnamnesisFieldSpec> _explicitSpecs = {
    AnamnesisKeys.hypertensionStatus: AnamnesisFieldSpec(
      valueType: AnamnesisValueType.enumValue,
      enumValues: yesNoEnumValues,
    ),
    AnamnesisKeys.hypotensionStatus: AnamnesisFieldSpec(
      valueType: AnamnesisValueType.enumValue,
      enumValues: yesNoEnumValues,
    ),
    AnamnesisKeys.smokingStatus: AnamnesisFieldSpec(
      valueType: AnamnesisValueType.enumValue,
      enumValues: smokingStatusEnumValues,
    ),
    AnamnesisKeys.skinPhototype: AnamnesisFieldSpec(
      valueType: AnamnesisValueType.enumValue,
      enumValues: skinPhototypeEnumValues,
    ),
    AnamnesisKeys.alcoholFrequency: AnamnesisFieldSpec(
      valueType: AnamnesisValueType.enumValue,
      enumValues: frequencyEnumValues,
    ),
    AnamnesisKeys.sunscreenFrequency: AnamnesisFieldSpec(
      valueType: AnamnesisValueType.enumValue,
      enumValues: frequencyEnumValues,
    ),
    AnamnesisKeys.sunExposureFrequency: AnamnesisFieldSpec(
      valueType: AnamnesisValueType.enumValue,
      enumValues: frequencyEnumValues,
    ),
    AnamnesisKeys.visitReasonOption: AnamnesisFieldSpec(
      valueType: AnamnesisValueType.enumValue,
      enumValues: visitReasonEnumValues,
    ),
  };

  static final Set<String> knownKeys = {
    ..._booleanKeys,
    ..._integerKeys,
    ..._decimalKeys,
    ..._dateKeys,
    ..._explicitSpecs.keys,
    AnamnesisKeys.maritalStatus,
    AnamnesisKeys.nationality,
    AnamnesisKeys.address,
    AnamnesisKeys.phone,
    AnamnesisKeys.whatsapp,
    AnamnesisKeys.email,
    AnamnesisKeys.age,
    AnamnesisKeys.profession,
    AnamnesisKeys.visitReasonOther,
    AnamnesisKeys.aestheticTreatmentType,
    AnamnesisKeys.scarringComment,
    AnamnesisKeys.medicationType,
    AnamnesisKeys.isotretinoin6MonthsComment,
    AnamnesisKeys.healthProblemType,
    AnamnesisKeys.thrombosisLocation,
    AnamnesisKeys.surgeryType,
    AnamnesisKeys.oncologicalComment,
    AnamnesisKeys.infectiousDiseaseType,
    AnamnesisKeys.exerciseType,
    AnamnesisKeys.dietComment,
    AnamnesisKeys.alcoholFrequencyOther,
    AnamnesisKeys.drugType,
    AnamnesisKeys.hormoneImbalanceType,
    AnamnesisKeys.smokingDuration,
    AnamnesisKeys.bowelComment,
    AnamnesisKeys.diabetesControlled,
    AnamnesisKeys.cardiacConditionType,
    AnamnesisKeys.depressionTreatment,
    AnamnesisKeys.epilepsyComment,
    AnamnesisKeys.dentalImplantLocation,
    AnamnesisKeys.denturesComment,
    AnamnesisKeys.contactLensesComment,
    AnamnesisKeys.acidType,
    AnamnesisKeys.cosmeticProductTypes,
    AnamnesisKeys.sunscreenType,
    AnamnesisKeys.sunscreenFrequencyOther,
    AnamnesisKeys.sunExposureFrequencyOther,
    AnamnesisKeys.permanentMakeupLocation,
    AnamnesisKeys.botulinumLocation,
    AnamnesisKeys.allergiesDetails,
    AnamnesisKeys.menstrualCycleComment,
    AnamnesisKeys.herpesDuration,
    AnamnesisKeys.contraceptiveType,
    AnamnesisKeys.hormoneType,
    AnamnesisKeys.photoAuthorizationComment,
    AnamnesisKeys.estrogenComment,
    AnamnesisKeys.hasOtherLesions,
    AnamnesisKeys.chromaticAbnormalityJustification,
    AnamnesisKeys.treatmentIndicated,
    AnamnesisKeys.cosmeticPrescription,
  };

  static AnamnesisFieldSpec resolve(String key) {
    final explicit = _explicitSpecs[key];
    if (explicit != null) {
      return explicit;
    }
    if (_booleanKeys.contains(key)) {
      return const AnamnesisFieldSpec(valueType: AnamnesisValueType.boolean);
    }
    if (_integerKeys.contains(key)) {
      return const AnamnesisFieldSpec(valueType: AnamnesisValueType.integer);
    }
    if (_decimalKeys.contains(key)) {
      return const AnamnesisFieldSpec(valueType: AnamnesisValueType.decimal);
    }
    if (_dateKeys.contains(key)) {
      return const AnamnesisFieldSpec(valueType: AnamnesisValueType.date);
    }
    return const AnamnesisFieldSpec(valueType: AnamnesisValueType.text);
  }
}
