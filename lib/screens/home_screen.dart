import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/premium_gate.dart';
import 'aura_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BodyEnergiz"),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: Container(
        decoration: AppTheme.mainGradient,
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Logo
            Image.asset("images/logo.png", height: 110),

            const SizedBox(height: 20),

            const Text(
              "Analyse ton aura et mesure ton énergie vitale",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),

            const SizedBox(height: 30),

            // PROTECTED BUTTON
            PremiumGate(
              child: AppTheme.gradientButton(
                text: "Scanner mon aura",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuraScanScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Place ton doigt sur la caméra arrière pour une mesure PPG.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}


