import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/local/local_store.dart';
import 'package:gabaritei/data/memory/memory_repositories.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/rules/xp_rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<AnswerRecord> answers(Quiz quiz, {int? count}) => [
  for (final q in quiz.questions.take(count ?? quiz.questions.length))
    AnswerRecord(questionId: q.id, selectedIndex: q.correctIndex, correct: true),
];

void main() {
  test('todas as 86 unidades têm medalha própria com disciplina e assunto', () {
    final quizzes = {for (final q in SampleContent.quizzes) q.id: q};
    final medals = {for (final m in SampleContent.medals) m.id: m};
    expect(medals.length, 116);
    expect(medals.length, SampleContent.medals.length);
    final moduleBadges = <String>{};
    final finalBadges = <String>{};
    for (final trail in SampleContent.trails) {
      for (final module in trail.modules) {
        final quiz = quizzes[module.quizId]!;
        expect(quiz.badgeId, isNotNull, reason: module.id);
        final medal = medals[quiz.badgeId]!;
        expect(medal.discipline, trail.title);
        if (module.isFinalExam) {
          finalBadges.add(quiz.badgeId!);
        } else {
          expect(moduleBadges.add(quiz.badgeId!), isTrue);
          expect(medal.name, '${trail.title} · ${module.title}');
        }
      }
    }
    expect(moduleBadges.length, 86);
    expect(finalBadges.length, 26);
    expect(moduleBadges.intersection(finalBadges), isEmpty);
    expect(SampleContent.leiDeOhm.badgeId, 'mestre-ohm');
    expect(SampleContent.codigoDeCores.badgeId, 'mestre-cores');
    expect(SampleContent.associacaoDeResistores.badgeId, 'rei-paralelo');
  });

  for (final trail in SampleContent.trails) {
    test('assuntos de ${trail.title} concedem medalhas sem duplicar', () async {
      final student = MemoryStudentRepository();
      await student.resetProgress();
      final content = MemoryContentRepository(studentRepository: student);
      for (final module in trail.modules.where((m) => !m.isFinalExam)) {
        final quiz = await content.getQuiz(module.quizId!);
        final result = await student.submitQuiz(quiz, answers(quiz));
        expect(result.newMedals.map((m) => m.id), contains(quiz.badgeId));
        final again = await student.submitQuiz(quiz, answers(quiz));
        expect(again.newMedals.map((m) => m.id), isNot(contains(quiz.badgeId)));
      }
    });
  }

  test('80% concede assunto; 75% e respostas erradas não concedem', () async {
    final student = MemoryStudentRepository();
    await student.resetProgress();
    final quiz = SampleContent.associacaoDeResistores;
    final below = await student.submitQuiz(quiz, answers(quiz, count: 3));
    expect(below.newMedals.map((m) => m.id), isNot(contains(quiz.badgeId)));
    final ohm = SampleContent.leiDeOhm;
    final forged = await student.submitQuiz(ohm, [
      for (final q in ohm.questions)
        AnswerRecord(questionId: q.id,
          selectedIndex: (q.correctIndex + 1) % q.options.length, correct: true),
    ]);
    expect(forged.newMedals.map((m) => m.id), isNot(contains(ohm.badgeId)));
    final exact = await student.submitQuiz(ohm, answers(ohm, count: 4));
    expect(exact.newMedals.map((m) => m.id), contains(ohm.badgeId));
  });

  test('notas anteriores restauram assuntos sem dar domínio nem alterar XP', () async {
    final first = MemoryStudentRepository();
    final old = await first.getCurrentStudent();
    final quiz = SampleContent.lessons.firstWhere((q) => q.id == 'q-circuitos-ca-1');
    final restored = MemoryStudentRepository(
      initial: old,
      quizScores: {quiz.id: 0.8, 'q-circuitos-ca-2': 0.79, 'desconhecido': 1},
    );
    final student = await restored.getCurrentStudent();
    expect(student.totalXp, old.totalXp);
    expect(student.questionsAnswered, old.questionsAnswered);
    expect(student.earnedBadgeIds, containsAll(old.earnedBadgeIds));
    expect(student.earnedBadgeIds, contains(quiz.badgeId));
    expect(student.earnedBadgeIds, isNot(contains('assunto-circuitos-ca-2')));
    expect(student.earnedBadgeIds, isNot(contains('dominio-circuitos-ca')));
  });

  test('novas medalhas persistem e reset não as restaura indevidamente', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.open();
    final student = store.studentRepository();
    await student.resetProgress();
    final quiz = await store.contentRepository(students: student).getQuiz('q-circuitos-ca-1');
    await student.submitQuiz(quiz, answers(quiz));
    final restored = (await LocalStore.open()).studentRepository();
    expect((await restored.getCurrentStudent()).earnedBadgeIds, contains(quiz.badgeId));
    await restored.resetProgress();
    final reset = (await LocalStore.open()).studentRepository();
    expect((await reset.getCurrentStudent()).earnedBadgeIds, isEmpty);
  });

  test('migração persiste medalha ausente em arquivo antigo de progresso', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.open();
    final student = store.studentRepository();
    await student.resetProgress();
    student.bestQuizScores['q-circuitos-ca-1'] = 0.8;
    // Salva a nota antiga sem a medalha, como no catálogo anterior.
    student.onChanged!(student);
    final migrated = (await LocalStore.open()).studentRepository();
    final badge = SampleContent.lessons.firstWhere((q) => q.id == 'q-circuitos-ca-1').badgeId;
    expect((await migrated.getCurrentStudent()).earnedBadgeIds, contains(badge));
    final again = (await LocalStore.open()).studentRepository();
    expect((await again.getCurrentStudent()).earnedBadgeIds, contains(badge));
  });
}
