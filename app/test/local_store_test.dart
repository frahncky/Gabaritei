import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/local/local_store.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/rules/xp_rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('progresso do aluno sobrevive a reabrir o app', () async {
    final now = DateTime(2026, 10, 20, 10);
    final quiz = SampleContent.quizzes.first;
    final answers = [
      for (final q in quiz.questions)
        AnswerRecord(
            questionId: q.id, selectedIndex: q.correctIndex, correct: true),
    ];

    final first = (await LocalStore.open()).studentRepository(clock: () => now);
    final result = await first.submitQuiz(quiz, answers);

    final reopened =
        (await LocalStore.open()).studentRepository(clock: () => now);
    final student = await reopened.getCurrentStudent();
    expect(student.totalXp, result.xpAfter);
    expect(student.studyDays, contains(DateTime(2026, 10, 20)));
    expect(reopened.weeklyXp, first.weeklyXp);
  });

  test('sequência perdida aparece zerada', () async {
    final today = DateTime(2026, 10, 20);
    final quiz = SampleContent.quizzes.first;
    await (await LocalStore.open())
        .studentRepository(clock: () => today)
        .submitQuiz(quiz, const []);

    final later = (await LocalStore.open())
        .studentRepository(clock: () => today.add(const Duration(days: 5)));
    expect((await later.getCurrentStudent()).streakDays, 0);
  });

  test('recomeçar zera o progresso salvo', () async {
    await (await LocalStore.open()).studentRepository().resetProgress();
    final student =
        await (await LocalStore.open()).studentRepository().getCurrentStudent();
    expect(student.totalXp, 0);
    expect(student.earnedBadgeIds, isEmpty);
  });

  test('questões criadas pelo professor ficam salvas', () async {
    const q = Question(
      id: 'q-1',
      topic: 'Lei de Ohm',
      prompt: 'V = ?',
      options: ['R·I', 'R/I'],
      correctIndex: 0,
      explanation: 'Lei de Ohm.',
      visual: QuestionVisual.circuitSeries,
    );
    await (await LocalStore.open()).contentRepository().saveQuestion(q);
    final saved = await (await LocalStore.open())
        .contentRepository()
        .getCreatedQuestions();
    expect(saved.single.visual, QuestionVisual.circuitSeries);
  });
}
