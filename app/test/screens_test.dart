import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester
        .pumpWidget(GabariteiApp(dependencies: AppDependencies.inMemory()));
    await tester.pumpAndSettle();
  }

  testWidgets('aluno navega pelas quatro abas', (tester) async {
    await pumpApp(tester, const Size(400, 860));

    await tester.tap(find.text('Entrar como aluno'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Ana'), findsOneWidget);
    expect(find.text('Missões de hoje'), findsOneWidget);

    await tester.tap(find.text('Trilhas').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('4. Associação de resistores'), 200);
    expect(find.text('4. Associação de resistores'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, 2000));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CLP e Automação'));
    await tester.pumpAndSettle();
    expect(find.textContaining('para desbloquear esta'), findsOneWidget);

    await tester.tap(find.text('Ranking').last);
    await tester.pumpAndSettle();
    expect(find.text('Ana S. (você)'), findsOneWidget);
    expect(find.textContaining('Liga Prata'), findsOneWidget);

    await tester.tap(find.text('Mês'));
    await tester.pumpAndSettle();
    expect(find.text('Ana S. (você)'), findsOneWidget);

    await tester.tap(find.text('Perfil').last);
    await tester.pumpAndSettle();
    expect(find.text('Ana Souza'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('2 de 9'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('2 de 9'), findsOneWidget);
  });

  testWidgets('desafio da tela inicial soma XP ao voltar', (tester) async {
    await pumpApp(tester, const Size(400, 860));
    await tester.tap(find.text('Entrar como aluno'));
    await tester.pumpAndSettle();
    expect(find.text('1.000 XP'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Começar'), 200);
    // A lista constrói itens além da borda: rola até o botão estar na tela.
    await tester.ensureVisible(find.text('Começar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    // Responde sempre a primeira alternativa até o fim.
    while (find.text('Ver resultado').evaluate().isEmpty) {
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      if (find.text('Próxima').evaluate().isNotEmpty) {
        await tester.tap(find.text('Próxima'));
        await tester.pump();
      }
    }
    await tester.tap(find.text('Ver resultado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Ana'), findsOneWidget);
    expect(find.text('1.000 XP'), findsNothing);
  });

  testWidgets('professor vê o painel e publica um desafio', (tester) async {
    await pumpApp(tester, const Size(1280, 1600));

    await tester.tap(find.text('Entrar como professor'));
    await tester.pumpAndSettle();
    expect(find.text('Visão geral da turma'), findsOneWidget);
    expect(find.text('27 / 32'), findsOneWidget);

    await tester.tap(find.text('Enviar lembrete').first);
    await tester.pumpAndSettle();
    expect(find.text('Enviado'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Título'), 'Paralelo turbo');
    await tester.pump();
    await tester.tap(find.text('Publicar para a turma'));
    await tester.pumpAndSettle();
    expect(find.text('Paralelo turbo'), findsOneWidget);
  });

  testWidgets('laboratório anima o circuito e troca de assunto',
      (tester) async {
    await pumpApp(tester, const Size(400, 860));
    await tester.tap(find.text('Entrar como aluno'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
        find.text('Veja a eletricidade em movimento'), 200);
    await tester.tap(find.text('Veja a eletricidade em movimento'));
    // O laboratório anima sem parar: avança quadros em vez de pumpAndSettle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('1 · Lei de Ohm'), findsOneWidget);
    expect(find.text('0,60 A'), findsWidgets);
    expect(find.text('seguro'), findsOneWidget);

    await tester.tap(find.text('Potência'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('P = V × I = V² ÷ R'), findsOneWidget);
    expect(find.text('7,2 W'), findsWidgets);

    await tester.tap(find.text('Cores'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1 kΩ'), findsOneWidget);
    expect(find.text('meta: 4,7 kΩ'), findsOneWidget);

    // Monta 4,7 kΩ: amarelo, violeta e o vermelho que já está no multiplicador.
    final semantics = tester.ensureSemantics();
    // Procura a cor dentro do seletor da faixa: a lista é preguiçosa e o
    // seletor de cima pode já ter saído da árvore.
    Future<void> pick(String band, String color) async {
      await tester.scrollUntilVisible(find.text(band), 80,
          scrollable: find.byType(Scrollable).last);
      final picker =
          find.ancestor(of: find.text(band), matching: find.byType(Column));
      final swatch = find.descendant(
          of: picker.first, matching: find.bySemanticsLabel(color));
      await tester.ensureVisible(swatch);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(swatch);
      await tester.pump(const Duration(milliseconds: 400));
    }

    await pick('1ª faixa · 1º dígito', 'Amarelo, 4');
    await pick('2ª faixa · 2º dígito', 'Violeta, 7');
    expect(find.text('4,7 kΩ'), findsWidgets);
    expect(find.text('acertou o desafio!'), findsOneWidget);
    semantics.dispose();

    await tester.tap(find.byType(BackButton));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Veja a eletricidade em movimento'), findsOneWidget);
  });
}
