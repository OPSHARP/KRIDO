import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/game_contract/game_action.dart';
import 'g012_controller.dart';

/// View for G012: Alpha Grid Tap
/// Colorful 5×6 grid of shuffled letters. Kids tap A→Z in order.
class G012View extends StatefulWidget {
  final G012Controller controller;

  const G012View({super.key, required this.controller});

  @override
  State<G012View> createState() => _G012ViewState();
}

class _G012ViewState extends State<G012View> with TickerProviderStateMixin {
  late AnimationController _hintPulseController;
  late AnimationController _wrongShakeController;

  // Tile colors for a candy-like palette
  static const List<Color> _tileColors = [
    Color(0xFF42A5F5), Color(0xFF66BB6A), Color(0xFFFFCA28),
    Color(0xFFEF5350), Color(0xFFAB47BC), Color(0xFF26C6DA),
    Color(0xFFFF7043), Color(0xFF8D6E63), Color(0xFF78909C),
    Color(0xFFEC407A), Color(0xFF5C6BC0), Color(0xFF29B6F6),
    Color(0xFF9CCC65), Color(0xFFFFA726), Color(0xFFD4E157),
  ];

  @override
  void initState() {
    super.initState();
    _hintPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _wrongShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _hintPulseController.dispose();
    _wrongShakeController.dispose();
    super.dispose();
  }

  void _onCellTapped(AlphaGridCell cell) {
    if (cell.isFiller) return;
    if (widget.controller.completedIndices.contains(cell.gridIndex)) return;

    HapticFeedback.lightImpact().catchError((_) {});

    widget.controller.handleAction(GameAction(
      type: GameActionType.tap,
      targetId: cell.label,
      payload: {'label': cell.label, 'gridIndex': cell.gridIndex},
    ));

    if (widget.controller.lastWrongGridIndex == cell.gridIndex) {
      _wrongShakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A237E), // Deep indigo
                Color(0xFF0D47A1), // Royal blue
                Color(0xFF1B5E20), // Forest green
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 8),
                _buildTargetIndicator(),
                const SizedBox(height: 6),
                Expanded(child: _buildGrid()),
                _buildBottomBar(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
              ),
            ),

          // Title
          Column(
            children: [
              Text(
                'ALPHA GRID',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.5), offset: const Offset(1, 2), blurRadius: 4),
                  ],
                ),
              ),
              Text(
                'Tap A to Z in Order!',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              widget.controller.timerString,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: widget.controller.elapsedSeconds > 60
                    ? const Color(0xFFFF5252)
                    : const Color(0xFF69F0AE),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTargetIndicator() {
    final ctrl = widget.controller;
    if (ctrl.isGridComplete) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            '🎉 ALL LETTERS FOUND! 🎉',
            style: GoogleFonts.bubblegumSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Find: ',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5252).withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              ctrl.currentTargetLetter,
              style: GoogleFonts.bubblegumSans(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Progress
          Text(
            '${ctrl.currentTargetIndex}/26',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final ctrl = widget.controller;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 0.9,
        ),
        itemCount: ctrl.cells.length,
        itemBuilder: (context, index) {
          final cell = ctrl.cells[index];
          return _buildCell(cell);
        },
      ),
    );
  }

  Widget _buildCell(AlphaGridCell cell) {
    final ctrl = widget.controller;
    final isCompleted = ctrl.completedIndices.contains(cell.gridIndex);
    final isHinted = ctrl.hintHighlightId == cell.label && !isCompleted;
    final isWrong = ctrl.lastWrongGridIndex == cell.gridIndex;

    final tileColor = _tileColors[cell.gridIndex % _tileColors.length];

    if (cell.isFiller) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(cell.label, style: const TextStyle(fontSize: 22)),
        ),
      );
    }

    if (isCompleted) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF43A047).withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                cell.label,
                style: GoogleFonts.bubblegumSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              top: 2,
              right: 4,
              child: Icon(Icons.check_circle, color: Colors.white, size: 14),
            ),
          ],
        ),
      );
    }

    // Active cell
    Widget cellWidget = GestureDetector(
      onTap: () => _onCellTapped(cell),
      child: AnimatedBuilder(
        animation: isHinted ? _hintPulseController : const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          final hintScale = isHinted ? 1.0 + (_hintPulseController.value * 0.08) : 1.0;
          return Transform.scale(
            scale: hintScale,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tileColor,
                    Color.lerp(tileColor, Colors.black, 0.2) ?? tileColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHinted
                      ? const Color(0xFFFFD54F)
                      : Colors.white.withOpacity(0.5),
                  width: isHinted ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHinted
                        ? const Color(0xFFFFD54F).withOpacity(0.6)
                        : tileColor.withOpacity(0.3),
                    blurRadius: isHinted ? 12 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  cell.label,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(1, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (isWrong) {
      cellWidget = AnimatedBuilder(
        animation: _wrongShakeController,
        builder: (context, child) {
          final shakeOffset = (_wrongShakeController.value < 0.5)
              ? (_wrongShakeController.value * 12 - 3)
              : ((1 - _wrongShakeController.value) * 12 - 3);
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: cellWidget,
      );
    }

    return cellWidget;
  }

  Widget _buildBottomBar() {
    final ctrl = widget.controller;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hint button
          _buildActionButton(
            icon: Icons.lightbulb_rounded,
            label: 'HINT',
            color: const Color(0xFFFFCA28),
            onTap: () {
              HapticFeedback.lightImpact().catchError((_) {});
              ctrl.requestHint();
            },
          ),
          const SizedBox(width: 16),
          // Restart button
          _buildActionButton(
            icon: Icons.refresh_rounded,
            label: 'RESTART',
            color: const Color(0xFF78909C),
            onTap: () {
              HapticFeedback.lightImpact().catchError((_) {});
              ctrl.restartGame();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.bubblegumSans(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
