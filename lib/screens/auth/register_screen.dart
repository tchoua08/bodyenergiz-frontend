import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/auth_input.dart';
import '../../services/auth_repository.dart';
import '../main_navigation.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final AuthRepository _repo = AuthRepository();
  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);

    final res = await _repo.register(
      _name.text.trim(),
      _email.text.trim(),
      _pass.text.trim(),
    );

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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
        title: const Text("Créer un compte"),
        centerTitle: true,
      ),

      // ----------- BACKGROUND -----------
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryTeal, AppTheme.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // ----------- LOGO -----------
                Image.asset(
                  'images/logo.png',
                  width: 110,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                const Text(
                  "Créer un compte",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // ----------- INPUTS -----------
                AuthInput(
                  controller: _name,
                  hint: "Nom complet",
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),

                AuthInput(
                  controller: _email,
                  hint: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 12),

                AuthInput(
                  controller: _pass,
                  hint: "Mot de passe",
                  icon: Icons.lock,
                  obscure: true,
                ),

                const SizedBox(height: 20),

                // ----------- BUTTON -----------
                AppTheme.gradientButton(
                  text: _loading ? "Création..." : "Créer le compte",
                  onPressed: _loading ? null : _register,
                ),

                const SizedBox(height: 130), // évite l’espace blanc en bas
              ],
            ),
          ),
        ),
      ),
    );
  }
}


