import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/app/app.dart';
import 'package:gabaritei/app/dependencies.dart';

void main() {
  testWidgets('navegação se adapta à largura e mantém a aba selecionada', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GabariteiApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar como aluno'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Trilhas'),
      ),
    );
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      1,
    );
    expect(
      find.byKey(const ValueKey('course-electrotechnics')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(tester.takeException(), isNull);
  });
}
