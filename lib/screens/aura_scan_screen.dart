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
import '../services/auth_repository.dart';
import '../utils/theme.dart';
import 'subscription_screen.dart';

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
  final ScanRepository _scanRepo = ScanRepository();
  final AuthRepository _auth = AuthRepository();

  bool checkingPlan = true;
  bool allowedScan = false;

  double _vibration = 0.0;
  double _lastBpm = 0.0;

  Timer? _bpmTimer;
  int _frameCounter = 0;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionThenInit();
  }

  // ----------------------------------------------------------
  // Vérifie abonnement avant d'initialiser le scanner
  // ----------------------------------------------------------
  Future<void> _checkSubscriptionThenInit() async {
    final plan = await _auth.getSubscriptionStatus();

    setState(() {
      checkingPlan = false;
      allowedScan = plan["ok"] && plan["data"]["active"] == true;
    });

    if (allowedScan) {
      await _initAll();
    }
  }

  // ----------------------------------------------------------
  // Initialisation capteurs + caméra
  // ----------------------------------------------------------
  Future<void> _initAll() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _cameraReady = false);
      return;
    }

    final cams = await availableCameras();
    final back = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cams.first,
    );

    _controller =
        CameraController(back, ResolutionPreset.low, enableAudio: false);
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

  // ----------------------------------------------------------
  // Traitement d'image caméra → PPG
  // ----------------------------------------------------------
  void _processCameraImage(CameraImage image) {
    try {
      final bytes = image.planes[0].bytes;
      if (bytes.isEmpty) return;

      final step = max(1, (bytes.length ~/ 50).toInt());
      double sum = 0;
      int count = 0;

      for (int i = 0; i < bytes.length; i += step) {
        sum += bytes[i];
        count++;
      }
      final avg = count > 0 ? sum / count : 0.0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (_scanning) _ppg.addSample(avg, now);

      _frameCounter++;
      if (_frameCounter % 30 == 0 && !_scanning) {
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  // ----------------------------------------------------------
  // Démarrage du SCAN
  // ----------------------------------------------------------
  void _startScan() {
    _ppg.reset();

    setState(() {
      _scanning = true;
      _lastBpm = 0.0;
    });

    Future.delayed(const Duration(seconds: 12), () async {
      if (!mounted) return;

      setState(() => _scanning = false);

      final bpm = _ppg.estimateBpm();
      final movement = _vibration;

      final fusion =
          EnergyFusion.computeScores(bpm: bpm, movement: movement);

      final result = EnergyResult(
        bpm: bpm,
        movement: movement,
        energyScore: fusion['energy'],
        auraColor: fusion['auraColor'],
      );

      // SAVE
      await _scanRepo.saveScan(
        bpm: result.bpm,
        movement: result.movement,
        energyScore: result.energyScore,
        auraColor: result.auraColor,
      );

      if (mounted) Navigator.pop(context, result);
    });
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _sensor.stop();
    _bpmTimer?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------
  // UI Premium lock
  // ----------------------------------------------------------
  Widget _buildLockedUI() {
    return Container(
      decoration: AppTheme.mainGradient,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("images/logo.png", height: 110),
          const SizedBox(height: 20),
          const Text(
            "Débloque le Scan d’Aura",
            style: TextStyle(
                fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Analyse complète du BPM, vibrations, couleurs d’aura, et conseils IA.",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 35),

          // PREMIUM
          AppTheme.gradientButton(
            text: "Premium – 2.99€ / mois",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
            },
          ),
          const SizedBox(height: 15),

          // PREMIUM PLUS
          AppTheme.gradientButton(
            text: "Premium Plus – 5.99€ / mois",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
            },
          ),

          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
            },
            child: const Text("Voir les avantages",
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // UI SCANNER
  // ----------------------------------------------------------
  Widget _scannerUI() {
    return Container(
      decoration: AppTheme.mainGradient,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _cameraPreviewWidget(),
          const SizedBox(height: 12),
          Text(_scanning ? 'Scan en cours...' : 'Prêt',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Vibration: ${_vibration.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
              'BPM actuel: ${_lastBpm > 0 ? _lastBpm.toStringAsFixed(1) : "--"}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          AppTheme.gradientButton(
            text: _scanning ? 'Scan...' : 'Démarrer le scan (12s)',
            loading: _scanning,
            onPressed: _cameraReady && !_scanning ? _startScan : null,
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // WIDGET CAMERA
  // ----------------------------------------------------------
  Widget _cameraPreviewWidget() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Caméra indisponible', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: CameraPreview(_controller!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (checkingPlan) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner l'aura"),
        backgroundColor: AppTheme.primaryTeal,
      ),
      body: allowedScan ? _scannerUI() : _buildLockedUI(),
    );
  }
}


