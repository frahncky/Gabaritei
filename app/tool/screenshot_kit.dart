// Gera imagens das telas dentro de testes de widget, com as fontes reais do
// app, para conferir o visual sem precisar de emulador.
//
// Usado por tool/screenshots_test.dart e por testes temporários dos agentes
// de design e animação. As imagens vão para build/screenshots/.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';
import 'package:gabaritei/app/theme.dart';

const screenshotDir = 'build/screenshots';

/// Tamanhos lógicos usados nas capturas.
const phone = Size(400, 860);
const smallPhone = Size(360, 780);
const tablet = Size(1280, 1600);

bool _fontsLoaded = false;

/// Carrega as fontes do `FontManifest.json` (Bricolage, IBM Plex e Material
/// Icons). Sem isso o teste desenha todo texto como retângulos.
///
/// O teste não tem as fontes do sistema, e isso serve de alerta nas imagens:
/// - texto virando **bloco sólido** não tem `fontFamily` e, no celular, sai
///   em Roboto, fora da identidade visual;
/// - **□** no lugar de um caractere (como `Ω`) indica um glifo que as fontes do
///   app não têm; no celular ele sai na fonte do sistema.
Future<void> loadAppFonts() async {
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

/// Teste de captura: fontes reais e sombras ligadas (o flutter_test as
/// desliga por padrão e exige que voltem ao normal antes do fim do teste).
void screenshotTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    await loadAppFonts();
    // Um toque que erra o alvo capturaria a tela errada sem aviso visível.
    WidgetController.hitTestWarningShouldBeFatal = true;
    debugDisableShadows = false;
    try {
      await body(tester);
    } finally {
      debugDisableShadows = true;
    }
  });
}

/// Abre o app com dados de exemplo em memória no tamanho pedido.
Future<void> pumpGabaritei(
  WidgetTester tester, {
  Size size = phone,
  double pixelRatio = 2,
}) async {
  tester.view.physicalSize = size * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);
  await tester
      .pumpWidget(GabariteiApp(dependencies: AppDependencies.inMemory()));
  await tester.pumpAndSettle();
}

const _shotKey = ValueKey('screenshot-root');

/// Abre só [home] (uma tela ou um widget solto) com o tema do app, para
/// capturar estados difíceis de alcançar navegando, como um resultado perfeito
/// ou um diagrama específico.
///
/// Não espera as animações: chame `pumpAndSettle` ou `shootFrames` depois.
Future<void> pumpScreenshotWidget(
  WidgetTester tester,
  Widget home, {
  Size size = phone,
  double pixelRatio = 2,
}) async {
  tester.view.physicalSize = size * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(RepaintBoundary(
    key: _shotKey,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: home,
    ),
  ));
}

/// Rola até [finder] e deixa o item no meio da tela, longe da barra inferior.
Future<void> scrollToCenter(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200,
      scrollable: find.byType(Scrollable).first);
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}

Future<ui.Image> _capture(WidgetTester tester) async {
  final app = find.byType(GabariteiApp);
  final element =
      (app.evaluate().isEmpty ? find.byKey(_shotKey) : app).evaluate().single;
  final pending = captureImage(element);
  return (await tester.runAsync(() => pending))!;
}

Future<void> _writePng(WidgetTester tester, ui.Image image, String name) async {
  await tester.runAsync(() async {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$screenshotDir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// Salva a tela atual em `build/screenshots/<name>.png`.
Future<void> shoot(WidgetTester tester, String name) async {
  final image = await _capture(tester);
  await _writePng(tester, image, name);
  image.dispose();
}

/// Salva [frames] quadros de uma animação, avançando [step] entre eles, numa
/// única folha `build/screenshots/<name>.png` com o tempo de cada quadro.
///
/// Dispare a animação (tap, navegação...) e chame logo em seguida, sem
/// `pumpAndSettle` antes.
Future<void> shootFrames(
  WidgetTester tester,
  String name, {
  int frames = 8,
  Duration step = const Duration(milliseconds: 60),
  int columns = 4,
}) async {
  final images = <ui.Image>[];
  for (var i = 0; i < frames; i++) {
    if (i > 0) await tester.pump(step);
    images.add(await _capture(tester));
  }

  // Cada quadro entra pela metade do tamanho, com 28 px para a legenda.
  const scale = 0.5;
  const label = 28.0;
  final cellW = images.first.width * scale;
  final cellH = images.first.height * scale + label;
  final rows = (frames / columns).ceil();
  final cols = frames < columns ? frames : columns;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(Rect.fromLTWH(0, 0, cellW * cols, cellH * rows),
        Paint()..color = const Color(0xFF000000));
  for (var i = 0; i < images.length; i++) {
    final origin = Offset((i % columns) * cellW, (i ~/ columns) * cellH);
    final image = images[i];
    canvas.drawImageRect(
      image,
      Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
      origin + const Offset(0, label) &
          Size(image.width * scale, image.height * scale),
      Paint()..filterQuality = FilterQuality.medium,
    );
    final paragraph = (ui.ParagraphBuilder(ui.ParagraphStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 16,
    ))
          ..pushStyle(ui.TextStyle(color: const Color(0xFFFFFFFF)))
          ..addText('${step.inMilliseconds * i} ms'))
        .build()
      ..layout(ui.ParagraphConstraints(width: cellW));
    canvas.drawParagraph(paragraph, origin + const Offset(8, 4));
  }

  final sheet = await tester.runAsync(() => recorder
      .endRecording()
      .toImage((cellW * cols).round(), (cellH * rows).round()));
  await _writePng(tester, sheet!, name);
  sheet.dispose();
  for (final image in images) {
    image.dispose();
  }
}
