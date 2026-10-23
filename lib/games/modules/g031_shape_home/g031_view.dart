import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g031_controller.dart';

class G031View extends StatefulWidget {
  final G031Controller controller;

  const G031View({super.key, required this.controller});

  @override
  State<G031View> createState() => _G031ViewState();
}

class _G031ViewState extends State<G031View> with SingleTickerProviderStateMixin {
  late AnimationController _arrowAnimController;
  late Animation<double> _arrowPhaseAnim;
  int _autoAdvanceCountdown = 2;
  Timer? _autoAdvanceTimer;
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    _arrowAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _arrowPhaseAnim = CurvedAnimation(
      parent: _arrowAnimController,
      curve: Curves.easeInOut,
    );

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
    _arrowAnimController.dispose();
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
        _advanceToNextLevelNow();
      }
    });
  }

  void _advanceToNextLevelNow() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
    _countdownTicker?.cancel();
    _countdownTicker = null;
    widget.controller.generateNextLevel();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final unplacedShapes = controller.shapes.where((s) => !s.isPlaced).toList();
        final isCompleted = controller.state == GameLifecycleState.completed;

        return Stack(
          children: [
            // Background scenic mountain landscape
            Positioned.fill(
              child: _buildMountainScenicBackground(),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Header Row: EXIT, Sun, SHAPE MATCH! Ribbon, Level Tag
                  _buildHeaderRow(),

                  const SizedBox(height: 6),

                  // Main Play Area inside Wooden Tablet Frame
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: WoodenTabletFrame(
                        borderWidth: 10,
                        cornerRadius: 24,
                        trayColor: Colors.transparent,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 560;

                            if (isCompleted) {
                              return Center(
                                child: _buildLevelCompletedAutoAdvance(),
                              );
                            }

                            return isWide
                                ? Row(
                                    children: [
                                      // Left Cream Card: Dashed Shape Silhouettes with Kawaii Faces
                                      Expanded(
                                        flex: 5,
                                        child: _buildSilhouetteCard(constraints),
                                      ),
                                      const SizedBox(width: 12),
                                      // Right Cream Card: Living Draggable 3D Objects
                                      Expanded(
                                        flex: 5,
                                        child: _buildDraggableObjectsCard(unplacedShapes),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: _buildSilhouetteCard(constraints),
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        flex: 5,
                                        child: _buildDraggableObjectsCard(unplacedShapes),
                                      ),
                                    ],
                                  );
                          },
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

  /// Top Header Row matching Image 3 with Level Badge
  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Left: Back Pill Button
          CandyPillButton(
            width: 44,
            height: 36,
            borderRadius: 18,
            color: const Color(0xFFF7C59F),
            borderColor: Colors.white,
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF6B4226),
              size: 22,
            ),
          ),
          const SizedBox(width: 6),

          // Smiling Sun
          const CartoonSun(size: 36),
          const SizedBox(width: 6),

          // Center: SHAPE MATCH! Ribbon Banner (Flexible)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFC89658), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🦊', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'SHAPE MATCH!',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4A3418),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Level indicator tag
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
  }

  /// Left Cream Card: Dashed Shape Silhouettes with Kawaii Faces
  Widget _buildSilhouetteCard(BoxConstraints constraints) {
    final silhouettes = widget.controller.silhouettes;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5C290), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: "MATCH SHAPES!"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              'MATCH SHAPES HERE!',
              style: GoogleFonts.bubblegumSans(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF5D4037),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: LayoutBuilder(
              builder: (context, slotConstraints) {
                return Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  runAlignment: WrapAlignment.spaceEvenly,
                  spacing: 10,
                  runSpacing: 8,
                  children: silhouettes.map((shapeType) {
                    final placedShape = widget.controller.shapes.firstWhere(
                      (s) => s.shapeType == shapeType,
                      orElse: () => ShapeItem(id: '', shapeType: shapeType, colorValue: 0),
                    );
                    final isPlaced = placedShape.isPlaced;

                    return DragTarget<String>(
                      onWillAcceptWithDetails: (details) => !isPlaced,
                      onAcceptWithDetails: (details) {
                        widget.controller.handleAction(
                          GameAction.dragDrop(
                            targetId: shapeType.name,
                            payload: details.data,
                          ),
                        );
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isHovered = candidateData.isNotEmpty;

                        return GestureDetector(
                          onTap: () {
                            widget.controller.handleAction(
                              GameAction.tap('slot_${shapeType.name}'),
                            );
                          },
                          child: _buildSilhouetteShape(shapeType, isPlaced, isHovered, placedShape),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilhouetteShape(
    ShapeType type,
    bool isPlaced,
    bool isHovered,
    ShapeItem placedShape,
  ) {
    const size = 68.0;
    final label = type.nameEn.toUpperCase();
    final isJustMatched = widget.controller.justMatchedShapeId == placedShape.id;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFFFFF9C4) : const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? const Color(0xFFFFB300)
                  : (isPlaced ? const Color(0xFF81C784) : const Color(0xFFD7CCC8)),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isPlaced
              ? TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: isJustMatched ? 0.3 : 1.0, end: 1.0),
                  duration: Duration(milliseconds: isJustMatched ? 600 : 200),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isJustMatched)
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD54F).withOpacity(0.85),
                                    blurRadius: 14,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          GlossyShapeWidget(shapeType: type, size: 52),
                        ],
                      ),
                    );
                  },
                )
              : GlossyShapeWidget(shapeType: type, size: 52, isSilhouette: true),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.bubblegumSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isPlaced ? const Color(0xFF2E7D32) : const Color(0xFF6B4226),
          ),
        ),
      ],
    );
  }

  /// Right Cream Card: Living Draggable 3D Objects with animated arrows
  Widget _buildDraggableObjectsCard(List<ShapeItem> unplacedShapes) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5C290), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: "TAP OR DRAG SHAPES!"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF81D4FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              'TAP OR DRAG SHAPES!',
              style: GoogleFonts.bubblegumSans(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF01579B),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: unplacedShapes.isEmpty
                ? const Center(
                    child: Text(
                      '🎉 Great Job!\nAll Shapes Matched!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF43A047),
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: unplacedShapes.map((shape) {
                            final isSelected = widget.controller.selectedShapeForTap?.id == shape.id;

                            return Draggable<String>(
                              data: shape.id,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildLivingObjectWidget(shape, isDragging: true),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.25,
                                child: _buildLivingObjectWidget(shape),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Tap to select for tap-place
                                  widget.controller.handleAction(GameAction.tap(shape.id));
                                  // Also auto-place directly if slot exists!
                                  widget.controller.handleAction(
                                    GameAction.tap('slot_${shape.shapeType.name}'),
                                  );
                                },
                                child: Container(
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFD54F).withOpacity(0.9),
                                              blurRadius: 14,
                                              spreadRadius: 4,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: _buildLivingObjectWidget(shape),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Glossy 3D Shape item with animated hint arrow
  Widget _buildLivingObjectWidget(ShapeItem shape, {bool isDragging = false}) {
    final type = shape.shapeType;
    final label = type.nameEn.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _arrowPhaseAnim,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(-3 * _arrowPhaseAnim.value, 0),
                    child: const Text('←', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B4226))),
                  );
                },
              ),
              const SizedBox(width: 4),
              GlossyShapeWidget(
                shapeType: type,
                size: 54,
                isDragging: isDragging,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.bubblegumSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4A3418),
            ),
          ),
        ],
      ),
    );
  }

  /// Celebratory Auto-Advance Banner when all shapes are matched
  Widget _buildLevelCompletedAutoAdvance() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4FC3F7), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟 🎉 🔺 🟦 🟡 🎉 🌟', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Shapes Matched! Level Complete!',
              textAlign: TextAlign.center,
              style: GoogleFonts.bubblegumSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0277BD),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Next shapes in ${_autoAdvanceCountdown}s...',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0277BD),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CandyPillButton(
              width: 160,
              height: 44,
              color: const Color(0xFF0288D1),
              borderColor: Colors.white,
              borderRadius: 22,
              onPressed: _advanceToNextLevelNow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXT SHAPES',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.skip_next_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMountainScenicBackground() {
    return Stack(
      children: [
        // Sky gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF81D4FA), // Top vibrant cyan
                Color(0xFFB3E5FC),
                Color(0xFFE1F5FE), // Horizon haze
              ],
            ),
          ),
        ),

        // 3 Layered cartoon mountains
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 220,
          child: CustomPaint(
            painter: CartoonMountainPainter(),
          ),
        ),

        // Fluffy clouds
        Positioned(
          top: 15,
          left: 20,
          child: Opacity(
            opacity: 0.8,
            child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 54),
          ),
        ),
        Positioned(
          top: 25,
          right: 50,
          child: Opacity(
            opacity: 0.85,
            child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 44),
          ),
        ),
      ],
    );
  }
}

class CartoonMountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Back distant mountain
    final paintBack = Paint()..color = const Color(0xFF90CAF9);
    final pathBack = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height)
      ..close();
    canvas.drawPath(pathBack, paintBack);

    // Mid mountain with snowy peak
    final paintMid = Paint()..color = const Color(0xFF64B5F6);
    final pathMid = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..lineTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(pathMid, paintMid);

    // Snow caps
    final snowPaint = Paint()..color = Colors.white;
    final snowPath = Path()
      ..moveTo(size.width * 0.65, size.height * 0.35)
      ..lineTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width * 0.75, size.height * 0.35)
      ..close();
    canvas.drawPath(snowPath, snowPaint);

    // Foreground rolling hill
    final paintFore = Paint()..color = const Color(0xFF81C784);
    final pathFore = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.55, size.width, size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathFore, paintFore);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Glossy 3D Shape Renderer for Shapes matching
class GlossyShapeWidget extends StatelessWidget {
  final ShapeType shapeType;
  final double size;
  final bool isSilhouette;
  final bool isDragging;

  const GlossyShapeWidget({
    super.key,
    required this.shapeType,
    this.size = 54,
    this.isSilhouette = false,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSilhouette) {
      return _buildSilhouette();
    }
    return _buildGlossyShape();
  }

