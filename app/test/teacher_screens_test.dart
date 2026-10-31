import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';

Future<void> _enterAsTeacher(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester
      .pumpWidget(GabariteiApp(dependencies: AppDependencies.inMemory()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Entrar como professor'));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200,
      scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  const phone = Size(400, 860);

  testWidgets('no celular, "Enviar lembrete" vira "Enviado"', (tester) async {
    await _enterAsTeacher(tester, phone);
    expect(find.text('Visão geral da turma'), findsOneWidget);

    final remind = find.text('Enviar lembrete');
    while (remind.evaluate().isEmpty) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(remind.first);
    await tester.pumpAndSettle();
    final before = remind.evaluate().length;
    await tester.tap(remind.first);
    await tester.pumpAndSettle();
    expect(find.text('Enviado'), findsOneWidget);
    expect(find.text('Enviar lembrete'), findsNWidgets(before - 1));
    expect(find.textContaining('Lembrete enviado para '), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem título o desafio explica por que não publica',
      (tester) async {
    await _enterAsTeacher(tester, phone);
    const why = 'Dê um título ao desafio para publicar.';
    final title = find.widgetWithText(TextField, 'Título');
    await _scrollTo(tester, title);
    await _scrollTo(tester, find.text(why));
    expect(find.text(why), findsOneWidget);
    FilledButton publish() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Publicar para a turma'));
    expect(publish().onPressed, isNull);

    await tester.enterText(title, 'Paralelo turbo');
    await tester.pump();
    expect(find.text(why), findsNothing);
    expect(publish().onPressed, isNotNull);

    // Só espaços não contam como título.
    await tester.enterText(title, '   ');
    await tester.pump();
    expect(find.text(why), findsOneWidget);
    expect(publish().onPressed, isNull);
  });

  testWidgets('o rascunho gerado mostra a linha "Gabarito: …"', (tester) async {
    await _enterAsTeacher(tester, phone);
    await _scrollTo(tester, find.text('Gerar questão'));
    expect(find.textContaining('Gabarito: '), findsNothing);

    await tester.tap(find.text('Gerar questão'));
    await tester.pumpAndSettle();
    // Eletricidade básica / Grandezas elétricas: a correta é a primeira, e
    // a questão de assunto não ganha um circuito sem relação com ela.
    await _scrollTo(tester, find.textContaining('Gabarito: '));
    expect(
        find.text('Gabarito: A · Visual: sem recurso visual'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is Icon && w.semanticLabel == 'gabarito'),
      findsOneWidget,
    );
    expect(find.text('Adicionar ao banco'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
