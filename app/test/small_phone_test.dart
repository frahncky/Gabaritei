import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';

/// Celular pequeno de referência.
const _small = Size(360, 780);

var _fontsLoaded = false;

/// Fontes reais do app (como em tool/screenshot_kit.dart): sem elas o teste
/// usa glifos quadrados, mais largos que a Bricolage e o IBM Plex, e acusaria
/// overflow que não existe no aparelho. Carrega uma vez por arquivo: o
/// rootBundle guarda as leituras, e repetir a carga num teste seguinte fica
/// esperando para sempre.
Future<void> _loadAppFonts() async {
  if (_fontsLoaded) return;
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  _fontsLoaded = true;
}

Future<void> _start(WidgetTester tester, String role) async {
  await _loadAppFonts();
  tester.view.physicalSize = _small;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));
  await tester
      .pumpWidget(GabariteiApp(dependencies: AppDependencies.inMemory()));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'tela de entrada');
  await tester.tap(find.text(role));
  await tester.pumpAndSettle();
}

/// Rola a lista visível até o fim, conferindo overflow a cada passo.
Future<void> _sweep(WidgetTester tester, String where,
    {bool settle = true}) async {
  for (var i = 0; i < 20; i++) {
    final scrollable = find.byType(Scrollable).first;
    final position = tester.state<ScrollableState>(scrollable).position;
    if (position.pixels >= position.maxScrollExtent) break;
    await tester.drag(scrollable, const Offset(0, -300));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(tester.takeException(), isNull, reason: '$where, passo $i');
  }
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
      of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: label);
}

void main() {
  testWidgets('aluno percorre as quatro abas em 360 × 780 sem overflow',
      (tester) async {
    await _start(tester, 'Entrar como aluno');
    expect(tester.takeException(), isNull);
    await _sweep(tester, 'Início');

    await _tab(tester, 'Trilhas');
    await tester.tap(find.byKey(const ValueKey('course-electrotechnics')));
    await tester.pumpAndSettle();
    for (final id in ['eletricidade-basica', 'instalacoes-eletricas']) {
      final option = find.byKey(ValueKey('discipline-$id'));
      await tester.scrollUntilVisible(option, 200, scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
      await _sweep(tester, 'Módulos / $id');
      final back = find.byKey(const ValueKey('back-to-disciplines'));
      await tester.scrollUntilVisible(back, -300, scrollable: find.byType(Scrollable).first);
      await tester.tap(back);
      await tester.pumpAndSettle();
    }
    await _tab(tester, 'Ranking');
    await _sweep(tester, 'Ranking');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 5000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mês'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Ranking / Mês');

    await _tab(tester, 'Perfil');
    await _sweep(tester, 'Perfil');
  });

  testWidgets('atividade de instalações cabe em 360 × 780', (tester) async {
    await _start(tester, 'Entrar como aluno');
    await _tab(tester, 'Trilhas');
    await tester.tap(find.byKey(const ValueKey('course-electrotechnics')));
    await tester.pumpAndSettle();
    final discipline = find.byKey(const ValueKey('discipline-instalacoes-eletricas'));
    await tester.scrollUntilVisible(discipline, 200, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(discipline);
    await tester.tap(discipline);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Continuar lição'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('Continuar lição'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar lição'));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(tester.takeException(), isNull);
    await _sweep(tester, 'Desafio', settle: false);
  });

  testWidgets('painel do professor e rascunho cabem em 360 × 780',
      (tester) async {
    await _start(tester, 'Entrar como professor');
    expect(tester.takeException(), isNull);
    await _sweep(tester, 'Painel');

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 5000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Gerar questão'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('Gerar questão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gerar questão'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'rascunho');
    await _sweep(tester, 'Painel com rascunho');
  });
}
