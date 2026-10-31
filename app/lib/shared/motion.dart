import 'package:flutter/widgets.dart';

/// Durações e curvas do movimento do app.
///
/// Use estes tokens em vez de números soltos, para que o ritmo das telas
/// combine entre si.
class AppMotion {
  AppMotion._();

  /// Toque e troca de estado.
  static const fast = Duration(milliseconds: 150);

  /// Cartões e trocas de aba.
  static const medium = Duration(milliseconds: 250);

  /// Entrada de tela e de blocos grandes.
  static const slow = Duration(milliseconds: 400);

  /// Comemoração completa (do disparo até assentar).
  static const celebration = Duration(milliseconds: 1200);

  /// Entrada: chega rápido e freia.
  static const Curve enter = Curves.easeOutCubic;

  /// Saída: arranca devagar e acelera.
  static const Curve exit = Curves.easeInCubic;

  /// Recompensa: passa um pouco do ponto e volta. Use com parcimônia.
  static const Curve reward = Curves.easeOutBack;

  /// Verdadeiro quando o sistema pede menos movimento: mostre o estado final.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
