import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/widgets/confetti_celebration.dart';

class MilestoneCertificateDialog extends ConsumerStatefulWidget {
  final String? customTitle;
  final int? starCount;
  final int? gamesCompleted;

  const MilestoneCertificateDialog({
    super.key,
    this.customTitle,
    this.starCount,
    this.gamesCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    String? customTitle,
    int? starCount,
    int? gamesCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MilestoneCertificateDialog(
        customTitle: customTitle,
        starCount: starCount,
        gamesCompleted: gamesCompleted,
      ),
    );
  }

  @override
  ConsumerState<MilestoneCertificateDialog> createState() =>
      _MilestoneCertificateDialogState();
}

class _MilestoneCertificateDialogState
    extends ConsumerState<MilestoneCertificateDialog> {
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ProceduralSfxEngine().playFanfare();
      setState(() => _showCelebration = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final locale = profile?.uiLocale ?? 'en';
    final isHindi = locale == 'hi';
    final childName = profile?.displayName ?? (isHindi ? 'राजकुमार' : 'Royal Explorer');
    final title = widget.customTitle ??
        (isHindi ? 'सम्पूर्ण राज्य का महान विजेता' : 'Grand Champion of the Kingdom');
    final stars = widget.starCount ?? 50;
    final games = widget.gamesCompleted ?? 25;

    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Certificate Card Container
          Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFFB300), width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Top Ornate Flourish & Crown
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌿', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE082),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFFFB300), width: 2),
                      ),
                      child: Row(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 6),
                          Text(
                            isHindi
                                ? 'राजकीय प्रशस्ति पत्र'
                                : 'ROYAL DIPLOMA OF EXCELLENCE',
                            style: GoogleFonts.cinzel(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: const Color(0xFF5D4037),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🌿', style: TextStyle(fontSize: 26)),
                  ],
                ),

                const SizedBox(height: 14),

                // Subtitle
                Text(
                  isHindi
                      ? 'यह प्रमाण पत्र गर्व से प्रदान किया जाता है'
                      : 'This prestigious honors diploma is proudly awarded to',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 15,
                    color: const Color(0xFF8D6E63),
                  ),
                ),

                const SizedBox(height: 6),

                // Child Name
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFFFB300), width: 2.5),
                    ),
                  ),
                  child: Text(
                    childName,
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Achievement Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4E342E),
                  ),
                ),

                const SizedBox(height: 14),

                // Distinction Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatPill('⭐ $stars', isHindi ? 'सितारे' : 'Stars'),
                    const SizedBox(width: 14),
                    _buildStatPill('🎮 $games', isHindi ? 'खेल' : 'Games'),
                    const SizedBox(width: 14),
                    _buildStatPill('📅 $dateStr', isHindi ? 'तारीख' : 'Date'),
                  ],
                ),

                const SizedBox(height: 18),

                // Bottom Seal and Signature Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Conferrer Leo Seal
                    Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                            ),
                            border: Border.all(
                                color: const Color(0xFFFFE082), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🦁', style: TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isHindi ? 'प्रिंस लियो की मोहर' : 'Prince Leo Seal',
                          style: GoogleFonts.cinzel(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF6D4C41),
                          ),
                        ),
                      ],
                    ),

                    // Official Stamp
                    Column(
                      children: [
                        const Text('🐾 👑 ⭐', style: TextStyle(fontSize: 22)),
                        Container(
                          width: 110,
                          height: 1.5,
                          color: const Color(0xFFBCAAA4),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                        Text(
                          isHindi
                              ? 'किड्स किंगडम परिषद'
                              : 'Kids Kingdom Council',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6D4C41),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact().catchError((_) {});
                        ProceduralSfxEngine().playFanfare();
                        setState(() => _showCelebration = true);
                      },
                      icon: const Icon(Icons.celebration_rounded, size: 20),
                      label: Text(
                        isHindi ? 'उत्सव मनाएं!' : 'Celebrate!',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        isHindi ? 'बंद करें' : 'Close',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 16,
                          color: const Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

          // Confetti Particle Explosion
          if (_showCelebration) const ConfettiCelebration(),
        ],
      ),
    );
  }

  Widget _buildStatPill(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.bubblegumSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE65100),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.bubblegumSans(
              fontSize: 10,
              color: const Color(0xFF8D6E63),
            ),
          ),
        ],
      ),
    );
  }
}
