import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/memory/memory_repositories.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/rules/xp_rules.dart';

List<AnswerRecord> correctAnswers(Quiz quiz, {int? count}) => [
  for (final q in quiz.questions.take(count ?? quiz.questions.length))
    AnswerRecord(questionId: q.id, selectedIndex: q.correctIndex, correct: true),
];

void main() {
  test('cada disciplina possui medalha final própria e nomes vinculados', () {
    final ids = <String>{};
    for (final trail in SampleContent.trails) {
      final exam = SampleContent.quizzes.firstWhere(
          (q) => q.id == trail.modules.last.quizId);
      expect(exam.badgeId, isNotNull);
      expect(ids.add(exam.badgeId!), isTrue);
      final medal = SampleContent.medals.firstWhere((m) => m.id == exam.badgeId);
      expect(medal.discipline, trail.title);
      expect(medal.name, contains(trail.title));
    }
    for (final medal in SampleContent.medals) {
      if (medal.discipline != null) {
        expect(medal.name, contains(medal.discipline!));
      }
    }
  });

  for (final trail in SampleContent.trails) {
    test('concluir ${trail.title} concede medalha uma única vez', () async {
      final student = MemoryStudentRepository();
      if (trail.requiresTrailId != null) {
        final prerequisite = SampleContent.trails.firstWhere(
            (t) => t.id == trail.requiresTrailId);
        for (final module in prerequisite.modules) {
          final quiz = SampleContent.quizzes.firstWhere((q) => q.id == module.quizId);
          await student.submitQuiz(quiz, correctAnswers(quiz));
        }
      }
      for (final module in trail.modules.where((m) => !m.isFinalExam)) {
        final quiz = SampleContent.quizzes.firstWhere((q) => q.id == module.quizId);
        await student.submitQuiz(quiz, correctAnswers(quiz));
      }
      final exam = SampleContent.quizzes.firstWhere(
          (q) => q.id == trail.modules.last.quizId);
      final result = await student.submitQuiz(exam, correctAnswers(exam));
      expect(result.newMedals.map((m) => m.id), contains(exam.badgeId));
      final repeated = await student.submitQuiz(exam, correctAnswers(exam));
      expect(repeated.newMedals.map((m) => m.id), isNot(contains(exam.badgeId)));
    });
  }

  test('prova isolada sem módulos não concede domínio', () async {
    final student = MemoryStudentRepository();
    final exam = SampleContent.quizzes.firstWhere((q) => q.id == 'q-ed-final');
    final result = await student.submitQuiz(exam, correctAnswers(exam));
    expect(result.newMedals.map((m) => m.id), isNot(contains(exam.badgeId)));
  });

  test('domínio exige 70%, sem exigir os 80% das medalhas de desafio', () async {
    final student = MemoryStudentRepository();
    final trail = SampleContent.trails.firstWhere((t) => t.id == 'eletronica-analogica');
    for (final module in trail.modules.where((m) => !m.isFinalExam)) {
      final quiz = SampleContent.quizzes.firstWhere((q) => q.id == module.quizId);
      await student.submitQuiz(quiz, correctAnswers(quiz));
    }
    final exam = SampleContent.quizzes.firstWhere((q) => q.id == trail.modules.last.quizId);
    expect(exam.questions.length, 10);
    final failed = await student.submitQuiz(exam, correctAnswers(exam, count: 6));
    expect(failed.newMedals.map((m) => m.id), isNot(contains(exam.badgeId)));
    final passed = await student.submitQuiz(exam, correctAnswers(exam, count: 7));
    expect(passed.newMedals.map((m) => m.id), contains(exam.badgeId));
  });

  test('IDs antigos continuam no catálogo para preservar medalhas salvas', () {
    expect(SampleContent.medals.map((m) => m.id), containsAll([
      'mestre-ohm', 'potencia-total', 'mestre-cores', 'rei-paralelo',
      'primeira-trilha', 'kirchhoff', 'streak-7', 'streak-30', 'streak-100',
    ]));
  });
}
