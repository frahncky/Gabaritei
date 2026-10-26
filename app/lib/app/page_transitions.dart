import 'package:flutter/material.dart';

import 'tokens.dart';

/// Fundo das páginas: [AppColors.ground] com a grade de "planta técnica"
/// por trás do conteúdo. Cartões tonais a cobrem; só o fundo a mostra.
///
/// O tema aplica este fundo a toda rota de página por
/// [BlueprintPageTransitionsBuilder], e os `Scaffold` ficam transparentes.
class BlueprintBackground extends StatelessWidget {
  const BlueprintBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ground,
      child: CustomPaint(painter: const _GridPainter(), child: child),
    );
  }
}

/// Envolve cada página em [BlueprintBackground] antes da transição de
/// [inner]. Assim cada página é opaca com a própria grade, e a tela de baixo
/// não vaza pela de cima durante a transição.
class BlueprintPageTransitionsBuilder extends PageTransitionsBuilder {
  const BlueprintPageTransitionsBuilder(this.inner);

  final PageTransitionsBuilder inner;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      inner.delegatedTransition;

  @override
  Duration get transitionDuration => inner.transitionDuration;

  @override
  Duration get reverseTransitionDuration => inner.reverseTransitionDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return inner.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      BlueprintBackground(child: child),
    );
  }
}

/// Só a grade fina de "planta técnica", para compor fundos fora das rotas
/// (as páginas já a recebem de [BlueprintBackground]).
///
/// É textura, não conteúdo: mais visível no topo (cabeçalho) e quase
/// apagada embaixo, para não somar ruído ao texto.
class BlueprintGrid extends StatelessWidget {
  const BlueprintGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(painter: _GridPainter(), size: Size.infinite),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Grade fina com uma linha mais marcada a cada 5, como no banner,
    // esmaecendo de cima para baixo.
    final rect = Offset.zero & size;
    Paint lines(double alpha) => Paint()
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.55],
        colors: [
          AppColors.skyOnInk.withValues(alpha: alpha),
          AppColors.skyOnInk.withValues(alpha: alpha * 0.3),
        ],
      ).createShader(rect);
    final minor = lines(0.018);
    final major = lines(0.04);
    const step = 28.0;
    var i = 0;
    for (var x = 0.0; x < size.width; x += step, i++) {
      canvas.drawLine(
          Offset(x, 0), Offset(x, size.height), i % 5 == 0 ? major : minor);
    }
    i = 0;
    for (var y = 0.0; y < size.height; y += step, i++) {
      canvas.drawLine(
          Offset(0, y), Offset(size.width, y), i % 5 == 0 ? major : minor);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
