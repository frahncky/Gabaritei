import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/services/question_generator.dart';

/// Sequências usadas nas varreduras do gerador (cobre os ciclos de 3, 4 e 5
/// itens dos bancos atuais).
final _sequences = [for (var s = 0; s <= 12; s++) s];

const _installations = 'Instalações elétricas';
const _planUnits = ['Plantas e simbologia', 'Dimensionamento', 'Luminotécnica'];

/// Valida uma questão isolada; [where] entra na mensagem de falha.
void _expectValidQuestion(Question q, String where) {
  expect(q.id, isNotEmpty, reason: where);
  expect(q.topic.trim(), isNotEmpty, reason: where);
  expect(q.prompt.trim(), isNotEmpty, reason: where);
  expect(q.explanation.trim(), isNotEmpty, reason: where);
  expect(q.options.length, greaterThanOrEqualTo(2), reason: where);
  expect(
    q.correctIndex,
    inInclusiveRange(0, q.options.length - 1),
    reason: where,
  );
  expect(q.options.every((o) => o.trim().isNotEmpty), isTrue, reason: where);
  expect(
    q.options.toSet(),
    hasLength(q.options.length),
    reason: '$where: opções repetidas ${q.options}',
  );
}

void main() {
  group('conteúdo de exemplo', () {
    test('toda questão dos desafios tem gabarito válido, tópico e opções '
        'distintas', () {
      for (final quiz in SampleContent.quizzes) {
        expect(quiz.questions, isNotEmpty, reason: quiz.id);
        for (final q in quiz.questions) {
          _expectValidQuestion(q, '${quiz.id}/${q.id}');
        }
      }
    });

    test('ids de desafios e de questões são únicos', () {
      final quizIds = SampleContent.quizzes.map((q) => q.id).toList();
      expect(quizIds.toSet(), hasLength(quizIds.length));
      final questionIds = [
        for (final quiz in SampleContent.quizzes)
          for (final q in quiz.questions) q.id,
      ];
      expect(questionIds.toSet(), hasLength(questionIds.length));
    });

    test('módulos e missões só apontam para desafios que existem', () {
      final quizIds = SampleContent.quizzes.map((q) => q.id).toSet();
      for (final trail in SampleContent.trails) {
        for (final m in trail.modules) {
          if (m.quizId != null) {
            expect(quizIds, contains(m.quizId), reason: m.id);
          }
        }
      }
      for (final m in SampleContent.dailyMissions) {
        if (m.quizId != null) {
          expect(quizIds, contains(m.quizId), reason: m.id);
        }
      }
    });

    test('medalhas dos desafios existem e os ids de medalha são únicos', () {
      final medalIds = SampleContent.medals.map((m) => m.id).toList();
      expect(medalIds.toSet(), hasLength(medalIds.length));
      for (final quiz in SampleContent.quizzes) {
        if (quiz.badgeId != null) {
          expect(medalIds, contains(quiz.badgeId), reason: quiz.id);
        }
      }
    });

    test('ids de trilhas e de módulos são únicos', () {
      final trailIds = SampleContent.trails.map((t) => t.id).toList();
      expect(trailIds.toSet(), hasLength(trailIds.length));
      final moduleIds = [
        for (final t in SampleContent.trails)
          for (final m in t.modules) m.id,
      ];
      expect(moduleIds.toSet(), hasLength(moduleIds.length));
    });

    test('trilha bloqueada exige uma trilha que existe no catálogo', () {
      final trailIds = SampleContent.trails.map((t) => t.id).toSet();
      for (final t in SampleContent.trails) {
        if (t.requiresTrailId != null) {
          expect(trailIds, contains(t.requiresTrailId), reason: t.id);
        }
      }
    });

    test('desafio da planta do quarto tem 5 questões, todas com a planta', () {
      final quiz = SampleContent.quizzes.singleWhere(
        (q) => q.id == 'q-planta-quarto',
      );
      expect(quiz.topic, _installations);
      expect(quiz.questions, hasLength(5));
      expect(
        quiz.questions.map((q) => q.visual),
        everyElement(QuestionVisual.bedroomPlan),
      );
      expect(quiz.questions.map((q) => q.hint), everyElement(isNotNull));
    });

    test('módulo ie-1 abre sua atividade curricular de simbologia', () {
      final trail = SampleContent.trails.singleWhere(
        (t) => t.id == 'instalacoes-eletricas',
      );
      final module = trail.modules.singleWhere((m) => m.id == 'ie-1');
      expect(module.quizId, 'q-ie-1');
      expect(
        SampleContent.quizzes
            .singleWhere((q) => q.id == module.quizId)
            .questions,
        isNotEmpty,
      );
      expect(module.status, ModuleStatus.current);
      expect(trail.unlocked, isTrue);
    });
  });

  group('gerador: instalações elétricas', () {
    for (final unit in _planUnits) {
      test('"$unit" usa a planta do quarto e varia com a sequência', () {
        final questions = [
          for (final s in _sequences)
            QuestionGenerator.generate(
              topic: _installations,
              unit: unit,
              sequence: s,
            ),
        ];
        for (final q in questions) {
          expect(q.visual, QuestionVisual.bedroomPlan, reason: q.id);
          expect(q.topic, _installations);
          expect(q.prompt, startsWith('$unit: '));
          _expectValidQuestion(q, q.id);
        }
        expect(
          questions.map((q) => q.prompt).toSet().length,
          greaterThan(1),
          reason: 'enunciado não muda com a sequência',
        );
        final ids = questions.map((q) => q.id).toList();
        expect(ids.toSet(), hasLength(ids.length));
      });
    }

    test('"Comandos elétricos" não mostra a planta do quarto', () {
      for (final s in _sequences) {
        final q = QuestionGenerator.generate(
          topic: _installations,
          unit: 'Comandos elétricos',
          sequence: s,
        );
        expect(q.visual, isNot(QuestionVisual.bedroomPlan), reason: q.id);
        expect(q.visual, isNull, reason: q.id);
        _expectValidQuestion(q, q.id);
      }
    });

    test('sem assunto, percorre as questões da planta com ids únicos', () {
      final questions = [
        for (final s in _sequences)
          QuestionGenerator.generate(topic: _installations, sequence: s),
      ];
      for (final q in questions) {
        expect(q.visual, QuestionVisual.bedroomPlan);
        // O enunciado começa em maiúscula mesmo sem o assunto na frente.
        expect(q.prompt[0], q.prompt[0].toUpperCase());
        _expectValidQuestion(q, q.id);
      }
      expect(questions.map((q) => q.prompt).toSet().length, greaterThan(1));
      final ids = questions.map((q) => q.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('sequência negativa não quebra o gerador', () {
      for (final unit in [..._planUnits, 'Comandos elétricos']) {
        final q = QuestionGenerator.generate(
          topic: _installations,
          unit: unit,
          sequence: -7,
        );
        _expectValidQuestion(q, q.id);
      }
    });
  });

  group('gerador: varredura de todas as disciplinas', () {
    test('com assunto, toda unidade gera questão válida e sem opções '
        'repetidas (sequência 0 a 12)', () {
      for (final topic in QuestionGenerator.topics) {
        for (final unit in QuestionGenerator.unitsFor(topic)) {
          final ids = <String>{};
          for (final s in _sequences) {
            final q = QuestionGenerator.generate(
              topic: topic,
              unit: unit.label,
              sequence: s,
            );
            _expectValidQuestion(q, '$topic/${unit.label}/$s');
            expect(
              ids.add(q.id),
              isTrue,
              reason: 'id repetido ${q.id} em $topic/${unit.label}',
            );
          }
        }
      }
    });

    for (final topic in QuestionGenerator.topics) {
      test('sem assunto, "$topic" gera questão válida e sem opções repetidas '
          '(sequência 0 a 12)', () {
        final ids = <String>{};
        for (final s in _sequences) {
          final q = QuestionGenerator.generate(topic: topic, sequence: s);
          _expectValidQuestion(q, '$topic/$s');
          expect(ids.add(q.id), isTrue, reason: 'id repetido ${q.id}');
        }
      });
    }

    test('Lei de Ohm gerada não repete opções fora do caso de 100 Ω', () {
      for (final s in _sequences.where((s) => s % 4 != 0)) {
        final q = QuestionGenerator.generate(
          topic: 'Eletricidade básica',
          sequence: s,
        );
        _expectValidQuestion(q, 'ohm/$s');
      }
    });

    test('Lei de Ohm com 100 Ω não repete a resposta entre os distratores', () {
      final q = QuestionGenerator.generate(
        topic: 'Eletricidade básica',
        sequence: 4,
      );
      expect(q.prompt, contains('100 Ω'));
      expect(
        q.options.where((o) => o == q.options[q.correctIndex]),
        hasLength(1),
        reason: 'opções: ${q.options}',
      );
    });
  });
}
