import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Supported 3D Cartoon Pixar Icon Types
enum PixarIconType {
  doggy,
  apple,
  letter,
  shapes,
  memory,
  art,
  star,
  microphone,
  timeDial,
  speaker,
  mosaic,
  alphaGrid,
  wordBuilder,
  spellingPuzzle,
  animalQuiz,
}

/// A premium 3D Cartoon Pixar-Style Icon Widget with specular highlights,
/// multi-layered radial depth, rim lighting, and lively kawaii expressions.
class Pixar3DIcon extends StatelessWidget {
  final PixarIconType type;
  final double size;
  final bool animate;

  const Pixar3DIcon({
    super.key,
    required this.type,
    this.size = 56,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(size, size),
          painter: _PixarIconPainter(type: type),
        ),
      ),
    );
  }
}

class _PixarIconPainter extends CustomPainter {
  final PixarIconType type;

  _PixarIconPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case PixarIconType.doggy:
        _paintDoggy(canvas, size);
        break;
      case PixarIconType.apple:
        _paintApple(canvas, size);
        break;
      case PixarIconType.letter:
        _paintLetter(canvas, size);
        break;
      case PixarIconType.shapes:
        _paintShapes(canvas, size);
        break;
      case PixarIconType.memory:
        _paintMemory(canvas, size);
        break;
      case PixarIconType.art:
        _paintArt(canvas, size);
        break;
      case PixarIconType.star:
        _paintStar(canvas, size);
        break;
      case PixarIconType.microphone:
        _paintMicrophone(canvas, size);
        break;
      case PixarIconType.timeDial:
        _paintTimeDial(canvas, size);
        break;
      case PixarIconType.speaker:
        _paintSpeaker(canvas, size);
        break;
      case PixarIconType.mosaic:
        _paintMosaic(canvas, size);
        break;
      case PixarIconType.alphaGrid:
        _paintAlphaGrid(canvas, size);
        break;
      case PixarIconType.wordBuilder:
        _paintWordBuilder(canvas, size);
        break;
      case PixarIconType.spellingPuzzle:
        _paintSpellingPuzzle(canvas, size);
        break;
      case PixarIconType.animalQuiz:
        _paintAnimalQuiz(canvas, size);
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // 1. PIXAR DOGGY: Warm caramel puppy with floppy 3D ears, glossy eyes & tongue
  // ---------------------------------------------------------------------------
  void _paintDoggy(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.54);

