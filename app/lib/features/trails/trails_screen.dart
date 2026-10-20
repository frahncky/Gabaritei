import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/content.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trails ??= Dependencies.of(context).content.getTrails();
  }

  Future<void> _startQuiz(String quizId) async {
    await openQuiz(context, quizId);
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<Trail>>(
      future: _trails!,
      builder: (context, trails) {
        final trail = trails.firstWhere(
          (t) => t.id == _selectedId,
          orElse: () => trails.first,
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Trilhas', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Complete módulos para desbloquear as próximas disciplinas.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in trails)
                  ChoiceChip(
                    label: Text(t.title),
                    avatar: t.unlocked ? null : const Icon(Icons.lock_outline, size: 16),
                    selected: t.id == trail.id,
                    onSelected: (_) => setState(() => _selectedId = t.id),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(trail.title, style: Theme.of(context).textTheme.titleLarge),
                ),
                Text(
                  '${trail.modulesDone} de ${trail.modulesTotal} módulos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(value: trail.fraction),
            const SizedBox(height: 16),
            if (!trail.unlocked) ...[
              _LockedTrailNotice(trail: trail, trails: trails),
              const SizedBox(height: 12),
            ],
            for (final module in trail.modules) ...[
              _ModuleTile(
                module: module,
                onStart: module.quizId == null || module.status == ModuleStatus.locked
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
    final required = trails.where((t) => t.id == trail.requiresTrailId).firstOrNull;
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
            background: Color(0xFFDCFCE7),
            child: Icon(Icons.check, size: 20, color: AppColors.success),
          ),
        ModuleStatus.current => _Badge(
            background: AppColors.blue,
            child: Text(
              '${module.order}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ModuleStatus.locked => const _Badge(
            background: AppColors.track,
            child: Icon(Icons.lock_outline, size: 18, color: AppColors.muted),
          ),
      };
    }

    final title = module.isFinalExam ? module.title : '${module.order}. ${module.title}';
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
                            color: isLocked ? AppColors.muted : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (status == ModuleStatus.done && !module.isFinalExam)
                    _Stars(count: module.stars),
                ],
              ),
              if (isCurrent) ...[
                if (module.lessonsTotal > 0) ...[
                  const SizedBox(height: 12),
                  ProgressBar(value: module.lessonFraction, height: 6),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onStart,
                  child: Text(onStart == null ? 'Lições em breve' : 'Continuar lição'),
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
