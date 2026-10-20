import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../domain/rules/level_rules.dart';
import 'format.dart';
import 'widgets.dart';

/// Cartão escuro com o nível atual, a escada de níveis e o progresso.
///
/// Com [animateFromXp], o XP sobe do valor antigo até o atual, passando
/// pelos níveis do meio (usado no resultado do desafio).
class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
    this.animateFromXp,
    this.color = AppColors.ink,
  });

  final LevelProgress level;
  final int? animateFromXp;

  /// Fundo do cartão; use [AppColors.inkRaised] sobre telas escuras.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final from = animateFromXp;
    final animate = from != null &&
        from != level.totalXp &&
        !MediaQuery.of(context).disableAnimations;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: color == AppColors.ink
            ? null
            : Border.all(color: AppColors.inkLine),
      ),
      child: animate
          ? TweenAnimationBuilder<double>(
              tween:
                  Tween(begin: from.toDouble(), end: level.totalXp.toDouble()),
              duration: const Duration(milliseconds: 1400),
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
                    style: const TextStyle(
                        color: AppColors.mutedOnInk, fontSize: 12),
                  ),
                  Text(
                    level.current.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${formatNumber(level.totalXp)} XP',
              style: const TextStyle(
                color: AppColors.amberOnInk,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: AppFonts.display,
                fontFeatures: [FontFeature.tabularFigures()],
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: t == tier ? FontWeight.w700 : FontWeight.w400,
                    color: t == tier
                        ? AppColors.amberOnInk
                        : t.index < tier.index
                            ? Colors.white
                            : AppColors.mutedOnInk.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(
          value: level.fraction,
          color: AppColors.amber,
          trackColor: AppColors.inkLine,
          height: 10,
          semanticsLabel: 'Progresso no nível',
        ),
        const SizedBox(height: 10),
        if (next == null)
          const Text(
            'Você chegou ao topo: Domínio.',
            style: TextStyle(color: AppColors.mutedOnInk, fontSize: 13),
          )
        else
          Text.rich(
            TextSpan(
              style: const TextStyle(color: AppColors.mutedOnInk, fontSize: 13),
              children: [
                const TextSpan(text: 'Faltam '),
                TextSpan(
                  text: '${formatNumber(level.xpToNext)} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' para ${next.name}${_afterNext(next)}'),
              ],
            ),
          ),
      ],
    );
  }

  /// " · depois vem Craque" quando o próximo degrau ainda é do mesmo nível.
  String _afterNext(LevelStep next) {
    final tier = level.current.tier;
    if (next.tier != tier) return '';
    return ' · depois vem ${LevelTier.values[tier.index + 1].label}';
  }
}
