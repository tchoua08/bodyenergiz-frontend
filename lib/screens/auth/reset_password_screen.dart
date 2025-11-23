import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/auth_input.dart';
import '../../services/auth_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthRepository _auth = AuthRepository();

  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _pwd2 = TextEditingController();

  bool loading = false;

  Future<void> resetPassword() async {
    final p1 = _pwd.text.trim();
    final p2 = _pwd2.text.trim();

    if (p1.isEmpty || p2.isEmpty || p1 != p2) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Les mots de passe ne correspondent pas.")));
      return;
    }

    setState(() => loading = true);

    final res = await _auth.resetPassword(p1); // 🟢 UTILISE LA BONNE MÉTHODE (JWT)

    setState(() => loading = false);

    if (res["ok"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe mis à jour avec succès.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${res["error"]}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau mot de passe"),
        backgroundColor: AppTheme.primaryTeal,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [AppTheme.primaryTeal, AppTheme.darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            AuthInput(
              controller: _pwd,
              hint: "Nouveau mot de passe",
              icon: Icons.lock,
              obscure: true,
            ),

            const SizedBox(height: 20),

            AuthInput(
              controller: _pwd2,
              hint: "Confirmer le mot de passe",
              icon: Icons.lock_reset,
              obscure: true,
            ),

            const SizedBox(height: 40),

            AppTheme.gradientButton(
              text: loading ? "Patientez..." : "Enregistrer",
              loading: loading,
              onPressed: loading ? null : resetPassword,
            ),
          ],
        ),
      ),
    );
  }
}


