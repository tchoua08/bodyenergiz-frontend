// lib/services/ppg_service.dart
import 'dart:math';

/// PpgService
/// - Collecte des valeurs (ex: moyenne channel rouge par frame)
/// - Filtre simple (moving average)
/// - Détection de pics basique (peak detection)
/// - Estimation BPM à partir d'intervalles entre pics
///
/// Usage:
///   final ppg = PpgService(maxSamples: 800);
///   ppg.addSample(value, timestampMs);
///   ... after collecting ...
///   final bpm = ppg.estimateBpm();
class PpgService {
  final int maxSamples;
  final int maWindow; // moving average window
  final List<double> _raw = [];
  final List<int> _times = [];
  final List<double> _filtered = [];

  PpgService({this.maxSamples = 600, this.maWindow = 5});

  void reset() {
    _raw.clear();
    _times.clear();
    _filtered.clear();
  }

  /// Add one sample from camera processing (value typically 0..255 or normalized)
  void addSample(double value, int timestampMs) {
    _raw.add(value);
    _times.add(timestampMs);
    if (_raw.length > maxSamples) {
      _raw.removeAt(0);
      _times.removeAt(0);
    }
    // update filtered using simple moving average
    _filtered.add(_movingAverageForLast(_raw, maWindow));
    if (_filtered.length > maxSamples) _filtered.removeAt(0);
  }

  double _movingAverageForLast(List<double> arr, int w) {
    final n = arr.length;
    if (n == 0) return 0.0;
    final start = max(0, n - w);
    double sum = 0;
    for (int i = start; i < n; i++) sum += arr[i];
    return sum / (n - start);
  }

  /// Estimate BPM using simple peak detection:
  /// 1) find local maxima above dynamic threshold
  /// 2) compute intervals (ms) between peaks
  /// 3) bpm = 60_000 / meanInterval
  double estimateBpm() {
    if (_filtered.length < 10 || _times.length < 10) return 0.0;

    // Build dynamic threshold: mean + k * std
    final mean = _filtered.reduce((a, b) => a + b) / _filtered.length;
    double variance = 0;
    for (final v in _filtered) variance += (v - mean) * (v - mean);
    variance = variance / _filtered.length;
    final std = sqrt(variance);
    final threshold = mean + std * 0.6; // adaptive threshold

    // peak detection: local maxima greater than neighbours and threshold
    final peaks = <int>[]; // indices of peaks
    for (int i = 1; i < _filtered.length - 1; i++) {
      final v = _filtered[i];
      if (v > threshold && v > _filtered[i - 1] && v > _filtered[i + 1]) {
        // enforce minimal distance between peaks (~300ms)
        final t = _times[i];
        if (peaks.isEmpty || (t - _times[peaks.last]) > 260) {
          peaks.add(i);
        }
      }
    }

    if (peaks.length < 2) return 0.0;

    // compute intervals in ms
    final intervals = <int>[];
    for (int i = 1; i < peaks.length; i++) {
      intervals.add(_times[peaks[i]] - _times[peaks[i - 1]]);
    }

    final meanInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    if (meanInterval <= 0) return 0.0;

    final bpm = 60000.0 / meanInterval;
    // clamp to reasonable range
    if (bpm.isNaN || bpm.isInfinite) return 0.0;
    if (bpm < 30 || bpm > 220) return 0.0;
    return bpm;
  }

  /// Get raw/filtered arrays for debugging / plotting
  List<double> getRawSignal() => List.unmodifiable(_raw);
  List<double> getFilteredSignal() => List.unmodifiable(_filtered);
}


