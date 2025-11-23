import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Remplace ce texte par ta vraie politique
  final String _policyText = '''
BodyEnergiz - Politique de confidentialité

Dernière mise à jour : 2025-11-23

1) Introduction
BodyEnergiz ("nous", "notre", "l'application") respecte votre vie privée...
(Remplace ce bloc par le texte complet de ta politique.)

2) Données collectées
- Données d'utilisation (anonymisées)
- Données de capteurs (caméra, accéléromètre) uniquement avec consentement
- Données d'authentification (email, hash du mot de passe)

3) Finalités
- Calculer une estimation d'« aura » (non médicale)
- Amélioration du service sous forme agrégée
- Notifications et gestion de compte

4) Partage & stockage
- Aucune donnée sensible n'est partagée sans consentement explicite.
- Stockage chiffré localement et optionnellement dans notre backend.

5) Droits
- Droit d'accès, rectification, suppression.
- Contact : privacy@bodyenergiz.com

6) Contact
Pour toute question : privacy@bodyenergiz.com
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          decoration: AppTheme.mainGradient,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo header (local path provided)
                // NOTE: transform the path to a url if needed in your setup
                SizedBox(
                  height: 120,
                  child: Image.network(
                    'images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const SizedBox(); // silent fallback if path not resolvable
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Politique de confidentialité',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _policyText,
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


