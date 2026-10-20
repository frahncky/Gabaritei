import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../domain/models/quiz_result.dart';
import '../../shared/format.dart';
import '../../shared/level_card.dart';
import '../../shared/medal_badge.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final level = result.levelAfter;
    final wrong = result.wrongQuestions;
    final ratio = result.total == 0 ? 0.0 : result.correctCount / result.total;
    final celebrate =
        ratio >= 0.7 || result.leveledUp || result.newMedals.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                      children: [
                        Center(
                          child: _ScoreRing(
                            correct: result.correctCount,
                            total: result.total,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _headline(ratio),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${result.correctCount} de ${result.total} acertos',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.mutedOnInk,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _XpCountUp(total: result.xp.total),
                        Text(
                          _breakdownText(result),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.mutedOnInk, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        if (result.leveledUp) ...[
                          _Kicker(
                            result.reachedNewTier
                                ? 'NOVO NÍVEL!'
                                : 'SUBIU DE NÍVEL',
                          ),
                          const SizedBox(height: 8),
                        ],
                        LevelCard(
                          level: level,
                          animateFromXp: result.xpBefore,
                          color: AppColors.inkRaised,
                        ),
                        for (final medal in result.newMedals) ...[
                          const SizedBox(height: 12),
                          _DarkCard(
                            leading: MedalBadge(medal: medal, size: 56),
                            kicker: 'NOVA MEDALHA',
                            title: medal.name,
                            subtitle: medal.description,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                icon: Icons.local_fire_department,
                                label: 'Sequência',
                                value: '${result.streakAfter} '
                                    '${result.streakAfter == 1 ? 'dia' : 'dias'}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MiniStat(
                                icon: Icons.track_changes,
                                label: 'Acerto',
                                value: formatPercent(ratio),
                              ),
                            ),
                          ],
                        ),
                        if (wrong.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Para revisar',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  for (final q in wrong) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.cancel,
                                            color: AppColors.error, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(q.topic,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              const SizedBox(height: 2),
                                              Text(q.explanation,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (celebrate) const Positioned.fill(child: _Confetti()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.amber,
                    foregroundColor: AppColors.ink,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _headline(double ratio) {
    if (ratio >= 1) return 'Gabaritou!';
    if (ratio >= 0.7) return 'Mandou bem!';
    if (ratio >= 0.4) return 'Bom treino!';
    return 'Bora revisar?';
  }

  static String _breakdownText(QuizResult result) {
    final xp = result.xp;
    final parts = <String>['${xp.baseXp} XP de acertos'];
    if (xp.comboXp > 0) parts.add('${xp.comboXp} de combo');
    if (xp.completionXp > 0) parts.add('${xp.completionXp} de conclusão');
    if (xp.hintPenalty > 0) parts.add('−${xp.hintPenalty} de dicas');
    return parts.join(' · ');
  }
}

bool _reduceMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;

/// Anel com a fração de acertos, que se preenche ao abrir a tela.
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final target = total == 0 ? 0.0 : correct / total;
    return Semantics(
      label: '$correct de $total acertos',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: _reduceMotion(context) ? target : 0, end: target),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => CustomPaint(
          size: const Size.square(128),
          painter: _RingPainter(value),
          child: SizedBox.square(
            dimension: 128,
            child: Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$correct',
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                    TextSpan(
                      text: '/$total',
                      style: const TextStyle(
                          fontSize: 18, color: AppColors.mutedOnInk),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.inkLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (value <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..color = AppColors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.value != value;
}

/// "+N XP" contando do zero.
class _XpCountUp extends StatelessWidget {
  const _XpCountUp({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: _reduceMotion(context) ? total : 0, end: total),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        '+${formatNumber(value)} XP',
        textAlign: TextAlign.center,
        semanticsLabel: 'Mais $total XP',
        style: const TextStyle(
          color: AppColors.amberOnInk,
          fontSize: 44,
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Chuva curta de confete, uma vez só, sem bloquear toques.
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  late final List<_Piece> _pieces = _Piece.scatter(70);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reduceMotion(context) &&
        !_controller.isAnimating &&
        _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(painter: _ConfettiPainter(_controller, _pieces)),
      ),
    );
  }
}

class _Piece {
  _Piece(math.Random r)
      : x = r.nextDouble(),
        delay = r.nextDouble() * 0.25,
        speed = 0.7 + r.nextDouble() * 0.6,
        drift = (r.nextDouble() - 0.5) * 0.25,
        spin = (r.nextDouble() - 0.5) * 14,
        width = 6 + r.nextDouble() * 5,
        color = _colors[r.nextInt(_colors.length)];

  static const _colors = [
    AppColors.amber,
    AppColors.amberOnInk,
    AppColors.blue,
    Color(0xFF93B4FA),
    Colors.white,
  ];

  static List<_Piece> scatter(int count) {
    final r = math.Random(7);
    return List.generate(count, (_) => _Piece(r));
  }

  final double x;
  final double delay;
  final double speed;
  final double drift;
  final double spin;
  final double width;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.animation, this.pieces) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Piece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    if (t == 0 || t == 1) return;
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local == 0) continue;
      // Cai acelerando e some no final.
      final y = -20 + local * local * size.height * p.speed;
      final x = (p.x + p.drift * local) * size.width;
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - local).clamp(0.0, 1.0));
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.spin * local);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.width, height: p.width * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.amber,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  const _DarkCard({
    required this.leading,
    required this.kicker,
    required this.title,
    required this.subtitle,
  });

  final Widget leading;
  final String kicker;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inkRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kicker,
                    style: const TextStyle(
                      color: AppColors.amberOnInk,
                      fontSize: 12,
                      letterSpacing: 1,
                    )),
                Text(title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                    )),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.mutedOnInk, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inkRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.amberOnInk, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.mutedOnInk, fontSize: 12)),
                Text(value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
