import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/core/theme/app_theme.dart';
import 'app/views/app_shell_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WavooApp());
}

class WavooApp extends StatelessWidget {
  const WavooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wavoo Jewellers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      home: const AppShellView(),
    );
  }
}

