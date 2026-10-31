import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';
import 'package:gabaritei/shared/brand.dart';

void main() {
  testWidgets('splash termina e entrada repete o giro após a pausa', (
    tester,
  ) async {
    await tester.pumpWidget(
      GabariteiApp(dependencies: AppDependencies.inMemory(), showSplash: true),
    );
    expect(find.text('Entrar como aluno'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Entrar como aluno'), findsOneWidget);
    double rotation() => tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(AnimatedGabariteiMark),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((widget) => widget.painter)
        .whereType<GabariteiMarkPainter>()
        .single
        .rotation;
    expect(rotation(), closeTo(0, 0.001));
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 200));
    expect(rotation().abs(), greaterThan(0.01));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
