import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a highly realistic, botanical 3D fruit with multi-layered gradients,
/// anatomical curves, specular lighting, surface textures, stem, and leaves.
class RealisticFruitWidget extends StatelessWidget {
  final String fruitKindId;
  final double size;
  final bool isCountTapped;
  final int? tapOrder;

  const RealisticFruitWidget({
    super.key,
    required this.fruitKindId,
    this.size = 52,
    this.isCountTapped = false,
    this.tapOrder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.12,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Soft Grounding / Branch Contact Shadow
          Positioned(
            bottom: 2,
            child: Container(
              width: size * 0.72,
              height: size * 0.18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.26),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          // Count tapped glowing halo aura
          if (isCountTapped)
            Positioned(
              child: Container(
                width: size * 1.15,
                height: size * 1.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withOpacity(0.85),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
            ),

          // Main realistic custom-painted fruit
          CustomPaint(
            size: Size(size, size * 1.1),
            painter: RealisticFruitPainter(
              fruitKindId: fruitKindId,
              isHighlighted: isCountTapped,
            ),
          ),

          // Ordinal tap badge indicator (e.g. 1, 2, 3...)
          if (isCountTapped && tapOrder != null)
            Positioned(
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  '$tapOrder',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter rendering botanical realism for all 8 fruit varieties
class RealisticFruitPainter extends CustomPainter {
  final String fruitKindId;
  final bool isHighlighted;

  RealisticFruitPainter({
    required this.fruitKindId,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    switch (fruitKindId) {
      case 'apple':
        _paintRealisticApple(canvas, size);
        break;
      case 'banana':
        _paintRealisticBanana(canvas, size);
        break;
      case 'orange':
        _paintRealisticOrange(canvas, size);
        break;
      case 'strawberry':
        _paintRealisticStrawberry(canvas, size);
        break;
      case 'watermelon':
        _paintRealisticWatermelon(canvas, size);
        break;
      case 'grapes':
        _paintRealisticGrapes(canvas, size);
        break;
      case 'mango':
        _paintRealisticMango(canvas, size);
        break;
      case 'cherry':
        _paintRealisticCherry(canvas, size);
        break;
      default:
        _paintRealisticApple(canvas, size);
        break;
    }

    canvas.restore();
  }

  // ===========================================================================
  // 1. REALISTIC APPLE (Honeycrisp / Red Delicious with botanical shape,
  //    stem cavity, calibrated radial gradient, fine striations, and glossy sheen)
  // ===========================================================================
  void _paintRealisticApple(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // --- STEM ---
    final stemPath = Path()
      ..moveTo(w * 0.49, h * 0.30)
      ..cubicTo(w * 0.48, h * 0.16, w * 0.58, h * 0.10, w * 0.64, h * 0.06);

    final stemPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.4, w * 0.06)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(stemPath, stemPaint);

    // Stem highlight
    final stemGlint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.02)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(stemPath, stemGlint);

    // --- BOTANICAL LEAF ---
    final leafPath = Path()
      ..moveTo(w * 0.52, h * 0.20)
      ..cubicTo(w * 0.70, h * 0.10, w * 0.86, h * 0.18, w * 0.90, h * 0.26)
      ..cubicTo(w * 0.78, h * 0.35, w * 0.62, h * 0.30, w * 0.52, h * 0.20)
      ..close();

    final leafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF81C784), Color(0xFF2E7D32), Color(0xFF1B5E20)],
      ).createShader(Rect.fromLTWH(w * 0.5, h * 0.1, w * 0.4, h * 0.3));
    canvas.drawPath(leafPath, leafPaint);

    // Leaf main central vein
    final veinPaint = Paint()
      ..color = const Color(0xFFA5D6A7).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final leafVeinPath = Path()
      ..moveTo(w * 0.54, h * 0.21)
      ..cubicTo(w * 0.68, h * 0.18, w * 0.78, h * 0.22, w * 0.88, h * 0.25);
    canvas.drawPath(leafVeinPath, veinPaint);

    // Dewdrop on leaf
    canvas.drawCircle(
      Offset(w * 0.74, h * 0.20),
      w * 0.025,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // --- APPLE ANATOMICAL SILHOUETTE ---
    // Characteristic dual-lobed top cleft and tapered base with 5 calyx bumps
    final applePath = Path();
    applePath.moveTo(w * 0.50, h * 0.33); // Stem indentation cleft
    applePath.cubicTo(w * 0.32, h * 0.23, w * 0.08, h * 0.38, w * 0.10, h * 0.62); // Left shoulder
    applePath.cubicTo(w * 0.11, h * 0.82, w * 0.28, h * 0.96, w * 0.44, h * 0.94); // Left lower base
    applePath.cubicTo(w * 0.48, h * 0.95, w * 0.52, h * 0.95, w * 0.56, h * 0.94); // Base cleft
    applePath.cubicTo(w * 0.72, h * 0.96, w * 0.89, h * 0.82, w * 0.90, h * 0.62); // Right lower base
    applePath.cubicTo(w * 0.92, h * 0.38, w * 0.68, h * 0.23, w * 0.50, h * 0.33); // Right shoulder
    applePath.close();

    // Volumetric 3D Shading: Shadow, Carmine Red, Honey Gold near stem
    final appleRect = Rect.fromLTWH(w * 0.08, h * 0.24, w * 0.84, h * 0.72);
    final baseShader = RadialGradient(
      center: const Alignment(-0.30, -0.35),
      radius: 0.88,
      colors: const [
        Color(0xFFFF8A80), // Sunlit highlight
        Color(0xFFFF1744), // Vibrant scarlet
        Color(0xFFD50000), // Rich crimson
        Color(0xFF880E4F), // Deep wine core
        Color(0xFF4A0012), // Deep shadow edge
      ],
      stops: const [0.0, 0.32, 0.65, 0.88, 1.0],
    ).createShader(appleRect);

    canvas.drawPath(applePath, Paint()..shader = baseShader);

    // Natural yellow-gold undertone near stem indentation
    final stemHollowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          const Color(0xFFFFD54F).withOpacity(0.65),
          const Color(0xFFC62828).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCenter(center: Offset(w * 0.50, h * 0.34), width: w * 0.28, height: h * 0.12));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.34), width: w * 0.28, height: h * 0.12),
      stemHollowPaint,
    );

