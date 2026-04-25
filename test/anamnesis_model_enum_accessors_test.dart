import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/constants/anamnesis_enums.dart';
import 'package:flutter_application_1/core/constants/anamnesis_keys.dart';
import 'package:flutter_application_1/data/models/anamnesis.dart';

void main() {
  group('Anamnesis model enum accessors', () {
    test('setters persist canonical values in answers map', () {
      final anamnesis = Anamnesis(clientId: 1);

      anamnesis.smokingStatus = AnamnesisSmokingStatus.exSmoker;
      anamnesis.hypertensionStatus = AnamnesisPressureStatus.compensated;
      anamnesis.hypotensionStatus = AnamnesisPressureStatus.no;
      anamnesis.alcoholFrequency = AnamnesisFrequency.weekly;
      anamnesis.sunscreenFrequency = AnamnesisFrequency.daily;
      anamnesis.sunExposureFrequency = AnamnesisFrequency.rare;
      anamnesis.skinPhototype = AnamnesisSkinPhototype.iii;

      expect(anamnesis.answers[AnamnesisKeys.smokingStatus], 'ex_fumante');
      expect(anamnesis.answers[AnamnesisKeys.hypertensionStatus], 'compensada');
      expect(anamnesis.answers[AnamnesisKeys.hypotensionStatus], 'nao');
      expect(anamnesis.answers[AnamnesisKeys.alcoholFrequency], 'semanal');
      expect(anamnesis.answers[AnamnesisKeys.sunscreenFrequency], 'diario');
      expect(anamnesis.answers[AnamnesisKeys.sunExposureFrequency], 'raro');
      expect(anamnesis.answers[AnamnesisKeys.skinPhototype], 'III');
    });

    test('getters parse canonical values and reject non-canonical values', () {
      final anamnesis = Anamnesis(
        clientId: 1,
        answers: {
          AnamnesisKeys.smokingStatus: 'sim',
          AnamnesisKeys.hypertensionStatus: 'descompensada',
          AnamnesisKeys.hypotensionStatus: 'nao',
          AnamnesisKeys.alcoholFrequency: 'diario',
          AnamnesisKeys.sunscreenFrequency: 'semanal',
          AnamnesisKeys.sunExposureFrequency: 'nunca',
          AnamnesisKeys.skinPhototype: 'VI',
        },
      );

      expect(anamnesis.smokingStatus, AnamnesisSmokingStatus.yes);
      expect(
        anamnesis.hypertensionStatus,
        AnamnesisPressureStatus.decompensated,
      );
      expect(anamnesis.hypotensionStatus, AnamnesisPressureStatus.no);
      expect(anamnesis.alcoholFrequency, AnamnesisFrequency.daily);
      expect(anamnesis.sunscreenFrequency, AnamnesisFrequency.weekly);
      expect(anamnesis.sunExposureFrequency, AnamnesisFrequency.never);
      expect(anamnesis.skinPhototype, AnamnesisSkinPhototype.vi);

      anamnesis.answers[AnamnesisKeys.smokingStatus] = 'SIM';
      expect(anamnesis.smokingStatus, isNull);
    });

    test('null enum setter removes key from answers map', () {
      final anamnesis = Anamnesis(
        clientId: 1,
        answers: {AnamnesisKeys.skinPhototype: 'II'},
      );

      anamnesis.skinPhototype = null;

      expect(
        anamnesis.answers.containsKey(AnamnesisKeys.skinPhototype),
        isFalse,
      );
    });
  });
}
