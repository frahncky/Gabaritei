import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/memory/expanded_question_bank.dart';
import 'package:gabaritei/data/memory/memory_repositories.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';

void main() {
  test('banco cobre 86 unidades com no mínimo quatro questões', () {
    final quizzes = {for (final q in SampleContent.quizzes) q.id: q};
    final modules = SampleContent.trails.expand((t) => t.modules)
        .where((m) => !m.isFinalExam).toList();
    expect(ExpandedQuestionBank.practice.keys.toSet(), modules.map((m) => m.id).toSet());
    for (final module in modules) {
      expect(quizzes[module.quizId]!.questions.length, greaterThanOrEqualTo(4),
          reason: module.id);
    }
    expect(SampleContent.lessons.fold<int>(0, (n, q) => n + q.questions.length), 354);
  });

  test('26 provas usam apenas perguntas próprias sem repetir as de estudo', () {
    final practiceIds = SampleContent.lessons.expand((q) => q.questions).map((q) => q.id).toSet();
    final practicePrompts = SampleContent.lessons.expand((q) => q.questions)
        .map((q) => q.prompt.trim().toLowerCase()).toSet();
    var examCount = 0;
    for (final trail in SampleContent.trails) {
      final exam = SampleContent.quizzes.firstWhere((q) => q.id == trail.modules.last.quizId);
      expect(exam.questions.length, greaterThanOrEqualTo(4));
      for (final question in exam.questions) {
        expect(practiceIds, isNot(contains(question.id)));
        expect(practicePrompts, isNot(contains(question.prompt.trim().toLowerCase())));
        expect(question.id, startsWith('exam-v2-'));
        examCount++;
      }
    }
    expect(ExpandedQuestionBank.assessment.length, 26);
    expect(examCount, 110);
  });

  test('464 questões têm IDs únicos, gabarito válido e alternativas distintas', () {
    final questions = SampleContent.quizzes.expand((q) => q.questions).toList();
    expect(questions.length, 464);
    expect(questions.map((q) => q.id).toSet().length, questions.length);
    for (final q in questions) {
      expect(q.prompt.trim(), isNotEmpty, reason: q.id);
      expect(q.options.length, 4, reason: q.id);
      expect(q.options.map((o) => o.trim().toLowerCase()).toSet().length, 4, reason: q.id);
      expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
      expect(q.explanation.trim(), isNotEmpty, reason: q.id);
    }
  });

  test('rotação mantém o gabarito associado à resposta correta', () {
    for (final item in [...ExpandedQuestionBank.practice.values.expand((v) => v),
      ...ExpandedQuestionBank.assessment.values.expand((v) => v)]) {
      for (var position = 0; position < 8; position++) {
        final question = item.question('test', 'Teste', position);
        expect(question.options[question.correctIndex], item.answer);
      }
    }
  });

  test('conversões e cálculos representativos conferem com as fórmulas', () {
    double answer(String key, int index) => double.parse(
      RegExp(r'−?\d+(?:[.,]\d+)?').firstMatch(
        ExpandedQuestionBank.practice[key]![index].answer)!.group(0)!
        .replaceAll(',', '.').replaceAll('−', '-'));
    expect(answer('eb-1', 0), 30 / 5);
    expect(answer('eb-2', 0), closeTo(330 * 0.020, 1e-9));
    expect(answer('eb-3', 0), closeTo(1.5 * (40 / 60) * 30, 1e-9));
    expect(answer('eb-3', 1), closeTo(100 * 0.2 * 0.2, 1e-9));
    expect(answer('eb-6', 0), 12 * 1 / (3 + 1));
    expect(answer('ea-5', 0), closeTo(1 / (2 * math.pi * 1000 * 1e-6), 0.5));
    expect(answer('circuitos-ca-2', 1), math.sqrt(6 * 6 + 8 * 8));
    expect(answer('circuitos-ca-3', 0), math.sqrt(400 * 400 + 300 * 300));
    expect(answer('eletronica-potencia-2', 1), 12 / (1 - 0.5));
    expect(answer('maquinas-eletricas-2', 0), 1200 * (1 - 0.04));
    expect(answer('pneumatica-hidraulica-2', 0), 500000 * 0.002);
    expect(answer('sensores-instrumentacao-2', 1), (16 - 4) / 16 * 400);
    expect(answer('mecanica-maquinas-1', 1), 3000 / 150);
    expect(answer('cnc-manufatura-3', 0), 3600 / 45);
    expect(answer('qualidade-gestao-ambiente-1', 0), 15 / 500 * 100);
  });

  test('ampliação preserva notas, XP e medalhas já registrados', () async {
    final original = await MemoryStudentRepository().getCurrentStudent();
    final student = MemoryStudentRepository(initial: original,
      quizScores: {'q-eb-1': 0.8, 'q-ea-final': 0.7});
    final content = MemoryContentRepository(studentRepository: student);
    expect((await content.getQuiz('q-eb-1')).questions.length, 4);
    expect((await content.getQuiz('q-ea-final')).questions.length, 10);
    expect(student.bestQuizScores['q-eb-1'], 0.8);
    expect(student.bestQuizScores['q-ea-final'], 0.7);
    expect((await content.getTrails()).first.modules.first.status, ModuleStatus.done);
    expect((await student.getCurrentStudent()).totalXp, original.totalXp);
    expect((await student.getCurrentStudent()).earnedBadgeIds,
        containsAll(original.earnedBadgeIds));
  });
}
