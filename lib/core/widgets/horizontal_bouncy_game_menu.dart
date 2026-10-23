import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/procedural_sfx_engine.dart';
import 'funny_pixar_characters.dart';
import 'playful_bouncing_effects.dart';

/// Style variants for mini-game showcase cards in the carousel
enum GameCardStyle {
  /// 3D Floating Adventure Stage Diorama with isometric pedestal, glowing portal, and tactile control dock
  dioramaStage,

  /// Original Toy-Box Pop-Out with comic speech bubble and full-width candy button
  toyBox,
}

/// Horizontal Bouncy Mini Game Menu
/// Displays the game islands one at a time with:
/// - Smooth horizontal swiping from left to right
/// - Fun bouncy spring & parabolic hopping animation between screens
/// - Playful procedural sound effect on every swipe
/// - Tactile left/right candy stepper arrows
/// - Animated progress dots and "Game X of Y" counter
class HorizontalBouncyGameMenu extends StatefulWidget {
  final List<Map<String, dynamic>> islands;
  final void Function(String gameId) onLaunchGame;
  final bool isLandscape;
  final int initialIndex;
  final GameCardStyle cardStyle;

  const HorizontalBouncyGameMenu({
    super.key,
    required this.islands,
    required this.onLaunchGame,
    this.isLandscape = false,
    this.initialIndex = 0,
    this.cardStyle = GameCardStyle.dioramaStage,
  });

  @override
  State<HorizontalBouncyGameMenu> createState() =>
      _HorizontalBouncyGameMenuState();
}

