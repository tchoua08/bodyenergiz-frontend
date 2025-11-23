import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/auth_input.dart';
import '../../services/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final AuthRepository _auth = AuthRepository();
  bool loading = false;

  Future<void> send() async {
    final email = _email.text.trim();

    if (email.isEmpty || !email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un email valide.")),
      );
      return;
    }

    setState(() => loading = true);

    final resp = await _auth.forgotPassword(email);

    setState(() => loading = false);

    if (resp["ok"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Un email de réinitialisation a été envoyé."),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${resp['error']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mot de passe oublié"),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryTeal, AppTheme.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            const Text(
              "Réinitialiser votre mot de passe",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 14),

            const Text(
              "Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            AuthInput(
              controller: _email,
              hint: "Adresse email",
              icon: Icons.email,
            ),

            const SizedBox(height: 25),

            AppTheme.gradientButton(
              text: loading ? "Envoi..." : "Envoyer",
              loading: loading,
              onPressed: loading ? null : send,
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Retour",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}


