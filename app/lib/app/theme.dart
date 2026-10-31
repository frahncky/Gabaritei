import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'page_transitions.dart';
import 'tokens.dart';

// Os tokens moram em tokens.dart (sem dependências do app) para que
// page_transitions.dart e shared/ usem as cores sem importar este arquivo
// de volta. Quem importa theme.dart continua vendo AppColors e companhia.
export 'tokens.dart';

class AppTheme {
  AppTheme._();

  /// Ação secundária ao lado de uma principal: fundo tonal, sem borda.
  /// Use em `FilledButton(style: AppTheme.tonalButton, ...)`.
  static final tonalButton = FilledButton.styleFrom(
    backgroundColor: AppColors.blueSoft,
    foregroundColor: AppColors.skyOnInk,
    disabledBackgroundColor: AppColors.track,
    disabledForegroundColor: AppColors.muted,
    minimumSize: const Size(64, 48),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
    ),
    textStyle: AppTextStyles.label,
  );

  /// Contorno do estado "selecionado" ou "é você" (alternativa marcada no
  /// desafio, linha do aluno no ranking), sobre [AppColors.blueSoft].
  static const selectedBorder = BorderSide(
    color: AppColors.skyOnInk,
    width: 1.5,
  );

  /// Transições padrão de cada plataforma, com a página sobre o fundo de
  /// grade ([BlueprintPageTransitionsBuilder]). O fundo da transição é o
  /// `ground`: sem isso, a página que sai pisca na cor `surface`.
  static const _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: BlueprintPageTransitionsBuilder(
        PredictiveBackPageTransitionsBuilder(fallbackColor: AppColors.ground),
      ),
      TargetPlatform.iOS: BlueprintPageTransitionsBuilder(
        CupertinoPageTransitionsBuilder(),
      ),
      TargetPlatform.macOS: BlueprintPageTransitionsBuilder(
        CupertinoPageTransitionsBuilder(),
      ),
      TargetPlatform.windows: BlueprintPageTransitionsBuilder(
        ZoomPageTransitionsBuilder(backgroundColor: AppColors.ground),
      ),
      TargetPlatform.linux: BlueprintPageTransitionsBuilder(
        ZoomPageTransitionsBuilder(backgroundColor: AppColors.ground),
      ),
      TargetPlatform.fuchsia: BlueprintPageTransitionsBuilder(
        ZoomPageTransitionsBuilder(backgroundColor: AppColors.ground),
      ),
    },
  );

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.skyOnInk,
          onPrimary: AppColors.ink,
          primaryContainer: AppColors.blueSoft,
          onPrimaryContainer: AppColors.text,
          secondary: AppColors.amber,
          onSecondary: AppColors.ink,
          secondaryContainer: AppColors.blueSoft,
          onSecondaryContainer: AppColors.text,
          surface: AppColors.surface,
          onSurface: AppColors.text,
          onSurfaceVariant: AppColors.muted,
          surfaceContainerLowest: AppColors.ground,
          surfaceContainerLow: AppColors.surface,
          surfaceContainer: AppColors.surface,
          surfaceContainerHigh: AppColors.surfaceHigh,
          surfaceContainerHighest: AppColors.track,
          error: AppColors.error,
          onError: AppColors.ink,
          outline: AppColors.line,
          outlineVariant: AppColors.line,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Transparente: o fundo (ground + grade) vem de cada rota, por
      // [_pageTransitions]. Telas não pintam o próprio fundo.
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: _pageTransitions,
      fontFamily: AppFonts.body,
      // Ω, → e outros glifos que a Bricolage não tem caem no IBM Plex Sans.
      fontFamilyFallback: AppFonts.fallback,
    );

    TextStyle? display(TextStyle? style, FontWeight weight) => style?.copyWith(
      fontFamily: AppFonts.display,
      fontWeight: weight,
      color: AppColors.text,
    );

    const cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.large)),
    );
    const controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
    );
    final textTheme = base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );

    return base.copyWith(
      textTheme: textTheme.copyWith(
        headlineMedium: display(
          textTheme.headlineMedium,
          FontWeight.w800,
        )?.copyWith(letterSpacing: -0.5),
        headlineSmall: display(textTheme.headlineSmall, FontWeight.w700),
        titleLarge: display(textTheme.titleLarge, FontWeight.w700),
        titleMedium: display(textTheme.titleMedium, FontWeight.w600),
        bodySmall: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: display(
          textTheme.titleLarge,
          FontWeight.w700,
        )?.copyWith(fontSize: 18),
      ),
      // Cartões tonais: a diferença de tom separa do fundo, sem contorno.
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.onBlue,
          disabledBackgroundColor: AppColors.track,
          disabledForegroundColor: AppColors.muted,
          minimumSize: const Size.fromHeight(48),
          shape: controlShape,
          textStyle: AppTextStyles.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.line),
          shape: controlShape,
          textStyle: AppTextStyles.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.skyOnInk,
          minimumSize: const Size(48, 48),
          shape: controlShape,
          textStyle: AppTextStyles.label,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceHigh,
          foregroundColor: AppColors.text,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: controlShape,
          textStyle: AppTextStyles.label,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(AppTextStyles.label),
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.line)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.blueSoft
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.text
                : AppColors.muted,
          ),
        ),
      ),
      // Sem seleção: contorno discreto. Selecionado: fundo tonal e ✓.
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.blueSoft,
        disabledColor: AppColors.ground,
        checkmarkColor: AppColors.skyOnInk,
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const BorderSide(color: AppColors.blueSoft)
              : const BorderSide(color: AppColors.line),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.small)),
        ),
        labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.text),
        secondaryLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.text,
        ),
        iconTheme: const IconThemeData(color: AppColors.muted, size: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        textColor: AppColors.text,
        collapsedTextColor: AppColors.text,
        iconColor: AppColors.skyOnInk,
        collapsedIconColor: AppColors.muted,
        shape: Border(),
        collapsedShape: Border(),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.muted,
        titleTextStyle: AppTextStyles.body.copyWith(color: AppColors.text),
        subtitleTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w400,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.progress,
        linearTrackColor: AppColors.track,
        circularTrackColor: AppColors.track,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.text),
        actionTextColor: AppColors.skyOnInk,
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.text),
        decoration: const BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.small)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: cardShape,
        titleTextStyle: display(textTheme.titleLarge, FontWeight.w700),
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        dragHandleColor: AppColors.line,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceHigh,
        textStyle: AppTextStyles.body.copyWith(color: AppColors.text),
        shape: controlShape,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.body.copyWith(color: AppColors.text),
        menuStyle: const MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.surfaceHigh),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.amber,
        textColor: AppColors.ink,
        textStyle: AppTextStyles.labelSmall.copyWith(fontSize: 11),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.blueSoft,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTextStyles.labelSmall.copyWith(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.text
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
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.blueSoft,
        selectedIconTheme: const IconThemeData(color: AppColors.skyOnInk),
        unselectedIconTheme: const IconThemeData(color: AppColors.muted),
        selectedLabelTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.text,
        ),
        unselectedLabelTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.muted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
        floatingLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.skyOnInk,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
        helperStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.muted),
        errorStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
          borderSide: BorderSide(color: AppColors.line),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
          borderSide: BorderSide(color: AppColors.skyOnInk, width: 1.5),
        ),
      ),
      sliderTheme: SliderThemeData(
        valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.ink,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.skyOnInk,
        selectionHandleColor: AppColors.skyOnInk,
      ),
    );
  }
}
