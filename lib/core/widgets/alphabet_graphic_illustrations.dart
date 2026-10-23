import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../audio/procedural_sfx_engine.dart';

/// Renders high-quality, vibrant cartoon vector graphic illustrations for every
/// alphabet letter (A to Z and Hindi varnamala) with Pixar-style lighting,
/// glossy highlights, and kawaii expressions.
class AlphabetGraphicArtwork extends StatelessWidget {
  final String letter;
  final double size;
  final bool animate;

  const AlphabetGraphicArtwork({
    super.key,
    required this.letter,
    this.size = 120,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final glyph = letter.toUpperCase();
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(size, size),
          painter: _AlphabetGraphicPainter(glyph: glyph),
        ),
      ),
    );
  }
}

class _AlphabetGraphicPainter extends CustomPainter {
  final String glyph;

  _AlphabetGraphicPainter({required this.glyph});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop shadow under graphic artwork
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.84, w * 0.7, h * 0.12), shadowPaint);

    switch (glyph) {
      case 'A':
        _paintApple(canvas, size);
        break;
      case 'B':
        _paintButterfly(canvas, size);
        break;
      case 'C':
        _paintCat(canvas, size);
        break;
      case 'D':
        _paintDog(canvas, size);
        break;
      case 'E':
        _paintElephant(canvas, size);
        break;
      case 'F':
      case 'म':
        _paintFish(canvas, size);
        break;
      case 'G':
        _paintGiraffe(canvas, size);
        break;
      case 'H':
        _paintHorse(canvas, size);
        break;
      case 'I':
        _paintIceCream(canvas, size);
        break;
      case 'J':
        _paintJellyfish(canvas, size);
        break;
      case 'K':
        _paintKangaroo(canvas, size);
        break;
      case 'L':
        _paintLion(canvas, size);
        break;
      case 'M':
        _paintMonkey(canvas, size);
        break;
      case 'N':
        _paintNest(canvas, size);
        break;
      case 'O':
      case 'उ':
        _paintOwl(canvas, size);
        break;
      case 'P':
        _paintPanda(canvas, size);
        break;
      case 'Q':
        _paintQueen(canvas, size);
        break;
      case 'R':
      case 'ख':
        _paintRabbit(canvas, size);
        break;
      case 'S':
        _paintSun(canvas, size);
        break;
      case 'T':
        _paintTiger(canvas, size);
        break;
      case 'U':
        _paintUmbrella(canvas, size);
        break;
      case 'V':
        _paintViolin(canvas, size);
        break;
      case 'W':
        _paintWatermelon(canvas, size);
        break;
      case 'X':
        _paintXylophone(canvas, size);
        break;
      case 'Y':
        _paintYacht(canvas, size);
        break;
      case 'Z':
        _paintZebra(canvas, size);
        break;
      case 'आ':
        _paintMango(canvas, size);
        break;
      case 'प':
        _paintKite(canvas, size);
        break;
      case 'क':
        _paintLotus(canvas, size);
        break;
      default:
        _paintApple(canvas, size);
        break;
    }
  }

  // ===========================================================================
  // A: SHINY RED APPLE
  // ===========================================================================
  void _paintApple(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemPath = Path()
      ..moveTo(w * 0.50, h * 0.28)
      ..quadraticBezierTo(w * 0.53, h * 0.12, w * 0.62, h * 0.08);
    canvas.drawPath(stemPath, stemPaint);

    // Leaf
    final leafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.52, h * 0.08, w * 0.35, h * 0.22));
    final leafPath = Path()
      ..moveTo(w * 0.54, h * 0.22)
      ..quadraticBezierTo(w * 0.70, h * 0.08, w * 0.82, h * 0.18)
      ..quadraticBezierTo(w * 0.72, h * 0.30, w * 0.54, h * 0.22);
    canvas.drawPath(leafPath, leafPaint);

    // Apple Body (Juicy double lobes)
    final appleShader = const RadialGradient(
      center: Alignment(-0.25, -0.3),
      radius: 0.9,
      colors: [Color(0xFFFF5252), Color(0xFFD50000), Color(0xFF880E4F)],
    ).createShader(Rect.fromLTWH(w * 0.10, h * 0.22, w * 0.80, h * 0.68));
    final applePaint = Paint()..shader = appleShader;

    final path = Path()
      ..moveTo(w * 0.50, h * 0.34)
      ..cubicTo(w * 0.35, h * 0.22, w * 0.10, h * 0.32, w * 0.12, h * 0.60)
      ..cubicTo(w * 0.14, h * 0.82, w * 0.38, h * 0.88, w * 0.50, h * 0.82)
      ..cubicTo(w * 0.62, h * 0.88, w * 0.86, h * 0.82, w * 0.88, h * 0.60)
      ..cubicTo(w * 0.90, h * 0.32, w * 0.65, h * 0.22, w * 0.50, h * 0.34);
    canvas.drawPath(path, applePaint);

    // Gloss shine crescent
    final glossPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(w * 0.24, h * 0.35, w * 0.22, h * 0.12), glossPaint);

    // Cute Kawaii Face
    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.58), scale: w / 100);
  }

  // ===========================================================================
  // B: RAINBOW BUTTERFLY
  // ===========================================================================
  void _paintButterfly(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wings Upper Left & Right
    final wingGradient = const RadialGradient(
      colors: [Color(0xFFFF80AB), Color(0xFF9C27B0), Color(0xFF3F51B5)],
    );

    final leftTopWing = Path()
      ..moveTo(w * 0.48, h * 0.42)
      ..cubicTo(w * 0.25, h * 0.10, w * 0.05, h * 0.20, w * 0.08, h * 0.46)
      ..cubicTo(w * 0.10, h * 0.62, w * 0.35, h * 0.60, w * 0.48, h * 0.52);
    canvas.drawPath(
      leftTopWing,
      Paint()..shader = wingGradient.createShader(Rect.fromLTWH(0, 0, w * 0.5, h * 0.6)),
    );

    final rightTopWing = Path()
      ..moveTo(w * 0.52, h * 0.42)
      ..cubicTo(w * 0.75, h * 0.10, w * 0.95, h * 0.20, w * 0.92, h * 0.46)
      ..cubicTo(w * 0.90, h * 0.62, w * 0.65, h * 0.60, w * 0.52, h * 0.52);
    canvas.drawPath(
      rightTopWing,
      Paint()..shader = wingGradient.createShader(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.6)),
    );

    // Wings Lower
    final cyanWing = const LinearGradient(
      colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.50, w * 0.28, h * 0.30),
      Paint()..shader = cyanWing.createShader(Rect.fromLTWH(w * 0.18, h * 0.50, w * 0.28, h * 0.30)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.54, h * 0.50, w * 0.28, h * 0.30),
      Paint()..shader = cyanWing.createShader(Rect.fromLTWH(w * 0.54, h * 0.50, w * 0.28, h * 0.30)),
    );

    // Glowing Wing Spots
    final yellowPaint = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawCircle(Offset(w * 0.26, h * 0.34), w * 0.05, yellowPaint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.34), w * 0.05, yellowPaint);

    // Butterfly Body
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.44, h * 0.25, w * 0.12, h * 0.55));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.45, h * 0.30, w * 0.10, h * 0.50), const Radius.circular(12)),
      bodyPaint,
    );

    // Antennae
    final antPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = w * 0.03
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.48, h * 0.30)
        ..quadraticBezierTo(w * 0.40, h * 0.15, w * 0.35, h * 0.14),
      antPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.52, h * 0.30)
        ..quadraticBezierTo(w * 0.60, h * 0.15, w * 0.65, h * 0.14),
      antPaint,
    );
    canvas.drawCircle(Offset(w * 0.35, h * 0.14), w * 0.03, Paint()..color = const Color(0xFFFF4081));
    canvas.drawCircle(Offset(w * 0.65, h * 0.14), w * 0.03, Paint()..color = const Color(0xFFFF4081));

    // Kawaii Face on body
    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.40), scale: w / 160);
  }

  // ===========================================================================
  // C: CUTE GINGER CAT
  // ===========================================================================
  void _paintCat(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ears
    final earPaint = Paint()..color = const Color(0xFFFF9800);
    final earInner = Paint()..color = const Color(0xFFFF80AB);

    final leftEar = Path()
      ..moveTo(w * 0.22, h * 0.42)
      ..lineTo(w * 0.18, h * 0.18)
      ..lineTo(w * 0.42, h * 0.32)
      ..close();
    canvas.drawPath(leftEar, earPaint);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.24, h * 0.38)
        ..lineTo(w * 0.22, h * 0.24)
        ..lineTo(w * 0.38, h * 0.32)
        ..close(),
      earInner,
    );

    final rightEar = Path()
      ..moveTo(w * 0.78, h * 0.42)
      ..lineTo(w * 0.82, h * 0.18)
      ..lineTo(w * 0.58, h * 0.32)
      ..close();
    canvas.drawPath(rightEar, earPaint);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.76, h * 0.38)
        ..lineTo(w * 0.78, h * 0.24)
        ..lineTo(w * 0.62, h * 0.32)
        ..close(),
      earInner,
    );

    // Head
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.2),
        colors: [Color(0xFFFFB74D), Color(0xFFFF9800), Color(0xFFF57C00)],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.70, h * 0.60));
    canvas.drawCircle(Offset(w * 0.50, h * 0.55), w * 0.34, headPaint);

    // White Muzzle
    canvas.drawOval(
      Rect.fromLTWH(w * 0.32, h * 0.56, w * 0.36, h * 0.24),
      Paint()..color = Colors.white,
    );

    // Whiskers
    final whiskerPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = w * 0.02
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.16, h * 0.62), Offset(w * 0.32, h * 0.64), whiskerPaint);
    canvas.drawLine(Offset(w * 0.18, h * 0.70), Offset(w * 0.32, h * 0.68), whiskerPaint);
    canvas.drawLine(Offset(w * 0.84, h * 0.62), Offset(w * 0.68, h * 0.64), whiskerPaint);
    canvas.drawLine(Offset(w * 0.82, h * 0.70), Offset(w * 0.68, h * 0.68), whiskerPaint);

    // Kawaii Face
    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.55), scale: w / 90);
  }

  // ===========================================================================
  // D: HAPPY SPOTTED DOG
  // ===========================================================================
  void _paintDog(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Floppy Ears
    final earPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawOval(Rect.fromLTWH(w * 0.10, h * 0.32, w * 0.22, h * 0.40), earPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.68, h * 0.32, w * 0.22, h * 0.40), earPaint);

    // Head
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.2),
        colors: [Color(0xFFFFE082), Color(0xFFFFD54F), Color(0xFFFFB300)],
      ).createShader(Rect.fromLTWH(w * 0.18, h * 0.25, w * 0.64, h * 0.58));
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.30, headPaint);

    // White snout
    canvas.drawOval(
      Rect.fromLTWH(w * 0.34, h * 0.52, w * 0.32, h * 0.25),
      Paint()..color = Colors.white,
    );

    // Nose
    canvas.drawOval(
      Rect.fromLTWH(w * 0.43, h * 0.54, w * 0.14, h * 0.10),
      Paint()..color = const Color(0xFF212121),
    );

    // Tongue
    final tonguePaint = Paint()..color = const Color(0xFFFF5252);
    canvas.drawOval(Rect.fromLTWH(w * 0.46, h * 0.68, w * 0.08, h * 0.12), tonguePaint);

    // Eyes
    _drawEyes(canvas, center: Offset(w * 0.50, h * 0.46), scale: w / 90);
  }

  // ===========================================================================
  // E: BABY ELEPHANT
  // ===========================================================================
  void _paintElephant(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Big Flapping Ears
    final earPaint = Paint()..color = const Color(0xFF90CAF9);
    final earInner = Paint()..color = const Color(0xFFFF80AB).withOpacity(0.5);
    canvas.drawOval(Rect.fromLTWH(w * 0.05, h * 0.25, w * 0.32, h * 0.42), earPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.10, h * 0.30, w * 0.20, h * 0.30), earInner);

    canvas.drawOval(Rect.fromLTWH(w * 0.63, h * 0.25, w * 0.32, h * 0.42), earPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.70, h * 0.30, w * 0.20, h * 0.30), earInner);

    // Head
    final headPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFBBDEFB), Color(0xFF64B5F6), Color(0xFF1E88E5)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.56, h * 0.56));
    canvas.drawCircle(Offset(w * 0.50, h * 0.48), w * 0.26, headPaint);

    // Trunk
    final trunkPath = Path()
      ..moveTo(w * 0.44, h * 0.52)
      ..quadraticBezierTo(w * 0.42, h * 0.78, w * 0.54, h * 0.78)
      ..quadraticBezierTo(w * 0.62, h * 0.78, w * 0.60, h * 0.66)
      ..quadraticBezierTo(w * 0.54, h * 0.66, w * 0.50, h * 0.72)
      ..quadraticBezierTo(w * 0.48, h * 0.68, w * 0.54, h * 0.52)
      ..close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF42A5F5));

    // Cute Tusks
    canvas.drawOval(Rect.fromLTWH(w * 0.38, h * 0.60, w * 0.08, h * 0.14), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromLTWH(w * 0.54, h * 0.60, w * 0.08, h * 0.14), Paint()..color = Colors.white);

    // Kawaii Eyes & Blush
    _drawEyes(canvas, center: Offset(w * 0.50, h * 0.42), scale: w / 95);
  }

  // ===========================================================================
  // F: TROPICAL FISH
  // ===========================================================================
  void _paintFish(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tail Fin
    final tailPath = Path()
      ..moveTo(w * 0.35, h * 0.50)
      ..lineTo(w * 0.10, h * 0.25)
      ..quadraticBezierTo(w * 0.16, h * 0.50, w * 0.10, h * 0.75)
      ..close();
    canvas.drawPath(
      tailPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
        ).createShader(Rect.fromLTWH(0, 0, w * 0.4, h)),
    );

    // Fish Body (Oval)
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.2, -0.2),
        colors: [Color(0xFFFF9800), Color(0xFFFF5722), Color(0xFFD84315)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.25, w * 0.65, h * 0.50));
    canvas.drawOval(Rect.fromLTWH(w * 0.25, h * 0.28, w * 0.60, h * 0.44), bodyPaint);

    // White Clownfish Stripes
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06;
    canvas.drawArc(Rect.fromLTWH(w * 0.42, h * 0.28, w * 0.12, h * 0.44), -math.pi / 2, math.pi, false, stripePaint);

    // Floating Air Bubbles
    final bubblePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(w * 0.88, h * 0.30), w * 0.04, bubblePaint);
    canvas.drawCircle(Offset(w * 0.94, h * 0.20), w * 0.03, bubblePaint);

    // Eye
    canvas.drawCircle(Offset(w * 0.70, h * 0.44), w * 0.05, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.71, h * 0.44), w * 0.03, Paint()..color = Colors.black);
  }

  // ===========================================================================
  // G: TALL GIRAFFE
  // ===========================================================================
  void _paintGiraffe(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Neck
    final neckPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.40, h * 0.35, w * 0.20, h * 0.52), const Radius.circular(16)),
      neckPaint,
    );

    // Spots on neck
    final spotPaint = Paint()..color = const Color(0xFFA1887F);
    canvas.drawCircle(Offset(w * 0.48, h * 0.60), w * 0.045, spotPaint);
    canvas.drawCircle(Offset(w * 0.54, h * 0.74), w * 0.05, spotPaint);

    // Head
    canvas.drawOval(Rect.fromLTWH(w * 0.34, h * 0.20, w * 0.32, h * 0.28), neckPaint);

    // Ossicones (Horns)
    final hornPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.44, h * 0.22), Offset(w * 0.40, h * 0.12), hornPaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.22), Offset(w * 0.60, h * 0.12), hornPaint);
    canvas.drawCircle(Offset(w * 0.40, h * 0.12), w * 0.03, Paint()..color = const Color(0xFFD84315));
    canvas.drawCircle(Offset(w * 0.60, h * 0.12), w * 0.03, Paint()..color = const Color(0xFFD84315));

    // Snout
    canvas.drawOval(
      Rect.fromLTWH(w * 0.40, h * 0.34, w * 0.20, h * 0.12),
      Paint()..color = const Color(0xFFFFE082),
    );

    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.30), scale: w / 120);
  }

  // ===========================================================================
  // H: CHESTNUT HORSE / PONY
  // ===========================================================================
  void _paintHorse(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mane (Flowing Gold)
    final manePaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawOval(Rect.fromLTWH(w * 0.25, h * 0.20, w * 0.28, h * 0.48), manePaint);

    // Head
    final horsePaint = Paint()..color = const Color(0xFF8D6E63);
    final headPath = Path()
      ..moveTo(w * 0.40, h * 0.24)
      ..lineTo(w * 0.68, h * 0.38)
      ..lineTo(w * 0.64, h * 0.65)
      ..lineTo(w * 0.42, h * 0.72)
      ..lineTo(w * 0.32, h * 0.42)
      ..close();
    canvas.drawPath(headPath, horsePaint);

    // Ears
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.36, h * 0.24)
        ..lineTo(w * 0.34, h * 0.12)
        ..lineTo(w * 0.44, h * 0.20)
        ..close(),
      horsePaint,
    );

    // White Snout
    canvas.drawOval(Rect.fromLTWH(w * 0.52, h * 0.52, w * 0.16, h * 0.16), Paint()..color = const Color(0xFFFFE0B2));

    _drawEyes(canvas, center: Offset(w * 0.48, h * 0.38), scale: w / 110);
  }

  // ===========================================================================
  // I: DELICIOUS ICE CREAM CONE
  // ===========================================================================
  void _paintIceCream(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Waffle Cone
    final conePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.30, h * 0.48, w * 0.40, h * 0.46));
    final conePath = Path()
      ..moveTo(w * 0.30, h * 0.50)
      ..lineTo(w * 0.70, h * 0.50)
      ..lineTo(w * 0.50, h * 0.90)
      ..close();
    canvas.drawPath(conePath, conePaint);

    // Waffle Crosshatch Pattern
    final linePaint = Paint()
      ..color = const Color(0xFFBF360C).withOpacity(0.4)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(w * 0.36, h * 0.54), Offset(w * 0.58, h * 0.74), linePaint);
    canvas.drawLine(Offset(w * 0.64, h * 0.54), Offset(w * 0.42, h * 0.74), linePaint);

    // Vanilla Scoop
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.45),
      w * 0.22,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0xFFFFF9C4), Color(0xFFFFE082)],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.45), radius: w * 0.22)),
    );

    // Strawberry Scoop
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.30),
      w * 0.18,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFF80AB), Color(0xFFFF4081), Color(0xFFC2185B)],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.30), radius: w * 0.18)),
    );

    // Cherry on Top!
    canvas.drawCircle(Offset(w * 0.50, h * 0.14), w * 0.06, Paint()..color = const Color(0xFFD50000));
    canvas.drawCircle(Offset(w * 0.48, h * 0.12), w * 0.02, Paint()..color = Colors.white);
  }

  // ===========================================================================
  // J: GLOWING JELLYFISH
  // ===========================================================================
  void _paintJellyfish(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Jellyfish Bell Dome
    final domePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.4),
        colors: [Color(0xFFE1BEE7), Color(0xFFBA68C8), Color(0xFF7B1FA2)],
      ).createShader(Rect.fromLTWH(w * 0.20, h * 0.20, w * 0.60, h * 0.45));
    final domePath = Path()
      ..moveTo(w * 0.20, h * 0.52)
      ..cubicTo(w * 0.20, h * 0.20, w * 0.80, h * 0.20, w * 0.80, h * 0.52)
      ..quadraticBezierTo(w * 0.50, h * 0.58, w * 0.20, h * 0.52)
      ..close();
    canvas.drawPath(domePath, domePaint);

    // Tentacles
    final tentaclePaint = Paint()
      ..color = const Color(0xFFCE93D8)
      ..strokeWidth = w * 0.035
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final x = w * (0.32 + (i * 0.12));
      final path = Path()
        ..moveTo(x, h * 0.54)
        ..quadraticBezierTo(x + (i.isEven ? 8 : -8), h * 0.70, x, h * 0.85);
      canvas.drawPath(path, tentaclePaint);
    }

    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.40), scale: w / 110);
  }

  // ===========================================================================
  // K: KANGAROO
  // ===========================================================================
  void _paintKangaroo(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final rooPaint = Paint()..color = const Color(0xFFD7CCC8);
    // Ears
    canvas.drawOval(Rect.fromLTWH(w * 0.35, h * 0.10, w * 0.09, h * 0.20), rooPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.56, h * 0.10, w * 0.09, h * 0.20), rooPaint);

    // Body
    canvas.drawOval(Rect.fromLTWH(w * 0.28, h * 0.35, w * 0.44, h * 0.48), rooPaint);
    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.30), w * 0.18, rooPaint);

    // Pouch
    canvas.drawArc(
      Rect.fromLTWH(w * 0.36, h * 0.52, w * 0.28, h * 0.24),
      0,
      math.pi,
      true,
      Paint()..color = const Color(0xFFBCAAA4),
    );

    // Baby Joey peeking out
    canvas.drawCircle(Offset(w * 0.50, h * 0.56), w * 0.07, Paint()..color = const Color(0xFFA1887F));
    canvas.drawCircle(Offset(w * 0.48, h * 0.55), w * 0.015, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(w * 0.52, h * 0.55), w * 0.015, Paint()..color = Colors.black);

    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.30), scale: w / 110);
  }

  // ===========================================================================
  // L: REGAL LION KING
  // ===========================================================================
  void _paintLion(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Golden Sunflower Mane
    final manePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFB300), Color(0xFFFF8F00), Color(0xFFE65100)],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.52), radius: w * 0.40));
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.38, manePaint);

    // Face Circle
    final facePaint = Paint()..color = const Color(0xFFFFE082);
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.24, facePaint);

    // Gold Crown on Top
    final crownPath = Path()
      ..moveTo(w * 0.38, h * 0.24)
      ..lineTo(w * 0.42, h * 0.14)
      ..lineTo(w * 0.50, h * 0.20)
      ..lineTo(w * 0.58, h * 0.14)
      ..lineTo(w * 0.62, h * 0.24)
      ..close();
    canvas.drawPath(crownPath, Paint()..color = const Color(0xFFFFD700));

    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.52), scale: w / 95);
  }

  // ===========================================================================
  // M: CHEEKY MONKEY
  // ===========================================================================
  void _paintMonkey(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Big Round Ears
    final earPaint = Paint()..color = const Color(0xFF795548);
    final earInner = Paint()..color = const Color(0xFFFFCCBC);
    canvas.drawCircle(Offset(w * 0.20, h * 0.48), w * 0.14, earPaint);
    canvas.drawCircle(Offset(w * 0.20, h * 0.48), w * 0.08, earInner);
    canvas.drawCircle(Offset(w * 0.80, h * 0.48), w * 0.14, earPaint);
    canvas.drawCircle(Offset(w * 0.80, h * 0.48), w * 0.08, earInner);

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.48), w * 0.28, earPaint);

    // Heart-shaped Tan Face Muzzle
    final muzzlePaint = Paint()..color = const Color(0xFFFFCCBC);
    canvas.drawOval(Rect.fromLTWH(w * 0.32, h * 0.48, w * 0.36, h * 0.26), muzzlePaint);

    // Ripe Yellow Banana
    final bananaPath = Path()
      ..moveTo(w * 0.35, h * 0.78)
      ..quadraticBezierTo(w * 0.55, h * 0.90, w * 0.70, h * 0.74)
      ..quadraticBezierTo(w * 0.52, h * 0.82, w * 0.35, h * 0.78)
      ..close();
    canvas.drawPath(bananaPath, Paint()..color = const Color(0xFFFFEB3B));

    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.46), scale: w / 95);
  }

  // ===========================================================================
  // N: COZY BIRD NEST
  // ===========================================================================
  void _paintNest(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Turquoise Speckled Eggs
    final eggPaint = Paint()..color = const Color(0xFF80DEEA);
    canvas.drawOval(Rect.fromLTWH(w * 0.30, h * 0.28, w * 0.16, h * 0.26), eggPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.44, h * 0.24, w * 0.16, h * 0.26), eggPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.56, h * 0.30, w * 0.16, h * 0.26), eggPaint);

    // Woven Twig Nest
    final nestPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8D6E63), Color(0xFF5D4037), Color(0xFF3E2723)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.42, w * 0.70, h * 0.42));
    final nestPath = Path()
      ..moveTo(w * 0.15, h * 0.48)
      ..quadraticBezierTo(w * 0.50, h * 0.54, w * 0.85, h * 0.48)
      ..cubicTo(w * 0.88, h * 0.82, w * 0.12, h * 0.82, w * 0.15, h * 0.48)
      ..close();
    canvas.drawPath(nestPath, nestPaint);

    // Green sprout leaves
    final leafPaint = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawOval(Rect.fromLTWH(w * 0.72, h * 0.42, w * 0.14, h * 0.08), leafPaint);
  }

  // ===========================================================================
  // O: WISE BARN OWL
  // ===========================================================================
  void _paintOwl(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFBCAAA4), Color(0xFF8D6E63), Color(0xFF4E342E)],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.56, h * 0.65));
    canvas.drawOval(Rect.fromLTWH(w * 0.25, h * 0.22, w * 0.50, h * 0.62), bodyPaint);

    // Huge Golden Owl Eyes
    canvas.drawCircle(Offset(w * 0.40, h * 0.42), w * 0.13, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.60, h * 0.42), w * 0.13, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.40, h * 0.42), w * 0.09, Paint()..color = const Color(0xFFFFB300));
    canvas.drawCircle(Offset(w * 0.60, h * 0.42), w * 0.09, Paint()..color = const Color(0xFFFFB300));
    canvas.drawCircle(Offset(w * 0.40, h * 0.42), w * 0.05, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(w * 0.60, h * 0.42), w * 0.05, Paint()..color = Colors.black);

    // Orange Beak
    final beakPath = Path()
      ..moveTo(w * 0.46, h * 0.48)
      ..lineTo(w * 0.54, h * 0.48)
      ..lineTo(w * 0.50, h * 0.58)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = const Color(0xFFFF9800));
  }

  // ===========================================================================
  // P: FLUFFY PANDA
  // ===========================================================================
  void _paintPanda(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Black Ears
    final blackPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(Offset(w * 0.25, h * 0.28), w * 0.12, blackPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.28), w * 0.12, blackPaint);

    // White Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.32, Paint()..color = Colors.white);

    // Slanted Black Eye Patches
    canvas.save();
    canvas.translate(w * 0.38, h * 0.46);
    canvas.rotate(-math.pi / 8);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: w * 0.22), blackPaint);
    canvas.drawCircle(const Offset(2, -2), w * 0.035, Paint()..color = Colors.white);
    canvas.restore();

    canvas.save();
    canvas.translate(w * 0.62, h * 0.46);
    canvas.rotate(math.pi / 8);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: w * 0.22), blackPaint);
    canvas.drawCircle(const Offset(-2, -2), w * 0.035, Paint()..color = Colors.white);
    canvas.restore();

    // Black Nose & Smile
    canvas.drawOval(Rect.fromLTWH(w * 0.45, h * 0.56, w * 0.10, h * 0.06), blackPaint);

    // Green Bamboo Stalk
    final bambooPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.68, h * 0.85), Offset(w * 0.85, h * 0.55), bambooPaint);
  }

  // ===========================================================================
  // Q: FAIRYTALE QUEEN
  // ===========================================================================
  void _paintQueen(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Royal Purple Mantle
    final mantlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2), Color(0xFF4A148C)],
      ).createShader(Rect.fromLTWH(w * 0.20, h * 0.45, w * 0.60, h * 0.45));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.25, h * 0.55, w * 0.50, h * 0.35), const Radius.circular(24)),
      mantlePaint,
    );

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.48), w * 0.22, Paint()..color = const Color(0xFFFFE0B2));

    // Sparkling Golden Crown with Jewels
    final crownPath = Path()
      ..moveTo(w * 0.30, h * 0.32)
      ..lineTo(w * 0.36, h * 0.14)
      ..lineTo(w * 0.50, h * 0.22)
      ..lineTo(w * 0.64, h * 0.14)
      ..lineTo(w * 0.70, h * 0.32)
      ..close();
    canvas.drawPath(crownPath, Paint()..color = const Color(0xFFFFD700));

    // Rubies and Emeralds
    canvas.drawCircle(Offset(w * 0.36, h * 0.14), w * 0.03, Paint()..color = const Color(0xFFFF1744));
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.03, Paint()..color = const Color(0xFF00E676));
    canvas.drawCircle(Offset(w * 0.64, h * 0.14), w * 0.03, Paint()..color = const Color(0xFFFF1744));

    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.48), scale: w / 100);
  }

  // ===========================================================================
  // R: FLUFFY WHITE BUNNY
  // ===========================================================================
  void _paintRabbit(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Upright Long Ears
    final earPaint = Paint()..color = Colors.white;
    final earInner = Paint()..color = const Color(0xFFFF80AB);
    canvas.drawOval(Rect.fromLTWH(w * 0.30, h * 0.08, w * 0.14, h * 0.42), earPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.33, h * 0.12, w * 0.08, h * 0.32), earInner);

    canvas.drawOval(Rect.fromLTWH(w * 0.56, h * 0.08, w * 0.14, h * 0.42), earPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.59, h * 0.12, w * 0.08, h * 0.32), earInner);

    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.56), w * 0.28, earPaint);

    // Crisp Orange Carrot
    final carrotPath = Path()
      ..moveTo(w * 0.60, h * 0.68)
      ..lineTo(w * 0.82, h * 0.58)
      ..lineTo(w * 0.86, h * 0.85)
      ..close();
    canvas.drawPath(carrotPath, Paint()..color = const Color(0xFFFF9800));

    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.56), scale: w / 95);
  }

  // ===========================================================================
  // S: RADIANT SUN WITH SUNGLASSES
  // ===========================================================================
  void _paintSun(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Radiant Sun Rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final r1 = w * 0.34;
      final r2 = w * 0.46;
      canvas.drawLine(
        Offset(w * 0.50 + r1 * math.cos(angle), h * 0.50 + r1 * math.sin(angle)),
        Offset(w * 0.50 + r2 * math.cos(angle), h * 0.50 + r2 * math.sin(angle)),
        rayPaint,
      );
    }

    // Sun Face
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFEE58), Color(0xFFFFCA28), Color(0xFFFFA000)],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.50), radius: w * 0.30));
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.30, sunPaint);

    // Cool Sunglasses
    final glassPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.42, w * 0.20, h * 0.14), const Radius.circular(8)),
      glassPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.52, h * 0.42, w * 0.20, h * 0.14), const Radius.circular(8)),
      glassPaint,
    );
    canvas.drawLine(Offset(w * 0.48, h * 0.48), Offset(w * 0.52, h * 0.48), glassPaint..strokeWidth = 3);

    // Cheerful Smile
    final smilePaint = Paint()
      ..color = const Color(0xFFBF360C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromLTWH(w * 0.42, h * 0.58, w * 0.16, h * 0.12), 0, math.pi, false, smilePaint);
  }

  // ===========================================================================
  // T: BENGAL TIGER CUB
  // ===========================================================================
  void _paintTiger(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ears
    final earPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawCircle(Offset(w * 0.25, h * 0.28), w * 0.10, earPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.28), w * 0.10, earPaint);

    // Head
    final tigerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFFF9800), Color(0xFFE65100)],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.52), radius: w * 0.32));
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.30, tigerPaint);

    // Stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    // Forehead Stripes
    canvas.drawLine(Offset(w * 0.50, h * 0.26), Offset(w * 0.50, h * 0.36), stripePaint);
    canvas.drawLine(Offset(w * 0.44, h * 0.30), Offset(w * 0.46, h * 0.38), stripePaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.30), Offset(w * 0.54, h * 0.38), stripePaint);

    // Cheek Stripes
    canvas.drawLine(Offset(w * 0.22, h * 0.52), Offset(w * 0.30, h * 0.54), stripePaint);
    canvas.drawLine(Offset(w * 0.78, h * 0.52), Offset(w * 0.70, h * 0.54), stripePaint);

    // White Muzzle
    canvas.drawOval(Rect.fromLTWH(w * 0.35, h * 0.54, w * 0.30, h * 0.18), Paint()..color = Colors.white);

    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.52), scale: w / 95);
  }

  // ===========================================================================
  // U: RAINBOW UMBRELLA
  // ===========================================================================
  void _paintUmbrella(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rainbow Canopy Slices
    final colors = [
      const Color(0xFFFF5252),
      const Color(0xFFFFEB3B),
      const Color(0xFF69F0AE),
      const Color(0xFF40C4FF),
    ];

    for (int i = 0; i < colors.length; i++) {
      final sweep = math.pi / colors.length;
      final start = math.pi + (i * sweep);
      final slicePath = Path()
        ..moveTo(w * 0.50, h * 0.45)
        ..arcTo(Rect.fromLTWH(w * 0.12, h * 0.15, w * 0.76, h * 0.60), start, sweep, false)
        ..close();
      canvas.drawPath(slicePath, Paint()..color = colors[i]);
    }

    // Wooden Handle & Shaft
    final handlePaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = w * 0.04
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final shaft = Path()
      ..moveTo(w * 0.50, h * 0.45)
      ..lineTo(w * 0.50, h * 0.78)
      ..quadraticBezierTo(w * 0.50, h * 0.88, w * 0.42, h * 0.88);
    canvas.drawPath(shaft, handlePaint);

    // Cute Raindrops
    final dropPaint = Paint()..color = Colors.lightBlueAccent;
    canvas.drawOval(Rect.fromLTWH(w * 0.16, h * 0.68, w * 0.05, h * 0.10), dropPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.78, h * 0.68, w * 0.05, h * 0.10), dropPaint);
  }

  // ===========================================================================
  // V: CLASSICAL VIOLIN
  // ===========================================================================
  void _paintViolin(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wooden Body
    final violinPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFBCAAA4), Color(0xFF5D4037)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.50, h * 0.55));

    final body = Path()
      ..moveTo(w * 0.50, h * 0.35)
      ..cubicTo(w * 0.28, h * 0.35, w * 0.28, h * 0.55, w * 0.36, h * 0.60)
      ..cubicTo(w * 0.24, h * 0.68, w * 0.28, h * 0.88, w * 0.50, h * 0.88)
      ..cubicTo(w * 0.72, h * 0.88, w * 0.76, h * 0.68, w * 0.64, h * 0.60)
      ..cubicTo(w * 0.72, h * 0.55, w * 0.72, h * 0.35, w * 0.50, h * 0.35)
      ..close();
    canvas.drawPath(body, violinPaint);

    // Fingerboard & Neck
    canvas.drawRect(Rect.fromLTWH(w * 0.46, h * 0.12, w * 0.08, h * 0.35), Paint()..color = const Color(0xFF212121));

    // Musical Notes floating
    final notePaint = Paint()
      ..color = const Color(0xFFBA68C8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.80, h * 0.25), w * 0.04, notePaint);
    canvas.drawCircle(Offset(w * 0.20, h * 0.25), w * 0.03, notePaint);
  }

  // ===========================================================================
  // W: JUICY WATERMELON SLICE
  // ===========================================================================
  void _paintWatermelon(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Green Striped Rind
    final rindPaint = Paint()..color = const Color(0xFF2E7D32);
    final rindPath = Path()
      ..moveTo(w * 0.10, h * 0.42)
      ..quadraticBezierTo(w * 0.50, h * 0.88, w * 0.90, h * 0.42)
      ..lineTo(w * 0.85, h * 0.38)
      ..quadraticBezierTo(w * 0.50, h * 0.82, w * 0.15, h * 0.38)
      ..close();
    canvas.drawPath(rindPath, rindPaint);

    // Juicy Red Flesh
    final redPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.3),
        colors: [Color(0xFFFF5252), Color(0xFFFF1744), Color(0xFFC62828)],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.38, w * 0.70, h * 0.42));
    final redPath = Path()
      ..moveTo(w * 0.16, h * 0.38)
      ..lineTo(w * 0.84, h * 0.38)
      ..quadraticBezierTo(w * 0.50, h * 0.80, w * 0.16, h * 0.38)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Black Seeds
    final seedPaint = Paint()..color = const Color(0xFF212121);
    final seedOffsets = [
      Offset(w * 0.35, h * 0.46),
      Offset(w * 0.50, h * 0.44),
      Offset(w * 0.65, h * 0.46),
      Offset(w * 0.42, h * 0.56),
      Offset(w * 0.58, h * 0.56),
    ];
    for (final seed in seedOffsets) {
      canvas.drawOval(Rect.fromCenter(center: seed, width: w * 0.035, height: w * 0.05), seedPaint);
    }
  }

  // ===========================================================================
  // X: RAINBOW XYLOPHONE
  // ===========================================================================
  void _paintXylophone(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wooden Frame
    final framePaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.15, h * 0.35), Offset(w * 0.28, h * 0.75), framePaint);
    canvas.drawLine(Offset(w * 0.85, h * 0.35), Offset(w * 0.72, h * 0.75), framePaint);

    // Colored Bars
    final barColors = [
      const Color(0xFFFF5252),
      const Color(0xFFFF9800),
      const Color(0xFFFFEB3B),
      const Color(0xFF4CAF50),
      const Color(0xFF00E5FF),
      const Color(0xFF7C4DFF),
    ];

    for (int i = 0; i < barColors.length; i++) {
      final y = h * (0.35 + (i * 0.075));
      final barWidth = w * (0.68 - (i * 0.06));
      final left = (w - barWidth) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left, y, barWidth, h * 0.055), const Radius.circular(6)),
        Paint()..color = barColors[i],
      );
    }

    // Mallet
    canvas.drawLine(
      Offset(w * 0.75, h * 0.25),
      Offset(w * 0.60, h * 0.65),
      Paint()
        ..color = const Color(0xFFD7CCC8)
        ..strokeWidth = 3,
    );
    canvas.drawCircle(Offset(w * 0.75, h * 0.25), w * 0.05, Paint()..color = const Color(0xFFFF4081));
  }

  // ===========================================================================
  // Y: OCEAN YACHT / SAILBOAT
  // ===========================================================================
  void _paintYacht(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ocean Waves
    final wavePaint = Paint()
      ..color = const Color(0xFF29B6F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final wave = Path()
      ..moveTo(w * 0.10, h * 0.82)
      ..quadraticBezierTo(w * 0.30, h * 0.76, w * 0.50, h * 0.82)
      ..quadraticBezierTo(w * 0.70, h * 0.88, w * 0.90, h * 0.82);
    canvas.drawPath(wave, wavePaint);

    // Hull (Boat Body)
    final hullPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
      ).createShader(Rect.fromLTWH(w * 0.18, h * 0.65, w * 0.64, h * 0.18));
    final hull = Path()
      ..moveTo(w * 0.18, h * 0.68)
      ..lineTo(w * 0.82, h * 0.68)
      ..lineTo(w * 0.70, h * 0.82)
      ..lineTo(w * 0.30, h * 0.82)
      ..close();
    canvas.drawPath(hull, hullPaint);

    // Mast
    canvas.drawLine(
      Offset(w * 0.52, h * 0.20),
      Offset(w * 0.52, h * 0.68),
      Paint()
        ..color = const Color(0xFF424242)
        ..strokeWidth = 4,
    );

    // White Main Sail
    final sailPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFECEFF1)],
      ).createShader(Rect.fromLTWH(w * 0.24, h * 0.22, w * 0.28, h * 0.44));
    final sail = Path()
      ..moveTo(w * 0.50, h * 0.22)
      ..lineTo(w * 0.24, h * 0.64)
      ..lineTo(w * 0.50, h * 0.64)
      ..close();
    canvas.drawPath(sail, sailPaint);

    // Colorful Jib Sail
    final jib = Path()
      ..moveTo(w * 0.54, h * 0.26)
      ..lineTo(w * 0.76, h * 0.64)
      ..lineTo(w * 0.54, h * 0.64)
      ..close();
    canvas.drawPath(jib, Paint()..color = const Color(0xFFFFCA28));
  }

  // ===========================================================================
  // Z: STRIPED ZEBRA
  // ===========================================================================
  void _paintZebra(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Zebra Ears
    final earPaint = Paint()..color = Colors.white;
    canvas.drawOval(Rect.fromLTWH(w * 0.32, h * 0.12, w * 0.12, h * 0.30), earPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.56, h * 0.12, w * 0.12, h * 0.30), earPaint);

    // Spiky Black Mane
    final blackPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawRect(Rect.fromLTWH(w * 0.46, h * 0.12, w * 0.08, h * 0.28), blackPaint);

    // White Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.28, earPaint);

    // Bold Zebra Stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.24, h * 0.45), Offset(w * 0.36, h * 0.48), stripePaint);
    canvas.drawLine(Offset(w * 0.26, h * 0.56), Offset(w * 0.36, h * 0.56), stripePaint);
    canvas.drawLine(Offset(w * 0.76, h * 0.45), Offset(w * 0.64, h * 0.48), stripePaint);
    canvas.drawLine(Offset(w * 0.74, h * 0.56), Offset(w * 0.64, h * 0.56), stripePaint);

    // Grey Snout
    canvas.drawOval(Rect.fromLTWH(w * 0.40, h * 0.58, w * 0.20, h * 0.16), Paint()..color = const Color(0xFF757575));

    _drawEyes(canvas, center: Offset(w * 0.50, h * 0.46), scale: w / 95);
  }

  // ===========================================================================
  // HINDI EXTRAS (Mango, Kite, Lotus)
  // ===========================================================================
  void _paintMango(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mangoPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFEE58), Color(0xFFFFB300), Color(0xFFE65100)],
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.6));
    canvas.drawOval(Rect.fromLTWH(w * 0.25, h * 0.28, w * 0.50, h * 0.58), mangoPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.24), w * 0.08, Paint()..color = const Color(0xFF4CAF50));
    _drawKawaiiFace(canvas, center: Offset(w * 0.50, h * 0.52), scale: w / 100);
  }

  void _paintKite(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final kitePath = Path()
      ..moveTo(w * 0.50, h * 0.15)
      ..lineTo(w * 0.85, h * 0.50)
      ..lineTo(w * 0.50, h * 0.78)
      ..lineTo(w * 0.15, h * 0.50)
      ..close();
    canvas.drawPath(kitePath, Paint()..color = const Color(0xFFFF4081));
    canvas.drawLine(Offset(w * 0.50, h * 0.15), Offset(w * 0.50, h * 0.78), Paint()..color = Colors.white..strokeWidth = 3);
  }

  void _paintLotus(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final petalPaint = Paint()..color = const Color(0xFFF48FB1);
    canvas.drawOval(Rect.fromLTWH(w * 0.35, h * 0.30, w * 0.30, h * 0.45), petalPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.20, h * 0.42, w * 0.28, h * 0.35), petalPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.52, h * 0.42, w * 0.28, h * 0.35), petalPaint);
  }

  // ===========================================================================
  // SHARED KAWAII FACES
  // ===========================================================================
  void _drawKawaiiFace(Canvas canvas, {required Offset center, required double scale}) {
    final eyePaint = Paint()..color = const Color(0xFF212121);
    final eyeRadius = 4.0 * scale;
    final eyeSpacing = 16.0 * scale;

    // Eyes
    canvas.drawCircle(Offset(center.dx - eyeSpacing, center.dy), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(center.dx + eyeSpacing, center.dy), eyeRadius, eyePaint);

    // Sparkles in eyes
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - eyeSpacing - (eyeRadius * 0.3), center.dy - (eyeRadius * 0.3)), eyeRadius * 0.4, shinePaint);
    canvas.drawCircle(Offset(center.dx + eyeSpacing - (eyeRadius * 0.3), center.dy - (eyeRadius * 0.3)), eyeRadius * 0.4, shinePaint);

    // Rosy Blush
    final blushPaint = Paint()..color = const Color(0xFFFF4081).withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - eyeSpacing * 1.3, center.dy + (6 * scale)), width: 8 * scale, height: 5 * scale),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + eyeSpacing * 1.3, center.dy + (6 * scale)), width: 8 * scale, height: 5 * scale),
      blushPaint,
    );

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy + (4 * scale)), width: 10 * scale, height: 8 * scale),
      0,
      math.pi,
      false,
      smilePaint,
    );
  }

  void _drawEyes(Canvas canvas, {required Offset center, required double scale}) {
    final eyePaint = Paint()..color = const Color(0xFF212121);
    final eyeRadius = 4.0 * scale;
    final eyeSpacing = 16.0 * scale;

    canvas.drawCircle(Offset(center.dx - eyeSpacing, center.dy), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(center.dx + eyeSpacing, center.dy), eyeRadius, eyePaint);

    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - eyeSpacing - (eyeRadius * 0.3), center.dy - (eyeRadius * 0.3)), eyeRadius * 0.4, shinePaint);
    canvas.drawCircle(Offset(center.dx + eyeSpacing - (eyeRadius * 0.3), center.dy - (eyeRadius * 0.3)), eyeRadius * 0.4, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _AlphabetGraphicPainter oldDelegate) => oldDelegate.glyph != glyph;
}

/// Interactive Alphabet Graphic Card with bounce animation and tap speech
class AlphabetGraphicCard extends StatefulWidget {
  final String letter;
  final String word;
  final double size;
  final bool isHindi;
  final VoidCallback? onTap;

  const AlphabetGraphicCard({
    super.key,
    required this.letter,
    required this.word,
    this.size = 130,
    this.isHindi = false,
    this.onTap,
  });

  @override
  State<AlphabetGraphicCard> createState() => _AlphabetGraphicCardState();
}

class _AlphabetGraphicCardState extends State<AlphabetGraphicCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    ProceduralSfxEngine().playBoing();
    ProceduralSfxEngine().speakWord(widget.word, isHindi: widget.isHindi);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.size,
          height: widget.size * 1.18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFF3E5F5)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFBA68C8), width: 3.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B1FA2).withOpacity(0.25),
                offset: const Offset(0, 6),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlphabetGraphicArtwork(
                letter: widget.letter,
                size: widget.size * 0.72,
              ),
              const SizedBox(height: 2),
              Text(
                widget.word,
                style: GoogleFonts.bubblegumSans(
                  fontSize: widget.size * 0.14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF4A148C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
