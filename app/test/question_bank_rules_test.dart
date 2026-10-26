import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/memory/memory_repositories.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/rules/question_bank_rules.dart';
import 'package:gabaritei/domain/services/question_generator.dart';

Question _q(String id, String prompt) => Question(
      id: id,
      topic: 'Metrologia',
      prompt: prompt,
      options: const ['a', 'b', 'c', 'd'],
      correctIndex: 0,
      explanation: 'x',
    );

void main() {
  group('QuestionBankRules.admit', () {
    test('banco vazio mantém o id', () {
      final q = _q('g-1', 'A?');
      expect(QuestionBankRules.admit(q, const []).id, 'g-1');
    });

    test('id livre mantém o id', () {
      final q = _q('g-2', 'B?');
      expect(QuestionBankRules.admit(q, [_q('g-1', 'A?')]).id, 'g-2');
    });

    test('mesmo id e mesmo conteúdo é a mesma questão', () {
      final q = _q('g-1', 'A?');
      expect(QuestionBankRules.admit(q, [_q('g-1', 'A?')]).id, 'g-1');
    });

    test('mesmo id e conteúdo diferente recebe sufixo livre', () {
      final bank = [_q('g-1', 'A?'), _q('g-1-2', 'B?')];
      final admitted = QuestionBankRules.admit(_q('g-1', 'C?'), bank);
      expect(admitted.id, 'g-1-3');
      expect(admitted.prompt, 'C?');
    });

    test('conteúdo já guardado com sufixo reaproveita o id dele', () {
      final bank = [_q('g-1', 'A?'), _q('g-1-2', 'B?')];
      expect(QuestionBankRules.admit(_q('g-1', 'B?'), bank).id, 'g-1-2');
    });

    test('qualquer campo diferente conta como outra questão', () {
      final base = _q('g-1', 'A?');
      final otherHint = Question(
        id: 'g-1',
        topic: base.topic,
        prompt: base.prompt,
        options: base.options,
        correctIndex: base.correctIndex,
        explanation: base.explanation,
        hint: 'dica',
      );
      expect(QuestionBankRules.sameContent(base, otherHint), isFalse);
      expect(QuestionBankRules.sameContent(base, _q('outro', 'A?')), isTrue);
    });
  });

  group('MemoryContentRepository.saveQuestion', () {
    test('salvar duas questões geradas com o mesmo sequence mantém as duas',
        () async {
      final repo = MemoryContentRepository();
      final first = QuestionGenerator.generate(
          topic: 'Metrologia', unit: 'Calibração', sequence: 1);
      final second = QuestionGenerator.generate(
          topic: 'CNC e manufatura', unit: 'Programação CNC', sequence: 1);
      // Força a colisão que acontece ao reabrir o painel.
      final colliding = QuestionBankRules.withId(second, first.id);

      await repo.saveQuestion(first);
      final saved = await repo.saveQuestion(colliding);

      final bank = await repo.getCreatedQuestions();
      expect(bank, hasLength(2));
      expect(saved.id, isNot(first.id));
      expect(bank.map((q) => q.prompt), [first.prompt, second.prompt]);
    });

    test('salvar a mesma questão duas vezes não duplica', () async {
      var writes = 0;
      final repo = MemoryContentRepository(onChanged: (_) => writes++);
      final q = QuestionGenerator.generate(topic: 'CLP', sequence: 1);
      await repo.saveQuestion(q);
      await repo.saveQuestion(q);
      expect(await repo.getCreatedQuestions(), hasLength(1));
      expect(writes, 1);
    });
  });
}
