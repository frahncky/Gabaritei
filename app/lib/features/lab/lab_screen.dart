import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../shared/drawings/circuit_symbols.dart';
import '../../shared/format.dart';
import 'circuit.dart';
import 'color_code.dart';
import 'color_code_view.dart';
import 'lab_painters.dart';

/// Laboratório de eletricidade: um circuito "vivo", com elétrons andando,
/// amperímetro, controles e gráfico no tempo.
class LabScreen extends StatefulWidget {
  const LabScreen({super.key, this.initialMode = LabMode.ohm});

  final LabMode initialMode;

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen>
    with SingleTickerProviderStateMixin {
  late LabMode _mode = widget.initialMode;
  CircuitInput _input = const CircuitInput();
  final _motion = LabMotion();
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  // Código de cores: faixas montadas e a meta do desafio.
  ResistorBands _bands = const ResistorBands();
  double _target = 4700;
  final _random = math.Random();

  bool get _matched => _bands.matches(_target);

  CircuitReading get _reading => CircuitReading.solve(_mode, _input);

  double get _gaugeTarget =>
      (_reading.watched / (_mode.limit * labScaleOverLimit)).clamp(0.0, 1.05);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _ticker?.dispose();
      _ticker = null;
      _motion.snap(_gaugeTarget);
    } else {
      _ticker ??= _startTicker();
    }
  }

  Ticker _startTicker() => createTicker(_onTick)..start();

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final r = _reading;
    final currents = _mode == LabMode.paralelo
        ? [r.total, r.i1, r.i2, r.total]
        : [r.total, r.total, r.total, r.total];
    _motion.advance(dt.clamp(0, 0.1), currents, _gaugeTarget);
  }

  void _update(CircuitInput input) {
    setState(() => _input = input);
    if (_ticker == null) _motion.snap(_gaugeTarget);
  }

  void _setBands(ResistorBands bands) {
    final wasMatched = _matched;
    HapticFeedback.selectionClick();
    setState(() => _bands = bands);
    if (!wasMatched && _matched) HapticFeedback.mediumImpact();
  }

  void _nextTarget() {
    setState(() {
      double next;
      do {
        next = resistorTargets[_random.nextInt(resistorTargets.length)];
      } while (next == _target || _bands.matches(next));
      _target = next;
    });
  }

  void _setMode(LabMode mode) {
    if (mode == _mode) return;
    HapticFeedback.selectionClick();
    setState(() => _mode = mode);
    _motion.resetHistory();
    if (_ticker == null) _motion.snap(_gaugeTarget);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = _reading;
    final mode = _mode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        appBar: AppBar(title: const Text('Laboratório')),
        body: Column(
          children: [
            // Painel fixo: o circuito e o medidor ficam sempre à vista
            // enquanto o aluno mexe nos controles lá embaixo.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  _FormulaBox(formula: mode.formula),
                  const SizedBox(height: 8),
                  if (mode.hasCircuit) ...[
                    Semantics(
                      label: _circuitLabel(mode, reading),
                      excludeSemantics: true,
                      child: SizedBox(
                        height: 190,
                        width: double.infinity,
                        // Repinta a cada quadro: isolado do resto da página.
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: CircuitPainter(
                              mode: mode,
                              input: _input,
                              reading: reading,
                              motion: _motion,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _Readout(reading: reading, motion: _motion),
                  ] else ...[
                    SizedBox(
                      height: 190,
                      child: ResistorView(bands: _bands, matched: _matched),
                    ),
                    const SizedBox(height: 4),
                    ColorReadout(
                      bands: _bands,
                      target: _target,
                      matched: _matched,
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _panel(mode, reading)),
          ],
        ),
      ),
    );
  }

  /// Descrição do circuito para leitor de tela, com os valores atuais.
  String _circuitLabel(LabMode mode, CircuitReading r) {
    String ohms(double o) => '${formatDecimal(o, 0)} ohms';
    final source = 'fonte de ${formatDecimal(_input.volts, 1)} volts';
    return switch (mode) {
      LabMode.ohm => 'Circuito com $source e resistor de ${ohms(_input.r1)}',
      LabMode.potencia => 'Circuito com $source e lâmpada de '
          '${formatDecimal(LabLimits.lampWatts, 0)} watts, '
          '${ohms(_input.r1)}',
      LabMode.serie => 'Circuito em série: $source, R1 de ${ohms(_input.r1)} '
          'e R2 de ${ohms(_input.r2)}',
      LabMode.paralelo => 'Circuito em paralelo: $source, R1 de '
          '${ohms(_input.r1)} e R2 de ${ohms(_input.r2)}',
      LabMode.cores => '',
    };
  }

  Widget _panel(LabMode mode, CircuitReading reading) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _ModeTabs(selected: mode, onSelect: _setMode),
        const SizedBox(height: 20),
        Text(
          '${mode.index + 1} · ${mode.title}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          mode.idea,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          mode.tip,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 18),
        if (mode.hasCircuit) ...[
          ..._controls(mode),
          const SizedBox(height: 10),
          for (final row in _outputs(mode, reading)) ...[
            row,
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          _HistoryChart(mode: mode, motion: _motion),
        ] else
          ..._colorControls(),
      ],
    );
  }

  List<Widget> _colorControls() {
    String digit(BandColor c) => '${c.digit}';
    String multiplier(BandColor c) {
      final e = c.exponent!;
      return e >= 0
          ? '× ${formatNumber(math.pow(10, e).toInt())}'
          : '× ${formatDecimal(math.pow(10, e).toDouble(), -e)}';
    }

    String tolerance(BandColor c) {
      final t = c.tolerance!;
      final text = t == t.roundToDouble()
          ? t.toInt().toString()
          : t.toString().replaceAll('.', ',');
      return '±$text%';
    }

    return [
      ColorChallengeCard(
        target: _target,
        matched: _matched,
        onNext: _nextTarget,
      ),
      const SizedBox(height: 20),
      BandPicker(
        label: '1ª faixa · 1º dígito',
        meaning: digit,
        options: BandColor.firstDigits,
        selected: _bands.first,
        onSelect: (c) => _setBands(_bands.copyWith(first: c)),
      ),
      const SizedBox(height: 18),
      BandPicker(
        label: '2ª faixa · 2º dígito',
        meaning: digit,
        options: BandColor.digits,
        selected: _bands.second,
        onSelect: (c) => _setBands(_bands.copyWith(second: c)),
      ),
      const SizedBox(height: 18),
      BandPicker(
        label: '3ª faixa · multiplicador',
        meaning: multiplier,
        options: BandColor.multipliers,
        selected: _bands.multiplier,
        onSelect: (c) => _setBands(_bands.copyWith(multiplier: c)),
      ),
      const SizedBox(height: 18),
      BandPicker(
        label: '4ª faixa · tolerância',
        meaning: tolerance,
        options: BandColor.tolerances,
        selected: _bands.tolerance,
        onSelect: (c) => _setBands(_bands.copyWith(tolerance: c)),
      ),
    ];
  }

  List<Widget> _controls(LabMode mode) {
    final volts = _LabSlider(
      label: 'Tensão da fonte',
      value: _input.volts,
      min: 0,
      max: LabLimits.maxVolts,
      divisions: 48,
      unit: 'V',
      digits: 1,
      onChanged: (v) => _update(_input.copyWith(volts: v)),
    );
    _LabSlider ohms(String label, double value, ValueChanged<double> set) =>
        _LabSlider(
          label: label,
          value: value,
          min: LabLimits.minOhms,
          max: LabLimits.maxOhms,
          divisions: 19,
          unit: 'Ω',
          digits: 0,
          onChanged: set,
        );

    return switch (mode) {
      LabMode.ohm => [
          volts,
          ohms(
              'Resistência', _input.r1, (v) => _update(_input.copyWith(r1: v))),
        ],
      LabMode.potencia => [
          volts,
          ohms('Resistência da lâmpada', _input.r1,
              (v) => _update(_input.copyWith(r1: v))),
        ],
      LabMode.cores => const <Widget>[],
      LabMode.serie || LabMode.paralelo => [
          volts,
          ohms('R₁', _input.r1, (v) => _update(_input.copyWith(r1: v))),
          ohms('R₂', _input.r2, (v) => _update(_input.copyWith(r2: v))),
        ],
    };
  }

  /// Leituras do circuito. As de corrente ganham a barra âmbar, a mesma cor
  /// dos elétrons no desenho.
  List<Widget> _outputs(LabMode mode, CircuitReading r) {
    const ampScale = LabLimits.fuseAmps * labScaleOverLimit;
    String amps(double a) => '${formatDecimal(a, 2)} A';
    String volts(double v) => '${formatDecimal(v, 1)} V';
    String ohms(double o) => '${formatDecimal(o, o < 10 ? 1 : 0)} Ω';
    _OutputBar current(String label, double a) =>
        _OutputBar(label, a / ampScale, amps(a), current: true);

    return switch (mode) {
      LabMode.cores => const <Widget>[],
      LabMode.ohm => [
          current('Corrente', r.total),
          _OutputBar('Potência no resistor', r.power / 60,
              '${formatDecimal(r.power, 1)} W'),
        ],
      LabMode.serie => [
          _OutputBar('Tensão em R₁', _ratio(r.v1, _input.volts), volts(r.v1)),
          _OutputBar('Tensão em R₂', _ratio(r.v2, _input.volts), volts(r.v2)),
          _OutputBar('Resistência equivalente', r.req / 200, ohms(r.req)),
          current('Corrente', r.total),
        ],
      LabMode.paralelo => [
          current('Corrente em R₁', r.i1),
          current('Corrente em R₂', r.i2),
          _OutputBar('Resistência equivalente', r.req / 100, ohms(r.req)),
          current('Corrente total', r.total),
        ],
      LabMode.potencia => [
          current('Corrente', r.total),
          _OutputBar(
              'Potência',
              r.power / (LabLimits.lampWatts * labScaleOverLimit),
              '${formatDecimal(r.power, 1)} W'),
          _OutputBar('Brilho', r.power / LabLimits.lampWatts,
              formatPercent(math.min(r.power / LabLimits.lampWatts, 1))),
        ],
    };
  }

  static double _ratio(double a, double b) => b == 0 ? 0 : a / b;
}

