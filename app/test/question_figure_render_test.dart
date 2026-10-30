import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/theme.dart';
import 'package:gabaritei/data/memory/question_figure_catalog.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/features/quiz/figure_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final body = FontLoader('IBMPlexSans')
      ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-400.ttf'))
      ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-600.ttf'));
    final display = FontLoader('BricolageGrotesque')
      ..addFont(rootBundle.load('assets/fonts/BricolageGrotesque-700.ttf'));
    final technical = FontLoader('GabariteiTechnical')
      ..addFont(rootBundle.load('assets/fonts/GabariteiTechnical.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await body.load();
    await display.load();
    await technical.load();
    await icons.load();
  });

  testWidgets('figuras renderizam em celular estreito e com texto ampliado', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final setup in [(320.0,1.0),(400.0,1.6)]) {
      tester.view.physicalSize = Size(setup.$1, 1000);
      for (final entry in QuestionFigureCatalog.figures.entries) {
        await tester.pumpWidget(MaterialApp(theme: AppTheme.dark(),
          home: MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(setup.$2)),
            child: Scaffold(body: SingleChildScrollView(
              child: QuestionFigureView(key: ValueKey(entry.key), figure: entry.value))))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${entry.key} em ${setup.$1}');
        expect(find.text(entry.value.title), findsOneWidget);
      }
    }
  });

  testWidgets('gera amostras para inspeção visual dos diagramas', (tester) async {
    tester.view.physicalSize = const Size(420, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const ids = [
      'ohm-1', 'assoc-3', 'exam-v2-eletricidade-basica-1', 'bank-v2-ea-2-1', 'bank-v2-eb-4-0', 'bank-v2-eb-4-1', 'bank-v2-ea-2-0',
      'bank-v2-ea-5-0', 'cores-1', 'bank-v2-ed-2-0', 'bank-v2-clp-1-0',
      'circuitos-cc-3-2', 'circuitos-ca-2-2',
      'bank-v2-clp-1-1', 'bank-v2-clp-3-0', 'bank-v2-clp-4-1',
      'exam-v2-circuitos-ca-3', 'bank-v2-circuitos-ca-2-1',
      'bank-v2-circuitos-ca-3-0', 'bank-v2-mecanica-maquinas-1-0',
      'bank-v2-mecanica-maquinas-1-1', 'bank-v2-mecanica-maquinas-2-0',
      'bank-v2-pneumatica-hidraulica-2-0', 'bank-v2-robotica-1-1',
      'bank-v2-redes-industriais-1-0', 'bank-v2-desenho-cad-2-0',
      'bank-v2-supervisorios-processos-3-0', 'bank-v2-qualidade-gestao-ambiente-3-0',
    ];
    final directory = Directory('build/figure_previews')..createSync(recursive: true);
    for (final id in ids) {
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(theme: AppTheme.dark(),
        home: Scaffold(body: SingleChildScrollView(child: RepaintBoundary(key: key,
          child: QuestionFigureView(figure: QuestionFigureCatalog.figures[id]!))))));
      await tester.pumpAndSettle();
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${directory.path}/$id.png').writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull, reason: id);
    }
    final byCourse = {
      for (final trail in SampleContent.trails)
        trail.title: SampleContent.quizzes.where((q) =>
          trail.modules.any((m) => m.quizId == q.id))
          .expand((q) => q.questions).where((q) => q.figure != null).length,
    };
    File('${directory.path}/coverage.json').writeAsStringSync(jsonEncode({
      'total': QuestionFigureCatalog.figures.length, 'byDiscipline': byCourse,
    }));
  });
}
