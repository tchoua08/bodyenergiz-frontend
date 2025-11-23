// lib/services/sensor_service.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

/// Simple wrapper around sensors_plus to provide start/stop and smoothed
/// vibration/movement values. Designed to be minimal and easy to use.
class SensorService {
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  // Simple EMA smoothing
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;
  final double _alpha = 0.25; // smoothing factor

  // public read-only current movement magnitude
  double get movementMagnitude =>
      (_accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ).sqrt();

  // callback to deliver a smoothed movement magnitude (0..inf)
  void startAccelerometer(void Function(double magnitude) onData) {
    stop(); // ensure no double subscriptions
    _accSub = accelerometerEvents.listen((event) {
      _accelX = _ema(_accelX, event.x);
      _accelY = _ema(_accelY, event.y);
      _accelZ = _ema(_accelZ, event.z);
      final mag = (_accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ).sqrt();
      onData(mag);
    });
  }

  void startGyroscope(void Function(GyroscopeEvent e) onData) {
    _gyroSub?.cancel();
    _gyroSub = gyroscopeEvents.listen(onData);
  }

  void stop() {
    _accSub?.cancel();
    _gyroSub?.cancel();
    _accSub = null;
    _gyroSub = null;
  }

  // exponential moving average helper
  double _ema(double prev, double current) => prev + _alpha * (current - prev);
}

extension _SqrtExt on double {
  double sqrt() => math.sqrt(this.abs());
}


