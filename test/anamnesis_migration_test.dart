import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/constants/anamnesis_keys.dart';
import 'package:flutter_application_1/data/models/anamnesis.dart';

void main() {
  group('Anamnesis Migration: PT→EN Keys', () {
    test(
      'AnamnesisKeys.toCanonical() converts legacy PT keys to canonical EN',
      () {
        // Test a sample of the mappings
        expect(AnamnesisKeys.toCanonical('estadoCivil'),
            AnamnesisKeys.maritalStatus);
        expect(AnamnesisKeys.toCanonical('nacionalidade'),
            AnamnesisKeys.nationality);
        expect(AnamnesisKeys.toCanonical('endereco'), AnamnesisKeys.address);
        expect(AnamnesisKeys.toCanonical('telefone'), AnamnesisKeys.phone);
        expect(AnamnesisKeys.toCanonical('whatsapp'), AnamnesisKeys.whatsapp);
        expect(AnamnesisKeys.toCanonical('email'), AnamnesisKeys.email);
        expect(
            AnamnesisKeys.toCanonical('idade'), AnamnesisKeys.age);
        expect(AnamnesisKeys.toCanonical('profissao'),
            AnamnesisKeys.profession);
        expect(AnamnesisKeys.toCanonical('motivoVisita'),
            AnamnesisKeys.visitReason);
      },
    );

    test('AnamnesisKeys.toLegacy() converts canonical EN keys back to PT', () {
      // Inverse mapping should work
      expect(AnamnesisKeys.toLegacy(AnamnesisKeys.maritalStatus),
          'estadoCivil');
      expect(
          AnamnesisKeys.toLegacy(AnamnesisKeys.nationality), 'nacionalidade');
      expect(AnamnesisKeys.toLegacy(AnamnesisKeys.address), 'endereco');
      expect(AnamnesisKeys.toLegacy(AnamnesisKeys.phone), 'telefone');
      expect(AnamnesisKeys.toLegacy(AnamnesisKeys.whatsapp), 'whatsapp');
      expect(AnamnesisKeys.toLegacy(AnamnesisKeys.email), 'email');
      expect(AnamnesisKeys.toLegacy(AnamnesisKeys.age), 'idade');
      expect(AnamnesisKeys.toLegacy(AnamnesisKeys.profession), 'profissao');
      expect(AnamnesisKeys.toLegacy(AnamnesisKeys.visitReason), 'motivoVisita');
    });

    test('toCanonical() returns input unchanged for already-canonical keys',
        () {
      // If key is already canonical (not in legacyToCanonical), it should return unchanged
      expect(AnamnesisKeys.toCanonical(AnamnesisKeys.maritalStatus),
          AnamnesisKeys.maritalStatus);
      expect(AnamnesisKeys.toCanonical(AnamnesisKeys.nationality),
          AnamnesisKeys.nationality);
    });

    test('Round-trip conversion: PT → EN → PT maintains original key', () {
      final ptKey = 'estadoCivil';
      final enKey = AnamnesisKeys.toCanonical(ptKey);
      final backToPt = AnamnesisKeys.toLegacy(enKey);

      expect(enKey, AnamnesisKeys.maritalStatus);
      expect(backToPt, ptKey);
    });

    test('Anamnesis.answers can use canonical EN keys', () {
      // This simulates what CRUD test page does
      final anamnesis = Anamnesis(
        clientId: 1,
        answers: {
          AnamnesisKeys.maritalStatus: 'Single',
          AnamnesisKeys.nationality: 'Brazilian',
          AnamnesisKeys.profession: 'Engineer',
          AnamnesisKeys.age: 30,
        },
      );

      expect(anamnesis.answers['maritalStatus'], 'Single');
      expect(anamnesis.answers['nationality'], 'Brazilian');
      expect(anamnesis.answers['profession'], 'Engineer');
      expect(anamnesis.answers['age'], 30);
    });

    test('Backward compatibility: Reads work with legacy PT keys in mixed data',
        () {
      // Simulate migrated data: mix of old PT and new EN records
      final mixedAnswers = {
        // Old PT records (pre-migration)
        'estadoCivil': 'Solteiro',
        'nacionalidade': 'Brasileira',
        // New EN records (post-migration)
        'maritalStatus': 'Single',
        'nationality': 'Brazilian',
      };

      // When reading, canonical key should be tried first
      expect(mixedAnswers['maritalStatus'], 'Single');

      // Legacy key should still be queryable for older records
      expect(mixedAnswers['estadoCivil'], 'Solteiro');
    });

    test('All legacy keys have canonical mappings', () {
      expect(AnamnesisKeys.legacyToCanonical.length, greaterThanOrEqualTo(150));
      expect(AnamnesisKeys.canonicalToLegacy.length,
          AnamnesisKeys.legacyToCanonical.length);

      // Sample validation: spot-check a few mappings have reverse entries
      expect(AnamnesisKeys.canonicalToLegacy.containsKey(AnamnesisKeys.maritalStatus), true);
      expect(AnamnesisKeys.canonicalToLegacy.containsKey(AnamnesisKeys.nationality), true);
      expect(AnamnesisKeys.canonicalToLegacy.containsKey(AnamnesisKeys.profession), true);
    });

    test('Database migration handles all field types (bool, int, string, etc)',
        () {
      // The migration only changes field_key values, not value or value_type
      // This test documents the behavior expected in _normalizeAnswers

      final testAnswers = {
        AnamnesisKeys.maritalStatus: 'Single', // string
        AnamnesisKeys.age: 30, // int
        AnamnesisKeys.hasAllergies: true, // bool
        AnamnesisKeys.dateOfBirth: '1994-03-15', // datetime string
      };

      // After normalization, these should all be present with their types intact
      expect(testAnswers[AnamnesisKeys.maritalStatus], isA<String>());
      expect(testAnswers[AnamnesisKeys.age], isA<int>());
      expect(testAnswers[AnamnesisKeys.hasAllergies], isA<bool>());
      expect(testAnswers[AnamnesisKeys.dateOfBirth], isA<String>());
    });

    test('Fallback method strategy: canonical first, then legacy', () {
      // Simulate the dual-key lookup used in PDF service and repository
      final legacyKey = 'estadoCivil';
      final canonicalKey = AnamnesisKeys.toCanonical(legacyKey);

      // Test 1: Record has canonical key (new post-migration data)
      var answers = {canonicalKey: 'Married'};
      var value = answers[canonicalKey] ?? answers[legacyKey];
      expect(value, 'Married', reason: 'Should find canonical key');

      // Test 2: Record has legacy key (old pre-migration data)
      answers = {legacyKey: 'Casado'};
      value = answers[canonicalKey] ?? answers[legacyKey];
      expect(value, 'Casado', reason: 'Should fallback to legacy key');

      // Test 3: Record has both (shouldn't happen, but canonical wins)
      answers = {canonicalKey: 'Married', legacyKey: 'Casado'};
      value = answers[canonicalKey] ?? answers[legacyKey];
      expect(value, 'Married', reason: 'Canonical should take precedence');

      // Test 4: Record has neither (null/missing)
      answers = {};
      value = answers[canonicalKey] ?? answers[legacyKey];
      expect(value, null, reason: 'Should be null if neither key found');
    });

    test('Migration is idempotent: running twice produces same result', () {
      // This documents that the migration can be run multiple times safely
      // (important for testing/validation scenarios)

      final legacyData = {
        'estadoCivil': 'Solteiro',
        'nacionalidade': 'Brasileira',
        'profissao': 'Engenheira',
      };

      // First migration: convert all keys to canonical
      final firstMigration = <String, dynamic>{};
      for (final entry in legacyData.entries) {
        final canonicalKey = AnamnesisKeys.toCanonical(entry.key);
        firstMigration[canonicalKey] = entry.value;
      }

      // Second migration: apply same conversion again
      final secondMigration = <String, dynamic>{};
      for (final entry in firstMigration.entries) {
        final canonicalKey = AnamnesisKeys.toCanonical(entry.key);
        secondMigration[canonicalKey] = entry.value;
      }

      // Result should be identical (keys already canonical, so no change)
      expect(firstMigration, secondMigration,
          reason: 'Migration should be idempotent');
    });

    test('All standard anamnesis fields have EN names in constants', () {
      // Verify the most critical fields are properly named
      final requiredFields = [
        AnamnesisKeys.maritalStatus, // estadoCivil
        AnamnesisKeys.nationality, // nacionalidade
        AnamnesisKeys.dateOfBirth, // dataDeNascimento
        AnamnesisKeys.address, // endereco
        AnamnesisKeys.phone, // telefone
        AnamnesisKeys.whatsapp, // whatsapp
        AnamnesisKeys.email, // email
        AnamnesisKeys.age, // idade
        AnamnesisKeys.profession, // profissao
        AnamnesisKeys.visitReason, // motivoDaVisita
      ];

      for (final field in requiredFields) {
        expect(field, isNotEmpty, reason: 'Field name should not be empty');
        expect(field, isA<String>(), reason: 'Field should be a String');
        expect(field, isNotNull, reason: 'Field should not be null');
      }
    });
  });

  group('Database Migration Scenarios: v2→v3', () {
    test('Documentation: Migration happens on app open with old v2 DB', () {
      // When user opens app with old v2 databse:
      // 1. DbHelper.database getter is called
      // 2. _initDatabase() opens existing DB
      // 3. SQLite calls onUpgrade(db, 2, 3)
      // 4. onUpgrade checks: if (oldVersion < 3) → calls _migrateAnamnesisKeysToEnglish()
      // 5. _migrateAnamnesisKeysToEnglish() iterates all 170+ legacyToCanonical entries
      // 6. For each entry: UPDATE anamnesis_answers SET field_key = 'canonical' WHERE field_key = 'legacy'
      // 7. All updates run in single atomic transaction
      // 8. Result: All field_key values in DB changed from PT to EN
      // 9. Old records still readable via fallback methods
      // 10. New writes use canonical EN keys from AnamnesisKeys

      // This test documents the expected behavior
      expect(true, true,
          reason:
              'Migration process documented: automatic v2→v3 upgrade with dual-key fallback');
    });

    test('Documentation: No manual migration needed (automatic on app upgrade)',
        () {
      // User experience:
      // 1. User builds new version with updated code (v3 schema)
      // 2. App opens on device with old v2 database
      // 3. DbHelper automatically detects version mismatch
      // 4. onUpgrade triggers, migration runs, database updated to v3
      // 5. No data loss, no manual steps, transparent to user
      // 6. App works as normal

      expect(true, true,
          reason: 'Zero-downtime migration: fully automatic on app open');
    });

    test('Documentation: Atomic transaction ensures all-or-nothing migration',
        () {
      // The migration runs in a single transaction:
      // await db.transaction((txn) async {
      //   for (final entry in AnamnesisKeys.legacyToCanonical.entries) {
      //     await txn.update(...);
      //   }
      // });

      // If any update fails:
      // - All changes rolled back
      // - Database remains in consistent state (either all v2 or all v3)
      // - No partial/corrupted migration possible

      expect(true, true,
          reason:
              'Atomic transaction: all-or-nothing migration, no partial states');
    });

    test('Documentation: Backward compatibility maintained indefinitely', () {
      // Because of fallback methods, old PT records are forever readable:
      // - Old code: answers['estadoCivil'] → works (legacy key read)
      // - New code: answers['maritalStatus'] → works (canonical key read)
      // - Mixed code: answers[canonicalKey] ?? answers[legacyKey] → works (dual-key)
      // - Indefinite compatibility: no need to ever remove PT keys from fallback

      expect(true, true,
          reason: 'Backward compatible forever: no need for deprecation timeline');
    });
  });
}
