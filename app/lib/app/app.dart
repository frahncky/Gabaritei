import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/start/start_screen.dart';
import 'dependencies.dart';
import 'theme.dart';

class GabariteiApp extends StatelessWidget {
  const GabariteiApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return Dependencies(
      value: dependencies,
      child: MaterialApp(
        title: 'Gabaritei',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            systemNavigationBarColor: AppColors.ink,
          ),
          // A grade fica atrás do conteúdo: cada rota a recebe do tema
          // (BlueprintPageTransitionsBuilder). Aqui só o ground, por baixo
          // de tudo, para nunca haver um quadro sem fundo.
          child: ColoredBox(color: AppColors.ground, child: child!),
        ),
        home: const StartScreen(),
      ),
    );
  }
}
