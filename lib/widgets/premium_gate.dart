import 'package:flutter/material.dart';
import '../services/auth_repository.dart';
import '../screens/subscription_screen.dart';

class PremiumGate extends StatefulWidget {
  final Widget child;
  const PremiumGate({required this.child, super.key});

  @override
  State<PremiumGate> createState() => _PremiumGateState();
}

class _PremiumGateState extends State<PremiumGate> {
  final AuthRepository _auth = AuthRepository();

  bool loading = true;
  bool isAllowed = false; // premium || premium_plus || trial

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final res = await _auth.getSubscriptionStatus();

    if (!mounted) return;

    if (res["ok"]) {
      final data = res["data"];

      final bool isPremium = data["isPremium"] == true;
      final bool isPremiumPlus = data["isPremiumPlus"] == true;
      final bool trialActiveFlag = data["trialActive"] == true;

      // --------- Calcul du trial à partir de trialEnd ----------
      bool trialValid = false;
      final trialEndString = data["trialEnd"];

      if (trialEndString != null) {
        final trialEnd = DateTime.tryParse(trialEndString);
        if (trialEnd != null && trialEnd.isAfter(DateTime.now())) {
          trialValid = true;
        }
      }

      setState(() {
        // 🔓 Accès si :
        // - Premium
        // - OU Premium Plus
        // - OU backend indique trialActive = true
        // - OU trialEnd encore dans le futur
        isAllowed = isPremium || isPremiumPlus || trialActiveFlag || trialValid;
        loading = false;
      });
    } else {
      setState(() {
        isAllowed = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (isAllowed) return widget.child;

    // ----------------------------------------------------------
    // PAYWALL si pas premium et pas en trial
    // ----------------------------------------------------------
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, size: 75, color: Colors.white70),
          const SizedBox(height: 14),

          const Text(
            "Fonctionnalité Premium",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Débloquez cette fonctionnalité en devenant Premium ou en activant votre essai gratuit.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubscriptionScreen(),
                ),
              );
            },
            child: const Text("Débloquer Premium"),
          ),
        ],
      ),
    );
  }
}


