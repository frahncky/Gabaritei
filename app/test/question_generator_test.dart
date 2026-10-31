import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/services/question_generator.dart';
import 'package:gabaritei/domain/models/question_figure.dart';

void main() {
  test('figuras geradas preservam os valores de cada variação de Ohm', () {
    const resistances = [100, 220, 470, 1000];
    for (var i = 0; i < 16; i++) {
      final q = QuestionGenerator.generate(topic: 'Eletricidade básica', sequence: i);
      expect(q.figure!.kind, FigureKind.seriesCircuit);
      expect(q.figure!.sourceLabel, '12 V');
      expect(q.figure!.elements.single.label, 'R = ${resistances[i % 4]} Ω');
      expect(q.prompt, contains('${resistances[i % 4]} Ω'));
      expect(QuestionFigure.fromJson(q.figure!.toJson()).toJson(), q.figure!.toJson());
    }
  });

  test('figura gerada de paralelo mantém ramos e valores sem inventar tensão', () {
    final q = QuestionGenerator.generate(topic: 'Circuitos CC', sequence: 1);
    expect(q.figure!.kind, FigureKind.parallelCircuit);
    expect(q.figure!.elements.map((e) => e.label), ['R1 = 100 Ω', 'R2 = 100 Ω']);
    expect(q.figure!.sourceLabel, 'Fonte');
    expect(q.figure!.description, contains('não foi especificada'));
  });

  test('gerador de Ohm não repete a alternativa correta nos distratores', () {
    for (var sequence = 0; sequence < 16; sequence++) {
      final q = QuestionGenerator.generate(topic: 'Eletricidade básica', sequence: sequence);
      expect(q.options.toSet().length, 4);
    }
    final q = QuestionGenerator.generate(topic: 'Eletricidade básica', sequence: 0);
    expect(q.options[q.correctIndex], '120 mA');
  });

  test('gera questão válida para todas as áreas do catálogo', () {
    for (final topic in QuestionGenerator.topics) {
      final question = QuestionGenerator.generate(topic: topic, sequence: 1);

      expect(question.topic, topic);
      expect(question.prompt, isNotEmpty);
      expect(question.options.length, greaterThanOrEqualTo(4));
      expect(question.correctIndex,
          inInclusiveRange(0, question.options.length - 1));
      expect(question.explanation, isNotEmpty);
      // Sem desenho que combine, a questão fica sem visual e não pode
      // citar uma ilustração.
      if (question.visual == null) {
        expect(question.prompt, isNot(contains('ilustrad')), reason: topic);
      }
    }
  });

  test('questões por assunto só mostram desenho ligado à disciplina', () {
    QuestionVisual? visualOf(String topic) {
      final unit = QuestionGenerator.unitsFor(topic).first.label;
      return QuestionGenerator.generate(topic: topic, unit: unit, sequence: 1)
          .visual;
    }

    for (final topic in const [
      'Metrologia',
      'CNC e manufatura',
      'Circuitos CA',
      'Eletrônica digital',
      'Eletrônica analógica',
      'Robótica',
      'Programação',
      'Redes industriais',
    ]) {
      expect(visualOf(topic), isNull, reason: topic);
    }
    expect(visualOf('Segurança e normas'), QuestionVisual.electricalPlan);
    expect(visualOf('Desenho técnico e CAD'), QuestionVisual.electricalPlan);
    expect(visualOf('CLP'), QuestionVisual.processControl);
    expect(visualOf('Supervisórios e controle de processos'),
        QuestionVisual.processControl);
    expect(visualOf('Instalações elétricas'), QuestionVisual.bedroomPlan);
  });

  test('nenhuma questão por assunto usa o circuito em série como padrão', () {
    for (final topic in QuestionGenerator.topics) {
      for (final unit in QuestionGenerator.unitsFor(topic)) {
        final q = QuestionGenerator.generate(
            topic: topic, unit: unit.label, sequence: 1);
        expect(q.visual, isNot(QuestionVisual.circuitSeries),
            reason: '$topic / ${unit.label}');
      }
    }
  });

  test('varia os valores das questões de eletricidade básica', () {
    final first = QuestionGenerator.generate(
      topic: 'Eletricidade básica',
      sequence: 1,
    );
    final second = QuestionGenerator.generate(
      topic: 'Eletricidade básica',
      sequence: 2,
    );

    expect(first.prompt, isNot(second.prompt));
    expect(first.id, isNot(second.id));
  });

  test('todos os cursos têm currículo e geram questões válidas', () {
    for (final course in TechnicalCourse.values) {
      final topics = QuestionGenerator.topicsFor(course);
      expect(topics, isNotEmpty, reason: course.label);

      for (final topic in topics) {
        expect(QuestionGenerator.topics, contains(topic));
        final units = QuestionGenerator.unitsFor(topic);
        expect(units, isNotEmpty, reason: topic);
        expect(
          QuestionGenerator.generate(topic: topic, sequence: 2).topic,
          topic,
        );
        for (final unit in units) {
          final question = QuestionGenerator.generate(
            topic: topic,
            unit: unit.label,
            sequence: 3,
          );
          expect(question.topic, topic);
          expect(question.prompt, contains(unit.label));
          expect(question.options, hasLength(4));
        }
      }
    }
  });
}
