import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/local/local_store.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/rules/xp_rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  _visualTests();

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

  test('salvar outra questão com o mesmo id depois de reabrir mantém as duas',
      () async {
    // O painel recomeça o sequence em 1 a cada abertura; a questão gerada
    // pode repetir o id de uma salva antes (ex.: modelo revisado).
    const before = Question(
      id: 'generated-installations-simbologia-1',
      topic: 'Instalações elétricas',
      prompt: 'Versão antiga?',
      options: ['a', 'b', 'c', 'd'],
      correctIndex: 0,
      explanation: 'x',
    );
    const after = Question(
      id: 'generated-installations-simbologia-1',
      topic: 'Instalações elétricas',
      prompt: 'Versão nova?',
      options: ['a', 'b', 'c', 'd'],
      correctIndex: 1,
      explanation: 'y',
    );
    await (await LocalStore.open()).contentRepository().saveQuestion(before);
    final saved =
        await (await LocalStore.open()).contentRepository().saveQuestion(after);

    final bank = await (await LocalStore.open())
        .contentRepository()
        .getCreatedQuestions();
    expect(bank.map((q) => q.prompt), ['Versão antiga?', 'Versão nova?']);
    expect(bank.map((q) => q.id).toSet(), hasLength(2));
    expect(bank.last.id, saved.id);
  });

  test('banco salvo no formato v1 aceita nova questão sem perder as antigas',
      () async {
    SharedPreferences.setMockInitialValues({
      'gabaritei.questions.v1': jsonEncode([
        {
          'id': 'generated-ohm-1',
          'topic': 'Eletricidade básica',
          'prompt': 'Antiga?',
          'options': ['a', 'b', 'c', 'd'],
          'correctIndex': 0,
          'explanation': 'x',
          'hint': null,
          'visual': 'circuitSeries',
        },
      ]),
    });
    const fresh = Question(
      id: 'generated-ohm-1',
      topic: 'Eletricidade básica',
      prompt: 'Nova?',
      options: ['a', 'b', 'c', 'd'],
      correctIndex: 2,
      explanation: 'y',
    );
    await (await LocalStore.open()).contentRepository().saveQuestion(fresh);

    final bank = await (await LocalStore.open())
        .contentRepository()
        .getCreatedQuestions();
    expect(bank.map((q) => q.prompt), ['Antiga?', 'Nova?']);
    expect(bank.first.id, 'generated-ohm-1');
    expect(bank.first.visual, QuestionVisual.circuitSeries);
    expect(bank.last.id, 'generated-ohm-1-2');
  });
}

void _visualTests() {
  test('questão com a planta do quarto volta com o mesmo visual', () async {
    SharedPreferences.setMockInitialValues({});
    const q = Question(
      id: 'q-planta',
      topic: 'Instalações elétricas',
      prompt: 'Quantos circuitos?',
      options: ['1', '2', '3'],
      correctIndex: 2,
      explanation: 'Três números de circuito.',
      hint: 'Conte os números.',
      visual: QuestionVisual.bedroomPlan,
    );
    await (await LocalStore.open()).contentRepository().saveQuestion(q);
    final saved = (await (await LocalStore.open())
            .contentRepository()
            .getCreatedQuestions())
        .single;
    expect(saved.visual, QuestionVisual.bedroomPlan);
    expect(saved.options, q.options);
    expect(saved.correctIndex, 2);
    expect(saved.hint, q.hint);
  });

  test('questões salvas antes da planta do quarto continuam abrindo', () async {
    // Formato v1 gravado antes de existir bedroomPlan: o visual vai pelo
    // nome, então inserir um valor no meio do enum não muda o que se lê.
    SharedPreferences.setMockInitialValues({
      'gabaritei.questions.v1': jsonEncode([
        {
          'id': 'antiga-1',
          'topic': 'CLP',
          'prompt': 'Ciclo?',
          'options': ['a', 'b'],
          'correctIndex': 0,
          'explanation': 'x',
          'hint': null,
          'visual': 'processControl',
        },
        {
          'id': 'antiga-2',
          'topic': 'Instalações elétricas',
          'prompt': 'Planta?',
          'options': ['a', 'b'],
          'correctIndex': 1,
          'explanation': 'y',
          'hint': null,
          'visual': null,
        },
      ]),
    });
    final saved = await (await LocalStore.open())
        .contentRepository()
        .getCreatedQuestions();
    expect(saved.map((q) => q.visual), [QuestionVisual.processControl, null]);
  });
}
