import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g002_controller.dart';
import 'realistic_fruit_painter.dart';

class G002View extends StatefulWidget {
  final G002Controller controller;

  const G002View({super.key, required this.controller});

  @override
  State<G002View> createState() => _G002ViewState();
}

class _G002ViewState extends State<G002View> with SingleTickerProviderStateMixin {
  int _autoAdvanceCountdown = 2;
  Timer? _autoAdvanceTimer;
  Timer? _countdownTicker;
  late AnimationController _treeWobbleAnim;
  late Animation<double> _treeWobbleAngle;

  @override
  void initState() {
    super.initState();
    _treeWobbleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _treeWobbleAngle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.04), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.04, end: 0.04), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.04, end: -0.02), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.02, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _treeWobbleAnim, curve: Curves.easeInOut));

    widget.controller.addListener(_onControllerState);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _countdownTicker?.cancel();
    widget.controller.removeListener(_onControllerState);
    _treeWobbleAnim.dispose();
    super.dispose();
  }

  void _onControllerState() {
    if (widget.controller.state == GameLifecycleState.completed && _autoAdvanceTimer == null) {
      _startAutoAdvance();
    }
    if (mounted) setState(() {});
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _countdownTicker?.cancel();
    setState(() {
      _autoAdvanceCountdown = 2;
    });

    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _autoAdvanceCountdown > 0) {
        setState(() {
          _autoAdvanceCountdown--;
        });
      }
    });

    _autoAdvanceTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _advanceToNextOrchardNow();
      }
    });
  }

  void _advanceToNextOrchardNow() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
    _countdownTicker?.cancel();
    _countdownTicker = null;
    widget.controller.generateNextOrchard();
  }

  void _shakeTree() {
    if (!_treeWobbleAnim.isAnimating) {
      _treeWobbleAnim.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isHindi = controller.profile.uiLocale == 'hi';

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Stack(
          children: [
            // Background scenic meadow
            Positioned.fill(
              child: _buildMeadowBackground(),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Navigation Header: Blue Back ◀️, Title Plaque, Level Badge
                  _buildHeaderRow(isHindi),

                  const SizedBox(height: 4),

                  // Dynamic Question Banner with Fruit
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF81C784), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RealisticFruitWidget(fruitKindId: controller.currentFruit.id, size: 24),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isHindi ? controller.questionHi : controller.questionEn,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          RealisticFruitWidget(fruitKindId: controller.currentFruit.id, size: 24),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Horizontal Fruit Selector Bar (All fruits come to play!)
                  _buildFruitSelectorBar(),

                  const SizedBox(height: 2),

                  // Main Wooden Tablet Frame containing Tree & Number Choices
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: WoodenTabletFrame(
                        borderWidth: 10,
                        cornerRadius: 24,
                        showCornerLeaves: true,
                        trayColor: const Color(0xFFE8F5E9),
                        child: Stack(
                          children: [
                            // Meadow background inside the wooden frame
                            Positioned.fill(
                              child: _buildMeadowBackground(),
                            ),

                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 540;
                                return isWide
                                    ? Row(
                                        children: [
                                          // Left Side: Friendly Living Pixar Tree in Meadow
                                          Expanded(
                                            flex: 6,
                                            child: _buildLivingAppleTree(constraints),
                                          ),
                                          const SizedBox(width: 8),
                                          // Right Side: Number choices panel
                                          Expanded(
                                            flex: 5,
                                            child: _buildNumberChoicesPanel(isHindi, isHorizontal: false),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: _buildLivingAppleTree(constraints),
                                          ),
                                          const SizedBox(height: 4),
                                          _buildNumberChoicesPanel(isHindi, isHorizontal: true),
                                        ],
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Top Bar matching Image 5:
  /// Left: Blue round back button ◀️
  /// Center: Title plaque with colorful leaves "COUNT THE APPLES!"
  /// Right: Level Badge & Quick Advance
  Widget _buildHeaderRow(bool isHindi) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Blue Round Back Button
              CandyPillButton(
                width: 40,
                height: 40,
                borderRadius: 20,
                color: const Color(0xFF29B6F6),
                borderColor: Colors.white,
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),

              // Title Plaque with Leaf Flanks: "COUNT THE APPLES!"
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFC89658), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        offset: const Offset(0, 3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RealisticFruitWidget(fruitKindId: widget.controller.currentFruit.id, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        isHindi ? widget.controller.titleHi : widget.controller.titleEn,
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4E342E),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RealisticFruitWidget(fruitKindId: widget.controller.currentFruit.id, size: 22),
                    ],
                  ),
                ),
              ),

              // Level indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  'Lv 1-${widget.controller.levelIndex + 1}',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Rolling meadow background with gentle hills and distant trees
  Widget _buildMeadowBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF81D4FA), // Soft cartoon sky blue
            Color(0xFFB2EBF2),
            Color(0xFFA5D6A7), // Lush meadow greens
            Color(0xFF66BB6A),
          ],
          stops: [0.0, 0.45, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // White fluffy cartoon clouds
          Positioned(
            top: 15,
            left: 20,
            child: Opacity(
              opacity: 0.85,
              child: Row(
                children: const [
                  Icon(Icons.cloud_rounded, color: Colors.white, size: 48),
                  SizedBox(width: 4),
                  Icon(Icons.cloud_rounded, color: Colors.white, size: 36),
                ],
              ),
            ),
          ),
          Positioned(
            top: 25,
            right: 40,
            child: Opacity(
              opacity: 0.75,
              child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 54),
            ),
          ),
          // Smiling Sun in upper corner
          const Positioned(
            top: 10,
            right: 15,
            child: CartoonSun(size: 42),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitSelectorBar() {
    final controller = widget.controller;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: G002Controller.fruitKinds.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final fruit = G002Controller.fruitKinds[index];
          final isSelected = fruit.id == controller.currentFruit.id;
          return GestureDetector(
            onTap: () {
              controller.selectFruit(fruit);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF9C4) : Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF8F00) : const Color(0xFFB0BEC5),
                  width: isSelected ? 2.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFFFB300).withOpacity(0.4)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: isSelected ? 6 : 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RealisticFruitWidget(fruitKindId: fruit.id, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    fruit.nameEn,
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected ? const Color(0xFFE65100) : const Color(0xFF37474F),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Friendly Realistic Pixar 3D Cartoon Tree with volumetric canopy, organic bark, and face
  Widget _buildLivingAppleTree(BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _treeWobbleAngle,
      builder: (context, child) {
        return Transform.rotate(
          angle: _treeWobbleAngle.value,
          origin: const Offset(0, 100),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _shakeTree,
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, treeConstraints) {
            final w = treeConstraints.maxWidth;
            final h = treeConstraints.maxHeight;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Realistic Pixar 3D Tree CustomPainter (Trunk, branches, volumetric canopy, mound)
                Positioned.fill(
                  child: CustomPaint(
                    painter: Pixar3DTreePainter(),
                  ),
                ),

                // 2. Countable Fruits pinned on tree canopy with twig connectors
                ...widget.controller.fruits.map((fruit) {
                  final left = (fruit.normalizedX * w) - 26;
                  final top = (fruit.normalizedY * h) - 26;

                  return Positioned(
                    left: left.clamp(8.0, w - 56.0),
                    top: top.clamp(8.0, h - 56.0),
                    child: GestureDetector(
                      onTap: () {
                        widget.controller.handleAction(GameAction.tap('fruit_${fruit.id}'));
                      },
                      child: _buildFruitWidget(fruit),
                    ),
                  );
                }),

                // Interactive tap-hint pill
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC89658), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Builder(
                        builder: (context) {
                          final isHindi = widget.controller.profile.uiLocale == 'hi';
                          return Text(
                            isHindi ? widget.controller.tapHintHi : widget.controller.tapHintEn,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF5D4037),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Realistic 3D Botanical Fruit with stem, leaf, glossy sheen, and tap glow
  Widget _buildFruitWidget(FruitInstance fruit) {
    return RealisticFruitWidget(
      fruitKindId: fruit.fruitKindId,
      size: 52,
      isCountTapped: fruit.isCountTapped,
      tapOrder: fruit.isCountTapped ? fruit.id : null,
    );
  }

  /// Number Choices Panel: 5 vibrant candy buttons (user requested more numbers)
  Widget _buildNumberChoicesPanel(bool isHindi, {bool isHorizontal = false}) {
    final controller = widget.controller;
    final isCompleted = controller.state == GameLifecycleState.completed;

    if (isCompleted) {
      return _buildOrchardCompletedAutoAdvance(isHindi);
    }

    final choices = controller.answerChoices;

    final buttonStyles = [
      {'color': const Color(0xFFFFA726), 'hasLeaves': true, 'hasSparkles': false},
      {'color': const Color(0xFF42A5F5), 'hasLeaves': false, 'hasSparkles': false},
      {'color': const Color(0xFF81C784), 'hasLeaves': false, 'hasSparkles': true},
      {'color': const Color(0xFFBA68C8), 'hasLeaves': false, 'hasSparkles': false},
      {'color': const Color(0xFFFF7043), 'hasLeaves': true, 'hasSparkles': true},
      {'color': const Color(0xFFFFD54F), 'hasLeaves': false, 'hasSparkles': true},
    ];

    final buttons = List.generate(choices.length, (index) {
      final choice = choices[index];
      final style = buttonStyles[index % buttonStyles.length];
      final isSelected = controller.selectedAnswer == choice;

      return Padding(
        padding: const EdgeInsets.all(4),
        child: CandyPillButton(
          width: isHorizontal ? 68 : 88,
          height: isHorizontal ? 48 : 54,
          borderRadius: 20,
          color: style['color'] as Color,
          borderColor: isSelected ? Colors.white : Colors.white.withOpacity(0.95),
          onPressed: () {
            controller.handleAction(GameAction.select(choice.toString()));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (style['hasLeaves'] == true) ...[
                const Icon(Icons.eco_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 2),
              ],
              Text(
                '$choice',
                style: GoogleFonts.bubblegumSans(
                  fontSize: isHorizontal ? 26 : 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.35),
                      offset: const Offset(1, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              if (style['hasSparkles'] == true) ...[
                const SizedBox(width: 2),
                const Text('✨', style: TextStyle(fontSize: 10)),
              ],
            ],
          ),
        ),
      );
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Subtitle prompt
        Text(
          isHindi
              ? 'कितने ${controller.currentFruit.nameHi} हैं? सही संख्या दबाएं!'
              : 'How many ${controller.currentFruit.nameEn.toLowerCase()}? Tap the number!',
          textAlign: TextAlign.center,
          style: GoogleFonts.bubblegumSans(
            fontSize: isHorizontal ? 12 : 14,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4E342E),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 4,
          spacing: 4,
          children: buttons,
        ),
      ],
    );
  }

  /// Celebratory Auto-Advance Banner when round is solved
  Widget _buildOrchardCompletedAutoAdvance(bool isHindi) {
    final actual = widget.controller.actualCount;
    final currentFruit = widget.controller.currentFruit;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EE),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF81C784), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                RealisticFruitWidget(fruitKindId: currentFruit.id, size: 36),
                const SizedBox(width: 6),
                const Text('🎉', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isHindi
                    ? '$actual ${currentFruit.nameHi} बिल्कुल सही! शाबाश!'
                    : 'Super! $actual ${currentFruit.nameEn} Counted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.bubblegumSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Next tree in ${_autoAdvanceCountdown}s...',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CandyPillButton(
              width: 150,
              height: 38,
              color: const Color(0xFF4CAF50),
              borderColor: Colors.white,
              borderRadius: 19,
              onPressed: _advanceToNextOrchardNow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXT ORCHARD',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.skip_next_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a warm, high-fidelity Pixar 3D cartoon tree with volumetric cloud-puffed canopy,
/// organic flared roots, bark striations, spreading bough limbs, and friendly expressive eyes.
class Pixar3DTreePainter extends CustomPainter {
  const Pixar3DTreePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft Ambient Ground Shadow under tree base
    final groundShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.94), width: w * 0.62, height: h * 0.10),
      groundShadowPaint,
    );

    // 2. Grassy Knoll Mound
    final moundPath = Path()
      ..moveTo(w * 0.10, h * 0.96)
      ..quadraticBezierTo(w * 0.50, h * 0.88, w * 0.90, h * 0.96)
      ..lineTo(w * 0.90, h)
      ..lineTo(w * 0.10, h)
      ..close();
    final moundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF81C784), Color(0xFF43A047), Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, h * 0.88, w, h * 0.12));
    canvas.drawPath(moundPath, moundPaint);

    // Cute flower blooms on mound
    _drawMoundDecorations(canvas, w, h);

    // 3. Spreading Woody Trunk and Branch Arms
    _drawSculptedTrunk(canvas, w, h);

    // 4. Multi-cluster Volumetric Pixar Cloud Canopy
    _drawPixarCanopy(canvas, w, h);

    // 5. Friendly Kawaii Pixar Eyes & Rosy Smile
    _drawFriendlyFace(canvas, w, h);
  }

  void _drawMoundDecorations(Canvas canvas, double w, double h) {
    final flowerCenters = [
      Offset(w * 0.22, h * 0.93),
      Offset(w * 0.32, h * 0.95),
      Offset(w * 0.68, h * 0.95),
      Offset(w * 0.78, h * 0.93),
    ];
    final petalPaint = Paint()..color = Colors.white;
    final flowerCenterPaint = Paint()..color = const Color(0xFFFFD54F);

    for (final fc in flowerCenters) {
      for (int i = 0; i < 5; i++) {
        final a = i * 2 * math.pi / 5;
        canvas.drawCircle(Offset(fc.dx + 3.0 * math.cos(a), fc.dy + 3.0 * math.sin(a)), 2.2, petalPaint);
      }
      canvas.drawCircle(fc, 2.0, flowerCenterPaint);
    }
  }

  void _drawSculptedTrunk(Canvas canvas, double w, double h) {
    final trunkPath = Path();
    // Root base left
    trunkPath.moveTo(w * 0.34, h * 0.94);
    // Left trunk waist taper
    trunkPath.cubicTo(w * 0.40, h * 0.82, w * 0.42, h * 0.68, w * 0.40, h * 0.52);
    // Left branch fork reaching out
    trunkPath.cubicTo(w * 0.34, h * 0.46, w * 0.24, h * 0.42, w * 0.18, h * 0.38);
    trunkPath.lineTo(w * 0.22, h * 0.35);
    trunkPath.cubicTo(w * 0.32, h * 0.40, w * 0.42, h * 0.44, w * 0.46, h * 0.42);
    // Center branch
    trunkPath.cubicTo(w * 0.48, h * 0.36, w * 0.48, h * 0.30, w * 0.50, h * 0.26);
    trunkPath.lineTo(w * 0.54, h * 0.26);
    // Right branch fork reaching out
    trunkPath.cubicTo(w * 0.54, h * 0.36, w * 0.58, h * 0.42, w * 0.78, h * 0.35);
    trunkPath.lineTo(w * 0.82, h * 0.38);
    trunkPath.cubicTo(w * 0.74, h * 0.42, w * 0.64, h * 0.46, w * 0.60, h * 0.52);
    // Right trunk waist taper
    trunkPath.cubicTo(w * 0.58, h * 0.68, w * 0.60, h * 0.82, w * 0.66, h * 0.94);
    // Base root flare connection
    trunkPath.quadraticBezierTo(w * 0.50, h * 0.92, w * 0.34, h * 0.94);
    trunkPath.close();

    // 3D Bark Linear Gradient
    final trunkShader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF5D3014), // Deep bark shadow
        Color(0xFF79461E),
        Color(0xFFA06834), // Warm lit chestnut
        Color(0xFFC69055), // Sun specular rim
        Color(0xFF8D5424),
        Color(0xFF4A250D), // Right ambient occlusion
      ],
      stops: [0.0, 0.20, 0.45, 0.60, 0.85, 1.0],
    ).createShader(Rect.fromLTWH(w * 0.18, h * 0.26, w * 0.64, h * 0.68));

    canvas.drawPath(trunkPath, Paint()..shader = trunkShader);

    // Organic bark grain curves
    final grainPaint = Paint()
      ..color = const Color(0xFF3E1F0B).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final grain1 = Path()
      ..moveTo(w * 0.45, h * 0.88)
      ..cubicTo(w * 0.47, h * 0.74, w * 0.46, h * 0.62, w * 0.44, h * 0.52);
    final grain2 = Path()
      ..moveTo(w * 0.54, h * 0.86)
      ..cubicTo(w * 0.52, h * 0.72, w * 0.53, h * 0.60, w * 0.55, h * 0.50);
    canvas.drawPath(grain1, grainPaint);
    canvas.drawPath(grain2, grainPaint);

    // Wood Knot
    final knotCenter = Offset(w * 0.50, h * 0.72);
    canvas.drawOval(
      Rect.fromCenter(center: knotCenter, width: 10, height: 14),
      Paint()..color = const Color(0xFF3E1F0B).withOpacity(0.45),
    );
    canvas.drawOval(
      Rect.fromCenter(center: knotCenter, width: 5, height: 8),
      Paint()..color = const Color(0xFF261205).withOpacity(0.6),
    );
  }

  void _drawPixarCanopy(Canvas canvas, double w, double h) {
    // Deep backdrop shadow lobes
    final shadowLobePaint = Paint()..color = const Color(0xFF143D15);
    canvas.drawCircle(Offset(w * 0.32, h * 0.38), w * 0.24, shadowLobePaint);
    canvas.drawCircle(Offset(w * 0.68, h * 0.38), w * 0.24, shadowLobePaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.24), w * 0.25, shadowLobePaint);

    // Volumetric 3D Cloud Lobes
    void drawLobe(Offset center, double radius) {
      final lobeRect = Rect.fromCircle(center: center, radius: radius);
      final lobeShader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        radius: 0.85,
        colors: const [
          Color(0xFFAED581), // Warm sunlight chartreuse
          Color(0xFF81C784), // Sunny green
          Color(0xFF43A047), // Emerald leaf midtone
          Color(0xFF2E7D32), // Deep forest green
          Color(0xFF1B5E20), // Ambient occlusion shadow
        ],
        stops: const [0.0, 0.25, 0.55, 0.82, 1.0],
      ).createShader(lobeRect);

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = lobeShader
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
      );

      // Top arc sun highlight
      final arcPath = Path()
        ..addArc(Rect.fromCircle(center: center, radius: radius * 0.94), -2.6, 2.0);
      canvas.drawPath(
        arcPath,
        Paint()
          ..color = const Color(0xFFFFF9C4).withOpacity(0.40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
      );
    }

    // 7 volumetric lobes arranged harmoniously
    drawLobe(Offset(w * 0.26, h * 0.36), w * 0.21);
    drawLobe(Offset(w * 0.74, h * 0.36), w * 0.21);
    drawLobe(Offset(w * 0.35, h * 0.22), w * 0.19);
    drawLobe(Offset(w * 0.65, h * 0.22), w * 0.19);
    drawLobe(Offset(w * 0.50, h * 0.18), w * 0.22);
    drawLobe(Offset(w * 0.50, h * 0.34), w * 0.25);
    drawLobe(Offset(w * 0.50, h * 0.46), w * 0.22);
  }

  void _drawFriendlyFace(Canvas canvas, double w, double h) {
    final faceY = h * 0.50;
    final leftEye = Offset(w * 0.45, faceY);
    final rightEye = Offset(w * 0.55, faceY);

    // Large Pixar anime eyes with gloss catchlights
    final eyePaint = Paint()..color = const Color(0xFF2E1C12);
    canvas.drawOval(Rect.fromCenter(center: leftEye, width: 8.5, height: 11), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: rightEye, width: 8.5, height: 11), eyePaint);

    // Dual catchlights
    final catchPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(leftEye.dx - 1.5, leftEye.dy - 2.5), 2.2, catchPaint);
    canvas.drawCircle(Offset(leftEye.dx + 1.8, leftEye.dy + 2.0), 1.1, catchPaint);
    canvas.drawCircle(Offset(rightEye.dx - 1.5, rightEye.dy - 2.5), 2.2, catchPaint);
    canvas.drawCircle(Offset(rightEye.dx + 1.8, rightEye.dy + 2.0), 1.1, catchPaint);

    // Rosy Blush Cheeks
    final blushPaint = Paint()
      ..color = const Color(0xFFFF8A80).withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.41, faceY + 4), width: 10, height: 6), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.59, faceY + 4), width: 10, height: 6), blushPaint);

    // Happy smiling mouth
    final mouthPath = Path()
      ..moveTo(w * 0.47, faceY + 4.5)
      ..quadraticBezierTo(w * 0.50, faceY + 8.5, w * 0.53, faceY + 4.5);
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = const Color(0xFF4E260E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
