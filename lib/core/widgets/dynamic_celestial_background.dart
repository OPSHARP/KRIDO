import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../environment/celestial_time_engine.dart';
import 'cartoon_ui_components.dart';

/// Multi-layered animated landscape background that responds to:
/// 1. Real-time / interactive Time of Day (Dawn, Day, Sunset, Night)
/// 2. Device Parallax Tilt (tiltX, tiltY)
class DynamicCelestialBackground extends StatefulWidget {
  final CelestialPhase phase;
  final double tiltX;
  final double tiltY;
  final Widget? child;

  const DynamicCelestialBackground({
    super.key,
    required this.phase,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
    this.child,
  });

  @override
  State<DynamicCelestialBackground> createState() => _DynamicCelestialBackgroundState();
}

class _DynamicCelestialBackgroundState extends State<DynamicCelestialBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientAnimController;

  @override
  void initState() {
    super.initState();
    _ambientAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ambientAnimController,
      builder: (context, _) {
        final progress = _ambientAnimController.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Sky Gradient with smooth animated transitions
            AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(widget.tiltX * 0.1, -1.0 + widget.tiltY * 0.05),
                  end: Alignment(-widget.tiltX * 0.1, 1.0 - widget.tiltY * 0.05),
                  colors: widget.phase.skyGradient,
                ),
              ),
            ),

            // Layer 2: Celestial Body (Sun or Moon) with Parallax
            _buildCelestialBody(progress),

            // Layer 3: Ambient Atmosphere (Clouds, Fireflies, Stars, Shooting Stars)
            _buildAmbientAtmosphere(progress),

            // Layer 4: Distant Mountains & Castle Silhouette (Parallax depth 0.3)
            Transform.translate(
              offset: Offset(widget.tiltX * 8, widget.tiltY * 4),
              child: CustomPaint(
                painter: _DistantHorizonPainter(
                  phase: widget.phase,
                ),
              ),
            ),

            // Layer 5: Rolling Green/Twilight Foreground Hills (Parallax depth 0.6)
            Transform.translate(
              offset: Offset(widget.tiltX * 16, widget.tiltY * 8),
              child: CustomPaint(
                painter: _ForegroundHillsPainter(
                  phase: widget.phase,
                ),
              ),
            ),

            // Foreground child content (learning hub interface)
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }

  /// Celestial Sun or Moon with orbital path & cute expressions
  Widget _buildCelestialBody(double progress) {
    final isNight = widget.phase.isNight;
    final isSunset = widget.phase == CelestialPhase.sunset;
    final isDawn = widget.phase == CelestialPhase.dawn;

    // Celestial orbital positioning
    double topRatio;
    double leftRatio;

    if (isDawn) {
      topRatio = 0.28;
      leftRatio = 0.12;
    } else if (isSunset) {
      topRatio = 0.35;
      leftRatio = 0.82;
    } else if (isNight) {
      topRatio = 0.18;
      leftRatio = 0.78;
    } else {
      // Day: High in the sky
      topRatio = 0.15;
      leftRatio = 0.55;
    }

    return Positioned(
      top: MediaQuery.of(context).size.height * topRatio + (widget.tiltY * 12),
      left: MediaQuery.of(context).size.width * leftRatio + (widget.tiltX * 12),
      child: isNight
          ? _buildSmilingCrescentMoon(progress)
          : _buildRadiantCartoonSun(progress, isSunset: isSunset, isDawn: isDawn),
    );
  }

  /// Radiant Sun with rotating beam halo & kawaii cheeks
  Widget _buildRadiantCartoonSun(double progress, {required bool isSunset, required bool isDawn}) {
    final sunColor = isSunset
        ? const Color(0xFFFF7043)
        : (isDawn ? const Color(0xFFFFB74D) : const Color(0xFFFFD54F));

    return Transform.rotate(
      angle: progress * 2 * math.pi,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: sunColor,
          boxShadow: [
            BoxShadow(
              color: widget.phase.sunMoonHaloColor,
              blurRadius: 28,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Counter-rotate face so eyes stay upright
            Transform.rotate(
              angle: -progress * 2 * math.pi,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const KawaiiFace(
                    size: 38,
                    blushColor: Color(0xFFFF5252),
                    eyeColor: Color(0xFF2E1C0C),
                  ),
                  if (isSunset)
                    const Text('🕶️', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cute Crescent Moon with sleeping nightcap and glowing halo
  Widget _buildSmilingCrescentMoon(double progress) {
    return Transform.translate(
      offset: Offset(0, math.sin(progress * 2 * math.pi) * 6),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE0E7FF).withOpacity(0.5),
              blurRadius: 26,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Crescent Moon shape
            const Text(
              '🌙',
              style: TextStyle(fontSize: 64),
            ),
            // Sleeping Nightcap
            const Positioned(
              top: -6,
              left: 2,
              child: Text('✨', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  /// Ambient atmosphere particles
  Widget _buildAmbientAtmosphere(double progress) {
    if (widget.phase.isNight) {
      return _buildStarryNightAtmosphere(progress);
    } else if (widget.phase == CelestialPhase.sunset) {
      return _buildSunsetFireflies(progress);
    } else {
      return _buildDaytimeClouds(progress);
    }
  }

  Widget _buildDaytimeClouds(double progress) {
    return Stack(
      children: [
        // Cloud 1
        Positioned(
          top: 30 + widget.tiltY * 5,
          left: (progress * 1.3 * 800) % (MediaQuery.of(context).size.width + 150) - 100,
          child: Opacity(
            opacity: 0.75,
            child: _buildCloud(width: 110, height: 42),
          ),
        ),
        // Cloud 2
        Positioned(
          top: 75 + widget.tiltY * 7,
          left: ((progress * 0.8 + 0.5) * 800) % (MediaQuery.of(context).size.width + 150) - 100,
          child: Opacity(
            opacity: 0.85,
            child: _buildCloud(width: 140, height: 50),
          ),
        ),
        // Floating colorful balloons in day
        Positioned(
          top: 60 - (progress * 40),
          left: 120 + widget.tiltX * 10,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎈', style: TextStyle(fontSize: 22)),
              Text('🎈', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSunsetFireflies(double progress) {
    return Stack(
      children: List.generate(12, (index) {
        final xSeed = ((index * 79) % 100) / 100.0;
        final ySeed = 0.4 + (((index * 47) % 50) / 100.0);
        final pulse = math.sin((progress * 4 * math.pi) + index);

        return Positioned(
          left: MediaQuery.of(context).size.width * xSeed + (widget.tiltX * (index + 2)),
          top: MediaQuery.of(context).size.height * ySeed + (widget.tiltY * (index + 1)) + (pulse * 8),
          child: Opacity(
            opacity: 0.3 + (pulse.abs() * 0.7),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFEB3B),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStarryNightAtmosphere(double progress) {
    return Stack(
      children: [
        // Twinkling Star Field
        ...List.generate(24, (index) {
          final x = ((index * 97) % 100) / 100.0;
          final y = ((index * 53) % 65) / 100.0;
          final twinkle = (math.sin(progress * 6 * math.pi + index) + 1) / 2;

          return Positioned(
            left: MediaQuery.of(context).size.width * x,
            top: MediaQuery.of(context).size.height * y,
            child: Opacity(
              opacity: 0.2 + (twinkle * 0.8),
              child: Text(
                index % 3 == 0 ? '✦' : (index % 3 == 1 ? '★' : '•'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8 + (twinkle * 8),
                ),
              ),
            ),
          );
        }),

        // Shooting Star with Tail
        Positioned(
          top: 40 + (progress * 120),
          left: (progress * 2.0 * MediaQuery.of(context).size.width) % (MediaQuery.of(context).size.width + 200) - 100,
          child: Opacity(
            opacity: math.sin(progress * math.pi),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 35,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.white.withOpacity(0.8)],
                    ),
                  ),
                ),
                const Text('💫', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloud({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

/// Distant mountain and castle horizon painter
class _DistantHorizonPainter extends CustomPainter {
  final CelestialPhase phase;

  _DistantHorizonPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = phase.hillColorSecondary.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.68);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.55, size.width * 0.5, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.75, size.width, size.height * 0.62);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DistantHorizonPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

/// Foreground rolling hills painter
class _ForegroundHillsPainter extends CustomPainter {
  final CelestialPhase phase;

  _ForegroundHillsPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paintPrimary = Paint()
      ..color = phase.hillColorPrimary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.78);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.70, size.width * 0.65, size.height * 0.79);
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.84, size.width, size.height * 0.76);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paintPrimary);

    // Warm top highlight crest line
    final crestPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final crestPath = Path();
    crestPath.moveTo(0, size.height * 0.78);
    crestPath.quadraticBezierTo(size.width * 0.3, size.height * 0.70, size.width * 0.65, size.height * 0.79);
    crestPath.quadraticBezierTo(size.width * 0.85, size.height * 0.84, size.width, size.height * 0.76);

    canvas.drawPath(crestPath, crestPaint);
  }

  @override
  bool shouldRepaint(covariant _ForegroundHillsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
