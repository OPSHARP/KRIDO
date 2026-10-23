import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g073_controller.dart';

class G073View extends StatefulWidget {
  final G073Controller controller;

  const G073View({super.key, required this.controller});

  @override
  State<G073View> createState() => _G073ViewState();
}

class _G073ViewState extends State<G073View> with SingleTickerProviderStateMixin {
  late AnimationController _sparkleAnim;

  @override
  void initState() {
    super.initState();
    _sparkleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    widget.controller.addListener(_onControllerState);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerState);
    _sparkleAnim.dispose();
    super.dispose();
  }

  void _onControllerState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final isCompleted = controller.state == GameLifecycleState.completed;

        return Stack(
          children: [
            // Background scenic pastel forest
            Positioned.fill(
              child: _buildScenicBackground(),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: WoodenTabletFrame(
                        borderWidth: 10,
                        cornerRadius: 24,
                        trayColor: Colors.transparent,
                        child: isCompleted
                            ? Center(child: _buildLevelCompleteCard())
                            : _buildPlayArea(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderRow() {
    final controller = widget.controller;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
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
          const SizedBox(width: 8),
          const CartoonSun(size: 36),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  const Text('✏️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'SPELL THE WORD!',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4A3418),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              '${controller.currentRound + 1}/${controller.totalRounds}',
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

  Widget _buildPlayArea() {
    final controller = widget.controller;
    final word = controller.targetWord;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0C49C), width: 3),
      ),
      child: Column(
        children: [
          // Upper Card: Illustrated Word Card + Slot Slots
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF9C4), Color(0xFFFFF176)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD54F), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji + Word prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.targetEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.targetHindi,
                                style: GoogleFonts.hind(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF795548),
                                ),
                              ),
                              Text(
                                controller.isWordSolved ? word : 'TAP LETTERS IN ORDER',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: controller.isWordSolved
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF5D4037),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Word Slot Boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(word.length, (slotIdx) {
                          final hasLetter = slotIdx < controller.selectedTileIndices.length;
                          final letter = hasLetter
                              ? controller.scrambledLetters[controller.selectedTileIndices[slotIdx]]
                              : '';

                          return Container(
                            width: 44,
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: hasLetter ? const Color(0xFF4CAF50) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: hasLetter ? const Color(0xFF2E7D32) : const Color(0xFF8D6E63),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: hasLetter
                                      ? const Color(0xFF4CAF50).withOpacity(0.4)
                                      : Colors.black.withOpacity(0.06),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              hasLetter ? letter : '_',
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: hasLetter ? Colors.white : const Color(0xFFBCAAA4),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Lower Area: Scrambled 3D Candy Letter Tiles
          Expanded(
            flex: 5,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: List.generate(controller.scrambledLetters.length, (tileIdx) {
                    final letter = controller.scrambledLetters[tileIdx];
                    final isUsed = controller.selectedTileIndices.contains(tileIdx);
                    final isWrong = controller.lastWrongTileIndex == tileIdx;
                    final isHinted = controller.hintHighlightId == 'tile_$tileIdx';

                    return GestureDetector(
                      onTap: isUsed
                          ? null
                          : () {
                              controller.handleAction(GameAction.tap('tile_$tileIdx'));
                            },
                      child: Opacity(
                        opacity: isUsed ? 0.3 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 58,
                          height: 58,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isWrong
                                  ? [const Color(0xFFFF8A80), const Color(0xFFD50000)]
                                  : (isHinted
                                      ? [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]
                                      : [const Color(0xFF42A5F5), const Color(0xFF1E88E5)]),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isWrong
                                  ? Colors.red.shade900
                                  : (isHinted ? Colors.amber.shade900 : Colors.white),
                              width: 2.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isWrong
                                    ? Colors.red.withOpacity(0.5)
                                    : (isHinted
                                        ? Colors.amber.withOpacity(0.6)
                                        : const Color(0xFF1565C0).withOpacity(0.4)),
                                offset: const Offset(0, 4),
                                blurRadius: isHinted ? 12 : 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Top shine gloss
                              Align(
                                alignment: const Alignment(0.0, -0.65),
                                child: Container(
                                  width: 32,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              Text(
                                letter,
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCompleteCard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EE),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFB300), width: 3.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟 🎉 📚 🐱 🐶 🎉 🌟', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Amazing Speller!',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You completed all word puzzles!',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 14),
            CandyPillButton(
              width: 150,
              height: 42,
              color: const Color(0xFF43A047),
              borderColor: Colors.white,
              borderRadius: 21,
              onPressed: () {
                widget.controller.nextLevel();
              },
              child: Text(
                'NEXT WORDS',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenicBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE1F5FE), Color(0xFFFFF9C4), Color(0xFFC8E6C9)],
            ),
          ),
        ),
      ],
    );
  }
}
