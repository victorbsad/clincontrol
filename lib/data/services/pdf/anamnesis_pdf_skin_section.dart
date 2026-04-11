import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/anamnesis_keys.dart';
import 'anamnesis_pdf_styles.dart';

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
    )
    pairLine,
    required pw.Widget Function(String label, String value) line,
    required pw.Widget Function(String title) subTitle,
    required pw.Widget Function(List<String> labels, List<dynamic> values)
    wrapBullets,
    required pw.Widget Function(List<String> columns) tableHeader,
    required pw.Widget Function(String session, String date, String treatment)
    tableRow,
    required String Function(Map<String, dynamic> answers, String key) value,
    required dynamic Function(Map<String, dynamic> answers, String key)
    getAnswer,
    required String Function(Map<String, dynamic> answers, String key)
    checkboxSymbolForKey,
  }) {
    return [
      buildSubSection('BIOTIPO CUTÂNEO', [
        buildSubSection('Pele Oleosa (Lipídica)', [
          pairLine(
            'Sensível',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinSensitive),
            'Resistente',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinResistant),
          ),
          pairLine(
            'Pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinPigmented),
            'Não pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinNonPigmented),
          ),
          pairLine(
            'Firme',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinFirm),
            'Propensa à rugas',
            checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinWrinkled),
          ),
        ]),
        pw.SizedBox(height: 8),
        buildSubSection('Pele Seca (Alípica)', [
          pairLine(
            'Sensível',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinSensitive),
            'Resistente',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinResistant),
          ),
          pairLine(
            'Pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinPigmented),
            'Não pigmentada',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinNonPigmented),
          ),
          pairLine(
            'Firme',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinFirm),
            'Propensa à rugas',
            checkboxSymbolForKey(answers, AnamnesisKeys.drySkinWrinkled),
          ),
        ]),
        pw.SizedBox(height: 8),
        buildSubSection('Pele Mista', [
          pairLine(
            'Sensível',
            checkboxSymbolForKey(
              answers,
              AnamnesisKeys.combinationSkinSensitive,
            ),
            'Resistente',
            checkboxSymbolForKey(
              answers,
              AnamnesisKeys.combinationSkinResistant,
            ),
          ),
          pairLine(
            'Pigmentada',
            checkboxSymbolForKey(
              answers,
              AnamnesisKeys.combinationSkinPigmented,
            ),
            'Não pigmentada',
            checkboxSymbolForKey(
              answers,
              AnamnesisKeys.combinationSkinNonPigmented,
            ),
          ),
          pairLine(
            'Firme',
            checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinFirm),
            'Propensa à rugas',
            checkboxSymbolForKey(
              answers,
              AnamnesisKeys.combinationSkinWrinkled,
            ),
          ),
        ]),
      ]),
      pw.SizedBox(height: 12),
      buildSubSection('ANÁLISE DETALHADA DA PELE', [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: buildSubSection('Pele com acne', [
                wrapBullets(
                  [
                    'Comedão',
                    'Pústula',
                    'Pápula',
                    'Nódulo',
                    'Hiperqueratinização',
                    'Mílium',
                    'Microcisto',
                    'Acne Inflamatória',
                    'Acne Não Inflamatória',
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
              child: buildSubSection('Lesões dermatológicas', [
                wrapBullets(
                  [
                    'Telangiectasia/ Nevo',
                    'Queratose Actínica',
                    'Nevo Melanocítico',
                    'Dermatose Papulosa Nigra',
                    'Papiloma',
                    'Acrocórdon',
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
                    'Hiperpigmentação inflamatória',
                    'Fotoenvelhecimento',
                    'Melasma',
                    'Efelides',
                    'Hiperpigmentação orbicular',
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
                  'Por quê? Quanto tempo?',
                  value(
                    answers,
                    AnamnesisKeys.chromaticAbnormalityJustification,
                  ),
                ),
              ]),
            ),
          ],
        ),
      ]),
      pw.SizedBox(height: 12),
      buildSubSection(
        'FOTOTIPO – REATIVIDADE À LUZ ULTRAVIOLETA (Escala Fitzpatrick)',
        [_phototypeBlock(value(answers, AnamnesisKeys.skinPhototype))],
      ),
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
        line(
          'NUMERO DE SESSOES',
          value(answers, AnamnesisKeys.numberOfSessions),
        ),
        pw.SizedBox(height: 6),
        subTitle('CONTROLE PROCEDIMENTOS'),
        tableHeader(['Sessão', 'Data', 'Tratamento']),
        tableRow(
          '1ª',
          value(answers, AnamnesisKeys.session1Date),
          value(answers, AnamnesisKeys.session1),
        ),
        tableRow(
          '2ª',
          value(answers, AnamnesisKeys.session2Date),
          value(answers, AnamnesisKeys.session2),
        ),
        tableRow(
          '3ª',
          value(answers, AnamnesisKeys.session3Date),
          value(answers, AnamnesisKeys.session3),
        ),
        tableRow(
          '4ª',
          value(answers, AnamnesisKeys.session4Date),
          value(answers, AnamnesisKeys.session4),
        ),
        tableRow(
          '5ª',
          value(answers, AnamnesisKeys.session5Date),
          value(answers, AnamnesisKeys.session5),
        ),
        tableRow(
          '6ª',
          value(answers, AnamnesisKeys.session6Date),
          value(answers, AnamnesisKeys.session6),
        ),
        tableRow(
          '7ª',
          value(answers, AnamnesisKeys.session7Date),
          value(answers, AnamnesisKeys.session7),
        ),
        tableRow(
          '8ª',
          value(answers, AnamnesisKeys.session8Date),
          value(answers, AnamnesisKeys.session8),
        ),
        tableRow(
          '9ª',
          value(answers, AnamnesisKeys.session9Date),
          value(answers, AnamnesisKeys.session9),
        ),
        tableRow(
          '10ª',
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

  static pw.Widget _phototypeBlock(String selectedValue) {
    final normalized = selectedValue.trim().toUpperCase();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 4),
        _phototypeOption('I', 'Branco / Loiro', 'nunca bronzeia', normalized),
        _phototypeOption('II', 'Branco', 'dificilmente bronzeia', normalized),
        _phototypeOption(
          'III',
          'Moreno Claro',
          'bronzeia moderadamente',
          normalized,
        ),
        _phototypeOption(
          'IV',
          'Moreno Moderado',
          'sempre bronzeia',
          normalized,
        ),
        _phototypeOption(
          'V',
          'Moreno Escuro',
          'bronzeia intensamente',
          normalized,
        ),
        _phototypeOption('VI', 'Negro', 'não se queima', normalized),
      ],
    );
  }

  static pw.Widget _phototypeOption(
    String code,
    String skinTone,
    String description,
    String selectedValue,
  ) {
    final isSelected = selectedValue == code;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        '${isSelected ? '[x]' : '[ ]'} $code – $skinTone – $description',
        style: AnamnesisPdfStyles.text,
      ),
    );
  }
}
