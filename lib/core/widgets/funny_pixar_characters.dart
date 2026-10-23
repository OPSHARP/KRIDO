import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Funny Pixar 3D Character Types for Kids Game Cards
enum FunnyCharacterType {
  dino,      // G001: 1-1000 Mosaic (Chubby turquoise dino with silly glasses)
  lion,      // G011: Learn ABCD (Goofy lion cub with crooked crown & tongue out)
  robot,     // G012: Alpha Grid (Bubbly retro robot with spring antenna & LED smile)
  alien,     // Purple 3-eyed cosmic alien with funny antennae
  monkey,    // G002: Count Apples (Hilarious monkey balancing apple on head)
  doggy,     // G051: Doggy Puzzle (Floppy-eared puppy with puzzle piece)
  monster,   // G031: Shape Match (Fluffy blue monster munching shape cookies)
  owl,       // G041: Memory Match (Chubby owl with huge spiral glasses)
  bunny,     // G072, G073: Word Builder & Spelling (Fluffy pink bunny with pencil)
  hippo,     // G074: Kid Math (Lavender baby hippo in bowtie doing math)
  chameleon, // G075: Pattern Path (Neon chameleon with mismatched googly eyes)
  djFrog,    // G076, G077: Animal Sounds & Quiz (Lime frog with giant pink headphones)
  penguin,   // G078: Rhyme Match (Tuxedo penguin singing in red bow tie)
  dragon,    // G079: Letter Trace (Cute baby purple dragon with rainbow crayon)
  rockBear,  // G080: Rainbow Xylo (Teddy bear with star sunglasses & mallets)
  kingLeo,   // STORYBOOK (Prince Leo with giant crown over one eye)
  beaver,    // WORLD_BUILDER (Funny beaver with yellow construction hardhat)
}

/// Helper to get character info (type, funny speech quote, mood color)
class FunnyCharacterInfo {
  final FunnyCharacterType type;
  final String name;
  final String speechQuote;
  final String tagBadge;

  const FunnyCharacterInfo({
    required this.type,
    required this.name,
    required this.speechQuote,
    required this.tagBadge,
  });

  static FunnyCharacterInfo forGameId(String gameId) {
    switch (gameId) {
      case 'G001':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.dino,
          name: 'Dino Digits',
          speechQuote: 'Can you find the next rock? 🦖',
          tagBadge: '🔢 NUMBERS',
        );
      case 'G011':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.lion,
          name: 'Sunny Leo',
          speechQuote: 'A, B, C... Sing with me! 🦁',
          tagBadge: '🔤 PHONICS',
        );
      case 'G012':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.robot,
          name: 'Beep-Boop Bot',
          speechQuote: 'Tap all the letters fast! 🤖',
          tagBadge: '🕹️ ABC GRID',
        );
      case 'G072':
      case 'G073':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.bunny,
          name: 'Barnaby Bunny',
          speechQuote: 'Spell words like a champ! 🐰',
          tagBadge: '✏️ SPELLING',
        );
      case 'G002':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.monkey,
          name: 'Chompy Monkey',
          speechQuote: 'Count my juicy apples! 🍎',
          tagBadge: '🌳 COUNTING',
        );
      case 'G051':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.doggy,
          name: 'Puzzle Pup',
          speechQuote: 'Woof! Put my picture together! 🐶',
          tagBadge: '🧩 JIGSAW',
        );
      case 'G031':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.monster,
          name: 'Shapey Monster',
          speechQuote: 'Circles & Stars are yummy! 👾',
          tagBadge: '⭐ SHAPES',
        );
      case 'G041':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.owl,
          name: 'Professor Hoot',
          speechQuote: 'Hoot! Remember the cards! 🦉',
          tagBadge: '🧠 MEMORY',
        );
      case 'G074':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.hippo,
          name: 'Hippo Einstein',
          speechQuote: '1 + 1 = Super Brainy! 🦛',
          tagBadge: '➕ KID MATH',
        );
      case 'G075':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.chameleon,
          name: 'Ziggy Chameleon',
          speechQuote: 'Follow the groovy colors! 🦎',
          tagBadge: '🌈 PATTERNS',
        );
      case 'G076':
      case 'G077':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.djFrog,
          name: 'DJ Froggy',
          speechQuote: 'Who makes that silly sound? 🎧',
          tagBadge: '🐾 ANIMALS',
        );
      case 'G078':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.penguin,
          name: 'Pippin Penguin',
          speechQuote: 'Cat rhymes with Hat! 🐧',
          tagBadge: '🎵 RHYMES',
        );
      case 'G079':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.dragon,
          name: 'Sparky Dragon',
          speechQuote: 'Trace with your magic finger! ✨',
          tagBadge: '🖍️ TRACING',
        );
      case 'G080':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.rockBear,
          name: 'Bongos Bear',
          speechQuote: 'Rock the rainbow xylophone! 🎶',
          tagBadge: '🎹 MUSIC',
        );
      case 'G081':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.monster,
          name: 'Color Sorter',
          speechQuote: 'Sort the bright toys into boxes! 🔴🔵',
          tagBadge: '🏭 FACTORY',
        );
      case 'G082':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.owl,
          name: 'Habitat Guide',
          speechQuote: 'Help animals find their home! 🐾🏠',
          tagBadge: '🌿 HABITATS',
        );
      case 'STORYBOOK':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.kingLeo,
          name: 'Story Prince Leo',
          speechQuote: 'Read me a bedtime tale! 👑',
          tagBadge: '📖 STORYBOOK',
        );
      case 'WORLD_BUILDER':
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.beaver,
          name: 'Builder Beaver',
          speechQuote: 'Build castles with stickers! 🏰',
          tagBadge: '🛠️ SANDBOX',
        );
      default:
        return const FunnyCharacterInfo(
          type: FunnyCharacterType.dino,
          name: 'Sparky Buddy',
          speechQuote: 'Let\'s play and discover! 🚀',
          tagBadge: '🎮 FUN GAME',
        );
    }
  }
}

