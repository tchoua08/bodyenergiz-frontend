import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/auth_repository.dart';
import '../widgets/premium_gate.dart';
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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final r = await _auth.getMe();
    if (r["ok"]) {
      setState(() {
        user = r["data"];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),

                  // ---- FULL PAGE ----
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ----- HEADER -----
                      const SizedBox(height: 20),
                      const Text(
                        "Mon Profil",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ----- AVATAR -----
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user!["photoUrl"] != null
                            ? NetworkImage(user!["photoUrl"])
                            : null,
                        child: user!["photoUrl"] == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.black54)
                            : null,
                      ),

                      const SizedBox(height: 12),

                      // ----- USER NAME -----
                      Text(
                        user!["name"] ?? "Utilisateur",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 30),

                      // ----- EDIT PROFILE -----
                      _menuItem(
                        icon: Icons.edit,
                        text: "Modifier mon profil",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),

                      // ----- HISTORY (PREMIUM) -----
                      PremiumGate(
                        child: _menuItem(
                          icon: Icons.history,
                          text: "Historique des scans",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HistoryScreen()),
                            );
                          },
                        ),
                      ),

                      // ----- SUBSCRIPTION -----
                      _menuItem(
                        icon: Icons.workspace_premium,
                        text: "Devenir Premium",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SubscriptionScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                      // ----- LOGOUT BUTTON -----
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: AppTheme.gradientButton(
                          text: "Se déconnecter",
                          onPressed: () async {
                            await _auth.logout();
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (_) => false,
                              );
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------------- MENU ITEM -------------------------
  Widget _menuItem(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }
}


