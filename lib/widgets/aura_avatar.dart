import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AuraAvatar extends StatelessWidget {
  final double size;
  final Widget child;

  const AuraAvatar({
    super.key,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.5),
            blurRadius: 25,
            spreadRadius: 10,
          ),
        ],
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryTeal,
            AppTheme.darkBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipOval(child: child),
        ),
      ),
    );
  }
}


