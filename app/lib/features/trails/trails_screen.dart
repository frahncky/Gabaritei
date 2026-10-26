import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../domain/services/question_generator.dart';
import '../../shared/widgets.dart';
import '../quiz/quiz_screen.dart';

/// Trilhas de estudo, em três partes: escolher a trilha, avançar pelos
/// módulos dela e consultar o mapa do curso técnico.
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
  TechnicalCourse _course = TechnicalCourse.electronics;
  String? _selectedDiscipline;

  /// Chaves no [PageStorage] da rota do aluno. O shell recria esta aba
  /// depois de um desafio para recarregar o progresso; guardando a escolha
  /// fora do estado, o aluno volta para a trilha e o curso em que estava.
  static const _trailKey = 'trails.selectedId';
  static const _courseKey = 'trails.course';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_trails == null) {
      final storage = PageStorage.maybeOf(context);
      _selectedId =
          storage?.readState(context, identifier: _trailKey) as String?;
      _course = storage?.readState(context, identifier: _courseKey)
              as TechnicalCourse? ??
          _course;
      _trails = Dependencies.of(context).content.getTrails();
    }
  }

  void _selectTrail(String id) {
    setState(() => _selectedId = id);
    PageStorage.maybeOf(context)
        ?.writeState(context, id, identifier: _trailKey);
  }

  void _selectCourse(TechnicalCourse course) {
    setState(() {
      _course = course;
      _selectedDiscipline = null;
    });
    PageStorage.maybeOf(context)
        ?.writeState(context, course, identifier: _courseKey);
  }

  Future<void> _startQuiz(String quizId) async {
    await openQuiz(context, quizId);
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<Trail>>(
      future: _trails!,
      onRetry: () => setState(
          () => _trails = Dependencies.of(context).content.getTrails()),
      builder: (context, trails) {
        final trail = trails.firstWhere(
          (t) => t.id == _selectedId,
          orElse: () => trails.first,
        );
        final textTheme = Theme.of(context).textTheme;
        return ListView(
          padding: AppSpacing.screen,
          children: [
            Text('Trilhas', style: textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Escolha uma trilha e avance módulo por módulo.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _TrailPicker(
              trails: trails,
              selectedId: trail.id,
              // Trilhas bloqueadas continuam consultáveis para que o aluno
              // veja claramente qual requisito falta.
              onSelected: _selectTrail,
            ),
            const SizedBox(height: AppSpacing.section),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(trail.title, style: textTheme.titleLarge),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${trail.modulesDone} de ${_modules(trail.modulesTotal)}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(value: trail.fraction, semanticsLabel: trail.title),
            const SizedBox(height: 20),
            if (!trail.unlocked) ...[
              _LockedTrailNotice(trail: trail, trails: trails),
              const SizedBox(height: 16),
            ],
            for (var i = 0; i < trail.modules.length; i++)
              _ModuleStep(
                module: trail.modules[i],
                isFirst: i == 0,
                isLast: i == trail.modules.length - 1,
                onStart: trail.modules[i].quizId == null ||
                        trail.modules[i].status == ModuleStatus.locked
                    ? null
                    : () => _startQuiz(trail.modules[i].quizId!),
              ),
            const SizedBox(height: AppSpacing.section + 8),
            const SectionHeader(
              'Mapa do curso',
              subtitle: 'Tudo o que cada curso técnico estuda, para consultar '
                  'antes de a disciplina virar trilha.',
            ),
            const SizedBox(height: AppSpacing.header),
            _CourseMap(
              course: _course,
              selectedDiscipline: _selectedDiscipline,
              onCourseChanged: _selectCourse,
              onDisciplineSelected: (discipline) => setState(
                () => _selectedDiscipline =
                    _selectedDiscipline == discipline ? null : discipline,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Grade de trilhas em duas colunas: nome, progresso e cadeado.
class _TrailPicker extends StatelessWidget {
  const _TrailPicker({
    required this.trails,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Trail> trails;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget cell(int i) => i < trails.length
        ? _TrailOption(
            trail: trails[i],
            selected: trails[i].id == selectedId,
            onTap: () => onSelected(trails[i].id),
          )
        : const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < trails.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.item),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cell(i)),
                const SizedBox(width: AppSpacing.item),
                Expanded(child: cell(i + 1)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TrailOption extends StatelessWidget {
  const _TrailOption({
    required this.trail,
    required this.selected,
    required this.onTap,
  });

  final Trail trail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !trail.unlocked;
    final done = trail.modulesTotal > 0 && trail.fraction >= 1;
    final status = locked
        ? 'Bloqueada'
        : done
            ? 'Concluída'
            : '${trail.modulesDone} de ${_modules(trail.modulesTotal)}';

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.blueSoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          side: selected
              ? const BorderSide(color: AppColors.skyOnInk, width: 1.5)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        trail.title,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: locked ? AppColors.muted : AppColors.text,
                        ),
                      ),
                    ),
                    if (locked)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.lock_outline,
                            size: 16, color: AppColors.muted),
                      )
                    else if (selected)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.check_circle,
                            size: 16, color: AppColors.skyOnInk),
                      ),
                  ],
                ),
                const Spacer(),
                const SizedBox(height: 10),
                if (!locked) ...[
                  ProgressBar(value: trail.fraction, height: 4),
                  const SizedBox(height: 6),
                ],
                Text(
                  status,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Um módulo no caminho da trilha. O fio à esquerda liga os módulos como um
/// circuito: aceso até onde o aluno chegou. Só o módulo atual vira cartão,
/// com o botão de continuar.
class _ModuleStep extends StatelessWidget {
  const _ModuleStep({
    required this.module,
    required this.isFirst,
    required this.isLast,
    this.onStart,
  });

  final TrailModule module;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onStart;

  static const _node = 36.0;

  @override
  Widget build(BuildContext context) {
    final status = module.status;
    final isCurrent = status == ModuleStatus.current;
    final isLocked = status == ModuleStatus.locked;
    final isDone = status == ModuleStatus.done;
    // Altura do centro do nó, alinhado ao título do conteúdo.
    final nodeTop = isCurrent ? 9.0 : 6.0;
    final wireDone = AppColors.progress.withValues(alpha: 0.7);
    // O fio que chega ao nó acende quando o módulo já foi alcançado.
    final wireIn = isLocked ? AppColors.line : wireDone;
    final wireOut = isDone ? wireDone : AppColors.line;

    final Widget node;
    if (module.isFinalExam) {
      node = IconBadge(
        icon: Icons.emoji_events_outlined,
        color: isLocked ? AppColors.muted : AppColors.amberText,
        background: isLocked ? AppColors.surface : AppColors.amberSoft,
        size: _node,
        circle: true,
      );
    } else {
      node = switch (status) {
        ModuleStatus.done => const IconBadge(
            icon: Icons.check,
            color: AppColors.success,
            background: AppColors.successSoft,
            size: _node,
            circle: true,
          ),
        ModuleStatus.current => const IconBadge(
            icon: Icons.play_arrow_rounded,
            color: AppColors.onBlue,
            background: AppColors.blue,
            size: _node,
            circle: true,
          ),
        ModuleStatus.locked => const IconBadge(
            icon: Icons.lock_outline,
            color: AppColors.muted,
            background: AppColors.surface,
            size: _node,
            circle: true,
          ),
      };
    }

    final title =
        module.isFinalExam ? module.title : '${module.order}. ${module.title}';
    final Widget content = isCurrent
        ? _CurrentModuleCard(module: module, title: title, onStart: onStart)
        : _ModuleRow(module: module, title: title, onTap: onStart);

    return Stack(
      children: [
        if (!isFirst)
          Positioned(
            left: _node / 2 - 1,
            width: 2,
            top: 0,
            height: nodeTop + _node / 2,
            child: ColoredBox(color: wireIn),
          ),
        if (!isLast)
          Positioned(
            left: _node / 2 - 1,
            width: 2,
            top: nodeTop + _node / 2,
            bottom: 0,
            child: ColoredBox(color: wireOut),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: nodeTop), child: node),
              const SizedBox(width: 12),
              Expanded(child: content),
            ],
          ),
        ),
      ],
    );
  }
}

