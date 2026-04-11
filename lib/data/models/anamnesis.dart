import '../../core/constants/anamnesis_enums.dart';
import '../../core/constants/anamnesis_keys.dart';

class Anamnesis {
  int? id;
  int clientId;
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> answers;

  Anamnesis({
    this.id,
    required this.clientId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? answers,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now(),
       answers = answers ?? {};

  AnamnesisVisitReasonOption? get visitReasonOption {
    final raw = answers[AnamnesisKeys.visitReasonOption]?.toString();
    if (raw == null) return null;
    return AnamnesisVisitReasonOptionParse.fromCanonical(raw);
  }

  set visitReasonOption(AnamnesisVisitReasonOption? value) {
    _setCanonicalEnumAnswer(AnamnesisKeys.visitReasonOption, value?.canonical);
  }

  AnamnesisSmokingStatus? get smokingStatus {
    final raw = answers[AnamnesisKeys.smokingStatus]?.toString();
    if (raw == null) return null;
    return AnamnesisSmokingStatusParse.fromCanonical(raw);
  }

  set smokingStatus(AnamnesisSmokingStatus? value) {
    _setCanonicalEnumAnswer(AnamnesisKeys.smokingStatus, value?.canonical);
  }

  AnamnesisPressureStatus? get hypertensionStatus {
    final raw = answers[AnamnesisKeys.hypertensionStatus]?.toString();
    if (raw == null) return null;
    return AnamnesisPressureStatusParse.fromCanonical(raw);
  }

  set hypertensionStatus(AnamnesisPressureStatus? value) {
    _setCanonicalEnumAnswer(AnamnesisKeys.hypertensionStatus, value?.canonical);
  }

  AnamnesisPressureStatus? get hypotensionStatus {
    final raw = answers[AnamnesisKeys.hypotensionStatus]?.toString();
    if (raw == null) return null;
    return AnamnesisPressureStatusParse.fromCanonical(raw);
  }

  set hypotensionStatus(AnamnesisPressureStatus? value) {
    _setCanonicalEnumAnswer(AnamnesisKeys.hypotensionStatus, value?.canonical);
  }

  AnamnesisFrequency? get alcoholFrequency {
    final raw = answers[AnamnesisKeys.alcoholFrequency]?.toString();
    if (raw == null) return null;
    return AnamnesisFrequencyParse.fromCanonical(raw);
  }

  set alcoholFrequency(AnamnesisFrequency? value) {
    _setCanonicalEnumAnswer(AnamnesisKeys.alcoholFrequency, value?.canonical);
  }

  AnamnesisFrequency? get sunscreenFrequency {
    final raw = answers[AnamnesisKeys.sunscreenFrequency]?.toString();
    if (raw == null) return null;
    return AnamnesisFrequencyParse.fromCanonical(raw);
  }

  set sunscreenFrequency(AnamnesisFrequency? value) {
    _setCanonicalEnumAnswer(AnamnesisKeys.sunscreenFrequency, value?.canonical);
  }

  AnamnesisFrequency? get sunExposureFrequency {
    final raw = answers[AnamnesisKeys.sunExposureFrequency]?.toString();
    if (raw == null) return null;
    return AnamnesisFrequencyParse.fromCanonical(raw);
  }

  set sunExposureFrequency(AnamnesisFrequency? value) {
    _setCanonicalEnumAnswer(
      AnamnesisKeys.sunExposureFrequency,
      value?.canonical,
    );
  }

  AnamnesisSkinPhototype? get skinPhototype {
    final raw = answers[AnamnesisKeys.skinPhototype]?.toString();
    if (raw == null) return null;
    return AnamnesisSkinPhototypeParse.fromCanonical(raw);
  }

  set skinPhototype(AnamnesisSkinPhototype? value) {
    _setCanonicalEnumAnswer(AnamnesisKeys.skinPhototype, value?.canonical);
  }

  void _setCanonicalEnumAnswer(String key, String? canonicalValue) {
    if (canonicalValue == null) {
      answers.remove(key);
      return;
    }
    answers[key] = canonicalValue;
  }
}

class StoredAnamnesisAnswer {
  final String? textValue;
  final int? intValue;
  final double? realValue;
  final int? boolValue;
  final String? dateValue;
  final String? enumValue;
  final String? jsonValue;
  final String type;

  const StoredAnamnesisAnswer({
    required this.type,
    this.textValue,
    this.intValue,
    this.realValue,
    this.boolValue,
    this.dateValue,
    this.enumValue,
    this.jsonValue,
  });

  Map<String, Object?> toDbMap() {
    return {
      'value_type': type,
      'value_text': textValue,
      'value_int': intValue,
      'value_real': realValue,
      'value_bool': boolValue,
      'value_date': dateValue,
      'value_enum': enumValue,
      'value_json': jsonValue,
    };
  }
}