    // Drop Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, h * 0.88), width: w * 0.72, height: h * 0.18),
      shadowPaint,
    );

    // Floppy Left Ear
    final leftEarPath = Path()
      ..moveTo(w * 0.28, h * 0.35)
      ..cubicTo(w * 0.05, h * 0.38, w * 0.04, h * 0.75, w * 0.22, h * 0.78)
      ..cubicTo(w * 0.32, h * 0.78, w * 0.36, h * 0.58, w * 0.30, h * 0.40)
      ..close();
    final earPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8D5B28), Color(0xFF5D3A1A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(leftEarPath, earPaint);

    // Floppy Right Ear
    final rightEarPath = Path()
      ..moveTo(w * 0.72, h * 0.35)
      ..cubicTo(w * 0.95, h * 0.38, w * 0.96, h * 0.75, w * 0.78, h * 0.78)
      ..cubicTo(w * 0.68, h * 0.78, w * 0.64, h * 0.58, w * 0.70, h * 0.40)
      ..close();
    canvas.drawPath(rightEarPath, earPaint);

    // Head Sphere with 3D Radial Gradient
    final headRect = Rect.fromCenter(center: center, width: w * 0.68, height: h * 0.64);
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 0.85,
        colors: [Color(0xFFFFE0B2), Color(0xFFFFB74D), Color(0xFFF57C00)],
        stops: [0.0, 0.65, 1.0],
      ).createShader(headRect);
    canvas.drawOval(headRect, headPaint);

    // Head Specular Top Crescent
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.0)],
      ).createShader(headRect);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - h * 0.16), width: w * 0.45, height: h * 0.22),
      shinePaint,
    );

    // Cute Eye Patch (Right Eye)
    final patchPaint = Paint()
      ..color = const Color(0xFF8D5B28).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.62, h * 0.48), width: w * 0.22, height: h * 0.22),
      patchPaint,
    );

    // Left Eye & Right Eye (Big Pixar Glossy Eyes)
    _drawPixarEye(canvas, Offset(w * 0.40, h * 0.49), size, r: w * 0.082);
    _drawPixarEye(canvas, Offset(w * 0.60, h * 0.49), size, r: w * 0.082);

    // White Muzzle
    final muzzleRect = Rect.fromCenter(center: Offset(center.dx, h * 0.64), width: w * 0.36, height: h * 0.26);
    final muzzlePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.2),
        colors: [Color(0xFFFFFFFF), Color(0xFFFFF3E0)],
      ).createShader(muzzleRect);
    canvas.drawOval(muzzleRect, muzzlePaint);

    // Shiny Black Nose
    final noseCenter = Offset(center.dx, h * 0.58);
    final nosePaint = Paint()..color = const Color(0xFF212121);
    canvas.drawOval(
      Rect.fromCenter(center: noseCenter, width: w * 0.12, height: h * 0.08),
      nosePaint,
    );
    // Nose gleam
    canvas.drawCircle(Offset(noseCenter.dx - w * 0.025, noseCenter.dy - h * 0.015), w * 0.02, Paint()..color = Colors.white);

    // Smiling Mouth with Pink Tongue
    final mouthPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, w * 0.035)
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(center.dx - w * 0.08, h * 0.64)
      ..quadraticBezierTo(center.dx - w * 0.04, h * 0.69, center.dx, h * 0.66)
      ..quadraticBezierTo(center.dx + w * 0.04, h * 0.69, center.dx + w * 0.08, h * 0.64);
    canvas.drawPath(mouthPath, mouthPaint);

    // Bouncy Pink Tongue
    final tonguePath = Path()
      ..moveTo(center.dx - w * 0.04, h * 0.66)
      ..quadraticBezierTo(center.dx, h * 0.77, center.dx + w * 0.04, h * 0.66)
      ..close();
    canvas.drawPath(tonguePath, Paint()..color = const Color(0xFFFF5252));
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, h * 0.67)
        ..lineTo(center.dx, h * 0.73),
      Paint()
        ..color = const Color(0xFFD32F2F)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. PIXAR APPLE: Juicy 3D Red Apple with Stem, Dewdrop Leaf & Kawaii Face
  // ---------------------------------------------------------------------------
  void _paintApple(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.56);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, h * 0.90), width: w * 0.65, height: h * 0.16),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Curved Woody Stem
    final stemPath = Path()
      ..moveTo(w * 0.50, h * 0.32)
      ..cubicTo(w * 0.52, h * 0.16, w * 0.60, h * 0.12, w * 0.65, h * 0.10);
    canvas.drawPath(
      stemPath,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(3.0, w * 0.07)
        ..strokeCap = StrokeCap.round,
    );

    // Emerald Green Leaf with 3D Gloss
    final leafPath = Path()
      ..moveTo(w * 0.53, h * 0.22)
      ..quadraticBezierTo(w * 0.76, h * 0.14, w * 0.82, h * 0.26)
      ..quadraticBezierTo(w * 0.68, h * 0.32, w * 0.53, h * 0.22)
      ..close();
    final leafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(w * 0.5, h * 0.1, w * 0.35, h * 0.25));
    canvas.drawPath(leafPath, leafPaint);

    // Leaf specular dewdrop
    canvas.drawCircle(Offset(w * 0.72, h * 0.22), w * 0.022, Paint()..color = Colors.white.withOpacity(0.85));

    // Apple Body (Juicy voluptuous heart/apple curves)
    final applePath = Path();
    applePath.moveTo(w * 0.50, h * 0.34);
    applePath.cubicTo(w * 0.30, h * 0.24, w * 0.12, h * 0.44, w * 0.16, h * 0.68);
    applePath.cubicTo(w * 0.20, h * 0.88, w * 0.38, h * 0.90, w * 0.50, h * 0.84);
    applePath.cubicTo(w * 0.62, h * 0.90, w * 0.80, h * 0.88, w * 0.84, h * 0.68);
    applePath.cubicTo(w * 0.88, h * 0.44, w * 0.70, h * 0.24, w * 0.50, h * 0.34);
    applePath.close();

    final applePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.30),
        radius: 0.85,
        colors: [Color(0xFFFF5252), Color(0xFFE53935), Color(0xFFB71C1C)],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.25, w * 0.8, h * 0.7));
    canvas.drawPath(applePath, applePaint);

    // Apple Specular Curved Shine (Top-Left)
    final shinePath = Path()
      ..moveTo(w * 0.26, h * 0.40)
      ..quadraticBezierTo(w * 0.34, h * 0.34, w * 0.44, h * 0.38)
      ..quadraticBezierTo(w * 0.34, h * 0.42, w * 0.26, h * 0.52)
      ..close();
    canvas.drawPath(
      shinePath,
      Paint()
        ..color = Colors.white.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Kawaii Smiling Apple Face
    _drawPixarEye(canvas, Offset(w * 0.39, h * 0.58), size, r: w * 0.065);
    _drawPixarEye(canvas, Offset(w * 0.61, h * 0.58), size, r: w * 0.065);

    // Rosy Pink Cheeks
    final blushPaint = Paint()..color = const Color(0xFFFF8DA1).withOpacity(0.65);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.31, h * 0.64), width: w * 0.12, height: h * 0.06), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.69, h * 0.64), width: w * 0.12, height: h * 0.06), blushPaint);

    // Happy Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A1212)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, w * 0.035)
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..moveTo(w * 0.44, h * 0.66)
      ..quadraticBezierTo(w * 0.50, h * 0.73, w * 0.56, h * 0.66);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  // ---------------------------------------------------------------------------
  // 3. PIXAR LETTER: 3D Candy Alphabet Cube with Bevels & Sparkling "B"
  // ---------------------------------------------------------------------------
  void _paintLetter(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.88), width: w * 0.75, height: h * 0.20),
        const Radius.circular(16),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 3D Candy Block Base (Isometric rounded perspective)
    final blockRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.78, height: h * 0.74),
      Radius.circular(w * 0.22),
    );

    // Vibrant Purple/Magenta Candy Gradient
    final blockPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFBA68C8), Color(0xFF8E24AA), Color(0xFF6A1B9A)],
      ).createShader(blockRRect.outerRect);
    canvas.drawRRect(blockRRect, blockPaint);

    // Inner Specular Bevel Border
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.50), width: w * 0.70, height: h * 0.66),
      Radius.circular(w * 0.18),
    );
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.0)],
      ).createShader(innerRRect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(innerRRect, borderPaint);

    // Glossy Bubble Letter "B" (or ABC)
    _draw3DGlyphB(canvas, Offset(w * 0.5, h * 0.51), size);

    // Floating Star Sparkles
    _drawSparkle(canvas, Offset(w * 0.22, h * 0.25), w * 0.10, const Color(0xFFFFEB3B));
    _drawSparkle(canvas, Offset(w * 0.78, h * 0.32), w * 0.08, const Color(0xFFFF80AB));
  }

  void _draw3DGlyphB(Canvas canvas, Offset center, Size size) {
    final w = size.width;
    final h = size.height;

    final glyphShadow = TextPainter(
      text: TextSpan(
        text: 'B',
        style: TextStyle(
          fontSize: size.width * 0.46,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF4A148C),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    glyphShadow.paint(canvas, Offset(center.dx - glyphShadow.width / 2 + 2, center.dy - glyphShadow.height / 2 + 3));

    final glyphPaint = TextPainter(
      text: TextSpan(
        text: 'B',
        style: TextStyle(
          fontSize: size.width * 0.46,
          fontWeight: FontWeight.w900,
          foreground: Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFF9800)],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    glyphPaint.paint(canvas, Offset(center.dx - glyphPaint.width / 2, center.dy - glyphPaint.height / 2));
  }

  // ---------------------------------------------------------------------------
  // 4. PIXAR LIVING SHAPES: Gemstone Pyramid, Sphere & Star with Kawaii Faces
  // ---------------------------------------------------------------------------
  void _paintShapes(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.88), width: w * 0.78, height: h * 0.18),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Blue Bouncy Sphere (Left)
    final sphereCenter = Offset(w * 0.34, h * 0.60);
    final sphereR = w * 0.22;
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.35),
        colors: const [Color(0xFF80D8FF), Color(0xFF00B0FF), Color(0xFF0277BD)],
      ).createShader(Rect.fromCircle(center: sphereCenter, radius: sphereR));
    canvas.drawCircle(sphereCenter, sphereR, spherePaint);
    // Sphere shine
    canvas.drawCircle(Offset(sphereCenter.dx - sphereR * 0.35, sphereCenter.dy - sphereR * 0.35), sphereR * 0.22, Paint()..color = Colors.white.withOpacity(0.7));
    // Sphere kawaii eyes
    _drawKawaiiDots(canvas, Offset(sphereCenter.dx, sphereCenter.dy + sphereR * 0.05), sphereR * 0.4);

    // Glossy Red/Orange Living Triangle (Right)
    final triCenter = Offset(w * 0.66, h * 0.56);
    final triPath = Path()
      ..moveTo(triCenter.dx, triCenter.dy - h * 0.28)
      ..lineTo(triCenter.dx + w * 0.26, triCenter.dy + h * 0.20)
      ..lineTo(triCenter.dx - w * 0.26, triCenter.dy + h * 0.20)
      ..close();
    final triPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8A80), Color(0xFFFF5252), Color(0xFFD50000)],
      ).createShader(Rect.fromLTWH(w * 0.4, h * 0.2, w * 0.5, h * 0.5));
    canvas.drawPath(triPath, triPaint);
    // Triangle gloss
    canvas.drawCircle(Offset(triCenter.dx, triCenter.dy - h * 0.12), w * 0.045, Paint()..color = Colors.white.withOpacity(0.65));
    _drawKawaiiDots(canvas, Offset(triCenter.dx, triCenter.dy + h * 0.06), w * 0.15);

    // Golden Living Star (Top Center Accent)
    _drawSparkle(canvas, Offset(w * 0.50, h * 0.22), w * 0.14, const Color(0xFFFFD700));
  }

  // ---------------------------------------------------------------------------
  // 5. PIXAR MEMORY TILE: 3D Sunburst Medal on Gold/Purple Tile
  // ---------------------------------------------------------------------------
  void _paintMemory(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, h * 0.88), width: w * 0.72, height: h * 0.18),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Golden Sunburst Medal Body
    final sunR = w * 0.35;
    final sunPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        colors: const [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFFA000)],
      ).createShader(Rect.fromCircle(center: center, radius: sunR));

    // Radiating 8 Sun Rays
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final rayP = Path()
        ..moveTo(center.dx + (sunR * 0.6) * math.cos(angle - 0.2), center.dy + (sunR * 0.6) * math.sin(angle - 0.2))
        ..lineTo(center.dx + (sunR * 1.15) * math.cos(angle), center.dy + (sunR * 1.15) * math.sin(angle))
        ..lineTo(center.dx + (sunR * 0.6) * math.cos(angle + 0.2), center.dy + (sunR * 0.6) * math.sin(angle + 0.2))
        ..close();
      canvas.drawPath(rayP, sunPaint);
    }

    // Center Core Sphere
    canvas.drawCircle(center, sunR * 0.75, sunPaint);

    // Specular Rim
    canvas.drawCircle(
      center,
      sunR * 0.75,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: sunR))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Kawaii Face on the Sun
    _drawPixarEye(canvas, Offset(center.dx - w * 0.10, center.dy - h * 0.02), size, r: w * 0.055);
    _drawPixarEye(canvas, Offset(center.dx + w * 0.10, center.dy - h * 0.02), size, r: w * 0.055);

    // Rosy Cheeks
    canvas.drawCircle(Offset(center.dx - w * 0.14, center.dy + h * 0.07), w * 0.04, Paint()..color = const Color(0xFFFF7043).withOpacity(0.6));
    canvas.drawCircle(Offset(center.dx + w * 0.14, center.dy + h * 0.07), w * 0.04, Paint()..color = const Color(0xFFFF7043).withOpacity(0.6));

    // Curved Smile
    final mouthPath = Path()
      ..moveTo(center.dx - w * 0.07, center.dy + h * 0.07)
      ..quadraticBezierTo(center.dx, center.dy + h * 0.14, center.dx + w * 0.07, center.dy + h * 0.07);
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  // ---------------------------------------------------------------------------
  // 6. PIXAR ART: Wooden Artist Palette with 3D Gel Paint Dollops & Wet Brush
  // ---------------------------------------------------------------------------
  void _paintArt(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Palette Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.86), width: w * 0.74, height: h * 0.18),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Wooden Palette Kidney Shape
    final palettePath = Path();
    palettePath.moveTo(w * 0.20, h * 0.35);
    palettePath.cubicTo(w * 0.25, h * 0.15, w * 0.75, h * 0.18, w * 0.82, h * 0.40);
    palettePath.cubicTo(w * 0.88, h * 0.65, w * 0.70, h * 0.82, w * 0.45, h * 0.80);
    palettePath.cubicTo(w * 0.28, h * 0.78, w * 0.15, h * 0.60, w * 0.20, h * 0.35);
    palettePath.close();

    final woodPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE0B2), Color(0xFFFFB74D), Color(0xFFC89658)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(palettePath, woodPaint);

    // Thumb Hole
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.70, h * 0.62), width: w * 0.14, height: h * 0.18),
      Paint()..color = const Color(0xFF795548).withOpacity(0.4),
    );

    // 4 Shiny 3D Gel Paint Drops
    _drawPaintDollop(canvas, Offset(w * 0.32, h * 0.32), w * 0.085, const Color(0xFFFF5252));
    _drawPaintDollop(canvas, Offset(w * 0.52, h * 0.26), w * 0.085, const Color(0xFFFFD600));
    _drawPaintDollop(canvas, Offset(w * 0.70, h * 0.35), w * 0.085, const Color(0xFF00E676));
    _drawPaintDollop(canvas, Offset(w * 0.36, h * 0.58), w * 0.085, const Color(0xFF00B0FF));

    // Paintbrush Crossing Palette
    final brushPath = Path()
      ..moveTo(w * 0.15, h * 0.82)
      ..lineTo(w * 0.82, h * 0.18);
    canvas.drawPath(
      brushPath,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(3.5, w * 0.075)
        ..strokeCap = StrokeCap.round,
    );
    // Silver ferrule
    canvas.drawLine(
      Offset(w * 0.70, h * 0.30),
      Offset(w * 0.76, h * 0.24),
      Paint()
        ..color = Colors.white
        ..strokeWidth = math.max(4.0, w * 0.085),
    );
    // Colorful brush tip
    canvas.drawCircle(Offset(w * 0.82, h * 0.18), w * 0.065, Paint()..color = const Color(0xFFBA68C8));
  }

  void _drawPaintDollop(Canvas canvas, Offset pos, double r, Color color) {
    final dollopPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        colors: [color.withOpacity(0.9), color, Colors.black.withOpacity(0.35)],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, dollopPaint);
    // White specular highlight
    canvas.drawCircle(Offset(pos.dx - r * 0.35, pos.dy - r * 0.35), r * 0.25, Paint()..color = Colors.white.withOpacity(0.85));
  }

  // ---------------------------------------------------------------------------
  // 7. PIXAR STAR: Mario/Pixar metallic golden star with cute eyes
  // ---------------------------------------------------------------------------
  void _paintStar(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    // Star Path
    final starPath = Path();
    const points = 5;
    final rOuter = w * 0.44;
    final rInner = w * 0.20;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points - (math.pi / 2);
      final r = (i.isEven) ? rOuter : rInner;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    // 3D Golden Gradient
    final starPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.3),
        colors: [Color(0xFFFFFDE7), Color(0xFFFFEE58), Color(0xFFFFA000)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(starPath, starPaint);

    // Specular Rim
    canvas.drawPath(
      starPath,
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Cute Oval Eyes
    _drawPixarEye(canvas, Offset(w * 0.43, h * 0.50), size, r: w * 0.055);
    _drawPixarEye(canvas, Offset(w * 0.57, h * 0.50), size, r: w * 0.055);
  }

  // ---------------------------------------------------------------------------
  // 8. PIXAR MICROPHONE: 3D Studio Mic with silver mesh & audio ripples
  // ---------------------------------------------------------------------------
  void _paintMicrophone(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.48);

    // Audio Ripple Waves
    final wavePaint = Paint()
      ..color = const Color(0xFF64FFDA).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(center, w * 0.44, wavePaint);
    canvas.drawCircle(center, w * 0.36, wavePaint..color = const Color(0xFF00E676).withOpacity(0.6));

    // Handle
    final handleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, h * 0.68), width: w * 0.16, height: h * 0.36),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      handleRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00E676), Color(0xFF009688)],
        ).createShader(handleRect.outerRect),
    );

    // Silver Grille Mesh Ball
    final micR = w * 0.24;
    final micRect = Rect.fromCircle(center: Offset(center.dx, h * 0.38), radius: micR);
    final micPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.35),
        colors: [Color(0xFFFFFFFF), Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
      ).createShader(micRect);
    canvas.drawCircle(Offset(center.dx, h * 0.38), micR, micPaint);

    // Grille Specular Shine
    canvas.drawCircle(
      Offset(center.dx - micR * 0.35, h * 0.38 - micR * 0.35),
      micR * 0.28,
      Paint()..color = Colors.white.withOpacity(0.85),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. PIXAR TIME DIAL: 3D Sun & Moon Clock with embossed dial
  // ---------------------------------------------------------------------------
  void _paintTimeDial(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    // Dial Outer Rim
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFECB3), Color(0xFFFFB300), Color(0xFFFF6F00)],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.46));
    canvas.drawCircle(center, w * 0.46, rimPaint);

    // Inner White Dial Face
    canvas.drawCircle(center, w * 0.36, Paint()..color = Colors.white);

    // Half Sun / Half Moon
    final sunPath = Path()
      ..addArc(Rect.fromCircle(center: center, radius: w * 0.32), -math.pi / 2, math.pi)
      ..close();
    canvas.drawPath(
      sunPath,
      Paint()..shader = const LinearGradient(colors: [Color(0xFFFFEB3B), Color(0xFFFF9800)]).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Moon Crescent
    final moonPaint = Paint()..color = const Color(0xFF5C6BC0);
    final moonPath = Path()
      ..addArc(Rect.fromCircle(center: center, radius: w * 0.32), math.pi / 2, math.pi)
      ..close();
    canvas.drawPath(moonPath, moonPaint);

    // Center Gold Pivot
    canvas.drawCircle(center, w * 0.08, Paint()..color = const Color(0xFFFFA000));
    canvas.drawCircle(center, w * 0.03, Paint()..color = Colors.white);
  }

  // ---------------------------------------------------------------------------
  // 10. PIXAR SPEAKER: 3D Candy Megaphone with floating musical notes
  // ---------------------------------------------------------------------------
  void _paintSpeaker(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Megaphone Cone
    final conePath = Path()
      ..moveTo(w * 0.25, h * 0.40)
      ..lineTo(w * 0.65, h * 0.24)
      ..lineTo(w * 0.65, h * 0.76)
      ..lineTo(w * 0.25, h * 0.60)
      ..close();

    canvas.drawPath(
      conePath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Sound Waves
    final wavePaint = Paint()
      ..color = const Color(0xFF64B5F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final arc1 = Path()..addArc(Rect.fromCenter(center: Offset(w * 0.65, h * 0.5), width: w * 0.35, height: h * 0.45), -math.pi / 3, (2 * math.pi) / 3);
    final arc2 = Path()..addArc(Rect.fromCenter(center: Offset(w * 0.65, h * 0.5), width: w * 0.55, height: h * 0.65), -math.pi / 3, (2 * math.pi) / 3);
    canvas.drawPath(arc1, wavePaint);
    canvas.drawPath(arc2, wavePaint);
  }

  // ---------------------------------------------------------------------------
  // 11. PIXAR MOSAIC: 3D Cobblestone Number Pebble Circle
  // ---------------------------------------------------------------------------
  void _paintMosaic(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);
    final r = w * 0.44;

    // Drop shadow
    canvas.drawCircle(
      Offset(center.dx, center.dy + h * 0.06),
      r,
      Paint()
        ..color = Colors.black.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Dark grout circular rim base
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF2C3440), Color(0xFF141923)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, rimPaint);

    // Inner cobblestone pebble pattern
    final pebbleCount = 8;
    for (int i = 0; i < pebbleCount; i++) {
      final angle = (i * 2 * math.pi) / pebbleCount;
      final pDist = r * 0.58;
      final px = center.dx + pDist * math.cos(angle);
      final py = center.dy + pDist * math.sin(angle);
      final pR = r * 0.32;

      final pebblePath = Path();
      pebblePath.addOval(Rect.fromCenter(center: Offset(px, py), width: pR * 1.8, height: pR * 1.5));

      final pebblePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF3ECE1), Color(0xFFDDD2C0)],
        ).createShader(Rect.fromCircle(center: Offset(px, py), radius: pR));
      canvas.drawPath(pebblePath, pebblePaint);

      // Pebble border grout
      canvas.drawPath(
        pebblePath,
        Paint()
          ..color = const Color(0xFF1B2230)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // Center focal pebble
    final centerR = r * 0.46;
    final centerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFFF7ED), Color(0xFFE8DECF)],
      ).createShader(Rect.fromCircle(center: center, radius: centerR));
    canvas.drawCircle(center, centerR, centerPaint);

    // Center grout border
    canvas.drawCircle(
      center,
      centerR,
      Paint()
        ..color = const Color(0xFF1B2230)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // Bold Coral-Red "1" in the center (just like the reference photo!)
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '1',
        style: TextStyle(
          color: Color(0xFFFF5252),
          fontSize: 16,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );

    // Specular shine arc on top rim
    final shinePath = Path()
      ..addArc(Rect.fromCircle(center: center, radius: r * 0.92), -math.pi * 0.85, math.pi * 0.7);
    canvas.drawPath(
      shinePath,
      Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // Tiny golden star sparkle
    _drawSparkle(canvas, Offset(w * 0.78, h * 0.22), 4, const Color(0xFFFFD54F));
  }

  // ---------------------------------------------------------------------------
  // 12. PIXAR ALPHA GRID: 2x2 Candy Alphabet Tiles (A, B, C, D) with Specular Bevels
  // ---------------------------------------------------------------------------
  void _paintAlphaGrid(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    // Drop Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 4), width: w * 0.86, height: h * 0.86),
        const Radius.circular(16),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Base Grid Tablet Plate
    final baseRect = Rect.fromCenter(center: center, width: w * 0.86, height: h * 0.86);
    final baseRRect = RRect.fromRectAndRadius(baseRect, const Radius.circular(16));
    canvas.drawRRect(
      baseRRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F51B5), Color(0xFF1A237E)],
        ).createShader(baseRect),
    );
    canvas.drawRRect(
      baseRRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 4 Colorful 2x2 Letter Tiles
    final tileMargin = w * 0.04;
    final tileSize = (w * 0.74 - tileMargin) / 2;
    final startX = center.dx - w * 0.37;
    final startY = center.dy - h * 0.37;

    final tiles = [
      {'letter': 'A', 'x': startX, 'y': startY, 'c1': const Color(0xFF00E5FF), 'c2': const Color(0xFF0091EA)},
      {'letter': 'B', 'x': startX + tileSize + tileMargin, 'y': startY, 'c1': const Color(0xFFFFD54F), 'c2': const Color(0xFFFF8F00)},
      {'letter': 'C', 'x': startX, 'y': startY + tileSize + tileMargin, 'c1': const Color(0xFFFF4081), 'c2': const Color(0xFFC2185B)},
      {'letter': 'D', 'x': startX + tileSize + tileMargin, 'y': startY + tileSize + tileMargin, 'c1': const Color(0xFF69F0AE), 'c2': const Color(0xFF00C853)},
    ];

    for (final t in tiles) {
      final tx = t['x'] as double;
      final ty = t['y'] as double;
      final tileRect = Rect.fromLTWH(tx, ty, tileSize, tileSize);
      final tileRRect = RRect.fromRectAndRadius(tileRect, const Radius.circular(8));

      // Tile Background with 3D gradient
      canvas.drawRRect(
        tileRRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [t['c1'] as Color, t['c2'] as Color],
          ).createShader(tileRect),
      );

      // White border
      canvas.drawRRect(
        tileRRect,
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Specular gloss pill
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tx + 2, ty + 2, tileSize - 4, tileSize * 0.4),
          const Radius.circular(6),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withOpacity(0.65), Colors.white.withOpacity(0.0)],
          ).createShader(tileRect),
      );

      // Letter typography
      final tp = TextPainter(
        text: TextSpan(
          text: t['letter'] as String,
          style: TextStyle(
            fontSize: tileSize * 0.60,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(1, 1),
                blurRadius: 1,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(tx + (tileSize - tp.width) / 2, ty + (tileSize - tp.height) / 2),
      );
    }

    _drawSparkle(canvas, Offset(w * 0.88, h * 0.12), 4, const Color(0xFFFFEB3B));
  }


  // ---------------------------------------------------------------------------
  // 14. PIXAR WORD BUILDER: 3D Interlocking Colorful Toy Letter Blocks ("C - A - T")
  // ---------------------------------------------------------------------------
  void _paintWordBuilder(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop Shadows
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.88), width: w * 0.85, height: h * 0.16),
      Paint()
        ..color = Colors.black.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // 3 Interlocking Blocks: C (Left red), A (Center gold, elevated), T (Right blue)
    final blockWidth = w * 0.28;
    final blockHeight = h * 0.38;

    final blocks = [
      {'letter': 'C', 'x': w * 0.08, 'y': h * 0.44, 'c1': const Color(0xFFFF5252), 'c2': const Color(0xFFC62828)},
      {'letter': 'T', 'x': w * 0.64, 'y': h * 0.44, 'c1': const Color(0xFF29B6F6), 'c2': const Color(0xFF0277BD)},
      {'letter': 'A', 'x': w * 0.36, 'y': h * 0.24, 'c1': const Color(0xFFFFCA28), 'c2': const Color(0xFFF57F17)}, // Hero center block
    ];

    for (final b in blocks) {
      final bx = b['x'] as double;
      final by = b['y'] as double;
      final rect = Rect.fromLTWH(bx, by, blockWidth, blockHeight);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

      // Block Front Face
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [b['c1'] as Color, b['c2'] as Color],
          ).createShader(rect),
      );
      // White Bevel Border
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = Colors.white.withOpacity(0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // Top Highlight Bevel
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx + 2, by + 2, blockWidth - 4, blockHeight * 0.36),
          const Radius.circular(6),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.0)],
          ).createShader(rect),
      );

      // Letter Print
      final tp = TextPainter(
        text: TextSpan(
          text: b['letter'] as String,
          style: TextStyle(
            fontSize: blockWidth * 0.65,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(1, 2),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(bx + (blockWidth - tp.width) / 2, by + (blockHeight - tp.height) / 2));
    }

    _drawSparkle(canvas, Offset(w * 0.85, h * 0.18), 4, const Color(0xFFFFD54F));
  }

  // ---------------------------------------------------------------------------
  // 15. PIXAR SPELLING PUZZLE: 3D Storybook with Jigsaw Piece & Magic Wand
  // ---------------------------------------------------------------------------
  void _paintSpellingPuzzle(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    // Book Drop Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, h * 0.88), width: w * 0.82, height: h * 0.16),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Storybook Cover Base
    final bookRect = Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: w * 0.82, height: h * 0.72);
    final bookRRect = RRect.fromRectAndRadius(bookRect, const Radius.circular(12));
    canvas.drawRRect(
      bookRRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
        ).createShader(bookRect),
    );
    canvas.drawRRect(
      bookRRect,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Inner Cream Page
    final pageRect = Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: w * 0.70, height: h * 0.58);
    final pageRRect = RRect.fromRectAndRadius(pageRect, const Radius.circular(8));
    canvas.drawRRect(
      pageRRect,
      Paint()..color = const Color(0xFFFFFDE7),
    );

    // Jigsaw Puzzle Piece Shape inside the page
    final pw = w * 0.36;
    final ph = h * 0.36;
    final px = center.dx - pw * 0.60;
    final py = center.dy - ph * 0.40;

    final puzzlePath = Path()
      ..moveTo(px, py)
      ..lineTo(px + pw * 0.35, py)
      ..cubicTo(px + pw * 0.35, py - ph * 0.2, px + pw * 0.65, py - ph * 0.2, px + pw * 0.65, py)
      ..lineTo(px + pw, py)
      ..lineTo(px + pw, py + ph * 0.35)
      ..cubicTo(px + pw + pw * 0.2, py + ph * 0.35, px + pw + pw * 0.2, py + ph * 0.65, px + pw, py + ph * 0.65)
      ..lineTo(px + pw, py + ph)
      ..lineTo(px, py + ph)
      ..close();

    canvas.drawPath(
      puzzlePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFFAB47BC), Color(0xFF6A1B9A)],
        ).createShader(Rect.fromLTWH(px, py, pw, ph)),
    );
    canvas.drawPath(
      puzzlePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Star Wand Tipped into the puzzle piece
    final wandPath = Path()
      ..moveTo(center.dx + w * 0.12, center.dy + h * 0.22)
      ..lineTo(center.dx + w * 0.36, center.dy - h * 0.18);
    canvas.drawPath(
      wandPath,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    _drawSparkle(canvas, Offset(center.dx + w * 0.36, center.dy - h * 0.18), 7, const Color(0xFFFFEB3B));
    _drawSparkle(canvas, Offset(center.dx - w * 0.20, center.dy - h * 0.22), 4, const Color(0xFF00E5FF));
  }

  // ---------------------------------------------------------------------------
  // 16. PIXAR ANIMAL QUIZ: Cute Safari Explorer Lion Cub with Detective Badge & Paw
  // ---------------------------------------------------------------------------
  void _paintAnimalQuiz(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.52);

    // Drop shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, h * 0.88), width: w * 0.75, height: h * 0.16),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 1. Lion Mane (Soft Scalloped Petals)
    final maneRadius = w * 0.36;
    final maneRect = Rect.fromCircle(center: center, radius: maneRadius);
    canvas.drawCircle(
      center,
      maneRadius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFB300), Color(0xFFE65100)],
        ).createShader(maneRect),
    );

    // 2. Lion Face (Golden Honey)
    final faceRadius = w * 0.26;
    final faceRect = Rect.fromCircle(center: center, radius: faceRadius);
    canvas.drawCircle(
      center,
      faceRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.3),
          radius: 0.8,
          colors: [Color(0xFFFFF9C4), Color(0xFFFFCA28), Color(0xFFFFA000)],
        ).createShader(faceRect),
    );
    canvas.drawCircle(
      center,
      faceRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 3. Cute Round Ears with Pink Inner
    final earOffsetY = center.dy - faceRadius * 0.75;
    canvas.drawCircle(Offset(center.dx - faceRadius * 0.8, earOffsetY), faceRadius * 0.35, Paint()..color = const Color(0xFFFFA000));
    canvas.drawCircle(Offset(center.dx - faceRadius * 0.8, earOffsetY), faceRadius * 0.20, Paint()..color = const Color(0xFFFF80AB));
    canvas.drawCircle(Offset(center.dx + faceRadius * 0.8, earOffsetY), faceRadius * 0.35, Paint()..color = const Color(0xFFFFA000));
    canvas.drawCircle(Offset(center.dx + faceRadius * 0.8, earOffsetY), faceRadius * 0.20, Paint()..color = const Color(0xFFFF80AB));

    // 4. Muzzle & Whiskers
    final muzzleRect = Rect.fromCenter(center: Offset(center.dx, center.dy + faceRadius * 0.28), width: faceRadius * 0.9, height: faceRadius * 0.65);
    canvas.drawOval(muzzleRect, Paint()..color = const Color(0xFFFFFDE7));
    // Cute brown nose
    final nosePath = Path()
      ..moveTo(center.dx - 4, center.dy + faceRadius * 0.12)
      ..lineTo(center.dx + 4, center.dy + faceRadius * 0.12)
      ..lineTo(center.dx, center.dy + faceRadius * 0.24)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFF4E342E));

    // 5. Pixar Big Catchlight Eyes
    _drawPixarEye(canvas, Offset(center.dx - faceRadius * 0.40, center.dy - faceRadius * 0.10), size, r: 4.5);
    _drawPixarEye(canvas, Offset(center.dx + faceRadius * 0.40, center.dy - faceRadius * 0.10), size, r: 4.5);

    // 6. Rosy Blushing Cheeks
    canvas.drawCircle(Offset(center.dx - faceRadius * 0.55, center.dy + faceRadius * 0.20), 4, Paint()..color = const Color(0xFFFF8A80).withOpacity(0.55));
    canvas.drawCircle(Offset(center.dx + faceRadius * 0.55, center.dy + faceRadius * 0.20), 4, Paint()..color = const Color(0xFFFF8A80).withOpacity(0.55));

    // 7. Detective Magnifying Glass / Quiz Badge floating in top right with "?"
    final badgeCenter = Offset(w * 0.80, h * 0.24);
    final badgeRadius = w * 0.15;
    canvas.drawCircle(
      badgeCenter,
      badgeRadius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
        ).createShader(Rect.fromCircle(center: badgeCenter, radius: badgeRadius)),
    );
    canvas.drawCircle(
      badgeCenter,
      badgeRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    final qp = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    qp.paint(canvas, Offset(badgeCenter.dx - qp.width / 2, badgeCenter.dy - qp.height / 2));
  }

  // ---------------------------------------------------------------------------
  // HELPER UTILITIES: Pixar Eyes, Dots & Sparkles
  // ---------------------------------------------------------------------------
  void _drawPixarEye(Canvas canvas, Offset center, Size size, {required double r}) {
    // Dark Black/Brown Iris
    final eyePaint = Paint()..color = const Color(0xFF1E272E);
    canvas.drawOval(Rect.fromCenter(center: center, width: r * 1.5, height: r * 1.9), eyePaint);

    // Primary Specular Catchlight (Upper Left)
    canvas.drawCircle(
      Offset(center.dx - r * 0.25, center.dy - r * 0.38),
      r * 0.42,
      Paint()..color = Colors.white,
    );

    // Secondary Specular Twinkle (Lower Right)
    canvas.drawCircle(
      Offset(center.dx + r * 0.30, center.dy + r * 0.38),
      r * 0.20,
      Paint()..color = Colors.white,
    );
  }

  void _drawKawaiiDots(Canvas canvas, Offset center, double span) {
    canvas.drawCircle(Offset(center.dx - span * 0.5, center.dy), span * 0.22, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(Offset(center.dx + span * 0.5, center.dy), span * 0.22, Paint()..color = const Color(0xFF212121));
  }

  void _drawSparkle(Canvas canvas, Offset center, double r, Color color) {
    final sparklePath = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + r, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + r)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - r, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - r)
      ..close();
    canvas.drawPath(sparklePath, Paint()..color = color);
    canvas.drawCircle(center, r * 0.3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PixarIconPainter oldDelegate) => oldDelegate.type != type;
}