/// Módulo concluído, bloqueado ou prova final: linha simples, sem cartão.
class _ModuleRow extends StatelessWidget {
  const _ModuleRow({required this.module, required this.title, this.onTap});

  final TrailModule module;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = module.status;
    final isLocked = status == ModuleStatus.locked;
    final isDone = status == ModuleStatus.done;
    final subtitle = switch (status) {
      _ when module.isFinalExam => keepLastWordsTogether(module.subtitle),
      ModuleStatus.done => onTap == null ? 'Concluído' : 'Concluído · refazer',
      ModuleStatus.locked => 'Bloqueado · ${module.subtitle}',
      ModuleStatus.current => module.subtitle,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Row(
            children: [
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
              if (isDone && !module.isFinalExam) ...[
                const SizedBox(width: 8),
                _Stars(count: module.stars),
              ],
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Módulo em andamento: o único cartão do caminho e a ação principal da tela.
class _CurrentModuleCard extends StatelessWidget {
  const _CurrentModuleCard({
    required this.module,
    required this.title,
    this.onStart,
  });

  final TrailModule module;
  final String title;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 2),
            Text(module.subtitle, style: Theme.of(context).textTheme.bodySmall),
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
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onStart,
              icon: Icon(onStart == null
                  ? Icons.hourglass_empty_rounded
                  : Icons.play_arrow_rounded),
              label: Text(switch (onStart) {
                null => 'Lições em breve',
                _ when module.lessonsDone == 0 => 'Começar',
                _ => 'Continuar lição',
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mapa curricular consultável antes de uma disciplina ganhar suas lições.
/// A fonte é a mesma matriz usada pelo gerador de questões do professor.
class _CourseMap extends StatelessWidget {
  const _CourseMap({
    required this.course,
    required this.selectedDiscipline,
    required this.onCourseChanged,
    required this.onDisciplineSelected,
  });

  final TechnicalCourse course;
  final String? selectedDiscipline;
  final ValueChanged<TechnicalCourse> onCourseChanged;
  final ValueChanged<String> onDisciplineSelected;

  @override
  Widget build(BuildContext context) {
    final disciplines = QuestionGenerator.topicsFor(course);
    final unitCount = disciplines.fold<int>(
      0,
      (total, discipline) =>
          total + QuestionGenerator.unitsFor(discipline).length,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Curso', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in TechnicalCourse.values)
                      ChoiceChip(
                        label: Text(item.label.replaceFirst('Técnico em ', '')),
                        selected: item == course,
                        onSelected: (_) => onCourseChanged(item),
                      ),
                  ],
                ),
              ],
            ),
          ),
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text(
              'Ver disciplinas e unidades',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${disciplines.length} disciplinas · $unitCount unidades',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            children: [
              for (final discipline in disciplines) ...[
                const Divider(indent: 16, endIndent: 16),
                _DisciplineRow(
                  discipline: discipline,
                  expanded: discipline == selectedDiscipline,
                  onTap: () => onDisciplineSelected(discipline),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Disciplina do mapa: abre as unidades logo abaixo, no mesmo lugar.
class _DisciplineRow extends StatelessWidget {
  const _DisciplineRow({
    required this.discipline,
    required this.expanded,
    required this.onTap,
  });

  final String discipline;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final units = QuestionGenerator.unitsFor(discipline);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          expanded: expanded,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        discipline,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              expanded ? FontWeight.w600 : FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${units.length} '
                      '${units.length == 1 ? 'unidade' : 'unidades'}',
                      style: textTheme.bodySmall,
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: Column(
              children: [
                for (var index = 0; index < units.length; index++) ...[
                  if (index > 0) const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              units[index].label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(units[index].objective,
                                style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
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
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < count ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 18,
              color: i < count ? AppColors.amber : AppColors.muted,
            ),
        ],
      ),
    );
  }
}

/// "1 módulo", "6 módulos".
String _modules(int count) => '$count ${count == 1 ? 'módulo' : 'módulos'}';
