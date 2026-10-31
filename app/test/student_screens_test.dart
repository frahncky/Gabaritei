import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
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
  await tester.tap(find.byKey(const ValueKey('course-electrotechnics')));
  await tester.pumpAndSettle();
  final discipline = find.byKey(const ValueKey('discipline-instalacoes-eletricas'));
  await _scrollTo(tester, discipline);
  await tester.tap(discipline);
  await tester.pumpAndSettle();
  // O desafio extra é independente da atividade curricular ie-1.
  final context = tester.element(find.byType(NavigationBar));
  openQuiz(context, SampleContent.plantaDoQuarto.id);
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
    testWidgets('"Comece por aqui" abre a primeira atividade',
        (tester) async {
      await _enterAsStudent(tester);
      expect(find.text('Comece por aqui'), findsOneWidget);
      expect(find.text('Eletricidade Básica · Módulo 1'), findsOneWidget);
      expect(find.text('0 de 1 lições'), findsOneWidget);

      await _scrollTo(tester, find.text('Começar').first);
      await tester.tap(find.text('Começar').first);
      await _pumpQuiz(tester);
      expect(find.byType(QuizScreen), findsOneWidget);
      expect(_inAppBar('Grandezas elétricas'), findsOneWidget);

      // Sair sem responder volta direto para o início.
      await tester.tap(find.byTooltip('Sair do desafio'));
      await tester.pumpAndSettle();
      expect(find.byType(QuizScreen), findsNothing);
      expect(find.text('Olá, Ana'), findsOneWidget);
    });

    testWidgets('início não exibe os cards de laboratórios removidos', (tester) async {
      await _enterAsStudent(tester);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.text('Laboratórios'), findsNothing);
      expect(find.text('Veja a eletricidade em movimento'), findsNothing);
      expect(find.text('Sensor, CLP e válvula'), findsNothing);
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
    testWidgets('curso abre disciplinas, módulos e permite voltar', (tester) async {
      await _enterAsStudent(tester);
      await _openTab(tester, 'Trilhas');
      await tester.tap(find.byKey(const ValueKey('course-electrotechnics')));
      await tester.pumpAndSettle();
      final discipline = find.byKey(const ValueKey('discipline-instalacoes-eletricas'));
      await _scrollTo(tester, discipline);
      await tester.tap(discipline);
      await tester.pumpAndSettle();
      expect(find.text('1. Simbologia e diagramas'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('back-to-disciplines')));
      await tester.pumpAndSettle();
      expect(discipline, findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('back-to-courses')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('course-electronics')), findsOneWidget);
    });

    testWidgets('trilha bloqueada informa o pré-requisito real', (tester) async {
      await _enterAsStudent(tester);
      await _openTab(tester, 'Trilhas');
      await tester.tap(find.byKey(const ValueKey('course-automation')));
      await tester.pumpAndSettle();
      final discipline = find.byKey(const ValueKey('discipline-clp-automacao'));
      await _scrollTo(tester, discipline);
      await tester.tap(discipline);
      await tester.pumpAndSettle();
      expect(find.text('Conclua a trilha Eletrônica Digital para desbloquear esta.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Continuar lição'), findsWidgets);
      for (final button in tester.widgetList<FilledButton>(find.byType(FilledButton))) {
        expect(button.onPressed, isNull);
      }
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

    testWidgets('medalhas mostram grupos por disciplina e constância', (tester) async {
      await _enterAsStudent(tester);
      await _openTab(tester, 'Perfil');
      await _scrollTo(tester, find.text('2 de ${SampleContent.medals.length}'));
      expect(find.text('2 de ${SampleContent.medals.length}'), findsOneWidget);
      expect(find.text('Eletricidade Básica'), findsOneWidget);
      await _scrollTo(tester, find.text('Constância'));
      expect(find.text('Constância'), findsOneWidget);
      expect(tester.takeException(), isNull);
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
      expect(find.text('Instalações Elétricas'), findsOneWidget);
      expect(find.text('4. Associação de resistores'), findsNothing);
      expect(find.byType(ResultScreen), findsNothing);
    });
  });
}
