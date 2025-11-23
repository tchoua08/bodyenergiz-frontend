// lib/services/energy_fusion.dart
import 'dart:math';

/// Simple fusion logic to compute:
///  - energyScore: 0.0 .. 100.0
///  - auraColor: "green", "blue", "gold", "red", "purple"
///
/// Inputs:
///  - bpm: beats per minute (double)
///  - movement: magnitude from accelerometer (double, arbitrary unit)
///
/// Strategy:
///  - Normalize bpm into a 0..1 activation scale (30..140 BPM typical)
///  - Normalize movement into 0..1 (user calibrates; we assume 0..15 typical)
///  - energyScore = weighted sum (bpmWeight, movementWeight)
///  - auraColor chosen by thresholds on energyScore and bpm/HRV proxy
class EnergyFusion {
  // weights (tunable)
  static const double bpmWeight = 0.65;
  static const double movementWeight = 0.35;

  /// Map bpm to 0..1 (30 -> 0.0, 140 -> 1.0)
  static double _normBpm(double bpm) {
    final cl = bpm.clamp(30.0, 140.0);
    return (cl - 30.0) / (140.0 - 30.0);
  }

  /// Map movement to 0..1 using a soft cap
  /// expectedMovementRange is expected max magnitude (tune for device)
  static double _normMovement(double movement, {double expectedMax = 12.0}) {
    final v = movement.clamp(0.0, expectedMax);
    return v / expectedMax;
  }

  /// Compute final energy score 0..100 and choose aura color
  /// returns { 'energy': double, 'auraColor': String }
  static Map<String, dynamic> computeScores({required double bpm, required double movement}) {
    final nb = _normBpm(bpm);
    final nm = _normMovement(movement);

    final energyFraction = (nb * bpmWeight) + (nm * movementWeight);
    final energyScore = (energyFraction * 100).clamp(0.0, 100.0);

    // Decide aura color heuristics:
    // - high energy & moderate bpm -> gold
    // - high movement & high bpm -> red (excited/agitated)
    // - low bpm & low movement -> green (calm / relaxed)
    // - medium values -> blue / purple for nuance
    String aura;
    if (energyScore >= 80 && nb >= 0.7 && nm < 0.6) {
      aura = 'gold';
    } else if (energyScore >= 75 && nm >= 0.7 && nb >= 0.6) {
      aura = 'red';
    } else if (energyScore <= 35 && nb <= 0.4 && nm <= 0.4) {
      aura = 'green';
    } else if (energyScore >= 50 && nb >= 0.5 && nm < 0.5) {
      aura = 'blue';
    } else {
      aura = 'purple';
    }

    return {
      'energy': energyScore.toDouble(),
      'auraColor': aura,
      'normBpm': nb,
      'normMovement': nm,
    };
  }
}


