import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BodyEnergizApp());
}

class BodyEnergizApp extends StatelessWidget {
  const BodyEnergizApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BodyEnergiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}


