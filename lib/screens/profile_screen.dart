import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/auth_repository.dart';
import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'history_screen.dart';
import './auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AuthRepository _auth = AuthRepository();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: Container(
        decoration: AppTheme.mainGradient,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: _auth.getMe(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final Map<String, dynamic> user = snapshot.data as Map<String, dynamic>;

            return Column(
              children: [
                // ---- AVATAR ----
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  backgroundImage: user['avatar'] != null
                      ? NetworkImage(user['avatar'] as String)
                      : const AssetImage("images/logo.png") as ImageProvider,
                ),
                const SizedBox(height: 12),

                // ---- NAME ----
                Text(
                  (user['name'] ?? '').toString(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                // -------- MENU --------
                _menuTile(
                  icon: Icons.person,
                  title: "Modifier mon profil",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),

                _menuTile(
                    icon: Icons.history,
                    title: "Historique des scans",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    }),

                _menuTile(
                  icon: Icons.privacy_tip,
                  title: "Politique de confidentialité",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                ),

                _menuTile(
                  icon: Icons.description,
                  title: "Conditions d’utilisation",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    );
                  },
                ),

                const Spacer(),

                // ---- LOGOUT ----
              // Déconnexion
                AppTheme.gradientButton(
                  text: "Se déconnecter",
                  onPressed: () async {
                    await _auth.logout();

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  // -------- MENU TILE WIDGET --------
  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }
}


