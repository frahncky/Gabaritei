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

/// Zona segura do ícone adaptativo: círculo de 66 dp numa camada de 108 dp.
final _foregroundScale = GabariteiMarkPainter.bubbleScaleToFit(66 / 108 / 2);

/// Splash do Android 12: só o círculo de 768 px (de 1152) aparece; folga
/// de 4%.
final _splash12Scale = GabariteiMarkPainter.bubbleScaleToFit(0.32);

void main() {
  testWidgets('gera ícone e splash', (tester) async {
    await tester.runAsync(() async {
      // Ícone legado e da loja: quadrado cheio, o launcher arredonda.
      await _render(
        'assets/brand/icon.png',
        1024,
        const GabariteiMarkPainter(fullBleed: true),
      );
      // Ícone adaptativo: a marca sem fundo, inteira na zona segura.
      await _render(
        'assets/brand/icon_foreground.png',
        1024,
        GabariteiMarkPainter(
            withBackground: false, bubbleScale: _foregroundScale),
      );
      // Splash do Android 12+: 1152 px, marca dentro do círculo de 768 px.
      await _render(
        'assets/brand/splash_android12.png',
        1152,
        GabariteiMarkPainter(
            withBackground: false, bubbleScale: _splash12Scale),
      );
      // Splash até o Android 11.
      await _render(
        'assets/brand/splash.png',
        512,
        const GabariteiMarkPainter(withBackground: false),
      );

      // Recursos efetivamente usados pelo launcher Android. Mantê-los aqui
      // evita que o PNG-fonte mude sem atualizar o ícone instalado.
      const launcherSizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      };
      const foregroundSizes = {
        'mdpi': 108,
        'hdpi': 162,
        'xhdpi': 216,
        'xxhdpi': 324,
        'xxxhdpi': 432,
      };
      for (final entry in launcherSizes.entries) {
        await _render(
          'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
          entry.value,
          const GabariteiMarkPainter(fullBleed: true),
        );
      }
      for (final entry in foregroundSizes.entries) {
        await _render(
          'android/app/src/main/res/drawable-${entry.key}/ic_launcher_foreground.png',
          entry.value,
          GabariteiMarkPainter(
            withBackground: false,
            bubbleScale: _foregroundScale,
          ),
        );
      }
    });
  });
}
