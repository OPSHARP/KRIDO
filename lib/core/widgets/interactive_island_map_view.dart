import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'interactive_floating_island.dart';
import 'playful_bouncing_effects.dart';

/// Interactive Island Map View
/// Transforms the game cards into an adventurous archipelago map where floating
/// 3D islands are arranged along an undulating, organic winding path.
///
/// Features:
/// - Dual Orientation: Horizontal panoramic archipelago in Landscape; Winding S-curve in Portrait
/// - Unified Full Screen Scrolling: Supports an optional header in portrait mode so the whole screen scrolls up together
/// - Custom-painted stepping-stone adventure path connecting islands sequentially
/// - Atmospheric animated environment: drifting fluffy clouds, friendly sea mascots (dolphin, turtle),
///   and glowing treasure landmarks
/// - Interactive touch sound cues and scaling responses on every island
class InteractiveIslandMapView extends StatefulWidget {
  final List<Map<String, dynamic>> islands;
  final void Function(String gameId) onLaunchGame;
  final bool isLandscape;
  final ScrollController? scrollController;
  final Widget? header;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const InteractiveIslandMapView({
    super.key,
    required this.islands,
    required this.onLaunchGame,
    required this.isLandscape,
    this.scrollController,
    this.header,
    this.physics,
    this.padding,
  });

  @override
  State<InteractiveIslandMapView> createState() =>
      _InteractiveIslandMapViewState();
}

