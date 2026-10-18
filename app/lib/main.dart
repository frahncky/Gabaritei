import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/dependencies.dart';

void main() {
  // Troque `AppDependencies.inMemory()` pela versão com servidor quando
  // o backend for escolhido. Nada mais precisa mudar.
  runApp(GabaritouApp(dependencies: AppDependencies.inMemory()));
}
