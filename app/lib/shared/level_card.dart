import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../domain/rules/level_rules.dart';
import 'format.dart';
import 'widgets.dart';

/// Cartão com o nível atual, a escada de níveis e o progresso.
///
/// Com [animateFromXp], o XP sobe do valor antigo até o atual, passando
/// pelos níveis do meio (usado no resultado do desafio).
class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
    this.animateFromXp,
    this.color = AppColors.surface,
  });

  /// Raio do cartão, para efeitos que precisam acompanhar o contorno.
  static const radius = 20.0;

  /// Quanto a barra leva para subir com [animateFromXp]; o resultado usa
  /// para sincronizar o selo de nível novo com o cruzamento da barra.
  static const animationDuration = Duration(milliseconds: 1400);

  final LevelProgress level;
  final int? animateFromXp;

  /// Fundo do cartão. O acento do cartão é a barra de XP em âmbar; o fundo
  /// fica tonal.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final from = animateFromXp;
    final animate = from != null &&
        from != level.totalXp &&
        !MediaQuery.of(context).disableAnimations;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: animate
          ? TweenAnimationBuilder<double>(
              tween:
                  Tween(begin: from.toDouble(), end: level.totalXp.toDouble()),
              duration: animationDuration,
              curve: Curves.easeOutCubic,
              builder: (context, xp, _) =>
                  _LevelContent(level: LevelRules.progressFor(xp.round())),
            )
          : _LevelContent(level: level),
    );
  }
}

class _LevelContent extends StatelessWidget {
  const _LevelContent({required this.level});

  final LevelProgress level;

  @override
  Widget build(BuildContext context) {
    final tier = level.current.tier;
    final next = level.next;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nível ${tier.index + 1} de ${LevelTier.values.length}',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  Text(
                    level.current.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 26,
                      height: 1.2,
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${formatNumber(level.totalXp)} XP',
                style: const TextStyle(
                  color: AppColors.amberText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.display,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final t in LevelTier.values)
              Expanded(
                child: Text(
                  t.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: t == tier ? FontWeight.w700 : FontWeight.w400,
                    color: t == tier
                        ? AppColors.amberText
                        : t.index < tier.index
                            ? AppColors.text
                            : AppColors.muted,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(
          value: level.fraction,
          gradient: AppColors.xpGradient,
          height: 10,
          semanticsLabel: 'Progresso no nível',
        ),
        const SizedBox(height: 10),
        if (next == null)
          const Text(
            'Você chegou ao topo: Domínio.',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          )
        else
          // A escada logo acima já mostra o nível seguinte; a frase fica curta
          // para caber numa linha mesmo em 360 dp.
          Text.rich(
            TextSpan(
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
              children: [
                const TextSpan(text: 'Faltam '),
                TextSpan(
                  text: '${formatNumber(level.xpToNext)} XP',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' para ${next.name}'),
              ],
            ),
          ),
      ],
    );
  }
}
