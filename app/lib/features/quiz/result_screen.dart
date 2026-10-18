import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/models/quiz_result.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final xp = result.xp;
    final level = result.levelAfter;
    final wrong = result.wrongQuestions;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            const Text(
              'DESAFIO CONCLUÍDO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedOnInk,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.correctCount} de ${result.total} acertos',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+${xp.total} XP',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.amberOnInk,
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _breakdownText(result),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedOnInk, fontSize: 13),
            ),
            const SizedBox(height: 20),
            if (result.reachedNewTier)
              _DarkCard(
                leading: const Icon(Icons.trending_up, color: AppColors.amberOnInk, size: 32),
                kicker: 'NOVO NÍVEL',
                title: level.current.name,
                subtitle: 'Você chegou a um novo grande nível!',
              )
            else if (result.leveledUp)
              _DarkCard(
                leading: const Icon(Icons.arrow_upward, color: AppColors.amberOnInk, size: 32),
                kicker: 'SUBIU DE NÍVEL',
                title: level.current.name,
                subtitle: level.isMax
                    ? 'Você está no topo: Domínio.'
                    : 'Faltam ${level.xpToNext} XP para ${level.next!.name}',
              ),
            for (final medal in result.newMedals) ...[
              const SizedBox(height: 12),
              _DarkCard(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.amber,
                  child: Text(
                    medal.glyph,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
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
                    label: 'Sequência',
                    value: '${result.streakAfter} '
                        '${result.streakAfter == 1 ? 'dia' : 'dias'}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(label: 'Nível atual', value: level.current.name),
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
                          style: Theme.of(context).textTheme.titleMedium),
                      for (final q in wrong) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.cancel, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(q.topic,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(q.explanation,
                                      style: Theme.of(context).textTheme.bodySmall),
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
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: AppColors.ink,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
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
        color: const Color(0xFF1F302A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF36493F)),
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
                      fontWeight: FontWeight.w700,
                    )),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.mutedOnInk, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F302A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF36493F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.mutedOnInk, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
