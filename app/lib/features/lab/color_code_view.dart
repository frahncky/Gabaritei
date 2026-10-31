import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'color_code.dart';

/// Cor de cada faixa, como aparece num resistor de verdade.
const _paint = <BandColor, Color>{
  BandColor.preto: Color(0xFF1B1B1B),
  BandColor.marrom: Color(0xFF8B4A1C),
  BandColor.vermelho: Color(0xFFE53935),
  BandColor.laranja: Color(0xFFFB8C00),
  BandColor.amarelo: Color(0xFFFDD835),
  BandColor.verde: Color(0xFF43A047),
  BandColor.azul: Color(0xFF1E88E5),
  BandColor.violeta: Color(0xFF8E24AA),
  BandColor.cinza: Color(0xFF9E9E9E),
  BandColor.branco: Color(0xFFFAFAFA),
  BandColor.dourado: Color(0xFFD4AF37),
  BandColor.prata: Color(0xFFC0C0C0),
};

Color _onBand(Color band) =>
    band.computeLuminance() > 0.35 ? AppColors.ink : AppColors.text;

/// Resistor grande com as quatro faixas; as cores trocam com animação e o
/// corpo brilha quando o desafio é cumprido.
class ResistorView extends StatelessWidget {
  const ResistorView({super.key, required this.bands, required this.matched});

  final ResistorBands bands;
  final bool matched;

  @override
  Widget build(BuildContext context) {
    Widget band(BandColor color) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 16,
          color: _paint[color],
        );

    return Semantics(
      label: 'Resistor com faixas ${bands.first.label}, ${bands.second.label}, '
          '${bands.multiplier.label} e ${bands.tolerance.label}: '
          '${formatOhms(bands.ohms)}',
      excludeSemantics: true,
      child: Center(
        child: SizedBox(
          width: 320,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Terminais.
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8C2CF),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 210,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(38),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success
                          .withValues(alpha: matched ? 0.45 : 0),
                      blurRadius: matched ? 28 : 0,
                      spreadRadius: matched ? 2 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF3E2B8),
                              Color(0xFFD9BE85),
                              Color(0xFFB99A5E),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 34),
                          band(bands.first),
                          const SizedBox(width: 14),
                          band(bands.second),
                          const SizedBox(width: 14),
                          band(bands.multiplier),
                          const Spacer(),
                          band(bands.tolerance),
                          const SizedBox(width: 34),
                        ],
                      ),
                      // Reflexo, para dar volume.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.12),
                            ],
                            stops: const [0, 0.45, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Valor lido nas faixas, faixa de tolerância e situação do desafio.
class ColorReadout extends StatelessWidget {
  const ColorReadout({
    super.key,
    required this.bands,
    required this.target,
    required this.matched,
  });

  final ResistorBands bands;
  final double target;
  final bool matched;

  @override
  Widget build(BuildContext context) {
    final tolerance = bands.tolerancePercent;
    final tolText = tolerance == tolerance.roundToDouble()
        ? tolerance.toInt().toString()
        : tolerance.toString().replaceAll('.', ',');

    // Altura mínima igual à do medidor das outras abas, para o painel não pular.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 104),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              formatOhms(bands.ohms),
              key: ValueKey(bands.ohms),
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
                fontSize: 34,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            '±$tolText% · de ${formatOhms(bands.minOhms)} a '
            '${formatOhms(bands.maxOhms)}',
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          // O AnimatedDefaultTextStyle troca o estilo inteiro: sem a reserva,
          // o "Ω" da meta sairia fora da fonte do app.
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.fallback,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: matched ? AppColors.success : AppColors.skyOnInk,
            ),
            child: Text(
              matched ? 'acertou o desafio!' : 'meta: ${formatOhms(target)}',
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma faixa do resistor: rótulo e as cores possíveis para ela.
class BandPicker extends StatelessWidget {
  const BandPicker({
    super.key,
    required this.label,
    required this.meaning,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String label;

  /// O que a cor escolhida vale nesta posição (ex.: "4", "× 100", "±5%").
  final String Function(BandColor color) meaning;
  final List<BandColor> options;
  final BandColor selected;
  final ValueChanged<BandColor> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ),
            Text(
              '${selected.label} = ${meaning(selected)}',
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Cada cor tem área de toque de 48 dp com o círculo de 32 no meio:
        // a folga da área já separa os círculos (16 dp), sem espaçamento
        // extra. Em 360 dp cabem 6 por linha.
        Wrap(
          children: [
            for (final color in options)
              Semantics(
                button: true,
                selected: color == selected,
                label: '${color.label}, ${meaning(color)}',
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(color),
                  child: SizedBox.square(
                    dimension: 48,
                    child: Center(
                      child: _Swatch(
                        paint: _paint[color]!,
                        selected: color == selected,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Círculo de 32 dp com a cor da faixa; a escolhida ganha contorno e ✓.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.paint, required this.selected});

  final Color paint;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: paint,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.skyOnInk : AppColors.line,
          width: selected ? 3 : 1.5,
        ),
      ),
      child:
          selected ? Icon(Icons.check, size: 16, color: _onBand(paint)) : null,
    );
  }
}

/// Meta do momento e botão para sortear outra.
class ColorChallengeCard extends StatelessWidget {
  const ColorChallengeCard({
    super.key,
    required this.target,
    required this.matched,
    required this.onNext,
  });

  final double target;
  final bool matched;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Cartão tonal: o fundo verde já marca o acerto, sem contorno.
        color: matched ? AppColors.successSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              matched ? Icons.check_circle : Icons.track_changes,
              key: ValueKey(matched),
              size: 32,
              color: matched ? AppColors.success : AppColors.skyOnInk,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Desafio',
                  style: TextStyle(
                    color: AppColors.skyOnInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  matched
                      ? 'Acertou! Esse é o resistor de ${formatOhms(target)}.'
                      : 'Monte um resistor de ${formatOhms(target)}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onNext,
            child: Text(matched ? 'Próximo' : 'Trocar'),
          ),
        ],
      ),
    );
  }
}
