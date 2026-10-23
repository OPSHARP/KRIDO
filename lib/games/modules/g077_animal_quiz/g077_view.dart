import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../core/widgets/pixar_3d_animal_art.dart';
import '../../../core/widgets/pixar_3d_icons.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g077_controller.dart';

class G077View extends StatefulWidget {
  final G077Controller controller;

  const G077View({super.key, required this.controller});

  @override
  State<G077View> createState() => _G077ViewState();
}

class _G077ViewState extends State<G077View> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.90), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    widget.controller.addListener(_onControllerUpdate);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _bounceController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (widget.controller.isRoundCorrect && !_bounceController.isAnimating) {
      _bounceController.forward(from: 0.0);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isHindi = controller.profile.uiLocale == 'hi';

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF3E0), // Soft warm sunrise
                  Color(0xFFFFE0B2),
                  Color(0xFFFFCC80),
                  Color(0xFFFFB74D),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top Header
                  _buildHeader(context, isHindi),

                  // Main Content Viewport with ScaleDown protection
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 380,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Animal Showcase Card
                                _buildAnimalShowcaseCard(controller, isHindi),

                                const SizedBox(height: 16),

                                // Prompt Badge
                                _buildPromptBadge(isHindi),

                                const SizedBox(height: 14),

                                // 4 Name Choices Buttons
                                _buildChoicesGrid(controller, isHindi),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Ad / Safety Breathing padding
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isHindi) {
    final controller = widget.controller;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          CandyPillButton(
            width: 40,
            height: 40,
            borderRadius: 20,
            color: const Color(0xFFFFA000),
            borderColor: Colors.white,
            onPressed: () {
              HapticFeedback.lightImpact().catchError((_) {});
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),

          // Title Plaque
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  offset: const Offset(0, 3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Pixar3DIcon(type: PixarIconType.animalQuiz, size: 24),
                const SizedBox(width: 6),
                Text(
                  isHindi ? 'जानवर क्विज़' : 'ANIMAL QUIZ',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE65100),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Round Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00ACC1),
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

  Widget _buildAnimalShowcaseCard(G077Controller controller, bool isHindi) {
    final target = controller.targetAnimal;
    final isSolved = controller.isRoundCorrect;

    return Container(
      width: 340,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSolved ? const Color(0xFF66BB6A) : const Color(0xFFFFB74D),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSolved ? const Color(0xFF66BB6A) : Colors.black).withOpacity(0.16),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          // Speech Bubble Above Animal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: isSolved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSolved ? const Color(0xFF81C784) : const Color(0xFFFFD54F),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSolved ? '🎉 ${target.soundText} 🎉' : (isHindi ? '🐾 मैं कौन हूँ? पहचानो!' : '🐾 Who am I? Guess my name!'),
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isSolved ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Animal Big Avatar Stage with Bouncing Animation
          ScaleTransition(
            scale: _bounceAnimation,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.3),
                  radius: 0.8,
                  colors: [
                    Color(target.colorValue).withOpacity(0.20),
                    Color(target.colorValue).withOpacity(0.55),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Color(target.colorValue).withOpacity(0.4),
                    offset: const Offset(0, 6),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Pixar3DAnimalArt(
                  animalId: target.id,
                  size: 120,
                ),
              ),
            ),
          ),

          if (isSolved) ...[
            const SizedBox(height: 10),
            Text(
              isHindi ? target.nameHi : target.nameEn.toUpperCase(),
              style: GoogleFonts.bubblegumSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E7D32),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromptBadge(bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
      ),
      child: Text(
        isHindi ? 'सही नाम पर टैप करें 👇' : 'Tap the correct name below! 👇',
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF5D4037),
        ),
      ),
    );
  }

  Widget _buildChoicesGrid(G077Controller controller, bool isHindi) {
    final choices = controller.choices;
    final target = controller.targetAnimal;
    final isHinted = controller.hintHighlightId != null;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: choices.map((animal) {
        final isSelected = controller.selectedChoice?.id == animal.id;
        final isTarget = animal.id == target.id;
        final isWrong = controller.wrongChoice?.id == animal.id;
        final isHighlighted = isHinted && controller.hintHighlightId == 'choice_${animal.id}';

        Color btnColor;
        if (isSelected && isTarget) {
          btnColor = const Color(0xFF4CAF50); // Emerald victory
        } else if (isWrong) {
          btnColor = const Color(0xFFFF5252); // Soft error shake
        } else if (isHighlighted) {
          btnColor = const Color(0xFFFFD54F); // Glowing hint
        } else {
          btnColor = Color(animal.colorValue);
        }

        return CandyPillButton(
          width: 160,
          height: 52,
          borderRadius: 20,
          color: btnColor,
          borderColor: isHighlighted || (isSelected && isTarget) ? Colors.white : Colors.white.withOpacity(0.9),
          onPressed: () {
            HapticFeedback.lightImpact().catchError((_) {});
            controller.handleAction(GameAction.tap('choice_${animal.id}'));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pixar3DAnimalArt(
                animalId: animal.id,
                size: 32,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isHindi ? animal.nameHi : animal.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(1, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected && isTarget) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
