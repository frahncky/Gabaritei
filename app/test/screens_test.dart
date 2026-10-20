import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GabariteiApp(dependencies: AppDependencies.inMemory()));
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
    await tester.scrollUntilVisible(find.text('4. Associação de resistores'), 200);
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

    await tester.enterText(find.widgetWithText(TextField, 'Título'), 'Paralelo turbo');
    await tester.pump();
    await tester.tap(find.text('Publicar para a turma'));
    await tester.pumpAndSettle();
    expect(find.text('Paralelo turbo'), findsOneWidget);
  });
}
