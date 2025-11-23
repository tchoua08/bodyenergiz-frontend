import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'auth/login_screen.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    const logoPath = '/mnt/data/A_logo_for_the_digital_application_named_"BodyEner.png';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.darkBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.network(logoPath, width: 180, errorBuilder: (c, e, s) {
              // fallback to asset if network path not available
              return Image.asset('images/logo.png', width: 180);
            }),
            const SizedBox(height: 16),
            const Text('BodyEnergiz', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}


