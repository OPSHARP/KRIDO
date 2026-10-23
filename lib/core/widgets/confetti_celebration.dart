import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiCelebration extends StatefulWidget {
  final VoidCallback? onComplete;

  const ConfettiCelebration({super.key, this.onComplete});

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  static const List<Color> _palette = [
    Color(0xFFFF7675), // Coral
    Color(0xFFFFB236), // Sun Gold
    Color(0xFF7150B8), // Purple
    Color(0xFF75DDF2), // Sky Blue
    Color(0xFF80C94A), // Vibrant Green
    Color(0xFFFF9FF3), // Pink
    Color(0xFF54A0FF), // Bright Blue
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _initParticles();
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  void _initParticles() {
    _particles.clear();
    // 90 vibrant confetti pieces
    for (int i = 0; i < 90; i++) {
      final angle = -pi / 2 + (_rng.nextDouble() - 0.5) * (pi * 0.85);
      final speed = _rng.nextDouble() * 550 + 250;
      _particles.add(
        _Particle(
          x: 0.5,
          y: 0.65, // Burst from center lower portion
          vx: cos(angle) * speed / 400,
          vy: sin(angle) * speed / 400,
          size: _rng.nextDouble() * 10 + 6,
          color: _palette[_rng.nextInt(_palette.length)],
          rotation: _rng.nextDouble() * 2 * pi,
          rotationSpeed: (_rng.nextDouble() - 0.5) * 12,
          isStar: i % 4 == 0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            final opacity = (1.0 - progress).clamp(0.0, 1.0);

            return Opacity(
              opacity: opacity > 0.3 ? 1.0 : opacity / 0.3,
              child: CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: progress,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final bool isStar;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.isStar,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const gravity = 1.4;

    for (final p in particles) {
      final t = progress * 2.6; // time in seconds
      final px = (p.x * size.width) + (p.vx * 150 * t);
      final py = (p.y * size.height) + (p.vy * 220 * t) + (0.5 * gravity * 380 * t * t);
      final currentRotation = p.rotation + (p.rotationSpeed * t);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(currentRotation);

      final paint = Paint()..color = p.color;

      if (p.isStar) {
        _drawStar(canvas, p.size, paint);
      } else {
        // Confetti rectangular ribbon
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
            const Radius.circular(2),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const int points = 5;
    final double outerRadius = size * 0.7;
    final double innerRadius = outerRadius * 0.45;
    final double step = pi / points;

    for (int i = 0; i < 2 * points; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final angle = i * step - pi / 2;
      final x = cos(angle) * r;
      final y = sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
