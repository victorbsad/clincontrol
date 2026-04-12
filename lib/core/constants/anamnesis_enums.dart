import 'anamnesis_keys.dart';

enum AnamnesisVisitReasonOption {
  initialEvaluation,
  acne,
  melasma,
  spots,
  wrinkles,
  oiliness,
  sensitivity,
  maintenance,
  other,
}

extension AnamnesisVisitReasonOptionParse on AnamnesisVisitReasonOption {
  static AnamnesisVisitReasonOption? fromCanonical(String value) {
    switch (value) {
      case 'avaliacao_inicial':
        return AnamnesisVisitReasonOption.initialEvaluation;
      case 'acne':
        return AnamnesisVisitReasonOption.acne;
      case 'melasma':
        return AnamnesisVisitReasonOption.melasma;
      case 'manchas':
        return AnamnesisVisitReasonOption.spots;
      case 'rugas':
        return AnamnesisVisitReasonOption.wrinkles;
      case 'oleosidade':
        return AnamnesisVisitReasonOption.oiliness;
      case 'sensibilidade':
        return AnamnesisVisitReasonOption.sensitivity;
      case 'manutencao':
        return AnamnesisVisitReasonOption.maintenance;
      case 'outro':
        return AnamnesisVisitReasonOption.other;
      default:
        return null;
    }
  }
}

extension AnamnesisVisitReasonOptionExt on AnamnesisVisitReasonOption {
  String get canonical {
    switch (this) {
      case AnamnesisVisitReasonOption.initialEvaluation:
        return 'avaliacao_inicial';
      case AnamnesisVisitReasonOption.acne:
        return 'acne';
      case AnamnesisVisitReasonOption.melasma:
        return 'melasma';
      case AnamnesisVisitReasonOption.spots:
        return 'manchas';
      case AnamnesisVisitReasonOption.wrinkles:
        return 'rugas';
      case AnamnesisVisitReasonOption.oiliness:
        return 'oleosidade';
      case AnamnesisVisitReasonOption.sensitivity:
        return 'sensibilidade';
      case AnamnesisVisitReasonOption.maintenance:
        return 'manutencao';
      case AnamnesisVisitReasonOption.other:
        return 'outro';
    }
  }

  String get label {
    switch (this) {
      case AnamnesisVisitReasonOption.initialEvaluation:
        return 'Avaliacao inicial';
      case AnamnesisVisitReasonOption.acne:
        return 'Acne';
      case AnamnesisVisitReasonOption.melasma:
        return 'Melasma';
      case AnamnesisVisitReasonOption.spots:
        return 'Manchas';
      case AnamnesisVisitReasonOption.wrinkles:
        return 'Rugas';
      case AnamnesisVisitReasonOption.oiliness:
        return 'Oleosidade';
      case AnamnesisVisitReasonOption.sensitivity:
        return 'Sensibilidade';
      case AnamnesisVisitReasonOption.maintenance:
        return 'Manutencao';
      case AnamnesisVisitReasonOption.other:
        return 'Outro';
    }
  }
}

enum AnamnesisSmokingStatus { never, exSmoker, yes }

extension AnamnesisSmokingStatusParse on AnamnesisSmokingStatus {
  static AnamnesisSmokingStatus? fromCanonical(String value) {
    switch (value) {
      case 'nunca':
        return AnamnesisSmokingStatus.never;
      case 'ex_fumante':
        return AnamnesisSmokingStatus.exSmoker;
      case 'sim':
        return AnamnesisSmokingStatus.yes;
      default:
        return null;
    }
  }
}

extension AnamnesisSmokingStatusExt on AnamnesisSmokingStatus {
  String get canonical {
    switch (this) {
      case AnamnesisSmokingStatus.never:
        return 'nunca';
      case AnamnesisSmokingStatus.exSmoker:
        return 'ex_fumante';
      case AnamnesisSmokingStatus.yes:
        return 'sim';
    }
  }

  String get label {
    switch (this) {
      case AnamnesisSmokingStatus.never:
        return 'Nunca fumou';
      case AnamnesisSmokingStatus.exSmoker:
        return 'Ex-fumante';
      case AnamnesisSmokingStatus.yes:
        return 'Sim';
    }
  }
}

enum AnamnesisPressureStatus { no, compensated, decompensated }

extension AnamnesisPressureStatusParse on AnamnesisPressureStatus {
  static AnamnesisPressureStatus? fromCanonical(String value) {
    switch (value) {
      case 'nao':
        return AnamnesisPressureStatus.no;
      case 'compensada':
        return AnamnesisPressureStatus.compensated;
      case 'descompensada':
        return AnamnesisPressureStatus.decompensated;
      default:
        return null;
    }
  }
}

extension AnamnesisPressureStatusExt on AnamnesisPressureStatus {
  String get canonical {
    switch (this) {
      case AnamnesisPressureStatus.no:
        return 'nao';
      case AnamnesisPressureStatus.compensated:
        return 'compensada';
      case AnamnesisPressureStatus.decompensated:
        return 'descompensada';
    }
  }

  String get label {
    switch (this) {
      case AnamnesisPressureStatus.no:
        return 'Nao';
      case AnamnesisPressureStatus.compensated:
        return 'Compensada';
      case AnamnesisPressureStatus.decompensated:
        return 'Descompensada';
    }
  }
}

enum AnamnesisFrequency { never, rare, weekly, daily, other }

