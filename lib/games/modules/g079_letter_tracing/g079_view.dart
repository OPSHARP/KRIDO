import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';
import '../../../core/audio/procedural_sfx_engine.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../core/widgets/confetti_celebration.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g079_controller.dart';

class G079View extends StatefulWidget {
  final G079Controller controller;

  const G079View({super.key, required this.controller});

  @override
  State<G079View> createState() => _G079ViewState();
}

class _G079ViewState extends State<G079View> with SingleTickerProviderStateMixin {
  late AnimationController _guideAnim;
  final ScrollController _ribbonScrollController = ScrollController();
  Color _selectedBrushColor = const Color(0xFF00E5FF);

  static const List<Color> _brushPalette = [
    Color(0xFF00E5FF), // Neon Cyan
    Color(0xFFFF4081), // Hot Pink
    Color(0xFFFFD54F), // Bright Gold
    Color(0xFF69F0AE), // Neon Mint Green
    Color(0xFFB388FF), // Vivid Lavender
    Color(0xFFFF6E40), // Coral Orange
  ];

  @override
  void initState() {
    super.initState();
    _guideAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    widget.controller.addListener(_onControllerChanged);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _guideAnim.dispose();
    _ribbonScrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      _scrollToActiveLetter();
    }
  }

  void _scrollToActiveLetter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_ribbonScrollController.hasClients) return;
      final targetOffset = (widget.controller.currentLetterIndex * 52.0) - 100.0;
      _ribbonScrollController.animateTo(
        targetOffset.clamp(0.0, _ribbonScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _speakCurrentLetter(bool isHindi) {
    final current = widget.controller.currentLetter;
    ProceduralSfxEngine().speakPhonics(
      current.letter,
      isHindi ? current.wordHi : current.word,
      isHindi: isHindi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final isCompleted = controller.state == GameLifecycleState.completed;
        final isHindi = controller.profile.uiLocale == 'hi';

        return Stack(
          children: [
            // Studio Backdrop
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF80DEEA),
                      Color(0xFFE0F7FA),
                      Color(0xFFFFF8E1),
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Header Row
                  _buildHeaderRow(controller, isHindi),

                  const SizedBox(height: 4),

                  // A-Z Alphabet Ribbon Carousel
                  _buildLetterRibbon(controller, isHindi),

                  const SizedBox(height: 6),

                  // Main Tracing Stage
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: WoodenTabletFrame(
                        borderWidth: 10,
                        cornerRadius: 24,
                        trayColor: const Color(0xFF1E293B), // Dark chalkboard slate
                        child: isCompleted
                            ? Center(child: _buildFinalVictoryCard(controller, isHindi))
                            : _buildTracingBoard(controller, isHindi),
                      ),
                    ),
                  ),

                  // Color Palette & Bottom Controls Row
                  _buildBottomControls(controller, isHindi),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            if (controller.isLetterCompleted)
              const Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiCelebration(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderRow(G079Controller controller, bool isHindi) {
    final current = controller.currentLetter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CandyPillButton(
            width: 58,
            height: 38,
            borderRadius: 19,
            color: const Color(0xFFFFCC80),
            borderColor: Colors.white,
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFE65100), size: 24),
          ),

          const SizedBox(width: 8),

          // Letter Word Banner with Phonics speaker
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: GestureDetector(
                  onTap: () => _speakCurrentLetter(isHindi),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFB300), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(current.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          '${current.letter} for ${isHindi ? current.wordHi : current.word}',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textNavy,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.volume_up_rounded, color: Color(0xFFFF9800), size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Star / Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB300)),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${(controller.completionRatio * 100).round()}%',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF57F17),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterRibbon(G079Controller controller, bool isHindi) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        controller: _ribbonScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: controller.letterDeck.length,
        itemBuilder: (context, index) {
          final item = controller.letterDeck[index];
          final isSelected = index == controller.currentLetterIndex;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick().catchError((_) {});
              ProceduralSfxEngine().playPop();
              controller.selectLetter(index);
              _speakCurrentLetter(isHindi);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 48 : 40,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isSelected
                      ? [const Color(0xFFFFD54F), const Color(0xFFFF9800)]
                      : [Colors.white, const Color(0xFFF5F5F5)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFFF9800).withOpacity(0.4)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: isSelected ? 6 : 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  item.letter,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: isSelected ? 22 : 18,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : const Color(0xFF37474F),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTracingBoard(G079Controller controller, bool isHindi) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;

        return Stack(
          children: [
            // Ambient Star Grid on blackboard
            Positioned(
              top: 10,
              left: 14,
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    isHindi
                      ? 'तारे का पीछा करते हुए अक्षर बनाएं!'
                      : 'Follow the glowing star & trace the path! ✨',
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Canvas with touch listener
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (details) {
                  if (canvasWidth <= 0 || canvasHeight <= 0) return;
                  final local = details.localPosition;
                  controller.onPanStart(
                    Offset(
                      (local.dx / canvasWidth).clamp(0.0, 1.0),
                      (local.dy / canvasHeight).clamp(0.0, 1.0),
                    ),
                  );
                },
                onPanUpdate: (details) {
                  if (canvasWidth <= 0 || canvasHeight <= 0) return;
                  final local = details.localPosition;
                  controller.onPanUpdate(
                    Offset(
                      (local.dx / canvasWidth).clamp(0.0, 1.0),
                      (local.dy / canvasHeight).clamp(0.0, 1.0),
                    ),
                  );
                },
                onPanEnd: (_) {
                  controller.onPanEnd();
                },
                child: AnimatedBuilder(
                  animation: _guideAnim,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(canvasWidth, canvasHeight),
                      painter: _LetterTracingPainter(
                        letterItem: controller.currentLetter,
                        userStrokes: controller.userDrawnStrokes,
                        isCompleted: controller.isLetterCompleted,
                        guideProgress: _guideAnim.value,
                        brushColor: _selectedBrushColor,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Completion Banner Overlay
            if (controller.isLetterCompleted)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Text('🌟', style: TextStyle(fontSize: 26)),
                              const SizedBox(width: 8),
                              Text(
                                isHindi ? 'शानदार अनुरेखण!' : 'Magnificent Tracing! 🎨',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CandyPillButton(
                        width: 90,
                        height: 38,
                        borderRadius: 19,
                        color: const Color(0xFF4CAF50),
                        borderColor: Colors.white,
                        onPressed: () {
                          HapticFeedback.selectionClick().catchError((_) {});
                          controller.nextLetter();
                          if (controller.state != GameLifecycleState.completed) {
                            _speakCurrentLetter(isHindi);
                          }
                        },
                        child: Center(
                          child: Text(
                            isHindi ? 'अगला ➔' : 'Next ➔',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBottomControls(G079Controller controller, bool isHindi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Erase / Clear Button
            CandyPillButton(
              width: 88,
              height: 40,
              borderRadius: 20,
              color: const Color(0xFFEF5350),
              borderColor: Colors.white,
              onPressed: () {
                HapticFeedback.lightImpact().catchError((_) {});
                ProceduralSfxEngine().playWhoosh();
                controller.clearCanvas();
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      isHindi ? 'मिटाएं' : 'Erase',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Brush Color Selector Palette
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFCA28), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _brushPalette.map((color) {
                  final isSelected = _selectedBrushColor == color;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick().catchError((_) {});
                      ProceduralSfxEngine().playPop();
                      setState(() => _selectedBrushColor = color);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSelected ? 26 : 20,
                      height: isSelected ? 26 : 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black87 : Colors.white,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: isSelected ? 6 : 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(width: 8),

            // Phonics Speaker Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE7F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_rounded, color: AppTheme.purple, size: 24),
              ),
              onPressed: () {
                HapticFeedback.selectionClick().catchError((_) {});
                _speakCurrentLetter(isHindi);
              },
            ),

            const SizedBox(width: 8),

            // Next Button
            CandyPillButton(
              width: 88,
              height: 40,
              borderRadius: 20,
              color: const Color(0xFF42A5F5),
              borderColor: Colors.white,
              onPressed: () {
                HapticFeedback.lightImpact().catchError((_) {});
                ProceduralSfxEngine().playWhoosh();
                controller.nextLetter();
                if (controller.state != GameLifecycleState.completed) {
                  _speakCurrentLetter(isHindi);
                }
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isHindi ? 'अगला' : 'Next',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalVictoryCard(G079Controller controller, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑', style: TextStyle(fontSize: 58)),
            const SizedBox(height: 10),
            Text(
              isHindi ? 'वर्णमाला मास्टर! 🌟' : 'Alphabet Master! 🌟',
              style: GoogleFonts.bubblegumSans(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? 'आपने 26 अक्षरों को बहुत सुंदर उकेरा है! +1 पेट ट्रीट जीता!'
                  : 'You mastered tracing all 26 letters with wonderful penmanship! Earned +1 pet treat!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            CandyPillButton(
              width: 170,
              height: 48,
              borderRadius: 24,
              color: const Color(0xFF4CAF50),
              borderColor: Colors.white,
              onPressed: () {
                controller.reset();
              },
              child: Center(
                child: Text(
                  isHindi ? 'शुरू से खेलें 🚀' : 'Trace Again 🚀',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterTracingPainter extends CustomPainter {
  final TracingLetterItem letterItem;
  final List<List<Offset>> userStrokes;
  final bool isCompleted;
  final double guideProgress;
  final Color brushColor;

  _LetterTracingPainter({
    required this.letterItem,
    required this.userStrokes,
    required this.isCompleted,
    required this.guideProgress,
    required this.brushColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Dotted Guide Strokes track
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final stroke in letterItem.strokes) {
      if (stroke.waypoints.length > 1) {
        final path = Path();
        final first = stroke.waypoints.first;
        path.moveTo(first.x * size.width, first.y * size.height);
        for (int i = 1; i < stroke.waypoints.length; i++) {
          final wp = stroke.waypoints[i];
          path.lineTo(wp.x * size.width, wp.y * size.height);
        }
        canvas.drawPath(path, guidePaint);
      }
    }

    // 2. Draw Waypoint Dots (Green glow if hit, Translucent white if unhit)
    for (final stroke in letterItem.strokes) {
      for (int i = 0; i < stroke.waypoints.length; i++) {
        final wp = stroke.waypoints[i];
        final center = Offset(wp.x * size.width, wp.y * size.height);

        final dotPaint = Paint()
          ..color = wp.isHit || isCompleted
              ? const Color(0xFF69F0AE)
              : Colors.white.withOpacity(0.35)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(center, wp.isHit ? 7.0 : 5.0, dotPaint);

        // Draw start dot with stroke number badge
        if (i == 0) {
          final circlePaint = Paint()
            ..color = const Color(0xFFFFD54F)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(center, 13.0, circlePaint);

          final textPainter = TextPainter(
            text: TextSpan(
              text: '${stroke.strokeNumber}',
              style: const TextStyle(
                color: Color(0xFF3E2723),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(
            canvas,
            center - Offset(textPainter.width / 2, textPainter.height / 2),
          );
        }
      }
    }

    // 3. Draw User Traced Glow Strokes (Double pass for neon glow)
    final glowPaint = Paint()
      ..color = (isCompleted ? const Color(0xFFFFD54F) : brushColor).withOpacity(0.40)
      ..strokeWidth = 26
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final corePaint = Paint()
      ..color = isCompleted ? const Color(0xFFFFD54F) : brushColor
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in userStrokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        final p = Offset(stroke.first.dx * size.width, stroke.first.dy * size.height);
        canvas.drawCircle(p, 13, glowPaint);
        canvas.drawCircle(p, 8, corePaint);
      } else {
        final path = Path();
        path.moveTo(stroke.first.dx * size.width, stroke.first.dy * size.height);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx * size.width, stroke[i].dy * size.height);
        }
        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, corePaint);
      }
    }

    // 4. Animated Guiding Indicator (Golden Star moving along active stroke)
    if (!isCompleted) {
      LetterStroke? activeStroke;
      for (final stroke in letterItem.strokes) {
        final hasUnhit = stroke.waypoints.any((w) => !w.isHit);
        if (hasUnhit) {
          activeStroke = stroke;
          break;
        }
      }

      if (activeStroke != null && activeStroke.waypoints.length > 1) {
        final guidePos = _calculateStrokePosition(activeStroke.waypoints, guideProgress, size);

        // Pulsating outer halo
        final haloPaint = Paint()
          ..color = const Color(0xFFFFEB3B).withOpacity(0.35 + 0.25 * math.sin(guideProgress * 2 * math.pi))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(guidePos, 18, haloPaint);

        // Core star marker
        final starPaint = Paint()
          ..color = const Color(0xFFFFC107)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(guidePos, 10, starPaint);

        final starPainter = TextPainter(
          text: const TextSpan(
            text: '⭐',
            style: TextStyle(fontSize: 14),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        starPainter.paint(
          canvas,
          guidePos - Offset(starPainter.width / 2, starPainter.height / 2),
        );
      }
    }
  }

  Offset _calculateStrokePosition(List<TracingWaypoint> points, double t, Size size) {
    if (points.isEmpty) return Offset.zero;
    if (points.length == 1) {
      return Offset(points[0].x * size.width, points[0].y * size.height);
    }

    final totalSegments = points.length - 1;
    final scaledT = t * totalSegments;
    final segmentIdx = scaledT.floor().clamp(0, totalSegments - 1);
    final localT = scaledT - segmentIdx;

    final p1 = points[segmentIdx];
    final p2 = points[segmentIdx + 1];

    final curX = (p1.x + (p2.x - p1.x) * localT) * size.width;
    final curY = (p1.y + (p2.y - p1.y) * localT) * size.height;

    return Offset(curX, curY);
  }

  @override
  bool shouldRepaint(covariant _LetterTracingPainter oldDelegate) => true;
}
