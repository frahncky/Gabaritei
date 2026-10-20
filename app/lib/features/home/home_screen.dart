import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/student.dart';
import '../../shared/level_card.dart';
import '../../shared/widgets.dart';
import '../lab/lab_screen.dart';
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
      onRetry: () => setState(() => _data = _load(Dependencies.of(context))),
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
            LevelCard(level: student.level),
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
            const SectionHeader('Missões de hoje',
                trailing: 'renovam à meia-noite'),
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
            const SizedBox(height: 16),
            _LabCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LabScreen()),
              ),
            ),
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
                  color: done ? AppColors.successSoft : AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  done ? Icons.check : Icons.flag_outlined,
                  size: 20,
                  color: done ? AppColors.success : AppColors.skyOnInk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    if (done)
                      const Text(
                        'Concluída',
                        style:
                            TextStyle(color: AppColors.success, fontSize: 13),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                              child: ProgressBar(
                                  value: mission.fraction, height: 6)),
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
                child: Text(mission.title,
                    style: Theme.of(context).textTheme.titleMedium),
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
              backgroundColor: AppColors.amber,
              foregroundColor: AppColors.ink,
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
                      'PRÓXIMA CONEXÃO · ${trail.title}',
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

/// Atalho para o Laboratório.
class _LabCard extends StatelessWidget {
  const _LabCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blueSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.skyOnInk.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.inkRaised,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.skyOnInk, width: 1.5),
                ),
                child: const Icon(Icons.electric_bolt,
                    color: AppColors.amberOnInk, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LABORATÓRIO',
                      style: TextStyle(
                        color: AppColors.skyOnInk,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Veja a eletricidade em movimento',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ohm, série, paralelo e potência',
                      style:
                          TextStyle(color: AppColors.mutedOnInk, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mutedOnInk),
            ],
          ),
        ),
      ),
    );
  }
}
