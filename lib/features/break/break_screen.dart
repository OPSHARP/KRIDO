import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/audio/procedural_sfx_engine.dart';

class BreakScreen extends ConsumerStatefulWidget {
  const BreakScreen({super.key});

  @override
  ConsumerState<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends ConsumerState<BreakScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  bool _drankWater = false;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  void _onDrinkWater(bool isHindi) {
    if (_drankWater) return;
    HapticFeedback.mediumImpact().catchError((_) {});
    ProceduralSfxEngine().playBubble();
    ProceduralSfxEngine().playCheer();
    setState(() {
      _drankWater = true;
    });
    ProceduralSfxEngine().speak(
      isHindi ? 'वाह! ताजा पानी पीकर मजा आ गया!' : 'Ah, fresh water feels so good!',
      isHindi: isHindi,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerService = ref.watch(sessionTimerServiceProvider);
    final profile = ref.watch(currentProfileProvider);
    final isHindi = profile?.uiLocale == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1), // Soothing mint-cyan
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Breathing Cloud with Prince Leo
                AnimatedBuilder(
                  animation: _breatheController,
                  builder: (context, _) {
                    final scale = 1.0 + (_breatheController.value * 0.12);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFEE58),
                              Color(0xFFFFB300),
                              Color(0xFFF57C00),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB300).withOpacity(0.45),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFF9C4),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/art/app_icon.png',
                                  width: 134,
                                  height: 134,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Text('🦁', style: TextStyle(fontSize: 68)),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.18),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _drankWater ? '✨' : '💤',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Breathing guidance text
                AnimatedBuilder(
                  animation: _breatheController,
                  builder: (context, _) {
                    final isInhale = _breatheController.value > 0.5;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isInhale
                            ? (isHindi ? '🌬️ गहरी साँस लें...' : '🌬️ Breathe In Slowly...')
                            : (isHindi ? '🍃 धीरे से साँस छोड़ें...' : '🍃 Breathe Out Gently...'),
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00796B),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Friendly Leo Curfew Title
                Text(
                  isHindi ? 'लियो का विश्राम समय! 🦁' : 'Prince Leo\'s Rest Time! 🦁',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF004D40),
                  ),
                ),
                const SizedBox(height: 12),

                // Friendly Dialogue Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF80CBC4), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    isHindi
                        ? '“दोस्त! मेरी नन्ही शेर जैसी आँखें थोड़ी थक गई हैं। चलो 5 मिनट थोड़ा पानी पीते हैं, खिंचाव करते हैं और आँखों को आराम देते हैं!” 🥛✨'
                        : '“Friend! My little lion eyes are a little tired. Let\'s drink fresh water, stretch our paws, and rest our eyes together!” 🥛✨',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textNavy,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Interactive Drink Water Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _drankWater ? const Color(0xFF26A69A) : const Color(0xFF0288D1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () => _onDrinkWater(isHindi),
                  icon: Text(_drankWater ? '✅' : '🥛', style: const TextStyle(fontSize: 20)),
                  label: Text(
                    _drankWater
                        ? (isHindi ? 'पानी पी लिया! बहुत बढ़िया!' : 'Drank Water! Great Job!')
                        : (isHindi ? 'पानी पिएं 🥛' : 'Drink Fresh Water 🥛'),
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),

                const SizedBox(height: 14),

                // Extend Session Button
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00796B),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    timerService.extendSession(15);
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 24),
                  label: Text(
                    isHindi ? '15 मिनट और खेलें' : 'Play 15 More Mins ▶',
                    style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
