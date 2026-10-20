import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../domain/models/gamification.dart';

/// Emblema de uma medalha: roseta âmbar com fitas e o símbolo no centro.
/// Bloqueada, aparece apagada e com cadeado.
class MedalBadge extends StatelessWidget {
  const MedalBadge(
      {super.key, required this.medal, this.earned = true, this.size = 64});

  final Medal medal;
  final bool earned;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Símbolos longos ("100") encolhem para caber no miolo.
    final glyphSize = size * (medal.glyph.length >= 3 ? 0.22 : 0.3);

    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 1.15),
            painter: _MedalPainter(earned: earned),
          ),
          SizedBox(
            width: size,
            height: size,
            child: Center(
              child: earned
                  ? Text(
                      medal.glyph,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        fontSize: glyphSize,
                        height: 1,
                        color: AppColors.ink,
                      ),
                    )
                  : Icon(Icons.lock_outline,
                      size: size * 0.3, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  const _MedalPainter({required this.earned});

  final bool earned;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);

    // Fitas, atrás da roseta.
    final ribbon = Paint()..color = earned ? AppColors.blue : AppColors.line;
    for (final dir in [-1.0, 1.0]) {
      final x = s / 2 + dir * s * 0.16;
      canvas.drawPath(
        Path()
          ..moveTo(x - s * 0.11, s * 0.6)
          ..lineTo(x + s * 0.11, s * 0.6)
          ..lineTo(x + s * 0.11 + dir * s * 0.04, s * 1.13)
          ..lineTo(x + dir * s * 0.04, s * 1.03)
          ..lineTo(x - s * 0.11 + dir * s * 0.04, s * 1.13)
          ..close(),
        ribbon,
      );
    }

    // Roseta: borda ondulada com 16 pontas.
    const points = 16;
    final outer = s * 0.48;
    final inner = s * 0.43;
    final rosette = Path();
    for (var i = 0; i <= points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? rosette.moveTo(p.dx, p.dy) : rosette.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      rosette,
      Paint()..color = earned ? AppColors.amberText : AppColors.line,
    );

    // Miolo com anel.
    canvas.drawCircle(
      center,
      s * 0.36,
      Paint()..color = earned ? AppColors.amber : AppColors.track,
    );
    canvas.drawCircle(
      center,
      s * 0.3,
      Paint()
        ..color = earned ? AppColors.amberOnInk : AppColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.025,
    );
  }

  @override
  bool shouldRepaint(_MedalPainter oldDelegate) => oldDelegate.earned != earned;
}
