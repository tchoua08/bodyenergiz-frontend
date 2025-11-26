import 'package:intl/intl.dart';

class DateUtilsHelper {
  /// Convertit une date ISO (String) en DateTime
  static DateTime? parse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Format JJ/MM/AAAA
  static String format(DateTime? date) {
    if (date == null) return "--/--/----";
    return DateFormat("dd/MM/yyyy").format(date);
  }

  /// Nombre de jours restants entre today et target date
  static int daysRemaining(DateTime? futureDate) {
    if (futureDate == null) return 0;

    final now = DateTime.now();
    final diff = futureDate.difference(now).inDays;

    // +1 pour inclure aujourd’hui
    return diff + 1;
  }

  /// Vérifie si l'essai gratuit est toujours valide
  static bool isTrialActive(DateTime? trialEnd) {
    if (trialEnd == null) return false;
    return trialEnd.isAfter(DateTime.now());
  }

  /// Retourne une phrase lisible
  static String remainingSentence(DateTime? futureDate) {
    final d = daysRemaining(futureDate);
    if (d <= 0) return "Expiré";
    if (d == 1) return "Expire dans 1 jour";

    return "Expire dans $d jours";
  }
}


