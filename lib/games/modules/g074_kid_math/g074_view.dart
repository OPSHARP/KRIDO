import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g074_controller.dart';

class G074View extends StatefulWidget {
  final G074Controller controller;

  const G074View({super.key, required this.controller});

  @override
  State<G074View> createState() => _G074ViewState();
}

class _G074ViewState extends State<G074View> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerState);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerState);
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
            // Sunny meadow background
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
                  const Text('🔢', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      controller.currentQuestion.mode == MathMode.counting
                          ? 'COUNT THE OBJECTS!'
                          : 'ADD THEM TOGETHER!',
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
    final q = controller.currentQuestion;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0C49C), width: 3),
      ),
      child: Column(
        children: [
          // Math display board
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF81C784), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: q.mode == MathMode.counting
                      ? _buildCountingBoard(q, controller)
                      : _buildAdditionBoard(q, controller),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Answer options: 4 glossy candy buttons
          Expanded(
            flex: 4,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: q.options.map((opt) {
                final isSelected = controller.selectedOption == opt;
                final isAnswer = opt == q.answer;
                final isWrong = controller.wrongOption == opt;
                final isHinted = controller.hintHighlightId == 'opt_$opt';

                Color primaryColor = const Color(0xFF42A5F5);
                Color darkColor = const Color(0xFF1E88E5);

                if (isSelected && isAnswer) {
                  primaryColor = const Color(0xFF66BB6A);
                  darkColor = const Color(0xFF2E7D32);
                } else if (isWrong) {
                  primaryColor = const Color(0xFFFF5252);
                  darkColor = const Color(0xFFC62828);
                } else if (isHinted) {
                  primaryColor = const Color(0xFFFFD54F);
                  darkColor = const Color(0xFFFFA000);
                }

                return GestureDetector(
                  onTap: () {
                    controller.handleAction(GameAction.tap('opt_$opt'));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryColor, darkColor],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: darkColor.withOpacity(0.4),
                          offset: const Offset(0, 4),
                          blurRadius: isHinted ? 14 : 6,
                          spreadRadius: isHinted ? 2 : 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Top gloss highlight
                        Align(
                          alignment: const Alignment(0.0, -0.65),
                          child: Container(
                            width: 36,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        Text(
                          '$opt',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildCountingBoard(MathQuestion q, G074Controller controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'How many ${q.itemName} can you see?',
          textAlign: TextAlign.center,
          style: GoogleFonts.bubblegumSans(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: List.generate(q.countA, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: Duration(milliseconds: 300 + (i * 100)),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Text(
                    q.itemEmoji,
                    style: const TextStyle(fontSize: 44),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 10),
        if (controller.isRoundAnswered)
          Text(
            '🌟 Excellent! Exactly ${q.answer} ${q.itemName}! 🌟',
            style: GoogleFonts.bubblegumSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionBoard(MathQuestion q, G074Controller controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Count both groups together!',
          textAlign: TextAlign.center,
          style: GoogleFonts.bubblegumSans(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Group A
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
              ),
              child: Row(
                children: List.generate(q.countA, (i) {
                  return Text(q.itemEmoji, style: const TextStyle(fontSize: 32));
                }),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '+',
              style: GoogleFonts.bubblegumSans(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 8),
            // Group B
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
              ),
              child: Row(
                children: List.generate(q.countB, (i) {
                  return Text(q.itemEmoji, style: const TextStyle(fontSize: 32));
                }),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '=',
              style: GoogleFonts.bubblegumSans(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 8),
            // Answer box
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: controller.isRoundAnswered ? const Color(0xFF4CAF50) : const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.isRoundAnswered ? const Color(0xFF1B5E20) : const Color(0xFFFFB300),
                  width: 2.5,
                ),
              ),
              child: Text(
                controller.isRoundAnswered ? '${q.answer}' : '?',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: controller.isRoundAnswered ? Colors.white : const Color(0xFFE65100),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (controller.isRoundAnswered)
          Text(
            '🌟 Super! ${q.countA} + ${q.countB} = ${q.answer}! 🌟',
            style: GoogleFonts.bubblegumSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
            ),
          ),
      ],
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
            const Text('🌟 🔢 🍎 ⭐ 🏆 🎉 🌟', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Math Champion!',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You solved all math challenges!',
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
                'NEXT MATH',
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFFFF9C4), Color(0xFFA5D6A7)],
        ),
      ),
    );
  }
}
