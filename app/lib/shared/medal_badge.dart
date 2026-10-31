import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../domain/models/gamification.dart';

/// Emblema de uma medalha: roseta âmbar com fitas e ícone semântico no centro.
/// Bloqueada, aparece apagada e com cadeado.
class MedalBadge extends StatelessWidget {
  const MedalBadge(
      {super.key, required this.medal, this.earned = true, this.size = 64});

  final Medal medal;
  final bool earned;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${medal.name}, ${earned ? 'conquistada' : 'bloqueada'}',
      image: true,
      child: SizedBox(
        width: size,
        height: size * 1.15,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            CustomPaint(
              size: Size(size, size * 1.15),
              painter: _MedalPainter(earned: earned, icon: medal.icon),
            ),
            SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Icon(
                  _iconFor(medal.icon),
                  size: size * 0.38,
                  color: earned ? AppColors.ink : AppColors.muted,
                ),
              ),
            ),
            if (medal.iconLabel != null)
              Positioned(
                top: size * 0.58,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: earned ? AppColors.ink : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    medal.iconLabel!,
                    style: TextStyle(
                      color: earned ? AppColors.amberText : AppColors.muted,
                      fontSize: size * 0.14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            if (!earned)
              Positioned(
                right: size * 0.04,
                top: size * 0.57,
                child: Container(
                  padding: EdgeInsets.all(size * 0.05),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock,
                      size: size * 0.18, color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(MedalIcon icon) => switch (icon) {
      MedalIcon.ohm => Icons.functions,
      MedalIcon.bolt => Icons.speed,
      MedalIcon.streak => Icons.local_fire_department,
      MedalIcon.resistor => Icons.visibility_outlined,
      MedalIcon.parallel => Icons.call_split,
      MedalIcon.electrician => Icons.electrical_services,
      MedalIcon.kirchhoff => Icons.device_hub,
      MedalIcon.analog => Icons.graphic_eq,
      MedalIcon.digital => Icons.memory,
      MedalIcon.installation => Icons.electrical_services,
      MedalIcon.automation => Icons.precision_manufacturing,
    };

class _MedalPainter extends CustomPainter {
  const _MedalPainter({required this.earned, required this.icon});

  final bool earned;
  final MedalIcon icon;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);

    // Fitas, atrás da roseta: azul suave, para o âmbar ser o único acento.
    final ribbon = Paint()
      ..color = earned ? AppColors.progress : AppColors.line;
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

    // Cada família de conquista ganha uma cadência própria de nós no anel.
    final marks = 3 + icon.index;
    final markPaint = Paint()
      ..color = earned ? AppColors.inkSoft : AppColors.line;
    for (var i = 0; i < marks; i++) {
      final angle = -math.pi / 2 + (math.pi * 2 * i / marks);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * s * 0.31,
        s * 0.018,
        markPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MedalPainter oldDelegate) =>
      oldDelegate.earned != earned || oldDelegate.icon != icon;
}
