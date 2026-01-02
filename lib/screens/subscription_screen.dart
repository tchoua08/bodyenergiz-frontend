import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/auth_repository.dart';
import '../utils/theme.dart';
import '../utils/date_utils.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final AuthRepository _auth = AuthRepository();

  bool loading = true;
  Map<String, dynamic>? subscription;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final res = await _auth.getSubscriptionStatus();

    if (!mounted) return;

    setState(() {
      loading = false;
      subscription = res["ok"] ? res["data"] : null;
    });
  }

  // ----------------------------------------------------------
  // TRIGGER CHECKOUT
  // ----------------------------------------------------------
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("URL Stripe introuvable.")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WebViewCheckout(url: url)),
    );
  }

  // ----------------------------------------------------------
  // CANCEL SUBSCRIPTION
  // ----------------------------------------------------------
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
    final isTrial = subscription?["isTrialing"] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Abonnements"),
        backgroundColor: AppTheme.primaryTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Container(
        decoration: AppTheme.mainGradient,
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    if (isTrial) _buildTrialCard(),

                    if (!isTrial &&
                        subscription?["subscriptionLevel"] != "none")
                      _buildActivePlan(),

                    if (!isTrial &&
                        subscription?["subscriptionLevel"] == "none")
                      _buildAvailablePlans(),
                  ],
                ),
              ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TRIAL
  // ----------------------------------------------------------
  Widget _buildTrialCard() {
    final trialEndString = subscription?["trialEnd"];
    DateTime? trialEnd = DateTime.tryParse(trialEndString ?? "");

    final remainingDays =
        trialEnd != null ? trialEnd.difference(DateTime.now()).inDays + 1 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.amberAccent, width: 2),
        ),
        child: Column(
          children: [
            const Text(
              "Essai gratuit actif",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Il vous reste $remainingDays jours d’essai",
              style: const TextStyle(color: Colors.white70),
            )
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              isPlus ? "Premium Plus" : "Premium",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 20),
            AppTheme.gradientButton(
                text: "Annuler l'abonnement",
                onPressed: _cancelSubscription)
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
          price: "2.99€/mois (+ 7 jours gratuits)",
          description:
              "Mesure d’aura avancée, historique illimité, conseils personnalisés.",
          onSubscribe: () => _subscribe("premium"),
        ),
        const SizedBox(height: 24),
        _buildPlanCard(
          title: "Premium Plus",
          price: "5.99€/mois (+ 7 jours gratuits)",
          description:
              "Rituels audio IA, respiration guidée, conseils vibratoires avancés.",
          highlight: true,
          onSubscribe: () => _subscribe("premium_plus"),
        ),
      ],
    );
  }

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
          color: highlight ? Colors.white.withOpacity(.18) : Colors.white24,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlight ? Colors.amberAccent : Colors.white30,
            width: highlight ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(price,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 14),
            Text(description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            AppTheme.gradientButton(text: "S'abonner", onPressed: onSubscribe),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// WEBVIEW STRIPE CHECKOUT
// ----------------------------------------------------------
class WebViewCheckout extends StatefulWidget {
  final String url;
  const WebViewCheckout({super.key, required this.url});

  @override
  State<WebViewCheckout> createState() => _WebViewCheckoutState();
}

class _WebViewCheckoutState extends State<WebViewCheckout> {
  late final WebViewController _controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => loading = false);
            }
          },

          // 👉 OPTIONNEL : détecter retour Stripe
          onNavigationRequest: (request) {
            if (request.url.contains("success")) {
              Navigator.pop(context, true); // paiement OK
              return NavigationDecision.prevent;
            }

            if (request.url.contains("cancel")) {
              Navigator.pop(context, false); // paiement annulé
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement sécurisé")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}