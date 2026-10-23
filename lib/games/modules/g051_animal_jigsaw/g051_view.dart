import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g051_controller.dart';

class G051View extends StatefulWidget {
  final G051Controller controller;

  const G051View({super.key, required this.controller});

  @override
  State<G051View> createState() => _G051ViewState();
}

class _G051ViewState extends State<G051View>
    with SingleTickerProviderStateMixin {
  late AnimationController _handAnimController;
  final GlobalKey _frameKey = GlobalKey();
  final GlobalKey _pieceKey = GlobalKey();
  final Map<String, GlobalKey> _slotKeys = {};
  bool _isUserDragging = false;

  Timer? _autoAdvanceTimer;
  int _autoAdvanceCountdown = 2;
  Timer? _countdownTicker;

  GlobalKey _getSlotKey(int r, int c) {
    return _slotKeys.putIfAbsent('$r,$c', () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    _handAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

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
    _handAnimController.dispose();
    super.dispose();
  }

  void _onControllerState() {
    if (widget.controller.isPuzzleCompleted) {
      _startAutoAdvance();
    }
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _countdownTicker?.cancel();

    setState(() {
      _autoAdvanceCountdown = 2;
    });

    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_autoAdvanceCountdown > 1) {
        setState(() {
          _autoAdvanceCountdown--;
        });
      } else {
        timer.cancel();
      }
    });

    // Automatically generate the next puzzle after 2.2 seconds celebration
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted && widget.controller.isPuzzleCompleted) {
        widget.controller.generateNextPuzzle();
      }
    });
  }

  void _advanceNextNow() {
    _autoAdvanceTimer?.cancel();
    _countdownTicker?.cancel();
    widget.controller.generateNextPuzzle();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final placedCount = controller.pieces.where((p) => p.isPlaced).length;
        final totalCount = controller.pieces.length;
        final unplacedPieces =
            controller.pieces.where((p) => !p.isPlaced).toList();
        final currentTheme = controller.currentTheme;

        return Stack(
          children: [
            // Ambient cartoon scenic background
            const Positioned.fill(
              child: CartoonScenicBackground(child: SizedBox()),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  _buildTopBar(placedCount, totalCount),

                  const SizedBox(height: 8),

                  // 3D Bubble Title: Dynamic Animal Theme
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: BubbleTitle(
                        text: currentTheme.title,
                        fontSize: 26,
                        leadingIcon: const Text('⭐', style: TextStyle(fontSize: 22)),
                        trailingIcon:
                            const Text('⭐', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Main Wooden Tablet Tray Board with 2 Inset Compartments
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: WoodenTabletFrame(
                        key: _frameKey,
                        borderWidth: 10,
                        cornerRadius: 24,
                        trayColor: const Color(0xFFDAB382), // Warm wood tray
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 580;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                isWide
                                    ? Row(
                                        children: [
                                          // Left Inset Compartment: Pieces to place / Auto Advance
                                          Expanded(
                                            flex: 5,
                                            child: _buildPiecesTray(
                                                unplacedPieces, controller),
                                          ),
                                          const SizedBox(width: 8),
                                          // Right Inset Compartment: Assembled animal board
                                          Expanded(
                                            flex: 6,
                                            child: _buildPuzzleTargetBoard(
                                                controller, unplacedPieces),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Expanded(
                                            flex: controller.isPuzzleCompleted ? 5 : 5,
                                            child: _buildPuzzleTargetBoard(
                                                controller, unplacedPieces),
                                          ),
                                          const SizedBox(height: 6),
                                          Expanded(
                                            flex: controller.isPuzzleCompleted ? 5 : 4,
                                            child: _buildPiecesTray(
                                                unplacedPieces, controller),
                                          ),
                                        ],
                                      ),
                                // Accurate tutorial hand guide overlay
                                if (unplacedPieces.isNotEmpty &&
                                    !_isUserDragging &&
                                    !controller.isPuzzleCompleted)
                                  _buildTutorialHandOverlay(
                                    constraints,
                                    isWide,
                                    unplacedPieces.first,
                                    controller,
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

  /// Top bar with dynamic level and puzzle completion stats
  Widget _buildTopBar(int placedCount, int totalCount) {
    final controller = widget.controller;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Group: Back, Sound, Music, Star count
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CandyPillButton(
                    width: 40,
                    height: 40,
                    color: const Color(0xFFFF7043),
                    borderRadius: 14,
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 5),
                  CandyPillButton(
                    width: 40,
                    height: 40,
                    color: AppTheme.candyOrange,
                    child: const Icon(Icons.volume_up_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 5),
                  CandyPillButton(
                    width: 40,
                    height: 40,
                    color: AppTheme.candyHotPink,
                    child: const Icon(Icons.music_note_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 5),
                  PillBadge(
                    height: 36,
                    backgroundColor: const Color(0xFFC89658),
                    borderColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 3),
                        Text(
                          '$placedCount/$totalCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Right Group: Dynamic Level Badge, Undo/Reset
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Level Badge (shows continuous progress e.g. 1-1, 1-2, 1-3...)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5A866),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LEVEL',
                        style: GoogleFonts.nunito(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '1-${controller.puzzleIndex + 1}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Green Reset Current Puzzle Pill
                CandyPillButton(
                  width: 44,
                  height: 40,
                  color: const Color(0xFF80C94A),
                  borderRadius: 14,
                  child: const Icon(Icons.undo_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    controller.resetCurrentPuzzle();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Left Inset Tray: Pieces to place or Auto-Generating Celebration Card
  Widget _buildPiecesTray(
      List<JigsawPiece> unplacedPieces, G051Controller controller) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: unplacedPieces.isEmpty
          ? const EdgeInsets.all(4)
          : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFBA8A57), // Inset wood well
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8A5928), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: unplacedPieces.isEmpty
          ? _buildPuzzleCompletedAutoAdvance(controller)
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final p = unplacedPieces.first;
                widget.controller.handleAction(
                  GameAction.dragDrop(
                    targetId: 'slot_${p.targetRow}_${p.targetCol}',
                    payload: p.id,
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                // Goal / Target Reference Picture of the assembled realistic animal
                Positioned(
                  right: 18,
                  top: 20,
                  child: GestureDetector(
                    onTap: () {
                      final p = unplacedPieces.first;
                      widget.controller.handleAction(
                        GameAction.dragDrop(
                          targetId: 'slot_${p.targetRow}_${p.targetCol}',
                          payload: p.id,
                        ),
                      );
                    },
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7DD),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFFFB300),
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned.fill(
                              child: controller.currentTheme.imageAsset != null
                                  ? Image.asset(
                                      controller.currentTheme.imageAsset!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Center(
                                        child: Text('🐶', style: TextStyle(fontSize: 44)),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        controller.currentTheme.mainEmoji,
                                        style: const TextStyle(fontSize: 44),
                                      ),
                                    ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              color: const Color(0xFFE65100).withOpacity(0.85),
                              child: Text(
                                'PREVIEW ⭐',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Draggable & Tap-friendly Piece (First unplaced)
                Positioned(
                  left: 18,
                  top: 24,
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerUp: (_) {
                      final p = unplacedPieces.first;
                      widget.controller.handleAction(
                        GameAction.dragDrop(
                          targetId: 'slot_${p.targetRow}_${p.targetCol}',
                          payload: p.id,
                        ),
                      );
                    },
                    child: Draggable<int>(
                      data: unplacedPieces.first.id,
                      onDragStarted: () {
                        setState(() => _isUserDragging = true);
                      },
                      onDragEnd: (_) {
                        setState(() => _isUserDragging = false);
                      },
                      onDraggableCanceled: (_, _) {
                        setState(() => _isUserDragging = false);
                      },
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildPuzzlePieceWidget(
                          unplacedPieces.first,
                          isDragging: true,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildPuzzlePieceWidget(unplacedPieces.first),
                      ),
                      child: Container(
                        key: _pieceKey,
                        child: _buildPuzzlePieceWidget(unplacedPieces.first),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Celebratory Card with Auto-Advance Countdown
  Widget _buildPuzzleCompletedAutoAdvance(G051Controller controller) {
    final nextThemeIndex =
        (controller.puzzleIndex + 1) % G051Controller.animalThemes.length;
    final nextTheme = G051Controller.animalThemes[nextThemeIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isCompact = availableHeight < 240;
        final isUltraCompact = availableHeight < 185;
        final avatarSize = isUltraCompact ? 40.0 : (isCompact ? 52.0 : 66.0);
        final buttonHeight = isUltraCompact ? 32.0 : (isCompact ? 36.0 : 40.0);

        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: isUltraCompact ? 4 : (isCompact ? 6 : 10),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'PUZZLE SOLVED!',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: isCompact ? 16 : 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('⭐', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  SizedBox(height: isUltraCompact ? 1 : 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${controller.currentTheme.animalName} completed!',
                      style: GoogleFonts.nunito(
                        fontSize: isCompact ? 11 : 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A3418),
                      ),
                    ),
                  ),
                  if (controller.currentTheme.imageAsset != null && !isUltraCompact) ...[
                    SizedBox(height: isCompact ? 3 : 5),
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFFB300), width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          controller.currentTheme.imageAsset!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: isUltraCompact ? 2 : (isCompact ? 4 : 5)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF81C784), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🚀', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Next: ${nextTheme.animalName} in ${_autoAdvanceCountdown}s...',
                            style: GoogleFonts.nunito(
                              fontSize: isCompact ? 10 : 11,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isUltraCompact ? 4 : 6),
                  // Instant Next Puzzle Button
                  CandyPillButton(
                    width: 145,
                    height: buttonHeight,
                    color: const Color(0xFF80C94A),
                    borderRadius: 18,
                    onPressed: _advanceNextNow,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NEXT PUZZLE',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: isCompact ? 12 : 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.skip_next_rounded,
                            color: Colors.white, size: isCompact ? 18 : 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Target Grid representing the assembled animal puzzle
  Widget _buildPuzzleTargetBoard(
      G051Controller controller, List<JigsawPiece> unplacedPieces) {
    final dim = controller.gridDimension;
    final activePiece =
        unplacedPieces.isNotEmpty ? unplacedPieces.first : null;

    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFBA8A57),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8A5928), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8CBA3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: dim,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
              ),
              itemCount: dim * dim,
              itemBuilder: (context, index) {
                final r = index ~/ dim;
                final c = index % dim;

                final piece = controller.pieces.firstWhere(
                  (p) => p.targetRow == r && p.targetCol == c,
                );

                final isTargetForActive = activePiece != null &&
                    !piece.isPlaced &&
                    activePiece.targetRow == r &&
                    activePiece.targetCol == c;

                return DragTarget<int>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    controller.handleAction(
                      GameAction.dragDrop(
                        targetId: 'slot_${r}_$c',
                        payload: details.data,
                      ),
                    );
                  },
                  builder: (context, candidates, _) {
                    final isSlotActive = candidates.isNotEmpty;

                    return GestureDetector(
                      key: _getSlotKey(r, c),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        controller.handleAction(
                          GameAction.tap('slot_${r}_$c'),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: piece.isPlaced
                              ? const Color(0xFFFFF9EE)
                              : (isSlotActive
                                  ? const Color(0xFFFFE082)
                                  : (isTargetForActive
                                      ? const Color(0xFFFFF3E0)
                                      : const Color(0xFFD4A373))),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getPieceBorderColor(r, c),
                            width: isTargetForActive ? 4.5 : 3.5,
                          ),
                          boxShadow: isTargetForActive
                              ? [
                                  BoxShadow(
                                    color: _getPieceBorderColor(r, c)
                                        .withOpacity(0.55),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: piece.isPlaced
                            ? _buildAnimalSection(r, c)
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (controller.currentTheme.imageAsset != null)
                                    _buildAnimalSection(r, c, isGhost: true),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSlotActive
                                            ? const Color(0xFFFFB300)
                                            : (isTargetForActive
                                                ? const Color(0xFFFF9800)
                                                : Colors.black
                                                    .withOpacity(0.35)),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        boxShadow: isTargetForActive
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFFF9800)
                                                      .withOpacity(0.5),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: isTargetForActive
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('🎯',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                const SizedBox(width: 3),
                                                Text(
                                                  'PUT HERE!',
                                                  style:
                                                      GoogleFonts.bubblegumSans(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              isSlotActive
                                                  ? 'Drop here!'
                                                  : controller.currentTheme
                                                          .quadrantLabels[
                                                      (r * dim + c) %
                                                          controller.currentTheme
                                                              .quadrantLabels
                                                              .length],
                                              style: GoogleFonts.bubblegumSans(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 11,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Offset _getPieceCenter(BoxConstraints constraints, bool isWide) {
    try {
      final frameBox =
          _frameKey.currentContext?.findRenderObject() as RenderBox?;
      final pieceBox =
          _pieceKey.currentContext?.findRenderObject() as RenderBox?;
      if (frameBox != null &&
          pieceBox != null &&
          frameBox.hasSize &&
          pieceBox.hasSize) {
        return frameBox.globalToLocal(
            pieceBox.localToGlobal(pieceBox.size.center(Offset.zero)));
      }
    } catch (_) {}

    // Robust geometric fallback
    if (isWide) {
      return Offset(constraints.maxWidth * 0.22, constraints.maxHeight * 0.50);
    } else {
      final boardH = (constraints.maxHeight - 6) * 5 / 9;
      return Offset(70, boardH + 6 + 75);
    }
  }

  Offset _getSlotCenter(
    int r,
    int c,
    BoxConstraints constraints,
    bool isWide,
    int dim,
  ) {
    try {
      final frameBox =
          _frameKey.currentContext?.findRenderObject() as RenderBox?;
      final slotKey = _slotKeys['$r,$c'];
      final slotBox =
          slotKey?.currentContext?.findRenderObject() as RenderBox?;
      if (frameBox != null &&
          slotBox != null &&
          frameBox.hasSize &&
          slotBox.hasSize) {
        return frameBox.globalToLocal(
            slotBox.localToGlobal(slotBox.size.center(Offset.zero)));
      }
    } catch (_) {}

    // Robust geometric fallback
    if (isWide) {
      final boardLeft = constraints.maxWidth * (5 / 11);
      final boardW = constraints.maxWidth * (6 / 11);
      final cellW = boardW / dim;
      final cellH = constraints.maxHeight / dim;
      return Offset(
        boardLeft + (c + 0.5) * cellW,
        (r + 0.5) * cellH,
      );
    } else {
      final boardH = (constraints.maxHeight - 6) * 5 / 9;
      final boardSize = (constraints.maxWidth - 20) < (boardH - 20)
          ? (constraints.maxWidth - 20)
          : (boardH - 20);
      final boardLeft = (constraints.maxWidth - boardSize) / 2;
      final boardTop = (boardH - boardSize) / 2;
      final cellSize = boardSize / dim;
      return Offset(
        boardLeft + (c + 0.5) * cellSize,
        boardTop + (r + 0.5) * cellSize,
      );
    }
  }

  Widget _buildTutorialHandOverlay(
    BoxConstraints constraints,
    bool isWide,
    JigsawPiece activePiece,
    G051Controller controller,
  ) {
    if (_isUserDragging || controller.isPuzzleCompleted) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _handAnimController,
      builder: (context, _) {
        final t = _handAnimController.value;
        final startPos = _getPieceCenter(constraints, isWide);
        final endPos = _getSlotCenter(
          activePiece.targetRow,
          activePiece.targetCol,
          constraints,
          isWide,
          controller.gridDimension,
        );

        double opacity = 1.0;
        double scale = 1.0;
        Offset currentPos;
        bool showGhostPiece = false;

        if (t < 0.15) {
          // Press down on piece (Phase 1)
          final progress = t / 0.15;
          scale = 1.0 - (0.16 * Curves.easeOut.transform(progress));
          currentPos = startPos;
          opacity = (t / 0.05).clamp(0.0, 1.0);
        } else if (t < 0.70) {
          // Glide up to target slot along a gentle curve (Phase 2)
          final progress = (t - 0.15) / 0.55;
          final curveVal = Curves.easeInOutCubic.transform(progress);
          final directOffset = Offset.lerp(startPos, endPos, curveVal)!;
          final archDy = -16.0 * (1.0 - (2 * (curveVal - 0.5)).abs());
          currentPos = Offset(directOffset.dx, directOffset.dy + archDy);
          scale = 0.88;
          showGhostPiece = true;
        } else if (t < 0.85) {
          // Release / drop into target slot (Phase 3)
          final progress = (t - 0.70) / 0.15;
          scale = 0.88 + (0.14 * Curves.easeOut.transform(progress));
          currentPos = endPos;
          opacity = 1.0;
        } else {
          // Fade out (Phase 4)
          final progress = (t - 0.85) / 0.15;
          opacity = (1.0 - progress).clamp(0.0, 1.0);
          scale = 1.0;
          currentPos = endPos;
        }

        return Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                // Ghost mini-piece carrying the crop preview along with the finger
                if (showGhostPiece)
                  Positioned(
                    left: currentPos.dx - 24,
                    top: currentPos.dy - 56,
                    child: Opacity(
                      opacity: opacity * 0.9,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9EE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getPieceBorderColor(
                              activePiece.targetRow,
                              activePiece.targetCol,
                            ),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildAnimalSection(
                            activePiece.targetRow,
                            activePiece.targetCol,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Touch ripple on piece at start
                if (t < 0.22)
                  Positioned(
                    left: startPos.dx - 22,
                    top: startPos.dy - 22,
                    child: Opacity(
                      opacity: (1.0 - (t / 0.22)).clamp(0.0, 1.0),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD54F),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Sparkle burst when dropping into target slot
                if (t >= 0.70 && t < 0.88)
                  Positioned(
                    left: endPos.dx - 16,
                    top: endPos.dy - 16,
                    child: Opacity(
                      opacity: ((0.88 - t) / 0.18).clamp(0.0, 1.0),
                      child: const Text('✨', style: TextStyle(fontSize: 32)),
                    ),
                  ),

                // Tutorial hand finger icon pointing accurately
                Positioned(
                  left: currentPos.dx - 22,
                  top: currentPos.dy - 16,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(2, 6),
                            ),
                          ],
                        ),
                        child: const Text(
                          '👆',
                          style: TextStyle(fontSize: 46),
                        ),
                      ),
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

  Color _getPieceBorderColor(int r, int c) {
    final colors = widget.controller.currentTheme.quadrantBorderColors;
    final index = (r * widget.controller.gridDimension + c) % colors.length;
    return colors[index];
  }

  Widget _buildPuzzlePieceWidget(JigsawPiece piece,
      {bool isDragging = false}) {
    final borderColor =
        _getPieceBorderColor(piece.targetRow, piece.targetCol);

    return Container(
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDragging ? 0.35 : 0.2),
            offset: const Offset(0, 4),
            blurRadius: isDragging ? 14 : 6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildAnimalSection(piece.targetRow, piece.targetCol),
            // Jigsaw Tab Knob Accent (visual interlocking cue)
            Positioned(
              right: -6,
              child: Container(
                width: 14,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9EE),
                  border: Border.all(color: borderColor, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Illustrated animal quadrant based on current theme.
  /// Renders the high-definition realistic photo crop if available,
  /// with seamless fallback to cartoon emoji representation.
  Widget _buildAnimalSection(int r, int c, {bool isGhost = false}) {
    final theme = widget.controller.currentTheme;
    final dim = widget.controller.gridDimension;
    final index = (r * dim + c) % theme.quadrantLabels.length;
    final label = theme.quadrantLabels[index];

    if (theme.imageAsset != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final pieceW = constraints.maxWidth;
          final pieceH = constraints.maxHeight;
          final fullW = pieceW * dim;
          final fullH = pieceH * dim;

          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Opacity(
              opacity: isGhost ? 0.28 : 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: -c * pieceW,
                    top: -r * pieceH,
                    width: fullW,
                    height: fullH,
                    child: Image.asset(
                      theme.imageAsset!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, _, _) =>
                          _buildFallbackEmojiSection(r, c, theme, dim),
                    ),
                  ),
                  if (!isGhost)
                    Positioned(
                      bottom: 3,
                      left: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.nunito(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: const [
                              Shadow(color: Colors.black87, blurRadius: 2),
                            ],
                          ),
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

    return _buildFallbackEmojiSection(r, c, theme, dim);
  }

  Widget _buildFallbackEmojiSection(
      int r, int c, PuzzleAnimalTheme theme, int dim) {
    final index = (r * dim + c) % theme.quadrantLabels.length;
    final emoji = theme.quadrantEmojis[index % theme.quadrantEmojis.length];
    final label = theme.quadrantLabels[index];
    final color =
        theme.quadrantBorderColors[index % theme.quadrantBorderColors.length];

    return Container(
      color: const Color(0xFFFFF6E5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.bubblegumSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
