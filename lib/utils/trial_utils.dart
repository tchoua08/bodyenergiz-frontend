class TrialUtils {
  static int daysLeft(DateTime trialEnd) {
    final now = DateTime.now();
    final diff = trialEnd.difference(now).inDays;

    // Si moins de 24h → afficher 1 jour minimum
    return diff < 1 ? 1 : diff;
  }
}


