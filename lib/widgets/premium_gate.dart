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
  bool? isPremium;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final r = await _auth.getSubscriptionStatus();
    if (r["ok"]) {
      setState(() {
        isPremium = r["data"]["isPremium"] == true;
        loading = false;
      });
    } else {
      setState(() {
        isPremium = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (isPremium == true) return widget.child;

    // paywall
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Fonctionnalité Premium", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            child: const Text("Passer à Premium"),
          )
        ],
      ),
    );
  }
}


