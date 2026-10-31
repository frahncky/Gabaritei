import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Troque `AppDependencies.local()` pela versão com servidor quando
  // o backend for escolhido. Nada mais precisa mudar.
  runApp(
    GabariteiApp(dependencies: await AppDependencies.local(), showSplash: true),
  );
}
