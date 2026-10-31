// Gera screenshots das principais telas em build/screenshots/.
//
//   flutter test tool/screenshots_test.dart              (todas)
//   flutter test tool/screenshots_test.dart --name quiz  (só um grupo)
//
// Os agentes de design e animação olham estas imagens antes e depois de
// mudar uma tela. Fica fora de test/ para não rodar na suíte normal.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/quiz_result.dart';
import 'package:gabaritei/domain/rules/xp_rules.dart';
import 'package:gabaritei/features/quiz/result_screen.dart';

import 'screenshot_kit.dart';

Future<void> _enterAsStudent(WidgetTester tester) async {
  await tester.tap(find.text('Entrar como aluno'));
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, String tab) async {
  await tester.tap(find.text(tab).last);
  await tester.pumpAndSettle();
}

/// Resultado de festa completa: 5 de 5 na Lei de Ohm, subindo de Afiado III
/// para Craque I (nível novo) e ganhando a medalha do desafio.
QuizResult _perfectResult() {
  const quiz = SampleContent.leiDeOhm;
  final answers = [
    for (final q in quiz.questions)
      AnswerRecord(
        questionId: q.id,
        selectedIndex: q.correctIndex,
        correct: true,
      ),
  ];
  final xp = XpRules.score(answers, completionReward: quiz.rewardXp);
  const before = 1240;
  return QuizResult(
    quiz: quiz,
    answers: answers,
    xp: xp,
    xpBefore: before,
    xpAfter: before + xp.total,
    streakAfter: 14,
    newMedals: [
      SampleContent.medals.firstWhere((m) => m.id == quiz.badgeId),
    ],
  );
}

void main() {
  screenshotTest('inicio', (tester) async {
    await pumpGabaritei(tester);
    await shoot(tester, '01_inicio');
  });

  screenshotTest('aluno', (tester) async {
    await pumpGabaritei(tester);
    await _enterAsStudent(tester);
    await shoot(tester, '02_aluno_inicio');

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    await shoot(tester, '03_aluno_inicio_rolada');

    await _openTab(tester, 'Trilhas');
    await shoot(tester, '04_trilhas');
    await _openTab(tester, 'Ranking');
    await shoot(tester, '05_ranking');
    await _openTab(tester, 'Perfil');
    await shoot(tester, '06_perfil');
  });

  screenshotTest('aluno celular pequeno', (tester) async {
    await pumpGabaritei(tester, size: smallPhone);
    await _enterAsStudent(tester);
    await shoot(tester, '02b_aluno_inicio_360');
  });

  screenshotTest('quiz e resultado', (tester) async {
    await pumpGabaritei(tester);
    await _enterAsStudent(tester);
    await scrollToCenter(tester, find.text('Começar'));
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    await shoot(tester, '07_quiz');

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await shoot(tester, '07b_quiz_marcada');
    await tester.tap(find.text('Confirmar'));
    // Dois quadros: o primeiro só dispara as transições de cor e borda.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await shoot(tester, '08_quiz_resposta');

    // Responde sempre a primeira alternativa até o fim.
    while (find.text('Ver resultado').evaluate().isEmpty) {
      if (find.text('Próxima').evaluate().isNotEmpty) {
        await tester.tap(find.text('Próxima'));
        await tester.pump();
      }
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
    }
    await tester.tap(find.text('Ver resultado'));
    await tester.pumpAndSettle();
    await shoot(tester, '09_resultado');

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
  });

  screenshotTest('resultado comemorativo', (tester) async {
    // O fundo com a grade vem do tema (transição de página), como no app.
    await pumpScreenshotWidget(tester, ResultScreen(result: _perfectResult()));
    await shootFrames(
      tester,
      '09c_resultado_animacao',
      frames: 16,
      step: const Duration(milliseconds: 120),
    );
    await tester.pumpAndSettle();
    await shoot(tester, '09b_resultado_gabarito');
  });

  screenshotTest('laboratorio', (tester) async {
    await pumpGabaritei(tester);
    await _enterAsStudent(tester);
    final lab = find.text('Veja a eletricidade em movimento');
    await scrollToCenter(tester, lab);
    await tester.tap(lab);
    // O laboratório anima sem parar: avança quadros em vez de pumpAndSettle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await shoot(tester, '10_laboratorio');
    await shootFrames(tester, '10b_laboratorio_animacao');
  });

  screenshotTest('professor', (tester) async {
    await pumpGabaritei(tester, size: tablet, pixelRatio: 1);
    await tester.tap(find.text('Entrar como professor'));
    await tester.pumpAndSettle();
    await shoot(tester, '11_professor');
  });

  screenshotTest('professor celular', (tester) async {
    await pumpGabaritei(tester);
    await tester.tap(find.text('Entrar como professor'));
    await tester.pumpAndSettle();
    await shoot(tester, '12_professor_celular');

    // Rascunho gerado pelo motor de questões.
    await scrollToCenter(tester, find.text('Gerar questão'));
    await tester.tap(find.text('Gerar questão'));
    await tester.pumpAndSettle();
    await scrollToCenter(tester, find.text('Adicionar ao banco'));
    await shoot(tester, '12b_professor_rascunho');
  });
}
