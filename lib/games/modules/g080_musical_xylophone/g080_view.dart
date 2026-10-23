import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/cartoon_ui_components.dart';
import 'g080_controller.dart';

class G080View extends StatefulWidget {
  final G080Controller controller;

  const G080View({super.key, required this.controller});

  @override
  State<G080View> createState() => _G080ViewState();
}

class _G080ViewState extends State<G080View> with TickerProviderStateMixin {
  late AnimationController _bounceGuideController;

  static const List<Color> barColors = [
    Color(0xFFE53935), // C4: Red
    Color(0xFFFB8C00), // D4: Orange
    Color(0xFFFDD835), // E4: Yellow
    Color(0xFF43A047), // F4: Green
    Color(0xFF00ACC1), // G4: Cyan
    Color(0xFF1E88E5), // A4: Blue
    Color(0xFF8E24AA), // B4: Purple
    Color(0xFFD81B60), // C5: Deep Pink
  ];

  @override
  void initState() {
    super.initState();
    _bounceGuideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceGuideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

        return Scaffold(
          backgroundColor: const Color(0xFFE8F5E9),
          body: SafeArea(
            child: Stack(
              children: [
                // Scenic Meadow Pattern Background
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE1F5FE), Color(0xFFC8E6C9)],
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // Top Navigation & Song Progress Bar
                    _buildTopHeader(ctrl),

                    // Center: The 8-Key Rainbow Musical Xylophone with Giant Buttons
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                        child: _buildXylophoneFrame(ctrl, isPortrait),
                      ),
                    ),
                  ],
                ),

                // Song Completed Victory Celebration Overlay
                if (ctrl.isSongCompleted) _buildVictoryCelebration(ctrl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(G080Controller ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back to Home Button
          CandyPillButton(
            width: 44,
            height: 40,
            borderRadius: 20,
            color: const Color(0xFFFFCC80),
            borderColor: Colors.white,
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFE65100), size: 22),
          ),
          const SizedBox(width: 8),

          // Mode Toggle Pill
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick().catchError((_) {});
              ctrl.toggleMode();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ctrl.isFreePlay
                      ? [const Color(0xFF7B1FA2), const Color(0xFFAB47BC)]
                      : [const Color(0xFF0288D1), const Color(0xFF29B6F6)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: (ctrl.isFreePlay ? Colors.purple : Colors.blue).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ctrl.isFreePlay ? Icons.piano_rounded : Icons.music_note_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ctrl.isFreePlay ? 'FREE PLAY' : 'SONG MODE',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Active Song Information & Notes Played
          Expanded(
            child: ctrl.isFreePlay
                ? Text(
                    'Tap any rainbow bar to create music! 🎶',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 16,
                      color: const Color(0xFF4A148C),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(ctrl.currentSong.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ctrl.currentSong.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                          Text(
                            '${ctrl.songStep}/${ctrl.currentSong.notes.length}',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ctrl.currentSong.notes.isEmpty
                              ? 0
                              : ctrl.songStep / ctrl.currentSong.notes.length,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF43A047)),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(width: 8),

          // Next Song Button
          if (!ctrl.isFreePlay)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact().catchError((_) {});
                ctrl.nextSong();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildXylophoneFrame(G080Controller ctrl, bool isPortrait) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPortrait ? 10 : 14,
        vertical: isPortrait ? 10 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63), // Rich wood soundboard
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF5D4037), width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isPortrait
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(8, (index) {
                final isTarget = index == ctrl.targetNoteIndex;
                // Bars taper organically: lower note (0) is widest, higher note (7) is shortest
                final lengthRatio = 0.98 - (index * 0.032);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: _buildHorizontalXylophoneBar(
                      index: index,
                      color: barColors[index],
                      lengthRatio: lengthRatio,
                      isTarget: isTarget,
                      onTap: () {
                        HapticFeedback.selectionClick().catchError((_) {});
                        ctrl.tapNote(index);
                      },
                    ),
                  ),
                );
              }),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(8, (index) {
                final isTarget = index == ctrl.targetNoteIndex;
                final lengthRatio = 1.0 - (index * 0.042);

                return Expanded(
                  child: _buildVerticalXylophoneBar(
                    index: index,
                    color: barColors[index],
                    lengthRatio: lengthRatio,
                    isTarget: isTarget,
                    onTap: () {
                      HapticFeedback.selectionClick().catchError((_) {});
                      ctrl.tapNote(index);
                    },
                  ),
                );
              }),
            ),
    );
  }

  /// Big chunky horizontal bar for mobile portrait view (Full Width & Tall Tap Target)
  Widget _buildHorizontalXylophoneBar({
    required int index,
    required Color color,
    required double lengthRatio,
    required bool isTarget,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth * lengthRatio;
        final solfegeName = G080Controller.solfege[index];
        final noteLetter = G080Controller.noteNames[index];

        return Center(
          child: SizedBox(
            width: barWidth,
            height: constraints.maxHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Metallic Rainbow Bar with massive touch target
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.95),
                          color,
                          HSLColor.fromColor(color).withLightness(0.38).toColor(),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isTarget ? const Color(0xFFFFEB3B) : Colors.white.withOpacity(0.75),
                        width: isTarget ? 3.5 : 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isTarget
                              ? color.withOpacity(0.7)
                              : Colors.black.withOpacity(0.25),
                          blurRadius: isTarget ? 14 : 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSilverRivet(),
                        // Big bold centered note info
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              noteLetter,
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                solfegeName,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildSilverRivet(),
                      ],
                    ),
                  ),
                ),

                // Floating Bouncing Star Guide if target note in play-along mode
                if (isTarget)
                  Positioned(
                    right: -12,
                    child: AnimatedBuilder(
                      animation: _bounceGuideController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, math.sin(_bounceGuideController.value * math.pi) * 6),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD54F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text('⭐', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Big chunky vertical bar for landscape/tablet view
  Widget _buildVerticalXylophoneBar({
    required int index,
    required Color color,
    required double lengthRatio,
    required bool isTarget,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        final barHeight = totalHeight * lengthRatio;
        final solfegeName = G080Controller.solfege[index];
        final noteLetter = G080Controller.noteNames[index];

        return Center(
          child: SizedBox(
            height: barHeight,
            width: constraints.maxWidth * 0.90,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Floating Bouncing Star Guide if target note in play-along mode
                if (isTarget)
                  Positioned(
                    top: -32 + math.sin(_bounceGuideController.value * math.pi) * 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD54F),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Text('⭐', style: TextStyle(fontSize: 16)),
                    ),
                  ),

                // Metallic Rainbow Bar
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.95),
                          color,
                          HSLColor.fromColor(color).withLightness(0.35).toColor(),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isTarget ? const Color(0xFFFFEB3B) : Colors.white.withOpacity(0.75),
                        width: isTarget ? 3.5 : 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isTarget
                              ? color.withOpacity(0.6)
                              : Colors.black.withOpacity(0.25),
                          blurRadius: isTarget ? 14 : 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 10,
                          child: _buildSilverRivet(),
                        ),
                        Positioned(
                          bottom: 10,
                          child: _buildSilverRivet(),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              noteLetter,
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              solfegeName,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSilverRivet() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFFCFD8DC),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF78909C), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
    );
  }

  Widget _buildVictoryCelebration(G080Controller ctrl) {
    return Container(
      color: Colors.black.withOpacity(0.55),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFFB300), width: 4),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉 🎵 🌟', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'SONG COMPLETED!',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You played "${ctrl.currentSong.title}" like a royal maestro!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact().catchError((_) {});
                          ctrl.restart();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42A5F5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: Text('Replay', style: GoogleFonts.bubblegumSans(fontSize: 16)),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact().catchError((_) {});
                          ctrl.nextSong();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: Text('Next Song 🎶', style: GoogleFonts.bubblegumSans(fontSize: 16)),
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
}
