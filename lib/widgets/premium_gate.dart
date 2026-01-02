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
  bool isAllowed = false; // premium || premium_plus || trial actif

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final res = await _auth.getSubscriptionStatus();

    if (!mounted) return;

    if (res["ok"] != true) {
      setState(() {
        loading = false;
        isAllowed = false;
      });
      return;
    }
     print("res: $res");
    final data = (res["data"] ?? {}) as Map<String, dynamic>;

    // ----------------------------------------------------------
    // 1) Flags directs venant du backend
    // ----------------------------------------------------------
    bool isPremium = data["isPremium"] == true;
    bool isPremiumPlus = data["isPremiumPlus"] == true;
     
    // ----------------------------------------------------------
    // 2) Lecture d'un éventuel objet "subscription"
    //    { active: bool, plan: "premium" | "premium_plus", trialEndsAt: Date }
    // ----------------------------------------------------------
    final sub = data["subscription"];
    if (sub is Map<String, dynamic>) {
      final bool active = sub["active"] == true;
      final String? plan = sub["plan"]?.toString();

      if (active && plan != null) {
        if (plan == "premium" || plan == "premium_plus") {
          isPremium = true;
        }
        if (plan == "premium_plus") {
          isPremiumPlus = true;
        }
      }
    }

    // ----------------------------------------------------------
    // 3) Gestion du TRIAL (isTrialing + trialEnd / trialEndsAt)
    // ----------------------------------------------------------
    bool trialValid = false;

    // a) champ booléen direct (backend moderne)
    final bool trialFlag = data["isTrialing"] == true;

    // b) date de fin de trial (backend renvoie trialEnd ou subscription.trialEndsAt)
    String? trialEndString;

    if (data["trialEnd"] != null) {
      trialEndString = data["trialEnd"].toString();
    } else if (sub is Map<String, dynamic> && sub["trialEndsAt"] != null) {
      trialEndString = sub["trialEndsAt"].toString();
    }

    if (trialEndString != null) {
      final parsed = DateTime.tryParse(trialEndString);
      if (parsed != null && parsed.isAfter(DateTime.now())) {
        trialValid = true;
      }
    }

    final bool trialActive = trialFlag || trialValid;

    // ----------------------------------------------------------
    // 4) Décision finale
    // ----------------------------------------------------------
    setState(() {
      loading = false;
      isAllowed = isPremium || isPremiumPlus || trialActive;
    });

    // (Optionnel) Debug pour vérifier ce que renvoie le backend
    // print("SUB STATUS => isPremium=$isPremium, isPremiumPlus=$isPremiumPlus, trialActive=$trialActive");
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
              "Débloquez cette fonctionnalité en devenant Premium ou utilisez votre essai gratuit.",
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