class _HorizontalBouncyGameMenuState extends State<HorizontalBouncyGameMenu>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _idleFloatController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.islands.length - 1);
    final viewportFraction = widget.isLandscape ? 0.60 : 0.85;
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: viewportFraction,
    );

    // Continuous breathing float animation for the active center card
    _idleFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant HorizontalBouncyGameMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLandscape != widget.isLandscape) {
      final viewportFraction = widget.isLandscape ? 0.60 : 0.85;
      final current = _currentIndex;
      final old = _pageController;
      _pageController = PageController(
        initialPage: current,
        viewportFraction: viewportFraction,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          old.dispose();
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _idleFloatController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick().catchError((_) {});
      // Play boing sound on every horizontal card swipe
      ProceduralSfxEngine().playBoing();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.islands.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
      );
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final islands = widget.islands;
    if (islands.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Main Horizontal Bouncy PageView Carousel
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: _onPageChanged,
                itemCount: islands.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: Listenable.merge([_pageController, _idleFloatController]),
                    builder: (context, child) {
                      double pageOffset = 0.0;
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        pageOffset = (_pageController.page ?? _currentIndex.toDouble()) - index;
                      } else {
                        pageOffset = (_currentIndex - index).toDouble();
                      }

                      final absDiff = pageOffset.abs().clamp(0.0, 1.0);

                      // Fun bouncy transformations:
                      // 1. Scale down neighboring cards
                      final scale = 1.0 - (absDiff * 0.16);
                      // 2. Parabolic vertical hopping bounce as card enters center
                      final bounceHop = -math.sin((1.0 - absDiff) * math.pi) * 16.0;
                      // 3. Playful 3D tilt rotation
                      final tiltAngle = (pageOffset * 0.06).clamp(-0.25, 0.25);
                      // 4. Subtle opacity for inactive cards
                      final opacity = (1.0 - (absDiff * 0.35)).clamp(0.4, 1.0);

                      // Idle floating bobbing for center card
                      final isCenter = absDiff < 0.2;
                      final idleBob = isCenter
                          ? (math.sin(_idleFloatController.value * math.pi * 2) * 4.0)
                          : 0.0;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(0.0, bounceHop + idleBob)
                          ..rotateZ(tiltAngle)
                          ..scale(scale),
                        child: Opacity(
                          opacity: opacity,
                          child: _buildGameCard(islands[index], index, isCenter),
                        ),
                      );
                    },
                  );
                },
              ),

              // Left Stepper Arrow Button (◀)
              if (_currentIndex > 0)
                Positioned(
                  left: 6,
                  child: _buildStepperArrow(
                    icon: Icons.arrow_back_ios_rounded,
                    onTap: _goToPrevious,
                  ),
                ),

              // Right Stepper Arrow Button (▶)
              if (_currentIndex < islands.length - 1)
                Positioned(
                  right: 6,
                  child: _buildStepperArrow(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: _goToNext,
                  ),
                ),
            ],
          ),
        ),

        // Bottom Controls: Game Counter Pill & Interactive Dots
        _buildBottomPaginationControls(islands.length),
      ],
    );
  }

  /// Delegates to selected card style
  Widget _buildGameCard(
    Map<String, dynamic> island,
    int index,
    bool isCenter,
  ) {
    if (widget.cardStyle == GameCardStyle.toyBox) {
      return _buildToyBoxCard(island, index, isCenter);
    }
    return _buildDioramaStageCard(island, index, isCenter);
  }

  /// =========================================================================
  /// STYLE 1: 3D FLOATING ADVENTURE STAGE DIORAMA (Default)
  /// Featuring arched capsule geometry, glowing portal arch, 3D isometric
  /// stage pedestal, floor contact shadows, speech cloud, and tactile control dock.
  /// =========================================================================
  Widget _buildDioramaStageCard(
    Map<String, dynamic> island,
    int index,
    bool isCenter,
  ) {
    final islandColor = island['islandColor'] as Color? ?? const Color(0xFF1E88E5);
    final accentColor = island['accent'] as Color? ?? const Color(0xFFFFD54F);
    final title = island['title'] as String? ?? '';
    final subtitle = island['subtitle'] as String? ?? '';
    final gameId = island['id'] as String? ?? '';
    final charInfo = FunnyCharacterInfo.forGameId(gameId);

    return Center(
      child: BouncyBounceTap(
        onTap: () {
          widget.onLaunchGame(gameId);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(38),
              topRight: Radius.circular(38),
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(islandColor, Colors.white, 0.16)!,
                islandColor,
                Color.lerp(islandColor, const Color(0xFF0F172A), 0.45)!,
              ],
              stops: const [0.0, 0.42, 1.0],
            ),
            border: Border.all(
              color: isCenter ? Colors.white : Colors.white.withOpacity(0.70),
              width: isCenter ? 3.8 : 2.4,
            ),
            boxShadow: [
              BoxShadow(
                color: islandColor.withOpacity(isCenter ? 0.55 : 0.22),
                offset: const Offset(0, 12),
                blurRadius: isCenter ? 24 : 12,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.32),
                offset: const Offset(0, 5),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
            child: Stack(
              children: [
                // Top Curved Gloss Specular Highlight Arch
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  height: 18,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.40),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                ),

                // Main Card Content Layout
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Column(
                    children: [
                      // 1. Top Ribbon: Category Capsule & Golden 3D Stars
                      _buildDioramaTopRibbon(charInfo, accentColor, index),

                      // 2. Center Diorama Stage: Portal + 3D Pedestal + Mascot
                      Expanded(
                        child: _buildDioramaStageCenter(
                          charInfo: charInfo,
                          accentColor: accentColor,
                          islandColor: islandColor,
                          isCenter: isCenter,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // 3. Lower Control Dock with Title & Chunky Play Trigger
                      _buildDioramaControlTray(
                        title: title,
                        subtitle: subtitle,
                        charInfo: charInfo,
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Top Ribbon for Diorama Style
  Widget _buildDioramaTopRibbon(
    FunnyCharacterInfo charInfo,
    Color accentColor,
    int index,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Category Badge Capsule with Game Number
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.38),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withOpacity(0.9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                charInfo.tagBadge,
                style: GoogleFonts.bubblegumSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        // Golden 3D Stars Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF9EE), Color(0xFFFFECB3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFB300), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8F00).withOpacity(0.35),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('⭐', style: TextStyle(fontSize: 11)),
              SizedBox(width: 1),
              Text('⭐', style: TextStyle(fontSize: 11)),
              SizedBox(width: 1),
              Text('⭐', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  /// Center Stage Area with Rainbow Portal, 3D Stage Pedestal, and Mascot
  Widget _buildDioramaStageCenter({
    required FunnyCharacterInfo charInfo,
    required Color accentColor,
    required Color islandColor,
    required bool isCenter,
  }) {
    final charSize = widget.isLandscape ? 92.0 : 114.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stageW = (constraints.maxWidth * 0.76).clamp(140.0, 220.0);
        final stageH = widget.isLandscape ? 34.0 : 42.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // A. Glowing Portal Glow
            Positioned(
              top: widget.isLandscape ? 2 : 6,
              child: Container(
                width: charSize * 1.35,
                height: charSize * 1.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withOpacity(0.35),
                      Colors.white.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.65, 1.0],
                  ),
                ),
              ),
            ),

            // B. Portal Ring Arch with neon bloom
            Positioned(
              top: widget.isLandscape ? 6 : 10,
              child: Container(
                width: charSize * 1.18,
                height: charSize * 1.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.40),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // C. Floating Sparkles
            Positioned(
              top: 4,
              left: constraints.maxWidth * 0.16,
              child: const Text('✨', style: TextStyle(fontSize: 13)),
            ),
            Positioned(
              top: 12,
              right: constraints.maxWidth * 0.14,
              child: const Text('⭐', style: TextStyle(fontSize: 11)),
            ),

            // D. 3D Floating Stage Pedestal Platform
            Positioned(
              bottom: widget.isLandscape ? 2 : 4,
              child: SizedBox(
                width: stageW,
                height: stageH,
                child: CustomPaint(
                  painter: _StagePedestalPainter(
                    topColor: Color.lerp(accentColor, Colors.white, 0.45)!,
                    rimColor: Color.lerp(accentColor, const Color(0xFF3E2723), 0.35)!,
                    shadowColor: Colors.black.withOpacity(0.38),
                  ),
                ),
              ),
            ),

            // E. Funny Pixar 3D Mascot standing on the stage
            Positioned(
              bottom: widget.isLandscape ? 16 : 22,
              child: FunnyPixarCharacterWidget(
                type: charInfo.type,
                size: charSize,
                animate: isCenter,
              ),
            ),

            // F. Comic Speech Cloud Bubble
            Positioned(
              top: widget.isLandscape ? 0 : 2,
              right: 4,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: widget.isLandscape ? 135 : 155,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF263238),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  charInfo.speechQuote,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: widget.isLandscape ? 10 : 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Lower Control Dock with Title, Subtitle, and Chunky 3D Play Trigger
  Widget _buildDioramaControlTray({
    required String title,
    required String subtitle,
    required FunnyCharacterInfo charInfo,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: widget.isLandscape ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side: Mascot Name + Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mascot name mini pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withOpacity(0.6),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    charInfo.name,
                    style: GoogleFonts.bubblegumSans(
                      fontSize: widget.isLandscape ? 10 : 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFE082),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // Game Title with 3D drop-shadow
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: widget.isLandscape ? 15 : 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.4,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.7),
                        offset: const Offset(1, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),

                // Subtitle
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: widget.isLandscape ? 9.5 : 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right side: Chunky 3D "PLAY NOW" Candy Button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isLandscape ? 10 : 12,
              vertical: widget.isLandscape ? 7 : 9,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFEE58),
                  Color(0xFFFFB300),
                  Color(0xFFFF8F00),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                const BoxShadow(
                  color: Color(0xFFBF360C),
                  offset: Offset(0, 3.5),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  offset: const Offset(0, 5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎮', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  'PLAY NOW',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: widget.isLandscape ? 11 : 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF3E2723),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================================================================
  /// STYLE 2: TOY-BOX POP-OUT CARD (Alternative Style)
  /// =========================================================================
  Widget _buildToyBoxCard(
    Map<String, dynamic> island,
    int index,
    bool isCenter,
  ) {
    final islandColor = island['islandColor'] as Color? ?? const Color(0xFF1E88E5);
    final accentColor = island['accent'] as Color? ?? const Color(0xFFFFD54F);
    final title = island['title'] as String? ?? '';
    final subtitle = island['subtitle'] as String? ?? '';
    final gameId = island['id'] as String? ?? '';
    final charInfo = FunnyCharacterInfo.forGameId(gameId);

    return Center(
      child: BouncyBounceTap(
        onTap: () {
          widget.onLaunchGame(gameId);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                islandColor.withOpacity(0.95),
                Color.lerp(islandColor, const Color(0xFF1A237E), 0.35)!,
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isCenter ? Colors.white : Colors.white.withOpacity(0.65),
              width: isCenter ? 4.0 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: islandColor.withOpacity(isCenter ? 0.50 : 0.22),
                offset: const Offset(0, 12),
                blurRadius: isCenter ? 24 : 12,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Ribbon: Character Tag + Milestone Badge + Golden Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accentColor.withOpacity(0.85),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      charInfo.tagBadge,
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⭐', style: TextStyle(fontSize: 11)),
                        Text('⭐', style: TextStyle(fontSize: 11)),
                        Text('⭐', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Center Stage: Mascot with Speech Bubble
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: widget.isLandscape ? 120 : 140,
                      height: widget.isLandscape ? 120 : 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: FunnyPixarCharacterWidget(
                        type: charInfo.type,
                        size: widget.isLandscape ? 94 : 116,
                        animate: isCenter,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 4,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: widget.isLandscape ? 130 : 150,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF37474F),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          charInfo.speechQuote,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.bubblegumSans(
                            fontSize: widget.isLandscape ? 10 : 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF263238),
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Character Name Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  charInfo.name,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: widget.isLandscape ? 11 : 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFE082),
                    letterSpacing: 0.4,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // Game Title
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.bubblegumSans(
                  fontSize: widget.isLandscape ? 18 : 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.6,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.65),
                      offset: const Offset(1, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),

              // Subtitle Description
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: widget.isLandscape ? 10.5 : 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.92),
                ),
              ),

              const SizedBox(height: 8),

              // Full-Width "PLAY NOW 🎮" Candy Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      Color.lerp(accentColor, Colors.orange, 0.45)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.45),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎮', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'PLAY NOW',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF3E2723),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouncy Candy Stepper Arrow (◀ / ▶)
  Widget _buildStepperArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return BouncyBounceTap(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF9EE), Color(0xFFFFE082)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFFFB300), width: 2.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF5D4037),
          ),
        ),
      ),
    );
  }

  /// Bottom Counter & Dot Indicator Pill
  Widget _buildBottomPaginationControls(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BouncyBounceTap(
            onTap: () {
              HapticFeedback.lightImpact().catchError((_) {});
              ProceduralSfxEngine().playSparkle();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🧭', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    'Game ${_currentIndex + 1} of $total',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter that renders an isometric 3D floating stage pedestal disc
/// with depth rim, ambient floor shadow, radiant top surface, and character contact shadow.
class _StagePedestalPainter extends CustomPainter {
  final Color topColor;
  final Color rimColor;
  final Color shadowColor;

  _StagePedestalPainter({
    required this.topColor,
    required this.rimColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rimDepth = h * 0.32;
    final ellipseH = h - rimDepth;

    // 1. Ambient Drop Shadow under the stage
    final shadowRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.72),
      width: w * 0.94,
      height: ellipseH * 0.75,
    );
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(shadowRect, shadowPaint);

    // 2. 3D Rim (Extrusion cylinder)
    final topRect = Rect.fromLTWH(0, 0, w, ellipseH);
    final bottomRect = Rect.fromLTWH(0, rimDepth, w, ellipseH);

    final rimPath = Path()
      ..moveTo(0, ellipseH / 2)
      ..arcTo(topRect, math.pi, -math.pi, false)
      ..lineTo(w, ellipseH / 2 + rimDepth)
      ..arcTo(bottomRect, 0, math.pi, false)
      ..close();

    final rimPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          rimColor,
          Color.lerp(rimColor, Colors.black, 0.45)!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(rimPath, rimPaint);

    // Rim specular bottom edge
    final rimOutlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(bottomRect, 0, math.pi, false, rimOutlinePaint);

    // 3. Top Stage Ellipse surface
    final surfacePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.85,
        colors: [
          Colors.white,
          topColor,
          Color.lerp(topColor, rimColor, 0.4)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(topRect);
    canvas.drawOval(topRect, surfacePaint);

    // Top surface border ring
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawOval(topRect, borderPaint);

    // Concentric stage inner circle inlay
    final innerRect = Rect.fromCenter(
      center: Offset(w / 2, ellipseH / 2),
      width: w * 0.65,
      height: ellipseH * 0.60,
    );
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(innerRect, innerPaint);

    // 4. Contact Shadow directly under character's feet
    final contactShadowRect = Rect.fromCenter(
      center: Offset(w / 2, ellipseH * 0.52),
      width: w * 0.42,
      height: ellipseH * 0.36,
    );
    final contactPaint = Paint()
      ..color = Colors.black.withOpacity(0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(contactShadowRect, contactPaint);
  }

  @override
  bool shouldRepaint(covariant _StagePedestalPainter oldDelegate) => false;
}
