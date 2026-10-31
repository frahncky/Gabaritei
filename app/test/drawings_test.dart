import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/theme.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/features/lab/lab_painters.dart';
import 'package:gabaritei/features/quiz/question_visual.dart';
import 'package:gabaritei/shared/drawings/circuit_symbols.dart';

void main() {
  group('cargas da corrente', () {
    test('ficam igualmente espaçadas dentro do trecho', () {
      final d = CurrentDots.offsets(100, shift: 7, spacing: 18).toList();
      expect(d.first, 7);
      expect(d.every((x) => x >= 0 && x < 100), isTrue);
      for (var i = 1; i < d.length; i++) {
        expect(d[i] - d[i - 1], closeTo(18, 1e-9));
      }
    });

    test('andar um espaçamento inteiro fecha o ciclo sem salto', () {
      final start = CurrentDots.offsets(100, shift: 0, spacing: 18).toList();
      final end = CurrentDots.offsets(100, shift: 18 * 3, spacing: 18).toList();
      expect(end, start);
    });

    test('ramo que começa depois continua a contagem do anterior', () {
      // Carga a 5 px do fim de um trecho de 41 px chega ao próximo a 13 px.
      final first = CurrentDots.offsets(41, shift: 0, spacing: 18).last;
      final next =
          CurrentDots.offsets(50, shift: 0, spacing: 18, startsAt: 41).first;
      expect(41 - first + next, closeTo(18, 1e-9));
    });
  });

  group('circuito das questões', () {
    const size = Size(296, 132);

    test('no paralelo, cada resistor fica num ramo entre os dois nós', () {
      final l = QuestionCircuitLayout(size);
      final [top, bottom] = l.nodes;
      expect(l.parallelR1.dx, top.dx);
      expect(l.parallelR1.dx, bottom.dx);
      expect(l.parallelR2.dx, l.right);
      // Ramos distintos: se estivessem no mesmo fio, seriam série.
      expect(l.parallelR2.dx - l.parallelR1.dx, greaterThan(60));
      expect(l.parallelR1.dy, allOf(greaterThan(top.dy), lessThan(bottom.dy)));
    });

    test('os fios saem do + da fonte e voltam pelo −', () {
      final l = QuestionCircuitLayout(size);
      for (final parallel in [false, true]) {
        final wires = l.wires(parallel: parallel);
        final out = wires.first.computeMetrics().first.getTangentForOffset(0)!;
        final back = wires.last.computeMetrics().first;
        final end = back.getTangentForOffset(back.length)!;
        expect(out.position.dy, lessThan(l.source.dy)); // placa longa (+)
        expect(end.position.dy, greaterThan(l.source.dy)); // placa curta (−)
      }
    });
  });

  group('gráfico do laboratório', () {
    final scale = HistoryChartScale(const Size(300, 120), limit: 3);

    test('eixo y começa no zero e vai até 1,6 vez o limite', () {
      expect(scale.yForValue(0), scale.plot.bottom);
      expect(scale.yForValue(4.8), closeTo(scale.plot.top, 1e-9));
      expect(scale.yTicks, [0, 3, closeTo(4.8, 1e-9)]);
      expect(scale.yForValue(3), lessThan(scale.yForValue(0)));
    });

    test('eixo x mostra os últimos 6 s, com o agora na ponta direita', () {
      expect(HistoryChartScale.seconds, 6);
      expect(scale.xForSecondsAgo(0), scale.plot.right);
      expect(scale.xForSecondsAgo(6), scale.plot.left);
      expect(scale.xForSecondsAgo(3), closeTo(scale.plot.center.dx, 1e-9));
    });
  });

  testWidgets('pausar o diagrama da questão para o controlador da animação',
      (tester) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20),
          child: QuestionVisualCard(visual: QuestionVisual.circuitParallel),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
        find.bySemanticsLabel(RegExp('Circuito em paralelo')), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.tap(find.text('Pausar animação'));
    await tester.pumpAndSettle();
    expect(find.text('Animar diagrama'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);

    await tester.tap(find.text('Animar diagrama'));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
    semantics.dispose();
  });

  testWidgets('código de cores não anima nem mostra o botão de pausa',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: QuestionVisualCard(visual: QuestionVisual.resistorBands),
      ),
    ));
    await tester.pump();
    expect(find.text('Pausar animação'), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
