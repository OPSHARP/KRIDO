import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../voice/voice_navigation_controller.dart';
import 'pixar_3d_icons.dart';

/// Left-side Verbal Character Studio for Landscape Mode
/// Features:
/// 1. Leo Mascot with interactive poke reactions
/// 2. 3D Cartoon Speech Bubble
/// 3. Pulsating Kid Microphone Button with live bouncing soundwaves
/// 4. Quick verbal command chips
class VerbalCharacterStudio extends StatefulWidget {
  final VoiceNavigationController controller;
  final VoidCallback? onMicTap;

  const VerbalCharacterStudio({
    super.key,
    required this.controller,
    this.onMicTap,
  });

  @override
  State<VerbalCharacterStudio> createState() => _VerbalCharacterStudioState();
}

class _VerbalCharacterStudioState extends State<VerbalCharacterStudio>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveAnimController;

  @override
  void initState() {
    super.initState();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isListening = widget.controller.isListening;

        return Container(
          width: 260,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. 3D Cartoon Speech Bubble
              _buildSpeechBubble(),

              const SizedBox(height: 6),

              // 2. Interactive Talking Mascot (Leo the Lion)
              _buildInteractiveMascot(),

              const SizedBox(height: 6),

              // 3. Kid Voice Microphone with Audio Waveform Visualizer
              _buildKidVoiceMic(isListening),

              // 4. Quick Verbal Command Chips
              if (isListening) ...[
                const SizedBox(height: 4),
                _buildQuickVerbalChips(),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 3D Cartoon Speech Bubble
  Widget _buildSpeechBubble() {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5A866), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C41).withOpacity(0.18),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tail pointing down toward Leo
          Positioned(
            bottom: -16,
            left: 36,
            child: CustomPaint(
              size: const Size(16, 12),
              painter: _SpeechTailPainter(),
            ),
          ),
          Row(
            children: [
              Text(
                widget.controller.mood.mascotEmoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.controller.currentDialogue,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4A3418),
                    height: 1.15,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Interactive Animated Mascot Avatar
  Widget _buildInteractiveMascot() {
    return GestureDetector(
      onTap: () {
        widget.controller.pokeMascot();
      },
      child: AnimatedBuilder(
        animation: _waveAnimController,
        builder: (context, child) {
          final floatOffset = math.sin(_waveAnimController.value * 2 * math.pi) * 3;
          final isTalking = widget.controller.mood == MascotMood.talking;

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                  center: Alignment(-0.2, -0.3),
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8F00).withOpacity(0.4),
                    offset: const Offset(0, 6),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Royal Crown
                  Positioned(
                    top: 2,
                    child: Transform.rotate(
                      angle: isTalking ? math.sin(_waveAnimController.value * 6 * math.pi) * 0.08 : 0,
                      child: const Text('👑', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  // Leo Lion Mascot Face
                  const Positioned(
                    top: 24,
                    child: Text('🦁', style: TextStyle(fontSize: 52)),
                  ),
                  // Tap me callout
                  Positioned(
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7043),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        'POKE ME!',
                        style: GoogleFonts.nunito(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Kid Voice Mic with dynamic pulsing soundwaves
  Widget _buildKidVoiceMic(bool isListening) {
    return GestureDetector(
      onTap: () {
        widget.onMicTap?.call();
        if (isListening) {
          widget.controller.stopListening();
        } else {
          widget.controller.startListening();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isListening ? const Color(0xFFFF3D00) : const Color(0xFF80C94A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: isListening
                  ? const Color(0xFFFF3D00).withOpacity(0.5)
                  : const Color(0xFF689F38).withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Pixar3DIcon(
              type: PixarIconType.microphone,
              size: 24,
            ),
            const SizedBox(width: 6),
            Text(
              isListening ? 'LISTENING...' : 'VOICE TALK',
              style: GoogleFonts.bubblegumSans(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            if (isListening) ...[
              const SizedBox(width: 8),
              // Live Bouncing Waveform
              _buildLiveAudioWaveform(),
            ],
          ],
        ),
      ),
    );
  }

  /// Live animated audio wave visualizer bars
  Widget _buildLiveAudioWaveform() {
    return AnimatedBuilder(
      animation: _waveAnimController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final waveHeight = 6.0 + math.sin((_waveAnimController.value * 4 * math.pi) + index) * 5.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: waveHeight.clamp(4.0, 14.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  /// Quick verbal chips shown when listening
  Widget _buildQuickVerbalChips() {
    final chips = [
      {'label': '🐶 Puzzle', 'cmd': 'play puzzle'},
      {'label': '🍎 Apples', 'cmd': 'count apples'},
      {'label': '🔤 Find B', 'cmd': 'find b'},
      {'label': '🌙 Night', 'cmd': 'night'},
      {'label': '☀️ Day', 'cmd': 'day'},
      {'label': '🎲 Surprise', 'cmd': 'surprise'},
    ];

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: chips.map((c) {
        return GestureDetector(
          onTap: () {
            widget.controller.executeVerbalCommand(c['cmd']!);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC89658), width: 1.5),
            ),
            child: Text(
              c['label']!,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF5D4037),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SpeechTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFDF5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFE5A866)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