class _InteractiveIslandMapViewState extends State<InteractiveIslandMapView>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _ambientCloudController;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_handleScroll);
    _ambientCloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  void _handleScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final show = _scrollController.offset > 320.0;
    if (show != _showBackToTop) {
      setState(() {
        _showBackToTop = show;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _ambientCloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLandscape
        ? _buildLandscapeMapLayout()
        : _buildPortraitMapLayout();
  }

  /// --------------------------------------------------------------------------
  /// LANDSCAPE MODE: Panoramic Horizontal Winding Archipelago Trail
  /// --------------------------------------------------------------------------
  Widget _buildLandscapeMapLayout() {
    final islands = widget.islands;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : 284.0;
        final islandHeight = (availableHeight - 56.0).clamp(140.0, 224.0);
        final islandWidth = islandHeight * 0.75;
        const islandSpacing = 24.0;
        final totalWidth = (islands.length * (islandWidth + islandSpacing)) + 80.0;
        final waveAmplitude = ((availableHeight - islandHeight - 16.0) / 2.0).clamp(6.0, 24.0);
        final verticalCenter = availableHeight / 2.0;

        return AnimatedBuilder(
          animation: _ambientCloudController,
          builder: (context, _) {
            final cloudOffset = _ambientCloudController.value;

            return ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.02, 0.98, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: totalWidth,
                  height: availableHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Painted Winding Stepping-Stone Trail Connecting Islands
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LandscapeTrailPainter(
                            islandCount: islands.length,
                            islandWidth: islandWidth,
                            islandSpacing: islandSpacing,
                            verticalCenter: verticalCenter,
                            waveAmplitude: waveAmplitude,
                          ),
                        ),
                      ),

                      // 2. Drifting Fluffy Clouds & Sea Mascots in Landscape
                      _buildLandscapeEnvironmentalDeco(cloudOffset, totalWidth),

                      // 3. Floating 3D Islands Positioned Along the Wave Path
                      ...List.generate(islands.length, (index) {
                        final island = islands[index];
                        final leftPos = 24.0 + (index * (islandWidth + islandSpacing));

                        // Undulating vertical sine wave creates the natural archipelago rhythm
                        final waveY = math.sin(index * 1.15) * waveAmplitude;
                        final topPos = (verticalCenter - (islandHeight / 2.0)) + waveY;

                        return Positioned(
                          left: leftPos,
                          top: topPos,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Milestone number flag badge
                              _buildMilestoneFlag(index + 1),
                              const SizedBox(width: 6),
                              InteractiveFloatingIsland(
                                islandData: island,
                                index: index,
                                width: islandWidth,
                                height: islandHeight,
                                onTap: () {
                                  widget.onLaunchGame(island['id'] as String);
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// --------------------------------------------------------------------------
  /// PORTRAIT MODE: Vertical Winding S-Curve Mountain/Sky Archipelago Path
  /// --------------------------------------------------------------------------
  Widget _buildPortraitMapLayout() {
    final islands = widget.islands;
    const itemHeight = 196.0;
    final hasHeader = widget.header != null;
    final totalCount = islands.length + (hasHeader ? 1 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        // Clamp maximum S-curve offset so island never touches horizontal edges
        final maxOffset = ((screenWidth - 230.0) / 2.0).clamp(12.0, 44.0);

        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              physics: widget.physics ?? const BouncingScrollPhysics(),
              padding: widget.padding ??
                  EdgeInsets.fromLTRB(
                    12,
                    hasHeader ? 0 : 10,
                    12,
                    36,
                  ),
              itemCount: totalCount,
              itemBuilder: (context, index) {
                if (hasHeader && index == 0) {
                  return widget.header!;
                }

                final islandIndex = hasHeader ? index - 1 : index;
                final island = islands[islandIndex];

                // S-Curve horizontal shifting: alternates left, center, right
                final curveOffset = math.sin(islandIndex * 1.25) * maxOffset;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: itemHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Connecting Stepping Stone Path between vertical islands
                        if (islandIndex < islands.length - 1)
                          Positioned(
                            bottom: -22,
                            child: _buildVerticalSteppingStones(
                              nextOffset: math.sin((islandIndex + 1) * 1.25) * maxOffset,
                              currentOffset: curveOffset,
                            ),
                          ),

                        // Floating Island with S-Curve Offset
                        Transform.translate(
                          offset: Offset(curveOffset, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Milestone badge
                              _buildMilestoneFlag(islandIndex + 1),
                              const SizedBox(width: 8),

                              InteractiveFloatingIsland(
                                islandData: island,
                                index: islandIndex,
                                width: 172.0,
                                height: 196.0,
                                isCompact: true,
                                onTap: () {
                                  widget.onLaunchGame(island['id'] as String);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Animated Floating "TOP 🦁" Pill Button
            if (_showBackToTop)
              Positioned(
                right: 14,
                bottom: 12,
                child: BouncyBounceTap(
                  onTap: () {
                    HapticFeedback.lightImpact().catchError((_) {});
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🦁', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'TOP ⬆️',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Milestone Number Flag on the Island Coast
  Widget _buildMilestoneFlag(int number) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFF9100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.bubblegumSans(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A2810),
          ),
        ),
      ),
    );
  }

  /// Stepping stone trail between vertically stacked portrait islands
  Widget _buildVerticalSteppingStones({
    required double currentOffset,
    required double nextOffset,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final t = (i + 1) / 4.0;
        final stoneX = (currentOffset * (1 - t)) + (nextOffset * t);

        return Transform.translate(
          offset: Offset(stoneX, i * 6.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 12.0 - (i % 2) * 2,
            height: 12.0 - (i % 2) * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.85),
              border: Border.all(
                color: const Color(0xFFFFD54F),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9100).withOpacity(0.35),
                  offset: const Offset(0, 2),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Atmospheric deco: drifting clouds, playful swimming dolphin, and rainbow peak
  Widget _buildLandscapeEnvironmentalDeco(double cloudOffset, double totalWidth) {
    return Stack(
      children: [
        // Drifting Fluffy Clouds
        Positioned(
          left: (cloudOffset * totalWidth * 0.8) % totalWidth,
          top: 8,
          child: _buildMiniCloud(scale: 0.9),
        ),
        Positioned(
          left: ((cloudOffset + 0.5) * totalWidth * 0.8) % totalWidth,
          top: 18,
          child: _buildMiniCloud(scale: 1.1),
        ),

        // Friendly Dolphin Jumping between Islands 3 and 4
        Positioned(
          left: 560,
          top: 18,
          child: const Text('🐬', style: TextStyle(fontSize: 26)),
        ),

        // Friendly Sea Turtle Swimming near Island 8
        Positioned(
          left: 1280,
          bottom: 12,
          child: const Text('🐢', style: TextStyle(fontSize: 22)),
        ),

        // Glowing Treasure Chest at Island 10
        Positioned(
          left: 1980,
          top: 14,
          child: const Text('💎', style: TextStyle(fontSize: 24)),
        ),

        // Rainbow Arch above Final Destination Island
        Positioned(
          right: 28,
          top: 6,
          child: const Text('🌈', style: TextStyle(fontSize: 32)),
        ),
      ],
    );
  }

  Widget _buildMiniCloud({required double scale}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 72,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.70),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for horizontal winding stepping-stone trail in Landscape mode
class _LandscapeTrailPainter extends CustomPainter {
  final int islandCount;
  final double islandWidth;
  final double islandSpacing;
  final double verticalCenter;
  final double waveAmplitude;

  _LandscapeTrailPainter({
    required this.islandCount,
    required this.islandWidth,
    required this.islandSpacing,
    required this.verticalCenter,
    this.waveAmplitude = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trailPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < islandCount; i++) {
      final x = 24.0 + (i * (islandWidth + islandSpacing)) + (islandWidth * 0.5);
      final waveY = math.sin(i * 1.15) * waveAmplitude;
      final y = verticalCenter + waveY;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX =
            24.0 + ((i - 1) * (islandWidth + islandSpacing)) + (islandWidth * 0.5);
        final prevWaveY = math.sin((i - 1) * 1.15) * waveAmplitude;
        final prevY = verticalCenter + prevWaveY;

        final midX = (prevX + x) / 2;
        final midY = (prevY + y) / 2 - 14.0; // Gentle arch curve

        path.quadraticBezierTo(midX, midY, x, y);

        // Draw glowing stepping dots at midway
        canvas.drawCircle(Offset(midX - 12, midY + 8), 3.5, dotPaint);
        canvas.drawCircle(Offset(midX, midY + 6), 4.5, dotPaint);
        canvas.drawCircle(Offset(midX + 12, midY + 8), 3.5, dotPaint);
      }
    }

    // Draw dashed connection curve
    canvas.drawPath(path, trailPaint);
  }

  @override
  bool shouldRepaint(covariant _LandscapeTrailPainter oldDelegate) =>
      oldDelegate.verticalCenter != verticalCenter ||
      oldDelegate.islandWidth != islandWidth ||
      oldDelegate.waveAmplitude != waveAmplitude;
}
