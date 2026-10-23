import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/confetti_celebration.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g001_controller.dart';
import 'mosaic_generator.dart';

/// 1-1000 Number Focus Mosaic Quiz View
/// Accurately renders the reference photo design:
/// - Circular cobblestone mosaic disk with 50 organic Voronoi cells
/// - Dark focus atmosphere
/// - "Find 1 to 50" header with highlighted current target
/// - "00:03" stopwatch timer
/// - 20 Stages covering 1 to 1000 in chunks of 50
/// - Hint engine, error wobble, sound effects, and stage complete dialog
class G001View extends StatefulWidget {
  final G001Controller controller;

  const G001View({super.key, required this.controller});

  @override
  State<G001View> createState() => _G001ViewState();
}

class _G001ViewState extends State<G001View> with TickerProviderStateMixin {
  late AnimationController _hintPulseController;
  late AnimationController _wrongShakeController;

  @override
  void initState() {
    super.initState();
    _hintPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _wrongShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _hintPulseController.dispose();
    _wrongShakeController.dispose();
    super.dispose();
  }

  void _onBoardTap(Offset localOffset, Size boardSize) {
    // Find which cell contains localOffset
    for (final cell in widget.controller.cells) {
      if (cell.containsPoint(localOffset, boardSize)) {
        HapticFeedback.lightImpact();

        final isCorrect = cell.number == widget.controller.currentTarget;
        if (!isCorrect) {
          _wrongShakeController.forward(from: 0.0);
        }

        widget.controller.onCellTapped(cell);
        break;
      }
    }
  }

  void _showStagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _buildStagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = widget.controller;