/// A delightful, vector-rendered Funny Pixar 3D Character widget
/// Features:
/// - Chunky Pixar 3D toy-box cartoon proportions (big head, expressive eyes, cute accessories)
/// - Continuous subtle cartoon breathing & head tilt animation
/// - 3D radial highlights, glossy specular shines, and deep drop-shadows
class FunnyPixarCharacterWidget extends StatefulWidget {
  final FunnyCharacterType type;
  final double size;
  final bool animate;

  const FunnyPixarCharacterWidget({
    super.key,
    required this.type,
    this.size = 110,
    this.animate = true,
  });

  @override
  State<FunnyPixarCharacterWidget> createState() =>
      _FunnyPixarCharacterWidgetState();
}

class _FunnyPixarCharacterWidgetState extends State<FunnyPixarCharacterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.animate) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final t = _animController.value;
        // Comical head tilt & slight vertical breathing bob
        final bobY = math.sin(t * math.pi) * 3.5;
        final tilt = math.sin(t * math.pi * 2) * 0.04;

        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..translate(0.0, -bobY)
            ..rotateZ(tilt),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _FunnyPixarCharacterPainter(
              type: widget.type,
              animationValue: t,
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for funny Pixar characters with vibrant cartoon 3D details
class _FunnyPixarCharacterPainter extends CustomPainter {
  final FunnyCharacterType type;
  final double animationValue;

  _FunnyPixarCharacterPainter({
    required this.type,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground soft ambient shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.94),
        width: w * 0.72,
        height: h * 0.16,
      ),
      shadowPaint,
    );

    switch (type) {
      case FunnyCharacterType.dino:
        _paintDino(canvas, size);
        break;
      case FunnyCharacterType.lion:
      case FunnyCharacterType.kingLeo:
        _paintLion(canvas, size, isKing: type == FunnyCharacterType.kingLeo);
        break;
      case FunnyCharacterType.robot:
        _paintRobot(canvas, size);
        break;
      case FunnyCharacterType.alien:
        _paintAlien(canvas, size);
        break;
      case FunnyCharacterType.monkey:
        _paintMonkey(canvas, size);
        break;
      case FunnyCharacterType.doggy:
        _paintDoggy(canvas, size);
        break;
      case FunnyCharacterType.monster:
        _paintMonster(canvas, size);
        break;
      case FunnyCharacterType.owl:
        _paintOwl(canvas, size);
        break;
      case FunnyCharacterType.bunny:
        _paintBunny(canvas, size);
        break;
      case FunnyCharacterType.hippo:
        _paintHippo(canvas, size);
        break;
      case FunnyCharacterType.chameleon:
        _paintChameleon(canvas, size);
        break;
      case FunnyCharacterType.djFrog:
        _paintFrog(canvas, size);
        break;
      case FunnyCharacterType.penguin:
        _paintPenguin(canvas, size);
        break;
      case FunnyCharacterType.dragon:
        _paintDragon(canvas, size);
        break;
      case FunnyCharacterType.rockBear:
        _paintBear(canvas, size);
        break;
      case FunnyCharacterType.beaver:
        _paintBeaver(canvas, size);
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // 1. DINO: Turquoise T-Rex with oversized yellow silly glasses & toothy grin
  // ---------------------------------------------------------------------------
  void _paintDino(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body / Head (Chubby pear shape)
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.76, height: h * 0.72);
    final dinoPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        colors: [Color(0xFF80DEEA), Color(0xFF26C6DA), Color(0xFF00838F)],
        stops: [0.0, 0.65, 1.0],
      ).createShader(headRect);
    canvas.drawOval(headRect, dinoPaint);

    // Cute Back Spikes (Orange spikes)
    for (int i = 0; i < 3; i++) {
      final spikeY = h * (0.28 + i * 0.15);
      final spikePath = Path()
        ..moveTo(w * 0.15, spikeY)
        ..lineTo(w * 0.04, spikeY + h * 0.05)
        ..lineTo(w * 0.15, spikeY + h * 0.10)
        ..close();
      canvas.drawPath(spikePath, Paint()..color = const Color(0xFFFF7043));
    }

    // Top glossy highlight
    _drawGlossHighlight(canvas, Offset(w * 0.5, h * 0.30), w * 0.45, h * 0.20);

    // Cute Chubby Snout
    final snoutRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.55, height: h * 0.32);
    final snoutPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.2),
        colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
      ).createShader(snoutRect);
    canvas.drawOval(snoutRect, snoutPaint);

    // Wide Happy Toothy Smile
    final smilePath = Path()
      ..moveTo(w * 0.32, h * 0.66)
      ..quadraticBezierTo(w * 0.5, h * 0.82, w * 0.68, h * 0.66);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF006064)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Two little cartoon teeth sticking out
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.42, h * 0.67, w * 0.06, h * 0.05), const Radius.circular(2)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.52, h * 0.67, w * 0.06, h * 0.05), const Radius.circular(2)), Paint()..color = Colors.white);

    // Oversized Yellow Goofy Glasses Frames
    final glassPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(Offset(w * 0.36, h * 0.44), w * 0.16, glassPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.44), w * 0.16, glassPaint);
    // Glasses bridge
    canvas.drawLine(Offset(w * 0.48, h * 0.44), Offset(w * 0.52, h * 0.44), glassPaint);

    // Pixar Kawaii Eyes inside glasses
    _drawPixarEye(canvas, Offset(w * 0.36, h * 0.44), size, r: w * 0.11);
    _drawPixarEye(canvas, Offset(w * 0.64, h * 0.44), size, r: w * 0.11);

    // Tiny clappy hands at bottom
    _drawCutePaw(canvas, Offset(w * 0.34, h * 0.78), w * 0.10, isLeft: true);
    _drawCutePaw(canvas, Offset(w * 0.66, h * 0.78), w * 0.10, isLeft: false);
  }

  // ---------------------------------------------------------------------------
  // 2. LION / KING LEO: Warm golden cub with fluffy jigsaw mane & tilted crown
  // ---------------------------------------------------------------------------
  void _paintLion(Canvas canvas, Size size, {bool isKing = false}) {
    final w = size.width;
    final h = size.height;

    // Fluffy Mane (Sunburst petals)
    final manePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFB300), Color(0xFFE65100)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * math.pi / 12);
      final r = w * 0.42;
      final px = w * 0.5 + r * math.cos(angle);
      final py = h * 0.52 + r * math.sin(angle);
      canvas.drawCircle(Offset(px, py), w * 0.14, manePaint);
    }

    // Head Sphere
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.68, height: h * 0.64);
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        colors: [Color(0xFFFFE082), Color(0xFFFFCA28), Color(0xFFFFA000)],
      ).createShader(headRect);
    canvas.drawOval(headRect, headPaint);

    // Cute Ears
    canvas.drawCircle(Offset(w * 0.24, h * 0.30), w * 0.10, Paint()..color = const Color(0xFFFFA000));
    canvas.drawCircle(Offset(w * 0.24, h * 0.30), w * 0.06, Paint()..color = const Color(0xFFFFD180));
    canvas.drawCircle(Offset(w * 0.76, h * 0.30), w * 0.10, Paint()..color = const Color(0xFFFFA000));
    canvas.drawCircle(Offset(w * 0.76, h * 0.30), w * 0.06, Paint()..color = const Color(0xFFFFD180));

    // Gloss
    _drawGlossHighlight(canvas, Offset(w * 0.5, h * 0.34), w * 0.40, h * 0.18);

    // White Muzzle
    final muzzleRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.66), width: w * 0.40, height: h * 0.28);
    canvas.drawOval(muzzleRect, Paint()..color = const Color(0xFFFFF8E1));

    // Nose (Brown cute heart/triangle)
    final nosePath = Path()
      ..moveTo(w * 0.45, h * 0.60)
      ..lineTo(w * 0.55, h * 0.60)
      ..lineTo(w * 0.50, h * 0.66)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFF5D4037));

    // Smile with cute pink tongue sticking out!
    final mouthPath = Path()
      ..moveTo(w * 0.40, h * 0.68)
      ..quadraticBezierTo(w * 0.50, h * 0.80, w * 0.60, h * 0.68);
    canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);

    // Tongue
    final tongueRect = Rect.fromCenter(center: Offset(w * 0.53, h * 0.74), width: w * 0.10, height: h * 0.08);
    canvas.drawOval(tongueRect, Paint()..color = const Color(0xFFFF4081));

    // Big Kawaii Eyes
    _drawPixarEye(canvas, Offset(w * 0.38, h * 0.50), size, r: w * 0.095);
    _drawPixarEye(canvas, Offset(w * 0.62, h * 0.50), size, r: w * 0.095);

    // Crooked Royal Crown tilted playfully over left ear
    canvas.save();
    canvas.translate(w * 0.42, h * 0.20);
    canvas.rotate(-0.25);
    _drawCartoonCrown(canvas, w * 0.36, h * 0.22);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // 3. ROBOT: Candy-blue retro bubble robot with spring antenna & LED smile
  // ---------------------------------------------------------------------------
  void _paintRobot(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Spring Antenna
    final antennaPath = Path()
      ..moveTo(w * 0.5, h * 0.22)
      ..lineTo(w * 0.5, h * 0.12);
    canvas.drawPath(antennaPath, Paint()..color = const Color(0xFF78909C)..style = PaintingStyle.stroke..strokeWidth = 4);
    // Glowing red beacon ball at top
    canvas.drawCircle(Offset(w * 0.5, h * 0.10), w * 0.07, Paint()..color = const Color(0xFFFF5252));
    canvas.drawCircle(Offset(w * 0.48, h * 0.08), w * 0.02, Paint()..color = Colors.white);

    // Robot Head Box (Rounded 3D square)
    final headRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.72, height: h * 0.60),
      const Radius.circular(24),
    );
    final botPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFF81D4FA), Color(0xFF29B6F6), Color(0xFF0277BD)],
      ).createShader(headRRect.outerRect);
    canvas.drawRRect(headRRect, botPaint);

    // Bolt Ears
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.08, h * 0.46, w * 0.08, h * 0.12), const Radius.circular(4)), Paint()..color = const Color(0xFFFFD54F));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.84, h * 0.46, w * 0.08, h * 0.12), const Radius.circular(4)), Paint()..color = const Color(0xFFFFD54F));

    // Dark Visor Screen
    final visorRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.48), width: w * 0.56, height: h * 0.32),
      const Radius.circular(16),
    );
    canvas.drawRRect(visorRRect, Paint()..color = const Color(0xFF0F172A));

    // Two big blinking LED eyes (Cyan glow)
    canvas.drawCircle(Offset(w * 0.39, h * 0.48), w * 0.09, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(w * 0.37, h * 0.46), w * 0.03, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.61, h * 0.48), w * 0.09, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(w * 0.59, h * 0.46), w * 0.03, Paint()..color = Colors.white);

    // Pixel LED Smile
    final smilePath = Path()
      ..moveTo(w * 0.38, h * 0.70)
      ..lineTo(w * 0.44, h * 0.75)
      ..lineTo(w * 0.56, h * 0.75)
      ..lineTo(w * 0.62, h * 0.70);
    canvas.drawPath(smilePath, Paint()..color = const Color(0xFF69F0AE)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  // ---------------------------------------------------------------------------
  // 4. ALIEN: Purple 3-eyed cosmic creature with wiggly antennas
  // ---------------------------------------------------------------------------
  void _paintAlien(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Two wiggly antennae
    canvas.drawLine(Offset(w * 0.35, h * 0.28), Offset(w * 0.24, h * 0.14), Paint()..color = const Color(0xFF7E57C2)..strokeWidth = 4);
    canvas.drawCircle(Offset(w * 0.24, h * 0.14), w * 0.06, Paint()..color = const Color(0xFFFF4081));

    canvas.drawLine(Offset(w * 0.65, h * 0.28), Offset(w * 0.76, h * 0.14), Paint()..color = const Color(0xFF7E57C2)..strokeWidth = 4);
    canvas.drawCircle(Offset(w * 0.76, h * 0.14), w * 0.06, Paint()..color = const Color(0xFFFF4081));

    // Head (Squishy dome)
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.74, height: h * 0.64);
    final alienPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.3),
        colors: [Color(0xFFE1BEE7), Color(0xFFAB47BC), Color(0xFF6A1B9A)],
      ).createShader(headRect);
    canvas.drawOval(headRect, alienPaint);

    // 3 Hilarious Googly Eyes! (Center eye is larger at top)
    _drawPixarEye(canvas, Offset(w * 0.50, h * 0.40), size, r: w * 0.11);
    _drawPixarEye(canvas, Offset(w * 0.32, h * 0.52), size, r: w * 0.09);
    _drawPixarEye(canvas, Offset(w * 0.68, h * 0.52), size, r: w * 0.09);

    // Big Goofy Open Mouth with tiny alien tooth
    final mouthRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.70), width: w * 0.34, height: h * 0.18);
    canvas.drawOval(mouthRect, Paint()..color = const Color(0xFF311B92));
    // Pink tongue
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.75), width: w * 0.22, height: h * 0.10), Paint()..color = const Color(0xFFFF4081));
  }

  // ---------------------------------------------------------------------------
  // 5. MONKEY: Hilarious monkey with apple balanced on head
  // ---------------------------------------------------------------------------
  void _paintMonkey(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Big Round Ears
    canvas.drawCircle(Offset(w * 0.16, h * 0.50), w * 0.15, Paint()..color = const Color(0xFF6D4C41));
    canvas.drawCircle(Offset(w * 0.16, h * 0.50), w * 0.09, Paint()..color = const Color(0xFFFFCCBC));
    canvas.drawCircle(Offset(w * 0.84, h * 0.50), w * 0.15, Paint()..color = const Color(0xFF6D4C41));
    canvas.drawCircle(Offset(w * 0.84, h * 0.50), w * 0.09, Paint()..color = const Color(0xFFFFCCBC));

    // Head
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.66, height: h * 0.58);
    canvas.drawOval(headRect, Paint()..color = const Color(0xFF6D4C41));

    // Peach Face Mask (Heart-ish mask)
    final faceRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.54, height: h * 0.44);
    canvas.drawOval(faceRect, Paint()..color = const Color(0xFFFFCCBC));

    // Red Apple balanced playfully on head!
    final appleRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: w * 0.32, height: h * 0.28);
    final applePaint = Paint()..shader = const RadialGradient(colors: [Color(0xFFFF5252), Color(0xFFC62828)]).createShader(appleRect);
    canvas.drawOval(appleRect, applePaint);
    // Apple leaf
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.54, h * 0.10), width: w * 0.10, height: h * 0.06), Paint()..color = const Color(0xFF4CAF50));

    // Eyes: One winking eye, one open eye!
    _drawPixarEye(canvas, Offset(w * 0.39, h * 0.48), size, r: w * 0.085);
    // Winking eye
    final winkPath = Path()
      ..moveTo(w * 0.55, h * 0.50)
      ..quadraticBezierTo(w * 0.63, h * 0.42, w * 0.71, h * 0.50);
    canvas.drawPath(winkPath, Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round);

    // Wide monkey smile
    final smilePath = Path()
      ..moveTo(w * 0.38, h * 0.64)
      ..quadraticBezierTo(w * 0.50, h * 0.76, w * 0.62, h * 0.64);
    canvas.drawPath(smilePath, Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round);
  }

  // ---------------------------------------------------------------------------
  // 6. DOGGY: Caramel puppy with floppy ears & puzzle piece in mouth
  // ---------------------------------------------------------------------------
  void _paintDoggy(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Floppy Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.18, h * 0.54), width: w * 0.22, height: h * 0.48), Paint()..color = const Color(0xFF8D6E63));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.82, h * 0.54), width: w * 0.22, height: h * 0.48), Paint()..color = const Color(0xFF8D6E63));

    // Head
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.50), width: w * 0.68, height: h * 0.60);
    canvas.drawOval(headRect, Paint()..shader = const RadialGradient(colors: [Color(0xFFFFCC80), Color(0xFFFFA726)]).createShader(headRect));

    // White snout
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.42, height: h * 0.28), Paint()..color = Colors.white);
    // Black nose
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.14, height: h * 0.09), Paint()..color = const Color(0xFF212121));

    // Eyes
    _drawPixarEye(canvas, Offset(w * 0.38, h * 0.44), size, r: w * 0.09);
    _drawPixarEye(canvas, Offset(w * 0.62, h * 0.44), size, r: w * 0.09);

    // Shiny Blue Puzzle piece held in mouth!
    final puzzleRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.74), width: w * 0.26, height: h * 0.18);
    canvas.drawRRect(RRect.fromRectAndRadius(puzzleRect, const Radius.circular(8)), Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(w * 0.5, h * 0.68), w * 0.05, Paint()..color = const Color(0xFF00E5FF));
  }

  // ---------------------------------------------------------------------------
  // 7. MONSTER: Fluffy blue monster with funny horns
  // ---------------------------------------------------------------------------
  void _paintMonster(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Striped Candy Horns
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.26, h * 0.22), width: w * 0.12, height: h * 0.22), Paint()..color = const Color(0xFFFFD54F));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.74, h * 0.22), width: w * 0.12, height: h * 0.22), Paint()..color = const Color(0xFFFFD54F));

    // Fluffy Body
    final bodyRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.76, height: h * 0.66);
    canvas.drawOval(bodyRect, Paint()..shader = const RadialGradient(colors: [Color(0xFF81D4FA), Color(0xFF0288D1)]).createShader(bodyRect));

    // Two big silly eyes
    _drawPixarEye(canvas, Offset(w * 0.37, h * 0.42), size, r: w * 0.12);
    _drawPixarEye(canvas, Offset(w * 0.63, h * 0.42), size, r: w * 0.12);

    // Big happy open mouth with cute single tooth
    final mouthRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.42, height: h * 0.22);
    canvas.drawOval(mouthRect, Paint()..color = const Color(0xFF01579B));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.46, h * 0.60, w * 0.08, h * 0.06), const Radius.circular(3)), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.75), width: w * 0.24, height: h * 0.10), Paint()..color = const Color(0xFFFF4081));
  }

  // ---------------------------------------------------------------------------
  // 8. OWL: Chubby owl with huge spiral hypnotic glasses
  // ---------------------------------------------------------------------------
  void _paintOwl(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.72, height: h * 0.68);
    canvas.drawOval(bodyRect, Paint()..shader = const RadialGradient(colors: [Color(0xFFBCAAA4), Color(0xFF5D4037)]).createShader(bodyRect));

    // Ear Tufts
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.28, h * 0.22), width: w * 0.14, height: h * 0.20), Paint()..color = const Color(0xFF4E342E));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.72, h * 0.22), width: w * 0.14, height: h * 0.20), Paint()..color = const Color(0xFF4E342E));

    // White eye rings
    canvas.drawCircle(Offset(w * 0.36, h * 0.46), w * 0.18, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.64, h * 0.46), w * 0.18, Paint()..color = Colors.white);

    // Spiral Cartoon Eyes!
    _drawSpiralEye(canvas, Offset(w * 0.36, h * 0.46), w * 0.14);
    _drawSpiralEye(canvas, Offset(w * 0.64, h * 0.46), w * 0.14);

    // Cute Orange Beak
    final beakPath = Path()
      ..moveTo(w * 0.44, h * 0.58)
      ..lineTo(w * 0.56, h * 0.58)
      ..lineTo(w * 0.50, h * 0.68)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = const Color(0xFFFF9800));
  }

  // ---------------------------------------------------------------------------
  // 9. BUNNY: Fluffy pink bunny with floppy ears & graduation cap
  // ---------------------------------------------------------------------------
  void _paintBunny(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Long Bunny Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.32, h * 0.20), width: w * 0.16, height: h * 0.38), Paint()..color = const Color(0xFFF8BBD0));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.32, h * 0.20), width: w * 0.08, height: h * 0.26), Paint()..color = const Color(0xFFFF4081));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.68, h * 0.20), width: w * 0.16, height: h * 0.38), Paint()..color = const Color(0xFFF8BBD0));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.68, h * 0.20), width: w * 0.08, height: h * 0.26), Paint()..color = const Color(0xFFFF4081));

    // Head
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.70, height: h * 0.58);
    canvas.drawOval(headRect, Paint()..shader = const RadialGradient(colors: [Color(0xFFFFF0F5), Color(0xFFF48FB1)]).createShader(headRect));

    // Eyes
    _drawPixarEye(canvas, Offset(w * 0.38, h * 0.50), size, r: w * 0.09);
    _drawPixarEye(canvas, Offset(w * 0.62, h * 0.50), size, r: w * 0.09);

    // Pink nose & whiskers
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.09, height: h * 0.06), Paint()..color = const Color(0xFFE91E63));
    canvas.drawLine(Offset(w * 0.20, h * 0.62), Offset(w * 0.36, h * 0.63), Paint()..color = const Color(0xFFAD1457)..strokeWidth = 2);
    canvas.drawLine(Offset(w * 0.80, h * 0.62), Offset(w * 0.64, h * 0.63), Paint()..color = const Color(0xFFAD1457)..strokeWidth = 2);

    // Cute buck teeth
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.44, h * 0.68, w * 0.05, h * 0.06), const Radius.circular(2)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.51, h * 0.68, w * 0.05, h * 0.06), const Radius.circular(2)), Paint()..color = Colors.white);
  }

  // ---------------------------------------------------------------------------
  // 10. HIPPO: Lavender baby hippo in bowtie
  // ---------------------------------------------------------------------------
  void _paintHippo(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Small Ears
    canvas.drawCircle(Offset(w * 0.24, h * 0.28), w * 0.08, Paint()..color = const Color(0xFF9575CD));
    canvas.drawCircle(Offset(w * 0.76, h * 0.28), w * 0.08, Paint()..color = const Color(0xFF9575CD));

    // Head
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.50), width: w * 0.68, height: h * 0.54);
    canvas.drawOval(headRect, Paint()..shader = const RadialGradient(colors: [Color(0xFFD1C4E9), Color(0xFF7E57C2)]).createShader(headRect));

    // Big Chubby Hippo Muzzle
    final muzzleRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.66), width: w * 0.62, height: h * 0.34);
    canvas.drawOval(muzzleRect, Paint()..color = const Color(0xFFEDE7F6));

    // Nostrils
    canvas.drawCircle(Offset(w * 0.40, h * 0.60), w * 0.05, Paint()..color = const Color(0xFF512DA8));
    canvas.drawCircle(Offset(w * 0.60, h * 0.60), w * 0.05, Paint()..color = const Color(0xFF512DA8));

    // Eyes
    _drawPixarEye(canvas, Offset(w * 0.38, h * 0.42), size, r: w * 0.08);
    _drawPixarEye(canvas, Offset(w * 0.62, h * 0.42), size, r: w * 0.08);

    // Red Bow Tie at neck
    final bowTiePath = Path()
      ..moveTo(w * 0.38, h * 0.84)
      ..lineTo(w * 0.62, h * 0.94)
      ..lineTo(w * 0.62, h * 0.84)
      ..lineTo(w * 0.38, h * 0.94)
      ..close();
    canvas.drawPath(bowTiePath, Paint()..color = const Color(0xFFFF1744));
    canvas.drawCircle(Offset(w * 0.5, h * 0.89), w * 0.05, Paint()..color = const Color(0xFFFF5252));
  }

  // ---------------------------------------------------------------------------
  // 11. CHAMELEON: Neon green with mismatched rotating eyes
  // ---------------------------------------------------------------------------
  void _paintChameleon(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.74, height: h * 0.62);
    canvas.drawOval(bodyRect, Paint()..shader = const RadialGradient(colors: [Color(0xFFB9F6CA), Color(0xFF00E676), Color(0xFF00897B)]).createShader(bodyRect));

    // Head crest
    final crestPath = Path()
      ..moveTo(w * 0.35, h * 0.28)
      ..quadraticBezierTo(w * 0.50, h * 0.12, w * 0.65, h * 0.28);
    canvas.drawPath(crestPath, Paint()..color = const Color(0xFF00C853)..style = PaintingStyle.fill);

    // Mismatched Googly Turret Eyes (One looking up-left, one looking down-right!)
    _drawTurretEye(canvas, Offset(w * 0.35, h * 0.44), w * 0.15, lookAngle: -0.8);
    _drawTurretEye(canvas, Offset(w * 0.65, h * 0.44), w * 0.15, lookAngle: 1.2);

    // Curled Party Tongue
    final tonguePath = Path()
      ..moveTo(w * 0.5, h * 0.70)
      ..cubicTo(w * 0.55, h * 0.80, w * 0.70, h * 0.75, w * 0.65, h * 0.65);
    canvas.drawPath(tonguePath, Paint()..color = const Color(0xFFFF4081)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  // ---------------------------------------------------------------------------
  // 12. FROG: Lime frog with giant pink DJ headphones
  // ---------------------------------------------------------------------------
  void _paintFrog(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Giant Pink Headphones Headband
    final bandPath = Path()
      ..moveTo(w * 0.12, h * 0.48)
      ..cubicTo(w * 0.15, h * 0.12, w * 0.85, h * 0.12, w * 0.88, h * 0.48);
    canvas.drawPath(bandPath, Paint()..color = const Color(0xFFE91E63)..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round);

    // Headphone Ear Cushions
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.14, h * 0.50), width: w * 0.14, height: h * 0.24), const Radius.circular(8)), Paint()..color = const Color(0xFFFF4081));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.86, h * 0.50), width: w * 0.14, height: h * 0.24), const Radius.circular(8)), Paint()..color = const Color(0xFFFF4081));

    // Frog Bulbous Eyes on top
    canvas.drawCircle(Offset(w * 0.35, h * 0.34), w * 0.16, Paint()..color = const Color(0xFF76FF03));
    canvas.drawCircle(Offset(w * 0.65, h * 0.34), w * 0.16, Paint()..color = const Color(0xFF76FF03));

    // Frog Head (Wide oval)
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.58), width: w * 0.68, height: h * 0.52);
    canvas.drawOval(headRect, Paint()..shader = const RadialGradient(colors: [Color(0xFFCCFF90), Color(0xFF76FF03), Color(0xFF43A047)]).createShader(headRect));

    // Eyes
    _drawPixarEye(canvas, Offset(w * 0.35, h * 0.34), size, r: w * 0.11);
    _drawPixarEye(canvas, Offset(w * 0.65, h * 0.34), size, r: w * 0.11);

    // Huge Grinning Frog Mouth
    final mouthPath = Path()
      ..moveTo(w * 0.28, h * 0.62)
      ..quadraticBezierTo(w * 0.50, h * 0.82, w * 0.72, h * 0.62);
    canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF1B5E20)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  // ---------------------------------------------------------------------------
  // 13. PENGUIN: Tuxedo penguin in red bow tie
  // ---------------------------------------------------------------------------
  void _paintPenguin(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body (Black egg)
    final bodyRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.68, height: h * 0.68);
    canvas.drawOval(bodyRect, Paint()..color = const Color(0xFF263238));

    // White belly
    final bellyRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.58), width: w * 0.48, height: h * 0.54);
    canvas.drawOval(bellyRect, Paint()..color = Colors.white);

    // Eyes
    _drawPixarEye(canvas, Offset(w * 0.39, h * 0.44), size, r: w * 0.085);
    _drawPixarEye(canvas, Offset(w * 0.61, h * 0.44), size, r: w * 0.085);

    // Beak (Singing wide open!)
    final beakPath = Path()
      ..moveTo(w * 0.44, h * 0.54)
      ..lineTo(w * 0.56, h * 0.54)
      ..lineTo(w * 0.50, h * 0.64)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = const Color(0xFFFF9800));

    // Red Bowtie
    canvas.drawCircle(Offset(w * 0.5, h * 0.74), w * 0.04, Paint()..color = const Color(0xFFFF1744));
    canvas.drawPath(Path()..moveTo(w * 0.42, h * 0.72)..lineTo(w * 0.58, h * 0.78)..lineTo(w * 0.58, h * 0.72)..lineTo(w * 0.42, h * 0.78)..close(), Paint()..color = const Color(0xFFFF1744));
  }

  // ---------------------------------------------------------------------------
  // 14. DRAGON: Baby purple dragon with rainbow crayon
  // ---------------------------------------------------------------------------
  void _paintDragon(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tiny wings
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.18, h * 0.44), width: w * 0.18, height: h * 0.28), Paint()..color = const Color(0xFFFF80AB));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.82, h * 0.44), width: w * 0.18, height: h * 0.28), Paint()..color = const Color(0xFFFF80AB));

    // Head
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.72, height: h * 0.62);
    canvas.drawOval(headRect, Paint()..shader = const RadialGradient(colors: [Color(0xFFEA80FC), Color(0xFFAA00FF)]).createShader(headRect));

    // Golden horns
    canvas.drawPath(Path()..moveTo(w * 0.32, h * 0.28)..lineTo(w * 0.24, h * 0.16)..lineTo(w * 0.38, h * 0.24)..close(), Paint()..color = const Color(0xFFFFD54F));
    canvas.drawPath(Path()..moveTo(w * 0.68, h * 0.28)..lineTo(w * 0.76, h * 0.16)..lineTo(w * 0.62, h * 0.24)..close(), Paint()..color = const Color(0xFFFFD54F));

    // Eyes
    _drawPixarEye(canvas, Offset(w * 0.38, h * 0.46), size, r: w * 0.095);
    _drawPixarEye(canvas, Offset(w * 0.62, h * 0.46), size, r: w * 0.095);

    // Glowing Rainbow Crayon held in hands
    final crayonRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.72), width: w * 0.38, height: h * 0.10);
    canvas.drawRRect(RRect.fromRectAndRadius(crayonRect, const Radius.circular(5)), Paint()..shader = const LinearGradient(colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue]).createShader(crayonRect));
  }

  // ---------------------------------------------------------------------------
  // 15. BEAR: Golden honey teddy bear with star sunglasses & mallets
  // ---------------------------------------------------------------------------
  void _paintBear(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ears
    canvas.drawCircle(Offset(w * 0.22, h * 0.30), w * 0.12, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawCircle(Offset(w * 0.22, h * 0.30), w * 0.07, Paint()..color = const Color(0xFFFFCCBC));
    canvas.drawCircle(Offset(w * 0.78, h * 0.30), w * 0.12, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawCircle(Offset(w * 0.78, h * 0.30), w * 0.07, Paint()..color = const Color(0xFFFFCCBC));

    // Head
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.72, height: h * 0.62);
    canvas.drawOval(headRect, Paint()..shader = const RadialGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFF57C00)]).createShader(headRect));

    // Star Sunglasses!
    _drawStarGlasses(canvas, Offset(w * 0.36, h * 0.46), w * 0.16);
    _drawStarGlasses(canvas, Offset(w * 0.64, h * 0.46), w * 0.16);
    canvas.drawLine(Offset(w * 0.48, h * 0.46), Offset(w * 0.52, h * 0.46), Paint()..color = const Color(0xFFFF1744)..strokeWidth = 4);

    // Muzzle & nose
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.66), width: w * 0.36, height: h * 0.22), Paint()..color = const Color(0xFFFFF9C4));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.12, height: h * 0.08), Paint()..color = const Color(0xFF3E2723));

    // Smile
    canvas.drawPath(Path()..moveTo(w * 0.44, h * 0.68)..quadraticBezierTo(w * 0.5, h * 0.75, w * 0.56, h * 0.68), Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
  }

  // ---------------------------------------------------------------------------
  // 16. BEAVER: Beaver with yellow construction hardhat
  // ---------------------------------------------------------------------------
  void _paintBeaver(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Head
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.70, height: h * 0.58);
    canvas.drawOval(headRect, Paint()..color = const Color(0xFF795548));

    // Yellow Construction Hardhat at top!
    final hatRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.30), width: w * 0.68, height: h * 0.30);
    canvas.drawOval(hatRect, Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.5, h * 0.38), width: w * 0.76, height: h * 0.08), const Radius.circular(4)), Paint()..color = const Color(0xFFFDD835));

    // Eyes
    _drawPixarEye(canvas, Offset(w * 0.38, h * 0.50), size, r: w * 0.085);
    _drawPixarEye(canvas, Offset(w * 0.62, h * 0.50), size, r: w * 0.085);

    // Big Buck Teeth!
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.30, height: h * 0.18), Paint()..color = const Color(0xFFD7CCC8));
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.59), width: w * 0.12, height: h * 0.07), Paint()..color = const Color(0xFF3E2723));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.44, h * 0.67, w * 0.05, h * 0.08), const Radius.circular(2)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.51, h * 0.67, w * 0.05, h * 0.08), const Radius.circular(2)), Paint()..color = Colors.white);
  }

  // ===========================================================================
  // SHARED PIXAR DRAWING UTILITIES
  // ===========================================================================

  void _drawPixarEye(Canvas canvas, Offset center, Size size, {required double r}) {
    // Sclera (White eye background)
    canvas.drawCircle(center, r, Paint()..color = Colors.white);

    // Dark Iris (Glossy cartoon dark pupil)
    canvas.drawCircle(center, r * 0.72, Paint()..color = const Color(0xFF1E293B));

    // Specular Highlight #1 (Big glint top-left)
    canvas.drawCircle(
      Offset(center.dx - r * 0.28, center.dy - r * 0.28),
      r * 0.28,
      Paint()..color = Colors.white,
    );

    // Specular Highlight #2 (Small glint bottom-right)
    canvas.drawCircle(
      Offset(center.dx + r * 0.22, center.dy + r * 0.22),
      r * 0.14,
      Paint()..color = Colors.white.withOpacity(0.9),
    );
  }

  void _drawSpiralEye(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF1A237E));
    final spiralPath = Path();
    for (double theta = 0; theta < 4 * math.pi; theta += 0.2) {
      final rad = (theta / (4 * math.pi)) * r * 0.8;
      final x = center.dx + rad * math.cos(theta);
      final y = center.dy + rad * math.sin(theta);
      if (theta == 0) {
        spiralPath.moveTo(x, y);
      } else {
        spiralPath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      spiralPath,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawTurretEye(Canvas canvas, Offset center, double r, {required double lookAngle}) {
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFE8F5E9));
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF2E7D32)..style = PaintingStyle.stroke..strokeWidth = 3);
    final pupilX = center.dx + (r * 0.4) * math.cos(lookAngle);
    final pupilY = center.dy + (r * 0.4) * math.sin(lookAngle);
    canvas.drawCircle(Offset(pupilX, pupilY), r * 0.45, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(Offset(pupilX - r * 0.15, pupilY - r * 0.15), r * 0.18, Paint()..color = Colors.white);
  }

  void _drawStarGlasses(Canvas canvas, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final double angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF1744)..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  void _drawGlossHighlight(Canvas canvas, Offset center, double w, double h) {
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.0)],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  void _drawCutePaw(Canvas canvas, Offset center, double size, {required bool isLeft}) {
    canvas.drawCircle(center, size, Paint()..color = const Color(0xFF00838F));
    canvas.drawCircle(center, size * 0.6, Paint()..color = const Color(0xFFB2EBF2));
  }

  void _drawCartoonCrown(Canvas canvas, double w, double h) {
    final crownPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.3)
      ..lineTo(w * 0.25, h * 0.6)
      ..lineTo(w * 0.5, 0)
      ..lineTo(w * 0.75, h * 0.6)
      ..lineTo(w, h * 0.3)
      ..lineTo(w, h)
      ..close();

    final crownPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(crownPath, crownPaint);
    canvas.drawPath(crownPath, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

    // Crown jewels
    canvas.drawCircle(Offset(0, h * 0.3), 3.5, Paint()..color = const Color(0xFFFF1744));
    canvas.drawCircle(Offset(w * 0.5, 0), 4.5, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(w, h * 0.3), 3.5, Paint()..color = const Color(0xFF76FF03));
  }

  @override
  bool shouldRepaint(covariant _FunnyPixarCharacterPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.animationValue != animationValue;
  }
}