  Widget _buildSilhouette() {
    switch (shapeType) {
      case ShapeType.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEFEBE9),
            border: Border.all(color: const Color(0xFF8D6E63), width: 2.5),
          ),
        );
      case ShapeType.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.22),
            color: const Color(0xFFEFEBE9),
            border: Border.all(color: const Color(0xFF8D6E63), width: 2.5),
          ),
        );
      case ShapeType.oval:
        return Container(
          width: size * 0.82,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.elliptical(size * 0.41, size * 0.5)),
            color: const Color(0xFFEFEBE9),
            border: Border.all(color: const Color(0xFF8D6E63), width: 2.5),
          ),
        );
      case ShapeType.triangle:
        return CustomPaint(
          size: Size(size, size * 0.9),
          painter: GlossyTrianglePainter(isSilhouette: true),
        );
      case ShapeType.star:
        return CustomPaint(
          size: Size(size, size),
          painter: GlossyStarPainter(isSilhouette: true),
        );
      case ShapeType.heart:
        return CustomPaint(
          size: Size(size, size * 0.9),
          painter: GlossyHeartPainter(isSilhouette: true),
        );
      case ShapeType.diamond:
        return CustomPaint(
          size: Size(size, size),
          painter: GlossyDiamondPainter(isSilhouette: true),
        );
      case ShapeType.crescent:
        return CustomPaint(
          size: Size(size, size),
          painter: GlossyMoonPainter(isSilhouette: true),
        );
      case ShapeType.cloud:
        return CustomPaint(
          size: Size(size * 1.05, size * 0.8),
          painter: GlossyCloudPainter(isSilhouette: true),
        );
    }
  }

  Widget _buildGlossyShape() {
    switch (shapeType) {
      case ShapeType.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.35, -0.35),
              radius: 0.85,
              colors: [
                Color(0xFFFF80AB), // Candy light pink highlight
                Color(0xFFFF4081), // Vibrant pink
                Color(0xFFC2185B), // Deep pink rim
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4081).withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: isDragging ? 12 : 5,
              ),
            ],
          ),
          child: Align(
            alignment: const Alignment(-0.4, -0.5),
            child: Container(
              width: size * 0.28,
              height: size * 0.16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.14, size * 0.08)),
              ),
            ),
          ),
        );

      case ShapeType.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF64B5F6), // Electric light blue
                Color(0xFF2196F3), // Electric blue
                Color(0xFF1565C0), // Deep blue rim
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: isDragging ? 12 : 5,
              ),
            ],
          ),
          child: Align(
            alignment: const Alignment(0.0, -0.65),
            child: Container(
              width: size * 0.6,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(size * 0.06),
              ),
            ),
          ),
        );

      case ShapeType.oval:
        return Container(
          width: size * 0.82,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.elliptical(size * 0.41, size * 0.5)),
            gradient: const RadialGradient(
              center: Alignment(-0.35, -0.35),
              radius: 0.85,
              colors: [
                Color(0xFFAED581), // Light lime
                Color(0xFF7CB342), // Vibrant lime green
                Color(0xFF558B2F), // Deep lime rim
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7CB342).withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: isDragging ? 12 : 5,
              ),
            ],
          ),
          child: Align(
            alignment: const Alignment(-0.3, -0.5),
            child: Container(
              width: size * 0.24,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.12, size * 0.08)),
              ),
            ),
          ),
        );

      case ShapeType.triangle:
        return CustomPaint(
          size: Size(size, size * 0.9),
          painter: GlossyTrianglePainter(isSilhouette: false),
        );

      case ShapeType.star:
        return CustomPaint(
          size: Size(size, size),
          painter: GlossyStarPainter(isSilhouette: false),
        );

      case ShapeType.heart:
        return CustomPaint(
          size: Size(size, size * 0.9),
          painter: GlossyHeartPainter(isSilhouette: false),
        );

      case ShapeType.diamond:
        return CustomPaint(
          size: Size(size, size),
          painter: GlossyDiamondPainter(isSilhouette: false),
        );

      case ShapeType.crescent:
        return CustomPaint(
          size: Size(size, size),
          painter: GlossyMoonPainter(isSilhouette: false),
        );

      case ShapeType.cloud:
        return CustomPaint(
          size: Size(size * 1.05, size * 0.8),
          painter: GlossyCloudPainter(isSilhouette: false),
        );
    }
  }
}