class _FormulaBox extends StatelessWidget {
  const _FormulaBox({required this.formula});

  final String formula;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        color: AppColors.surface,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Text(
          formula,
          key: ValueKey(formula),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.fallback,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.skyOnInk,
          ),
        ),
      ),
    );
  }
}

/// Amperímetro (ou wattímetro) com ponteiro, e a leitura ao lado.
class _Readout extends StatelessWidget {
  const _Readout({required this.reading, required this.motion});

  final CircuitReading reading;
  final LabMotion motion;

  @override
  Widget build(BuildContext context) {
    final mode = reading.mode;
    final value = mode.watchesPower
        ? '${formatDecimal(reading.power, 1)} W'
        : '${formatDecimal(reading.total, 2)} A';
    final limit = mode.watchesPower
        ? 'nominal: ${formatDecimal(LabLimits.lampWatts, 0)} W'
        : 'fusível: ${formatDecimal(LabLimits.fuseAmps, 0)} A';
    final (statusText, statusColor) = switch (reading.status) {
      LabStatus.off => ('sem tensão', AppColors.muted),
      LabStatus.safe => ('seguro', AppColors.success),
      LabStatus.near => ('perto do limite', AppColors.amberText),
      LabStatus.over => (
          mode.watchesPower ? 'a lâmpada queimaria!' : 'o fusível queimaria!',
          AppColors.error
        ),
    };

    return Row(
      children: [
        Semantics(
          label: '${mode.watchesPower ? 'Wattímetro' : 'Amperímetro'}: $value',
          excludeSemantics: true,
          child: RepaintBoundary(
            child: CustomPaint(
              size: const Size.square(104),
              painter:
                  GaugePainter(motion, unit: mode.watchesPower ? 'W' : 'A'),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  fontSize: 34,
                  color: AppColors.text,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                limit,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              // O AnimatedDefaultTextStyle troca o estilo inteiro: a reserva
              // de glifos precisa vir junto.
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.fallback,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: statusColor,
                ),
                child: Text(statusText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Abas de assunto. Selecionada: fundo tonal azul e contorno de estado.
class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.selected, required this.onSelect});

  final LabMode selected;
  final ValueChanged<LabMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final mode in LabMode.values) ...[
          if (mode.index > 0) const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              selected: mode == selected,
              button: true,
              // O fundo anima por fora; a tinta do toque fica por cima dele,
              // num Material transparente.
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                decoration: BoxDecoration(
                  color:
                      mode == selected ? AppColors.blueSoft : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                  border: mode == selected
                      ? Border.all(color: AppColors.skyOnInk, width: 1.2)
                      : null,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => onSelect(mode),
                    borderRadius: BorderRadius.circular(AppRadii.small),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            mode.tab,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: mode == selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: mode == selected
                                  ? AppColors.text
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LabSlider extends StatelessWidget {
  const _LabSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.digits,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final int digits;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = '${formatDecimal(value, digits)} $unit';
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 14)),
            ),
            Text(
              text,
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: labSliderTheme(context),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            semanticFormatterCallback: (_) => text,
            onChanged: (v) {
              if (v != value) HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

/// Controles deslizantes dos laboratórios: trilho azul suave e cursor claro,
/// sem competir com o desenho.
SliderThemeData labSliderTheme(BuildContext context) =>
    SliderTheme.of(context).copyWith(
      activeTrackColor: AppColors.progress,
      inactiveTrackColor: AppColors.track,
      thumbColor: AppColors.skyOnInk,
      overlayColor: AppColors.skyOnInk.withValues(alpha: 0.12),
      trackHeight: 5,
      tickMarkShape: SliderTickMarkShape.noTickMark,
      showValueIndicator: ShowValueIndicator.never,
    );

/// Linha de resultado: nome, barra proporcional e valor.
class _OutputBar extends StatelessWidget {
  const _OutputBar(this.label, this.fraction, this.value,
      {this.current = false});

  final String label;
  final double fraction;
  final String value;

  /// Corrente elétrica: barra âmbar, como os elétrons no circuito.
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ),
        Container(
          width: 72,
          height: 10,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.track,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fraction.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              builder: (context, f, _) => FractionallySizedBox(
                widthFactor: f,
                heightFactor: 1,
                child: ColoredBox(
                  color: current ? CircuitColors.current : AppColors.progress,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.text,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// Gráfico da grandeza vigiada nos últimos 6 segundos.
class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.mode, required this.motion});

  final LabMode mode;
  final LabMotion motion;

  @override
  Widget build(BuildContext context) {
    final power = mode.watchesPower;
    final limit = power
        ? 'nominal ${formatDecimal(LabLimits.lampWatts, 0)} W'
        : 'fusível ${formatDecimal(LabLimits.fuseAmps, 0)} A';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            power ? 'Potência nos últimos 6 s' : 'Corrente nos últimos 6 s',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Gráfico da ${power ? 'potência' : 'corrente'} nos '
                'últimos 6 segundos, com o limite de $limit',
            excludeSemantics: true,
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: HistoryChartPainter(
                    motion,
                    quantity: power ? 'P' : 'I',
                    unit: power ? 'W' : 'A',
                    limit: mode.limit,
                    limitLabel: limit,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