extension AnamnesisFrequencyParse on AnamnesisFrequency {
  static AnamnesisFrequency? fromCanonical(String value) {
    switch (value) {
      case 'nunca':
        return AnamnesisFrequency.never;
      case 'raro':
        return AnamnesisFrequency.rare;
      case 'semanal':
        return AnamnesisFrequency.weekly;
      case 'diario':
        return AnamnesisFrequency.daily;
      case 'outro':
        return AnamnesisFrequency.other;
      default:
        return null;
    }
  }
}

extension AnamnesisFrequencyExt on AnamnesisFrequency {
  String get canonical {
    switch (this) {
      case AnamnesisFrequency.never:
        return 'nunca';
      case AnamnesisFrequency.rare:
        return 'raro';
      case AnamnesisFrequency.weekly:
        return 'semanal';
      case AnamnesisFrequency.daily:
        return 'diario';
      case AnamnesisFrequency.other:
        return 'outro';
    }
  }

  String get label {
    switch (this) {
      case AnamnesisFrequency.never:
        return 'Nunca';
      case AnamnesisFrequency.rare:
        return 'Raro';
      case AnamnesisFrequency.weekly:
        return 'Semanal';
      case AnamnesisFrequency.daily:
        return 'Diario';
      case AnamnesisFrequency.other:
        return 'Outro';
    }
  }
}

enum AnamnesisSkinPhototype { i, ii, iii, iv, v, vi }

extension AnamnesisSkinPhototypeParse on AnamnesisSkinPhototype {
  static AnamnesisSkinPhototype? fromCanonical(String value) {
    switch (value) {
      case 'I':
        return AnamnesisSkinPhototype.i;
      case 'II':
        return AnamnesisSkinPhototype.ii;
      case 'III':
        return AnamnesisSkinPhototype.iii;
      case 'IV':
        return AnamnesisSkinPhototype.iv;
      case 'V':
        return AnamnesisSkinPhototype.v;
      case 'VI':
        return AnamnesisSkinPhototype.vi;
      default:
        return null;
    }
  }
}

extension AnamnesisSkinPhototypeExt on AnamnesisSkinPhototype {
  String get canonical {
    switch (this) {
      case AnamnesisSkinPhototype.i:
        return 'I';
      case AnamnesisSkinPhototype.ii:
        return 'II';
      case AnamnesisSkinPhototype.iii:
        return 'III';
      case AnamnesisSkinPhototype.iv:
        return 'IV';
      case AnamnesisSkinPhototype.v:
        return 'V';
      case AnamnesisSkinPhototype.vi:
        return 'VI';
    }
  }
}

class AnamnesisEnumHumanizer {
  const AnamnesisEnumHumanizer._();

  static String humanize(String fieldKey, String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return rawValue;

    switch (fieldKey) {
      case AnamnesisKeys.visitReasonOption:
        return _visitReasonLabel(value);
      case AnamnesisKeys.smokingStatus:
        return _smokingLabel(value);
      case AnamnesisKeys.hypertensionStatus:
      case AnamnesisKeys.hypotensionStatus:
        return _pressureLabel(value);
      case AnamnesisKeys.alcoholFrequency:
      case AnamnesisKeys.sunscreenFrequency:
      case AnamnesisKeys.sunExposureFrequency:
        return _frequencyLabel(value);
      default:
        return rawValue;
    }
  }

  static String _visitReasonLabel(String value) {
    switch (value) {
      case 'avaliacao_inicial':
        return AnamnesisVisitReasonOption.initialEvaluation.label;
      case 'acne':
        return AnamnesisVisitReasonOption.acne.label;
      case 'melasma':
        return AnamnesisVisitReasonOption.melasma.label;
      case 'manchas':
        return AnamnesisVisitReasonOption.spots.label;
      case 'rugas':
        return AnamnesisVisitReasonOption.wrinkles.label;
      case 'oleosidade':
        return AnamnesisVisitReasonOption.oiliness.label;
      case 'sensibilidade':
        return AnamnesisVisitReasonOption.sensitivity.label;
      case 'manutencao':
        return AnamnesisVisitReasonOption.maintenance.label;
      case 'outro':
        return AnamnesisVisitReasonOption.other.label;
      default:
        return value;
    }
  }

  static String _smokingLabel(String value) {
    switch (value) {
      case 'nunca':
        return AnamnesisSmokingStatus.never.label;
      case 'ex_fumante':
        return AnamnesisSmokingStatus.exSmoker.label;
      case 'sim':
        return AnamnesisSmokingStatus.yes.label;
      default:
        return value;
    }
  }

  static String _pressureLabel(String value) {
    switch (value) {
      case 'nao':
        return AnamnesisPressureStatus.no.label;
      case 'compensada':
        return AnamnesisPressureStatus.compensated.label;
      case 'descompensada':
        return AnamnesisPressureStatus.decompensated.label;
      default:
        return value;
    }
  }

  static String _frequencyLabel(String value) {
    switch (value) {
      case 'nunca':
        return AnamnesisFrequency.never.label;
      case 'raro':
        return AnamnesisFrequency.rare.label;
      case 'semanal':
        return AnamnesisFrequency.weekly.label;
      case 'diario':
        return AnamnesisFrequency.daily.label;
      case 'outro':
        return AnamnesisFrequency.other.label;
      default:
        return value;
    }
  }
}
