import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/energy_result.dart';
import '../widgets/premium_gate.dart';
import '../services/ai_repository.dart';

class PersonalizedAdviceScreen extends StatefulWidget {
  final EnergyResult result;

  const PersonalizedAdviceScreen({super.key, required this.result});

  @override
  State<PersonalizedAdviceScreen> createState() =>
      _PersonalizedAdviceScreenState();
}

class _PersonalizedAdviceScreenState extends State<PersonalizedAdviceScreen> {
  final AIRepository _ai = AIRepository();

  bool loading = true;
  String? advice;
  Color? auraColor;

  @override
  void initState() {
    super.initState();
    auraColor = AppTheme.colorFromAura(widget.result.auraColor);
    _loadAdvice();
  }

  Future<void> _loadAdvice() async {
    final resp = await _ai.generateAdvice(widget.result);

    if (resp["ok"]) {
      setState(() {
        advice = resp["data"]["advice"];
        loading = false;
      });
    } else {
      setState(() {
        advice = "Impossible de générer les conseils.";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Conseils personnalisés"),
        ),
        body: Container(
          decoration: AppTheme.mainGradient,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(18),
          child: loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // AURA ICON
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: auraColor!.withOpacity(.25),
                          border: Border.all(color: auraColor!, width: 4),
                        ),
                        child: Icon(Icons.auto_awesome, color: auraColor, size: 60),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "Analyse IA de ton aura :",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          advice ?? "Aucun conseil disponible.",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


