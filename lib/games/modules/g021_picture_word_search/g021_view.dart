import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../domain/game_contract/game_action.dart';
import 'g021_controller.dart';

class G021View extends StatelessWidget {
  final G021Controller controller;

  const G021View({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          children: [
            // Target words list with pictures
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: controller.words.map((pw) {
                  final isHinted = controller.hintHighlightId == pw.word;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: pw.isFound
                          ? AppTheme.green
                          : (isHinted
                              ? AppTheme.sunGold.withOpacity(0.35)
                              : AppTheme.cardWhite),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: pw.isFound
                            ? Colors.green
                            : (isHinted ? Colors.orange : AppTheme.sky),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(pw.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 6),
                        Text(
                          pw.word,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: pw.isFound ? Colors.white : AppTheme.textNavy,
                            decoration: pw.isFound
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        if (pw.isFound) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check, size: 18, color: Colors.white),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // Letter Grid
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: controller.gridSize,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: controller.gridSize * controller.gridSize,
                      itemBuilder: (context, index) {
                        final row = index ~/ controller.gridSize;
                        final col = index % controller.gridSize;
                        final letter = controller.grid[row][col];

                        final isStart = controller.selectedStart?.x == row &&
                            controller.selectedStart?.y == col;

                        // Check if part of any found word
                        bool isCellFound = false;
                        for (final pw in controller.words) {
                          if (!pw.isFound) continue;
                          if (_isPointInWord(Point(row, col), pw)) {
                            isCellFound = true;
                            break;
                          }
                        }

                        return GestureDetector(
                          onTap: () {
                            controller.handleAction(
                              GameAction.tap('cell', {'row': row, 'col': col}),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCellFound
                                  ? AppTheme.green.withOpacity(0.85)
                                  : (isStart ? AppTheme.sunGold : const Color(0xFFF3F7FA)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isStart
                                    ? Colors.orange
                                    : (isCellFound ? Colors.green : AppTheme.sky.withOpacity(0.5)),
                                width: isStart ? 3 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isCellFound ? Colors.white : AppTheme.textNavy,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isPointInWord(Point<int> pt, PlacedWord pw) {
    final minR = min(pw.startRow, pw.endRow);
    final maxR = max(pw.startRow, pw.endRow);
    final minC = min(pw.startCol, pw.endCol);
    final maxC = max(pw.startCol, pw.endCol);

    if (pw.startRow == pw.endRow) {
      return pt.x == pw.startRow && pt.y >= minC && pt.y <= maxC;
    } else if (pw.startCol == pw.endCol) {
      return pt.y == pw.startCol && pt.x >= minR && pt.x <= maxR;
    }
    return false;
  }
}
