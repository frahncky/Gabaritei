import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/theme.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/models/gamification.dart';
import 'package:gabaritei/domain/models/quiz_result.dart';
import 'package:gabaritei/domain/rules/xp_rules.dart';
import 'package:gabaritei/features/quiz/result_screen.dart';
import 'package:gabaritei/shared/effects/confetti.dart';

/// XP de partida sem subir de nível: Craque I vai de 1.300 a 1.599.
const _steady = 1300;

/// Afiado II (820) → passa de 1.050 e vira Afiado III, sem trocar de nível.
const _sublevelUp = 1000;

/// Afiado III (1.050) → passa de 1.300 e vira Craque I.
const _tierUp = 1250;

const _medal = Medal(
  id: 'mestre-teste',
  name: 'Mestre de Teste',
  description: 'Acertou tudo no desafio de teste',
  icon: MedalIcon.ohm,
);

QuizResult _result({
  required int correct,
  int total = 5,
  int xpBefore = _steady,
  List<Medal> medals = const [],
}) {
  final questions = [
    for (var i = 0; i < total; i++)
      Question(
        id: 'r-$i',
        topic: 'Tópico $i',
        prompt: 'Pergunta $i',
        options: const ['certa', 'errada'],
        correctIndex: 0,
        explanation: 'Explicação da pergunta $i.',
      ),
  ];
  final answers = [
    for (var i = 0; i < total; i++)
      AnswerRecord(
        questionId: 'r-$i',
        selectedIndex: i < correct ? 0 : 1,
        correct: i < correct,
      ),
  ];
  final xp = XpRules.score(answers, completionReward: 20);
  return QuizResult(
    quiz: Quiz(
      id: 'q-teste',
      title: 'Teste',
      topic: 'Teste',
      questions: questions,
      rewardXp: 20,
    ),
    answers: answers,
    xp: xp,
    xpBefore: xpBefore,
    xpAfter: xpBefore + xp.total,
    streakAfter: 3,
    newMedals: medals,
  );
}

/// Registra as vibrações pedidas ao sistema (HapticFeedback).
List<String> _recordHaptics(WidgetTester tester) {
  final log = <String>[];
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      log.add(
          (call.arguments as String).replaceFirst('HapticFeedbackType.', ''));
    }
    return null;
  });
  addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null));
  return log;
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void _reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

Future<void> _pumpResult(
  WidgetTester tester,
  QuizResult result, {
  Size size = const Size(400, 860),
}) async {
  _setSize(tester, size);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.dark(),
    home: ResultScreen(result: result),
  ));
}

/// Pintor do anel de acertos (classe privada da tela): lido pelos campos
/// públicos para saber se o halo e o clarão foram ligados.
dynamic _ringPainter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((p) => p.painter)
    .firstWhere((p) => p.runtimeType.toString() == '_RingPainter');