class GlossyTrianglePainter extends CustomPainter {
  final bool isSilhouette;
  const GlossyTrianglePainter({required this.isSilhouette});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w / 2, 4)
      ..lineTo(w - 4, h - 4)
      ..lineTo(4, h - 4)
      ..close();

    if (isSilhouette) {
      final fillPaint = Paint()..color = const Color(0xFFEFEBE9);
      final strokePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      return;
    }

    // Shadow
    canvas.drawShadow(path, const Color(0xFFFFC107).withOpacity(0.5), 5, true);

    // Gradient body
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF59D), Color(0xFFFFC107), Color(0xFFFFA000)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final paint = Paint()..shader = gradient;
    canvas.drawPath(path, paint);

    // Stroke border
    final borderPaint = Paint()
      ..color = const Color(0xFFFF8F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // Specular highlight line along left edge
    final highlightPath = Path()
      ..moveTo(w / 2, 8)
      ..lineTo(w * 0.25, h * 0.55);
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant GlossyTrianglePainter oldDelegate) =>
      oldDelegate.isSilhouette != isSilhouette;
}

class GlossyStarPainter extends CustomPainter {
  final bool isSilhouette;
  const GlossyStarPainter({required this.isSilhouette});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final R = w * 0.46;
    final r = R * 0.42;

    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 5);
      final radius = i.isEven ? R : r;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    if (isSilhouette) {
      final fillPaint = Paint()..color = const Color(0xFFEFEBE9);
      final strokePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      return;
    }

    canvas.drawShadow(path, const Color(0xFFFF9800).withOpacity(0.5), 5, true);

    final gradient = const RadialGradient(
      center: Alignment(-0.2, -0.2),
      radius: 0.9,
      colors: [Color(0xFFFFE082), Color(0xFFFF9800), Color(0xFFF57C00)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final paint = Paint()..shader = gradient;
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = const Color(0xFFE65100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // Specular shine dot
    canvas.drawCircle(
      Offset(cx - 3, cy - 6),
      4,
      Paint()..color = Colors.white.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(covariant GlossyStarPainter oldDelegate) =>
      oldDelegate.isSilhouette != isSilhouette;
}

class GlossyHeartPainter extends CustomPainter {
  final bool isSilhouette;
  const GlossyHeartPainter({required this.isSilhouette});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, h * 0.85);
    path.cubicTo(w * 0.05, h * 0.55, 0, h * 0.22, w * 0.26, h * 0.12);
    path.cubicTo(w * 0.44, h * 0.05, w * 0.5, h * 0.32, w * 0.5, h * 0.32);
    path.cubicTo(w * 0.5, h * 0.32, w * 0.56, h * 0.05, w * 0.74, h * 0.12);
    path.cubicTo(w * 1.0, h * 0.22, w * 0.95, h * 0.55, w * 0.5, h * 0.85);
    path.close();

    if (isSilhouette) {
      final fillPaint = Paint()..color = const Color(0xFFEFEBE9);
      final strokePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      return;
    }

    canvas.drawShadow(path, const Color(0xFFE53935).withOpacity(0.5), 5, true);

    final gradient = const RadialGradient(
      center: Alignment(-0.3, -0.3),
      radius: 0.85,
      colors: [Color(0xFFFF5252), Color(0xFFE53935), Color(0xFFB71C1C)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, Paint()..shader = gradient);

    final borderPaint = Paint()
      ..color = const Color(0xFF880E4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // Specular shine bubble on left lobe
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.65);
    canvas.save();
    canvas.translate(w * 0.28, h * 0.28);
    canvas.rotate(-0.4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.18, height: h * 0.10),
      shinePaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GlossyHeartPainter oldDelegate) =>
      oldDelegate.isSilhouette != isSilhouette;
}

class GlossyDiamondPainter extends CustomPainter {
  final bool isSilhouette;
  const GlossyDiamondPainter({required this.isSilhouette});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, 4)
      ..lineTo(w - 4, h * 0.5)
      ..lineTo(w * 0.5, h - 4)
      ..lineTo(4, h * 0.5)
      ..close();

    if (isSilhouette) {
      final fillPaint = Paint()..color = const Color(0xFFEFEBE9);
      final strokePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      return;
    }

    canvas.drawShadow(path, const Color(0xFF9C27B0).withOpacity(0.5), 5, true);

    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFCE93D8), Color(0xFF9C27B0), Color(0xFF6A1B9A)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, Paint()..shader = gradient);

    final borderPaint = Paint()
      ..color = const Color(0xFF4A148C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // Specular shine bar on top-left facet
    final highlightPath = Path()
      ..moveTo(w * 0.5, 8)
      ..lineTo(w * 0.22, h * 0.42);
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant GlossyDiamondPainter oldDelegate) =>
      oldDelegate.isSilhouette != isSilhouette;
}

