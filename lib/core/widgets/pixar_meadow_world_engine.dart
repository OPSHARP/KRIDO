import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../audio/audio_service.dart';
import '../environment/celestial_time_engine.dart';

/// Pixar Meadow World Engine
/// Accurately renders the lush cartoon atmosphere from the Krido hero photo:
/// - Sunny cerulean sky with subtle sunbeams and fluffy 3D cumulus clouds
/// - Sparkling turquoise valley lake and distant rolling mountain silhouettes
/// - Multi-layered rolling emerald green hills with blooming white daisies
/// - Interactive floating 3D jigsaw puzzle pieces (Cyan & Magenta)
/// - Interactive floating smiling golden stars
/// - Tap-to-burst magical particle dust engine
/// - Dynamic Day, Sunset, and Night celestial lighting phases
class PixarMeadowWorldEngine extends StatefulWidget {
  final CelestialPhase phase;
  final double tiltX;
  final double tiltY;
  final Widget? child;
  final void Function(SoundCue cue)? onPlayCue;

  const PixarMeadowWorldEngine({
    super.key,
    required this.phase,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
    this.child,
    this.onPlayCue,
  });

  @override
  State<PixarMeadowWorldEngine> createState() => _PixarMeadowWorldEngineState();
}

class _PixarMeadowWorldEngineState extends State<PixarMeadowWorldEngine>
    with TickerProviderStateMixin {
  late AnimationController _ambientLoopController;
  late AnimationController _flowerBreezeController;

  final List<_SparkleParticle> _sparkles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _ambientLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _flowerBreezeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientLoopController.dispose();
    _flowerBreezeController.dispose();
    super.dispose();
  }

  void _triggerSparkleBurst(Offset position) {
    widget.onPlayCue?.call(SoundCue.star);
    HapticFeedback.lightImpact();

    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFF4081),
      const Color(0xFF00E5FF),
      const Color(0xFF76FF03),
      const Color(0xFFFFAB00),
      Colors.white,
    ];

    setState(() {
      for (int i = 0; i < 12; i++) {
        final angle = (_random.nextDouble() * 2 * math.pi);
        final speed = 35.0 + _random.nextDouble() * 65.0;
        final color = colors[_random.nextInt(colors.length)];
        final size = 6.0 + _random.nextDouble() * 10.0;
        final isPuzzle = _random.nextBool();

        _sparkles.add(_SparkleParticle(
          position: position,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: size,
          isPuzzle: isPuzzle,
          rotation: _random.nextDouble() * 2 * math.pi,
          createdTime: DateTime.now(),
        ));
      }
    });
  }

  void _updateSparkles() {
    final now = DateTime.now();
    _sparkles.removeWhere((p) =>
        now.difference(p.createdTime).inMilliseconds > 900);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ambientLoopController, _flowerBreezeController]),
      builder: (context, _) {
        _updateSparkles();
        final progress = _ambientLoopController.value;
        final breeze = _flowerBreezeController.value;

        return Listener(
          onPointerDown: (event) {
            _triggerSparkleBurst(event.localPosition);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: Living Landscape Custom Paint
              CustomPaint(
                painter: _PixarMeadowPainter(
                  phase: widget.phase,
                  progress: progress,
                  breeze: breeze,
                  tiltX: widget.tiltX,
                  tiltY: widget.tiltY,
                ),
                size: Size.infinite,
              ),

              // Layer 2: Interactive Floating Elements (Clouds, Puzzle Pieces, Stars)
              _buildFloatingElements(progress),

              // Layer 3: Main Screen Content
              if (widget.child != null) widget.child!,

              // Layer 4: Floating Touch Sparkle Particles
              if (_sparkles.isNotEmpty)
                IgnorePointer(
                  child: CustomPaint(
                    painter: _SparkleParticlePainter(_sparkles),
                    size: Size.infinite,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingElements(double progress) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Floating Cyan Puzzle Piece (upper sky, matching photo)
        final puzzle1X = w * 0.68 + math.sin(progress * 2 * math.pi) * 10 + widget.tiltX * 16;
        final puzzle1Y = h * 0.11 + math.cos(progress * 2 * math.pi) * 6 + widget.tiltY * 12;

        // Floating Magenta Puzzle Piece (upper sky, matching photo)
        final puzzle2X = w * 0.74 + math.cos(progress * 2 * math.pi + 1.2) * 8 + widget.tiltX * 16;
        final puzzle2Y = h * 0.15 + math.sin(progress * 2 * math.pi + 1.2) * 6 + widget.tiltY * 12;

        // Floating Smiling Golden Star (left upper sky)
        final star1X = w * 0.06 + math.sin(progress * 2 * math.pi + 2.5) * 6 + widget.tiltX * 10;
        final star1Y = h * 0.20 + math.cos(progress * 2 * math.pi + 2.5) * 6 + widget.tiltY * 8;

        // Floating Smiling Star (right upper sky)
        final star2X = w * 0.82 + math.cos(progress * 2 * math.pi + 3.8) * 8 + widget.tiltX * 10;
        final star2Y = h * 0.09 + math.sin(progress * 2 * math.pi + 3.8) * 5 + widget.tiltY * 8;

        return Stack(
          children: [
            // Puzzle Piece 1: Sky Cyan
            Positioned(
              left: puzzle1X - 22,
              top: puzzle1Y - 22,
              child: _buildInteractivePuzzlePiece(
                color: const Color(0xFF00B0FF),
                accentColor: const Color(0xFF80D8FF),
                size: 44,
                rotation: -0.22 + math.sin(progress * 2 * math.pi) * 0.12,
              ),
            ),

            // Puzzle Piece 2: Candy Magenta / Red
            Positioned(
              left: puzzle2X - 20,
              top: puzzle2Y - 20,
              child: _buildInteractivePuzzlePiece(
                color: const Color(0xFFFF1744),
                accentColor: const Color(0xFFFF80AB),
                size: 40,
                rotation: 0.28 + math.cos(progress * 2 * math.pi) * 0.12,
              ),
            ),

            // Smiling Star 1
            Positioned(
              left: star1X - 18,
              top: star1Y - 18,
              child: _buildInteractiveSmilingStar(size: 36, progress: progress),
            ),

            // Smiling Star 2
            Positioned(
              left: star2X - 16,
              top: star2Y - 16,
              child: _buildInteractiveSmilingStar(size: 32, progress: progress + 0.5),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInteractivePuzzlePiece({
    required Color color,
    required Color accentColor,
    required double size,
    required double rotation,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onPlayCue?.call(SoundCue.snap);
        HapticFeedback.mediumImpact();
        _triggerSparkleBurst(Offset(size / 2, size / 2));
      },
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.28),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.55),
                offset: const Offset(0, 5),
                blurRadius: 10,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Highlight shine
              Positioned(
                top: 4,
                left: 6,
                child: Container(
                  width: size * 0.35,
                  height: size * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              // Jigsaw center tab indicator
              Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveSmilingStar({
    required double size,
    required double progress,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onPlayCue?.call(SoundCue.star);
        HapticFeedback.lightImpact();
        _triggerSparkleBurst(Offset(size / 2, size / 2));
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD54F),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFAB00).withOpacity(0.6),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Highlight
            Positioned(
              top: 3,
              left: 5,
              child: Container(
                width: size * 0.3,
                height: size * 0.18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Cute kawaii face
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 3.5,
                      height: 4.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5D4037),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3.5,
                      height: 4.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5D4037),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  width: 7,
                  height: 3.5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE65100),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Particle representation for tap sparkles
class _SparkleParticle {
  Offset position;
  final Offset velocity;
  final Color color;
  final double size;
  final bool isPuzzle;
  final double rotation;
  final DateTime createdTime;

  _SparkleParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.isPuzzle,
    required this.rotation,
    required this.createdTime,
  });
}

class _SparkleParticlePainter extends CustomPainter {
  final List<_SparkleParticle> particles;

  _SparkleParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();

    for (final p in particles) {
      final elapsed = now.difference(p.createdTime).inMilliseconds / 900.0;
      if (elapsed >= 1.0) continue;

      final fade = 1.0 - elapsed;
      final currentPos = p.position + p.velocity * elapsed;

      final paint = Paint()
        ..color = p.color.withOpacity(fade.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentPos.dx, currentPos.dy);
      canvas.rotate(p.rotation + elapsed * 3);

      if (p.isPuzzle) {
        // Draw tiny jigsaw piece
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size * fade,
          height: p.size * fade,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(p.size * 0.25)), paint);
      } else {
        // Draw organic breeze petal / fluttering leaf
        final r = (p.size * fade);
        final path = Path()
          ..moveTo(0, -r)
          ..quadraticBezierTo(r * 0.55, -r * 0.2, 0, r)
          ..quadraticBezierTo(-r * 0.55, -r * 0.2, 0, -r);
        canvas.drawPath(path, paint);

        // Subtle center vein
        final veinPaint = Paint()
          ..color = Colors.white.withOpacity((fade * 0.45).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        canvas.drawLine(Offset(0, -r * 0.7), Offset(0, r * 0.7), veinPaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleParticlePainter oldDelegate) => true;
}

/// Custom painter for the rolling Pixar hills, sparkling lake, and daisies
class _PixarMeadowPainter extends CustomPainter {
  final CelestialPhase phase;
  final double progress;
  final double breeze;
  final double tiltX;
  final double tiltY;

  _PixarMeadowPainter({
    required this.phase,
    required this.progress,
    required this.breeze,
    required this.tiltX,
    required this.tiltY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. SKY GRADIENT
    _paintSky(canvas, size);

    // 2. SUN OR MOON
    _paintCelestialBody(canvas, size);

    // 3. FLUFFY 3D CUMULUS CLOUDS
    _paintClouds(canvas, size);

    // 4. DISTANT CYAN MOUNTAINS
    _paintDistantMountains(canvas, size);

    // 5. SPARKLING TURQUOISE VALLEY LAKE
    _paintValleyLake(canvas, size);

    // 6. MULTI-TIER ROLLING GREEN HILLS
    _paintRollingHills(canvas, size);

    // 7. BLOOMING DAISIES & LAWN FLORA
    _paintFlora(canvas, size);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    late final Gradient gradient;

    switch (phase) {
      case CelestialPhase.day:
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF29B6F6), // Cerulean sky
            Color(0xFF81D4FA), // Soft bright blue
            Color(0xFFE1F5FE), // Horizon haze
          ],
          stops: [0.0, 0.55, 1.0],
        );
        break;
      case CelestialPhase.sunset:
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7E57C2), // Twilight Purple
            Color(0xFFFF7043), // Coral Sunset
            Color(0xFFFFE082), // Golden horizon
          ],
          stops: [0.0, 0.55, 1.0],
        );
        break;
      case CelestialPhase.night:
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B2A), // Midnight
            Color(0xFF1B263B), // Deep Indigo
            Color(0xFF415A77), // Horizon glow
          ],
          stops: [0.0, 0.6, 1.0],
        );
        break;
      default:
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFFE0F7FA)],
        );
    }

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintCelestialBody(Canvas canvas, Size size) {
    final isDay = phase == CelestialPhase.day;
    final isSunset = phase == CelestialPhase.sunset;

    if (isDay || isSunset) {
      // Golden Sun with glowing aura and soft rays
      final sunCenter = Offset(
        size.width * 0.76 + tiltX * 10,
        size.height * 0.14 + tiltY * 10,
      );

      // Outer glowing ring
      final glowPaint = Paint()
        ..color = (isDay ? const Color(0xFFFFF9C4) : const Color(0xFFFFD54F))
            .withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(sunCenter, 46, glowPaint);

      // Sun core
      final sunPaint = Paint()
        ..shader = RadialGradient(
          colors: isDay
              ? [const Color(0xFFFFFDE7), const Color(0xFFFFD54F)]
              : [const Color(0xFFFFE082), const Color(0xFFFF6F00)],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: 28));
      canvas.drawCircle(sunCenter, 28, sunPaint);
    } else {
      // Glowing Crescent Moon
      final moonCenter = Offset(
        size.width * 0.80 + tiltX * 10,
        size.height * 0.15 + tiltY * 10,
      );

      final glowPaint = Paint()
        ..color = const Color(0xFFE0F7FA).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(moonCenter, 32, glowPaint);

      final moonPaint = Paint()..color = const Color(0xFFFFFDE7);
      canvas.drawCircle(moonCenter, 22, moonPaint);

      final cutoutPaint = Paint()..color = const Color(0xFF0D1B2A);
      canvas.drawCircle(moonCenter + const Offset(-7, -4), 18, cutoutPaint);
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    if (phase == CelestialPhase.night) return;

    final w = size.width;
    final h = size.height;

    // Cloud 1: Top Left
    _draw3DCloud(
      canvas,
      Offset(w * 0.14 + math.sin(progress * 2 * math.pi) * 8 + tiltX * 15, h * 0.12),
      scale: 1.1,
      opacity: 0.92,
    );

    // Cloud 2: Top Center
    _draw3DCloud(
      canvas,
      Offset(w * 0.48 + math.cos(progress * 2 * math.pi) * 10 + tiltX * 12, h * 0.08),
      scale: 0.85,
      opacity: 0.85,
    );

    // Cloud 3: Far Right
    _draw3DCloud(
      canvas,
      Offset(w * 0.88 + math.sin(progress * 2 * math.pi + 1) * 7 + tiltX * 18, h * 0.16),
      scale: 0.95,
      opacity: 0.90,
    );
  }

  void _draw3DCloud(Canvas canvas, Offset center, {double scale = 1.0, double opacity = 1.0}) {
    final shadowPaint = Paint()
      ..color = const Color(0xFFB0BEC5).withOpacity(opacity * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final whitePaint = Paint()
      ..color = Colors.white.withOpacity(opacity);

    final puffRadius = 26.0 * scale;

    // Draw soft bottom shadow
    canvas.drawCircle(center + Offset(0, 6 * scale), puffRadius * 1.2, shadowPaint);

    // Draw composite cloud puffs
    canvas.drawCircle(center + Offset(-puffRadius * 0.8, 2 * scale), puffRadius * 0.85, whitePaint);
    canvas.drawCircle(center + Offset(puffRadius * 0.8, 3 * scale), puffRadius * 0.75, whitePaint);
    canvas.drawCircle(center + Offset(0, -puffRadius * 0.3), puffRadius * 1.05, whitePaint);
    canvas.drawCircle(center + Offset(-puffRadius * 0.35, -puffRadius * 0.1), puffRadius * 0.9, whitePaint);
    canvas.drawCircle(center + Offset(puffRadius * 0.4, 0), puffRadius * 0.88, whitePaint);
  }

  void _paintDistantMountains(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.42 + tiltY * 12;

    final mountainPath = Path()
      ..moveTo(0, horizonY)
      ..lineTo(0, horizonY - 45)
      ..quadraticBezierTo(w * 0.18, horizonY - 80, w * 0.35, horizonY - 30)
      ..quadraticBezierTo(w * 0.52, horizonY - 95, w * 0.72, horizonY - 40)
      ..quadraticBezierTo(w * 0.88, horizonY - 85, w, horizonY - 35)
      ..lineTo(w, horizonY + 60)
      ..lineTo(0, horizonY + 60)
      ..close();

    final mountainColor = phase == CelestialPhase.night
        ? const Color(0xFF1B263B)
        : (phase == CelestialPhase.sunset
            ? const Color(0xFF9575CD)
            : const Color(0xFF80DEEA)); // Cyan-blue haze matching photo

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [mountainColor, mountainColor.withOpacity(0.6)],
      ).createShader(Rect.fromLTWH(0, horizonY - 95, w, 155));

    canvas.drawPath(mountainPath, paint);
  }

  void _paintValleyLake(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final lakeY = h * 0.45 + tiltY * 10;

    final lakePath = Path()
      ..moveTo(w * 0.18, lakeY + 25)
      ..quadraticBezierTo(w * 0.42, lakeY - 5, w * 0.65, lakeY + 30)
      ..quadraticBezierTo(w * 0.40, lakeY + 45, w * 0.18, lakeY + 25)
      ..close();

    final lakeColor = phase == CelestialPhase.night
        ? const Color(0xFF0F3057)
        : (phase == CelestialPhase.sunset
            ? const Color(0xFFFF8A65)
            : const Color(0xFF00ACC1)); // Sparkling turquoise lake

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [lakeColor, const Color(0xFF80DEEA), lakeColor],
      ).createShader(Rect.fromLTWH(w * 0.18, lakeY - 5, w * 0.5, 50));

    canvas.drawPath(lakePath, paint);

    // Lake ripples
    final ripplePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(w * 0.32, lakeY + 18),
      Offset(w * 0.42, lakeY + 18),
      ripplePaint,
    );
    canvas.drawLine(
      Offset(w * 0.38, lakeY + 26),
      Offset(w * 0.50, lakeY + 26),
      ripplePaint,
    );
  }

  void _paintRollingHills(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // HILL LAYER 1: Far Meadow (Mid-Tone Green)
    final hill1Y = h * 0.52 + tiltY * 8;
    final path1 = Path()
      ..moveTo(0, hill1Y)
      ..quadraticBezierTo(w * 0.28, hill1Y - 45, w * 0.58, hill1Y)
      ..quadraticBezierTo(w * 0.82, hill1Y + 35, w, hill1Y - 15)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final color1 = phase == CelestialPhase.night
        ? const Color(0xFF132E28)
        : (phase == CelestialPhase.sunset
            ? const Color(0xFF5D7D3A)
            : const Color(0xFF689F38));

    canvas.drawPath(path1, Paint()..color = color1);

    // HILL LAYER 2: Rolling Emerald Center Hill
    final hill2Y = h * 0.64 + tiltY * 5;
    final path2 = Path()
      ..moveTo(0, hill2Y + 20)
      ..quadraticBezierTo(w * 0.35, hill2Y - 55, w * 0.72, hill2Y - 10)
      ..quadraticBezierTo(w * 0.88, hill2Y + 15, w, hill2Y + 5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final color2Top = phase == CelestialPhase.night
        ? const Color(0xFF1B4332)
        : (phase == CelestialPhase.sunset
            ? const Color(0xFF7CB342)
            : const Color(0xFF7CB342));
    final color2Bottom = phase == CelestialPhase.night
        ? const Color(0xFF0D2818)
        : const Color(0xFF558B2F);

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color2Top, color2Bottom],
      ).createShader(Rect.fromLTWH(0, hill2Y - 55, w, h - hill2Y + 55));

    canvas.drawPath(path2, paint2);

    // HILL LAYER 3: Forefront Grassy Knoll (Vibrant Apple Green matching photo)
    final hill3Y = h * 0.78 + tiltY * 3;
    final path3 = Path()
      ..moveTo(0, hill3Y - 30)
      ..quadraticBezierTo(w * 0.45, hill3Y - 60, w * 0.85, hill3Y - 10)
      ..quadraticBezierTo(w * 0.95, hill3Y + 5, w, hill3Y)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final color3Top = phase == CelestialPhase.night
        ? const Color(0xFF2D6A4F)
        : (phase == CelestialPhase.sunset
            ? const Color(0xFF9CCC65)
            : const Color(0xFF8BC34A));
    final color3Bottom = phase == CelestialPhase.night
        ? const Color(0xFF1B4332)
        : const Color(0xFF689F38);

    final paint3 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color3Top, color3Bottom],
      ).createShader(Rect.fromLTWH(0, hill3Y - 60, w, h - hill3Y + 60));

    canvas.drawPath(path3, paint3);
  }

  void _paintFlora(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scattered Blooming Daisies (matching the daisies in the photo foreground)
    final daisyPositions = [
      Offset(w * 0.12, h * 0.88),
      Offset(w * 0.22, h * 0.93),
      Offset(w * 0.44, h * 0.92),
      Offset(w * 0.68, h * 0.86),
      Offset(w * 0.82, h * 0.91),
      Offset(w * 0.92, h * 0.85),
      Offset(w * 0.32, h * 0.82),
      Offset(w * 0.58, h * 0.80),
    ];

    for (int i = 0; i < daisyPositions.length; i++) {
      final pos = daisyPositions[i];
      final sway = math.sin(breeze * math.pi + i) * 3.0;
      _drawDaisy(canvas, pos + Offset(sway, 0), size: 10 + (i % 3) * 2);
    }
  }

  void _drawDaisy(Canvas canvas, Offset center, {double size = 12.0}) {
    final petalPaint = Paint()..color = Colors.white;
    final centerPaint = Paint()..color = const Color(0xFFFFD54F);

    final petalRadius = size * 0.36;

    // 5 Petals
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5);
      final offset = Offset(math.cos(angle) * petalRadius, math.sin(angle) * petalRadius);
      canvas.drawCircle(center + offset, size * 0.28, petalPaint);
    }

    // Golden Button Center
    canvas.drawCircle(center, size * 0.24, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _PixarMeadowPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.progress != progress ||
        oldDelegate.breeze != breeze ||
        oldDelegate.tiltX != tiltX ||
        oldDelegate.tiltY != tiltY;
  }
}
