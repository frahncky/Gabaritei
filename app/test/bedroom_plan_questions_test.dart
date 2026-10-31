import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/services/question_generator.dart';
import 'package:gabaritei/shared/drawings/bedroom_plan.dart';
import 'package:gabaritei/shared/format.dart';

const _installations = 'Instalações elétricas';
const _units = <String?>[
  'Plantas e simbologia',
  'Dimensionamento',
  'Luminotécnica',
  'Comandos elétricos',
  null, // sem assunto: percorre o banco da planta
];

/// Constantes da NBR 5410 usadas nas questões (não vêm do desenho).
const _firstAreaM2 = 6; // primeiros 6 m² valem 100 VA
const _firstAreaVa = 100;
const _blockM2 = 4; // cada 4 m² inteiros a mais: +60 VA
const _blockVa = 60;
const _tugPerimeterM = 5; // 1 TUG a cada 5 m (ou fração) de perímetro
const _dedicatedAboveA = 10; // acima de 10 A, circuito independente
const _voltage = 127; // tensão informada nos enunciados
const _lux = 150; // iluminância pedida na questão de luminotécnica

double get _area => BedroomPlanSpec.widthM * BedroomPlanSpec.depthM;
double get _perimeter => 2 * (BedroomPlanSpec.widthM + BedroomPlanSpec.depthM);
int get _blocks => ((_area - _firstAreaM2) / _blockM2).floor();

String _m(double v) => '${formatDecimal(v, 2)} m';
String _m2(double v) => '${formatDecimal(v, 2)} m²';

/// Todo valor com unidade que os enunciados e explicações da planta podem
/// citar, calculado a partir de [BedroomPlanSpec] e das regras da norma.
Set<String> get _allowedWithUnit => {
      ...<String>[
        _m(BedroomPlanSpec.widthM),
        _m(BedroomPlanSpec.depthM),
        _m(_perimeter),
        _m2(_area),
        _m2(_area - _firstAreaM2),
        _m2((_firstAreaM2 + _blockM2 * (_blocks + 1)).toDouble()),
        '$_firstAreaM2 m²',
        '$_blockM2 m²',
        '$_tugPerimeterM m',
        '${BedroomPlanSpec.lightVa} VA',
        '${BedroomPlanSpec.outletVa} VA',
        '${BedroomPlanSpec.outletCount * BedroomPlanSpec.outletVa} VA',
        '$_firstAreaVa VA',
        '$_blockVa VA',
        '${_firstAreaVa + _blockVa * (_blocks + 1)} VA',
        '${formatNumber(BedroomPlanSpec.acWatts)} W',
        '${formatDecimal(BedroomPlanSpec.lightVa / _voltage, 2)} A',
        '${formatDecimal(BedroomPlanSpec.acWatts / _voltage, 1)} A',
        '$_dedicatedAboveA A',
        '$_lux lx',
        '${formatNumber((_lux * _area).round())} lm',
      ],
    };

/// Números soltos com duas casas ("3,50 × 3,00") que podem aparecer nas
/// contas das explicações.
Set<String> get _allowedBare => {
      ...<String>[
        formatDecimal(BedroomPlanSpec.widthM, 2),
        formatDecimal(BedroomPlanSpec.depthM, 2),
        formatDecimal(_area, 2),
        formatDecimal(_perimeter, 2),
        formatDecimal(_area - _firstAreaM2, 2),
        formatDecimal((_firstAreaM2 + _blockM2 * (_blocks + 1)).toDouble(), 2),
      ],
    };

final _withUnit =
    RegExp(r'(\d{1,3}(?:\.\d{3})*(?:,\d+)?) ?(m²|m|VA|W|A|lm|lx)(?![\wÀ-ú²])');
final _bareTwoDecimals = RegExp(r'(?<![\d,.])\d+,\d{2}(?![\d²])');

/// Confere que os números de [q] saíram do desenho; devolve os citados.
Set<String> _expectNumbersFromSpec(Question q) {
  final cited = <String>{};
  for (final text in [q.prompt, q.explanation]) {
    for (final m in _withUnit.allMatches(text)) {
      final value = '${m.group(1)} ${m.group(2)}';
      cited.add(value);
      expect(_allowedWithUnit, contains(value),
          reason: '${q.id}: "$value" não sai de BedroomPlanSpec em "$text"');
    }
    final withoutUnits = text.replaceAll(_withUnit, '');
    for (final m in _bareTwoDecimals.allMatches(withoutUnits)) {
      cited.add(m.group(0)!);
      expect(_allowedBare, contains(m.group(0)),
          reason: '${q.id}: "${m.group(0)}" não sai de BedroomPlanSpec');
    }
  }
  return cited;
}

