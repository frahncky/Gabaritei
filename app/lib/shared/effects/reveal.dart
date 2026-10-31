import 'package:flutter/material.dart';

/// Entrada de um bloco: aparece e sobe [rise] pixels enquanto [animation]
/// vai de 0 a 1 (já com a curva aplicada por quem chama).
///
/// Pensado para cascatas: um único controller, um trecho (`Interval`) por
/// bloco. Com 0 o bloco ocupa o espaço, mas não aparece.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.animation,
    required this.child,
    this.rise = 16,
  });

  final Animation<double> animation;
  final double rise;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - animation.value) * rise),
          child: child,
        ),
        child: child,
      ),
    );
  }
}