class GlossyMoonPainter extends CustomPainter {
  final bool isSilhouette;
  const GlossyMoonPainter({required this.isSilhouette});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.55, 4)
      ..cubicTo(w * 0.96, 4, w * 0.96, h - 4, w * 0.55, h - 4)
      ..cubicTo(w * 0.76, h * 0.68, w * 0.76, h * 0.32, w * 0.55, 4)
      ..close();

    if (isSilhouette) {
      final fillPaint = Paint()..color = const Color(0xFFEFEBE9);
      final strokePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      return;
    }

    canvas.drawShadow(path, const Color(0xFF5C6BC0).withOpacity(0.5), 5, true);

    final gradient = const RadialGradient(
      center: Alignment(0.2, -0.3),
      radius: 0.9,
      colors: [Color(0xFF9FA8DA), Color(0xFF5C6BC0), Color(0xFF3949AB)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, Paint()..shader = gradient);

    final borderPaint = Paint()
      ..color = const Color(0xFF283593)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // Specular shine curve along outer curve
    final shinePath = Path()
      ..moveTo(w * 0.65, 8)
      ..cubicTo(w * 0.88, 12, w * 0.92, h * 0.4, w * 0.88, h * 0.5);
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(covariant GlossyMoonPainter oldDelegate) =>
      oldDelegate.isSilhouette != isSilhouette;
}

class GlossyCloudPainter extends CustomPainter {
  final bool isSilhouette;
  const GlossyCloudPainter({required this.isSilhouette});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.2, h * 0.8)
      ..arcToPoint(Offset(w * 0.15, h * 0.45), radius: Radius.circular(w * 0.2))
      ..arcToPoint(Offset(w * 0.52, h * 0.22), radius: Radius.circular(w * 0.28))
      ..arcToPoint(Offset(w * 0.88, h * 0.48), radius: Radius.circular(w * 0.24))
      ..arcToPoint(Offset(w * 0.82, h * 0.8), radius: Radius.circular(w * 0.2))
      ..close();

    if (isSilhouette) {
      final fillPaint = Paint()..color = const Color(0xFFEFEBE9);
      final strokePaint = Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      return;
    }

    canvas.drawShadow(path, const Color(0xFF00BCD4).withOpacity(0.45), 5, true);

    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF80DEEA), Color(0xFF00BCD4), Color(0xFF00838F)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, Paint()..shader = gradient);

    final borderPaint = Paint()
      ..color = const Color(0xFF006064)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // Specular shine oval on top bump
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.3), width: w * 0.28, height: h * 0.12),
      Paint()..color = Colors.white.withOpacity(0.65),
    );
  }

  @override
  bool shouldRepaint(covariant GlossyCloudPainter oldDelegate) =>
      oldDelegate.isSilhouette != isSilhouette;
}

