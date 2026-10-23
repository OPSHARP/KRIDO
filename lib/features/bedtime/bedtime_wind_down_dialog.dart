import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/mascot/mascot_wardrobe_service.dart';
import '../../core/widgets/cartoon_ui_components.dart';
import '../../core/widgets/interactive_prince_leo.dart';

/// Bedtime Wind-Down Mode Dialog:
/// Features cozy twilight night sky, sleepy Prince Leo in his star nightcap,
/// calming lullaby music box melodies, and sweet bedtime affirmations.
class BedtimeWindDownDialog extends ConsumerStatefulWidget {
  const BedtimeWindDownDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'BedtimeWindDownDialog',
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const BedtimeWindDownDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<BedtimeWindDownDialog> createState() => _BedtimeWindDownDialogState();
}

class _BedtimeWindDownDialogState extends ConsumerState<BedtimeWindDownDialog> {
  bool _isPlayingLullaby = true;

  @override
  void initState() {
    super.initState();
    AudioService().playCue(SoundCue.star);
  }

  void _toggleLullaby() {
    HapticFeedback.selectionClick().catchError((_) {});
    setState(() {
      _isPlayingLullaby = !_isPlayingLullaby;
    });
    if (_isPlayingLullaby) {
      AudioService().playCue(SoundCue.magic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentOutfit = ref.watch(mascotWardrobeProvider);
    final bedtimeOutfit = currentOutfit.copyWith(crown: LeoCrown.starryNightcap);
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: math.min(isLandscape ? 600.0 : 360.0, screenSize.width * 0.95),
          height: math.min(isLandscape ? 380.0 : 530.0, screenSize.height * 0.94),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D1B2A), // Deep Midnight
                Color(0xFF1B263B),
                Color(0xFF415A77),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFFD54F), width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Text('🌙', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Night Time',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
                        'Bedtime Wind-Down ⭐️',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: isLandscape ? 22 : 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
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
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Center Stage with Sleepy Prince Leo & Teddy Bear
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Moon Glow Backdrop
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.amber.withOpacity(0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Sleepy Prince Leo with Nightcap
                        InteractivePrinceLeo(
                          size: isLandscape ? 170 : 190,
                          showSpeechBubble: true,
                          customSpeech: 'Yaaawn... Time for sweet dreams! 🧸🌙',
                          outfit: bedtimeOutfit,
                          isSleepy: true,
                          hideBlocks: true,
                        ),

                        // Teddy bear companion in foreground
                        Positioned(
                          bottom: 6,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xAAFFFFFF),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber, width: 2),
                            ),
                            child: const Text('🧸', style: TextStyle(fontSize: 26)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Bedtime affirmation text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'You learned so much today, champion! Rest your eyes and recharge your magic powers for tomorrow\'s adventures. 🌟',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toggle Lullaby
                  CandyPillButton(
                    width: 135,
                    height: 40,
                    color: _isPlayingLullaby ? const Color(0xFF3F51B5) : Colors.grey.shade700,
                    borderColor: Colors.white,
                    onPressed: _toggleLullaby,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_isPlayingLullaby ? '🎵' : '🔇', style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            _isPlayingLullaby ? 'Lullaby ON' : 'Play Music',
                            style: GoogleFonts.bubblegumSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Goodnight Button
                  CandyPillButton(
                    width: 135,
                    height: 40,
                    color: const Color(0xFFFFB300),
                    borderColor: Colors.white,
                    onPressed: () {
                      AudioService().playCue(SoundCue.purr);
                      Navigator.of(context).pop();
                    },
                    child: Center(
                      child: Text(
                        'Goodnight Leo 😴',
                        style: GoogleFonts.bubblegumSans(
                          color: const Color(0xFF3E2723),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
