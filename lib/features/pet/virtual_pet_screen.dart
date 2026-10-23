import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/health/step_tracker_service.dart';
import '../../core/widgets/cartoon_ui_components.dart';
import '../../core/widgets/confetti_celebration.dart';
import '../../domain/models/virtual_pet_model.dart';

class VirtualPetScreen extends ConsumerStatefulWidget {
  const VirtualPetScreen({super.key});

  @override
  ConsumerState<VirtualPetScreen> createState() => _VirtualPetScreenState();
}

class _VirtualPetScreenState extends ConsumerState<VirtualPetScreen>
    with TickerProviderStateMixin {
  late AnimationController _idleAnim;
  late AnimationController _chewAnim;
  late AnimationController _heartBurstAnim;
  late AnimationController _eggRockAnim;

  bool _isFeeding = false;
  String? _feedingTreatEmoji;
  bool _showEvolutionFanfare = false;

  final List<Map<String, String>> _treats = [
    {'id': 'apple', 'emoji': '🍎', 'name': 'Juicy Apple', 'nameHi': 'सेब'},
    {'id': 'berry', 'emoji': '🍓', 'name': 'Sweet Berry', 'nameHi': 'बेरी'},
    {'id': 'milk', 'emoji': '🥛', 'name': 'Golden Milk', 'nameHi': 'दूध'},
    {'id': 'cookie', 'emoji': '🍪', 'name': 'Star Cookie', 'nameHi': 'कुकी'},
  ];

  @override
  void initState() {
    super.initState();

    _idleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _eggRockAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _chewAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _heartBurstAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _idleAnim.dispose();
    _eggRockAnim.dispose();
    _chewAnim.dispose();
    _heartBurstAnim.dispose();
    super.dispose();
  }

  void _feedTreat(String emoji) async {
    if (_isFeeding) return;
    final petNotifier = ref.read(virtualPetProvider.notifier);
    final petState = ref.read(virtualPetProvider);

    if (petState.treatsAvailable <= 0) {
      HapticFeedback.heavyImpact().catchError((_) {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🌟 Complete learning games to earn delicious treats for your pet!',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          backgroundColor: AppTheme.purple,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isFeeding = true;
      _feedingTreatEmoji = emoji;
    });

    HapticFeedback.mediumImpact().catchError((_) {});
    _chewAnim.repeat(reverse: true);
    _heartBurstAnim.forward(from: 0.0);

    await petNotifier.feedPet(emoji);

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      _chewAnim.stop();
      _chewAnim.reset();
      setState(() {
        _isFeeding = false;
        _feedingTreatEmoji = null;
      });

      if (petNotifier.justEvolved) {
        petNotifier.clearEvolvedFlag();
        setState(() {
          _showEvolutionFanfare = true;
        });
      }
    }
  }

  void _petMascot() {
    HapticFeedback.lightImpact().catchError((_) {});
    ref.read(virtualPetProvider.notifier).patPet();
    _heartBurstAnim.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(virtualPetProvider);
    final profile = ref.watch(currentProfileProvider);
    final stepState = ref.watch(stepTrackerProvider);
    final isHindi = profile?.uiLocale == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          // Scenic Cartoon Meadow Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF81D4FA),
                    Color(0xFFC8E6C9),
                    Color(0xFFA5D6A7),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Glowing Sun & Clouds
          const Positioned(
            top: 25,
            right: 25,
            child: CartoonSun(size: 54),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              width: 90,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Row
                _buildTopBar(petState, isHindi),

                // Main Pet Playground Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Speech & Status Banner
                        _buildSpeechBubble(petState, isHindi),

                        const SizedBox(height: 12),

                        // Interactive Pet Character Stage
                        GestureDetector(
                          onTap: _petMascot,
                          child: Container(
                            height: 240,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pedestal Grass Mound
                                Positioned(
                                  bottom: 10,
                                  child: Container(
                                    width: 200,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF66BB6A).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // The Pet according to current stage
                                _buildPetForStage(petState),

                                // Flying Treat Animation
                                if (_isFeeding && _feedingTreatEmoji != null)
                                  Positioned(
                                    bottom: 120,
                                    child: AnimatedBuilder(
                                      animation: _heartBurstAnim,
                                      builder: (context, _) {
                                        final scale = 1.0 + (_heartBurstAnim.value * 0.4);
                                        return Transform.scale(
                                          scale: scale,
                                          child: Text(
                                            _feedingTreatEmoji!,
                                            style: const TextStyle(fontSize: 48),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                // Floating Hearts & Stars on petting or feeding
                                AnimatedBuilder(
                                  animation: _heartBurstAnim,
                                  builder: (context, _) {
                                    final val = _heartBurstAnim.value;
                                    if (val == 0.0 || val == 1.0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Positioned(
                                      top: 40 - (val * 40),
                                      child: Opacity(
                                        opacity: (1.0 - val).clamp(0.0, 1.0),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('💖', style: TextStyle(fontSize: 28)),
                                            SizedBox(width: 8),
                                            Text('✨', style: TextStyle(fontSize: 28)),
                                            SizedBox(width: 8),
                                            Text('🌟', style: TextStyle(fontSize: 28)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Evolution & Happiness Progress Card
                        _buildProgressCard(petState, isHindi),

                        const SizedBox(height: 14),

                        // Feeding Bowl & Treats Tray
                        _buildTreatsSection(petState, isHindi),

                        const SizedBox(height: 14),

                        // Step Tracker Activity Badge
                        _buildStepTrackerPill(stepState, isHindi),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Evolution Celebration Modal
          if (_showEvolutionFanfare)
            Positioned.fill(
              child: _buildEvolutionDialog(petState, isHindi),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(VirtualPetState petState, bool isHindi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact().catchError((_) {});
              Navigator.pop(context);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.purple, size: 24),
            ),
          ),

          // Title Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB300), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(petState.stage.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  isHindi ? petState.stage.nameHi : petState.stage.name,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textNavy,
                  ),
                ),
              ],
            ),
          ),

          // Treats Count Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9EE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFF7043), width: 2),
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
                const Text('🍎', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '${petState.treatsAvailable}',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFD84315),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(VirtualPetState petState, bool isHindi) {
    String message;
    switch (petState.stage) {
      case PetStage.egg:
        message = isHindi
          ? 'अंडे को प्यार से छुएं! 🥚 खेल खेलकर इसे सेने में मदद करें!'
          : 'Tap gently to care for the egg! 🐣 Complete games to help it hatch!';
        break;
      case PetStage.baby:
        message = isHindi
          ? 'नमस्ते! मुझे भूख लगी है, कृपया मुझे फल खिलाएं! 🍎'
          : 'Hello friend! I am hungry, feed me yummy apples! 🍎';
        break;
      case PetStage.cub:
        message = isHindi
          ? 'वाह! आपने बहुत सारे खेल सीखे हैं! मैं बड़ा हो रहा हूँ! 🌟'
          : 'Wow! You solved so many puzzles! I am growing stronger! 🌟';
        break;
      case PetStage.king:
        message = isHindi
          ? 'गर्वित दहाड़! 👑 आप किड्स किंग साम्राज्य के चैंपियन हैं!'
          : 'Royal Roar! 👑 Together we are champions of the Kingdom!';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('💬', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.textNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetForStage(VirtualPetState petState) {
    switch (petState.stage) {
      case PetStage.egg:
        return _buildAnimatedEgg(petState);
      case PetStage.baby:
        return _buildAnimatedBabyLeo();
      case PetStage.cub:
        return _buildAnimatedCubLeo();
      case PetStage.king:
        return _buildAnimatedKingLeo();
    }
  }

  Widget _buildAnimatedEgg(VirtualPetState petState) {
    return AnimatedBuilder(
      animation: _eggRockAnim,
      builder: (context, _) {
        final angle = math.sin(_eggRockAnim.value * math.pi * 2) * 0.08;
        return Transform.rotate(
          angle: angle,
          child: Container(
            width: 130,
            height: 170,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(-0.2, -0.3),
                radius: 0.9,
                colors: [
                  Color(0xFFFFF9C4),
                  Color(0xFFFFE082),
                  Color(0xFFFFB300),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.elliptical(65, 95),
                topRight: Radius.elliptical(65, 95),
                bottomLeft: Radius.elliptical(65, 75),
                bottomRight: Radius.elliptical(65, 75),
              ),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mystical decorative stars on shell
                const Positioned(top: 30, right: 25, child: Text('✨', style: TextStyle(fontSize: 18))),
                const Positioned(bottom: 40, left: 25, child: Text('⭐', style: TextStyle(fontSize: 16))),
                // Cracking zigzag lines if progress > 40%
                if (petState.evolutionProgress > 0.4)
                  CustomPaint(
                    size: const Size(60, 60),
                    painter: _EggCrackPainter(progress: petState.evolutionProgress),
                  ),
                // Glowing heart at center
                const Text('💖', style: TextStyle(fontSize: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBabyLeo() {
    return AnimatedBuilder(
      animation: _idleAnim,
      builder: (context, _) {
        final bounce = math.sin(_idleAnim.value * math.pi) * 8;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cute Baby Cub Head
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Little Orange Tufts
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF57C00), width: 3),
                    ),
                  ),
                  // Inner Face
                  Container(
                    width: 100,
                    height: 95,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE0B2),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Baby Eyes
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('👀', style: TextStyle(fontSize: 26)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Baby Smile / Chewing
                        _isFeeding
                            ? const Text('😋', style: TextStyle(fontSize: 24))
                            : const Text('👅', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  // Little Ears
                  const Positioned(top: -4, left: 10, child: Text('👂', style: TextStyle(fontSize: 20))),
                  const Positioned(top: -4, right: 10, child: Text('👂', style: TextStyle(fontSize: 20))),
                ],
              ),
              const SizedBox(height: 4),
              // Baby Body & Waving Paws
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🐾', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 20),
                  Text('🐾', style: TextStyle(fontSize: 22)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCubLeo() {
    return AnimatedBuilder(
      animation: _idleAnim,
      builder: (context, _) {
        final bounce = math.sin(_idleAnim.value * math.pi) * 10;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Jigsaw puzzle-piece shaped orange mane
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE65100), width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  // Face
                  Container(
                    width: 108,
                    height: 108,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE0B2),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('✨', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text('🦁', style: TextStyle(fontSize: 48)),
                          ],
                        ),
                        if (_isFeeding)
                          const Text('😋', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Playful Body
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Text('🐾 PLAYFUL CUB 🐾',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedKingLeo() {
    return AnimatedBuilder(
      animation: _idleAnim,
      builder: (context, _) {
        final bounce = math.sin(_idleAnim.value * math.pi) * 8;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Full royal mane
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFF57C00), Color(0xFFE65100)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD54F), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD54F).withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Crown tilted on head
                  const Positioned(
                    top: -24,
                    child: Text('👑', style: TextStyle(fontSize: 44)),
                  ),
                  // Cheerful Face
                  Container(
                    width: 118,
                    height: 118,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE0B2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🦁', style: TextStyle(fontSize: 56)),
                          if (_isFeeding)
                            const Text('😋', style: TextStyle(fontSize: 22)),
                        ],
                      ),
                    ),
                  ),
                  // Royal Cape
                  const Positioned(
                    bottom: -10,
                    child: Text('🧣', style: TextStyle(fontSize: 26)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                ),
                child: Text('👑 ROYAL KING LEO 👑',
                    style: GoogleFonts.bubblegumSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(VirtualPetState petState, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB2DFDB), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Happiness Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('💖', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    isHindi ? 'खुशी (Happiness)' : 'Pet Happiness',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textNavy,
                    ),
                  ),
                ],
              ),
              Text(
                '${(petState.happiness * 100).round()}%',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: petState.happiness,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
          ),

          const SizedBox(height: 14),

          // Evolution Growth Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    petState.stage.isMaxStage
                        ? (isHindi ? 'अधिकतम स्तर (Max Level)' : 'Royal Mastery')
                        : (isHindi
                            ? 'अगले चरण की प्रगति (Growth)'
                            : 'Growth to ${petState.stage.nextStage.name}'),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textNavy,
                    ),
                  ),
                ],
              ),
              Text(
                petState.stage.isMaxStage
                    ? '100%'
                    : '${(petState.evolutionProgress * 100).round()}%',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF388E3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: petState.evolutionProgress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),

          if (!petState.stage.isMaxStage) ...[
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? 'अगले विकास के लिए ${petState.xpNeededToEvolve} अनुभव अंक और चाहिए!'
                  : 'Complete ${(petState.xpNeededToEvolve / 35).ceil()} more learning modules to evolve!',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTreatsSection(VirtualPetState petState, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFB74D), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHindi ? 'स्नैक्स खिलाएं (Feeding Bowl)' : 'Feed Your Pet Treats',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF8D5B28),
                ),
              ),
              Text(
                '${petState.treatsAvailable} left',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _treats.map((treat) {
              return GestureDetector(
                onTap: () => _feedTreat(treat['emoji']!),
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(treat['emoji']!, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 2),
                      Text(
                        isHindi ? treat['nameHi']! : treat['name']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTrackerPill(StepTrackerState stepState, bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF90CAF9), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('🐾', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'लियो की दैनिक सैर (Daily Walk)' : "Leo's Daily Adventure Walk",
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textNavy,
                  ),
                ),
                Text(
                  '${stepState.stepsToday} / ${stepState.dailyGoal} steps • ${stepState.activeMinutes} mins active',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Add Steps test simulation button for child/parent interaction
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppTheme.purple, size: 28),
            onPressed: () {
              HapticFeedback.selectionClick().catchError((_) {});
              ref.read(stepTrackerProvider.notifier).addSteps(100);
            },
            tooltip: 'Walk 100 steps',
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionDialog(VirtualPetState petState, bool isHindi) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Stack(
        children: [
          const Positioned.fill(
            child: ConfettiCelebration(),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFD54F), width: 4),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉 EVOLUTION! 🎉',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD84315),
                      )),
                  const SizedBox(height: 14),
                  Text(
                    petState.stage.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isHindi ? petState.stage.nameHi : petState.stage.name,
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi ? petState.stage.descriptionHi : petState.stage.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CandyPillButton(
                    width: 160,
                    height: 48,
                    borderRadius: 24,
                    color: const Color(0xFF4CAF50),
                    borderColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _showEvolutionFanfare = false;
                      });
                    },
                    child: Center(
                      child: Text(
                        isHindi ? 'शानदार! 🚀' : 'Awesome! 🚀',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EggCrackPainter extends CustomPainter {
  final double progress;
  _EggCrackPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.1);
    path.lineTo(size.width * 0.4, size.height * 0.35);
    path.lineTo(size.width * 0.25, size.height * 0.55);
    path.lineTo(size.width * 0.6, size.height * 0.85);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EggCrackPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
