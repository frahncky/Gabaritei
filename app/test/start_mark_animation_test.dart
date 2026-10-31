import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';
import 'package:gabaritei/shared/brand.dart';

void main() {
  testWidgets('app abre direto na entrada e repete o giro após a pausa', (
    tester,
  ) async {
    await tester.pumpWidget(
      GabariteiApp(dependencies: AppDependencies.inMemory()),
    );
    expect(find.text('Entrar como aluno'), findsOneWidget);
    GabariteiMarkPainter painter() => tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(AnimatedGabariteiMark),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((widget) => widget.painter)
        .whereType<GabariteiMarkPainter>()
        .single;
    double rotation() => painter().rotation;

    // Enquanto os pilares giram, o ✓ ainda não apareceu.
    await tester.pump(const Duration(milliseconds: 1000));
    expect(rotation().abs(), greaterThan(0.01));
    expect(painter().checkProgress, 0);

    // Giro encerrado: o ✓ se traça com os pilares já parados.
    await tester.pump(const Duration(milliseconds: 900));
    expect(rotation(), 0);
    expect(painter().checkProgress, inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(rotation(), closeTo(0, 0.001));
    expect(painter().checkProgress, 1);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 200));
    expect(rotation().abs(), greaterThan(0.01));
    // No giro repetido o ✓ recolhe e volta só ao final.
    expect(painter().checkProgress, lessThan(1));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(painter().checkProgress, 0);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
