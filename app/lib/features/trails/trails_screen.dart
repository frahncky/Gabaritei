import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../domain/services/course_catalog.dart';
import '../../domain/services/question_generator.dart';
import '../../shared/widgets.dart';
import '../quiz/quiz_screen.dart';

/// Trilhas de estudo: uma aba por disciplina e a lista de módulos.
class TrailsScreen extends StatefulWidget {
  const TrailsScreen({super.key, required this.onDataChanged});

  /// Chamado depois de um desafio, para recarregar o progresso.
  final VoidCallback onDataChanged;

  @override
  State<TrailsScreen> createState() => _TrailsScreenState();
}

class _TrailsScreenState extends State<TrailsScreen> {
  Future<List<Trail>>? _trails;
  String? _selectedId;
  TechnicalCourse _course = TechnicalCourse.electrotechnics;
  bool _restored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trails ??= Dependencies.of(context).content.getTrails();
    if (!_restored) {
      final saved = PageStorage.of(context).readState(context,
          identifier: 'course-selection');
      if (saved is TechnicalCourse) _course = saved;
      final discipline = PageStorage.of(context).readState(context,
          identifier: 'discipline-selection');
      if (discipline is String) _selectedId = discipline;
      _restored = true;
    }
  }

  Future<void> _startQuiz(String quizId) async {
    await openQuiz(context, quizId);
    if (!mounted) return;
    setState(() {
      _trails = Dependencies.of(context).content.getTrails();
    });
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<Trail>>(
      future: _trails!,
      onRetry: () => setState(() {
        _trails = Dependencies.of(context).content.getTrails();
      }),
      builder: (context, trails) {
        final course = CourseCatalog.forType(_course);
        final courseTrails = CourseCatalog.trailsFor(_course, trails);
        final completed = courseTrails.where((t) =>
            t.modules.every((m) => m.status == ModuleStatus.done)).length;
        if (courseTrails.isEmpty) return const Text('Nenhuma disciplina disponível.');
        final trail = courseTrails.firstWhere(
          (t) => t.id == _selectedId,
          orElse: () => courseTrails.first,
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Cursos e disciplinas', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Escolha o curso para estudar suas disciplinas.'),
            const SizedBox(height: 16),
            const Text('Curso'),
            DropdownButton<TechnicalCourse>(
              key: const ValueKey('course-selector'),
              value: _course,
              isExpanded: true,
              items: [
                for (final item in CourseCatalog.courses)
                  DropdownMenuItem(value: item.type, child: Text(item.title)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _course = value;
                  _selectedId = null;
                });
                PageStorage.of(context).writeState(context, value,
                    identifier: 'course-selection');
                PageStorage.of(context).writeState(context, null,
                    identifier: 'discipline-selection');
              },
            ),
            Text(course.description),
            const SizedBox(height: 4),
            Text(course.objective, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Text('$completed de ${courseTrails.length} disciplinas concluídas'),
            const SizedBox(height: 6),
            ProgressBar(value: completed / courseTrails.length),
            const SizedBox(height: 16),
            const Text('Disciplina'),
            DropdownButton<String>(
              key: const ValueKey('discipline-selector'),
              value: trail.id,
              isExpanded: true,
              items: [
                for (final item in courseTrails)
                  DropdownMenuItem(
                    value: item.id,
                    child: Text(item.unlocked ? item.title : '${item.title} · Bloqueada',
                        overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedId = value);
                PageStorage.of(context).writeState(context, value,
                    identifier: 'discipline-selection');
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(trail.title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Text(
                  '${trail.modulesDone} de ${trail.modulesTotal} módulos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(value: trail.fraction),
            const SizedBox(height: 8),
            const Text('Acerte pelo menos 70% para liberar o próximo módulo.'),
            const SizedBox(height: 16),
            if (!trail.unlocked) ...[
              _LockedTrailNotice(trail: trail, trails: trails),
              const SizedBox(height: 12),
            ],
            for (final module in trail.modules) ...[
              _ModuleTile(
                module: module,
                onStart: !trail.unlocked || module.quizId == null ||
                        module.status == ModuleStatus.locked
                    ? null
                    : () => _startQuiz(module.quizId!),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _LockedTrailNotice extends StatelessWidget {
  const _LockedTrailNotice({required this.trail, required this.trails});

  final Trail trail;
  final List<Trail> trails;

  @override
  Widget build(BuildContext context) {
    final required =
        trails.where((t) => t.id == trail.requiresTrailId).firstOrNull;
    final message = required == null
        ? 'Conclua a trilha anterior para desbloquear esta.'
        : 'Conclua a trilha ${required.title} para desbloquear esta.';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.track,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module, this.onStart});

  final TrailModule module;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final status = module.status;
    final isCurrent = status == ModuleStatus.current;
    final isLocked = status == ModuleStatus.locked;

    final Widget leading;
    if (module.isFinalExam) {
      leading = _Badge(
        background: isLocked ? AppColors.track : AppColors.amberSoft,
        child: Icon(
          Icons.emoji_events_outlined,
          size: 20,
          color: isLocked ? AppColors.muted : AppColors.amberText,
        ),
      );
    } else {
      leading = switch (status) {
        ModuleStatus.done => const _Badge(
            background: AppColors.successSoft,
            child: Icon(Icons.check, size: 20, color: AppColors.success),
          ),
        ModuleStatus.current => _Badge(
            background: AppColors.blue,
            child: Text(
              '${module.order}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ModuleStatus.locked => const _Badge(
            background: AppColors.track,
            child: Icon(Icons.lock_outline, size: 18, color: AppColors.muted),
          ),
      };
    }

    final title =
        module.isFinalExam ? module.title : '${module.order}. ${module.title}';
    final subtitle = switch (status) {
      _ when module.isFinalExam => module.subtitle,
      ModuleStatus.done =>
        'Concluído · ${module.stars} ${module.stars == 1 ? 'estrela' : 'estrelas'}',
      ModuleStatus.current => module.lessonsTotal == 0
          ? module.subtitle
          : '${module.subtitle} · ${module.lessonsDone} de ${module.lessonsTotal} lições',
      ModuleStatus.locked => 'Bloqueado',
    };

    return Card(
      shape: isCurrent
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.blue, width: 2),
            )
          : null,
      color: isLocked ? AppColors.ground : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // No módulo atual quem abre o desafio é o botão.
        onTap: isCurrent ? null : onStart,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isLocked ? AppColors.muted : AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (status == ModuleStatus.done && !module.isFinalExam)
                    _Stars(count: module.stars),
                ],
              ),
              if (!isLocked && module.lessonText != null) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Estudar o conteúdo'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(module.lessonText!),
                    ),
                  ],
                ),
              ],
              if (isCurrent) ...[
                if (module.lessonsTotal > 0) ...[
                  const SizedBox(height: 12),
                  ProgressBar(value: module.lessonFraction, height: 6),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onStart,
                  child: Text(
                      onStart == null ? 'Lições em breve' : 'Continuar lição'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: child,
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count de 3 estrelas',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < count ? Icons.star : Icons.star_border,
              size: 18,
              color: i < count ? AppColors.amber : AppColors.line,
            ),
        ],
      ),
    );
  }
}
