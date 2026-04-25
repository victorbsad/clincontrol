import '../models/anamnesis.dart';
import '../models/client.dart';
import '../models/session.dart';
import '../../core/constants/anamnesis_enums.dart';
import '../../core/constants/anamnesis_keys.dart';
import '../../core/utils/app_date_formatter.dart';

class DevMockModels {
  const DevMockModels._();

  static const String notesMarker = '[DEV-MOCK]';

  static Client buildClient({String? name}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return Client(
      name: name ?? 'Cliente Dev $timestamp',
      phone: '(11) 99999-0000',
      notes: '$notesMarker Gerado para laboratorio de CRUD.',
      maritalStatus: 'Solteira',
      nationality: 'Brasileira',
      address: 'Rua Exemplo, 123 - Centro',
      whatsapp: '(11) 98888-0000',
      email: 'cliente.dev.$timestamp@example.com',
      dateOfBirth: '20/05/1994',
      age: '31',
      profession: 'Profissao de Teste',
    );
  }

  static Session buildSession({
    required int clientId,
    DateTime? date,
    double amount = 100.0,
    String procedure = 'Procedimento Teste',
    String notes = 'Observacoes de teste',
    String status = Session.statusScheduled,
  }) {
    final targetDate = date ?? DateTime.now();
    final dbDate = AppDateFormatter.toDatabaseIsoDate(targetDate);
    final now = DateTime.now();

    return Session(
      clientId: clientId,
      procedure: procedure,
      notes: notes,
      amount: amount,
      status: status,
      date: dbDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  static Anamnesis buildAnamnesis({required int clientId, DateTime? now}) {
    final createdAt = now ?? DateTime.now();
    return Anamnesis(
      clientId: clientId,
      createdAt: createdAt,
      updatedAt: createdAt,
      answers: sampleAnswers(),
    );
  }

  static Map<String, dynamic> sampleAnswers() {
    return {
      AnamnesisKeys.visitReasonAcne: true,
      AnamnesisKeys.visitReasonMelasma: true,
      AnamnesisKeys.visitReasonOther:
          'Validacao de fluxo em desenvolvimento para anamnese facial completa.',
      AnamnesisKeys.hadAestheticTreatment: true,
      AnamnesisKeys.aestheticTreatmentType:
          'Limpeza de pele, peeling e drenagem linfatica',
      AnamnesisKeys.keloidScarring: true,
      AnamnesisKeys.scarringComment: 'Cicatriz elevada em ombro esquerdo',
      AnamnesisKeys.usesMedication: true,
      AnamnesisKeys.medicationType: 'Multivitaminico e anti-histaminico',
      AnamnesisKeys.isotretinoin6Months: true,
      AnamnesisKeys.isotretinoin6MonthsComment: 'Uso previo ha 4 meses',
      AnamnesisKeys.hadMedicalTreatment: true,
      AnamnesisKeys.healthProblemType:
          'Acompanhamento dermatologico e endocrinologico',
      AnamnesisKeys.thrombosis: true,
      AnamnesisKeys.thrombosisLocation: 'Membro inferior direito',
      AnamnesisKeys.hadSurgery: true,
      AnamnesisKeys.surgeryType: 'Apendicectomia e rinoplastia',
      AnamnesisKeys.hasOncologicalHistory: true,
      AnamnesisKeys.oncologicalComment:
          'Historico familiar positivo para cancer de mama',
      AnamnesisKeys.infectiousDiseaseHistory: true,
      AnamnesisKeys.infectiousDiseaseType: 'Herpes labial pregresso',
      AnamnesisKeys.exercisesRegularly: true,
      AnamnesisKeys.exerciseType: 'Musculacao 4x por semana',
      AnamnesisKeys.balancedDiet: true,
      AnamnesisKeys.dietComment:
          'Dieta com orientacao nutricional e boa adesao',
      AnamnesisKeys.drinks2LitersWater: true,
      AnamnesisKeys.waterIntakeAmount: 2.5,
      AnamnesisKeys.consumesAlcohol: true,
      AnamnesisKeys.alcoholFrequency: AnamnesisFrequency.weekly.canonical,
      AnamnesisKeys.alcoholFrequencyOther:
          '1 a 2 vezes por semana em eventos sociais',
      AnamnesisKeys.usesDrugs: true,
      AnamnesisKeys.drugType: 'Nao faz uso de drogas ilicitas',
      AnamnesisKeys.hormoneImbalance: true,
      AnamnesisKeys.hormoneImbalanceType:
          'Sindrome dos ovarios policisticos em acompanhamento',
      AnamnesisKeys.smokingStatus: AnamnesisSmokingStatus.exSmoker.canonical,
      AnamnesisKeys.smokingDuration: '8 anos',
      AnamnesisKeys.sleepsWell: true,
      AnamnesisKeys.sleepHours: 7.5,
      AnamnesisKeys.regularBowelMovements: true,
      AnamnesisKeys.bowelComment: 'Evacuacao diaria sem intercorrencias',
      AnamnesisKeys.hypertensionStatus: AnamnesisPressureStatus.no.canonical,
      AnamnesisKeys.hypotensionStatus:
          AnamnesisPressureStatus.compensated.canonical,
      AnamnesisKeys.hasDiabetes: true,
      AnamnesisKeys.diabetesControlled: 'Compensada',
      AnamnesisKeys.hasCardiacCondition: true,
      AnamnesisKeys.cardiacConditionType:
          'Prolapso de valva mitral sem repercussao funcional',
      AnamnesisKeys.hasDepression: true,
      AnamnesisKeys.depressionTreatment: 'Psicoterapia regular',
      AnamnesisKeys.hasEpilepsy: true,
      AnamnesisKeys.epilepsyComment: 'Sem crises recentes',
      AnamnesisKeys.hasDentalImplants: true,
      AnamnesisKeys.dentalImplantLocation: 'Regiao inferior posterior',
      AnamnesisKeys.hasDentures: true,
      AnamnesisKeys.denturesComment: 'Proteses fixas superiores',
      AnamnesisKeys.wearsContactLenses: true,
      AnamnesisKeys.contactLensesComment: 'Uso diario de lentes gelatinosas',
      AnamnesisKeys.usesAcids: true,
      AnamnesisKeys.acidType: 'Acido glicolico e retinoico',
      AnamnesisKeys.usesCosmeticProducts: true,
      AnamnesisKeys.cosmeticProductTypes:
          'Hidratante, serum de vitamina C e vitamina A',
      AnamnesisKeys.usesSunscreen: true,
      AnamnesisKeys.sunscreenType: 'FPS 50 com cor',
      AnamnesisKeys.sunscreenFrequency: AnamnesisFrequency.daily.canonical,
      AnamnesisKeys.sunscreenFrequencyOther: 'Reaplica a cada 3 horas',
      AnamnesisKeys.exposedToSun: true,
      AnamnesisKeys.sunExposureFrequency: AnamnesisFrequency.weekly.canonical,
      AnamnesisKeys.sunExposureFrequencyOther:
          'Exposicao moderada em caminhada ao ar livre',
      AnamnesisKeys.hasPermanentMakeup: true,
      AnamnesisKeys.permanentMakeupLocation: 'Sobrancelhas e labios',
      AnamnesisKeys.usedBotulinum: true,
      AnamnesisKeys.botulinumLocation: 'Testa e glabela',
      AnamnesisKeys.hasAllergies: true,
      AnamnesisKeys.allergiesDetails:
          'Alergia respiratoria a poeira e sensibilidade a alguns cosmeticos',
      AnamnesisKeys.isPregnant: true,
      AnamnesisKeys.pregnancyMonths: 3,
      AnamnesisKeys.hasChildren: true,
      AnamnesisKeys.numberOfChildren: 2,
      AnamnesisKeys.regularMenstrualCycle: true,
      AnamnesisKeys.menstrualCycleComment: 'Ciclo mensal regular',
      AnamnesisKeys.hasHerpesHistory: true,
      AnamnesisKeys.herpesDuration: 'Ultimo episodio ha 1 ano',
      AnamnesisKeys.usesContraceptive: true,
      AnamnesisKeys.contraceptiveType: 'Anticoncepcional oral combinado',
      AnamnesisKeys.takesHormones: true,
      AnamnesisKeys.hormoneType: 'Estrogenio e progesterona',
      AnamnesisKeys.authorizedForPhotos: true,
      AnamnesisKeys.photoAuthorizationComment:
          'Autorizo uso para prontuario e divulgacao anonima',
      AnamnesisKeys.estrogenComment:
          'Uso de estrogênio com acompanhamento ginecologico',
      AnamnesisKeys.oilySkinSensitive: true,
      AnamnesisKeys.oilySkinResistant: true,
      AnamnesisKeys.oilySkinPigmented: true,
      AnamnesisKeys.oilySkinNonPigmented: true,
      AnamnesisKeys.oilySkinFirm: true,
      AnamnesisKeys.oilySkinWrinkled: true,
      AnamnesisKeys.drySkinSensitive: true,
      AnamnesisKeys.drySkinResistant: true,
      AnamnesisKeys.drySkinPigmented: true,
      AnamnesisKeys.drySkinNonPigmented: true,
      AnamnesisKeys.drySkinFirm: true,
      AnamnesisKeys.drySkinWrinkled: true,
      AnamnesisKeys.combinationSkinSensitive: true,
      AnamnesisKeys.combinationSkinResistant: true,
      AnamnesisKeys.combinationSkinPigmented: true,
      AnamnesisKeys.combinationSkinNonPigmented: true,
      AnamnesisKeys.combinationSkinFirm: true,
      AnamnesisKeys.combinationSkinWrinkled: true,
      AnamnesisKeys.hasComedo: true,
      AnamnesisKeys.hasPustule: true,
      AnamnesisKeys.hasPapule: true,
      AnamnesisKeys.hasNodule: true,
      AnamnesisKeys.hasHyperkeratinization: true,
      AnamnesisKeys.hasMilium: true,
      AnamnesisKeys.hasMicrocyst: true,
      AnamnesisKeys.hasInflammatoryAcne: true,
      AnamnesisKeys.hasNonInflammatoryAcne: true,
      AnamnesisKeys.hasTelangiectasiaNevus: true,
      AnamnesisKeys.hasActinicKeratosis: true,
      AnamnesisKeys.hasMelanocyticNevus: true,
      AnamnesisKeys.hasDermatosisPapulosa: true,
      AnamnesisKeys.hasPapilloma: true,
      AnamnesisKeys.hasAcrochordion: true,
      AnamnesisKeys.hasOtherLesions: 'Acrocordons pequenos em pescoco',
      AnamnesisKeys.hasInflammatoryHyperpigmentation: true,
      AnamnesisKeys.hasPhotoaging: true,
      AnamnesisKeys.hasMelasma: true,
      AnamnesisKeys.hasFreckles: true,
      AnamnesisKeys.hasOrbicularHyperpigmentation: true,
      AnamnesisKeys.hasHypochromia: true,
      AnamnesisKeys.chromaticAbnormalityJustification:
          'Escurecimento periorbital e exposicao solar pregressa',
      AnamnesisKeys.skinPhototype: AnamnesisSkinPhototype.iii.canonical,
      AnamnesisKeys.hasDermatitis: true,
      AnamnesisKeys.hasPsoriasis: true,
      AnamnesisKeys.treatmentIndicated:
          'Tratamento combinado com limpeza de pele, peeling e home care',
      AnamnesisKeys.cosmeticPrescription:
          'Limpeza suave, hidratante reparador, FPS 50 e antioxidante diurno.',
    };
  }

  static bool isDevMockClient(Client client) {
    return client.notes.contains(notesMarker);
  }
}
