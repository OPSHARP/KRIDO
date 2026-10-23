import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/procedural_sfx_engine.dart';

/// Interactive Magic Touch Overlay:
/// 1. Replaces star particles with a dynamic, aerodynamic wind & meadow breeze effect:
///    - Generates flowing aerodynamic wind ribbon streams with stylized vortex curls when dragging/scrolling.
///    - Sweeps up organic fluttering meadow leaves & petals tumbling along the swipe direction.
///    - Emits gentle radial breeze puffs upon tapping.
/// 2. Floats gentle iridescent soap bubbles that wobble upward.
/// 3. Popping bubbles produces cheerful bubble pop SFX & a breezy burst of leaves.
/// 4. Does NOT block any underlying clicks or card touches (HitTestBehavior.translucent).
class MagicTouchOverlay extends StatefulWidget {
  final Widget child;
  final bool enableBubbles;
  final bool enableSparkles; // Kept as alias for backwards compatibility
  final bool enableWind;

  const MagicTouchOverlay({
    super.key,
    required this.child,
    this.enableBubbles = true,
    this.enableSparkles = true,
    this.enableWind = true,
  });

  @override
  State<MagicTouchOverlay> createState() => _MagicTouchOverlayState();
}

/// Fluttering meadow breeze leaf or flower petal swept up by touch scroll.
class _WindLeaf {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double alpha;
  Color color;
  double rotation;
  double vr;
  double flutterPhase;

  _WindLeaf({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.alpha,
    required this.color,
    required this.rotation,
    required this.vr,
    required this.flutterPhase,
  });
}

/// Dynamic aerodynamic wind gust ribbon with optional cartoon spiral vortex curl.
class _WindStream {
  Offset start;
  Offset control;
  Offset end;
  double progress = 0.0;
  double alpha;
  double strokeWidth;
  Color color;
  bool hasSwirl;
  double swirlAngle;
  double swirlRadius;

  _WindStream({
    required this.start,
    required this.control,
    required this.end,
    required this.alpha,
    required this.strokeWidth,
    required this.color,
    this.hasSwirl = false,
    this.swirlAngle = 0.0,
    this.swirlRadius = 8.0,
  });
}

/// Gentle expanding radial breeze air ripple on tap down or bubble pop.
class _BreezePuff {
  Offset center;
  double radius;
  double maxRadius;
  double alpha;
  Color color;

  _BreezePuff({
    required this.center,
    required this.radius,
    required this.maxRadius,
    required this.alpha,
    required this.color,
  });
}

/// Point in live touch streamer trail
class _TouchWindPoint {
  Offset position;
  DateTime timestamp;
  _TouchWindPoint(this.position, this.timestamp);
}

/// Iridescent soap bubble floating upward
class _FloatingBubble {
  double x;
  double y;
  double radius;
  double speed;
  double wobbleOffset;
  double wobbleSpeed;
  Color tint;

  _FloatingBubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.wobbleOffset,
    required this.wobbleSpeed,
    required this.tint,
  });
}

