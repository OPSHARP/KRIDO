import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'g072_controller.dart';

/// View for G072: Word Builder Grid
/// Colorful 5×5 letter grid — drag adjacent letters to form simple words.
class G072View extends StatefulWidget {
  final G072Controller controller;

  const G072View({super.key, required this.controller});

  @override
  State<G072View> createState() => _G072ViewState();
}

class _G072ViewState extends State<G072View> with TickerProviderStateMixin {
  late AnimationController _hintPulseController;
  late AnimationController _foundWordController;

  // Grid cell keys for hit-testing
  final Map<int, GlobalKey> _cellKeys = {};

  @override
  void initState() {
    super.initState();
    _hintPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _foundWordController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Generate keys for each grid cell
    for (int i = 0; i < G072Controller.gridRows * G072Controller.gridCols; i++) {
      _cellKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _hintPulseController.dispose();
    _foundWordController.dispose();
    super.dispose();
  }

  int? _getCellAtPosition(Offset globalPos) {
    for (final entry in _cellKeys.entries) {
      final renderBox = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final local = renderBox.globalToLocal(globalPos);
        if (local.dx >= 0 && local.dy >= 0 &&
            local.dx <= renderBox.size.width && local.dy <= renderBox.size.height) {
          return entry.key;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6A1B9A), // Deep purple
                Color(0xFF283593), // Indigo
                Color(0xFF00695C), // Teal
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 8),
                _buildWordBank(),
                const SizedBox(height: 8),
                _buildDragIndicator(),
                const SizedBox(height: 4),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            ),
          ),
          Column(
            children: [
              Text(
                'WORD BUILDER',
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
                'Connect Letters to Spell Words!',
                style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white60),
              ),
            ],
          ),
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
                color: widget.controller.elapsedSeconds > 90
                    ? const Color(0xFFFF5252)
                    : const Color(0xFF69F0AE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordBank() {
    final ctrl = widget.controller;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Round ${ctrl.roundIndex + 1}/${ctrl.totalRounds}  •  Find: ',
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white60),
            ),
            const SizedBox(width: 4),
            ...ctrl.targetWords.map((pw) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pw.isFound
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: pw.isFound ? Colors.white : Colors.white30,
                      width: pw.isFound ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pw.word.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pw.word.word,
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          decoration: pw.isFound ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDragIndicator() {
    final ctrl = widget.controller;
    if (ctrl.currentDragWord.isEmpty) return const SizedBox(height: 28);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFF4511E)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFFF4511E).withOpacity(0.4), blurRadius: 8)],
      ),
      child: Center(
        child: Text(
          ctrl.currentDragWord,
          style: GoogleFonts.bubblegumSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final ctrl = widget.controller;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onPanStart: (details) {
          final cellIdx = _getCellAtPosition(details.globalPosition);
          if (cellIdx != null) {
            HapticFeedback.lightImpact().catchError((_) {});
            ctrl.startDrag(cellIdx);
          }
        },
        onPanUpdate: (details) {
          final cellIdx = _getCellAtPosition(details.globalPosition);
          if (cellIdx != null && !ctrl.currentDragPath.contains(cellIdx)) {
            HapticFeedback.selectionClick().catchError((_) {});
            ctrl.continueDrag(cellIdx);
          }
        },
        onPanEnd: (_) {
          HapticFeedback.mediumImpact().catchError((_) {});
          ctrl.endDrag();
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: G072Controller.gridCols / G072Controller.gridRows,
            child: CustomPaint(
              painter: _DragLinePainter(
                cells: ctrl.cells,
                dragPath: ctrl.currentDragPath,
                gridCols: G072Controller.gridCols,
                gridRows: G072Controller.gridRows,
                foundPlacements: ctrl.targetWords.where((w) => w.isFound).toList(),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: G072Controller.gridCols,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: ctrl.cells.length,
                itemBuilder: (context, index) {
                  return _buildGridCell(index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCell(int index) {
    final ctrl = widget.controller;
    final cell = ctrl.cells[index];
    final isInDragPath = ctrl.currentDragPath.contains(index);
    final isHinted = ctrl.hintHighlightId == index.toString();

    // Check if this cell is part of a found word
    bool isFoundCell = false;
    for (final pw in ctrl.targetWords) {
      if (pw.isFound && pw.cellIndices.contains(index)) {
        isFoundCell = true;
        break;
      }
    }

    final hue = (index * 29.0) % 360;
    final tileColor = HSLColor.fromAHSL(1, hue, 0.65, 0.45).toColor();

    return Container(
      key: _cellKeys[index],
      decoration: BoxDecoration(
        gradient: isFoundCell
            ? const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF43A047)])
            : isInDragPath
                ? const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFF4511E)])
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [tileColor, Color.lerp(tileColor, Colors.black, 0.2) ?? tileColor],
                  ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHinted
              ? const Color(0xFFFFD54F)
              : isInDragPath
                  ? Colors.white
                  : isFoundCell
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
          width: (isHinted || isInDragPath) ? 3 : 2,
        ),
        boxShadow: [
          if (isInDragPath || isHinted)
            BoxShadow(
              color: isHinted
                  ? const Color(0xFFFFD54F).withOpacity(0.6)
                  : const Color(0xFFFF6F00).withOpacity(0.5),
              blurRadius: 10,
            ),
          BoxShadow(
            color: tileColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isFoundCell
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    cell.letter,
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.check_circle, color: Colors.white, size: 12),
                  ),
                ],
              )
            : Text(
                cell.letter,
                style: GoogleFonts.bubblegumSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.4), offset: const Offset(1, 1), blurRadius: 2),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: Icons.lightbulb_rounded,
            label: 'HINT',
            color: const Color(0xFFFFCA28),
            onTap: () {
              HapticFeedback.lightImpact().catchError((_) {});
              widget.controller.requestHint();
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
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.bubblegumSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Paints the drag path line connecting selected cells
class _DragLinePainter extends CustomPainter {
  final List<WordGridCell> cells;
  final List<int> dragPath;
  final int gridCols;
  final int gridRows;
  final List<WordPlacement> foundPlacements;

  _DragLinePainter({
    required this.cells,
    required this.dragPath,
    required this.gridCols,
    required this.gridRows,
    required this.foundPlacements,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cells.isEmpty) return;

    final cellW = size.width / gridCols;
    final cellH = size.height / gridRows;

    Offset centerOf(int idx) {
      final r = idx ~/ gridCols;
      final c = idx % gridCols;
      return Offset(c * cellW + cellW / 2, r * cellH + cellH / 2);
    }

    // Draw found word lines (green)
    for (final pw in foundPlacements) {
      final foundPaint = Paint()
        ..color = const Color(0xFF66BB6A).withOpacity(0.4)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (int i = 0; i < pw.cellIndices.length; i++) {
        final pt = centerOf(pw.cellIndices[i]);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, foundPaint);
    }

    // Draw current drag line
    if (dragPath.length < 2) return;
    final dragPaint = Paint()
      ..color = const Color(0xFFFF6F00).withOpacity(0.7)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dragLinePath = Path();
    for (int i = 0; i < dragPath.length; i++) {
      final pt = centerOf(dragPath[i]);
      if (i == 0) {
        dragLinePath.moveTo(pt.dx, pt.dy);
      } else {
        dragLinePath.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(dragLinePath, dragPaint);

    // Glow dots at each dragged cell
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.8);
    for (final idx in dragPath) {
      canvas.drawCircle(centerOf(idx), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_DragLinePainter old) => true;
}
