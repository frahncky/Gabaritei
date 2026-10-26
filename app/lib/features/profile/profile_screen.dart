import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/student.dart';
import '../../domain/rules/streak_rules.dart';
import '../../shared/format.dart';
import '../../shared/level_card.dart';
import '../../shared/medal_badge.dart';
import '../../shared/widgets.dart';

typedef _ProfileData = ({Student student, List<Medal> medals});

/// Perfil do aluno: estatísticas, calendário de estudo e medalhas.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<_ProfileData>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _load(Dependencies.of(context));
  }

  static Future<_ProfileData> _load(AppDependencies deps) async {
    final (student, medals) = await (
      deps.students.getCurrentStudent(),
      deps.students.getAllMedals(),
    ).wait;
    return (student: student, medals: medals);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<_ProfileData>(
      future: _data!,
      onRetry: () => setState(() => _data = _load(Dependencies.of(context))),
      builder: (context, data) {
        final student = data.student;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final streakBroken = StreakRules.isBroken(
          lastStudyDay: student.lastStudyDay,
          today: today,
        );
        final streak = streakBroken ? 0 : student.streakDays;
        // Conquistadas primeiro: o aluno vê o que já ganhou antes das metas.
        final medals = [
          ...data.medals.where((m) => student.earnedBadgeIds.contains(m.id)),
          ...data.medals.where((m) => !student.earnedBadgeIds.contains(m.id)),
        ];
        final earned =
            medals.where((m) => student.earnedBadgeIds.contains(m.id)).length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Center(
              child: Avatar(
                initials: student.initials,
                size: 80,
                background: AppColors.blueSoft,
                foreground: AppColors.skyOnInk,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              student.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${student.className} · Liga ${student.league.label}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            // O XP total já aparece no cartão de nível; aqui vai a sequência.
            LevelCard(level: student.level),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatTile(
                      value: formatNumber(streak),
                      label: streak == 1 ? 'dia seguido' : 'dias seguidos',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      value: formatNumber(student.questionsAnswered),
                      label: 'questões',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      value: formatPercent(student.accuracy),
                      label: 'de acerto',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _StudyCalendar(
              studyDays: student.studyDays,
              today: today,
              streakAlive: streak > 0,
            ),
            const SizedBox(height: 24),
            SectionHeader('Medalhas', trailing: '$earned de ${medals.length}'),
            const SizedBox(height: 10),
            _MedalGrid(medals: medals, earnedIds: student.earnedBadgeIds),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: _confirmReset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Recomeçar progresso'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmReset() async {
    final deps = Dependencies.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recomeçar progresso?'),
        content:
            const Text('XP, sequência, medalhas e missões voltam ao início. '
                'Não dá para desfazer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Recomeçar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await deps.students.resetProgress();
    if (!mounted) return;
    setState(() => _data = _load(deps));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Progresso recomeçado.')));
  }
}

/// Cinco semanas de segunda a domingo (a liga também fecha no domingo), com a
/// semana atual embaixo. Dias estudados em tom suave; só "hoje" tem contorno.
class _StudyCalendar extends StatelessWidget {
  const _StudyCalendar({
    required this.studyDays,
    required this.today,
    required this.streakAlive,
  });

  final Set<DateTime> studyDays;

  /// Data de hoje, sem horário.
  final DateTime today;

  /// A sequência ainda vale (o aluno estudou ontem ou hoje).
  final bool streakAlive;

  static const _weeks = 5;
  static const _gap = 6.0;
  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final studied = {for (final d in studyDays) _key(d)};
    final monday =
        DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final first =
        DateTime(monday.year, monday.month, monday.day - 7 * (_weeks - 1));
    DateTime dayAt(int index) =>
        DateTime(first.year, first.month, first.day + index);
    final studiedToday = studied.contains(_key(today));
    final period = '${formatShortDate(first)} a ${formatShortDate(today)}';
    final small = Theme.of(context).textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('Dias de estudo', trailing: period),
        const SizedBox(height: 10),
        Semantics(
          container: true,
          label: 'Calendário de estudo de $period',
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Células quadradas que não crescem demais em tela larga.
                      final width = (constraints.maxWidth - _gap * 6) / 7;
                      final height = math.min(width, 44.0);
                      return Column(
                        children: [
                          ExcludeSemantics(
                            child: _WeekRow(
                              stretch: false,
                              children: [
                                for (final label in _weekdays)
                                  Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: small?.copyWith(fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          for (var week = 0; week < _weeks; week++) ...[
                            if (week > 0) const SizedBox(height: _gap),
                            SizedBox(
                              height: height,
                              child: _WeekRow(
                                children: [
                                  for (var day = 0; day < 7; day++)
                                    _cell(dayAt(week * 7 + day), studied),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  const ExcludeSemantics(child: _CalendarLegend()),
                  if (!studiedToday) ...[
                    const SizedBox(height: 8),
                    Text(
                      streakAlive
                          ? 'Estude hoje para manter a sequência.'
                          : 'Estude hoje para começar uma nova sequência.',
                      style: small,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(DateTime date, Set<int> studied) {
    // Os dias que ainda vão chegar nesta semana ficam vazios.
    if (date.isAfter(today)) return const SizedBox.shrink();
    return _DayCell(
      date: date,
      studied: studied.contains(_key(date)),
      isToday: _key(date) == _key(today),
    );
  }

  static int _key(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
}

/// Sete colunas de mesma largura, alinhadas com o cabeçalho dos dias.
class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.children, this.stretch = true});

  final List<Widget> children;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: _StudyCalendar._gap),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.studied,
    required this.isToday,
  });

  final DateTime date;
  final bool studied;
  final bool isToday;

  /// Preenchimento dos dias estudados: suave, para a grade não pesar.
  static final studiedFill = AppColors.skyOnInk.withValues(alpha: 0.28);

  static const _names = [
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
    'sábado',
    'domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final status = studied
        ? 'estudou'
        : isToday
            ? 'ainda não estudou'
            : 'não estudou';
    return Semantics(
      label: '${isToday ? 'Hoje, ' : ''}${_names[date.weekday - 1]}, '
          '${formatShortDate(date)}: $status',
      excludeSemantics: true,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: studied ? studiedFill : null,
          borderRadius: BorderRadius.circular(8),
          border:
              isToday ? Border.all(color: AppColors.skyOnInk, width: 2) : null,
        ),
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday
                ? AppColors.skyOnInk
                : studied
                    ? AppColors.text
                    : AppColors.muted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    Widget item(BoxDecoration swatch, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, decoration: swatch),
            const SizedBox(width: 6),
            Text(label, style: style),
          ],
        );
    return Wrap(
      spacing: 18,
      runSpacing: 6,
      children: [
        item(
          BoxDecoration(
            color: _DayCell.studiedFill,
            borderRadius: BorderRadius.circular(4),
          ),
          'Estudou',
        ),
        item(
          BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.skyOnInk, width: 2),
          ),
          'Hoje',
        ),
      ],
    );
  }
}

/// Medalhas em linhas de mesma altura: duas colunas no celular, mais em
/// telas largas.
class _MedalGrid extends StatelessWidget {
  const _MedalGrid({required this.medals, required this.earnedIds});

  final List<Medal> medals;
  final Set<String> earnedIds;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            math.max(2, ((constraints.maxWidth + _gap) / (180 + _gap)).floor());
        return Column(
          children: [
            for (var start = 0; start < medals.length; start += columns) ...[
              if (start > 0) const SizedBox(height: _gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = start; i < start + columns; i++) ...[
                      if (i > start) const SizedBox(width: _gap),
                      Expanded(
                        child: i < medals.length
                            ? _MedalTile(
                                medal: medals[i],
                                earned: earnedIds.contains(medals[i].id),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Medalha com o critério à vista: bloqueada, o texto diz como ganhar.
class _MedalTile extends StatelessWidget {
  const _MedalTile({required this.medal, required this.earned});

  final Medal medal;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    // Mesmo cartão para todas: a medalha apagada e o cadeado já dizem que
    // está bloqueada.
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDetails(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          child: Column(
            children: [
              MedalBadge(medal: medal, earned: earned, size: 56),
              const SizedBox(height: 6),
              Text(
                medal.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                keepLastWordsTogether(medal.description),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: AppColors.muted,
                ),
              ),
              if (earned) ...[
                const Spacer(),
                const SizedBox(height: 8),
                const Text(
                  'Conquistada',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDetails(BuildContext context) => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: MedalBadge(medal: medal, earned: earned, size: 72),
          title: Text(medal.name, textAlign: TextAlign.center),
          content: Text(
            earned
                ? medal.description
                : '${medal.description}\n\nAinda não conquistada.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
}
