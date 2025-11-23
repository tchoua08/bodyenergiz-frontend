import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  final String _termsText = '''
Conditions d'utilisation - BodyEnergiz

1) Acceptation
En utilisant BodyEnergiz, vous acceptez ces conditions.

2) Utilisation
L'application fournit une estimation d'énergie/aura à titre informatif seulement...

3) Contenu utilisateur
Vous êtes responsable des informations que vous nous communiquez.

4) Limitation de responsabilité
BodyEnergiz n'est pas un dispositif médical...

5) Modifications
Nous pouvons modifier ces conditions ; la date de mise à jour sera communiquée.

Contact : legal@bodyenergiz.com
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conditions d'utilisation"),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: AppTheme.mainGradient,
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              children: [
                SizedBox(
                  height: 110,
                  child: Image.network(
                    '/mnt/data/A_logo_features_a_stylized_human_figure_in_vibrant.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Conditions d'utilisation",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _termsText,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
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


