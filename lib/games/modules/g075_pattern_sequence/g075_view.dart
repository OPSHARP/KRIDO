import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';
import '../../../core/audio/procedural_sfx_engine.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../core/widgets/confetti_celebration.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g075_controller.dart';

class G075View extends StatefulWidget {
  final G075Controller controller;

  const G075View({super.key, required this.controller});

  @override
  State<G075View> createState() => _G075ViewState();
}

class _G075ViewState extends State<G075View> with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnim;
  int? _narratedRound;
  bool _isNarrating = false;

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    widget.controller.addListener(_onControllerState);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerState);
    _pulseAnim.dispose();
    super.dispose();
  }

  void _onControllerState() {
    if (mounted) {
      if (_narratedRound != widget.controller.currentRound && !widget.controller.isPatternComplete) {
        _narratedRound = widget.controller.currentRound;
      }
      setState(() {});
    }
  }

  Future<void> _narratePatternSequence(bool isHindi) async {
    if (_isNarrating) return;
    _isNarrating = true;
    try {
      final seq = widget.controller.displaySequence;
      for (final item in seq) {
        if (!mounted) break;
        ProceduralSfxEngine().playPop();
        final label = isHindi ? item.labelHi : item.label;
        await ProceduralSfxEngine().speakSentence(label, isHindi: isHindi);
        await Future.delayed(const Duration(milliseconds: 550));
      }
      if (mounted) {
        final prompt = isHindi ? 'अगला क्या आएगा?' : 'What comes next?';
        await ProceduralSfxEngine().speakSentence(prompt, isHindi: isHindi);
      }
    } catch (_) {} finally {
      if (mounted) _isNarrating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final isCompleted = controller.state == GameLifecycleState.completed;
        final isHindi = controller.profile.uiLocale == 'hi';

        return Stack(
          children: [
            Positioned.fill(
              child: _buildScenicBackground(),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeaderRow(controller, isHindi),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: WoodenTabletFrame(
                        borderWidth: 10,
                        cornerRadius: 24,
                        trayColor: Colors.transparent,
                        child: isCompleted
                            ? Center(child: _buildLevelCompleteCard(isHindi))
                            : _buildPlayArea(isHindi),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            if (controller.isPatternComplete)
              const Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiCelebration(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderRow(G075Controller controller, bool isHindi) {
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
                  const Text('🐾', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isHindi ? 'पैटर्न पथ पूरा करें! 🌸' : 'COMPLETE THE PATTERN PATH! 🌸',
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

  Widget _buildPlayArea(bool isHindi) {
    final controller = widget.controller;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0C49C), width: 3),
      ),
      child: Column(
        children: [
          // Upper Stage: Garden Stepping-Stone Pattern Path
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF81C784), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.12),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Path Header with Audio Speaker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🌿', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            isHindi ? 'अगला पत्थर कौन सा है?' : 'Which stone comes next on the path?',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),

                      // Audio Sequence Narrator Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact().catchError((_) {});
                          _narratePatternSequence(isHindi);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFF9800), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.volume_up_rounded, color: Color(0xFFE65100), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                isHindi ? 'सुनें' : 'Listen',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFE65100),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Stepping-Stone Path Ribbon
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < controller.displaySequence.length; i++) ...[
                          _buildSteppingStone(
                            item: controller.displaySequence[i],
                            stepIndex: i + 1,
                            isHindi: isHindi,
                          ),
                          _buildPathConnector(isHindi),
                        ],

                        // Final Missing Target Mystery Stone
                        _buildMysteryTargetStone(controller, isHindi),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Completion status banner
                  if (controller.isPatternComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌟', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(
                            isHindi
                                ? 'शानदार! पैटर्न पथ पूरा हुआ! 🎉'
                                : '🌟 Wonderful! Pattern Path Completed! 🎉',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      isHindi ? '👇 नीचे दिए विकल्पों में से चुनें' : '👇 Pick the matching stone from below',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Lower Area: Chunky 3D Choice Stepping Stones
          Expanded(
            flex: 4,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: controller.choices.map((choice) {
                    final isSelected = controller.selectedChoice?.id == choice.id;
                    final isCorrect = choice.id == controller.correctItem.id;
                    final isWrong = controller.wrongChoice?.id == choice.id;
                    final isHinted = controller.hintHighlightId == 'opt_${choice.id}';

                    Color primaryColor = const Color(0xFFFFB74D);
                    Color darkColor = const Color(0xFFF57C00);

                    if (isSelected && isCorrect) {
                      primaryColor = const Color(0xFF81C784);
                      darkColor = const Color(0xFF388E3C);
                    } else if (isWrong) {
                      primaryColor = const Color(0xFFFF8A80);
                      darkColor = const Color(0xFFD32F2F);
                    } else if (isHinted) {
                      primaryColor = const Color(0xFFFFF176);
                      darkColor = const Color(0xFFFBC02D);
                    }

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick().catchError((_) {});
                        ProceduralSfxEngine().playPop();
                        controller.handleAction(GameAction.tap('opt_${choice.id}'));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 74,
                              height: 74,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [primaryColor, darkColor],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: Colors.white, width: 3.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: darkColor.withOpacity(0.4),
                                    offset: const Offset(0, 5),
                                    blurRadius: isHinted ? 14 : 6,
                                    spreadRadius: isHinted ? 2 : 0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glossy highlight bar
                                  Align(
                                    alignment: const Alignment(0.0, -0.7),
                                    child: Container(
                                      width: 44,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    choice.emoji,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE0C49C), width: 1.5),
                              ),
                              child: Text(
                                isHindi ? choice.labelHi : choice.label,
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textNavy,
                                ),
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

  Widget _buildSteppingStone({
    required PatternItem item,
    required int stepIndex,
    required bool isHindi,
  }) {
    return Container(
      width: 58,
      height: 74,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3D Stone Pedestal
          Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF81D4FA), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0277BD).withOpacity(0.18),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),

          // Small Stone Step Number Badge
          Positioned(
            top: 0,
            left: 2,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF0288D1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepIndex',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathConnector(bool isHindi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🐾', style: TextStyle(fontSize: 12)),
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF81C784),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMysteryTargetStone(G075Controller controller, bool isHindi) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final scale = controller.isPatternComplete ? 1.0 : 1.0 + (_pulseAnim.value * 0.09);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 62,
            height: 76,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: controller.isPatternComplete
                    ? [const Color(0xFFA5D6A7), const Color(0xFF66BB6A)]
                    : [const Color(0xFFFFF9C4), const Color(0xFFFFD54F)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: controller.isPatternComplete
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFFF8F00),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: controller.isPatternComplete
                      ? const Color(0xFF4CAF50).withOpacity(0.5)
                      : const Color(0xFFFFB300).withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!controller.isPatternComplete)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Text('✨', style: TextStyle(fontSize: 10)),
                  ),
                Text(
                  controller.isPatternComplete
                      ? controller.correctItem.emoji
                      : '❓',
                  style: TextStyle(
                    fontSize: controller.isPatternComplete ? 34 : 26,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCompleteCard(bool isHindi) {
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
            const Text('🌟 🐾 🍎 🍌 🏆 🎉 🌟', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isHindi ? 'पैटर्न पथ मास्टर! 👑' : 'Pattern Path Master! 👑',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0277BD),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? 'आपने बगीचे के सभी पैटर्न पथ सफलता से पार कर लिए हैं!'
                  : 'You completed all garden stepping-stone sequence patterns!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 14),
            CandyPillButton(
              width: 160,
              height: 44,
              color: const Color(0xFF0288D1),
              borderColor: Colors.white,
              borderRadius: 22,
              onPressed: () {
                widget.controller.nextLevel();
              },
              child: Text(
                isHindi ? 'अगले पैटर्न ➔' : 'NEXT PATTERNS ➔',
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
          colors: [Color(0xFFE0F7FA), Color(0xFFFFF9C4), Color(0xFFC8E6C9)],
        ),
      ),
    );
  }
}
