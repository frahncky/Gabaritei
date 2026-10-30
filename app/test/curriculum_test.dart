import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/local/local_store.dart';
import 'package:gabaritei/data/memory/memory_repositories.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/rules/xp_rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<AnswerRecord> answersFor(Quiz quiz, {bool correct = true}) => [
  for (final q in quiz.questions)
    AnswerRecord(
      questionId: q.id,
      selectedIndex: correct ? q.correctIndex : (q.correctIndex + 1) % q.options.length,
      correct: correct,
    ),
];

void main() {
  test('catálogo tem atividades válidas e pré-requisitos existentes', () {
    final quizzes = {for (final q in SampleContent.quizzes) q.id: q};
    final trails = {for (final t in SampleContent.trails) t.id: t};
    expect(quizzes.length, SampleContent.quizzes.length);
    expect(trails.length, 26);
    for (final trail in trails.values) {
      if (trail.requiresTrailId != null) {
        expect(trails.containsKey(trail.requiresTrailId), isTrue);
      }
      expect(trail.modules.last.isFinalExam, isTrue);
      for (final module in trail.modules) {
        expect(quizzes.containsKey(module.quizId), isTrue, reason: module.id);
        final quiz = quizzes[module.quizId]!;
        expect(quiz.questions.length, greaterThanOrEqualTo(2));
        expect(quiz.questions.map((q) => q.id).toSet().length, quiz.questions.length);
        for (final question in quiz.questions) {
          expect(question.options.toSet().length, question.options.length);
          expect(question.correctIndex, inInclusiveRange(0, question.options.length - 1));
          expect(question.explanation, isNotEmpty);
        }
      }
    }
  });

  test('progresso inicial não inventa conclusão de módulos', () async {
    final content = MemoryContentRepository(studentRepository: MemoryStudentRepository());
    final trails = await content.getTrails();
    for (final trail in trails) {
      expect(trail.modulesDone, 0);
      expect(trail.modules.skip(1).every((m) => m.status == ModuleStatus.locked), isTrue);
    }
    expect(trails.first.modules.first.status, ModuleStatus.current);
    expect(trails.firstWhere((t) => t.id == 'clp-automacao').unlocked, isFalse);
  });

  test('aprovação libera o próximo módulo e tentativa pior preserva o melhor resultado', () async {
    final student = MemoryStudentRepository();
    final content = MemoryContentRepository(studentRepository: student);
    final first = (await content.getTrails()).first.modules.first;
    final quiz = await content.getQuiz(first.quizId!);
    await student.submitQuiz(quiz, answersFor(quiz, correct: false));
    expect((await content.getTrails()).first.modules[1].status, ModuleStatus.locked);
    await student.submitQuiz(quiz, answersFor(quiz));
    var trail = (await content.getTrails()).first;
    expect(trail.modules.first.status, ModuleStatus.done);
    expect(trail.modules.first.stars, 3);
    expect(trail.modules[1].status, ModuleStatus.current);
    await student.submitQuiz(quiz, answersFor(quiz, correct: false));
    trail = (await content.getTrails()).first;
    expect(trail.modules.first.stars, 3);
  });

  test('70% aprova e respostas faltantes contam como erro', () async {
    final student = MemoryStudentRepository();
    final quiz = Quiz(
      id: 'threshold',
      title: 'Limite',
      topic: 'Teste',
      rewardXp: 0,
      questions: [
        for (var i = 0; i < 10; i++)
          Question(id: 't-$i', topic: 'Teste', prompt: 'Teste $i',
            options: const ['Certa', 'Errada'], correctIndex: 0, explanation: 'Teste'),
      ],
    );
    await student.submitQuiz(quiz, answersFor(quiz).take(6).toList());
    expect(student.bestQuizScores[quiz.id], 0.6);
    await student.submitQuiz(quiz, answersFor(quiz).take(7).toList());
    expect(student.bestQuizScores[quiz.id], 0.7);
  });

  test('CLP exige todos os módulos e a prova final de Eletrônica Digital', () async {
    final student = MemoryStudentRepository();
    final content = MemoryContentRepository(studentRepository: student);
    var digital = (await content.getTrails()).firstWhere((t) => t.id == 'eletronica-digital');
    for (final module in digital.modules.where((m) => !m.isFinalExam)) {
      final quiz = await content.getQuiz(module.quizId!);
      await student.submitQuiz(quiz, answersFor(quiz));
    }
    expect((await content.getTrails()).firstWhere((t) => t.id == 'clp-automacao').unlocked, isFalse);
    digital = (await content.getTrails()).firstWhere((t) => t.id == 'eletronica-digital');
    expect(digital.modules.last.status, ModuleStatus.current);
    final exam = await content.getQuiz(digital.modules.last.quizId!);
    await student.submitQuiz(exam, answersFor(exam));
    final clp = (await content.getTrails()).firstWhere((t) => t.id == 'clp-automacao');
    expect(clp.unlocked, isTrue);
    expect(clp.modules.first.status, ModuleStatus.current);
    expect(clp.modules[1].status, ModuleStatus.locked);
  });

  test('progresso sobrevive a reabertura e reset bloqueia novamente', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.open();
    final student = store.studentRepository();
    final content = store.contentRepository(students: student);
    final quiz = await content.getQuiz((await content.getTrails()).first.modules.first.quizId!);
    await student.submitQuiz(quiz, answersFor(quiz));
    final reopened = await LocalStore.open();
    final restored = reopened.studentRepository();
    final restoredContent = reopened.contentRepository(students: restored);
    expect((await restoredContent.getTrails()).first.modules.first.status, ModuleStatus.done);
    await restored.resetProgress();
    final reset = await LocalStore.open();
    final resetContent = reset.contentRepository(students: reset.studentRepository());
    expect((await resetContent.getTrails()).first.modules.first.status, ModuleStatus.current);
    expect((await resetContent.getTrails()).firstWhere((t) => t.id == 'clp-automacao').unlocked, isFalse);
  });
}
