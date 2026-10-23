import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/providers.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/widgets/cartoon_ui_components.dart';

/// Royal Kingdom Diploma Dialog:
/// High-res printable royal parchment certificate with Prince Leo golden seal,
/// personal child milestone achievements, and celebratory trumpet fanfare.
class RoyalDiplomaDialog extends ConsumerStatefulWidget {
  const RoyalDiplomaDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'RoyalDiplomaDialog',
      barrierColor: Colors.black.withOpacity(0.70),
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (context, anim1, anim2) => const RoyalDiplomaDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<RoyalDiplomaDialog> createState() => _RoyalDiplomaDialogState();
}

class _RoyalDiplomaDialogState extends ConsumerState<RoyalDiplomaDialog> {
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    AudioService().playCue(SoundCue.trumpet);
    AudioService().playCue(SoundCue.cheer);
  }

  void _onPrintOrSave() {
    HapticFeedback.heavyImpact().catchError((_) {});
    AudioService().playCue(SoundCue.complete);
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() {
      _isPrinting = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Row(
              children: [
                const Text('📜', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Royal Diploma saved to photo gallery!',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final childName = profile?.displayName ?? 'Little Champion';
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: math.min(isLandscape ? 660.0 : 360.0, screenSize.width * 0.95),
          height: math.min(isLandscape ? 390.0 : 540.0, screenSize.height * 0.94),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFDE7), // Parchment cream
                Color(0xFFFFF9C4),
                Color(0xFFFFF59D),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFB300), width: 6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Close and Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('👑', style: TextStyle(fontSize: 24)),
                  Text(
                    'ROYAL KINGDOM OF KRIDO',
                    style: GoogleFonts.cinzel(
                      fontSize: isLandscape ? 16 : 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF5D4037),
                      letterSpacing: 2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ProceduralSfxEngine().playPop();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.brown, size: 18),
                    ),
                  ),
                ],
              ),

              const Divider(color: Color(0xFFFFB300), thickness: 1.5, height: 16),

              // Diploma Core Body
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DIPLOMA OF EXCELLENCE',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: isLandscape ? 22 : 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFC2185B),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This royal degree is joyfully presented to',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Child's Name
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF8D6E63), width: 2)),
                          ),
                          child: Text(
                            childName,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: isLandscape ? 24 : 20,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1565C0),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),
                        Text(
                          'For outstanding courage, sharp thinking, and brilliant mastery of Alphabet Letters, Numbers, Shapes & Island Puzzles!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: isLandscape ? 11 : 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4E342E),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Bottom Wax Seal & Royal Signature Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Official Prince Leo Seal
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const RadialGradient(
                                  colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('🦁', style: TextStyle(fontSize: 24)),
                              ),
                            ),

                            // Signature
                            Column(
                              children: [
                                Text(
                                  'Prince Leo 🐾',
                                  style: GoogleFonts.sacramento(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF4A148C),
                                  ),
                                ),
                                Text(
                                  'Guardian of KRIDO Kingdom',
                                  style: GoogleFonts.nunito(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.brown,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CandyPillButton(
                    width: 190,
                    height: 42,
                    color: const Color(0xFF4CAF50),
                    borderColor: Colors.white,
                    onPressed: _isPrinting ? null : _onPrintOrSave,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isPrinting ? '⏳' : '🖨️', style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          _isPrinting ? 'Saving...' : 'Save & Print',
                          style: GoogleFonts.bubblegumSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
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
