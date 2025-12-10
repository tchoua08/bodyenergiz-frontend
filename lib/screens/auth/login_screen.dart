import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/auth_input.dart';
import '../../services/auth_repository.dart';
import '../main_navigation.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  bool _loading = false;
  final AuthRepository _repo = AuthRepository();

  Future<void> _login() async {
    setState(() => _loading = true);
    final res = await _repo.login(_email.text.trim(), _pass.text.trim());
    setState(() => _loading = false);

    if (res['ok']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'].toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryTeal, AppTheme.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // -------------------------------
                // LOGO
                // -------------------------------
                Image.asset('images/logo.png', width: 120),

                const SizedBox(height: 12),

                // -------------------------------
                // TEXT JUST UNDER LOGO
                // -------------------------------
                const Text(
                  "Sauvons de l'énergie",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // -------------------------------
                // TITLE
                // -------------------------------
                const Text(
                  "Connexion",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // -------------------------------
                // FORM INPUTS
                // -------------------------------
                AuthInput(controller: _email, hint: "Email", icon: Icons.email),
                const SizedBox(height: 12),

                AuthInput(
                  controller: _pass,
                  hint: "Mot de passe",
                  icon: Icons.lock,
                  obscure: true,
                ),

                const SizedBox(height: 18),

                // -------------------------------
                // LOGIN BUTTON
                // -------------------------------
                AppTheme.gradientButton(
                  text: _loading ? "Connexion..." : "Se connecter",
                  onPressed: _loading ? null : _login,
                ),

                const SizedBox(height: 16),

                // -------------------------------
                // LINKS
                // -------------------------------
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    "Créer un compte",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


