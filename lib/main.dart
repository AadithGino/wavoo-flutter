import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavoo_app/app/views/screens/no_internet_screen.dart';
import 'package:wavoo_app/app/views/screens/splash_view.dart';

import 'app/bindings/initial_binding.dart';
import 'app/core/theme/app_theme.dart';

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
      builder: (context, child) {
        return NetworkListenerWrapper(child: child!);
      },
      home: const SplashScreen(),
    );
  }
}