class _MagicTouchOverlayState extends State<MagicTouchOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_WindLeaf> _leaves = [];
  final List<_WindStream> _streams = [];
  final List<_BreezePuff> _puffs = [];
  final List<_TouchWindPoint> _touchTrail = [];
  final List<_FloatingBubble> _bubbles = [];

  final math.Random _rng = math.Random();
  double _elapsedTime = 0.0;
  Size _screenSize = Size.zero;
  Offset _lastPointerPos = Offset.zero;
  DateTime _lastWhooshTime = DateTime.fromMillisecondsSinceEpoch(0);

  static const List<Color> _leafColors = [
    Color(0xFF81C784), // Fresh Spring Green
    Color(0xFFA5D6A7), // Soft Pastel Leaf
    Color(0xFF66BB6A), // Lush Meadow Green
    Color(0xFFB2DFDB), // Airy Mint Breeze
    Color(0xFFFFCDD2), // Soft Sakura Blossom Petal
    Color(0xFFFFF59D), // Sunny Meadow Pollen Leaf
  ];

  static const List<Color> _bubbleColors = [
    Color(0xFFFFD54F),
    Color(0xFFFF4081),
    Color(0xFF00E5FF),
    Color(0xFFB388FF),
    Color(0xFF76FF03),
    Colors.white,
  ];

  bool get _isWindEnabled => widget.enableWind && widget.enableSparkles;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick);
    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool _wasActive = false;

  void _onTick() {
    _elapsedTime += 0.016;

    // 1. Update fluttering wind leaves
    for (int i = _leaves.length - 1; i >= 0; i--) {
      final leaf = _leaves[i];
      leaf.x += leaf.vx + math.sin(_elapsedTime * 6.5 + leaf.flutterPhase) * 1.3;
      leaf.y += leaf.vy - 0.35; // gentle aerodynamic buoyant lift
      leaf.vx *= 0.93; // air drag resistance
      leaf.vy *= 0.93;
      leaf.rotation += leaf.vr;
      leaf.alpha -= 0.024;
      if (leaf.alpha <= 0.0) {
        _leaves.removeAt(i);
      }
    }

    // 2. Update dynamic wind streams
    for (int i = _streams.length - 1; i >= 0; i--) {
      final s = _streams[i];
      s.progress += 0.055;
      s.alpha -= 0.038;
      if (s.alpha <= 0.0 || s.progress >= 1.0) {
        _streams.removeAt(i);
      }
    }

    // 3. Update breeze puffs
    for (int i = _puffs.length - 1; i >= 0; i--) {
      final p = _puffs[i];
      p.radius += (p.maxRadius - p.radius) * 0.20 + 0.9;
      p.alpha -= 0.045;
      if (p.alpha <= 0.0 || p.radius >= p.maxRadius) {
        _puffs.removeAt(i);
      }
    }

    // 4. Prune live touch trail
    final now = DateTime.now();
    _touchTrail.removeWhere((tp) =>
        now.difference(tp.timestamp).inMilliseconds > 260);

    // 5. Update floating soap bubbles
    if (widget.enableBubbles && _screenSize.width > 0 && _screenSize.height > 0) {
      if (_bubbles.length < 9 && _rng.nextDouble() < 0.04) {
        _spawnBubble();
      }

      for (int i = _bubbles.length - 1; i >= 0; i--) {
        final b = _bubbles[i];
        b.y -= b.speed;
        b.x += math.sin(_elapsedTime * b.wobbleSpeed + b.wobbleOffset) * 0.8;

        if (b.y < -b.radius * 2) {
          _bubbles.removeAt(i);
        }
      }
    }

    final bool hasEntities = _leaves.isNotEmpty ||
        _streams.isNotEmpty ||
        _puffs.isNotEmpty ||
        _touchTrail.isNotEmpty ||
        _bubbles.isNotEmpty;

    if (hasEntities || _wasActive) {
      _wasActive = hasEntities;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _spawnBubble() {
    final x = _rng.nextDouble() * _screenSize.width;
    final y = _screenSize.height + 40.0;
    final radius = 18.0 + _rng.nextDouble() * 26.0;
    final speed = 0.6 + _rng.nextDouble() * 0.9;
    final wobbleOffset = _rng.nextDouble() * math.pi * 2;
    final wobbleSpeed = 1.5 + _rng.nextDouble() * 2.0;
    final tint = _bubbleColors[_rng.nextInt(_bubbleColors.length)].withOpacity(0.35);

    _bubbles.add(_FloatingBubble(
      x: x,
      y: y,
      radius: radius,
      speed: speed,
      wobbleOffset: wobbleOffset,
      wobbleSpeed: wobbleSpeed,
      tint: tint,
    ));
  }

  void _addWindStream(Offset from, Offset to, double speed) {
    if (!_isWindEnabled) return;

    final delta = to - from;
    final angle = math.atan2(delta.dy, delta.dx);
    final distance = delta.distance;

    // Curved aerodynamic wind trajectory
    final curveOffset = (_rng.nextDouble() - 0.5) * 16.0;
    final normal = Offset(-math.sin(angle) * curveOffset, math.cos(angle) * curveOffset);
    final control = (from + to) / 2.0 + normal;

    final hasSwirl = distance > 14.0 && _rng.nextDouble() < 0.35;
    final swirlRadius = 6.0 + _rng.nextDouble() * 7.0;

    _streams.add(_WindStream(
      start: from,
      control: control,
      end: to,
      alpha: 0.92,
      strokeWidth: (2.2 + _rng.nextDouble() * 1.8).clamp(2.0, 4.5),
      color: const Color(0xFFE0F7FA),
      hasSwirl: hasSwirl,
      swirlAngle: angle,
      swirlRadius: swirlRadius,
    ));

    // Sweep up fluttering meadow leaves along the wind path
    final leafCount = (speed > 16.0 ? 2 : 1);
    for (int i = 0; i < leafCount; i++) {
      if (_rng.nextDouble() < 0.7) {
        final leafSpread = Offset(
          (_rng.nextDouble() - 0.5) * 22.0,
          (_rng.nextDouble() - 0.5) * 22.0,
        );
        final leafSpeed = (speed * 0.35 + _rng.nextDouble() * 2.5).clamp(2.0, 9.0);
        final spreadAngle = angle + (_rng.nextDouble() - 0.5) * 0.6;

        _leaves.add(_WindLeaf(
          x: to.dx + leafSpread.dx,
          y: to.dy + leafSpread.dy,
          vx: math.cos(spreadAngle) * leafSpeed,
          vy: math.sin(spreadAngle) * leafSpeed - 0.8,
          size: 7.0 + _rng.nextDouble() * 6.5,
          alpha: 0.95,
          color: _leafColors[_rng.nextInt(_leafColors.length)],
          rotation: _rng.nextDouble() * math.pi * 2,
          vr: (_rng.nextDouble() - 0.5) * 0.28,
          flutterPhase: _rng.nextDouble() * math.pi * 2,
        ));
      }
    }

    // Play subtle whoosh sound on swift swipe
    if (speed > 28.0) {
      final now = DateTime.now();
      if (now.difference(_lastWhooshTime).inMilliseconds > 650) {
        _lastWhooshTime = now;
        ProceduralSfxEngine().playWhoosh().catchError((_) {});
      }
    }
  }

  void _addTapBreezePuff(Offset position) {
    if (!_isWindEnabled) return;

    _puffs.add(_BreezePuff(
      center: position,
      radius: 8.0,
      maxRadius: 36.0,
      alpha: 0.85,
      color: const Color(0xFFE0F7FA),
    ));

    // Spawn 2-3 gentle leaves drifting outward from the tap center
    for (int i = 0; i < 3; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 1.2 + _rng.nextDouble() * 2.2;
      _leaves.add(_WindLeaf(
        x: position.dx,
        y: position.dy,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 0.6,
        size: 7.5 + _rng.nextDouble() * 5.5,
        alpha: 0.95,
        color: _leafColors[_rng.nextInt(_leafColors.length)],
        rotation: _rng.nextDouble() * math.pi * 2,
        vr: (_rng.nextDouble() - 0.5) * 0.2,
        flutterPhase: _rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  void _checkBubblePop(Offset position) {
    if (!widget.enableBubbles) return;
    for (int i = _bubbles.length - 1; i >= 0; i--) {
      final b = _bubbles[i];
      final dx = position.dx - b.x;
      final dy = position.dy - b.y;
      final distSq = dx * dx + dy * dy;
      if (distSq <= (b.radius + 15) * (b.radius + 15)) {
        // Pop bubble!
        ProceduralSfxEngine().playBubble().catchError((_) {});

        // Emit airy pop ripple
        _puffs.add(_BreezePuff(
          center: Offset(b.x, b.y),
          radius: 12.0,
          maxRadius: b.radius * 2.4,
          alpha: 0.9,
          color: Colors.white,
        ));

        // Burst of fluttering leaves
        for (int k = 0; k < 6; k++) {
          final angle = _rng.nextDouble() * math.pi * 2;
          final speed = 2.0 + _rng.nextDouble() * 3.5;
          _leaves.add(_WindLeaf(
            x: b.x,
            y: b.y,
            vx: math.cos(angle) * speed,
            vy: math.sin(angle) * speed - 1.0,
            size: 8.0 + _rng.nextDouble() * 6.0,
            alpha: 0.95,
            color: _leafColors[_rng.nextInt(_leafColors.length)],
            rotation: _rng.nextDouble() * math.pi * 2,
            vr: (_rng.nextDouble() - 0.5) * 0.3,
            flutterPhase: _rng.nextDouble() * math.pi * 2,
          ));
        }

        _bubbles.removeAt(i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _screenSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            _lastPointerPos = event.localPosition;
            _touchTrail.clear();
            _touchTrail.add(_TouchWindPoint(event.localPosition, DateTime.now()));
            _checkBubblePop(event.localPosition);
            _addTapBreezePuff(event.localPosition);
          },
          onPointerMove: (event) {
            final delta = event.localPosition - _lastPointerPos;
            final distance = delta.distance;

            _touchTrail.add(_TouchWindPoint(event.localPosition, DateTime.now()));

            if (distance > 3.0) {
              _addWindStream(_lastPointerPos, event.localPosition, distance);
              _lastPointerPos = event.localPosition;
            }
          },
          onPointerUp: (_) {
            _touchTrail.clear();
          },
          onPointerCancel: (_) {
            _touchTrail.clear();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _WindBreezeOverlayPainter(
                      bubbles: _bubbles,
                      streams: _streams,
                      leaves: _leaves,
                      puffs: _puffs,
                      touchTrail: _touchTrail,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WindBreezeOverlayPainter extends CustomPainter {
  final List<_FloatingBubble> bubbles;
  final List<_WindStream> streams;
  final List<_WindLeaf> leaves;
  final List<_BreezePuff> puffs;
  final List<_TouchWindPoint> touchTrail;

  _WindBreezeOverlayPainter({
    required this.bubbles,
    required this.streams,
    required this.leaves,
    required this.puffs,
    required this.touchTrail,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // -------------------------------------------------------------------------
    // 1. Draw iridescent soap bubbles
    // -------------------------------------------------------------------------
    for (final b in bubbles) {
      final center = Offset(b.x, b.y);

      // Bubble base glow
      final bubblePaint = Paint()
        ..color = b.tint
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, b.radius, bubblePaint);

      // Iridescent rainbow rim gradient
      final rimPaint = Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.cyan.withOpacity(0.6),
            Colors.pinkAccent.withOpacity(0.6),
            Colors.amber.withOpacity(0.6),
            Colors.cyan.withOpacity(0.6),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: b.radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, b.radius, rimPaint);

      // Crescent sheen highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        center + Offset(-b.radius * 0.35, -b.radius * 0.35),
        b.radius * 0.28,
        highlightPaint,
      );

      // Secondary tiny glint
      canvas.drawCircle(
        center + Offset(b.radius * 0.35, b.radius * 0.35),
        b.radius * 0.12,
        highlightPaint,
      );
    }

    // -------------------------------------------------------------------------
    // 2. Draw breeze puffs (air ripples on tap)
    // -------------------------------------------------------------------------
    for (final puff in puffs) {
      final alpha = puff.alpha.clamp(0.0, 1.0);

      final outerGlowPaint = Paint()
        ..color = puff.color.withOpacity(alpha * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(puff.center, puff.radius, outerGlowPaint);

      final corePaint = Paint()
        ..color = Colors.white.withOpacity(alpha * 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(puff.center, puff.radius, corePaint);
    }

    // -------------------------------------------------------------------------
    // 3. Draw live touch drag wind ribbon (silky trail behind finger)
    // -------------------------------------------------------------------------
    if (touchTrail.length >= 2) {
      final now = DateTime.now();
      for (int i = 0; i < touchTrail.length - 1; i++) {
        final p1 = touchTrail[i];
        final p2 = touchTrail[i + 1];
        final ageMs = now.difference(p2.timestamp).inMilliseconds;
        final life = (1.0 - (ageMs / 260.0)).clamp(0.0, 1.0);
        if (life <= 0.05) continue;

        final width = (i / touchTrail.length) * 4.5 * life + 1.2;

        // Outer breeze halo
        final haloPaint = Paint()
          ..color = const Color(0xFF80DEEA).withOpacity(life * 0.35)
          ..strokeWidth = width + 3.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1.position, p2.position, haloPaint);

        // Inner translucent white wind streamer
        final corePaint = Paint()
          ..color = Colors.white.withOpacity(life * 0.75)
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1.position, p2.position, corePaint);
      }
    }

    // -------------------------------------------------------------------------
    // 4. Draw aerodynamic wind streams (curved breeze streaks + vortex swirls)
    // -------------------------------------------------------------------------
    for (final s in streams) {
      final alpha = s.alpha.clamp(0.0, 1.0);
      final path = Path()
        ..moveTo(s.start.dx, s.start.dy)
        ..quadraticBezierTo(s.control.dx, s.control.dy, s.end.dx, s.end.dy);

      if (s.hasSwirl) {
        final r = s.swirlRadius;
        final a = s.swirlAngle;
        final center = s.end + Offset(math.cos(a + math.pi / 2) * r, math.sin(a + math.pi / 2) * r);
        final rect = Rect.fromCircle(center: center, radius: r);
        path.addArc(rect, a - math.pi / 2, math.pi * 1.3);
      }

      // Outer soft cyan wind glow
      final glowPaint = Paint()
        ..color = s.color.withOpacity(alpha * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.strokeWidth + 2.8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawPath(path, glowPaint);

      // Core crisp airy streamer
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(alpha * 0.88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, corePaint);
    }

    // -------------------------------------------------------------------------
    // 5. Draw fluttering meadow breeze leaves & petals (NO STARS)
    // -------------------------------------------------------------------------
    for (final leaf in leaves) {
      final alpha = leaf.alpha.clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(leaf.x, leaf.y);
      canvas.rotate(leaf.rotation);

      final s = leaf.size;
      final leafPath = Path()
        ..moveTo(0, -s)
        ..quadraticBezierTo(s * 0.58, -s * 0.2, 0, s)
        ..quadraticBezierTo(-s * 0.58, -s * 0.2, 0, -s);

      // 3D drop shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(alpha * 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawPath(leafPath.shift(const Offset(0, 1.6)), shadowPaint);

      // Leaf body fill
      final fillPaint = Paint()
        ..color = leaf.color.withOpacity(alpha)
        ..style = PaintingStyle.fill;
      canvas.drawPath(leafPath, fillPaint);

      // Crisp highlight rim
      final rimPaint = Paint()
        ..color = Colors.white.withOpacity(alpha * 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(leafPath, rimPaint);

      // Delicate center vein
      final veinPaint = Paint()
        ..color = Colors.white.withOpacity(alpha * 0.5)
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, -s * 0.72), Offset(0, s * 0.72), veinPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WindBreezeOverlayPainter oldDelegate) => true;
}
