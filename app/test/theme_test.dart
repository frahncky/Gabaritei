import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';
import 'package:gabaritei/app/page_transitions.dart';
import 'package:gabaritei/app/theme.dart';

/// Nenhum Scaffold visível pinta fundo opaco por cima da grade da rota.
void _expectTransparentScaffolds(WidgetTester tester, String where) {
  final theme = AppTheme.dark();
  final scaffolds = tester.widgetList<Scaffold>(find.byType(Scaffold));
  expect(scaffolds, isNotEmpty, reason: where);
  for (final s in scaffolds) {
    final color = s.backgroundColor ?? theme.scaffoldBackgroundColor;
    expect(color.a, 0, reason: '$where: Scaffold com fundo $color');
  }
}

void main() {
  test('o tema deixa o Scaffold transparente e envolve toda rota na grade', () {
    final theme = AppTheme.dark();
    expect(theme.scaffoldBackgroundColor.a, 0);
    final builders = theme.pageTransitionsTheme.builders;
    for (final platform in TargetPlatform.values) {
      expect(builders[platform], isA<BlueprintPageTransitionsBuilder>(),
          reason: platform.name);
    }
  });

  testWidgets('cada tela do aluno recebe a grade pela rota e não a cobre',
      (tester) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester
        .pumpWidget(GabariteiApp(dependencies: AppDependencies.inMemory()));
    await tester.pumpAndSettle();

    // Entrada: a página fica sobre o fundo da rota.
    expect(find.byType(BlueprintBackground), findsOneWidget);
    _expectTransparentScaffolds(tester, 'entrada');

    await tester.tap(find.text('Entrar como aluno'));
    await tester.pumpAndSettle();
    expect(
      find.ancestor(
          of: find.text('Olá, Ana'),
          matching: find.byType(BlueprintBackground)),
      findsOneWidget,
    );
    for (final tab in ['Início', 'Trilhas', 'Ranking', 'Perfil']) {
      await tester.tap(find.descendant(
          of: find.byType(NavigationBar), matching: find.text(tab)));
      await tester.pumpAndSettle();
      _expectTransparentScaffolds(tester, tab);
    }

    // Desafio aberto por uma rota nova: também com a grade embaixo.
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text('Início')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Começar').first, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Começar').first);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(
      find.ancestor(
          of: find.byTooltip('Sair do desafio'),
          matching: find.byType(BlueprintBackground)),
      findsOneWidget,
    );
    _expectTransparentScaffolds(tester, 'desafio');
  });

  testWidgets('painel do professor também fica sobre a grade', (tester) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester
        .pumpWidget(GabariteiApp(dependencies: AppDependencies.inMemory()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar como professor'));
    await tester.pumpAndSettle();
    expect(
      find.ancestor(
          of: find.text('Painel do professor'),
          matching: find.byType(BlueprintBackground)),
      findsOneWidget,
    );
    _expectTransparentScaffolds(tester, 'professor');
  });
}
