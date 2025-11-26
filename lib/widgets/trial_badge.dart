import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/trial_utils.dart';

class TrialBadge extends StatelessWidget {
  final DateTime? trialEnd;

  const TrialBadge({super.key, required this.trialEnd});

  @override
  Widget build(BuildContext context) {
    if (trialEnd == null) return const SizedBox.shrink();

    final daysLeft = TrialUtils.daysLeft(trialEnd!);

    if (daysLeft <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppTheme.primaryTeal, AppTheme.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Essai gratuit actif — $daysLeft jour${daysLeft > 1 ? 's' : ''} restant${daysLeft > 1 ? 's' : ''}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}