        return Scaffold(
          backgroundColor: const Color(0xFF0C1222), // Midnight Focus Navy matching photo
          body: SafeArea(
            child: Stack(
              children: [
                // Main Game Content
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape = constraints.maxWidth >= constraints.maxHeight;

                    return isLandscape
                        ? _buildLandscapeLayout(constraints, c)
                        : _buildPortraitLayout(constraints, c);
                  },
                ),

                // Stage Completed Celebration Overlay
                if (c.state == GameLifecycleState.completed)
                  _buildStageCompleteOverlay(c),
              ],
            ),
          ),
        );
      },
    );
  }

  /// --------------------------------------------------------------------------
  /// PORTRAIT LAYOUT
  /// --------------------------------------------------------------------------
  Widget _buildPortraitLayout(BoxConstraints constraints, G001Controller c) {
    // Determine responsive board size
    final maxAvailableHeight = constraints.maxHeight - 170;
    final boardSize = math.min(constraints.maxWidth * 0.94, maxAvailableHeight).clamp(240.0, 520.0);

    return Column(
      children: [
        // 1. Top Challenge Header & Stage Selector
        _buildTopHeaderBar(c),

        // 2. "Find X to Y" Title & Current Target
        _buildTargetTitle(c),

        // 3. Digital Stopwatch Timer ("00:03" matching photo)
        _buildStopwatchTimer(c),

        const Spacer(),

        // 4. Circular Mosaic Cobblestone Board (Matching Photo)
        Center(
          child: _buildMosaicBoard(boardSize, c),
        ),

        const Spacer(),

        // 5. Bottom Action Controls (Hint, Stage Select, Replay)
        _buildBottomActionBar(c),
      ],
    );
  }

  /// --------------------------------------------------------------------------
  /// LANDSCAPE LAYOUT
  /// --------------------------------------------------------------------------
  Widget _buildLandscapeLayout(BoxConstraints constraints, G001Controller c) {
    final availableH = constraints.maxHeight - 24;
    final availableW = constraints.maxWidth * 0.52;
    final boardSize = math.min(availableH, availableW).clamp(200.0, 410.0);

    return Row(
      children: [
        // Left Column: Header, Target, Timer, Hints
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeaderBar(c, isCompact: true),
                _buildTargetTitle(c),
                _buildStopwatchTimer(c),
                _buildBottomActionBar(c, isHorizontal: true),
              ],
            ),
          ),
        ),

        // Right Column: Circular Mosaic Board
        Expanded(
          flex: 5,
          child: Center(
            child: _buildMosaicBoard(boardSize, c),
          ),
        ),
      ],
    );
  }

  /// Top Challenge Header: "STAGE X / 20 (Start-End)" with interactive prev/next stepper
  Widget _buildTopHeaderBar(G001Controller c, {bool isCompact = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          // Stage Navigation Stepper: ◀ STAGE X/20 (Start-End) ▶
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back Button (Top Left)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2438),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C3954), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Previous Stage
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  c.prevStage();
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2438),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C3954), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF4FC3F7),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Stage Pill (Tap to open 1-1000 Map)
              GestureDetector(
                onTap: () => _showStagePickerModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2438),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF4FC3F7).withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'STAGE ${c.currentStage}/${G001Controller.totalStages} ',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4FC3F7),
                        ),
                      ),
                      Text(
                        '(${c.rangeStart}-${c.rangeEnd})',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF4FC3F7), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Next Stage
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  c.nextStage();
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2438),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C3954), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF4FC3F7),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),

          // Stage Picker Button
          GestureDetector(
            onTap: () => _showStagePickerModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.grid_view_rounded, color: Color(0xFF4E342E), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '1-1000 MAP',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4E342E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Title Prompt: "Find X to Y" with current target highlighted
  Widget _buildTargetTitle(G001Controller c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Find ${c.rangeStart} to ${c.rangeEnd}',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withOpacity(0.4),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  'Next: ${c.currentTarget}',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Stage ${c.currentStage} of ${G001Controller.totalStages} • 1 to 1000 Mosaic Journey',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF90A4AE),
            ),
          ),
          const SizedBox(height: 4),
          // Progress line
          Container(
            width: 140,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3954),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: c.progressFraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Digital Stopwatch Timer ("00:03" in coral red matching photo)
  Widget _buildStopwatchTimer(G001Controller c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        c.timerString,
        style: GoogleFonts.nunito(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFF5252), // Coral red from photo
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: const Color(0xFFFF5252).withOpacity(0.35),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }

  /// The Circular Cobblestone Mosaic Board
  Widget _buildMosaicBoard(double boardSize, G001Controller c) {
    final size = Size(boardSize, boardSize);

    return AnimatedBuilder(
      animation: Listenable.merge([_hintPulseController, _wrongShakeController]),
      builder: (context, _) {
        final shakeOffset = math.sin(_wrongShakeController.value * math.pi * 4) * 8.0;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: GestureDetector(
            onTapUp: (details) {
              _onBoardTap(details.localPosition, size);
            },
            child: Container(
              width: boardSize,
              height: boardSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141A29),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                  ),
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.12),
                    offset: const Offset(0, 2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: CustomPaint(
                  size: size,
                  painter: _CobblestoneMosaicPainter(
                    cells: c.cells,
                    completedNumbers: c.completedNumbers,
                    currentTarget: c.currentTarget,
                    hintedNumber: c.hintedNumber,
                    wrongTappedNumber: c.lastTappedWrongNumber,
                    hintPulse: _hintPulseController.value,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Bottom Action Bar: Hint, Stage Select, Restart
  Widget _buildBottomActionBar(G001Controller c, {bool isHorizontal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // 1. Hint Button (Golden 💡)
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              c.useHint();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E283D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'HINT',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 14),

          // 2. Restart Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              c.restartStage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E283D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF90A4AE), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, color: Color(0xFFB0BEC5), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'RESTART',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFB0BEC5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 14),

          // 3. Stages Map Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showStagePickerModal(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E283D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF4FC3F7), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.grid_view_rounded, color: Color(0xFF4FC3F7), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'STAGES',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4FC3F7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Stage Complete Celebration Overlay
  Widget _buildStageCompleteOverlay(G001Controller c) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti celebration
          const ConfettiCelebration(),

          // Card
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: 310,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF263238), Color(0xFF1A2127)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFD54F), width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'STAGE ${c.currentStage} CLEARED!',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ),
                  Text(
                    'Found ${c.rangeStart} to ${c.rangeEnd} in ${c.timerString}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final earned = i < c.starsEarned;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          earned ? '⭐' : '☆',
                          style: TextStyle(
                            fontSize: 26,
                            color: earned ? const Color(0xFFFFD54F) : Colors.grey,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // "NEXT STAGE ➔" Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      c.nextStage();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E676), Color(0xFF00C853)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.4),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            c.currentStage < G001Controller.totalStages
                                ? 'NEXT STAGE (${c.rangeEnd + 1}–${c.rangeEnd + 50}) ➔'
                                : 'STAGE SELECT 🗺️',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // "PLAY AGAIN" Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      c.restartStage();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'PLAY THIS STAGE AGAIN 🔄',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFB74D),
                        ),
                      ),
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

  /// Stage Picker Bottom Sheet: All 20 stages from 1 to 1000 (chunks of 50)
  Widget _buildStagePickerSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFF141C2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF2C3954), width: 3),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1 to 1000 STAGES',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Pick any 50-number challenge',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF90A4AE),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF2C3954), height: 1),

          // Grid of 20 Stages
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: G001Controller.totalStages,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final stage = index + 1;
                final (start, end) = G001Controller.getStageRange(stage);
                final isCurrent = stage == widget.controller.currentStage;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.controller.selectStage(stage);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isCurrent
                            ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                            : [const Color(0xFF212C45), const Color(0xFF182238)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? Colors.white : const Color(0xFF334469),
                        width: isCurrent ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'STAGE $stage',
                          style: GoogleFonts.nunito(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isCurrent ? Colors.white : const Color(0xFF90A4AE),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$start-$end',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isCurrent ? Colors.white : const Color(0xFF4FC3F7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the 50 cobblestone Voronoi mosaic cells
class _CobblestoneMosaicPainter extends CustomPainter {
  final List<MosaicCell> cells;
  final Set<int> completedNumbers;
  final int currentTarget;
  final int? hintedNumber;
  final int? wrongTappedNumber;
  final double hintPulse;

  _CobblestoneMosaicPainter({
    required this.cells,
    required this.completedNumbers,
    required this.currentTarget,
    required this.hintedNumber,
    required this.wrongTappedNumber,
    required this.hintPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark grout outline paint
    final groutPaint = Paint()
      ..color = const Color(0xFF121620) // Dark grout lines from photo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 2. Iterate and draw each cell
    for (final cell in cells) {
      final isCompleted = completedNumbers.contains(cell.number);
      final isTarget = cell.number == currentTarget;
      final isHinted = cell.number == hintedNumber;
      final isWrong = cell.number == wrongTappedNumber;

      final path = cell.getPath(size);
      final centroid = cell.getCentroid(size);

      // Determine cell fill color
      Color fillColor;
      if (isCompleted) {
        fillColor = const Color(0xFFC8E6C9); // Soft pastel green for completed
      } else if (isHinted) {
        fillColor = Color.lerp(const Color(0xFFFAF7F2), const Color(0xFFFFD54F), hintPulse)!;
      } else if (isWrong) {
        fillColor = const Color(0xFFFFCDD2); // Soft red flash on wrong tap
      } else {
        fillColor = const Color(0xFFFAF7F2); // Ivory cream cobblestone matching photo
      }

      final cellPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      // Draw cell body
      canvas.drawPath(path, cellPaint);

      // Draw dark grout border
      canvas.drawPath(path, groutPaint);

      // If hinted, draw glowing pulse border
      if (isHinted) {
        final glowBorder = Paint()
          ..color = const Color(0xFFFFD54F).withOpacity(0.8 * hintPulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5;
        canvas.drawPath(path, glowBorder);
      }

      // 3. Draw Number Text at cell centroid
      _drawCellText(canvas, cell.number, centroid, isCompleted, isTarget);
    }
  }

  void _drawCellText(
    Canvas canvas,
    int number,
    Offset centroid,
    bool isCompleted,
    bool isTarget,
  ) {
    // Color: Red if target (matching photo where "1" is in red), green if completed, dark charcoal otherwise
    Color textColor;
    if (isCompleted) {
      textColor = const Color(0xFF2E7D32); // Deep forest green
    } else if (isTarget) {
      textColor = const Color(0xFFFF5252); // Vibrant coral red matching photo!
    } else {
      textColor = const Color(0xFF1E2024); // Dark charcoal matching photo
    }

    // Adjust font size based on cell count and number of digits
    final digits = number.toString().length;
    double fontSize;
    if (cells.length <= 12) {
      // 10-cell stages (1-100 in groups of 10) have spacious cells
      fontSize = digits <= 2 ? 26.0 : 20.0;
    } else {
      // 50-cell stages
      fontSize = 17.5;
      if (digits == 3) {
        fontSize = 14.5;
      } else if (digits >= 4) {
        fontSize = 11.5;
      }
    }

    final textSpan = TextSpan(
      text: '$number',
      style: GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: textColor,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final textOffset = Offset(
      centroid.dx - textPainter.width / 2,
      centroid.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _CobblestoneMosaicPainter oldDelegate) {
    return oldDelegate.completedNumbers != completedNumbers ||
        oldDelegate.currentTarget != currentTarget ||
        oldDelegate.hintedNumber != hintedNumber ||
        oldDelegate.wrongTappedNumber != wrongTappedNumber ||
        oldDelegate.hintPulse != hintPulse;
  }
}