void main() {
  group('título por faixa de desempenho', () {
    for (final (correct, total, title) in const [
      (5, 5, 'Gabaritou!'),
      (4, 5, 'Mandou bem!'),
      (7, 10, 'Mandou bem!'), // 70% exato já é "foi bem"
      (6, 10, 'Bom treino!'),
      (4, 10, 'Bom treino!'), // 40% exato
      (3, 10, 'Bora revisar?'),
      (1, 5, 'Bora revisar?'),
      (0, 0, 'Bora revisar?'), // desafio sem respostas
    ]) {
      testWidgets('$correct de $total acertos mostra "$title" e assenta',
          (tester) async {
        _recordHaptics(tester);
        await _pumpResult(tester, _result(correct: correct, total: total));
        await tester.pumpAndSettle();

        expect(find.text(title), findsOneWidget);
        expect(find.text('$correct/$total'), findsOneWidget);
        expect(find.text('$correct de $total acertos'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('festa na medida do desempenho', () {
    testWidgets(
        'gabarito solta confete e faíscas, acende halo e clarão e '
        'vibra médio', (tester) async {
      final haptics = _recordHaptics(tester);
      await _pumpResult(tester, _result(correct: 5));
      await tester.pump();
      expect(find.byType(ConfettiField), findsOneWidget);
      final ring = _ringPainter(tester);
      expect(ring.glow, isNotNull);
      expect(ring.flash, isNotNull);
      expect(ring.color, AppColors.amber);

      await tester.pumpAndSettle();
      expect(haptics, ['mediumImpact']);
      expect(find.text('+100 XP'), findsOneWidget);
    });

    testWidgets('70% ou mais acende o halo, vibra leve e não solta confete',
        (tester) async {
      final haptics = _recordHaptics(tester);
      await _pumpResult(tester, _result(correct: 4));
      await tester.pump();
      expect(find.byType(ConfettiField), findsNothing);
      final ring = _ringPainter(tester);
      expect(ring.glow, isNotNull);
      expect(ring.flash, isNull);
      expect(ring.color, AppColors.amber);

      await tester.pumpAndSettle();
      expect(haptics, ['lightImpact']);
    });

    for (final correct in [3, 1]) {
      testWidgets('$correct de 5 entra sóbrio: sem confete, halo nem vibração',
          (tester) async {
        final haptics = _recordHaptics(tester);
        await _pumpResult(tester, _result(correct: correct));
        await tester.pump();
        expect(find.byType(ConfettiField), findsNothing);
        final ring = _ringPainter(tester);
        expect(ring.glow, isNull);
        expect(ring.flash, isNull);
        expect(ring.color, AppColors.progress);

        await tester.pumpAndSettle();
        expect(haptics, isEmpty);
        expect(find.text('Para revisar'), findsOneWidget);
        expect(find.text('Tópico 4'), findsOneWidget);
      });
    }
  });

  group('nível e medalha novos', () {
    testWidgets(
        'subir de subnível mostra "Subiu de nível" e vibra forte com '
        'confete das laterais', (tester) async {
      final haptics = _recordHaptics(tester);
      // 3 de 5: sem halo, então a única festa é a do nível.
      await _pumpResult(tester, _result(correct: 3, xpBefore: _sublevelUp));
      await tester.pump();
      expect(find.byType(ConfettiField), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Subiu de nível'), findsOneWidget);
      expect(find.text('Novo nível!'), findsNothing);
      expect(find.text('Afiado III'), findsOneWidget);
      expect(haptics, ['heavyImpact']);
    });

    testWidgets('chegar a um nível novo mostra "Novo nível!"', (tester) async {
      _recordHaptics(tester);
      await _pumpResult(tester, _result(correct: 3, xpBefore: _tierUp));
      await tester.pumpAndSettle();
      expect(find.text('Novo nível!'), findsOneWidget);
      expect(find.text('Subiu de nível'), findsNothing);
      expect(find.text('Craque I'), findsOneWidget);
    });

    testWidgets('gabarito com nível novo vibra médio no anel e forte no nível',
        (tester) async {
      final haptics = _recordHaptics(tester);
      await _pumpResult(tester, _result(correct: 5, xpBefore: _tierUp));
      await tester.pumpAndSettle();
      expect(haptics, ['mediumImpact', 'heavyImpact']);
    });

    testWidgets('medalha nova aparece com nome e descrição e vibra forte',
        (tester) async {
      final haptics = _recordHaptics(tester);
      await _pumpResult(tester, _result(correct: 3, medals: const [_medal]));
      await tester.pump();
      // Sem nível novo, o confete das laterais sai na medalha.
      expect(find.byType(ConfettiField), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Nova medalha'), findsOneWidget);
      expect(find.text('Mestre de Teste'), findsOneWidget);
      expect(find.text('Acertou tudo no desafio de teste'), findsOneWidget);
      expect(haptics, ['heavyImpact']);
    });

    testWidgets('nível e medalha juntos: forte no nível, médio na medalha',
        (tester) async {
      final haptics = _recordHaptics(tester);
      await _pumpResult(
        tester,
        _result(correct: 3, xpBefore: _sublevelUp, medals: const [_medal]),
      );
      await tester.pumpAndSettle();
      expect(find.text('Subiu de nível'), findsOneWidget);
      expect(find.text('Nova medalha'), findsOneWidget);
      expect(haptics, ['heavyImpact', 'mediumImpact']);
    });
  });

  group('controle do aluno sobre a animação', () {
    testWidgets('tocar na lista pula para o estado final', (tester) async {
      _recordHaptics(tester);
      await _pumpResult(tester, _result(correct: 5, xpBefore: _tierUp));
      await tester.pump(const Duration(milliseconds: 300));
      // A contagem do XP ainda não começou.
      expect(find.text('+0 XP'), findsOneWidget);

      await tester.tap(find.text('Gabaritou!'));
      await tester.pump();
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('Novo nível!'), findsOneWidget);
      expect(find.text('1.350 XP'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'com menos movimento, o primeiro quadro já é o estado final, '
        'sem confete e com uma vibração só', (tester) async {
      final haptics = _recordHaptics(tester);
      _reduceMotion(tester);
      await _pumpResult(
        tester,
        _result(correct: 5, xpBefore: _tierUp, medals: const [_medal]),
      );

      expect(find.text('Gabaritou!'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('Novo nível!'), findsOneWidget);
      expect(find.text('Mestre de Teste'), findsOneWidget);
      expect(find.text('1.350 XP'), findsOneWidget);
      expect(find.byType(ConfettiField), findsNothing);
      expect(haptics, ['heavyImpact']);

      await tester.pumpAndSettle();
      expect(haptics, ['heavyImpact']);
    });

    testWidgets('com menos movimento e nota baixa, não vibra', (tester) async {
      final haptics = _recordHaptics(tester);
      _reduceMotion(tester);
      await _pumpResult(tester, _result(correct: 1));
      expect(find.text('Bora revisar?'), findsOneWidget);
      expect(find.text('1/5'), findsOneWidget);
      expect(haptics, isEmpty);
    });

    testWidgets('"Continuar" fecha a tela logo no início da festa',
        (tester) async {
      _recordHaptics(tester);
      _setSize(tester, const Size(400, 860));
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ResultScreen(
                      result: _result(correct: 5, xpBefore: _tierUp),
                    ),
                  ),
                ),
                child: const Text('abrir resultado'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('abrir resultado'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(ResultScreen), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.byType(ResultScreen), findsNothing);
      expect(find.text('abrir resultado'), findsOneWidget);
    });
  });

  testWidgets('resultado completo cabe em 360 × 780 sem overflow',
      (tester) async {
    _recordHaptics(tester);
    await _pumpResult(
      tester,
      _result(
        correct: 2,
        total: 10,
        xpBefore: _sublevelUp,
        medals: const [_medal, _medal],
      ),
      size: const Size(360, 780),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Continuar'), findsOneWidget);
  });
}
