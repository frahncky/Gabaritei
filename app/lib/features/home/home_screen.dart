import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/student.dart';
import '../../shared/level_card.dart';
import '../../shared/widgets.dart';
import '../quiz/quiz_screen.dart';

typedef _HomeData = ({
  Student student,
  List<Mission> missions,
  List<Trail> trails,
});

/// Tela inicial do aluno, na ordem do que ele precisa: quem é e em que nível
/// está, o que continuar agora (ação principal) e as missões do dia.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onDataChanged,
    required this.onOpenTrails,
    this.onOpenProfile,
  });

  /// Chamado depois de um desafio, para recarregar XP e missões.
  final VoidCallback onDataChanged;
  final VoidCallback onOpenTrails;

  /// Toque no avatar.
  final VoidCallback? onOpenProfile;

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
          padding: AppSpacing.screen,
          children: [
            _Greeting(student: student, onAvatarTap: widget.onOpenProfile),
            const SizedBox(height: 16),
            LevelCard(level: student.level),
            if (current != null) ...[
              const SizedBox(height: 12),
              _ContinueCard(
                trail: current.$1,
                module: current.$2,
                onContinue: current.$2.quizId == null
                    ? widget.onOpenTrails
                    : () => _startQuiz(current.$2.quizId!),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(
              'Missões de hoje',
              trailing: 'renovam à meia-noite',
            ),
            const SizedBox(height: AppSpacing.header),
            if (missions.isNotEmpty)
              _MissionList(
                missions: missions,
                onStart: (mission) => _startQuiz(mission.quizId!),
              ),
            if (flash != null) ...[
              const SizedBox(height: AppSpacing.item),
              _FlashCard(
                mission: flash,
                onStart: flash.quizId == null || flash.isDone
                    ? null
                    : () => _startQuiz(flash.quizId!),
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

class _Greeting extends StatelessWidget {
  const _Greeting({required this.student, this.onAvatarTap});

  final Student student;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final days = student.streakDays;
    final badges = student.earnedBadgeIds.length;
    final avatar = Avatar(
      initials: student.initials,
      size: 48,
      background: AppColors.blueSoft,
      foreground: AppColors.skyOnInk,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            if (onAvatarTap == null)
              avatar
            else
              // Nó próprio (container) com a ação de toque: sem isso o botão
              // se funde com a saudação e o leitor de tela não o aciona.
              Semantics(
                container: true,
                button: true,
                label: 'Abrir perfil',
                onTap: onAvatarTap,
                excludeSemantics: true,
                child: InkResponse(
                  onTap: onAvatarTap,
                  radius: 28,
                  child: avatar,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InfoPill(
              icon: Icons.local_fire_department,
              iconColor: AppColors.amberText,
              label: '$days ${days == 1 ? 'dia' : 'dias'} de sequência',
            ),
            InfoPill(
              icon: Icons.military_tech_outlined,
              label: '$badges ${badges == 1 ? 'medalha' : 'medalhas'}',
            ),
          ],
        ),
      ],
    );
  }
}

/// Ação principal da tela: retomar o módulo em andamento.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.trail,
    required this.module,
    required this.onContinue,
  });

  final Trail trail;
  final TrailModule module;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final hasQuiz = module.quizId != null;
    final fresh = module.lessonsDone == 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.studyGradient),
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fresh ? 'Comece por aqui' : 'Continue de onde parou',
                style: const TextStyle(
                  color: AppColors.skyOnInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                module.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 20, height: 1.2),
              ),
              const SizedBox(height: 2),
              Text(
                '${trail.title} · Módulo ${module.order}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (module.lessonsTotal > 0) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ProgressBar(
                        value: module.lessonFraction,
                        height: 6,
                        semanticsLabel: 'Lições do módulo',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${module.lessonsDone} de ${module.lessonsTotal} lições',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onContinue,
                icon: Icon(hasQuiz ? Icons.play_arrow_rounded : Icons.route),
                label: Text(switch (hasQuiz) {
                  false => 'Ver trilha',
                  true when fresh => 'Começar',
                  true => 'Continuar lição',
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Missões do dia num único cartão, uma por linha. Só as que abrem um
/// desafio têm seta e respondem ao toque.
class _MissionList extends StatelessWidget {
  const _MissionList({required this.missions, required this.onStart});

  final List<Mission> missions;
  final ValueChanged<Mission> onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < missions.length; i++) ...[
            if (i > 0) const Divider(indent: 64),
            _MissionRow(
              mission: missions[i],
              onTap: missions[i].quizId == null || missions[i].isDone
                  ? null
                  : () => onStart(missions[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({required this.mission, this.onTap});

  final Mission mission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = mission.isDone;
    final xp = Text(
      '+${mission.rewardXp} XP',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: done ? AppColors.muted : AppColors.amberText,
      ),
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            IconBadge(
              icon: done ? Icons.check : Icons.flag_outlined,
              color: done ? AppColors.success : AppColors.skyOnInk,
              background: done ? AppColors.successSoft : AppColors.blueSoft,
              size: 36,
              circle: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keepLastWordsTogether(mission.title),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: done ? AppColors.muted : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (done)
                        const Expanded(
                          child: Text(
                            'Concluída',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else ...[
                        Expanded(
                          child: ProgressBar(
                            value: mission.fraction,
                            height: 6,
                            semanticsLabel: 'Progresso da missão',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${mission.progress}/${mission.goal}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(width: 12),
                      xp,
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 28,
              child: onTap == null
                  ? null
                  : const Icon(Icons.chevron_right, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desafio cronometrado do dia: o âmbar fica no ícone e no XP; o botão é
/// secundário para não competir com "Continuar lição".
class _FlashCard extends StatelessWidget {
  const _FlashCard({required this.mission, this.onStart});

  final Mission mission;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final done = mission.isDone;
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBadge(
              icon: Icons.bolt,
              color: AppColors.amberText,
              background: AppColors.amberSoft,
              size: 36,
              circle: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Desafio relâmpago',
                          style: TextStyle(
                            color: AppColors.amberText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '+${mission.rewardXp} XP',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: done ? AppColors.muted : AppColors.amberText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    keepLastWordsTogether(mission.title),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: AppTheme.tonalButton,
                    onPressed: onStart,
                    icon: Icon(
                      done ? Icons.check : Icons.timer_outlined,
                      size: 18,
                    ),
                    label: Text(done ? 'Concluído' : 'Começar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
