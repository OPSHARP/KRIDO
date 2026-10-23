import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../core/widgets/pixar_3d_animal_art.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g076_controller.dart';

class G076View extends StatefulWidget {
  final G076Controller controller;

  const G076View({super.key, required this.controller});

  @override
  State<G076View> createState() => _G076ViewState();
}

class _G076ViewState extends State<G076View> with SingleTickerProviderStateMixin {
  late AnimationController _soundWaveAnim;
  int? _lastPlayedRound;

  @override
  void initState() {
    super.initState();
    _soundWaveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    widget.controller.addListener(_onControllerState);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lastPlayedRound = widget.controller.currentRound;
      _playTargetAnimalSound();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerState);
    _soundWaveAnim.dispose();
    super.dispose();
  }

  void _onControllerState() {
    if (mounted) {
      if (_lastPlayedRound != widget.controller.currentRound && !widget.controller.isRoundCorrect) {
        _lastPlayedRound = widget.controller.currentRound;
        _playTargetAnimalSound();
      }
      setState(() {});
    }
  }

  void _playTargetAnimalSound() {
    final animal = widget.controller.targetAnimal;
    final isHindi = widget.controller.profile.uiLocale == 'hi';
    AudioService().playAnimalSound(animal.soundText, animal.id, isHindi: isHindi);
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
    final isHindi = controller.profile.uiLocale == 'hi';

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
                  const Text('📢', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isHindi ? 'यह आवाज किसकी है? 🐾' : 'WHO MAKES THIS SOUND? 🐾',
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
    final animal = controller.targetAnimal;
    final isHindi = controller.profile.uiLocale == 'hi';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0C49C), width: 3),
      ),
      child: Column(
        children: [
          // Enhanced 3D Speaker Console with Ripple Waves & Sound Card
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFFB74D), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Massive 3D Pulsating Cartoon Speaker Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact().catchError((_) {});
                      _playTargetAnimalSound();
                    },
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated Outer Wave Ripple 1
                          AnimatedBuilder(
                            animation: _soundWaveAnim,
                            builder: (context, _) {
                              final waveScale = 1.0 + (_soundWaveAnim.value * 0.28);
                              final waveOpacity = (1.0 - _soundWaveAnim.value).clamp(0.0, 0.6);
                              return Container(
                                width: 90 * waveScale,
                                height: 90 * waveScale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFF9800).withOpacity(waveOpacity),
                                    width: 3,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Animated Outer Wave Ripple 2
                          AnimatedBuilder(
                            animation: _soundWaveAnim,
                            builder: (context, _) {
                              final waveScale2 = 1.0 + (((_soundWaveAnim.value + 0.5) % 1.0) * 0.22);
                              final waveOpacity2 = (1.0 - ((_soundWaveAnim.value + 0.5) % 1.0)).clamp(0.0, 0.45);
                              return Container(
                                width: 84 * waveScale2,
                                height: 84 * waveScale2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFB74D).withOpacity(waveOpacity2),
                                    width: 2.5,
                                  ),
                                ),
                              );
                            },
                          ),

                          // 3D Chunky Speaker Dome
                          AnimatedBuilder(
                            animation: _soundWaveAnim,
                            builder: (context, child) {
                              final pulse = 1.0 + (_soundWaveAnim.value * 0.08);
                              return Transform.scale(
                                scale: pulse,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFFFD54F),
                                    Color(0xFFFF9800),
                                    Color(0xFFE65100),
                                  ],
                                  stops: [0.0, 0.65, 1.0],
                                ),
                                border: Border.all(color: Colors.white, width: 3.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE65100).withOpacity(0.45),
                                    offset: const Offset(0, 5),
                                    blurRadius: 8,
                                  ),
                                  const BoxShadow(
                                    color: Colors.white70,
                                    offset: Offset(0, -2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('🔊', style: TextStyle(fontSize: 36)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Sound speech text & prompt banner
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact().catchError((_) {});
                        _playTargetAnimalSound();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFF9800), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              offset: const Offset(0, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🎵', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '"${animal.soundText}"',
                                    style: GoogleFonts.bubblegumSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFE65100),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: controller.isRoundCorrect
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                controller.isRoundCorrect
                                    ? (isHindi
                                        ? '🌟 यह ${animal.nameHi} है! 🌟'
                                        : '🌟 That\'s the ${animal.nameEn}! 🌟')
                                    : (isHindi
                                        ? '👉 आवाज सुनने के लिए स्पीकर दबाएं!'
                                        : '👉 Tap speaker to hear animal sound!'),
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: controller.isRoundCorrect
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFD84315),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Lower Area: 4 Animal Cards in 2x2 grid
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 12) / 2;
                final cardHeight = (constraints.maxHeight - 10) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: controller.choices.map((a) {
                    final isSelected = controller.selectedAnimal?.id == a.id;
                    final isCorrect = a.id == controller.targetAnimal.id;
                    final isWrong = controller.wrongAnimal?.id == a.id;
                    final isHinted = controller.hintHighlightId == 'animal_${a.id}';

                    Color cardColor = Color(a.colorValue);
                    if (isWrong) cardColor = const Color(0xFFE53935);
                    if (isSelected && isCorrect) cardColor = const Color(0xFF43A047);

                    return SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick().catchError((_) {});
                            final isHindi = controller.profile.uiLocale == 'hi';
                            AudioService().playAnimalSound(a.soundText, a.id, isHindi: isHindi);
                            controller.handleAction(GameAction.tap('animal_${a.id}'));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: cardWidth,
                            height: cardHeight,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  cardColor.withOpacity(0.85),
                                  cardColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isHinted ? const Color(0xFFFFD54F) : Colors.white,
                                width: isHinted ? 3.5 : 2.5,
                              ),
                          boxShadow: [
                            BoxShadow(
                              color: cardColor.withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: isHinted ? 14 : 6,
                              spreadRadius: isHinted ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Realistic Pixar 3D Animal Art portrait
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Pixar3DAnimalArt(
                                animalId: a.id,
                                size: 46,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Name
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.nameEn,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.bubblegumSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    a.nameHi,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.hind(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
                );
              },
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
            const Text('🌟 🦁 🐱 🐶 🦆 🏆 🎉 🌟', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Animal Safari Hero!',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE65100),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You recognized every animal sound!',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 14),
            CandyPillButton(
              width: 160,
              height: 42,
              color: const Color(0xFFFF9800),
              borderColor: Colors.white,
              borderRadius: 21,
              onPressed: () {
                widget.controller.nextLevel();
              },
              child: Text(
                'MORE ANIMALS',
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
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2), Color(0xFFFFCC80)],
        ),
      ),
    );
  }
}
