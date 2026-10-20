import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/student.dart';
import '../../shared/format.dart';
import '../../shared/widgets.dart';

typedef _RankingData = ({Student student, List<RankingEntry> entries});

/// Ranking da turma com pódio, filtro de período e aviso da liga.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  RankingPeriod _period = RankingPeriod.week;
  Future<_RankingData>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _load(Dependencies.of(context), _period);
  }

  static Future<_RankingData> _load(
      AppDependencies deps, RankingPeriod period) async {
    final (student, entries) = await (
      deps.students.getCurrentStudent(),
      deps.ranking.getClassRanking(period),
    ).wait;
    return (student: student, entries: entries);
  }

  void _changePeriod(RankingPeriod period) {
    setState(() {
      _period = period;
      _data = _load(Dependencies.of(context), period);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('Ranking', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        SegmentedButton<RankingPeriod>(
          segments: [
            for (final p in RankingPeriod.values)
              ButtonSegment(value: p, label: Text(p.label)),
          ],
          selected: {_period},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => _changePeriod(selection.first),
        ),
        const SizedBox(height: 20),
        AsyncView<_RankingData>(
          future: _data!,
          builder: (context, data) => _RankingBody(
            student: data.student,
            entries: data.entries,
          ),
        ),
      ],
    );
  }
}

class _RankingBody extends StatelessWidget {
  const _RankingBody({required this.student, required this.entries});

  final Student student;
  final List<RankingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final league = student.league;
    final nextLeague = league.index + 1 < League.values.length
        ? League.values[league.index + 1]
        : null;
    final podium = entries.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${student.className} · Liga ${league.label}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (podium.length == 3)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _PodiumPlace(entry: podium[1], height: 64)),
              const SizedBox(width: 8),
              Expanded(child: _PodiumPlace(entry: podium[0], height: 88)),
              const SizedBox(width: 8),
              Expanded(child: _PodiumPlace(entry: podium[2], height: 48)),
            ],
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.amberSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up,
                  color: AppColors.amberText, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nextLeague == null
                      ? 'Você está na Liga ${league.label}, a mais alta.'
                      : 'Os 3 primeiros sobem para a Liga ${nextLeague.label} no domingo.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final entry in entries.skip(podium.length)) ...[
          _RankingRow(entry: entry),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.entry, required this.height});

  final RankingEntry entry;
  final double height;

  @override
  Widget build(BuildContext context) {
    final first = entry.position == 1;
    return Column(
      children: [
        Avatar(
          initials: entry.initials,
          size: first ? 56 : 48,
          background: entry.isCurrentStudent ? AppColors.blue : AppColors.track,
          foreground: entry.isCurrentStudent ? Colors.white : AppColors.text,
        ),
        const SizedBox(height: 6),
        Text(
          shortName(entry.name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          '${formatNumber(entry.xp)} XP',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: first ? AppColors.amber : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: first ? null : Border.all(color: AppColors.line),
          ),
          child: Text(
            '${entry.position}',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: first ? AppColors.ink : AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.entry});

  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    final me = entry.isCurrentStudent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: me ? AppColors.blueSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: me ? AppColors.blue : AppColors.line, width: me ? 2 : 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.position}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: AppFonts.display,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Avatar(
            initials: entry.initials,
            size: 36,
            background: me ? AppColors.blue : AppColors.track,
            foreground: me ? Colors.white : AppColors.text,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              me ? '${shortName(entry.name)} (você)' : shortName(entry.name),
              style:
                  TextStyle(fontWeight: me ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
          Text(
            '${formatNumber(entry.xp)} XP',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.display,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
