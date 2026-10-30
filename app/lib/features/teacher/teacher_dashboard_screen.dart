import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../domain/models/teacher.dart';
import '../../domain/services/question_generator.dart';
import '../../shared/format.dart';
import '../../shared/widgets.dart';
import '../quiz/question_visual.dart';

typedef _ModuleOption = ({String id, String label});

typedef _DashboardData = ({
  List<({String id, String name})> classes,
  ClassOverview overview,
  List<_ModuleOption> modules,
});

/// Painel do professor: indicadores da turma, acerto por tópico, alunos
/// que precisam de atenção e criação de desafio rápido.
///
/// Pensado para desktop/tablet; em telas estreitas as colunas empilham.
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  Future<_DashboardData>? _data;
  String? _classId;
  final Set<String> _reminded = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _load(Dependencies.of(context), null);
  }

  static Future<_DashboardData> _load(
      AppDependencies deps, String? classId) async {
    final classes = await deps.teacher.getClasses();
    final (overview, trails) = await (
      deps.teacher.getClassOverview(classId ?? classes.first.id),
      deps.content.getTrails(),
    ).wait;
    return (
      classes: classes,
      overview: overview,
      modules: [
        for (final trail in trails.where((t) => t.unlocked))
          for (final module in trail.modules.where((m) => !m.isFinalExam))
            (id: module.id, label: '${trail.title} · Módulo ${module.order}'),
      ],
    );
  }

  void _selectClass(String classId) {
    setState(() {
      _classId = classId;
      _data = _load(Dependencies.of(context), _classId);
    });
  }

  Future<void> _sendReminder(StudentAlert alert) async {
    await Dependencies.of(context).teacher.sendReminder(alert.studentId);
    if (!mounted) return;
    setState(() => _reminded.add(alert.studentId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lembrete enviado para ${alert.name}.')),
    );
  }

  Future<void> _publish(String classId, NewChallengeDraft draft) async {
    final deps = Dependencies.of(context);
    await deps.teacher.publishChallenge(classId, draft);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Desafio "${draft.title}" publicado para a turma.')),
    );
    setState(() {
      _data = _load(deps, classId);
    });
  }

  Future<void> _saveGeneratedQuestion(Question question) async {
    await Dependencies.of(context).content.saveQuestion(question);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Questão adicionada ao banco da sessão.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel do professor')),
      body: AsyncView<_DashboardData>(
        future: _data!,
        onRetry: () => setState(
          () => _data = _load(Dependencies.of(context), _classId),
        ),
        builder: (context, data) => LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final overview = data.overview;

            final left = [
              _TopicsCard(topics: overview.topics),
              const SizedBox(height: 16),
              _AlertsCard(
                alerts: overview.alerts,
                reminded: _reminded,
                onRemind: _sendReminder,
              ),
            ];
            final right = [
              _QuestionGeneratorCard(onSave: _saveGeneratedQuestion),
              const SizedBox(height: 16),
              _QuickChallengeCard(
                modules: data.modules,
                onPublish: (draft) => _publish(overview.classId, draft),
              ),
              const SizedBox(height: 16),
              _ActiveChallengesCard(challenges: overview.activeChallenges),
            ];

            return ListView(
              padding: EdgeInsets.all(wide ? 24 : 16),
              children: [
                _Header(
                  overview: overview,
                  classes: data.classes,
                  onSelectClass: _selectClass,
                ),
                const SizedBox(height: 16),
                _StatsRow(overview: overview, columns: wide ? 4 : 2),
                const SizedBox(height: 16),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: Column(children: left)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: Column(children: right)),
                    ],
                  )
                else ...[
                  ...left,
                  const SizedBox(height: 16),
                  ...right,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.overview,
    required this.classes,
    required this.onSelectClass,
  });

  final ClassOverview overview;
  final List<({String id, String name})> classes;
  final ValueChanged<String> onSelectClass;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${overview.className} · ${overview.studentCount} alunos',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text('Visão geral da turma',
                style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<String>(
            initialValue: overview.classId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Turma'),
            items: [
              for (final c in classes)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (id) {
              if (id != null && id != overview.classId) onSelectClass(id);
            },
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.overview, required this.columns});

  final ClassOverview overview;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StatTile(
        value: '${overview.activeThisWeek} / ${overview.studentCount}',
        label: 'Alunos ativos na semana',
        icon: Icons.group_outlined,
      ),
      StatTile(
        value: formatPercent(overview.averageAccuracy),
        label: 'Média de acerto',
        icon: Icons.check_circle_outline,
      ),
      StatTile(
        value: formatNumber(overview.challengesCompleted),
        label: 'Desafios concluídos',
        icon: Icons.bolt,
        iconColor: AppColors.amberText,
        iconBackground: AppColors.amberSoft,
      ),
      StatTile(
        value: '${overview.averageStreak.round()} dias',
        label: 'Sequência média',
        icon: Icons.local_fire_department,
        iconColor: AppColors.amberText,
        iconBackground: AppColors.amberSoft,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final t in tiles) SizedBox(width: width, child: t)],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, this.trailing, required this.children});

  final String title;
  final String? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title, trailing: trailing),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TopicsCard extends StatelessWidget {
  const _TopicsCard({required this.topics});

  final List<TopicPerformance> topics;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Acerto por tópico',
      trailing: 'Abaixo de 60% sugere retomar em aula',
      children: [
        for (final topic in topics) ...[
          Row(
            children: [
              Expanded(child: Text(topic.topic)),
              if (topic.needsReview) ...[
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: AppColors.error),
                const SizedBox(width: 4),
              ],
              Text(
                formatPercent(topic.accuracy),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: topic.needsReview ? AppColors.error : AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ProgressBar(
            value: topic.accuracy,
            color: topic.needsReview ? AppColors.error : AppColors.blue,
            semanticsLabel: 'Acerto em ${topic.topic}',
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({
    required this.alerts,
    required this.reminded,
    required this.onRemind,
  });

  final List<StudentAlert> alerts;
  final Set<String> reminded;
  final ValueChanged<StudentAlert> onRemind;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return _Panel(
      title: 'Alunos que precisam de atenção',
      children: [
        if (alerts.isEmpty) const Text('Nenhum aluno em alerta nesta turma.'),
        for (final alert in alerts) ...[
          Row(
            children: [
              Avatar(initials: initialsOf(alert.name), size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(alert.reason),
                    Text(
                      'Último acesso: ${formatRelativeDay(alert.lastAccess, now)} · '
                      'Acerto ${formatPercent(alert.accuracy)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              reminded.contains(alert.studentId)
                  ? const TextButton(onPressed: null, child: Text('Enviado'))
                  : TextButton(
                      onPressed: () => onRemind(alert),
                      child: const Text('Enviar lembrete'),
                    ),
            ],
          ),
          const Divider(height: 24),
        ],
      ],
    );
  }
}

/// Área de autoria assistida: gera um rascunho revisável antes de salvá-lo.
class _QuestionGeneratorCard extends StatefulWidget {
  const _QuestionGeneratorCard({required this.onSave});

  final Future<void> Function(Question question) onSave;

  @override
  State<_QuestionGeneratorCard> createState() => _QuestionGeneratorCardState();
}

class _QuestionGeneratorCardState extends State<_QuestionGeneratorCard> {
  TechnicalCourse _course = TechnicalCourse.electronics;
  late String _topic = QuestionGenerator.topicsFor(_course).first;
  late String _unit = QuestionGenerator.unitsFor(_topic).first.label;
  int _sequence = 1;
  Question? _draft;
  bool _saving = false;

  Color get _courseColor => switch (_course) {
        TechnicalCourse.electronics => const Color(0xFFA78BCA),
        TechnicalCourse.electrotechnics => AppColors.amberText,
        TechnicalCourse.automation => const Color(0xFF72B7C5),
        TechnicalCourse.mechatronics => const Color(0xFF7EBC91),
      };

  void _generate() {
    if (_saving) return;
    setState(() {
      _draft = QuestionGenerator.generate(
        topic: _topic,
        unit: _unit == '__applied__' ? null : _unit,
        sequence: _sequence++,
      );
    });
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(draft);
      if (mounted && identical(_draft, draft)) setState(() => _draft = null);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Não foi possível salvar. O rascunho foi mantido; tente novamente.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    return _Panel(
      title: 'Motor de criação de questões',
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _courseColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _courseColor.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: _courseColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text(
                  _course.label,
                  style: TextStyle(
                      color: _courseColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Gere um rascunho com gabarito, explicação e recurso visual. Revise antes de publicar.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<TechnicalCourse>(
          initialValue: _course,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Curso técnico',
            prefixIcon: Icon(Icons.hub_outlined, color: _courseColor),
          ),
          items: [
            for (final course in TechnicalCourse.values)
              DropdownMenuItem(
                value: course,
                child: Text(course.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (course) {
            if (course == null) return;
            setState(() {
              _course = course;
              _topic = QuestionGenerator.topicsFor(course).first;
              _unit = QuestionGenerator.unitsFor(_topic).first.label;
              _draft = null;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey(_course),
          initialValue: _topic,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Disciplina'),
          items: [
            for (final topic in QuestionGenerator.topicsFor(_course))
              DropdownMenuItem(
                value: topic,
                child: Text(topic, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (topic) {
            if (topic == null) return;
            setState(() {
              _topic = topic;
              _unit = QuestionGenerator.unitsFor(topic).first.label;
              _draft = null;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('$_course-$_topic'),
          initialValue: _unit,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Assunto'),
          items: [
            const DropdownMenuItem(value: '__applied__',
              child: Text('Exercício aplicado da disciplina')), 
            for (final unit in QuestionGenerator.unitsFor(_topic))
              DropdownMenuItem(
                value: unit.label,
                child: Text(unit.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (unit) => setState(() {
            _unit = unit ?? _unit;
            _draft = null;
          }),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _saving ? null : _generate,
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text('Gerar questão'),
        ),
        if (draft != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.ground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draft.prompt,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                for (var i = 0; i < draft.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${String.fromCharCode(65 + i)}. ${draft.options[i]}${i == draft.correctIndex ? '  ✓ gabarito' : ''}',
                      style: TextStyle(
                          color: i == draft.correctIndex
                              ? AppColors.success
                              : AppColors.text),
                    ),
                  ),
                const SizedBox(height: 8),
                Text('Explicação: ${draft.explanation}'),
                if (draft.hint != null) Text('Dica: ${draft.hint}'),
                if (draft.figure != null || draft.visual != null) ...[
                  const SizedBox(height: 12),
                  QuestionVisualCard(figure: draft.figure, visual: draft.visual),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.add_task_outlined),
            label: Text(_saving ? 'Salvando…' : 'Adicionar ao banco'),
          ),
        ],
      ],
    );
  }


}

class _QuickChallengeCard extends StatefulWidget {
  const _QuickChallengeCard({required this.modules, required this.onPublish});

  final List<_ModuleOption> modules;
  final Future<void> Function(NewChallengeDraft draft) onPublish;

  @override
  State<_QuickChallengeCard> createState() => _QuickChallengeCardState();
}

class _QuickChallengeCardState extends State<_QuickChallengeCard> {
  static const _questionCounts = [5, 10, 15];
  static const _rewards = [50, 80, 100, 150];

  /// Medalha que o professor pode liberar no desafio rápido.
  static const _medalId = 'rei-paralelo';

  final _title = TextEditingController();
  late String? _moduleId = widget.modules.firstOrNull?.id;
  int _questions = _questionCounts.first;
  int _reward = 80;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _withMedal = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _canPublish =>
      !_sending && _title.text.trim().isNotEmpty && _moduleId != null;

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    await widget.onPublish(NewChallengeDraft(
      title: _title.text.trim(),
      moduleId: _moduleId!,
      questionCount: _questions,
      rewardXp: _reward,
      deadline: _deadline,
      badgeId: _withMedal ? _medalId : null,
    ));
    if (!mounted) return;
    _title.clear();
    setState(() => _withMedal = _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Desafio rápido',
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'Ex.: Associação em paralelo',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _moduleId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Trilha e módulo'),
          items: [
            for (final m in widget.modules)
              DropdownMenuItem(
                  value: m.id,
                  child: Text(m.label, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (id) => setState(() => _moduleId = id),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _questions,
                decoration: const InputDecoration(labelText: 'Questões'),
                items: [
                  for (final n in _questionCounts)
                    DropdownMenuItem(value: n, child: Text('$n')),
                ],
                onChanged: (n) => setState(() => _questions = n ?? _questions),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _reward,
                decoration: const InputDecoration(labelText: 'Recompensa'),
                items: [
                  for (final xp in _rewards)
                    DropdownMenuItem(value: xp, child: Text('$xp XP')),
                ],
                onChanged: (xp) => setState(() => _reward = xp ?? _reward),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style:
              OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: _pickDeadline,
          icon: const Icon(Icons.event_outlined, size: 18),
          label: Text('Prazo: até ${formatShortDate(_deadline)}'),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _withMedal,
          onChanged: (v) => setState(() => _withMedal = v ?? false),
          title:
              const Text('Liberar medalha "Rei do Paralelo" com 90% ou mais'),
        ),
        const SizedBox(height: 4),
        FilledButton(
          onPressed: _canPublish ? _submit : null,
          child: Text(_sending ? 'Publicando…' : 'Publicar para a turma'),
        ),
      ],
    );
  }
}

class _ActiveChallengesCard extends StatelessWidget {
  const _ActiveChallengesCard({required this.challenges});

  final List<ActiveChallenge> challenges;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Desafios ativos',
      children: [
        if (challenges.isEmpty) const Text('Nenhum desafio ativo.'),
        for (final challenge in challenges) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                'até ${formatShortDate(challenge.deadline)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ProgressBar(value: challenge.fraction),
          const SizedBox(height: 4),
          Text(
            '${challenge.completedBy} de ${challenge.classSize} alunos concluíram',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
