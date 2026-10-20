// Gera as imagens da marca em assets/brand/ a partir de GabariteiMarkPainter.
//
//   flutter test tool/brand_assets_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/shared/brand.dart';

Future<void> _render(
    String path, int side, GabariteiMarkPainter painter) async {
  final recorder = ui.PictureRecorder();
  final size = Size.square(side.toDouble());
  painter.paint(Canvas(recorder), size);
  final image = await recorder.endRecording().toImage(side, side);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('gera ícone e splash', (tester) async {
    await tester.runAsync(() async {
      // Ícone legado e da loja: quadrado cheio, o launcher arredonda.
      await _render(
        'assets/brand/icon.png',
        1024,
        const GabariteiMarkPainter(fullBleed: true),
      );
      // Ícone adaptativo: só a bolha, dentro da zona segura (66% centrais).
      await _render(
        'assets/brand/icon_foreground.png',
        1024,
        const GabariteiMarkPainter(withBackground: false, bubbleScale: 0.46),
      );
      // Splash do Android 12+: 1152 px, ícone dentro do círculo de 768 px.
      await _render(
        'assets/brand/splash_android12.png',
        1152,
        const GabariteiMarkPainter(withBackground: false, bubbleScale: 0.42),
      );
      // Splash até o Android 11.
      await _render(
        'assets/brand/splash.png',
        512,
        const GabariteiMarkPainter(withBackground: false, bubbleScale: 0.9),
      );
    });
  });
}
