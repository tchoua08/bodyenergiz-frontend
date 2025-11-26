import 'package:flutter/material.dart';
import '../services/auth_repository.dart';
import '../utils/theme.dart';
import 'profile_screen.dart';
import '../utils/date_utils.dart'; // si tu veux formater des dates

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final AuthRepository _auth = AuthRepository();

  bool loading = true;
  Map<String, dynamic>? subscription;

  // Prices
  final String premiumPriceId = "price_premium_299"; 
  final String premiumPlusPriceId = "price_premium_plus_599";

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final res = await _auth.getSubscriptionStatus();

    if (mounted) {
      setState(() {
        loading = false;
        subscription = res["ok"] ? res["data"] : null;
      });
    }
  }

  Future<void> _subscribe(String plan) async {
    setState(() => loading = true);

    final res = await _auth.createCheckoutSession(plan: plan);

    setState(() => loading = false);

    if (!res["ok"]) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : ${res["error"]}")));
      return;
    }

    final url = res["data"]["url"];
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("URL Stripe introuvable.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WebViewCheckout(url: url)),
    );
  }

  Future<void> _cancelSubscription() async {
    setState(() => loading = true);

    final res = await _auth.cancelSubscription();

    if (!mounted) return;

    setState(() => loading = false);

    if (!res["ok"]) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : ${res["error"]}")));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Abonnement annulé.")),
    );

    _loadSubscription();
  }

  @override
  Widget build(BuildContext context) {
    final isTrial = subscription?["isTrialing"] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Abonnements"),
        backgroundColor: AppTheme.primaryTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // garde bottom nav
        ),
      ),
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // TRIAL ACTIVE
                      if (isTrial) _buildTrialCard(),

                      // Sub active (premium / premium_plus)
                      if (!isTrial && subscription?["subscriptionLevel"] != "none")
                        _buildActivePlan(),

                      // No subscription
                      if (!isTrial && subscription?["subscriptionLevel"] == "none")
                        _buildAvailablePlans(),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CARD TRIAL
  // ----------------------------------------------------------
  Widget _buildTrialCard() {
    final trialEnd = DateTime.tryParse(subscription?["trialEnd"] ?? "");
    int remainingDays = 0;

    if (trialEnd != null) {
      remainingDays = trialEnd.difference(DateTime.now()).inDays + 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.amberAccent, width: 2),
        ),
        child: Column(
          children: [
            const Text(
              "Essai gratuit actif",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Il vous reste $remainingDays jours d’essai gratuit",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            AppTheme.gradientButton(
              text: "Gérer mon abonnement",
              onPressed: () {}, // pas de cancel pendant trial
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ACTIVE SUBSCRIPTION
  // ----------------------------------------------------------
  Widget _buildActivePlan() {
    final level = subscription?["subscriptionLevel"];
    final isPlus = level == "premium_plus";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Text(
              "Abonnement actif",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              isPlus ? "Premium Plus" : "Premium",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 20),
            AppTheme.gradientButton(
              text: "Annuler l'abonnement",
              onPressed: _cancelSubscription,
            )
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // AVAILABLE PLANS
  // ----------------------------------------------------------
  Widget _buildAvailablePlans() {
    return Column(
      children: [
        _buildPlanCard(
          title: "Premium",
          price: "2.99 €/mois\n(+ 7 jours gratuits)",
          description: "Mesure d’aura avancée, historique illimité, conseils personnalisés.",
          onSubscribe: () => _subscribe("premium"),
        ),
        const SizedBox(height: 22),
        _buildPlanCard(
          title: "Premium Plus",
          price: "5.99 €/mois\n(+ 7 jours gratuits)",
          description: "Rituels audio IA, respiration guidée, conseils vibratoires avancés.",
          highlight: true,
          onSubscribe: () => _subscribe("premium_plus"),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // CARD PLAN
  // ----------------------------------------------------------
  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required VoidCallback onSubscribe,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: highlight ? Colors.white.withOpacity(.18) : Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlight ? Colors.amber : Colors.white24,
            width: highlight ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(price, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 14),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            AppTheme.gradientButton(text: "S'abonner", onPressed: onSubscribe),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// WEBVIEW (Stripe)
// ----------------------------------------------------------
class WebViewCheckout extends StatelessWidget {
  final String url;
  const WebViewCheckout({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement sécurisé")),
      body: Center(
        child: Text(
          "Intègre une WebView ici.\n\nURL Stripe :\n$url",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


