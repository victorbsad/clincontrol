import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/anamnesis_keys.dart';

class AnamnesisPdfSkinSection {
  const AnamnesisPdfSkinSection._();

  static List<pw.Widget> build({
    required Map<String, dynamic> answers,
    required pw.Widget Function(String title, List<pw.Widget> lines)
        buildSubSection,
    required pw.Widget Function(
      String leftLabel,
      String leftValue,
      String rightLabel,
      String rightValue,
    ) pairLine,
    required pw.Widget Function(String label, String value) line,
    required pw.Widget Function(String title) subTitle,
    required pw.Widget Function(List<String> labels, List<dynamic> values)
        wrapBullets,
    required pw.Widget Function(List<String> columns) tableHeader,
    required pw.Widget Function(String session, String date, String treatment)
        tableRow,
    required String Function(Map<String, dynamic> answers, String key) value,
    required dynamic Function(Map<String, dynamic> answers, String key) getAnswer,
    required String Function(Map<String, dynamic> answers, String key)
        checkboxSymbolForKey,
  }) {
    return [
      buildSubSection('BIOTIPO CUTANEO', [
        buildSubSection('Pele Oleosa (Lipidica)', [
          pairLine(
            'Sensivel',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinSensitive),
            'Resistente',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinResistant),
          ),
          pairLine(
            'Pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinPigmented),
            'Nao pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinNonPigmented),
          ),
          pairLine(
            'Firme',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinFirm),
            'Propensa a rugas',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinWrinkled),
          ),
        ]),
        pw.SizedBox(height: 8),
        buildSubSection('Pele Seca (Alipica)', [
          pairLine(
            'Sensivel',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinSensitive),
            'Resistente',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinResistant),
          ),
          pairLine(
            'Pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinPigmented),
            'Nao pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinNonPigmented),
          ),
          pairLine(
            'Firme',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinFirm),
            'Propensa a rugas',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinWrinkled),
          ),
        ]),
        pw.SizedBox(height: 8),
        buildSubSection('Pele Mista', [
          pairLine(
            'Sensivel',
            checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinSensitive),
            'Resistente',
            checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinResistant),
          ),
          pairLine(
            'Pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinPigmented),
            'Nao pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinNonPigmented),
          ),
          pairLine(
            'Firme',
            checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinFirm),
            'Propensa a rugas',
            checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinWrinkled),
          ),
        ]),
      ]),
      pw.SizedBox(height: 12),
      buildSubSection('ANALISE DETALHADA DA PELE', [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: buildSubSection('Pele com acne', [
                wrapBullets(
                  [
                    'Comedao',
                    'Pustula',
                    'Papula',
                    'Nodulo',
                    'Hiperqueratinizacao',
                    'Milium',
                    'Microcisto',
                    'Acne Inflamatoria',
                    'Acne Nao Inflamatoria',
                  ],
                  [
                    getAnswer(answers, AnamnesisKeys.hasComedo),
                    getAnswer(answers, AnamnesisKeys.hasPustule),
                    getAnswer(answers, AnamnesisKeys.hasPapule),
                    getAnswer(answers, AnamnesisKeys.hasNodule),
                    getAnswer(answers, AnamnesisKeys.hasHyperkeratinization),
                    getAnswer(answers, AnamnesisKeys.hasMilium),
                    getAnswer(answers, AnamnesisKeys.hasMicrocyst),
                    getAnswer(answers, AnamnesisKeys.hasInflammatoryAcne),
                    getAnswer(answers, AnamnesisKeys.hasNonInflammatoryAcne),
                  ],
                ),
              ]),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: buildSubSection('Lesoes dermatologicas', [
                wrapBullets(
                  [
                    'Telangiectasia/ Nevo',
                    'Queratose Actinica',
                    'Nevo Melanocitico',
                    'Dermatose Papulosa Nigra',
                    'Papiloma',
                    'Acrocordon',
                  ],
                  [
                    getAnswer(answers, AnamnesisKeys.hasTelangiectasiaNevus),
                    getAnswer(answers, AnamnesisKeys.hasActinicKeratosis),
                    getAnswer(answers, AnamnesisKeys.hasMelanocyticNevus),
                    getAnswer(answers, AnamnesisKeys.hasDermatosisPapulosa),
                    getAnswer(answers, AnamnesisKeys.hasPapilloma),
                    getAnswer(answers, AnamnesisKeys.hasAcrochordion),
                  ],
                ),
                line('Outras', value(answers, AnamnesisKeys.hasOtherLesions)),
              ]),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: buildSubSection('Dicromias', [
                wrapBullets(
                  [
                    'Hiperpigmentacao inflamatoria',
                    'Fotoenvelhecimento',
                    'Melasma',
                    'Efelides',
                    'Hiperpigmentacao orbicular',
                    'Hipocromia',
                  ],
                  [
                    getAnswer(
                      answers,
                      AnamnesisKeys.hasInflammatoryHyperpigmentation,
                    ),
                    getAnswer(answers, AnamnesisKeys.hasPhotoaging),
                    getAnswer(answers, AnamnesisKeys.hasMelasma),
                    getAnswer(answers, AnamnesisKeys.hasFreckles),
                    getAnswer(
                      answers,
                      AnamnesisKeys.hasOrbicularHyperpigmentation,
                    ),
                    getAnswer(answers, AnamnesisKeys.hasHypochromia),
                  ],
                ),
                line(
                  'Por que? Quanto tempo?',
                  value(answers, AnamnesisKeys.chromaticAbnormalityJustification),
                ),
              ]),
            ),
          ],
        ),
      ]),
      pw.SizedBox(height: 12),
      buildSubSection('FOTOTIPO', [
        line(
          'FOTOTIPO - REATIVIDADE A LUZ ULTRAVIOLETA (Escala Fitzpatrick)',
          value(answers, AnamnesisKeys.skinPhototype),
        ),
      ]),
      pw.SizedBox(height: 12),
      buildSubSection('OUTROS', [
        pairLine(
          'DERMATITE',
          checkboxSymbolForKey(answers, AnamnesisKeys.hasDermatitis),
          'PSORIASE',
          checkboxSymbolForKey(answers, AnamnesisKeys.hasPsoriasis),
        ),
        pw.SizedBox(height: 6),
        line(
          'TRATAMENTO INDICADO',
          value(answers, AnamnesisKeys.treatmentIndicated),
        ),
        pw.SizedBox(height: 6),
        line('NUMERO DE SESSOES', value(answers, AnamnesisKeys.numberOfSessions)),
        pw.SizedBox(height: 6),
        subTitle('CONTROLE PROCEDIMENTOS'),
        tableHeader(['Sessao', 'Data', 'Tratamento']),
        tableRow(
          '1a',
          value(answers, AnamnesisKeys.session1Date),
          value(answers, AnamnesisKeys.session1),
        ),
        tableRow(
          '2a',
          value(answers, AnamnesisKeys.session2Date),
          value(answers, AnamnesisKeys.session2),
        ),
        tableRow(
          '3a',
          value(answers, AnamnesisKeys.session3Date),
          value(answers, AnamnesisKeys.session3),
        ),
        tableRow(
          '4a',
          value(answers, AnamnesisKeys.session4Date),
          value(answers, AnamnesisKeys.session4),
        ),
        tableRow(
          '5a',
          value(answers, AnamnesisKeys.session5Date),
          value(answers, AnamnesisKeys.session5),
        ),
        tableRow(
          '6a',
          value(answers, AnamnesisKeys.session6Date),
          value(answers, AnamnesisKeys.session6),
        ),
        tableRow(
          '7a',
          value(answers, AnamnesisKeys.session7Date),
          value(answers, AnamnesisKeys.session7),
        ),
        tableRow(
          '8a',
          value(answers, AnamnesisKeys.session8Date),
          value(answers, AnamnesisKeys.session8),
        ),
        tableRow(
          '9a',
          value(answers, AnamnesisKeys.session9Date),
          value(answers, AnamnesisKeys.session9),
        ),
        tableRow(
          '10a',
          value(answers, AnamnesisKeys.session10Date),
          value(answers, AnamnesisKeys.session10),
        ),
      ]),
      pw.SizedBox(height: 14),
      buildSubSection('PRESCRICAO COSMETICA (home care)', [
        line('', value(answers, AnamnesisKeys.cosmeticPrescription)),
      ]),
    ];
  }
}
