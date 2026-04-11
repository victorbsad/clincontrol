import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/constants/anamnesis_keys.dart';
import 'package:flutter_application_1/data/models/anamnesis.dart';

void main() {
  group('Anamnesis Keys - Canonical Only', () {
    test('core canonical keys are stable non-empty strings', () {
      final requiredFields = [
        AnamnesisKeys.maritalStatus,
        AnamnesisKeys.nationality,
        AnamnesisKeys.dateOfBirth,
        AnamnesisKeys.address,
        AnamnesisKeys.phone,
        AnamnesisKeys.whatsapp,
        AnamnesisKeys.email,
        AnamnesisKeys.age,
        AnamnesisKeys.profession,
        AnamnesisKeys.visitReason,
      ];

      for (final field in requiredFields) {
        expect(field, isA<String>());
        expect(field, isNotEmpty);
      }
    });

    test('anamnesis answers use canonical keys directly', () {
      final anamnesis = Anamnesis(
        clientId: 1,
        answers: {
          AnamnesisKeys.maritalStatus: 'Single',
          AnamnesisKeys.nationality: 'Brazilian',
          AnamnesisKeys.profession: 'Engineer',
          AnamnesisKeys.age: 30,
          AnamnesisKeys.hasAllergies: true,
        },
      );

      expect(anamnesis.answers[AnamnesisKeys.maritalStatus], 'Single');
      expect(anamnesis.answers[AnamnesisKeys.nationality], 'Brazilian');
      expect(anamnesis.answers[AnamnesisKeys.profession], 'Engineer');
      expect(anamnesis.answers[AnamnesisKeys.age], 30);
      expect(anamnesis.answers[AnamnesisKeys.hasAllergies], true);
    });

    test('mixed answer value types remain supported', () {
      final answers = {
        AnamnesisKeys.maritalStatus: 'Single',
        AnamnesisKeys.age: 30,
        AnamnesisKeys.hasAllergies: false,
        AnamnesisKeys.dateOfBirth: '1994-03-15',
      };

      expect(answers[AnamnesisKeys.maritalStatus], isA<String>());
      expect(answers[AnamnesisKeys.age], isA<int>());
      expect(answers[AnamnesisKeys.hasAllergies], isA<bool>());
      expect(answers[AnamnesisKeys.dateOfBirth], isA<String>());
    });
  });
}
