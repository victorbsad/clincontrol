import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/anamnesis_keys.dart';
import '../models/anamnesis.dart';
import '../models/client.dart';

class AnamnesisPdfService {
  const AnamnesisPdfService();

  Future<Uint8List> generate({
    required Client client,
    required Anamnesis anamnesis,
  }) async {
    final document = pw.Document();
    final answers = anamnesis.answers;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildHeader(client, anamnesis),
          pw.SizedBox(height: 16),
          _buildSection('DADOS PESSOAIS', [
            _line('Nome', client.name),
            _pairLine(
              'Estado civil',
              _value(answers, AnamnesisKeys.maritalStatus),
              'Nacionalidade',
              _value(answers, AnamnesisKeys.nationality),
            ),
            _line('Endereço completo', _value(answers, AnamnesisKeys.address)),
            _pairLine(
              'Telefone',
              _value(answers, AnamnesisKeys.phone),
              'WhatsApp',
              _value(answers, AnamnesisKeys.whatsapp),
            ),
            _line('Email', _value(answers, AnamnesisKeys.email)),
            _pairLine(
              'Data de nascimento',
              _formatDate(_value(answers, AnamnesisKeys.dateOfBirth)),
              'Idade',
              _value(answers, AnamnesisKeys.age),
            ),
            _line('Profissão', _value(answers, AnamnesisKeys.profession)),
            _line('Motivo da visita', _motivoVisitaLine(answers)),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('HISTÓRICO', [..._historicoRows(answers)]),
          pw.SizedBox(height: 20),
          pw.Text(
            '*Uso de estrogênio - não pode usar eletrolifting.',
            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
          ),
          pw.SizedBox(height: 20),
          pw.NewPage(),
          pw.SizedBox(height: 12),
          _buildSection('Avaliação da Pele', [
            _buildSubSection('BIOTIPO CUTANEO', [
              _buildSubSection('Pele Oleosa (Lipídica)', [
                _pairLine(
                  'Sensível',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinSensitive),
                  'Resistente',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinResistant),
                ),
                _pairLine(
                  'Pigmentada',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinPigmented),
                  'Não pigmentada',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinNonPigmented),
                ),
                _pairLine(
                  'Firme',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinFirm),
                  'Propensa à rugas',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.oilySkinWrinkled),
                ),
              ]),
              pw.SizedBox(height: 8),
              _buildSubSection('Pele Seca (Alípica)', [
                _pairLine(
                  'Sensível',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.drySkinSensitive),
                  'Resistente',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.drySkinResistant),
                ),
                _pairLine(
                  'Pigmentada',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.drySkinPigmented),
                  'Não pigmentada',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.drySkinNonPigmented),
                ),
                _pairLine(
                  'Firme',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.drySkinFirm),
                  'Propensa à rugas',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.drySkinWrinkled),
                ),
              ]),
              pw.SizedBox(height: 8),
              _buildSubSection('Pele Mista', [
                _pairLine(
                  'Sensível',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinSensitive),
                  'Resistente',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinResistant),
                ),
                _pairLine(
                  'Pigmentada',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinPigmented),
                  'Não pigmentada',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinNonPigmented),
                ),
                _pairLine(
                  'Firme',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinFirm),
                  'Propensa à rugas',
                  _checkboxSymbolForKey(answers, AnamnesisKeys.combinationSkinWrinkled),
                ),
              ]),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('ANALISE DETALHADA DA PELE', [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildSubSection('Pele com acne', [
                      _wrapBullets(
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
                          _getAnswer(answers, AnamnesisKeys.hasComedo),
                          _getAnswer(answers, AnamnesisKeys.hasPustule),
                          _getAnswer(answers, AnamnesisKeys.hasPapule),
                          _getAnswer(answers, AnamnesisKeys.hasNodule),
                          _getAnswer(answers, AnamnesisKeys.hasHyperkeratinization),
                          _getAnswer(answers, AnamnesisKeys.hasMilium),
                          _getAnswer(answers, AnamnesisKeys.hasMicrocyst),
                          _getAnswer(answers, AnamnesisKeys.hasInflammatoryAcne),
                          _getAnswer(answers, AnamnesisKeys.hasNonInflammatoryAcne),
                        ],
                      ),
                    ]),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _buildSubSection('Lesoes dermatologicas', [
                      _wrapBullets(
                        [
                          'Telangiectasia/ Nevo',
                          'Queratose Actínica',
                          'Nevo Melanocítico',
                          'Dermatose Papulosa Nigra',
                          'Papiloma',
                          'Acrocórdon',
                        ],
                        [
                          _getAnswer(answers, AnamnesisKeys.hasTelangiecatsiaNevus),
                          _getAnswer(answers, AnamnesisKeys.hasActinicKeratosis),
                          _getAnswer(answers, AnamnesisKeys.hasMelanocyticNevus),
                          _getAnswer(answers, AnamnesisKeys.hasDermatosisPapulosa),
                          _getAnswer(answers, AnamnesisKeys.hasPapilloma),
                          _getAnswer(answers, AnamnesisKeys.hasAcrochordion),
                        ],
                      ),
                      _line('Outras', _value(answers, AnamnesisKeys.hasOtherLesions)),
                    ]),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _buildSubSection('Dicromias', [
                      _wrapBullets(
                        [
                          'Hiperpimentação inflamatória',
                          'Fotoenvelhecimento',
                          'Melasma',
                          'Efelides',
                          'Hiperpigmentação orbicular',
                          'Hipocromia',
                        ],
                        [
                          _getAnswer(answers, AnamnesisKeys.hasInflammatoryHyperpigmentation),
                          _getAnswer(answers, AnamnesisKeys.hasPhotoaging),
                          _getAnswer(answers, AnamnesisKeys.hasMelasma),
                          _getAnswer(answers, AnamnesisKeys.hasFreckles),
                          _getAnswer(answers, AnamnesisKeys.hasOrbicularHyperpigmentation),
                          _getAnswer(answers, AnamnesisKeys.hasHypochromia),
                        ],
                      ),
                      _line(
                        'Por quê? Quanto tempo?',
                        _value(answers, AnamnesisKeys.chromaticAbnormalityJustification),
                      ),
                    ]),
                  ),
                ],
              ),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('FOTOTIPO', [
              _line(
                'FOTOTIPO - REATIVIDADE A LUZ ULTRAVIOLETA (Escala Fitzpatrick)',
                _value(answers, AnamnesisKeys.skinPhototype),
              ),
            ]),
            pw.SizedBox(height: 12),
            _buildSubSection('OUTROS', [
              _pairLine(
                'DERMATITE',
                _checkboxSymbolForKey(answers, AnamnesisKeys.hasDermatitis),
                'PSORIASE',
                _checkboxSymbolForKey(answers, AnamnesisKeys.hasPsoriasis),
              ),
              pw.SizedBox(height: 6),
              _line(
                'TRATAMENTO INDICADO',
                _value(answers, AnamnesisKeys.treatmentIndicated),
              ),
              pw.SizedBox(height: 6),
              _line('NUMERO DE SESSOES', _value(answers, AnamnesisKeys.numberOfSessions)),
              pw.SizedBox(height: 6),
              _subTitle('CONTROLE PROCEDIMENTOS'),
              _tableHeader(['Sessão', 'Data', 'Tratamento']),
              _tableRow(
                '1ª',
                _value(answers, AnamnesisKeys.session1Date),
                _value(answers, AnamnesisKeys.session1),
              ),
              _tableRow(
                '2ª',
                _value(answers, AnamnesisKeys.session2Date),
                _value(answers, AnamnesisKeys.session2),
              ),
              _tableRow(
                '3ª',
                _value(answers, AnamnesisKeys.session3Date),
                _value(answers, AnamnesisKeys.session3),
              ),
              _tableRow(
                '4ª',
                _value(answers, AnamnesisKeys.session4Date),
                _value(answers, AnamnesisKeys.session4),
              ),
              _tableRow(
                '5ª',
                _value(answers, AnamnesisKeys.session5Date),
                _value(answers, AnamnesisKeys.session5),
              ),
              _tableRow(
                '6ª',
                _value(answers, AnamnesisKeys.session6Date),
                _value(answers, AnamnesisKeys.session6),
              ),
              _tableRow(
                '7ª',
                _value(answers, AnamnesisKeys.session7Date),
                _value(answers, AnamnesisKeys.session7),
              ),
              _tableRow(
                '8ª',
                _value(answers, AnamnesisKeys.session8Date),
                _value(answers, AnamnesisKeys.session8),
              ),
              _tableRow(
                '9ª',
                _value(answers, AnamnesisKeys.session9Date),
                _value(answers, AnamnesisKeys.session9),
              ),
              _tableRow(
                '10ª',
                _value(answers, AnamnesisKeys.session10Date),
                _value(answers, AnamnesisKeys.session10),
              ),
            ]),
            pw.SizedBox(height: 14),
            _buildSubSection('PRESCRICAO COSMETICA (home care)', [
              _line('', _value(answers, AnamnesisKeys.cosmeticPrescription)),
            ]),
          ]),
          pw.SizedBox(height: 20),
          _buildSignatureSection(client),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _buildHeader(Client client, Anamnesis anamnesis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Ficha de Avaliação Facial',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(_pdfSafe('Cliente: ${client.name}')),
                pw.Text(
                  _pdfSafe('Gerado em: ${anamnesis.createdAt.toLocal()}'),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          _buildLogoPlaceholder(),
        ],
      ),
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> lines) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...lines,
        ],
      ),
    );
  }

  pw.Widget _buildSubSection(String title, List<pw.Widget> lines) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...lines,
        ],
      ),
    );
  }

  pw.Widget _line(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Text(
        _pdfSafe('$label: ${value.isEmpty ? 'NÃO' : value}'),
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  pw.Widget _subTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
      child: pw.Text(
        _pdfSafe(title),
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pairLine(
    String leftLabel,
    String leftValue,
    String rightLabel,
    String rightValue,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              '$leftLabel: ${leftValue.isEmpty ? 'NÃO' : leftValue}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              '$rightLabel: ${rightValue.isEmpty ? 'NÃO' : rightValue}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _stackedQuestion(
    String label,
    String value,
    String subLabel,
    String subValue,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label: ${value.isEmpty ? 'NÃO' : value}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '$subLabel: ${subValue.isEmpty ? 'NÃO' : subValue}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _historicoRows(Map<String, dynamic> answers) {
    final alergiasText = _value(answers, AnamnesisKeys.hasAllergies);

    final rows = <pw.Widget>[
      _yesNoRow(
        _yesNoQuestion(
          'Já fez algum tratamento estético ou dermatológico?',
          answers[AnamnesisKeys.hadAestheticTreatment],
          'Qual?',
          _value(answers, AnamnesisKeys.aestheticTreatmentType),
        ),
        _yesNoQuestion(
          'Problema de cicatrização ou Quelóide?',
          answers[AnamnesisKeys.keloidScarring],
          'Comente:',
          _value(answers, AnamnesisKeys.scarringComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Faz uso de algum medicamento?',
          answers[AnamnesisKeys.usesMedication],
          'Qual?',
          _value(answers, AnamnesisKeys.medicationType),
        ),
        _yesNoQuestion(
          'Usou Isotretinoína (Roacutan) nos últimos 6 meses?',
          answers[AnamnesisKeys.isotretinoin6Months],
          '',
          _value(answers, AnamnesisKeys.isotretinoin6MonthsComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Tratamento médico ou problema de saúde?',
          answers[AnamnesisKeys.hadMedicalTreatment],
          'Qual?',
          _value(answers, AnamnesisKeys.healthProblemType),
        ),
        _yesNoQuestion(
          'Apresenta trombose ou tromboflebite?',
          answers[AnamnesisKeys.thrombosis],
          'Local?',
          _value(answers, AnamnesisKeys.thrombosisLocation),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Já fez alguma cirurgia?',
          answers[AnamnesisKeys.hadSurgery],
          'Qual?',
          _value(answers, AnamnesisKeys.surgeryType),
        ),
        _yesNoQuestion(
          'Antecedentes oncológicos?',
          answers[AnamnesisKeys.hasOncologicalHistory],
          '',
          _value(answers, AnamnesisKeys.oncologicalComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Doença infectocontagiosa?',
          answers[AnamnesisKeys.infectiousDiseaseHistory],
          'Qual?',
          _value(answers, AnamnesisKeys.infectiousDiseaseType),
        ),
        _yesNoQuestion(
          'Pratica algum esporte?',
          answers[AnamnesisKeys.exercisesRegularly],
          '',
          _value(answers, AnamnesisKeys.exerciseType),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Alimentação balanceada?',
          answers[AnamnesisKeys.balancedDiet],
          '',
          _value(answers, AnamnesisKeys.dietComment),
        ),
        _yesNoQuestion(
          'Ingere no mínimo 2 litros de água por dia?',
          answers[AnamnesisKeys.drinks2LitersWater],
          'Quantos litros?',
          _value(answers, AnamnesisKeys.waterIntakeAmount),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Faz uso de bebida alcoólica?',
          answers[AnamnesisKeys.consumesAlcohol],
          'Frequência?',
          _value(answers, AnamnesisKeys.alcoholFrequency),
        ),
        _yesNoQuestion(
          'Faz uso de substâncias químicas ou entorpecentes?',
          answers[AnamnesisKeys.usesDrugs],
          'Qual?',
          _value(answers, AnamnesisKeys.drugType),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Distúrbio hormonal?',
          answers[AnamnesisKeys.hormoneImbalance],
          'Qual?',
          _value(answers, AnamnesisKeys.hormoneImbalanceType),
        ),
        _yesNoQuestion(
          'Dorme bem?',
          answers[AnamnesisKeys.sleepsWell],
          'Horas de sono:',
          _value(answers, AnamnesisKeys.sleepHours),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Funcionamento intestinal regular?',
          answers[AnamnesisKeys.regularBowelMovements],
          '',
          _value(answers, AnamnesisKeys.bowelComment),
        ),
        _yesNoQuestion(
          'Diabetes?',
          answers[AnamnesisKeys.hasDiabetes],
          'Compensada/descompensada?',
          _value(answers, AnamnesisKeys.diabetesControlled),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Tem problemas cardíacos?',
          answers[AnamnesisKeys.hasCardiacCondition],
          'Qual?',
          _value(answers, AnamnesisKeys.cardiacConditionType),
        ),
        _yesNoQuestion(
          'Depressão?',
          answers[AnamnesisKeys.hasDepression],
          'Faz tratamento?',
          _value(answers, AnamnesisKeys.depressionTreatment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Portador de Epilepsia?',
          answers[AnamnesisKeys.hasEpilepsy],
          '',
          _value(answers, AnamnesisKeys.epilepsyComment),
        ),
        _yesNoQuestion(
          'Possui placas e pinos metálicos na face?',
          answers[AnamnesisKeys.hasDentalImplants],
          'Onde?',
          _value(answers, AnamnesisKeys.dentalImplantLocation),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Próteses dentárias?',
          answers[AnamnesisKeys.hasDentures],
          '',
          _value(answers, AnamnesisKeys.denturesComment),
        ),
        _yesNoQuestion(
          'Faz uso de lentes de contato?',
          answers[AnamnesisKeys.wearsContactLenses],
          '',
          _value(answers, AnamnesisKeys.contactLensesComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Já fez ou faz uso de ácidos na pele?',
          answers[AnamnesisKeys.usesAcids],
          'Qual?',
          _value(answers, AnamnesisKeys.acidType),
        ),
        _yesNoQuestion(
          'Faz uso de cosméticos?',
          answers[AnamnesisKeys.usesCosmeticProducts],
          'Quais?',
          _value(answers, AnamnesisKeys.cosmeticProductTypes),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Faz uso de protetor solar?',
          answers[AnamnesisKeys.usesSunscreen],
          'Qual?',
          '${_value(answers, AnamnesisKeys.sunscreenType)} Frequência? ${_value(answers, AnamnesisKeys.sunscreenFrequency)}',
        ),
        _yesNoQuestion(
          'Costuma tomar sol?',
          answers[AnamnesisKeys.exposedToSun],
          'Frequência?',
          _value(answers, AnamnesisKeys.sunExposureFrequency),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Fez maquiagem definitiva?',
          answers[AnamnesisKeys.hasPermanentMakeup],
          'Local?',
          _value(answers, AnamnesisKeys.permanentMakeupLocation),
        ),
        _yesNoQuestion(
          'Fez aplicação de Metacril ou Toxina Botulínica?',
          answers[AnamnesisKeys.usedBotulinum],
          'Local?',
          _value(answers, AnamnesisKeys.botulinumLocation),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Alergias? (alimentar, cheiro, respiratória, corantes, medicamentos, etc)',
          _hasMeaningfulValue(alergiasText),
          'Especificar:',
          alergiasText,
        ),
        _yesNoQuestion(
          'Gestante?',
          answers[AnamnesisKeys.isPregnant],
          'Quantos meses?',
          _value(answers, AnamnesisKeys.pregnancyMonths),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Filhos?',
          answers[AnamnesisKeys.hasChildren],
          'Quantos?',
          _value(answers, AnamnesisKeys.numberOfChildren),
        ),
        _yesNoQuestion(
          'Ciclo menstrual regular?',
          answers[AnamnesisKeys.regularMenstrualCycle],
          'Obs.:',
          _value(answers, AnamnesisKeys.menstrualCycleComment),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Já teve herpes?',
          answers[AnamnesisKeys.hasHerpesHistory],
          'A quanto tempo?',
          _value(answers, AnamnesisKeys.herpesDuration),
        ),
        _yesNoQuestion(
          'Faz uso de anticoncepcional?',
          answers[AnamnesisKeys.usesContraceptive],
          'Qual?',
          _value(answers, AnamnesisKeys.contraceptiveType),
        ),
      ),
      _yesNoRow(
        _yesNoQuestion(
          'Faz uso de hormônio?*',
          answers[AnamnesisKeys.takesHormones],
          'Qual?',
          _value(answers, AnamnesisKeys.hormoneType),
        ),
        _yesNoQuestion(
          'Autoriza divulgação de foto antes/após tratamento?',
          answers[AnamnesisKeys.authorizedForPhotos],
          '',
          _value(answers, AnamnesisKeys.photoAuthorizationComment),
        ),
      ),
      _subTitle('Fuma ou Fumou'),
      _stackedQuestion(
        'Fuma',
        _value(answers, AnamnesisKeys.smokeOrSmoked),
        'Quanto tempo?',
        _value(answers, AnamnesisKeys.smokingDuration),
      ),
      _pressureQuestion(answers),
    ];

    return rows;
  }

  pw.Widget _yesNoRow(pw.Widget left, pw.Widget right) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: left),
          pw.SizedBox(width: 12),
          pw.Expanded(child: right),
        ],
      ),
    );
  }

  pw.Widget _yesNoQuestion(
    String question,
    dynamic rawAnswer,
    String commentLabel,
    String commentValue,
  ) {
    final selection = _toYesNoSelection(rawAnswer);
    final isYes = selection == true;
    final text = isYes ? 'SIM' : 'NÃO';
    final hasComment = _hasMeaningfulValue(commentValue);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          question,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
        if (isYes && commentLabel.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(
              _pdfSafe(
                '$commentLabel ${hasComment ? commentValue : 'NÃO INFORMADO'}',
              ),
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
      ],
    );
  }

  String _motivoVisitaLine(Map<String, dynamic> answers) {
    return _value(answers, AnamnesisKeys.visitReason);
  }

  pw.Widget _wrapBullets(List<String> labels, List<dynamic> values) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: List.generate(labels.length, (index) {
          final value = _checkboxSymbol(values[index]);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              '${labels[index]}: $value',
              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        }),
      ),
    );
  }

  pw.Widget _tableHeader(List<String> columns) {
    return pw.Row(
      children: columns
          .map(
            (column) => pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey600),
                  ),
                ),
                child: pw.Text(
                  column,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _tableRow(String session, String date, String treatment) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            _pdfSafe(session),
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            _pdfSafe(date.isEmpty ? 'NÃO' : date),
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            _pdfSafe(treatment.isEmpty ? 'NÃO' : treatment),
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    );
  }

  String _value(Map<String, dynamic> answers, String key) {
    final value = answers[key];
    if (value == null) return 'NÃO';
    if (value is String && value.trim().isEmpty) return 'NÃO';
    return value.toString();
  }

  dynamic _getAnswer(Map<String, dynamic> answers, String key) {
    return answers[key];
  }

  bool? _toYesNoSelection(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized == 'sim' || normalized == 'true' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'não' ||
        normalized == 'nao' ||
        normalized == 'false' ||
        normalized == 'no') {
      return false;
    }
    return null;
  }

  bool _hasMeaningfulValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (normalized == 'não' || normalized == 'nao') return false;
    return true;
  }

  String _checkboxSymbolForKey(Map<String, dynamic> answers, String key) {
    final value = answers[key];
    return _checkboxSymbol(value);
  }

  String _checkboxSymbol(dynamic value) {
    if (value == null) return '[ ]';
    if (value is bool) return value ? '[x]' : '[ ]';

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return '[ ]';

    if (normalized == 'true' ||
        normalized == 'sim' ||
        normalized == 'yes' ||
        normalized == 'selecionado') {
      return '[x]';
    }

    if (normalized == 'false' ||
        normalized == 'nao' ||
        normalized == 'não' ||
        normalized == 'no' ||
        normalized == 'não selecionado') {
      return '[ ]';
    }

    return '[ ]';
  }

  String _formatDate(String value) {
    if (value == 'NÃO') return value;
    return value;
  }

  String _pdfSafe(String value) {
    return value
        .replaceAll('\u00A0', ' ')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('’', "'")
        .replaceAll('•', '-')
        .replaceAll('☐', '[ ]')
        .replaceAll('☑', '[x]')
        .replaceAll('✓', 'v');
  }

  pw.Widget _buildLogoPlaceholder() {
    return pw.Container(
      width: 80,
      height: 80,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Center(
        child: pw.Text(
          '[Logo]',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ),
    );
  }

  pw.Widget _buildSignatureSection(Client client) {
    final currentDate = _formatBrazilianDate(DateTime.now());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Assinatura da Paciente:',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 60),
        pw.Container(width: double.infinity, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 6),
        pw.Text(
          _pdfSafe('Nome: ${client.name}'),
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          _pdfSafe('Data: $currentDate'),
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  String _formatBrazilianDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  pw.Widget _pressureQuestion(Map<String, dynamic> answers) {
    final pressureValue = _value(answers, AnamnesisKeys.bloodPressure);
    final pressureStatus = _value(answers, AnamnesisKeys.bloodPressureControlled);
    final hasPressure = pressureValue.isNotEmpty && pressureValue != 'NÃO';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Hipertensão ou Hipotensão?',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        if (hasPressure) ...[
          pw.Text(
            _pdfSafe(pressureValue),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _pdfSafe('Compensada/descompensada: $pressureStatus'),
            style: const pw.TextStyle(fontSize: 9),
          ),
        ] else
          pw.Text('NÃO', style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }
}
