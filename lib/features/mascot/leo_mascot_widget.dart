import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../core/audio/audio_service.dart';
import '../wardrobe/mascot_wardrobe_dialog.dart';

class _PetParticle {
  final double x;
  final double y;
  final double dx;
  final double dy;
  final String emoji;
  double opacity;

  _PetParticle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.emoji,
  }) : opacity = 1.0;
}

/// Interactive 3D Pixar Leo Mascot Widget on Home Screen:
/// - 3D Pixar lion pet avatar with golden royal crown
/// - Tactile petting squash & stretch response
/// - Spouting hearts, stars, and paw particles
/// - Quick interactive play actions: Feed 🍎, Ball 🎾, Dress Up 👑, Roar 🦁
class LeoMascotWidget extends StatefulWidget {
  final String locale;

  const LeoMascotWidget({super.key, this.locale = 'en'});

  @override
  State<LeoMascotWidget> createState() => _LeoMascotWidgetState();
}

class _LeoMascotWidgetState extends State<LeoMascotWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _squashController;
  late AnimationController _particleTicker;
  final List<_PetParticle> _particles = [];
  final math.Random _random = math.Random();

  int _messageIndex = 0;
  String? _temporaryMessage;
  bool _showBubble = true;

  final List<String> _messagesEn = [
    "Roar! 🦁 Welcome, Little King! Tap me to play!",
    "Ready for Today's 3 Quests? Let's go! 🚀",
    "Giggle giggle! You're my best friend! 💖",
    "You are doing awesome today, champion! ⭐",
    "Let's make art in the Sticker Canvas! 🎨",
    "High five! You're a royal superstar! 👑",
    "Can you pet my fluffy ears again? 🥰",
  ];

  final List<String> _messagesHi = [
    "दहाड़! 🦁 स्वागत है, छोटे राजा! मेरे साथ खेलें!",
    "क्या आप आज के 3 मिशन के लिए तैयार हैं? 🚀",
    "गुदगुदी! आप मेरे सबसे अच्छे दोस्त हैं! 💖",
    "आप बहुत बढ़िया खेल रहे हैं, चैंपियन! ⭐",
    "चलो स्टिकर कैनवस में चित्र बनाएं! 🎨",
    "हाई पांच! आप हमारे प्यारे राजा हैं! 👑",
    "क्या आप मुझे प्यार से थपथपा सकते हैं? 🥰",
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _squashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _particleTicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _squashController.dispose();
    _particleTicker.dispose();
    super.dispose();
  }

  void _updateParticles() {
    if (_particles.isEmpty) {
      if (_particleTicker.isAnimating) _particleTicker.stop();
      return;
    }

    setState(() {
      for (final p in _particles) {
        p.opacity -= 0.04;
      }
      _particles.removeWhere((p) => p.opacity <= 0.0);
    });

    if (_particles.isNotEmpty && !_particleTicker.isAnimating) {
      _particleTicker.repeat();
    }
  }

  void _spawnParticles(Offset pos, {int count = 6, List<String>? emojis}) {
    final pool = emojis ?? ['💖', '⭐', '✨', '🐾', '🥰'];
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 1.2 + _random.nextDouble() * 2.8;
      _particles.add(
        _PetParticle(
          x: pos.dx + (_random.nextDouble() - 0.5) * 20,
          y: pos.dy + (_random.nextDouble() - 0.5) * 20,
          dx: math.cos(angle) * speed,
          dy: math.sin(angle) * speed - 2.0,
          emoji: pool[_random.nextInt(pool.length)],
        ),
      );
    }
    if (!_particleTicker.isAnimating) _particleTicker.repeat();
  }

  void _onTapLeo(Offset pos) {
    HapticFeedback.mediumImpact();
    AudioService().playCue(SoundCue.mascotRoar);

    _squashController.forward(from: 0.0);
    _bounceController.forward(from: 0.0);
    _spawnParticles(pos, count: 6);

    setState(() {
      _temporaryMessage = null;
      final messages = widget.locale == 'hi' ? _messagesHi : _messagesEn;
      _messageIndex = (_messageIndex + 1) % messages.length;
      _showBubble = true;
    });
  }

  void _onFeedApple() {
    HapticFeedback.lightImpact();
    AudioService().playCue(SoundCue.snap);
    _spawnParticles(
      const Offset(40, 40),
      count: 8,
      emojis: ['🍎', '✨', '😋', '⭐', '💖'],
    );
    _squashController.forward(from: 0.0);
    setState(() {
      _temporaryMessage = widget.locale == 'hi'
          ? 'स्वादिष्ट सेब! बहुत धन्यवाद! 🍎😋'
          : 'Crunch crunch! Yum, delicious apple! 🍎😋';
      _showBubble = true;
    });
  }

  void _onPlayBall() {
    HapticFeedback.mediumImpact();
    AudioService().playCue(SoundCue.cheer);
    _spawnParticles(
      const Offset(40, 40),
      count: 8,
      emojis: ['🎾', '🎉', '⭐', '🐾', '🎈'],
    );
    _squashController.forward(from: 0.0);
    setState(() {
      _temporaryMessage = widget.locale == 'hi'
          ? 'वाह! शानदार उछाल! आप बहुत प्यारे हैं! 🎾🌟'
          : 'Wheee! High bounce! You\'re an amazing playmate! 🎾🌟';
      _showBubble = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.locale == 'hi' ? _messagesHi : _messagesEn;
    final currentMessage = _temporaryMessage ?? messages[_messageIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 3D Pixar Leo Mascot Avatar with Tactile Petting Response
              GestureDetector(
                onTapDown: (details) => _onTapLeo(details.localPosition),
                child: AnimatedBuilder(
                  animation: _squashController,
                  builder: (context, child) {
                    final squash = _squashController.value;
                    final sx = 1.0 + math.sin(squash * math.pi) * 0.15;
                    final sy = 1.0 - math.sin(squash * math.pi) * 0.12;
                    return Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.diagonal3Values(sx, sy, 1.0),
                      child: child,
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomRight,
                    children: [
                      // Golden Halo Glow
                      Container(
                        width: 86,
                        height: 86,
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
                              color: const Color(0xFFFF8F00).withOpacity(0.4),
                              blurRadius: 14,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFF9C4),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/art/app_icon.png',
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, _, _) => const Center(
                                child: Text('🦁', style: TextStyle(fontSize: 44)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Touch helper badge "Pet Me"
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🐾', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),

                      // Floating Pet Particles
                      ..._particles.map((p) => Positioned(
                            left: p.x + p.dx * (1.0 - p.opacity) * 12,
                            top: p.y + p.dy * (1.0 - p.opacity) * 12,
                            child: Opacity(
                              opacity: p.opacity.clamp(0.0, 1.0),
                              child: Text(
                                p.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Cheerful Interactive Speech Bubble with Play Controls
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTapLeo(const Offset(40, 40)),
                  child: AnimatedOpacity(
                    opacity: _showBubble ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(4),
                        ),
                        border: Border.all(color: const Color(0xFFFFB300), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE65100).withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentMessage,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textNavy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Quick Pet Action Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMiniActionButton(
                                label: 'Feed 🍎',
                                color: const Color(0xFFFF5252),
                                onTap: _onFeedApple,
                              ),
                              const SizedBox(width: 6),
                              _buildMiniActionButton(
                                label: 'Ball 🎾',
                                color: const Color(0xFF4CAF50),
                                onTap: _onPlayBall,
                              ),
                              const SizedBox(width: 6),
                              _buildMiniActionButton(
                                label: 'Dress 👑',
                                color: const Color(0xFFFFB300),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  MascotWardrobeDialog.show(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.bubblegumSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
