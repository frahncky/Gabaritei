import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/services/question_generator.dart';
import 'package:gabaritei/features/quiz/quiz_screen.dart';
import 'package:gabaritei/features/quiz/result_screen.dart';
import 'package:gabaritei/shared/drawings/bedroom_plan.dart';
import 'package:gabaritei/shared/format.dart';

Future<void> _enterAsStudent(
  WidgetTester tester, {
  Size size = const Size(400, 860),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // A tela de resultado vibra; o canal da plataforma fica mudo no teste.
  tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));
  await tester
      .pumpWidget(GabariteiApp(dependencies: AppDependencies.inMemory()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Entrar como aluno'));
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  ));
  await tester.pumpAndSettle();
}

/// Rola a lista visível até [finder] ficar inteiro na tela.
Future<void> _scrollTo(WidgetTester tester, Finder finder,
    {double delta = 200}) async {
  await tester.scrollUntilVisible(finder, delta,
      scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

/// Os diagramas das questões animam sem parar: avança quadros em vez de
/// esperar assentar.
Future<void> _pumpQuiz(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Abre a trilha de Instalações e começa o desafio da planta do quarto.
Future<void> _openBedroomQuiz(WidgetTester tester) async {
  await _openTab(tester, 'Trilhas');
  await tester.tap(find.text('Instalações Elétricas'));
  await tester.pumpAndSettle();
  await _scrollTo(tester, find.text('Começar'));
  await tester.tap(find.text('Começar'));
  await _pumpQuiz(tester);
}

/// Toca numa alternativa do desafio, rolando até ela.
Future<void> _pick(WidgetTester tester, Finder option) async {
  await tester.scrollUntilVisible(option, 150,
      scrollable: find
          .descendant(
              of: find.byType(QuizScreen), matching: find.byType(Scrollable))
          .first);
  await tester.ensureVisible(option);
  await tester.pump();
  await tester.tap(option);
  await tester.pump();
}

/// Algum `Semantics` acima de [finder] marca a propriedade pedida.
bool _hasSemantics(
  WidgetTester tester,
  Finder finder,
  bool Function(SemanticsProperties p) test,
) =>
    tester
        .widgetList<Semantics>(
            find.ancestor(of: finder, matching: find.byType(Semantics)))
        .any((s) => test(s.properties));

Finder _iconLabeled(String label) =>
    find.byWidgetPredicate((w) => w is Icon && w.semanticLabel == label);

Finder _inAppBar(String text) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(text));

const _weekdayNames = [
  'segunda',
  'terça',
  'quarta',
  'quinta',
  'sexta',
  'sábado',
  'domingo',
];

void main() {
  group('Início', () {
    testWidgets('"Continue de onde parou" abre o desafio do módulo atual',
        (tester) async {
      await _enterAsStudent(tester);
      expect(find.text('Continue de onde parou'), findsOneWidget);
      expect(find.text('Eletricidade Básica · Módulo 4'), findsOneWidget);
      expect(find.text('2 de 4 lições'), findsOneWidget);

      await _scrollTo(tester, find.text('Continuar lição'));
      await tester.tap(find.text('Continuar lição'));
      await _pumpQuiz(tester);
      expect(find.byType(QuizScreen), findsOneWidget);
      expect(_inAppBar('Associação de resistores'), findsOneWidget);

      // Sair sem responder volta direto para o início.
      await tester.tap(find.byTooltip('Sair do desafio'));
      await tester.pumpAndSettle();
      expect(find.byType(QuizScreen), findsNothing);
      expect(find.text('Olá, Ana'), findsOneWidget);
    });

    testWidgets('Laboratórios é uma seção com os dois laboratórios',
        (tester) async {
      await _enterAsStudent(tester);
      final header = find.text('Laboratórios');
      await _scrollTo(tester, find.text('Sensor, CLP e válvula'));
      expect(_hasSemantics(tester, header, (p) => p.header == true), isTrue);
      expect(
          find.text('Mexa nos valores e veja o que acontece.'), findsOneWidget);

      final headerY = tester.getTopLeft(header).dy;
      expect(
          tester.getTopLeft(find.text('Veja a eletricidade em movimento')).dy,
          greaterThan(headerY));
      expect(tester.getTopLeft(find.text('Sensor, CLP e válvula')).dy,
          greaterThan(headerY));
    });

    testWidgets('tocar no avatar abre o Perfil', (tester) async {
      await _enterAsStudent(tester);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );

      // Iniciais da Ana Souza no avatar da saudação.
      await tester.tap(find.text('AS'));
      await tester.pumpAndSettle();
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        3,
      );
    });

    testWidgets(
      'leitor de tela encontra o avatar como botão "Abrir perfil" com toque',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await _enterAsStudent(tester);
        final node = tester.getSemantics(find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Abrir perfil'));
        expect(node.label, 'Abrir perfil');
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        semantics.dispose();
      },
    );
  });

  group('Trilhas', () {
    testWidgets('a grade troca a trilha e marca a escolhida', (tester) async {
      await _enterAsStudent(tester);
      await _openTab(tester, 'Trilhas');
      expect(find.text('4. Associação de resistores'), findsOneWidget);

      final option = find.text('Instalações Elétricas');
      expect(option, findsOneWidget);
      await tester.tap(option);
      await tester.pumpAndSettle();

      // O nome aparece na grade e no título da trilha.
      expect(find.text('Instalações Elétricas'), findsNWidgets(2));
      expect(find.text('1. Simbologia e diagramas'), findsOneWidget);
      expect(find.text('4. Associação de resistores'), findsNothing);
      expect(
        _hasSemantics(tester, find.text('Instalações Elétricas').first,
            (p) => p.selected == true),
        isTrue,
      );
      expect(
        _hasSemantics(tester, find.text('Eletricidade Básica'),
            (p) => p.selected == true),
        isFalse,
      );
    });

    testWidgets('módulo ie-1 abre a planta do quarto pelo botão "Começar"',
        (tester) async {
      await _enterAsStudent(tester);
      await _openBedroomQuiz(tester);
      expect(_inAppBar('Planta elétrica do quarto'), findsOneWidget);
      expect(find.byType(BedroomPlan), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('trilha bloqueada mostra o cadeado e o requisito',
        (tester) async {
      await _enterAsStudent(tester);
      await _openTab(tester, 'Trilhas');
      expect(find.text('Bloqueada'), findsOneWidget);

      await tester.tap(find.text('CLP e Automação'));
      await tester.pumpAndSettle();
      expect(find.text('CLP e Automação'), findsNWidgets(2));
      expect(
          find.text(
              'Conclua a trilha Eletricidade Básica para desbloquear esta.'),
          findsOneWidget);
      expect(find.textContaining('Bloqueado · '), findsOneWidget);
      // Módulo bloqueado não tem botão de começar.
      expect(find.text('Começar'), findsNothing);
    });

    testWidgets('o mapa do curso abre como sanfona e troca de curso',
        (tester) async {
      await _enterAsStudent(tester);
      await _openTab(tester, 'Trilhas');

      String summaryOf(TechnicalCourse c) {
        final topics = QuestionGenerator.topicsFor(c);
        final units = topics.fold<int>(
            0, (sum, t) => sum + QuestionGenerator.unitsFor(t).length);
        return '${topics.length} disciplinas · $units unidades';
      }

      final tile = find.text('Ver disciplinas e unidades');
      await _scrollTo(tester, tile);
      expect(find.text(summaryOf(TechnicalCourse.electronics)), findsOneWidget);
      // Fechada: as disciplinas não aparecem.
      expect(find.text('Telecomunicações'), findsNothing);

      await tester.tap(tile);
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.text('Circuitos CA'));
      expect(find.text('Telecomunicações', skipOffstage: false), findsWidgets);

      // Cada disciplina abre as unidades logo abaixo e fecha no 2º toque.
      const objective = 'calcula grandezas usando V = R · I';
      final discipline = find.text('Eletricidade básica');
      expect(find.text(objective), findsNothing);
      await _scrollTo(tester, discipline);
      await tester.tap(discipline);
      await tester.pumpAndSettle();
      expect(find.text(objective), findsOneWidget);
      expect(
          _hasSemantics(tester, discipline, (p) => p.expanded == true), isTrue);
      await tester.tap(discipline);
      await tester.pumpAndSettle();
      expect(find.text(objective), findsNothing);

      await _scrollTo(tester, find.text('Eletrotécnica'), delta: -200);
      await tester.tap(find.text('Eletrotécnica'));
      await tester.pumpAndSettle();
      expect(find.text(summaryOf(TechnicalCourse.electrotechnics)),
          findsOneWidget);
    });
  });

  group('Perfil', () {
    testWidgets('calendário de segunda a domingo, com legenda e o dia de hoje',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await _enterAsStudent(tester);
      await _openTab(tester, 'Perfil');
      await _scrollTo(tester, find.text('Estudou'));

      const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      for (final day in days) {
        expect(find.text(day), findsOneWidget, reason: day);
      }
      for (var i = 1; i < days.length; i++) {
        expect(tester.getTopLeft(find.text(days[i - 1])).dx,
            lessThan(tester.getTopLeft(find.text(days[i])).dx));
      }
      expect(find.text('Estudou'), findsOneWidget);
      expect(find.text('Hoje'), findsOneWidget);

      // O perfil usa o relógio do aparelho; a Ana estudou até ontem.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final todayLabel = 'Hoje, ${_weekdayNames[today.weekday - 1]}, '
          '${formatShortDate(today)}: ainda não estudou';
      final yesterdayLabel = '${_weekdayNames[yesterday.weekday - 1]}, '
          '${formatShortDate(yesterday)}: estudou';
      // Os dias são lidos juntos, no nó do calendário.
      expect(find.bySemanticsLabel(RegExp(RegExp.escape(todayLabel))),
          findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(RegExp.escape(yesterdayLabel))),
          findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Hoje, ')), findsOneWidget);
      expect(find.text('Estude hoje para manter a sequência.'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('medalhas conquistadas vêm antes das bloqueadas',
        (tester) async {
      await _enterAsStudent(tester);
      await _openTab(tester, 'Perfil');
      await _scrollTo(tester, find.text('2 de ${SampleContent.medals.length}'));
      expect(find.text('2 de ${SampleContent.medals.length}'), findsOneWidget);
      await _scrollTo(tester, find.text('Olho de Resistor'));

      expect(find.text('Conquistada'), findsNWidgets(2));
      final earnedY = [
        tester.getTopLeft(find.text('Potência Total')).dy,
        tester.getTopLeft(find.text('7 dias seguidos')).dy,
      ];
      // "Mestre de Ohm" é a primeira do catálogo, mas não foi conquistada.
      final lockedY = tester.getTopLeft(find.text('Mestre de Ohm')).dy;
      for (final y in earnedY) {
        expect(y, lessThan(lockedY));
      }
    });
  });

  group('Ranking', () {
    testWidgets(
        'Semana diz quanto falta para a zona de subida e Mês diz a '
        'posição no mês', (tester) async {
      await _enterAsStudent(tester);
      await _openTab(tester, 'Ranking');
      // Ana tem 515 XP na semana; o 3º lugar tem 580: 580 − 515 + 1 = 66.
      expect(find.textContaining('Faltam 66 XP'), findsOneWidget);
      expect(find.textContaining('Os 3 primeiros sobem'), findsOneWidget);

      await tester.tap(find.text('Mês'));
      await tester.pumpAndSettle();
      expect(find.textContaining('no mês.'), findsOneWidget);
      expect(find.textContaining('Faltam'), findsNothing);
      expect(find.textContaining('primeiros da semana'), findsOneWidget);

      await tester.tap(find.text('Geral'));
      await tester.pumpAndSettle();
      expect(find.textContaining('no geral.'), findsOneWidget);
    });
  });

  group('Desafio', () {
    testWidgets('alternativa marcada e feedback de acerto com ícone',
        (tester) async {
      await _enterAsStudent(tester);
      await _openBedroomQuiz(tester);

      final first = SampleContent.plantaDoQuarto.questions.first;
      final right = find.text(first.options[first.correctIndex]);
      expect(_hasSemantics(tester, right, (p) => p.selected == true), isFalse);
      await _pick(tester, right);
      expect(_hasSemantics(tester, right, (p) => p.selected == true), isTrue);
      expect(_iconLabeled('correta'), findsNothing);

      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      expect(find.text('Mandou bem!'), findsOneWidget);
      expect(_iconLabeled('correta'), findsOneWidget);
      expect(_iconLabeled('errada'), findsNothing);
      expect(
        find.descendant(
          of: find.ancestor(
              of: find.text('Mandou bem!'), matching: find.byType(Row)),
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('resposta errada mostra o ✗ na marcada e o ✓ na correta',
        (tester) async {
      await _enterAsStudent(tester);
      await _openBedroomQuiz(tester);

      final first = SampleContent.plantaDoQuarto.questions.first;
      final wrongIndex = (first.correctIndex + 1) % first.options.length;
      await _pick(tester, find.text(first.options[wrongIndex]));
      await tester.tap(find.text('Confirmar'));
      await tester.pump();

      expect(find.text('Quase lá.'), findsOneWidget);
      expect(_iconLabeled('errada'), findsOneWidget);
      expect(_iconLabeled('correta'), findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(
              of: find.text('Quase lá.'), matching: find.byType(Row)),
          matching: find.byIcon(Icons.cancel),
        ),
        findsOneWidget,
      );
    });

    testWidgets('gabaritar a planta do quarto comemora e sobe de nível',
        (tester) async {
      await _enterAsStudent(tester);
      await _openBedroomQuiz(tester);

      final questions = SampleContent.plantaDoQuarto.questions;
      for (final (i, q) in questions.indexed) {
        expect(find.byType(BedroomPlan), findsOneWidget);
        await _pick(tester, find.text(q.options[q.correctIndex]));
        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        final last = i == questions.length - 1;
        await tester.tap(find.text(last ? 'Ver resultado' : 'Próxima'));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text('Gabaritou!'), findsOneWidget);
      expect(find.text('5/5'), findsOneWidget);
      // 50 de acertos + 30 de combo + 50 de conclusão: 1.000 → 1.130 XP,
      // passando de Afiado II para Afiado III.
      expect(find.text('+130 XP'), findsOneWidget);
      expect(find.text('Subiu de nível'), findsOneWidget);
      expect(find.text('Afiado III'), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      // A aba é recriada para recarregar o progresso, mas continua na trilha
      // que o aluno tinha escolhido.
      // O nome aparece no seletor e no título da trilha aberta.
      expect(find.text('Instalações Elétricas'), findsNWidgets(2));
      expect(find.text('4. Associação de resistores'), findsNothing);
      expect(find.byType(ResultScreen), findsNothing);
    });
  });
}
