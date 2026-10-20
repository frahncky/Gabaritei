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
      builder: (context, data) {
        final student = data.student;
        final medals = data.medals;
        final earned =
            medals.where((m) => student.earnedBadgeIds.contains(m.id)).length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Center(
              child: Avatar(
                initials: student.initials,
                size: 80,
                background: AppColors.blue,
                foreground: Colors.white,
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
            LevelCard(level: student.level),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                      value: formatNumber(student.totalXp), label: 'XP total'),
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
            const SizedBox(height: 24),
            SectionHeader('Dias de estudo', trailing: _streakText(student)),
            const SizedBox(height: 10),
            _StudyCalendar(studyDays: student.studyDays),
            const SizedBox(height: 24),
            SectionHeader('Medalhas', trailing: '$earned de ${medals.length}'),
            const SizedBox(height: 10),
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                // Emblema (60 x 69) + nome em até duas linhas.
                mainAxisExtent: 116,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final medal in medals)
                  _MedalTile(
                    medal: medal,
                    earned: student.earnedBadgeIds.contains(medal.id),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  static String _streakText(Student student) {
    final broken = StreakRules.isBroken(
      lastStudyDay: student.lastStudyDay,
      today: DateTime.now(),
    );
    if (broken || student.streakDays == 0) return 'sequência perdida';
    return '${student.streakDays} '
        '${student.streakDays == 1 ? 'dia seguido' : 'dias seguidos'}';
  }
}

/// Últimas cinco semanas, terminando hoje. Dias estudados em azul.
class _StudyCalendar extends StatelessWidget {
  const _StudyCalendar({required this.studyDays});

  final Set<DateTime> studyDays;

  static const _days = 35;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final studied = {for (final d in studyDays) _key(d)};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: [
            for (var i = _days - 1; i >= 0; i--)
              _DayCell(
                date: DateTime(today.year, today.month, today.day - i),
                studied: studied.contains(
                  _key(DateTime(today.year, today.month, today.day - i)),
                ),
                isToday: i == 0,
              ),
          ],
        ),
      ),
    );
  }

  static int _key(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
}

class _DayCell extends StatelessWidget {
  const _DayCell(
      {required this.date, required this.studied, required this.isToday});

  final DateTime date;
  final bool studied;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${formatShortDate(date)}: ${studied ? 'estudou' : 'não estudou'}',
      child: Container(
        decoration: BoxDecoration(
          color: studied ? AppColors.blue : AppColors.track,
          borderRadius: BorderRadius.circular(6),
          border: isToday ? Border.all(color: AppColors.amber, width: 2) : null,
        ),
      ),
    );
  }
}

class _MedalTile extends StatelessWidget {
  const _MedalTile({required this.medal, required this.earned});

  final Medal medal;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: medal.description,
      child: Column(
        children: [
          MedalBadge(medal: medal, earned: earned, size: 60),
          const SizedBox(height: 6),
          Text(
            medal.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: earned ? AppColors.text : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
