import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/student.dart';
import '../../shared/format.dart';
import '../../shared/widgets.dart';

typedef _RankingData = ({
  Student student,
  List<RankingEntry> entries,
  RankingPeriod period,
});

/// Quantos sobem de liga no domingo (os do pódio da semana).
const _promotionSlots = 3;

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
    // O período vai junto dos dados para o texto nunca descrever a lista
    // anterior enquanto a nova carrega.
    return (student: student, entries: entries, period: period);
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
          onRetry: () => setState(
            () => _data = _load(Dependencies.of(context), _period),
          ),
          builder: (context, data) => _RankingBody(
            student: data.student,
            entries: data.entries,
            period: data.period,
          ),
        ),
      ],
    );
  }
}

class _RankingBody extends StatelessWidget {
  const _RankingBody({
    required this.student,
    required this.entries,
    required this.period,
  });

  final Student student;
  final List<RankingEntry> entries;
  final RankingPeriod period;

  @override
  Widget build(BuildContext context) {
    final league = student.league;
    final nextLeague = league.index + 1 < League.values.length
        ? League.values[league.index + 1]
        : null;
    final podium = entries.take(_promotionSlots).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${student.className} · Liga ${league.label}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (podium.length == _promotionSlots)
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
        // Aviso da liga: tonal neutro, para o 1º lugar do pódio seguir como
        // o único âmbar cheio da tela.
        Container(
          padding: AppSpacing.card,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.trending_up,
                  color: AppColors.amberText, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _leagueText(league, nextLeague)),
                      ..._positionSpans(nextLeague),
                    ],
                  ),
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

  String _leagueText(League league, League? next) {
    if (next == null) return 'Você está na Liga ${league.label}, a mais alta.';
    // A subida usa o ranking da semana, mesmo quando o aluno olha outro.
    final who = period == RankingPeriod.week
        ? 'Os $_promotionSlots primeiros'
        : 'Os $_promotionSlots primeiros da semana';
    return '$who sobem para a Liga ${next.label} no domingo.';
  }

  /// Onde o aluno está e, na semana, quanto falta para a zona de subida.
  List<InlineSpan> _positionSpans(League? next) {
    final me = entries.where((e) => e.isCurrentStudent).firstOrNull;
    if (me == null) return const [];
    const bold = TextStyle(fontWeight: FontWeight.w700);
    final place = [
      const TextSpan(text: '\nVocê está em '),
      TextSpan(text: '${me.position}º', style: bold),
    ];
    if (period != RankingPeriod.week || next == null) {
      final where = switch (period) {
        RankingPeriod.week => 'na semana',
        RankingPeriod.month => 'no mês',
        RankingPeriod.all => 'no geral',
      };
      return [...place, TextSpan(text: ' $where.')];
    }
    if (me.position <= _promotionSlots) {
      return [...place, const TextSpan(text: ': dentro da zona de subida!')];
    }
    // Um XP a mais que o último do pódio garante passar, mesmo no empate.
    final gap = entries[_promotionSlots - 1].xp - me.xp + 1;
    return [
      ...place,
      const TextSpan(text: '. '),
      TextSpan(
        text: '${gap == 1 ? 'Falta' : 'Faltam'} ${formatNumber(gap)} XP',
        style: bold,
      ),
      const TextSpan(text: ' para passar o $_promotionSlotsº lugar.'),
    ];
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
        _RankAvatar(
          initials: entry.initials,
          size: first ? 56 : 48,
          me: entry.isCurrentStudent,
        ),
        const SizedBox(height: 6),
        Text(
          entry.isCurrentStudent
              ? '${shortName(entry.name)} (você)'
              : shortName(entry.name),
          maxLines: 2,
          textAlign: TextAlign.center,
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
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.medium)),
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

/// Avatar do ranking. O do próprio aluno ganha um anel azul-claro em vez
/// de cor cheia: destaca sem disputar com o pódio âmbar.
class _RankAvatar extends StatelessWidget {
  const _RankAvatar({
    required this.initials,
    required this.size,
    required this.me,
  });

  final String initials;
  final double size;
  final bool me;

  @override
  Widget build(BuildContext context) {
    return Avatar(
      initials: initials,
      size: size,
      background: me ? AppColors.blueSoft : AppColors.track,
      foreground: me ? AppColors.skyOnInk : AppColors.text,
      ring: me ? AppColors.skyOnInk : null,
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.entry});

  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    final me = entry.isCurrentStudent;
    // Linhas tonais; a do aluno usa o par "selecionado" do app.
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: me ? AppColors.blueSoft : AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.medium)),
        border:
            me ? const Border.fromBorderSide(AppTheme.selectedBorder) : null,
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
          _RankAvatar(initials: entry.initials, size: 36, me: me),
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
