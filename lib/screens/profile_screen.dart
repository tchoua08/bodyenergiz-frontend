import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/auth_repository.dart';
import '../widgets/premium_gate.dart';
import '../widgets/trial_badge.dart';
import 'subscription_screen.dart';
import 'edit_profile_screen.dart';
import 'history_screen.dart';
import './auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _auth = AuthRepository();

  Map<String, dynamic>? user;
  DateTime? trialEnd;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Load profile
    final r = await _auth.getMe();

    // Load subscription with trial info
    final sub = await _auth.getSubscriptionStatus();

    if (r["ok"]) {
      setState(() {
        user = r["data"];
        loading = false;
      });
    }

    if (sub["ok"]) {
      final data = sub["data"];
      if (data["trialEnd"] != null) {
        trialEnd = DateTime.tryParse(data["trialEnd"]);
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: Container(
        decoration: AppTheme.mainGradient,
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // ⭐ Trial Badge si actif
            if (trialEnd != null) TrialBadge(trialEnd: trialEnd),

            const SizedBox(height: 10),

            // Avatar
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              backgroundImage: user!["photoUrl"] != null
                  ? NetworkImage(user!["photoUrl"])
                  : null,
              child: user!["photoUrl"] == null
                  ? const Icon(Icons.person, size: 45, color: Colors.black54)
                  : null,
            ),

            const SizedBox(height: 12),

            Text(
              user!["name"] ?? "Utilisateur",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 25),

            // Buttons
            _menuItem(
              icon: Icons.edit,
              text: "Modifier mon profil",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),

            // HISTORY (protected)
            PremiumGate(
              child: _menuItem(
                icon: Icons.history,
                text: "Historique des scans",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
            ),

            _menuItem(
              icon: Icons.workspace_premium,
              text: "Devenir Premium",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
            ),

            const Spacer(),

            // Logout
            AppTheme.gradientButton(
              text: "Se déconnecter",
              onPressed: () async {
                await _auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Menu item builder
  Widget _menuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: onTap,
      ),
    );
  }
}


