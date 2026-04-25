import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/constants/anamnesis_enums.dart';
import 'package:flutter_application_1/core/constants/anamnesis_field_specs.dart';
import 'package:flutter_application_1/core/constants/anamnesis_keys.dart';

void main() {
  group('Anamnesis enum contracts', () {
    test('canonical enum values match field specs lists', () {
      final smokingCanonicals = AnamnesisSmokingStatus.values
          .map((e) => e.canonical)
          .toList();
      final pressureCanonicals = AnamnesisPressureStatus.values
          .map((e) => e.canonical)
          .toList();
      final frequencyCanonicals = AnamnesisFrequency.values
          .map((e) => e.canonical)
          .toList();
      final phototypeCanonicals = AnamnesisSkinPhototype.values
          .map((e) => e.canonical)
          .toList();

      expect(smokingCanonicals, AnamnesisFieldSpecs.smokingStatusEnumValues);
      expect(pressureCanonicals, AnamnesisFieldSpecs.yesNoEnumValues);
      expect(frequencyCanonicals, AnamnesisFieldSpecs.frequencyEnumValues);
      expect(phototypeCanonicals, AnamnesisFieldSpecs.skinPhototypeEnumValues);
    });

    test('humanizer returns translated labels for enum fields', () {
      expect(
        AnamnesisEnumHumanizer.humanize(
          AnamnesisKeys.smokingStatus,
          'ex_fumante',
        ),
        'Ex-fumante',
      );
      expect(
        AnamnesisEnumHumanizer.humanize(
          AnamnesisKeys.hypertensionStatus,
          'descompensada',
        ),
        'Descompensada',
      );
      expect(
        AnamnesisEnumHumanizer.humanize(
          AnamnesisKeys.alcoholFrequency,
          'semanal',
        ),
        'Semanal',
      );
    });

    test('fromCanonical parsers accept only strict canonical values', () {
      expect(
        AnamnesisSmokingStatusParse.fromCanonical('ex_fumante'),
        AnamnesisSmokingStatus.exSmoker,
      );
      expect(AnamnesisSmokingStatusParse.fromCanonical('EX_FUMANTE'), isNull);
      expect(
        AnamnesisFrequencyParse.fromCanonical('semanal'),
        AnamnesisFrequency.weekly,
      );
      expect(AnamnesisFrequencyParse.fromCanonical('Semanal'), isNull);
      expect(
        AnamnesisSkinPhototypeParse.fromCanonical('III'),
        AnamnesisSkinPhototype.iii,
      );
      expect(AnamnesisSkinPhototypeParse.fromCanonical('iii'), isNull);
    });
  });
}