    // Fine organic apple striations / skin speckles
    final stripePaint = Paint()
      ..color = const Color(0xFFFFCDD2).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 6; i++) {
      final t = 0.25 + i * 0.10;
      canvas.drawLine(
        Offset(w * t, h * 0.40),
        Offset(w * (t + 0.02), h * 0.78),
        stripePaint,
      );
    }

    // Specular High-Gloss Sheen (Curved highlight along left shoulder)
    final glossPath = Path()
      ..moveTo(w * 0.24, h * 0.42)
      ..cubicTo(w * 0.32, h * 0.36, w * 0.44, h * 0.40, w * 0.38, h * 0.52)
      ..cubicTo(w * 0.32, h * 0.46, w * 0.26, h * 0.48, w * 0.24, h * 0.42)
      ..close();

    final glossPaint = Paint()
      ..color = Colors.white.withOpacity(0.60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
    canvas.drawPath(glossPath, glossPaint);

    // Secondary soft ambient rim glint (bottom-right edge)
    final rimGlintPath = Path()
      ..moveTo(w * 0.72, h * 0.82)
      ..cubicTo(w * 0.82, h * 0.74, w * 0.84, h * 0.62, w * 0.85, h * 0.56);
    canvas.drawPath(
      rimGlintPath,
      Paint()
        ..color = Colors.white.withOpacity(0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }

  // ===========================================================================
  // 2. REALISTIC BANANA (Graceful crescent curve, faceted ridges, green crown,
  //    and ripened tip)
  // ===========================================================================
  void _paintRealisticBanana(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Banana main crescent body
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.78, h * 0.18); // Crown
    bodyPath.cubicTo(w * 0.86, h * 0.48, w * 0.66, h * 0.86, w * 0.22, h * 0.88); // Outer back curve
    bodyPath.cubicTo(w * 0.16, h * 0.88, w * 0.14, h * 0.84, w * 0.16, h * 0.80); // Tip
    bodyPath.cubicTo(w * 0.48, h * 0.74, w * 0.66, h * 0.46, w * 0.72, h * 0.22); // Inner belly curve
    bodyPath.close();

    final bananaShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFF176), // Bright banana yellow
        Color(0xFFFFEE58),
        Color(0xFFFDD835),
        Color(0xFFFBC02D), // Rich golden yellow
        Color(0xFFF57F17), // Shadow amber
      ],
      stops: [0.0, 0.35, 0.60, 0.85, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(bodyPath, Paint()..shader = bananaShader);

    // Distinctive longitudinal ridge facet
    final ridgePath = Path()
      ..moveTo(w * 0.75, h * 0.20)
      ..cubicTo(w * 0.78, h * 0.46, w * 0.58, h * 0.76, w * 0.20, h * 0.82);
    canvas.drawPath(
      ridgePath,
      Paint()
        ..color = const Color(0xFFF57F17).withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // Specular shine along ridge
    final ridgeShine = Path()
      ..moveTo(w * 0.72, h * 0.28)
      ..cubicTo(w * 0.74, h * 0.44, w * 0.56, h * 0.68, w * 0.32, h * 0.76);
    canvas.drawPath(
      ridgeShine,
      Paint()
        ..color = Colors.white.withOpacity(0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );

    // Green crown / stem stalk
    final stemPath = Path()
      ..moveTo(w * 0.78, h * 0.18)
      ..lineTo(w * 0.86, h * 0.10)
      ..lineTo(w * 0.82, h * 0.08)
      ..lineTo(w * 0.72, h * 0.22)
      ..close();
    canvas.drawPath(
      stemPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF7CB342), Color(0xFF33691E)],
        ).createShader(Rect.fromLTWH(w * 0.7, h * 0.05, w * 0.2, h * 0.2)),
    );

    // Brown tip at the blossom end
    canvas.drawCircle(Offset(w * 0.16, h * 0.83), w * 0.045, Paint()..color = const Color(0xFF4E342E));
  }

  // ===========================================================================
  // 3. REALISTIC ORANGE (Pored citrus peel, star calyx button, warm glow)
  // ===========================================================================
  void _paintRealisticOrange(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.50, h * 0.56);
    final r = w * 0.40;

    // Oblate spherical body
    final orangeRect = Rect.fromCenter(center: center, width: r * 2.05, height: r * 1.95);

    final orangeShader = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.88,
      colors: const [
        Color(0xFFFFCC80), // Sunlit highlight
        Color(0xFFFFA726), // Ripe orange
        Color(0xFFFF9800),
        Color(0xFFF57C00), // Deep orange
        Color(0xFFE65100), // Shadow citrus
        Color(0xFFBF360C), // Deepest rim
      ],
      stops: const [0.0, 0.35, 0.55, 0.75, 0.90, 1.0],
    ).createShader(orangeRect);

    canvas.drawOval(orangeRect, Paint()..shader = orangeShader);

    // Natural citrus peel stippling / pores
    final porePaint = Paint()..color = const Color(0xFFE65100).withOpacity(0.22);
    final random = math.Random(1234);
    for (int i = 0; i < 36; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final dist = random.nextDouble() * (r * 0.82);
      final px = center.dx + dist * math.cos(angle);
      final py = center.dy + dist * math.sin(angle) * 0.95;
      canvas.drawCircle(Offset(px, py), 0.7, porePaint);
    }

    // Specular crescent gleam
    final glintPath = Path()
      ..addOval(Rect.fromCenter(center: Offset(center.dx - r * 0.35, center.dy - r * 0.35), width: r * 0.65, height: r * 0.40));
    canvas.drawPath(
      glintPath,
      Paint()
        ..color = Colors.white.withOpacity(0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    // Botanical star calyx button (top)
    final calyxCenter = Offset(w * 0.50, h * 0.20);
    final calyxPaint = Paint()..color = const Color(0xFF33691E);
    for (int i = 0; i < 5; i++) {
      final a = (i * 2 * math.pi / 5) - math.pi / 2;
      final sepalPath = Path()
        ..moveTo(calyxCenter.dx, calyxCenter.dy)
        ..lineTo(calyxCenter.dx + w * 0.08 * math.cos(a - 0.25), calyxCenter.dy + w * 0.08 * math.sin(a - 0.25))
        ..lineTo(calyxCenter.dx + w * 0.12 * math.cos(a), calyxCenter.dy + w * 0.12 * math.sin(a))
        ..lineTo(calyxCenter.dx + w * 0.08 * math.cos(a + 0.25), calyxCenter.dy + w * 0.08 * math.sin(a + 0.25))
        ..close();
      canvas.drawPath(sepalPath, calyxPaint);
    }
    // Center button
    canvas.drawCircle(calyxCenter, w * 0.035, Paint()..color = const Color(0xFF558B2F));
  }

  // ===========================================================================
  // 4. REALISTIC STRAWBERRY (Conical heart, recessed achenes/seeds, calyx crown)
  // ===========================================================================
  void _paintRealisticStrawberry(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Heart-conical strawberry silhouette
    final berryPath = Path();
    berryPath.moveTo(w * 0.50, h * 0.25);
    berryPath.cubicTo(w * 0.18, h * 0.25, w * 0.14, h * 0.52, w * 0.32, h * 0.78);
    berryPath.cubicTo(w * 0.42, h * 0.94, w * 0.50, h * 0.98, w * 0.50, h * 0.98);
    berryPath.cubicTo(w * 0.50, h * 0.98, w * 0.58, h * 0.94, w * 0.68, h * 0.78);
    berryPath.cubicTo(w * 0.86, h * 0.52, w * 0.82, h * 0.25, w * 0.50, h * 0.25);
    berryPath.close();

    final berryShader = RadialGradient(
      center: const Alignment(-0.25, -0.30),
      radius: 0.85,
      colors: const [
        Color(0xFFFF8A80), // Sunlit highlight
        Color(0xFFFF1744), // Lush strawberry red
        Color(0xFFD50000),
        Color(0xFFB71C1C), // Deep crimson
        Color(0xFF4A0012), // Bottom shadow
      ],
      stops: const [0.0, 0.35, 0.65, 0.88, 1.0],
    ).createShader(Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.8, h * 0.8));

    canvas.drawPath(berryPath, Paint()..shader = berryShader);

    // Realistic yellow-gold achenes (seeds) in subtle micro-dimples
    final seedPositions = [
      Offset(w * 0.36, h * 0.38), Offset(w * 0.50, h * 0.36), Offset(w * 0.64, h * 0.38),
      Offset(w * 0.28, h * 0.48), Offset(w * 0.42, h * 0.48), Offset(w * 0.58, h * 0.48), Offset(w * 0.72, h * 0.48),
      Offset(w * 0.34, h * 0.60), Offset(w * 0.50, h * 0.60), Offset(w * 0.66, h * 0.60),
      Offset(w * 0.40, h * 0.72), Offset(w * 0.58, h * 0.72),
      Offset(w * 0.46, h * 0.84), Offset(w * 0.54, h * 0.84),
      Offset(w * 0.50, h * 0.92),
    ];

    for (final pos in seedPositions) {
      // Dimple shadow
      canvas.drawOval(
        Rect.fromCenter(center: Offset(pos.dx, pos.dy + 0.8), width: 3.2, height: 4.6),
        Paint()..color = const Color(0xFF5E0000).withOpacity(0.55),
      );
      // Yellow seed body
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 2.2, height: 3.6),
        Paint()..color = const Color(0xFFFFEB3B),
      );
    }

    // Top Glossy highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.35, h * 0.36), width: w * 0.22, height: h * 0.12),
      Paint()
        ..color = Colors.white.withOpacity(0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Green leafy crown (calyx)
    final calyxPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF66BB6A), Color(0xFF1B5E20)],
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.08, w * 0.6, h * 0.25));

    final calyxPath = Path();
    calyxPath.moveTo(w * 0.50, h * 0.16);
    // 5 pointed curved leaves radiating downward
    final sepalAngles = [-1.3, -0.65, 0.0, 0.65, 1.3];
    for (final sa in sepalAngles) {
      final tipX = w * 0.50 + w * 0.28 * math.sin(sa);
      final tipY = h * 0.24 + h * 0.12 * math.cos(sa);
      calyxPath.lineTo(tipX, tipY);
      calyxPath.lineTo(w * 0.50 + w * 0.08 * math.sin(sa + 0.3), h * 0.20);
    }
    calyxPath.close();
    canvas.drawPath(calyxPath, calyxPaint);

    // Small stem
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.12), width: 3.5, height: 8),
      Paint()..color = const Color(0xFF33691E),
    );
  }

  // ===========================================================================
  // 5. REALISTIC WATERMELON (Juicy crisp wedge, red pulp, rind, glossy seeds)
  // ===========================================================================
  void _paintRealisticWatermelon(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wedge triangular slice path
    final slicePath = Path();
    slicePath.moveTo(w * 0.50, h * 0.16); // Top apex
    slicePath.lineTo(w * 0.12, h * 0.78); // Bottom left
    slicePath.quadraticBezierTo(w * 0.50, h * 0.96, w * 0.88, h * 0.78); // Curved green rind
    slicePath.close();

    // 1. Outer Dark Green Rind
    final rindOuterPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(slicePath, rindOuterPaint);

    // 2. Inner Pale Green / White Rind Cushion
    final whiteRindPath = Path()
      ..moveTo(w * 0.50, h * 0.18)
      ..lineTo(w * 0.15, h * 0.75)
      ..quadraticBezierTo(w * 0.50, h * 0.91, w * 0.85, h * 0.75)
      ..close();
    canvas.drawPath(whiteRindPath, Paint()..color = const Color(0xFFE8F5E9));

    // 3. Crisp Red Juicy Pulp
    final pulpPath = Path()
      ..moveTo(w * 0.50, h * 0.20)
      ..lineTo(w * 0.18, h * 0.72)
      ..quadraticBezierTo(w * 0.50, h * 0.86, w * 0.82, h * 0.72)
      ..close();

    final pulpShader = const RadialGradient(
      center: Alignment(0.0, -0.2),
      radius: 0.85,
      colors: [
        Color(0xFFFF5252), // Juicy watermelon red
        Color(0xFFFF1744),
        Color(0xFFD50000),
      ],
    ).createShader(Rect.fromLTWH(w * 0.18, h * 0.20, w * 0.64, h * 0.66));
    canvas.drawPath(pulpPath, Paint()..shader = pulpShader);

    // 4. Glossy Teardrop Black Seeds
    final seedPaint = Paint()..color = const Color(0xFF212121);
    final glintPaint = Paint()..color = Colors.white;

    final watermelonSeeds = [
      Offset(w * 0.44, h * 0.42),
      Offset(w * 0.56, h * 0.46),
      Offset(w * 0.36, h * 0.58),
      Offset(w * 0.50, h * 0.60),
      Offset(w * 0.64, h * 0.56),
      Offset(w * 0.42, h * 0.72),
      Offset(w * 0.58, h * 0.70),
    ];

    for (final s in watermelonSeeds) {
      final sp = Path()
        ..moveTo(s.dx, s.dy - 3)
        ..cubicTo(s.dx + 2.2, s.dy, s.dx + 1.8, s.dy + 3.5, s.dx, s.dy + 3.5)
        ..cubicTo(s.dx - 1.8, s.dy + 3.5, s.dx - 2.2, s.dy, s.dx, s.dy - 3)
        ..close();
      canvas.drawPath(sp, seedPaint);
      canvas.drawCircle(Offset(s.dx + 0.8, s.dy), 0.6, glintPaint);
    }
  }

  // ===========================================================================
  // 6. REALISTIC GRAPES (Plum spherical berries cluster, powdery bloom, vine leaf)
  // ===========================================================================
  void _paintRealisticGrapes(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Vine stem
    final vinePath = Path()
      ..moveTo(w * 0.50, h * 0.24)
      ..lineTo(w * 0.52, h * 0.08)
      ..cubicTo(w * 0.65, h * 0.04, w * 0.72, h * 0.12, w * 0.78, h * 0.09);
    canvas.drawPath(
      vinePath,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // Vine leaf on right
    final leafPath = Path()
      ..moveTo(w * 0.52, h * 0.14)
      ..cubicTo(w * 0.72, h * 0.08, w * 0.85, h * 0.18, w * 0.82, h * 0.28)
      ..cubicTo(w * 0.68, h * 0.28, w * 0.56, h * 0.22, w * 0.52, h * 0.14)
      ..close();
    canvas.drawPath(
      leafPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
        ).createShader(Rect.fromLTWH(w * 0.5, h * 0.08, w * 0.35, h * 0.2)),
    );

    // Berry cluster coordinates: layered from back to front
    final berries = [
      // Top layer
      Offset(w * 0.36, h * 0.32), Offset(w * 0.50, h * 0.28), Offset(w * 0.64, h * 0.32),
      // Mid-top layer
      Offset(w * 0.28, h * 0.44), Offset(w * 0.42, h * 0.42), Offset(w * 0.58, h * 0.42), Offset(w * 0.72, h * 0.44),
      // Mid layer
      Offset(w * 0.34, h * 0.56), Offset(w * 0.50, h * 0.54), Offset(w * 0.66, h * 0.56),
      // Lower layer
      Offset(w * 0.40, h * 0.68), Offset(w * 0.60, h * 0.68),
      // Tip berry
      Offset(w * 0.50, h * 0.80),
    ];

    final berryRadius = w * 0.115;

    for (final b in berries) {
      final berryRect = Rect.fromCircle(center: b, radius: berryRadius);

      final berryShader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.85,
        colors: const [
          Color(0xFFBA68C8), // Light lavender highlight
          Color(0xFF8E24AA), // Royal purple
          Color(0xFF6A1B9A),
          Color(0xFF4A148C), // Deep plum shadow
        ],
      ).createShader(berryRect);

      canvas.drawCircle(b, berryRadius, Paint()..shader = berryShader);

      // Specular gleam
      canvas.drawCircle(
        Offset(b.dx - berryRadius * 0.35, b.dy - berryRadius * 0.35),
        berryRadius * 0.26,
        Paint()..color = Colors.white.withOpacity(0.55),
      );
    }
  }

  // ===========================================================================
  // 7. REALISTIC MANGO (Asymmetric Alphonso kidney teardrop, saffron & blush gradient)
  // ===========================================================================
  void _paintRealisticMango(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stem
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.48, h * 0.18), width: 3.5, height: 9),
      Paint()..color = const Color(0xFF4E342E),
    );

    // Anatomical mango curve (broad left shoulder, tapered curving beak tip)
    final mangoPath = Path();
    mangoPath.moveTo(w * 0.48, h * 0.22);
    mangoPath.cubicTo(w * 0.16, h * 0.24, w * 0.12, h * 0.62, w * 0.26, h * 0.84);
    mangoPath.cubicTo(w * 0.34, h * 0.95, w * 0.56, h * 0.98, w * 0.64, h * 0.88); // Beak tip curve
    mangoPath.cubicTo(w * 0.88, h * 0.74, w * 0.84, h * 0.36, w * 0.48, h * 0.22);
    mangoPath.close();

    final mangoShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF5252), // Rosy coral blush
        Color(0xFFFF7043),
        Color(0xFFFFB300), // Saffron gold
        Color(0xFFFFD54F),
        Color(0xFF81C784), // Soft green accent near stem
      ],
      stops: [0.0, 0.28, 0.58, 0.85, 1.0],
    ).createShader(Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.8, h * 0.8));

    canvas.drawPath(mangoPath, Paint()..shader = mangoShader);

    // Specular soft sheen
    final shinePath = Path()
      ..addOval(Rect.fromCenter(center: Offset(w * 0.38, h * 0.42), width: w * 0.32, height: h * 0.20));
    canvas.drawPath(
      shinePath,
      Paint()
        ..color = Colors.white.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );
  }

  // ===========================================================================
  // 8. REALISTIC CHERRY (Twin cordate glossy cherries, slender joined stems & leaf)
  // ===========================================================================
  void _paintRealisticCherry(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final leftCenter = Offset(w * 0.34, h * 0.74);
    final rightCenter = Offset(w * 0.68, h * 0.66);
    final cherryRadius = w * 0.22;

    // Slender twin curved stems
    final stemTop = Offset(w * 0.50, h * 0.12);
    final leftStem = Path()
      ..moveTo(leftCenter.dx, leftCenter.dy - cherryRadius * 0.75)
      ..cubicTo(leftCenter.dx - w * 0.05, h * 0.40, w * 0.42, h * 0.24, stemTop.dx, stemTop.dy);
    final rightStem = Path()
      ..moveTo(rightCenter.dx, rightCenter.dy - cherryRadius * 0.75)
      ..cubicTo(rightCenter.dx + w * 0.02, h * 0.38, w * 0.56, h * 0.22, stemTop.dx, stemTop.dy);

    final stemPaint = Paint()
      ..color = const Color(0xFF558B2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(leftStem, stemPaint);
    canvas.drawPath(rightStem, stemPaint);

    // Stem junction leaf
    final leafPath = Path()
      ..moveTo(stemTop.dx, stemTop.dy)
      ..cubicTo(w * 0.65, h * 0.06, w * 0.76, h * 0.12, w * 0.74, h * 0.20)
      ..cubicTo(w * 0.62, h * 0.22, w * 0.54, h * 0.16, stemTop.dx, stemTop.dy)
      ..close();
    canvas.drawPath(
      leafPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
        ).createShader(Rect.fromLTWH(w * 0.5, h * 0.06, w * 0.25, h * 0.16)),
    );

    // Left Cherry (Drawn first, behind)
    _drawSingleCherry(canvas, leftCenter, cherryRadius);

    // Right Cherry (Front)
    _drawSingleCherry(canvas, rightCenter, cherryRadius);
  }

  void _drawSingleCherry(Canvas canvas, Offset center, double radius) {
    // Cordate cherry path with indented top
    final p = Path();
    p.moveTo(center.dx, center.dy - radius * 0.75);
    p.cubicTo(center.dx - radius * 0.8, center.dy - radius * 1.1, center.dx - radius * 1.15, center.dy, center.dx - radius * 0.9, center.dy + radius * 0.75);
    p.cubicTo(center.dx - radius * 0.5, center.dy + radius * 1.1, center.dx, center.dy + radius * 0.95, center.dx, center.dy + radius * 0.95);
    p.cubicTo(center.dx, center.dy + radius * 0.95, center.dx + radius * 0.5, center.dy + radius * 1.1, center.dx + radius * 0.9, center.dy + radius * 0.75);
    p.cubicTo(center.dx + radius * 1.15, center.dy, center.dx + radius * 0.8, center.dy - radius * 1.1, center.dx, center.dy - radius * 0.75);
    p.close();

    final shader = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.85,
      colors: const [
        Color(0xFFFF5252), // Bright cherry shine
        Color(0xFFD50000), // Rich crimson
        Color(0xFF880E4F), // Deep wine
        Color(0xFF31000B), // Black cherry shadow
      ],
      stops: const [0.0, 0.40, 0.75, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(p, Paint()..shader = shader);

    // Specular brilliant gleam
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.35, center.dy - radius * 0.35), width: radius * 0.6, height: radius * 0.35),
      Paint()..color = Colors.white.withOpacity(0.70),
    );
  }

  @override
  bool shouldRepaint(covariant RealisticFruitPainter oldDelegate) {
    return oldDelegate.fruitKindId != fruitKindId || oldDelegate.isHighlighted != isHighlighted;
  }
}
