import 'package:flutter/material.dart';
import '../models/energy_result.dart';
import '../utils/theme.dart';
import 'personalized_advice_screen.dart';

class EnergyDetailPage extends StatelessWidget {
  final EnergyResult result;

  const EnergyDetailPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analyse de l'Aura"),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: Container(
        decoration: AppTheme.mainGradient,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            // AURA ICON
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.colorFromAura(result.auraColor).withOpacity(.3),
                border: Border.all(
                  color: AppTheme.colorFromAura(result.auraColor),
                  width: 4,
                ),
              ),
              child: Icon(Icons.energy_savings_leaf,
                  color: AppTheme.colorFromAura(result.auraColor), size: 70),
            ),

            const SizedBox(height: 20),

            Text(
              "Énergie Vitale : ${result.energyScore.toStringAsFixed(1)}%",
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),

            const SizedBox(height: 12),

            Text(
              "BPM : ${result.bpm.toStringAsFixed(1)}",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            Text(
              "Mouvement : ${result.movement.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const Spacer(),

           AppTheme.gradientButton(
            text: "Conseils personnalisés",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonalizedAdviceScreen(result: result),
                ),
              );
            },
          ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


