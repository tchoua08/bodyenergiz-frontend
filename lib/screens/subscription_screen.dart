import 'package:flutter/material.dart';
import '../services/auth_repository.dart';
import '../utils/theme.dart';
import 'profile_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final AuthRepository _auth = AuthRepository();

  bool loading = true;
  Map<String, dynamic>? subscription;

  // PriceIDs Stripe
  final String premiumPriceId = "price_premium_299";          // 2.99€
  final String premiumPlusPriceId = "price_premium_plus_599"; // 5.99€

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

  Future<void> _subscribe(String plan, String priceId) async {
    setState(() => loading = true);

    final res = await _auth.createCheckoutSession(plan: plan);

    setState(() => loading = false);

    if (!res["ok"]) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : ${res["error"]}")));
      return;
    }

    final url = res["data"]["checkoutUrl"];
    if (url == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("URL Stripe introuvable.")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewCheckout(url: url),
      ),
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

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Abonnement annulé.")));

    _loadSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------------------------------
      // APPBAR + RETOUR
      // -------------------------------
      appBar: AppBar(
        title: const Text("Abonnements"),
        backgroundColor: AppTheme.primaryTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              // AFFICHAGE
                              subscription?["active"] == true
                                  ? _buildActivePlan(subscription?["plan"])
                                  : _buildAvailablePlans(),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ABONNEMENT ACTIF
  // ----------------------------------------------------------
  Widget _buildActivePlan(String? plan) {
    final isPlus = plan == "premium_plus";

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
              style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
  // LISTE DES OFFRES
  // ----------------------------------------------------------
  Widget _buildAvailablePlans() {
    return Column(
      children: [
        _buildPlanCard(
          title: "Premium",
          price: "2.99 €/mois",
          description:
              "Débloque la mesure d’aura avancée, l’historique illimité et les conseils personnalisés.",
          onPressed: () => _subscribe("premium", premiumPriceId),
        ),
        const SizedBox(height: 22),

        _buildPlanCard(
          title: "Premium Plus",
          price: "5.99 €/mois",
          description:
              "Accès complet : rituels audio IA, respiration guidée, conseils vibratoires avancés.",
          highlight: true,
          onPressed: () => _subscribe("premium_plus", premiumPlusPriceId),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // CARD D’UN PLAN
  // ----------------------------------------------------------
  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required VoidCallback onPressed,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: highlight
              ? Colors.white.withOpacity(.18)
              : Colors.white.withOpacity(.12),
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
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              price,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 14),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            AppTheme.gradientButton(
              text: "S'abonner",
              onPressed: onPressed,
            )
          ],
        ),
      ),
    );
  }
}


// ----------------------------------------------------------
// WEBVIEW CHECKOUT (STRIPE)
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
          "Intègre WebView ici.\nURL Stripe :\n$url",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


