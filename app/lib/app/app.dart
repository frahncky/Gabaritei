import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/start/start_screen.dart';
import '../shared/widgets.dart';
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
          child: Stack(
            children: [child!, const Positioned.fill(child: BlueprintGrid())],
          ),
        ),
        home: const StartScreen(),
      ),
    );
  }
}
