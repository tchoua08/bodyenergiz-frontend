import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class EnergyGauge extends StatelessWidget {
  final double score; // 0 → 100

  const EnergyGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0, 100).toDouble();

    return CustomPaint(
      size: const Size(180, 180),
      painter: _GaugePainter(value: clamped),
      child: Center(
        child: Text(
          "${clamped.toStringAsFixed(0)}%",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;

  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - stroke;

    final basePaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppTheme.primaryTeal,
          AppTheme.darkBlue,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 2,
      false,
      basePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 2 * (value / 100),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


