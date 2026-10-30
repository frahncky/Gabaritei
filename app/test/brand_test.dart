import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/shared/brand.dart';

const _side = 512;

/// Pixels desenhados (não transparentes) da marca sem fundo.
Future<List<Offset>> _inkedPixels(
    WidgetTester tester, GabariteiMarkPainter painter) async {
  final pixels = <Offset>[];
  await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), const Size.square(_side + 0.0));
    final image = await recorder.endRecording().toImage(_side, _side);
    final data = (await image.toByteData())!;
    for (var y = 0; y < _side; y++) {
      for (var x = 0; x < _side; x++) {
        if (data.getUint8((y * _side + x) * 4 + 3) > 0) {
          pixels.add(Offset(x + 0.5, y + 0.5));
        }
      }
    }
    image.dispose();
  });
  return pixels;
}

void main() {
  testWidgets('marca do ícone adaptativo cabe na zona segura de 66 dp',
      (tester) async {
    final scale = GabariteiMarkPainter.bubbleScaleToFit(66 / 108 / 2);
    final pixels = await _inkedPixels(
      tester,
      GabariteiMarkPainter(withBackground: false, bubbleScale: scale),
    );
    const center = Offset(_side / 2, _side / 2);
    const safeRadius = _side * 66 / 108 / 2;
    expect(pixels, isNotEmpty);
    expect(
      pixels.where((p) => (p - center).distance > safeRadius + 1),
      isEmpty,
    );
  });

  testWidgets('splash Android 12 mantém toda a marca no círculo visível', (tester) async {
    final pixels = await _inkedPixels(tester, GabariteiMarkPainter(
      withBackground: false,
      bubbleScale: GabariteiMarkPainter.bubbleScaleToFit(.32)));
    const center = Offset(_side / 2, _side / 2);
    expect(pixels.where((p) => (p - center).distance > _side / 3 + 1), isEmpty);
  });

  testWidgets('pilares cabem no quadrado arredondado do ícone', (tester) async {
    final pixels = await _inkedPixels(
      tester,
      const GabariteiMarkPainter(withBackground: false),
    );
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, _side + 0.0, _side + 0.0),
      const Radius.circular(_side * 0.24),
    );
    expect(pixels.where((p) => !rrect.contains(p)), isEmpty);
  });

  testWidgets('leitor de tela anuncia os três pilares', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: GabariteiMark())),
    );
    expect(
      find.bySemanticsLabel('Gabaritei: teoria, prática e contexto'),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
