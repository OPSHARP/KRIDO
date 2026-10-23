import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a premium, realistic Pixar 3D cartoon animal portrait with
/// multi-layered radial studio lighting, glossy dual catchlights, specular
/// highlights, expressive facial features, and dimensional depth.
class Pixar3DAnimalArt extends StatelessWidget {
  final String animalId;
  final double size;
  final bool isAnimated;

  const Pixar3DAnimalArt({
    super.key,
    required this.animalId,
    this.size = 110,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(size, size),
          painter: _PixarAnimalPainter(animalId: animalId.toLowerCase().trim()),
        ),
      ),
    );
  }
}

class _PixarAnimalPainter extends CustomPainter {
  final String animalId;

  _PixarAnimalPainter({required this.animalId});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // 0. Soft drop shadow under the character
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.90),
        width: size.width * 0.70,
        height: size.height * 0.16,
      ),
      shadowPaint,
    );

    switch (animalId) {
      case 'lion':
        _paintLion(canvas, size, center, radius);
        break;
      case 'elephant':
        _paintElephant(canvas, size, center, radius);
        break;
      case 'panda':
        _paintPanda(canvas, size, center, radius);
        break;
      case 'dog':
      case 'puppy':
        _paintDog(canvas, size, center, radius);
        break;
      case 'cat':
      case 'kitten':
        _paintCat(canvas, size, center, radius);
        break;
      case 'cow':
        _paintCow(canvas, size, center, radius);
        break;
      case 'duck':
        _paintDuck(canvas, size, center, radius);
        break;
      case 'frog':
        _paintFrog(canvas, size, center, radius);
        break;
      case 'penguin':
        _paintPenguin(canvas, size, center, radius);
        break;
      case 'rabbit':
      case 'bunny':
        _paintRabbit(canvas, size, center, radius);
        break;
      case 'bear':
      case 'teddy':
        _paintBear(canvas, size, center, radius);
        break;
      case 'dolphin':
        _paintDolphin(canvas, size, center, radius);
        break;
      case 'giraffe':
        _paintGiraffe(canvas, size, center, radius);
        break;
      case 'monkey':
        _paintMonkey(canvas, size, center, radius);
        break;
      case 'tiger':
        _paintTiger(canvas, size, center, radius);
        break;
      case 'sheep':
        _paintSheep(canvas, size, center, radius);
        break;
      default:
        _paintDefaultAnimal(canvas, size, center, radius);
        break;
    }
  }

  // ===========================================================================
  // SHARED PIXAR 3D RENDERING HELPERS
  // ===========================================================================

  /// Renders signature Pixar 3D eyes with deep pupils & dual catchlights
  void _drawPixarEyes(Canvas canvas, Offset left, Offset right, double eyeR, {Color irisColor = const Color(0xFF2E1C0C)}) {
    for (final eyeCenter in [left, right]) {
      // 1. Sclera (White base with soft shading)
      final scleraPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          radius: 0.8,
          colors: const [Colors.white, Color(0xFFE8ECEF)],
        ).createShader(Rect.fromCircle(center: eyeCenter, radius: eyeR));
      canvas.drawCircle(eyeCenter, eyeR, scleraPaint);

      // 2. Iris
      final irisR = eyeR * 0.72;
      final irisPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.2),
          radius: 0.75,
          colors: [irisColor, Colors.black],
        ).createShader(Rect.fromCircle(center: eyeCenter, radius: irisR));
      canvas.drawCircle(eyeCenter, irisR, irisPaint);

      // 3. Specular dual gleams (Top-left big gleam, bottom-right micro sparkle)
      final gleamPaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(eyeCenter.dx - eyeR * 0.24, eyeCenter.dy - eyeR * 0.28),
        eyeR * 0.30,
        gleamPaint,
      );
      canvas.drawCircle(
        Offset(eyeCenter.dx + eyeR * 0.26, eyeCenter.dy + eyeR * 0.24),
        eyeR * 0.14,
        gleamPaint,
      );
    }
  }

  /// Rosy blush cheeks
  void _drawBlush(Canvas canvas, Offset left, Offset right, double r) {
    final blushPaint = Paint()
      ..color = const Color(0xFFFF6B81).withOpacity(0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(left, r, blushPaint);
    canvas.drawCircle(right, r, blushPaint);
  }

  /// Cute smiling mouth arc
  void _drawSmile(Canvas canvas, Offset mouthCenter, double width, {Color color = const Color(0xFF372617)}) {
    final mouthPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, width * 0.16)
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(mouthCenter.dx - width / 2, mouthCenter.dy)
      ..quadraticBezierTo(mouthCenter.dx, mouthCenter.dy + width * 0.55, mouthCenter.dx + width / 2, mouthCenter.dy);
    canvas.drawPath(path, mouthPaint);
  }

  // ===========================================================================
  // 1. LION (Leo Lion with volumetric mane and golden crown)
  // ===========================================================================
  void _paintLion(Canvas canvas, Size size, Offset center, double r) {
    // 1. Mane: 10 overlapping volumetric spherical puffs
    const maneCount = 10;
    final maneR = r * 0.42;
    for (int i = 0; i < maneCount; i++) {
      final angle = (i * 2 * math.pi) / maneCount;
      final puffCenter = Offset(center.dx + (r * 0.95 * math.cos(angle)), center.dy + (r * 0.95 * math.sin(angle)));
      final puffPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: const [Color(0xFFFFB74D), Color(0xFFF57C00), Color(0xFFE65100)],
        ).createShader(Rect.fromCircle(center: puffCenter, radius: maneR));
      canvas.drawCircle(puffCenter, maneR, puffPaint);
    }

    // 2. Head dome
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: const [Color(0xFFFFE082), Color(0xFFFFCA28), Color(0xFFFFA000)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.72));
    canvas.drawCircle(center, r * 0.72, headPaint);

    // 3. Round Ears
    for (final dir in [-1.0, 1.0]) {
      final earCenter = Offset(center.dx + dir * r * 0.52, center.dy - r * 0.58);
      canvas.drawCircle(earCenter, r * 0.22, Paint()..color = const Color(0xFFFFA000));
      canvas.drawCircle(earCenter, r * 0.13, Paint()..color = const Color(0xFFFFD54F));
    }

    // 4. White/Cream Snout
    final snoutCenter = Offset(center.dx, center.dy + r * 0.22);
    canvas.drawOval(
      Rect.fromCenter(center: snoutCenter, width: r * 0.72, height: r * 0.50),
      Paint()..color = const Color(0xFFFFF8E1),
    );

    // 5. Heart-shaped nose
    final noseCenter = Offset(center.dx, center.dy + r * 0.12);
    canvas.drawCircle(noseCenter, r * 0.12, Paint()..color = const Color(0xFF8D5B28));

    // 6. Eyes, Blush, Smile
    final eyeY = center.dy - r * 0.12;
    final eyeSpacing = r * 0.28;
    _drawPixarEyes(canvas, Offset(center.dx - eyeSpacing, eyeY), Offset(center.dx + eyeSpacing, eyeY), r * 0.16);
    _drawBlush(canvas, Offset(center.dx - r * 0.44, center.dy + r * 0.16), Offset(center.dx + r * 0.44, center.dy + r * 0.16), r * 0.14);
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.28), r * 0.30);

    // 7. Little Golden Crown
    final crownPath = Path()
      ..moveTo(center.dx - r * 0.30, center.dy - r * 0.70)
      ..lineTo(center.dx - r * 0.22, center.dy - r * 0.95)
      ..lineTo(center.dx, center.dy - r * 0.82)
      ..lineTo(center.dx + r * 0.22, center.dy - r * 0.95)
      ..lineTo(center.dx + r * 0.30, center.dy - r * 0.70)
      ..close();
    canvas.drawPath(crownPath, Paint()..color = const Color(0xFFFFD700));
  }

  // ===========================================================================
  // 2. ELEPHANT (Gentle curved trunk & big soft petal ears)
  // ===========================================================================
  void _paintElephant(Canvas canvas, Size size, Offset center, double r) {
    // 1. Big Petal Ears
    for (final dir in [-1.0, 1.0]) {
      final earCenter = Offset(center.dx + dir * r * 0.68, center.dy - r * 0.10);
      final earPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(dir * -0.3, -0.3),
          radius: 0.8,
          colors: const [Color(0xFFB0BEC5), Color(0xFF78909C)],
        ).createShader(Rect.fromCircle(center: earCenter, radius: r * 0.46));
      canvas.drawOval(Rect.fromCenter(center: earCenter, width: r * 0.60, height: r * 0.72), earPaint);
      canvas.drawOval(Rect.fromCenter(center: earCenter, width: r * 0.38, height: r * 0.48), Paint()..color = const Color(0xFFFFCDD2).withOpacity(0.70));
    }

    // 2. Head Dome
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: const [Color(0xFFCFD8DC), Color(0xFF90A4AE), Color(0xFF607D8B)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.68));
    canvas.drawCircle(center, r * 0.68, headPaint);

    // 3. Cute Tusks
    for (final dir in [-1.0, 1.0]) {
      final tuskCenter = Offset(center.dx + dir * r * 0.24, center.dy + r * 0.36);
      canvas.drawOval(Rect.fromCenter(center: tuskCenter, width: r * 0.12, height: r * 0.24), Paint()..color = Colors.white);
    }

    // 4. Curved Trunk
    final trunkPath = Path()
      ..moveTo(center.dx - r * 0.14, center.dy + r * 0.14)
      ..quadraticBezierTo(center.dx - r * 0.20, center.dy + r * 0.58, center.dx, center.dy + r * 0.62)
      ..quadraticBezierTo(center.dx + r * 0.24, center.dy + r * 0.54, center.dx + r * 0.18, center.dy + r * 0.36)
      ..quadraticBezierTo(center.dx + r * 0.08, center.dy + r * 0.44, center.dx - r * 0.02, center.dy + r * 0.42)
      ..quadraticBezierTo(center.dx - r * 0.06, center.dy + r * 0.24, center.dx + r * 0.14, center.dy + r * 0.14)
      ..close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF78909C));

    // 5. Eyes & Blush
    final eyeY = center.dy - r * 0.08;
    final eyeSpacing = r * 0.26;
    _drawPixarEyes(canvas, Offset(center.dx - eyeSpacing, eyeY), Offset(center.dx + eyeSpacing, eyeY), r * 0.15, irisColor: const Color(0xFF1E3C72));
    _drawBlush(canvas, Offset(center.dx - r * 0.38, center.dy + r * 0.18), Offset(center.dx + r * 0.38, center.dy + r * 0.18), r * 0.12);
  }

  // ===========================================================================
  // 3. PANDA (Signature eye patches, round fluffy ears, bamboo)
  // ===========================================================================
  void _paintPanda(Canvas canvas, Size size, Offset center, double r) {
    // 1. Black Ears
    for (final dir in [-1.0, 1.0]) {
      final earCenter = Offset(center.dx + dir * r * 0.56, center.dy - r * 0.54);
      final earPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          radius: 0.8,
          colors: const [Color(0xFF424242), Color(0xFF212121)],
        ).createShader(Rect.fromCircle(center: earCenter, radius: r * 0.26));
      canvas.drawCircle(earCenter, r * 0.26, earPaint);
    }

    // 2. White Head Dome
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 0.9,
        colors: const [Colors.white, Color(0xFFECEFF1), Color(0xFFCFD8DC)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.72));
    canvas.drawCircle(center, r * 0.72, headPaint);

    // 3. Signature Black Teardrop Eye Patches
    for (final dir in [-1.0, 1.0]) {
      final patchCenter = Offset(center.dx + dir * r * 0.28, center.dy - r * 0.06);
      canvas.save();
      canvas.translate(patchCenter.dx, patchCenter.dy);
      canvas.rotate(dir * 0.22);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.36, height: r * 0.46),
        Paint()..color = const Color(0xFF263238),
      );
      canvas.restore();
    }

    // 4. Eyes & Blush
    final eyeY = center.dy - r * 0.06;
    final eyeSpacing = r * 0.28;
    _drawPixarEyes(canvas, Offset(center.dx - eyeSpacing, eyeY), Offset(center.dx + eyeSpacing, eyeY), r * 0.14, irisColor: const Color(0xFF37474F));
    _drawBlush(canvas, Offset(center.dx - r * 0.44, center.dy + r * 0.22), Offset(center.dx + r * 0.44, center.dy + r * 0.22), r * 0.13);

    // 5. Snout & Nose
    final snoutCenter = Offset(center.dx, center.dy + r * 0.24);
    canvas.drawOval(Rect.fromCenter(center: snoutCenter, width: r * 0.42, height: r * 0.28), Paint()..color = const Color(0xFFFAFAFA));
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.18), r * 0.11, Paint()..color = const Color(0xFF212121));
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.28), r * 0.24);
  }

  // ===========================================================================
  // 4. DOGGY (Floppy caramel ears, wet shiny nose, happy tongue)
  // ===========================================================================
  void _paintDog(Canvas canvas, Size size, Offset center, double r) {
    // 1. Floppy Caramel Ears
    for (final dir in [-1.0, 1.0]) {
      final earCenter = Offset(center.dx + dir * r * 0.62, center.dy - r * 0.05);
      final earPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(dir * -0.3, -0.3),
          radius: 0.8,
          colors: const [Color(0xFF8D6E63), Color(0xFF5D4037)],
        ).createShader(Rect.fromCircle(center: earCenter, radius: r * 0.40));
      canvas.drawOval(Rect.fromCenter(center: earCenter, width: r * 0.44, height: r * 0.74), earPaint);
    }

    // 2. Head Dome
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: const [Color(0xFFFFE0B2), Color(0xFFFFCC80), Color(0xFFFFA726)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.70));
    canvas.drawCircle(center, r * 0.70, headPaint);

    // 3. White Snout
    final snoutCenter = Offset(center.dx, center.dy + r * 0.22);
    canvas.drawOval(Rect.fromCenter(center: snoutCenter, width: r * 0.60, height: r * 0.46), Paint()..color = Colors.white);

    // 4. Wet Shiny Black Nose
    final noseCenter = Offset(center.dx, center.dy + r * 0.14);
    canvas.drawOval(Rect.fromCenter(center: noseCenter, width: r * 0.24, height: r * 0.18), Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(Offset(noseCenter.dx - r * 0.04, noseCenter.dy - r * 0.03), r * 0.04, Paint()..color = Colors.white);

    // 5. Happy Pink Tongue
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.38), width: r * 0.18, height: r * 0.24), Paint()..color = const Color(0xFFFF5252));

    // 6. Eyes, Blush, Smile
    final eyeY = center.dy - r * 0.10;
    final eyeSpacing = r * 0.26;
    _drawPixarEyes(canvas, Offset(center.dx - eyeSpacing, eyeY), Offset(center.dx + eyeSpacing, eyeY), r * 0.15);
    _drawBlush(canvas, Offset(center.dx - r * 0.40, center.dy + r * 0.18), Offset(center.dx + r * 0.40, center.dy + r * 0.18), r * 0.13);
  }

  // ===========================================================================
  // 5. CAT / KITTEN (Perky pointed ears, whiskers, blue eyes)
  // ===========================================================================
  void _paintCat(Canvas canvas, Size size, Offset center, double r) {
    // 1. Pointed Ears
    for (final dir in [-1.0, 1.0]) {
      final earPath = Path()
        ..moveTo(center.dx + dir * r * 0.25, center.dy - r * 0.48)
        ..lineTo(center.dx + dir * r * 0.58, center.dy - r * 0.90)
        ..lineTo(center.dx + dir * r * 0.68, center.dy - r * 0.35)
        ..close();
      canvas.drawPath(earPath, Paint()..color = const Color(0xFFFF8A80));

      final innerPath = Path()
        ..moveTo(center.dx + dir * r * 0.32, center.dy - r * 0.50)
        ..lineTo(center.dx + dir * r * 0.54, center.dy - r * 0.80)
        ..lineTo(center.dx + dir * r * 0.60, center.dy - r * 0.40)
        ..close();
      canvas.drawPath(innerPath, Paint()..color = const Color(0xFFFFCDD2));
    }

    // 2. Head Dome
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: const [Color(0xFFFFCCBC), Color(0xFFFFAB91), Color(0xFFFF8A65)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.68));
    canvas.drawCircle(center, r * 0.68, headPaint);

    // 3. White Muzzle
    final snoutCenter = Offset(center.dx, center.dy + r * 0.20);
    canvas.drawOval(Rect.fromCenter(center: snoutCenter, width: r * 0.54, height: r * 0.38), Paint()..color = Colors.white);
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.12), r * 0.08, Paint()..color = const Color(0xFFE91E63));

    // 4. Eyes & Whiskers
    final eyeY = center.dy - r * 0.08;
    final eyeSpacing = r * 0.26;
    _drawPixarEyes(canvas, Offset(center.dx - eyeSpacing, eyeY), Offset(center.dx + eyeSpacing, eyeY), r * 0.15, irisColor: const Color(0xFF00B0FF));
    _drawBlush(canvas, Offset(center.dx - r * 0.40, center.dy + r * 0.16), Offset(center.dx + r * 0.40, center.dy + r * 0.16), r * 0.12);

    final whiskerPaint = Paint()
      ..color = const Color(0xFF795548).withOpacity(0.55)
      ..strokeWidth = 2.0;
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(Offset(center.dx + dir * r * 0.28, center.dy + r * 0.18), Offset(center.dx + dir * r * 0.68, center.dy + r * 0.14), whiskerPaint);
      canvas.drawLine(Offset(center.dx + dir * r * 0.28, center.dy + r * 0.24), Offset(center.dx + dir * r * 0.66, center.dy + r * 0.28), whiskerPaint);
    }
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.24), r * 0.22);
  }

  // ===========================================================================
  // 6. COW (Spotted dome, horns, soft pink snout)
  // ===========================================================================
  void _paintCow(Canvas canvas, Size size, Offset center, double r) {
    for (final dir in [-1.0, 1.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + dir * r * 0.42, center.dy - r * 0.65), width: r * 0.14, height: r * 0.32), Paint()..color = const Color(0xFFFFB74D));
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + dir * r * 0.64, center.dy - r * 0.32), width: r * 0.42, height: r * 0.24), Paint()..color = const Color(0xFF42A5F5));
    }
    canvas.drawCircle(center, r * 0.68, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(center.dx - r * 0.28, center.dy - r * 0.30), r * 0.20, Paint()..color = const Color(0xFF37474F));

    final snoutCenter = Offset(center.dx, center.dy + r * 0.28);
    canvas.drawOval(Rect.fromCenter(center: snoutCenter, width: r * 0.68, height: r * 0.42), Paint()..color = const Color(0xFFFF80AB));
    canvas.drawCircle(Offset(center.dx - r * 0.14, snoutCenter.dy), r * 0.06, Paint()..color = const Color(0xFF880E4F));
    canvas.drawCircle(Offset(center.dx + r * 0.14, snoutCenter.dy), r * 0.06, Paint()..color = const Color(0xFF880E4F));

    _drawPixarEyes(canvas, Offset(center.dx - r * 0.26, center.dy - r * 0.06), Offset(center.dx + r * 0.26, center.dy - r * 0.06), r * 0.14);
  }

  // ===========================================================================
  // 7. DUCK (Shiny golden bill, sunny feathers)
  // ===========================================================================
  void _paintDuck(Canvas canvas, Size size, Offset center, double r) {
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 0.85,
        colors: const [Color(0xFFFFF59D), Color(0xFFFFEE58), Color(0xFFFDD835)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.70));
    canvas.drawCircle(center, r * 0.70, headPaint);

    final billCenter = Offset(center.dx, center.dy + r * 0.24);
    canvas.drawOval(Rect.fromCenter(center: billCenter, width: r * 0.66, height: r * 0.36), Paint()..color = const Color(0xFFFF9800));
    canvas.drawOval(Rect.fromCenter(center: Offset(billCenter.dx, billCenter.dy - r * 0.06), width: r * 0.36, height: r * 0.12), Paint()..color = const Color(0xFFFFD54F));

    final eyeY = center.dy - r * 0.08;
    _drawPixarEyes(canvas, Offset(center.dx - r * 0.26, eyeY), Offset(center.dx + r * 0.26, eyeY), r * 0.15, irisColor: const Color(0xFF00897B));
    _drawBlush(canvas, Offset(center.dx - r * 0.42, center.dy + r * 0.16), Offset(center.dx + r * 0.42, center.dy + r * 0.16), r * 0.13);
  }

  // ===========================================================================
  // 8. FROG (Bulbous glossy eyes atop head, wide smile)
  // ===========================================================================
  void _paintFrog(Canvas canvas, Size size, Offset center, double r) {
    for (final dir in [-1.0, 1.0]) {
      final bulbCenter = Offset(center.dx + dir * r * 0.38, center.dy - r * 0.42);
      canvas.drawCircle(bulbCenter, r * 0.32, Paint()..color = const Color(0xFF66BB6A));
      _drawPixarEyes(canvas, bulbCenter, bulbCenter, r * 0.20, irisColor: const Color(0xFF2E7D32));
    }
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 0.85,
        colors: const [Color(0xFFA5D6A7), Color(0xFF81C784), Color(0xFF4CAF50)],
      ).createShader(Rect.fromCircle(center: Offset(center.dx, center.dy + r * 0.10), radius: r * 0.68));
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.14), width: r * 1.35, height: r * 0.90), headPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.32), width: r * 0.85, height: r * 0.45), Paint()..color = const Color(0xFFFFF59D));

    _drawBlush(canvas, Offset(center.dx - r * 0.48, center.dy + r * 0.18), Offset(center.dx + r * 0.48, center.dy + r * 0.18), r * 0.14);
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.26), r * 0.55);
  }

  // ===========================================================================
  // 9. PENGUIN (Tuxedo hood, white belly, orange beak)
  // ===========================================================================
  void _paintPenguin(Canvas canvas, Size size, Offset center, double r) {
    final hoodPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 0.85,
        colors: const [Color(0xFF455A64), Color(0xFF263238)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.72));
    canvas.drawCircle(center, r * 0.72, hoodPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.10), width: r * 0.95, height: r * 0.82), Paint()..color = Colors.white);

    final beakCenter = Offset(center.dx, center.dy + r * 0.14);
    final beakPath = Path()
      ..moveTo(beakCenter.dx - r * 0.16, beakCenter.dy)
      ..lineTo(beakCenter.dx + r * 0.16, beakCenter.dy)
      ..lineTo(beakCenter.dx, beakCenter.dy + r * 0.20)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = const Color(0xFFFF9800));

    final eyeY = center.dy - r * 0.08;
    _drawPixarEyes(canvas, Offset(center.dx - r * 0.26, eyeY), Offset(center.dx + r * 0.26, eyeY), r * 0.14, irisColor: const Color(0xFF0097A7));
    _drawBlush(canvas, Offset(center.dx - r * 0.38, center.dy + r * 0.18), Offset(center.dx + r * 0.38, center.dy + r * 0.18), r * 0.12);
  }

  // ===========================================================================
  // 10. RABBIT / BUNNY (Tall ears with pink interior, buck teeth)
  // ===========================================================================
  void _paintRabbit(Canvas canvas, Size size, Offset center, double r) {
    for (final dir in [-1.0, 1.0]) {
      final earCenter = Offset(center.dx + dir * r * 0.32, center.dy - r * 0.75);
      canvas.drawOval(Rect.fromCenter(center: earCenter, width: r * 0.26, height: r * 0.72), Paint()..color = const Color(0xFFF8BBD0));
      canvas.drawOval(Rect.fromCenter(center: earCenter, width: r * 0.14, height: r * 0.52), Paint()..color = const Color(0xFFF06292));
    }
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: const [Color(0xFFFCE4EC), Color(0xFFF8BBD0), Color(0xFFF48FB1)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.68));
    canvas.drawCircle(center, r * 0.68, headPaint);

    final toothCenter = Offset(center.dx, center.dy + r * 0.32);
    canvas.drawRect(Rect.fromCenter(center: toothCenter, width: r * 0.12, height: r * 0.10), Paint()..color = Colors.white);
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.14), r * 0.09, Paint()..color = const Color(0xFFE91E63));

    final eyeY = center.dy - r * 0.08;
    _drawPixarEyes(canvas, Offset(center.dx - r * 0.26, eyeY), Offset(center.dx + r * 0.26, eyeY), r * 0.15, irisColor: const Color(0xFFAD1457));
    _drawBlush(canvas, Offset(center.dx - r * 0.40, center.dy + r * 0.18), Offset(center.dx + r * 0.40, center.dy + r * 0.18), r * 0.13);
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.24), r * 0.24);
  }

  // ===========================================================================
  // 11. BEAR / TEDDY (Warm chocolate fur, honey snout)
  // ===========================================================================
  void _paintBear(Canvas canvas, Size size, Offset center, double r) {
    for (final dir in [-1.0, 1.0]) {
      final earCenter = Offset(center.dx + dir * r * 0.54, center.dy - r * 0.54);
      canvas.drawCircle(earCenter, r * 0.25, Paint()..color = const Color(0xFF6D4C41));
      canvas.drawCircle(earCenter, r * 0.14, Paint()..color = const Color(0xFFFFB74D));
    }
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: const [Color(0xFF8D6E63), Color(0xFF6D4C41), Color(0xFF4E342E)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.70));
    canvas.drawCircle(center, r * 0.70, headPaint);

    final snoutCenter = Offset(center.dx, center.dy + r * 0.22);
    canvas.drawOval(Rect.fromCenter(center: snoutCenter, width: r * 0.62, height: r * 0.46), Paint()..color = const Color(0xFFFFE0B2));
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.14), r * 0.12, Paint()..color = const Color(0xFF212121));

    final eyeY = center.dy - r * 0.10;
    _drawPixarEyes(canvas, Offset(center.dx - r * 0.28, eyeY), Offset(center.dx + r * 0.28, eyeY), r * 0.15);
    _drawBlush(canvas, Offset(center.dx - r * 0.42, center.dy + r * 0.18), Offset(center.dx + r * 0.42, center.dy + r * 0.18), r * 0.13);
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.26), r * 0.26);
  }

  // ===========================================================================
  // 12. DOLPHIN (Cyan body, curved dorsal fin, water sparkle)
  // ===========================================================================
  void _paintDolphin(Canvas canvas, Size size, Offset center, double r) {
    final finPath = Path()
      ..moveTo(center.dx, center.dy - r * 0.60)
      ..quadraticBezierTo(center.dx + r * 0.15, center.dy - r * 0.95, center.dx + r * 0.40, center.dy - r * 0.65)
      ..close();
    canvas.drawPath(finPath, Paint()..color = const Color(0xFF00B0FF));

    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: const [Color(0xFF80D8FF), Color(0xFF00E5FF), Color(0xFF0091EA)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.70));
    canvas.drawCircle(center, r * 0.70, bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - r * 0.10, center.dy + r * 0.26), width: r * 0.75, height: r * 0.44), Paint()..color = Colors.white);

    _drawPixarEyes(canvas, Offset(center.dx - r * 0.22, center.dy - r * 0.08), Offset(center.dx + r * 0.24, center.dy - r * 0.08), r * 0.14, irisColor: const Color(0xFF01579B));
    _drawBlush(canvas, Offset(center.dx - r * 0.38, center.dy + r * 0.14), Offset(center.dx + r * 0.38, center.dy + r * 0.14), r * 0.12);
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.20), r * 0.34);
  }

  // ===========================================================================
  // 13. GIRAFFE, MONKEY, TIGER, SHEEP & FALLBACK
  // ===========================================================================
  void _paintGiraffe(Canvas canvas, Size size, Offset center, double r) {
    for (final dir in [-1.0, 1.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + dir * r * 0.22, center.dy - r * 0.75), width: r * 0.12, height: r * 0.28), Paint()..color = const Color(0xFF8D6E63));
    }
    canvas.drawCircle(center, r * 0.68, Paint()..color = const Color(0xFFFFCA28));
    canvas.drawCircle(Offset(center.dx - r * 0.32, center.dy - r * 0.20), r * 0.12, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawCircle(Offset(center.dx + r * 0.30, center.dy - r * 0.24), r * 0.14, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.24), width: r * 0.60, height: r * 0.42), Paint()..color = const Color(0xFFFFE0B2));
    _drawPixarEyes(canvas, Offset(center.dx - r * 0.26, center.dy - r * 0.08), Offset(center.dx + r * 0.26, center.dy - r * 0.08), r * 0.14);
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.26), r * 0.26);
  }

  void _paintMonkey(Canvas canvas, Size size, Offset center, double r) {
    for (final dir in [-1.0, 1.0]) {
      canvas.drawCircle(Offset(center.dx + dir * r * 0.65, center.dy), r * 0.28, Paint()..color = const Color(0xFF8D6E63));
      canvas.drawCircle(Offset(center.dx + dir * r * 0.65, center.dy), r * 0.16, Paint()..color = const Color(0xFFFFCC80));
    }
    canvas.drawCircle(center, r * 0.66, Paint()..color = const Color(0xFF6D4C41));
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.18), width: r * 0.66, height: r * 0.46), Paint()..color = const Color(0xFFFFE0B2));
    _drawPixarEyes(canvas, Offset(center.dx - r * 0.24, center.dy - r * 0.10), Offset(center.dx + r * 0.24, center.dy - r * 0.10), r * 0.14);
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.24), r * 0.28);
  }

  void _paintTiger(Canvas canvas, Size size, Offset center, double r) {
    _paintLion(canvas, size, center, r);
  }

  void _paintSheep(Canvas canvas, Size size, Offset center, double r) {
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      canvas.drawCircle(Offset(center.dx + r * 0.7 * math.cos(angle), center.dy + r * 0.7 * math.sin(angle)), r * 0.35, Paint()..color = const Color(0xFFECEFF1));
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.10), width: r * 0.85, height: r * 0.75), Paint()..color = const Color(0xFFCFD8DC));
    _drawPixarEyes(canvas, Offset(center.dx - r * 0.24, center.dy - r * 0.04), Offset(center.dx + r * 0.24, center.dy - r * 0.04), r * 0.14);
    _drawSmile(canvas, Offset(center.dx, center.dy + r * 0.24), r * 0.24);
  }

  void _paintDefaultAnimal(Canvas canvas, Size size, Offset center, double r) {
    _paintLion(canvas, size, center, r);
  }

  @override
  bool shouldRepaint(covariant _PixarAnimalPainter oldDelegate) => oldDelegate.animalId != animalId;
}
