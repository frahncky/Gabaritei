import 'package:flutter/material.dart';

import '../app/theme.dart';

// O fundo de grade mora em app/page_transitions.dart (o tema precisa dele);
// fica exposto aqui junto dos outros widgets reutilizáveis.
export '../app/page_transitions.dart' show BlueprintBackground, BlueprintGrid;

/// Junta as últimas palavras de um título com espaço inseparável, para a
/// quebra de linha não deixar uma palavra sozinha ("Lei de / Ohm").
///
/// Une a última palavra à anterior e, se esta for curta (de, em, da...),
/// também à que vem antes: "Resolver 5 questões de / Lei de Ohm".
String keepLastWordsTogether(String text) {
  final words = text.split(' ');
  if (words.length < 3) return text;
  var glue = 1;
  if (words[words.length - 2].length <= 3 && words.length > 3) glue = 2;
  final head = words.sublist(0, words.length - glue - 1).join(' ');
  final tail = words.sublist(words.length - glue - 1).join(' ');
  return '$head $tail';
}

/// Barra de progresso arredondada (XP, trilhas, missões).
///
/// O padrão é o azul suave [AppColors.progress]: barra informa, não chama
/// para a ação. A barra de XP usa [AppColors.xpGradient].
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.progress,
    this.trackColor = AppColors.track,
    this.height = 8,
    this.semanticsLabel,
    this.gradient,
  });

  /// De 0 a 1.
  final double value;
  final Color color;
  final Color trackColor;
  final double height;
  final String? semanticsLabel;

  /// Preenchimento em degradê (substitui [color]), como a barra de XP.
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final fill = gradient;
    if (fill != null) {
      final radius = BorderRadius.circular(height / 2);
      return Semantics(
        label: semanticsLabel,
        value: '${(value.clamp(0, 1) * 100).round()}%',
        child: Container(
          height: height,
          decoration: BoxDecoration(color: trackColor, borderRadius: radius),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0, 1).toDouble(),
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: fill, borderRadius: radius),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1).toDouble(),
        minHeight: height,
        color: color,
        backgroundColor: trackColor,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}

/// Cartão pequeno com um número em destaque.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor = AppColors.skyOnInk,
    this.iconBackground = AppColors.blueSoft,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (icon != null) ...[
              IconBadge(
                icon: icon!,
                color: iconColor,
                background: iconBackground,
                size: 40,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppFonts.display,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Título de seção com texto auxiliar opcional à direita e uma linha de
/// explicação opcional embaixo.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.subtitle});

  final String title;
  final String? trailing;

  /// Diz para que serve a seção, quando o título sozinho não basta.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: theme.titleMedium),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              trailing!,
              style: theme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ],
    );
    if (subtitle == null) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        const SizedBox(height: 4),
        Text(subtitle!, style: theme.bodySmall),
      ],
    );
  }
}

/// Ícone dentro de um fundo tonal arredondado (status, atalho, estatística).
///
/// O par de cores segue o significado: azul para ação/navegação, âmbar para
/// XP e conquistas, verde/vermelho para acerto/erro, neutro para bloqueado.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.skyOnInk,
    this.background = AppColors.blueSoft,
    this.size = 40,
    this.circle = false,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  /// Círculo (nós de trilha, status) em vez de quadrado arredondado.
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.55),
    );
  }
}

/// Pílula tonal com ícone e texto curto (sequência, medalhas, prazos).
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AppColors.skyOnInk,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.small)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo com as iniciais de uma pessoa.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.background = AppColors.track,
    this.foreground = AppColors.text,
    this.ring,
  });

  final String initials;
  final double size;
  final Color background;
  final Color foreground;

  /// Contorno de destaque (o próprio aluno no ranking), sem encher de cor.
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final ring = this.ring;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: ring == null ? null : Border.all(color: ring, width: 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Carrega dados assíncronos mostrando "carregando" e erros de forma
/// padronizada. Evita repetir FutureBuilder em todas as telas.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.future,
    required this.builder,
    this.onRetry,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 36),
                  const SizedBox(height: 12),
                  const Text(
                    'Não foi possível carregar este conteúdo.',
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Carregando…'),
              ],
            ),
          );
        }
        return builder(context, snapshot.requireData);
      },
    );
  }
}
