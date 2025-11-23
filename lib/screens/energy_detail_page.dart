import 'package:flutter/material.dart';
import '../models/energy_result.dart';
import '../utils/theme.dart';

class EnergyDetailPage extends StatelessWidget {
  final EnergyResult result;

  const EnergyDetailPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'énergie"),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryTeal, AppTheme.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Text("Aura détectée",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.colorFromAura(result.auraColor)
                            .withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 10)
                  ],
                ),
                child: Icon(Icons.bolt,
                    color: AppTheme.colorFromAura(result.auraColor),
                    size: 70),
              ),

              const SizedBox(height: 25),

              _metric("Battements/minute (BPM)", result.bpm),
              _metric("Mouvement / vibration", result.movement),
              _metric("Score d'énergie", result.energyScore),

              const SizedBox(height: 40),

              AppTheme.gradientButton(
                text: "Retour",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value.toStringAsFixed(1),
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


