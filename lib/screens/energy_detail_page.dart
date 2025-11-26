import 'package:flutter/material.dart';
import '../models/energy_result.dart';
import '../utils/theme.dart';
import '../widgets/trial_badge.dart';
import '../services/auth_repository.dart';
import 'personalized_advice_screen.dart';

class EnergyDetailPage extends StatefulWidget {
  final EnergyResult result;

  const EnergyDetailPage({super.key, required this.result});

  @override
  State<EnergyDetailPage> createState() => _EnergyDetailPageState();
}

class _EnergyDetailPageState extends State<EnergyDetailPage> {
  final AuthRepository _auth = AuthRepository();
  DateTime? trialEnd;

  @override
  void initState() {
    super.initState();
    _loadTrialStatus();
  }

  Future<void> _loadTrialStatus() async {
    final res = await _auth.getSubscriptionStatus();
    if (res["ok"]) {
      final data = res["data"];

      if (data["trialEnd"] != null) {
        trialEnd = DateTime.tryParse(data["trialEnd"]);
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

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
            const SizedBox(height: 10),

            // -------------------------------------
            // ⭐ BADGE TRIAL (si actif)
            // -------------------------------------
            if (trialEnd != null) TrialBadge(trialEnd: trialEnd),
            const SizedBox(height: 10),

            // -------------------------------------
            // 🔮 AURA ICON
            // -------------------------------------
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

            // -------------------------------------
            // 🔋 ENERGY %
            // -------------------------------------
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

            // -------------------------------------
            // 🧠 BOUTON CONSEILS PERSONALISÉS
            // -------------------------------------
            AppTheme.gradientButton(
              text: "Conseils personnalisés",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PersonalizedAdviceScreen(result: widget.result),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


