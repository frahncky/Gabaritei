import 'package:flutter/material.dart';

/// Cores do Gabaritei: azul-marinho de "planta técnica", azul de ação e âmbar.
///
/// O app é todo escuro e calmo: superfícies tonais (sem borda em todo
/// cartão), um acento forte por bloco e cor cheia só no que é ação (azul) ou
/// conquista (âmbar). `ink` é o fundo mais profundo (e o texto sobre âmbar);
/// `text` é o texto principal.
class AppColors {
  AppColors._();

  /// Fundo das telas. É o mesmo tom do ícone e do splash: não mude sozinho.
  static const ground = Color(0xFF0F1D33);

  /// Cartões e campos (tonal: separa do fundo sem precisar de borda).
  static const surface = Color(0xFF182841);

  /// Um degrau acima de [surface]: pílulas, blocos dentro de cartões,
  /// snackbars e menus.
  static const surfaceHigh = Color(0xFF203250);

  /// Azul-marinho da marca: fundos de destaque e texto sobre âmbar.
  static const ink = Color(0xFF0F1D33);
  static const inkSoft = Color(0xFF243450);

  /// Texto principal (sem o branco puro, que ofusca no marinho) e secundário.
  /// Ambos passam de 4,5:1 sobre [ground], [surface], [surfaceHigh] e
  /// [blueSoft].
  static const text = Color(0xFFE3E8F0);
  static const muted = Color(0xFFA0ADC2);
  static const mutedOnInk = muted;

  /// Divisórias, contornos de botão e campo; trilho das barras.
  static const line = Color(0xFF2A3B59);
  static const track = Color(0xFF243552);

  /// Nomes antigos dos mesmos tons, usados nas telas que já eram escuras.
  static const inkRaised = surface;
  static const inkLine = line;

  /// Ação: botão principal e item ativo. Só em elementos pequenos ou que
  /// pedem toque; para preencher áreas grandes use [progress] ou [blueSoft].
  static const blue = Color(0xFF4467C4);

  /// Texto e ícone sobre [blue] (5,3:1).
  static const onBlue = Color(0xFFFFFFFF);

  /// Fundo de item selecionado (chip, aba, indicador da navegação).
  static const blueSoft = Color(0xFF213656);

  /// Azul claro para texto, ícone e link sobre fundos escuros.
  static const skyOnInk = Color(0xFF9FB6E4);

  /// Preenchimento de barras de progresso e gráficos: azul suave, que não
  /// compete com o botão de ação (4,2:1 sobre [track]).
  static const progress = Color(0xFF7D97CF);

  /// XP, sequência e conquistas.
  static const amber = Color(0xFFE0A23E);
  static const amberText = Color(0xFFE9BC63);
  static const amberOnInk = amberText;
  static const amberSoft = Color(0xFF2F2A21);

  /// Barra de XP: do âmbar ao dourado claro.
  static const xpGradient = LinearGradient(colors: [amber, amberText]);

  static const success = Color(0xFF74C095);
  static const successSoft = Color(0xFF1C3829);
  static const successOnInk = success;
  static const error = Color(0xFFE08585);
  static const errorSoft = Color(0xFF3A242A);
  static const errorOnInk = error;

  /// Cores fixas do símbolo da marca, iguais às do ícone e do splash já
  /// gerados (`tool/brand_assets_test.dart`). Não seguem os ajustes da
  /// paleta da interface.
  static const markAmber = Color(0xFFF59E0B);
  static const markTrace = Color(0xFF93B4FA);
}

/// Fontes embutidas em `assets/fonts/` (SIL Open Font License).
class AppFonts {
  AppFonts._();

  /// Títulos, nomes de nível e números em destaque (com algarismos tabulares).
  ///
  /// Não tem letras gregas: Ω e afins caem em [body] pela reserva do tema.
  static const display = 'BricolageGrotesque';

  /// Texto corrido (padrão do app). Versão completa, com grego (Ω, µ, Δ),
  /// setas, operadores (≈, −, ×) e índices (₁, ₂).
  static const body = 'IBMPlexSans';

  /// Reserva para glifos que a fonte do texto não tem.
  static const fallback = [body];
}

/// Raios de canto.
class AppRadii {
  AppRadii._();

  /// Chips, selos e pílulas pequenas.
  static const small = 10.0;

  /// Botões, campos, alternativas e blocos dentro de cartões.
  static const medium = 14.0;

  /// Cartões.
  static const large = 18.0;
}

/// Espaçamentos recorrentes (múltiplos de 4 dp).
class AppSpacing {
  AppSpacing._();

  /// Margens das telas com rolagem do aluno.
  static const screen = EdgeInsets.fromLTRB(20, 16, 20, 32);

  /// Entre uma seção e a seguinte.
  static const section = 28.0;

  /// Entre o título de uma seção e o conteúdo dela.
  static const header = 12.0;

  /// Entre cartões de uma mesma lista.
  static const item = 8.0;

  /// Respiro interno dos cartões.
  static const card = EdgeInsets.all(16);
}

/// Estilos de texto fora do `textTheme`, para componentes.
class AppTextStyles {
  AppTextStyles._();

  /// Rótulo de botão, chip e aba.
  static const label = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    letterSpacing: 0.1,
  );

  /// Rótulo pequeno (chips, navegação, dicas).
  static const labelSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontWeight: FontWeight.w500,
    fontSize: 13,
  );

  /// Texto de campos, menus e mensagens.
  static const body = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 15,
  );
}
