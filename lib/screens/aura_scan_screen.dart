// Full code condensed: uses camera, sensors, ppg_service (same as previously provided).
// Key change: after result computed, call ScanRepository().saveScan(...)
import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sensor_service.dart';
import '../services/ppg_service.dart';
import '../services/energy_fusion.dart';
import '../models/energy_result.dart';
import '../services/scan_repository.dart';
import '../utils/theme.dart';

class AuraScanScreen extends StatefulWidget {
  const AuraScanScreen({super.key});
  @override
  State<AuraScanScreen> createState() => _AuraScanScreenState();
}

class _AuraScanScreenState extends State<AuraScanScreen> {
  CameraController? _controller;
  bool _cameraReady = false;
  bool _scanning = false;
  final SensorService _sensor = SensorService();
  final PpgService _ppg = PpgService(maxSamples: 400);
  double _vibration = 0.0;
  double _lastBpm = 0.0;
  Timer? _bpmTimer;
  final ScanRepository _scanRepo = ScanRepository();

  @override
  void initState() { super.initState(); _initAll(); }

  Future<void> _initAll() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) { setState(() => _cameraReady = false); return; }
    final cams = await availableCameras();
    final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
    _controller = CameraController(back, ResolutionPreset.low, enableAudio: false);
    await _controller!.initialize();
    await _controller!.startImageStream(_processCameraImage);
    _sensor.startAccelerometer((v) => setState(() => _vibration = v));
    setState(() => _cameraReady = true);
    _bpmTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_scanning) {
        final bpm = _ppg.estimateBpm();
        if (bpm > 0) setState(() => _lastBpm = bpm);
      }
    });
  }

  int _frameCounter = 0;
  void _processCameraImage(CameraImage image) {
    try {
      final bytes = image.planes[0].bytes;
      if (bytes.isEmpty) return;
      final step = max(1, (bytes.length ~/ 50).toInt());
      double sum = 0;
      int count = 0;
      for (int i = 0; i < bytes.length; i += step) { sum += bytes[i]; count++; }
      final avg = count>0 ? sum/count : 0.0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_scanning) _ppg.addSample(avg, now);
      _frameCounter++;
      if (_frameCounter % 30 == 0 && !_scanning) if (mounted) setState(() {});
    } catch (e) {}
  }

  void _startScan() {
    _ppg.reset();
    setState(() { _scanning = true; _lastBpm = 0.0; });
    Future.delayed(const Duration(seconds: 12), () async {
      if (!mounted) return;
      setState(() => _scanning = false);
      final bpm = _ppg.estimateBpm();
      final movement = _vibration;
      final fusion = EnergyFusion.computeScores(bpm: bpm, movement: movement);
      final energy = fusion['energy'] as double;
      final auraColor = fusion['auraColor'] as String;
      final result = EnergyResult(bpm: bpm, movement: movement, energyScore: energy, auraColor: auraColor);

      // save to backend
      final resp = await _scanRepo.saveScan(bpm: result.bpm, movement: result.movement, energyScore: result.energyScore, auraColor: result.auraColor);
      if (!resp['ok']) {
        // optionally show error
      }

      if (mounted) Navigator.pop(context, result);
    });
  }

  @override
  void dispose() { _controller?.stopImageStream(); _controller?.dispose(); _sensor.stop(); _bpmTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner l'aura"), backgroundColor: AppTheme.primaryTeal),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.darkBlue], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            _cameraPreviewWidget(),
            const SizedBox(height: 12),
            Text(_scanning ? 'Scan en cours...' : 'Prêt', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Vibration: ${_vibration.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('BPM actuel: ${_lastBpm > 0 ? _lastBpm.toStringAsFixed(1) : "--"}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            AppTheme.gradientButton(text: _scanning ? 'Scan...' : 'Démarrer le scan (12s)', loading: _scanning, onPressed: _cameraReady && !_scanning ? _startScan : null),
          ]),
        ),
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    if (_controller == null || !_controller!.value.isInitialized) return Container(height:220, decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Caméra indisponible', style: TextStyle(color: Colors.white))));
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(height:220, child: CameraPreview(_controller!)));
  }
}


