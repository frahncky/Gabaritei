import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/local/local_store.dart';
import 'package:gabaritei/data/memory/question_figure_catalog.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/models/question_figure.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('todas as 26 disciplinas têm figuras específicas e nenhum vínculo é órfão', () {
    final bank = {for (final quiz in SampleContent.quizzes)
      for (final question in quiz.questions) question.id: question};
    for (final id in QuestionFigureCatalog.figures.keys) {
      expect(bank.containsKey(id), isTrue, reason: id);
      expect(bank[id]!.figure, isNotNull, reason: id);
    }
    expect(QuestionFigureCatalog.figures.length, greaterThanOrEqualTo(130));
    for (final trail in SampleContent.trails) {
      final ids = trail.modules.map((m) => m.quizId).toSet();
      final count = SampleContent.quizzes.where((q) => ids.contains(q.id))
          .expand((q) => q.questions).where((q) => q.figure != null).length;
      expect(count, greaterThanOrEqualTo(3), reason: trail.title);
    }
  });

  test('dados das figuras são serializáveis e coerentes com o renderer', () {
    for (final entry in QuestionFigureCatalog.figures.entries) {
      final f = entry.value;
      expect(f.title, isNotEmpty, reason: entry.key);
      expect(f.description, isNotEmpty, reason: entry.key);
      final decoded = QuestionFigure.fromJson(
        jsonDecode(jsonEncode(f.toJson())) as Map<String, dynamic>);
      expect(decoded.toJson(), f.toJson(), reason: entry.key);
      if (f.kind == FigureKind.truthTable || f.kind == FigureKind.referenceTable) {
        expect(f.headers, isNotEmpty);
        for (final row in f.rows) expect(row.length, f.headers.length, reason: entry.key);
      }
      if (f.kind == FigureKind.chart || f.kind == FigureKind.waveform) {
        expect(f.xMax, greaterThan(f.xMin));
        expect(f.yMax, greaterThan(f.yMin));
        expect(f.xLabel, isNotEmpty);
        expect(f.yLabel, isNotEmpty);
        for (final trace in f.traces) {
          expect(trace.points, isNotEmpty);
          var lastX = double.negativeInfinity;
          for (final p in trace.points) {
            expect(p.x.isFinite && p.y.isFinite, isTrue);
            expect(p.x, greaterThanOrEqualTo(lastX));
            expect(p.x, inInclusiveRange(f.xMin - 1e-9, f.xMax + 1e-9));
            expect(p.y, inInclusiveRange(f.yMin - 1e-9, f.yMax + 1e-9));
            lastX = p.x;
          }
        }
      }
      if (f.kind == FigureKind.phasor) {
        expect(f.values.length, 2);
        expect(f.values.every((v) => v.isFinite && v != 0), isTrue);
        expect(f.labels.length, 3);
      }
      if (f.kind == FigureKind.bars) {
        expect(f.values.length, f.labels.length);
        expect(f.values.every((v) => v.isFinite && v >= 0), isTrue);
      }
    }
  });

  test('circuitos preservam valores e distinguem série de paralelo', () {
    final series = QuestionFigureCatalog.figures['ohm-1']!;
    expect(series.kind, FigureKind.seriesCircuit);
    expect(series.sourceLabel, '12 V');
    expect(series.elements.single.label, 'R = 220 Ω');
    final parallel = QuestionFigureCatalog.figures['assoc-3']!;
    expect(parallel.kind, FigureKind.parallelCircuit);
    expect(parallel.elements.map((e) => e.label), ['R1 = 6 Ω', 'R2 = 3 Ω']);
    final mixed = QuestionFigureCatalog.figures['bank-v2-eb-4-1']!;
    expect(mixed.kind, FigureKind.mixedCircuit);
    expect(mixed.elements.map((e) => e.label), ['R1 = 10 Ω','R2 = 20 Ω','R3 = 20 Ω']);
  });

  test('onda atrasada respeita 50 Hz e atraso de 5 ms', () {
    final wave = QuestionFigureCatalog.figures['exam-v2-circuitos-ca-3']!;
    expect(wave.xLabel, 'Tempo (ms)');
    expect(wave.values, [50,1,5]);
    expect(wave.traces[0].points.first.y, closeTo(0, 1e-9));
    expect(wave.traces[1].points.first.y, closeTo(-1, 1e-9));
    final at5 = wave.traces[1].points.firstWhere((p) => (p.x - 5).abs() < 1e-9);
    expect(at5.y, closeTo(0, 1e-9));
  });

  test('Ladder conserva negação e tabelas não preenchem saídas', () {
    expect(QuestionFigureCatalog.figures['bank-v2-clp-1-1']!.rows, [['A','!B']]);
    final table = QuestionFigureCatalog.figures['bank-v2-ed-2-0']!;
    expect(table.rows.every((row) => row.last == '?'), isTrue);
  });

  test('anexar figura não altera alternativas nem gabarito', () {
    const q = Question(id: 'ohm-1', topic: 'Teste', prompt: 'Texto',
      options: ['A','B','C','D'], correctIndex: 2, explanation: 'Explicação');
    final illustrated = QuestionFigureCatalog.attach(q);
    expect(illustrated.figure, isNotNull);
    expect(illustrated.id, q.id);
    expect(illustrated.options, q.options);
    expect(illustrated.correctIndex, q.correctIndex);
    expect(illustrated.explanation, q.explanation);
  });

  test('figuras persistem nas questões salvas pelo professor', () async {
    SharedPreferences.setMockInitialValues({});
    final q = SampleContent.lessons.expand((q) => q.questions)
        .firstWhere((q) => q.figure != null);
    await (await LocalStore.open()).contentRepository().saveQuestion(q);
    final saved = await (await LocalStore.open()).contentRepository().getCreatedQuestions();
    expect(saved.single.figure!.toJson(), q.figure!.toJson());
    expect(saved.single.correctIndex, q.correctIndex);
  });
}
