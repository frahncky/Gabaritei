import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/student.dart';
import '../../domain/rules/level_rules.dart';
import '../../shared/format.dart';
import '../../shared/widgets.dart';
import '../quiz/quiz_screen.dart';

typedef _HomeData = ({
  Student student,
  List<Mission> missions,
  List<Trail> trails,
});

/// Tela inicial do aluno: nível, sequência, missões do dia, desafio
/// relâmpago e atalho para a trilha em andamento.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onDataChanged,
    required this.onOpenTrails,
  });

  /// Chamado depois de um desafio, para recarregar XP e missões.
  final VoidCallback onDataChanged;
  final VoidCallback onOpenTrails;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<_HomeData>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _load(Dependencies.of(context));
  }

  static Future<_HomeData> _load(AppDependencies deps) async {
    final (student, missions, trails) = await (
      deps.students.getCurrentStudent(),
      deps.students.getDailyMissions(),
      deps.content.getTrails(),
    ).wait;
    return (student: student, missions: missions, trails: trails);
  }

  Future<void> _startQuiz(String quizId) async {
    await openQuiz(context, quizId);
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<_HomeData>(
      future: _data!,
      builder: (context, data) {
        final student = data.student;
        final missions = data.missions.where((m) => !m.isFlash).toList();
        final flash = data.missions.where((m) => m.isFlash).firstOrNull;
        final current = _currentModule(data.trails);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gabaritei · ${student.className}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Olá, ${student.firstName}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                Avatar(
                  initials: student.initials,
                  size: 44,
                  background: AppColors.blue,
                  foreground: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _LevelCard(level: student.level),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: '${student.streakDays} '
                        '${student.streakDays == 1 ? 'dia' : 'dias'}',
                    label: 'de sequência',
                    icon: Icons.local_fire_department,
                    iconColor: AppColors.amberText,
                    iconBackground: AppColors.amberSoft,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: '${student.earnedBadgeIds.length}',
                    label: 'medalhas',
                    icon: Icons.military_tech_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader('Missões de hoje', trailing: 'renovam à meia-noite'),
            const SizedBox(height: 10),
            for (final mission in missions) ...[
              _MissionTile(
                mission: mission,
                onTap: mission.quizId == null || mission.isDone
                    ? null
                    : () => _startQuiz(mission.quizId!),
              ),
              const SizedBox(height: 10),
            ],
            if (flash != null) ...[
              const SizedBox(height: 6),
              _FlashCard(
                mission: flash,
                onStart: flash.quizId == null || flash.isDone
                    ? null
                    : () => _startQuiz(flash.quizId!),
              ),
            ],
            if (current != null) ...[
              const SizedBox(height: 16),
              _ContinueTrailCard(
                trail: current.$1,
                module: current.$2,
                onTap: widget.onOpenTrails,
              ),
            ],
          ],
        );
      },
    );
  }

  /// Primeira trilha liberada com um módulo em andamento.
  static (Trail, TrailModule)? _currentModule(List<Trail> trails) {
    for (final trail in trails.where((t) => t.unlocked)) {
      for (final module in trail.modules) {
        if (module.status == ModuleStatus.current) return (trail, module);
      }
    }
    return null;
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final LevelProgress level;

  @override
  Widget build(BuildContext context) {
    final tier = level.current.tier;
    final next = level.next;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
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
                      style: const TextStyle(color: AppColors.mutedOnInk, fontSize: 12),
                    ),
                    Text(
                      level.current.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
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
                      color: t.index <= tier.index
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
            trackColor: const Color(0xFF36493F),
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
      ),
    );
  }

  /// " · depois vem Craque" quando o próximo degrau ainda é do mesmo nível.
  String _afterNext(LevelStep next) {
    final tier = level.current.tier;
    if (next.tier != tier) return '';
    return ' · depois vem ${LevelTier.values[tier.index + 1].label}';
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.mission, this.onTap});

  final Mission mission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = mission.isDone;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: done ? const Color(0xFFDCFCE7) : AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  done ? Icons.check : Icons.flag_outlined,
                  size: 20,
                  color: done ? AppColors.success : AppColors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    if (done)
                      const Text(
                        'Concluída',
                        style: TextStyle(color: AppColors.success, fontSize: 13),
                      )
                    else
                      Row(
                        children: [
                          Expanded(child: ProgressBar(value: mission.fraction, height: 6)),
                          const SizedBox(width: 10),
                          Text(
                            '${mission.progress}/${mission.goal}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '+${mission.rewardXp} XP',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: done ? AppColors.muted : AppColors.amberText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashCard extends StatelessWidget {
  const _FlashCard({required this.mission, this.onStart});

  final Mission mission;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, size: 18, color: AppColors.amberText),
              SizedBox(width: 4),
              Text(
                'DESAFIO RELÂMPAGO',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.amberText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(mission.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              Text(
                '+${mission.rewardXp} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.amberText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
            ),
            onPressed: onStart,
            child: Text(mission.isDone ? 'Concluído' : 'Começar'),
          ),
        ],
      ),
    );
  }
}

class _ContinueTrailCard extends StatelessWidget {
  const _ContinueTrailCard({
    required this.trail,
    required this.module,
    required this.onTap,
  });

  final Trail trail;
  final TrailModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continuar trilha · ${trail.title}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Módulo ${module.order} — ${module.title}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ProgressBar(value: trail.fraction, height: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
