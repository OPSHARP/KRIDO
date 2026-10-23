import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/mascot/mascot_wardrobe_service.dart';
import '../../core/widgets/interactive_prince_leo.dart';

/// Prince Leo "Feed & Play" Pet Care Modal Sheet:
/// Toddlers can feed Prince Leo healthy pantry snacks, watch his mouth open & chew,
/// listen to funny lion purrs/crunches, and boost his happiness & growth XP.
class PrinceLeoCareSheet extends ConsumerStatefulWidget {
  const PrinceLeoCareSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrinceLeoCareSheet(),
    );
  }

  @override
  ConsumerState<PrinceLeoCareSheet> createState() => _PrinceLeoCareSheetState();
}

class _SnackItem {
  final String id;
  final String name;
  final String hindiName;
  final String emoji;
  final String soundReaction;

  const _SnackItem({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.emoji,
    required this.soundReaction,
  });
}

class _PrinceLeoCareSheetState extends ConsumerState<PrinceLeoCareSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _chewController;
  double _mouthOpen = 0.0;
  String _currentLeoSpeech = 'I\'m hungry, little champion! Pick a yummy snack! 🦁';
  final List<Offset> _floatingHearts = [];
  final math.Random _rng = math.Random();

  static const List<_SnackItem> _snacks = [
    _SnackItem(
      id: 'apple',
      name: 'Crispy Apple',
      hindiName: 'सेब',
      emoji: '🍎',
      soundReaction: 'Crunch crunch! Super sweet & healthy! 🍎',
    ),
    _SnackItem(
      id: 'cookie',
      name: 'Choco Cookie',
      hindiName: 'कुकी',
      emoji: '🍪',
      soundReaction: 'Mmm, warm chocolate chips! My favorite! 🍪',
    ),
    _SnackItem(
      id: 'milk',
      name: 'Fresh Milk',
      hindiName: 'दूध',
      emoji: '🥛',
      soundReaction: 'Gulp gulp gulp! Strong lion bones! 🥛',
    ),
    _SnackItem(
      id: 'icecream',
      name: 'Fruit Cone',
      hindiName: 'आइसक्रीम',
      emoji: '🍦',
      soundReaction: 'Brrr, so cool and berry delicious! 🍦',
    ),
    _SnackItem(
      id: 'pizza',
      name: 'Kingdom Slice',
      hindiName: 'पिज्जा',
      emoji: '🍕',
      soundReaction: 'Cheesy royal goodness! Roar! 🍕',
    ),
    _SnackItem(
      id: 'carrot',
      name: 'Sweet Carrot',
      hindiName: 'गाजर',
      emoji: '🥕',
      soundReaction: 'Munch munch! Good for bright lion eyes! 🥕',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _chewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        if (mounted) {
          setState(() {
            // Mouth open and shut cycle
            _mouthOpen = math.sin(_chewController.value * math.pi * 3).abs();
          });
        }
      });
  }

  @override
  void dispose() {
    _chewController.dispose();
    super.dispose();
  }

  void _feedSnack(_SnackItem snack) {
    HapticFeedback.heavyImpact().catchError((_) {});
    AudioService().playCue(SoundCue.snap);

    setState(() {
      _currentLeoSpeech = snack.soundReaction;
    });

    // Trigger chewing animation
    _chewController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _mouthOpen = 0.0;
      });
      AudioService().playCue(SoundCue.star);
      AudioService().playCue(SoundCue.purr);

      // Award XP to pet
      ref.read(virtualPetProvider.notifier).feedPet(snack.id);

      // Spawn floating hearts
      for (int i = 0; i < 4; i++) {
        _floatingHearts.add(Offset(
          120.0 + _rng.nextDouble() * 100.0,
          80.0 + _rng.nextDouble() * 60.0,
        ));
      }
      if (mounted) {
        setState(() {});
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _floatingHearts.clear();
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final outfit = ref.watch(mascotWardrobeProvider);
    final petState = ref.watch(virtualPetProvider);
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: math.min(isLandscape ? 380.0 : 520.0, screenSize.height * 0.94),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF8E1), // Warm cream
            Color(0xFFFFECB3),
            Color(0xFFFFE082),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFFB300), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Happiness Heart Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF4081), width: 2),
                ),
                child: Row(
                  children: [
                    const Text('💖', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'Happiness: ${(petState.happiness * 100).round()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFC2185B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Prince Leo Pantry 🍎',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4E342E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  ProceduralSfxEngine().playPop();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.brown, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Center Stage with Interactive Prince Leo
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    InteractivePrinceLeo(
                      size: isLandscape ? 170 : 190,
                      showSpeechBubble: true,
                      customSpeech: _currentLeoSpeech,
                      outfit: outfit,
                      hideBlocks: true,
                      mouthOpenProgress: _mouthOpen,
                    ),

                    // Floating hearts
                    for (final heart in _floatingHearts)
                      Positioned(
                        left: heart.dx,
                        top: heart.dy,
                        child: const Text('💖', style: TextStyle(fontSize: 22)),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Snack Pantry Shelf
          Text(
            'Tap any treat to feed Prince Leo!',
            style: GoogleFonts.bubblegumSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6D4C41),
            ),
          ),
          const SizedBox(height: 6),

          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _snacks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final snack = _snacks[index];

                return GestureDetector(
                  onTap: () => _feedSnack(snack),
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFB300), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(snack.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 2),
                        Text(
                          snack.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