List<Question> _generated(String? unit) => [
      for (var s = 0; s <= 11; s++)
        QuestionGenerator.generate(
            topic: _installations, unit: unit, sequence: s),
    ];

/// Valores do desenho que o conjunto de questões precisa citar. O banco do
/// gerador só cita perímetro e lados dentro das contas ("3,50 × 3,00"), sem
/// unidade; o desafio cita todos com unidade.
List<String> _keyValues({bool perimeter = true}) => [
      _m2(_area),
      '${BedroomPlanSpec.lightVa} VA',
      '${formatNumber(BedroomPlanSpec.acWatts)} W',
      if (perimeter) ...[
        _m(_perimeter),
        _m(BedroomPlanSpec.widthM),
        _m(BedroomPlanSpec.depthM),
      ] else ...[
        formatDecimal(BedroomPlanSpec.widthM, 2),
        formatDecimal(BedroomPlanSpec.depthM, 2),
      ],
    ];

void main() {
  group('regras da NBR 5410 fecham com o desenho', () {
    test('carga de iluminação = 100 VA + 60 VA por bloco inteiro de 4 m²', () {
      expect(_area, closeTo(10.5, 1e-9));
      expect(BedroomPlanSpec.lightVa, _firstAreaVa + _blockVa * _blocks);
    });

    test('quantidade de TUGs cobre 1 a cada 5 m de perímetro, ou fração', () {
      expect(BedroomPlanSpec.outletCount,
          greaterThanOrEqualTo((_perimeter / _tugPerimeterM).ceil()));
      expect(
          BedroomPlanLayout.points
              .where((p) => p.kind == PlanPointKind.lowOutlet),
          hasLength(BedroomPlanSpec.outletCount));
    });

    test('ar-condicionado passa de 10 A e tem circuito próprio', () {
      expect(BedroomPlanSpec.acWatts / _voltage, greaterThan(_dedicatedAboveA));
      expect(
          BedroomPlanSpec.acCircuit,
          isNot(anyOf(
              BedroomPlanSpec.lightCircuit, BedroomPlanSpec.outletCircuit)));
    });
  });

  group('gerador de Instalações elétricas', () {
    for (final unit in _units) {
      final name = unit ?? 'sem assunto';
      test('"$name": ids únicos e estáveis de 0 a 11', () {
        final first = _generated(unit);
        final again = _generated(unit);
        final ids = first.map((q) => q.id).toList();
        expect(ids.toSet(), hasLength(ids.length));
        expect(again.map((q) => q.id).toList(), ids);
        // Mesma sequência, mesma questão.
        expect(again.map((q) => q.prompt).toList(),
            first.map((q) => q.prompt).toList());
      });
    }

    test('números das questões com a planta saem de BedroomPlanSpec', () {
      final cited = <String>{};
      for (final unit in _units) {
        for (final q in _generated(unit)
            .where((q) => q.visual == QuestionVisual.bedroomPlan)) {
          cited.addAll(_expectNumbersFromSpec(q));
        }
      }
      for (final value in _keyValues(perimeter: false)) {
        expect(cited, contains(value), reason: 'nenhuma questão cita $value');
      }
    });
  });

  group('desafio "q-planta-quarto"', () {
    final quiz =
        SampleContent.quizzes.singleWhere((q) => q.id == 'q-planta-quarto');

    test('ids únicos e todas as questões com a planta', () {
      final ids = quiz.questions.map((q) => q.id).toList();
      expect(ids, hasLength(5));
      expect(ids.toSet(), hasLength(5));
      expect(quiz.questions.map((q) => q.visual),
          everyElement(QuestionVisual.bedroomPlan));
    });

    test('números dos enunciados e explicações saem de BedroomPlanSpec', () {
      final cited = <String>{};
      for (final q in quiz.questions) {
        cited.addAll(_expectNumbersFromSpec(q));
      }
      for (final value in _keyValues()) {
        expect(cited, contains(value), reason: 'nenhuma questão cita $value');
      }
    });

    test('gabarito das contas confere com o desenho', () {
      final byId = {for (final q in quiz.questions) q.id: q};
      String right(String id) => byId[id]!.options[byId[id]!.correctIndex];

      expect(
          right('planta-1'),
          contains('${{
            BedroomPlanSpec.lightCircuit,
            BedroomPlanSpec.outletCircuit,
            BedroomPlanSpec.acCircuit,
          }.length} circuitos'));
      expect(
          right('planta-3'),
          allOf(contains('$_firstAreaVa VA'),
              contains('${_blockVa * _blocks} VA')));
      expect(right('planta-4'),
          contains('→ ${(_perimeter / _tugPerimeterM).ceil()} TUGs'));
      expect(right('planta-5'),
          contains(formatDecimal(BedroomPlanSpec.acWatts / _voltage, 1)));
    });
  });
}
