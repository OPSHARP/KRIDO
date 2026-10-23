import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../audio/audio_service.dart';
import 'pixar_3d_icons.dart';

/// Interactive Floating 3D Island Element
/// Features:
/// - Continuous ambient floating bobbing animation with individual phase offsets
/// - Reactive touch physics: scales down (squishes) on tap down, bounces elastically on release
/// - Dynamic responsive ground shadow that shrinks/expands with height
/// - Tactile haptic feedback and rich sound cues on touch
/// - Thematic 3D geological stratum, lush top plateau, and 3D Pixar Icon pedestal
class InteractiveFloatingIsland extends StatefulWidget {
  final Map<String, dynamic> islandData;
  final int index;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool isCompact;

  const InteractiveFloatingIsland({
    super.key,
    required this.islandData,
    required this.index,
    required this.onTap,
    this.width = 168.0,
    this.height = 224.0,
    this.isCompact = false,
  });

  @override
  State<InteractiveFloatingIsland> createState() =>
      _InteractiveFloatingIslandState();
}

class _InteractiveFloatingIslandState extends State<InteractiveFloatingIsland>
    with TickerProviderStateMixin {
  late AnimationController _bobbingController;
  late AnimationController _touchSpringController;
  late Animation<double> _touchScaleAnimation;
  late Animation<double> _touchYOffsetAnimation;

  Timer? _sparkleTimer;
  Timer? _tapTimer;
  bool _isPressed = false;
  final List<_IslandSparkle> _sparkles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Ambient floating bobbing with staggered cycle
    _bobbingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2800 + (widget.index % 4) * 350),
    )..repeat(reverse: true);

    // Touch spring response controller
    _touchSpringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    _touchScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.10)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.10, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_touchSpringController);

    _touchYOffsetAnimation = Tween<double>(begin: 0.0, end: 9.0).animate(
      CurvedAnimation(
        parent: _touchSpringController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _sparkleTimer?.cancel();
    _tapTimer?.cancel();
    _bobbingController.dispose();
    _touchSpringController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_isPressed) return;
    setState(() => _isPressed = true);

    HapticFeedback.mediumImpact().catchError((_) {});
    AudioService().playCue(SoundCue.press);

    _touchSpringController.animateTo(
      0.35, // Squish state
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
    );
  }

  void _onTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _touchSpringController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
    );
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isPressed) return;
    setState(() => _isPressed = false);

    // Trigger celebratory sound & sparkle burst
    AudioService().playCue(SoundCue.star);
    HapticFeedback.selectionClick().catchError((_) {});
    _spawnSparkles();

    // Elastic bounce release animation
    _touchSpringController.forward(from: 0.35).then((_) {
      _touchSpringController.reset();
    });

    // Execute callback with brief micro-delay so child witnesses the bounce
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(milliseconds: 160), () {
      if (mounted) widget.onTap();
    });
  }

  void _spawnSparkles() {
    setState(() {
      final colors = [
        const Color(0xFFFFD54F),
        const Color(0xFFFF4081),
        const Color(0xFF00E5FF),
        const Color(0xFF76FF03),
        Colors.white,
      ];
      for (int i = 0; i < 7; i++) {
        _sparkles.add(_IslandSparkle(
          offset: Offset(
            (_random.nextDouble() - 0.5) * 60,
            (_random.nextDouble() - 0.5) * 40 - 20,
          ),
          color: colors[_random.nextInt(colors.length)],
          size: 8.0 + _random.nextDouble() * 8.0,
        ));
      }
    });

    _sparkleTimer?.cancel();
    _sparkleTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _sparkles.clear());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final island = widget.islandData;
    final islandColor = island['islandColor'] as Color? ?? const Color(0xFF43A047);
    final accentColor = island['accent'] as Color? ?? const Color(0xFFFFD54F);
    final pixarType = island['pixarType'] as PixarIconType? ?? PixarIconType.star;
    final title = (island['title'] as String? ?? 'ISLAND').toUpperCase();
    final tag = (island['tag'] as String? ?? 'PLAY').toUpperCase();
    final stars = island['stars'] as int? ?? 3;

    return AnimatedBuilder(
      animation: Listenable.merge([_bobbingController, _touchSpringController]),
      builder: (context, _) {
        // Individual phase-shifted floating bobbing: -5.5 to +5.5 px
        final phaseOffset = (widget.index * 0.72);
        final bobbingY = math.sin((_bobbingController.value * 2 * math.pi) + phaseOffset) * 5.5;

        final currentScale = _isPressed
            ? (1.0 - (_touchSpringController.value * 0.12))
            : _touchScaleAnimation.value;
        final touchOffsetY = _touchYOffsetAnimation.value;

        // Ground shadow responds inversely to height
        final shadowScale = (1.0 - (bobbingY / 30.0)).clamp(0.75, 1.15) *
            (_isPressed ? 0.85 : 1.0);
        final shadowOpacity = (0.28 - (bobbingY / 70.0)).clamp(0.12, 0.40);

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. DYNAMIC GROUND SHADOW (Floats on water/meadow below)
              Positioned(
                bottom: 6,
                child: Transform.scale(
                  scaleX: shadowScale,
                  scaleY: shadowScale * 0.65,
                  child: Container(
                    width: widget.width * 0.72,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(shadowOpacity),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(widget.width * 0.72, 22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(shadowOpacity * 0.8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. 3D FLOATING ISLAND STRUCTURE (Animated by bobbing and touch spring)
              Positioned(
                top: 8 + bobbingY + touchOffsetY,
                child: GestureDetector(
                  onTap: widget.onTap,
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  behavior: HitTestBehavior.opaque,
                  child: Transform.scale(
                    scale: currentScale,
                    alignment: Alignment.bottomCenter,
                    child: _buildFloatingIslandBody(
                      islandColor: islandColor,
                      accentColor: accentColor,
                      pixarType: pixarType,
                      title: title,
                      tag: tag,
                      stars: stars,
                    ),
                  ),
                ),
              ),

              // 3. CELEBRATORY SPARKLE BURST PARTICLES
              if (_sparkles.isNotEmpty)
                ..._sparkles.map((sp) {
                  return Positioned(
                    top: (widget.height * 0.4) + sp.offset.dy + bobbingY,
                    left: (widget.width * 0.5) + sp.offset.dx - (sp.size / 2),
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 0.0),
                        duration: const Duration(milliseconds: 380),
                        builder: (context, opacity, _) {
                          return Opacity(
                            opacity: opacity,
                            child: Icon(
                              Icons.star_rounded,
                              size: sp.size,
                              color: sp.color,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  /// 3D Island Multi-Layer Body with Stratum Cliffs, Lush Plateau, and Podium
  Widget _buildFloatingIslandBody({
    required Color islandColor,
    required Color accentColor,
    required PixarIconType pixarType,
    required String title,
    required String tag,
    required int stars,
  }) {
    final islandWidth = widget.width;
    final islandBodyHeight = widget.height - 30;

    return Container(
      width: islandWidth,
      height: islandBodyHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Soft ambient glow matching island hue
          BoxShadow(
            color: islandColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          // Deep subterranean shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Layer A: 3D Geological Stratum (Rocky cliff underneath)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      islandColor,
                      Color.lerp(islandColor, const Color(0xFF3E2723), 0.35) ??
                          const Color(0xFF3E2723),
                      const Color(0xFF2E1C14),
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
              ),
            ),

            // Layer B: Carved Cliff Texture & Hanging Crystal Seams
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 48,
              child: CustomPaint(
                painter: _IslandStratumPainter(
                  accentColor: accentColor,
                ),
              ),
            ),

            // Layer C: Top Lush Plateau Rim (Specular Gloss Rim)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: islandBodyHeight * 0.76,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(Colors.white, islandColor, 0.70) ?? islandColor,
                      islandColor,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                    width: 3.5,
                  ),
                ),
              ),
            ),

            // Layer D: Top Specular Sunbeam Glare Curve
            Positioned(
              top: 2,
              left: 12,
              right: 12,
              height: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.55),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Layer E: Island Centerpiece Content
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Tag Pill & Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Tag Pill
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accentColor.withOpacity(0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                offset: const Offset(0, 1.5),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF3E2723),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Golden Stars Badge
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(stars, (i) {
                          return const Padding(
                            padding: EdgeInsets.only(left: 1),
                            child: Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFD54F),
                              shadows: [
                                Shadow(
                                  color: Color(0xFFFF8F00),
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // Center Pedestal with 3D Pixar Icon
                  Center(
                    child: Container(
                      width: widget.isCompact ? 58 : 68,
                      height: widget.isCompact ? 58 : 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white,
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: islandColor.withOpacity(0.4),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Pixar3DIcon(
                          type: pixarType,
                          size: widget.isCompact ? 42 : 50,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Title Banner & Play Indicator
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Game Title in Bubblegum
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.bubblegumSans(
                          fontSize: widget.isCompact ? 13 : 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          shadows: [
                            const Shadow(
                              color: Color(0xFF2E1C14),
                              offset: Offset(1, 1.5),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Bouncy "PLAY" Action Capsule
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 3.5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCCFF90), Color(0xFF76FF03)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              offset: const Offset(0, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'PLAY',
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1B5E20),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF1B5E20),
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for jagged rock strata underneath the island
class _IslandStratumPainter extends CustomPainter {
  final Color accentColor;

  _IslandStratumPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.16)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.45, size.height * 0.4);
    path.lineTo(size.width * 0.7, size.height * 0.85);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Glowing crystal dots embedded in rock
    final crystalPaint = Paint()
      ..color = accentColor.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width * 0.28, size.height * 0.65), 2.5, crystalPaint);
    canvas.drawCircle(
        Offset(size.width * 0.65, size.height * 0.72), 3.0, crystalPaint);
    canvas.drawCircle(
        Offset(size.width * 0.82, size.height * 0.58), 2.0, crystalPaint);
  }

  @override
  bool shouldRepaint(covariant _IslandStratumPainter oldDelegate) => false;
}

class _IslandSparkle {
  final Offset offset;
  final Color color;
  final double size;

  _IslandSparkle({
    required this.offset,
    required this.color,
    required this.size,
  });
}
