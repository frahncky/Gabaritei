import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/theme.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/features/quiz/question_visual.dart';
import 'package:gabaritei/shared/drawings/bedroom_plan.dart';

/// Larguras da área de desenho no cartão da questão: celular de 360 dp, de
/// 400 dp e o limite do desenho.
const _widths = [296.0, 336.0, BedroomPlanLayout.maxWidth];

/// Tamanho da etiqueta medido nas capturas com as fontes do app, com folga
/// (os testes não carregam as fontes).
Size _tagSize(PlanPoint p) => Size(math.max(p.label.length * 6.0, 30), 26);

Iterable<Offset> _samples(Path path) sync* {
  for (final metric in path.computeMetrics()) {
    for (var d = 0.0; d < metric.length; d += 2) {
      yield metric.getTangentForOffset(d)!.position;
    }
    yield metric.getTangentForOffset(metric.length)!.position;
  }
}

void main() {
  test('o quarto mantém a proporção de 3,50 m por 3,00 m', () {
    for (final width in _widths) {
      final l = BedroomPlanLayout(width);
      expect(l.room.width / l.room.height, closeTo(3.5 / 3.0, 1e-9));
      expect(l.room.width, closeTo(BedroomPlanSpec.widthM * l.scale, 1e-9));
      expect(l.outer.left, greaterThanOrEqualTo(0));
      expect(l.outer.right, lessThanOrEqualTo(width));
      expect(l.height, greaterThan(l.outer.bottom));
    }
  });

  test('a planta tem 4 tomadas, 1 interruptor e os valores do enunciado', () {
    final points = BedroomPlanLayout.points;
    final tugs =
        points.where((p) => p.kind == PlanPointKind.lowOutlet).toList();
    final tues =
        points.where((p) => p.kind == PlanPointKind.highOutlet).toList();
    final switches =
        points.where((p) => p.kind == PlanPointKind.simpleSwitch).toList();

    expect(tugs, hasLength(3));
    expect(tugs.map((p) => p.label), everyElement('100 VA'));
    expect(tugs.map((p) => p.circuit), everyElement(2));
    expect(tues.single.label, '1.500 W');
    expect(tues.single.circuit, 3);
    expect(switches.single.label, 'a');
    expect(switches.single.circuit, 1);
    expect(switches.single.wall.side, WallSide.bottom);
  });

  test('o interruptor fica do lado da maçaneta, fora do giro da porta', () {
    for (final width in _widths) {
      final l = BedroomPlanLayout(width);
      final center = l.symbolCenter(BedroomPlanLayout.switchPoint);
      expect(center.dx, greaterThan(l.doorSwing.right));
      expect(center.dx - l.doorSwing.right, lessThan(0.4 * l.scale));
    }
  });

  test('os símbolos ficam dentro do quarto', () {
    for (final width in _widths) {
      final l = BedroomPlanLayout(width);
      expect(l.room.contains(l.light), isTrue);
      expect(l.light, l.room.center);
      for (final p in BedroomPlanLayout.points) {
        expect(l.room.contains(l.symbolCenter(p)), isTrue);
      }
    }
  });

  test('as etiquetas não se sobrepõem a outras, aos móveis nem à porta', () {
    for (final width in _widths) {
      final l = BedroomPlanLayout(width);
      final light = Rect.fromCircle(center: l.light, radius: l.lightRadius);
      final obstacles = [
        light,
        l.doorSwing,
        l.rect(BedroomPlanLayout.bed),
        l.rect(BedroomPlanLayout.airConditioner),
        for (final stand in BedroomPlanLayout.nightstands) l.rect(stand),
      ];
      final tags = [
        for (final p in BedroomPlanLayout.points) l.tagRect(p, _tagSize(p)),
      ];
      for (var i = 0; i < tags.length; i++) {
        expect(l.room.deflate(1).contains(tags[i].topLeft), isTrue);
        expect(l.room.deflate(1).contains(tags[i].bottomRight), isTrue);
        for (final other in [...obstacles, ...tags.skip(i + 1)]) {
          expect(tags[i].overlaps(other), isFalse,
              reason: 'etiqueta $i encosta em $other (largura $width)');
        }
      }
    }
  });

  test('os eletrodutos não passam por cima das etiquetas', () {
    for (final width in _widths) {
      final l = BedroomPlanLayout(width);
      final tags = [
        for (final p in BedroomPlanLayout.points)
          l.tagRect(p, _tagSize(p)).inflate(2),
      ];
      final paths = [l.feed, ...BedroomPlanLayout.points.map(l.conduitTo)];
      for (final path in paths) {
        for (final point in _samples(path)) {
          for (final tag in tags) {
            expect(tag.contains(point), isFalse,
                reason: '$point dentro de $tag (largura $width)');
          }
        }
      }
    }
  });

  test('o eletroduto do QD vem de fora e entra pela parede de baixo', () {
    final l = BedroomPlanLayout(296);
    expect(l.feedStart.dy, greaterThan(l.outer.bottom));
    expect(l.feedStart.dx, greaterThan(l.doorGap.right));
    final end = _samples(l.feed).last;
    expect((end - l.light).distance, lessThan(1));
  });

  test('cada ramal sai do ponto de luz e termina no seu ponto', () {
    final l = BedroomPlanLayout(336);
    for (final p in BedroomPlanLayout.points) {
      final samples = _samples(l.conduitTo(p)).toList();
      expect((samples.first - l.light).distance, lessThan(1));
      expect((samples.last - l.symbolCenter(p)).distance, lessThan(2.5));
    }
  });

  test('a descrição para leitor de tela traz medidas, potências e circuitos',
      () {
    final label = BedroomPlanSpec.semanticsLabel;
    for (final text in [
      '3,50 m',
      '3,00 m',
      '0,80 m',
      '160 VA, circuito 1, comando a',
      'interruptor simples a, do circuito 1',
      '3 tomadas de uso geral baixas, de 100 VA cada, no circuito 2',
      'uso específico alta, de 1.500 W, no circuito 3',
      'quadro de distribuição',
    ]) {
      expect(label, contains(text));
    }
    expect(label, isNot(contains('NBR')));
  });

  testWidgets('cartão mostra a planta do quarto e pausa a animação',
      (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: QuestionVisualCard(visual: QuestionVisual.bedroomPlan),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(BedroomPlan), findsOneWidget);
    expect(
        find.bySemanticsLabel(BedroomPlanSpec.semanticsLabel), findsOneWidget);
    expect(find.text('TUG baixa (uso geral)'), findsOneWidget);
    expect(find.text('TUE alta (uso específico)'), findsOneWidget);

    await tester.tap(find.text('Pausar animação'));
    await tester.pump();
    expect(find.text('Animar diagrama'), findsOneWidget);
    semantics.dispose();
  });
}
