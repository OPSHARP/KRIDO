import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../core/widgets/confetti_celebration.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g078_controller.dart';

class G078View extends StatefulWidget {
  final G078Controller controller;

  const G078View({super.key, required this.controller});

  @override
  State<G078View> createState() => _G078ViewState();
}

class _G078ViewState extends State<G078View> with SingleTickerProviderStateMixin {
  late AnimationController _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    widget.controller.addListener(_onControllerChange);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _shakeAnim.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (widget.controller.wrongOptionId != null) {
      _shakeAnim.forward(from: 0.0);
    }
    if (mounted) setState(() {});
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
            // Scenic Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF81D4FA),
                      Color(0xFFE1F5FE),
                      Color(0xFFFFF9C4),
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            const Positioned(
              top: 20,
              right: 20,
              child: CartoonSun(size: 50),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Header Row
                  _buildHeaderRow(controller, isHindi),

                  const SizedBox(height: 6),

                  // Main Playground Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: WoodenTabletFrame(
                        borderWidth: 9,
                        cornerRadius: 24,
                        trayColor: const Color(0xFFFFFDF5),
                        child: isCompleted
                            ? Center(child: _buildVictoryCard(controller, isHindi))
                            : _buildRoundContent(controller, isHindi),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            if (controller.isRoundCorrect)
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

  Widget _buildHeaderRow(G078Controller controller, bool isHindi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          CandyPillButton(
            width: 58,
            height: 38,
            borderRadius: 19,
            color: const Color(0xFFFFCC80),
            borderColor: Colors.white,
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFE65100), size: 24),
          ),

          // Title & Phonics Family Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFB300), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🎵', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  isHindi ? 'राइमिंग शब्द मिलान' : 'Rhyme Match!',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textNavy,
                  ),
                ),
              ],
            ),
          ),

          // Round Stars Tracker
          Row(
            children: List.generate(controller.totalRounds, (index) {
              final isPassed = index < controller.currentRound;
              final isCurrent = index == controller.currentRound;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  isPassed ? '⭐' : (isCurrent ? '🌟' : '⚪'),
                  style: TextStyle(fontSize: isCurrent ? 20 : 16),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundContent(G078Controller controller, bool isHindi) {
    final target = controller.currentSet;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Target Word Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFECB3), Color(0xFFFFD54F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFA000), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(target.targetEmoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          target.targetWord,
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF3E2723),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            target.rhymeFamily,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isHindi
                          ? 'इसके साथ तुक मिलाने वाला शब्द खोजें!'
                          : 'Find the word that rhymes with ${target.targetWord}!',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFE65100), size: 28),
                  onPressed: () {
                    HapticFeedback.selectionClick().catchError((_) {});
                    AudioService().playCue(SoundCue.hint);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Options 2x2 Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: constraints.maxWidth / (constraints.maxHeight * 0.95),
                  physics: const NeverScrollableScrollPhysics(),
                  children: controller.options.map((option) {
                    return _buildOptionCard(option, controller, isHindi);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(RhymeItem option, G078Controller controller, bool isHindi) {
    final isSelected = controller.selectedOptionId == option.id;
    final isWrong = controller.wrongOptionId == option.id;
    final isHinted = controller.hintHighlightId == option.id;

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFF90CAF9);

    if (isSelected && controller.isRoundCorrect) {
      bgColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF4CAF50);
    } else if (isWrong) {
      bgColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFEF5350);
    } else if (isHinted) {
      borderColor = const Color(0xFFFFB300);
      bgColor = const Color(0xFFFFFDE7);
    }

    Widget cardContent = GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact().catchError((_) {});
        controller.handleAction(GameAction.tap(option.id));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected || isHinted || isWrong ? 3.5 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 6),
            Text(
              option.wordEn,
              style: GoogleFonts.bubblegumSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isSelected && controller.isRoundCorrect
                    ? const Color(0xFF2E7D32)
                    : AppTheme.textNavy,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              isHindi ? option.wordHi : '',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            if (isSelected && controller.isRoundCorrect)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('✨ RHYME MATCH! ✨',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    )),
              ),
          ],
        ),
      ),
    );

    // Apply shake animation if wrong
    if (isWrong) {
      return AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) {
          final offset = math.sin(_shakeAnim.value * math.pi * 4) * 8;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildVictoryCard(G078Controller controller, bool isHindi) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isHindi ? 'शानदार तुकबंदी! 🌟' : 'Master of Rhymes! 🌟',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? 'आपने सभी तुक मिलाने वाले शब्द सही पहचाने! +1 पेट ट्रीट जीता!'
                  : 'You matched all rhyming words with flying colors! Earned +1 pet treat!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            CandyPillButton(
              width: 160,
              height: 44,
              borderRadius: 22,
              color: const Color(0xFF4CAF50),
              borderColor: Colors.white,
              onPressed: () {
                controller.reset();
              },
              child: Center(
                child: Text(
                  isHindi ? 'दोबारा खेलें 🚀' : 'Play Again 🚀',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
