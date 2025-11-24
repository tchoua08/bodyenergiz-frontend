import 'package:flutter/material.dart';

class AuraAnimation extends StatefulWidget {
  final double size;
  final Color color;
  const AuraAnimation({super.key, required this.size, required this.color});

  @override
  State<AuraAnimation> createState() => _AuraAnimationState();
}

class _AuraAnimationState extends State<AuraAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _ctr;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.12).animate(CurvedAnimation(parent: _ctr, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctr,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [widget.color.withOpacity(.35), widget.color.withOpacity(.12)]),
              boxShadow: [BoxShadow(color: widget.color.withOpacity(.2), blurRadius: 20, spreadRadius: 6)],
            ),
            child: child,
          ),
        );
      },
      child: Center(child: Icon(Icons.auto_awesome, color: widget.color, size: widget.size * 0.45)),
    );
  }
}


