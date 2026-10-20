import 'package:flutter/material.dart';

/// Cores do Gabaritei: azul-marinho de "planta técnica", azul de ação e âmbar.
///
/// O app é todo escuro. `ink` é o fundo mais profundo (e o texto sobre
/// âmbar); `text` é o texto principal.
class AppColors {
  AppColors._();

  /// Fundo das telas.
  static const ground = Color(0xFF0F1D33);

  /// Cartões e campos.
  static const surface = Color(0xFF1A2A45);

  /// Azul-marinho da marca: fundos de destaque e texto sobre âmbar.
  static const ink = Color(0xFF0F1D33);
  static const inkSoft = Color(0xFF26344D);

  /// Texto principal e secundário.
  static const text = Color(0xFFF1F5FB);
  static const muted = Color(0xFFAEBBD0);
  static const mutedOnInk = muted;

  /// Bordas e trilhos de barras.
  static const line = Color(0xFF33456A);
  static const track = Color(0xFF26385C);

  /// Nomes antigos dos mesmos tons, usados nas telas que já eram escuras.
  static const inkRaised = surface;
  static const inkLine = line;

  /// Ação (botões, barras, item ativo) e o tom claro dela para texto e ícones.
  static const blue = Color(0xFF3B6EF5);
  static const blueSoft = Color(0xFF1C3263);
  static const skyOnInk = Color(0xFF93B4FA);

  /// XP, sequência e conquistas.
  static const amber = Color(0xFFF59E0B);
  static const amberText = Color(0xFFFBBF24);
  static const amberOnInk = amberText;
  static const amberSoft = Color(0xFF3B2F12);

  static const success = Color(0xFF4ADE80);
  static const successSoft = Color(0xFF173B2A);
  static const successOnInk = success;
  static const error = Color(0xFFF87171);
  static const errorSoft = Color(0xFF3F1D27);
  static const errorOnInk = error;
}

/// Fontes embutidas em `assets/fonts/` (SIL Open Font License).
class AppFonts {
  AppFonts._();

  /// Títulos, nomes de nível e números em destaque (com algarismos tabulares).
  static const display = 'BricolageGrotesque';

  /// Texto corrido (padrão do app).
  static const body = 'IBMPlexSans';
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.skyOnInk,
      onPrimary: AppColors.ink,
      secondary: AppColors.amber,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.blueSoft,
      onSecondaryContainer: AppColors.text,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.muted,
      surfaceContainerHighest: AppColors.track,
      error: AppColors.error,
      outline: AppColors.line,
      outlineVariant: AppColors.line,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.ground,
      fontFamily: AppFonts.body,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.text, displayColor: AppColors.text)
          .copyWith(
            headlineMedium: base.textTheme.headlineMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
            titleMedium: base.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            bodySmall:
                base.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.track,
          disabledForegroundColor: AppColors.muted,
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.line),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.line),
        labelStyle: const TextStyle(color: AppColors.text),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.skyOnInk,
        contentTextStyle: TextStyle(color: AppColors.ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.blueSoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.skyOnInk
                : AppColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.skyOnInk
                : AppColors.muted,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}
