import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/providers.dart';
import '../../core/audio/audio_service.dart';
import '../mascot/mascot_wardrobe_service.dart';

/// Individual particle for tactile petting and play animations
class _LeoParticle {
  final double x;
  final double y;
  final double dx;
  final double dy;
  final String emoji;
  final double scale;
  double opacity;

  _LeoParticle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.emoji,
    required this.scale,
  }) : opacity = 1.0;
}

/// Interactive 3D Pixar Prince Leo Mascot & Pet Playmate:
/// - Photorealistic 3D Pixar Lion Pet model with royal golden crown
/// - Tactile petting physics (squash & stretch response on tap / petting gestures)
/// - Dynamic particle fountain (hearts 💖, stars ⭐, paws 🐾, sparkles ✨) on touch
/// - Interactive feeding mechanics with flying apple snack & munch sounds
/// - Interactive ball play animation with joyful cheering
/// - 3D toy alphabet blocks (A in Red, B in Blue, C in Green) with sound & haptics
/// - Floating 3D puzzle pieces & smiling stars
/// - Dynamic wardrobe accessory overlays (hats, crowns, glasses, bowties)
class InteractivePrinceLeo extends ConsumerStatefulWidget {
  final double size;
  final bool showSpeechBubble;
  final String? customSpeech;
  final VoidCallback? onLeoTapped;
  final VoidCallback? onBlockTapped;
  final VoidCallback? onWardrobeTapped;
  final VoidCallback? onFeedTapped;
  final LeoOutfit? outfit;
  final bool isSleepy;
  final double mouthOpenProgress;
  final bool hideBlocks;
  final bool showQuickActions;

  const InteractivePrinceLeo({
    super.key,
    this.size = 220,
    this.showSpeechBubble = true,
    this.customSpeech,
    this.onLeoTapped,
    this.onBlockTapped,
    this.onWardrobeTapped,
    this.onFeedTapped,
    this.outfit,
    this.isSleepy = false,
    this.mouthOpenProgress = 0.0,
    this.hideBlocks = false,
    this.showQuickActions = false,
  });

  @override
  ConsumerState<InteractivePrinceLeo> createState() => _InteractivePrinceLeoState();
}

class _InteractivePrinceLeoState extends ConsumerState<InteractivePrinceLeo>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _waveController;
  late AnimationController _squashController;
  late AnimationController _particleTicker;
  late AnimationController _feedController;
  late AnimationController _ballController;

  final List<_LeoParticle> _particles = [];
  final math.Random _random = math.Random();

  int _speechIndex = 0;
  String? _temporarySpeech;

  final List<String> _voiceQuotes = [
    'Roar! Welcome to KRIDO Kingdom! 👑',
    'Giggle giggle! That tickles! 🐾',
    'You are my best friend forever! 💖',
    'Roar! I love learning with you! 🦁',
    'Give me a big high five! 🖐️',
    'Look at my shiny golden crown! ⭐',
    'Tap the ABC blocks or pick an Island! 🚀',
    'You are super smart and brave! 🍎',
    'Yay! Can you pet my ears again? 🥰',
    'Little Games, Big Discoveries! 🌟',
  ];

  @override
  void initState() {
    super.initState();

    // Idle breathing & floating
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    // Subtle gentle paw/tail wave
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Tactile petting squash & stretch
    _squashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Particle updater ticker
    _particleTicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);

    // Snack feeding animation
    _feedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Ball toss animation
    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _waveController.dispose();
    _squashController.dispose();
    _particleTicker.dispose();
    _feedController.dispose();
    _ballController.dispose();
    super.dispose();
  }

  void _updateParticles() {
    if (_particles.isEmpty) {
      if (_particleTicker.isAnimating) {
        _particleTicker.stop();
      }
      return;
    }

    setState(() {
      for (final p in _particles) {
        p.opacity -= 0.035;
      }
      _particles.removeWhere((p) => p.opacity <= 0.0);
    });

    if (_particles.isNotEmpty && !_particleTicker.isAnimating) {
      _particleTicker.repeat();
    }
  }

  void _spawnParticles(Offset localPos, {int count = 6, List<String>? emojis}) {
    final emojiPool = emojis ?? ['💖', '⭐', '✨', '🐾', '🥰', '🌟'];
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 1.5 + _random.nextDouble() * 3.5;
      _particles.add(
        _LeoParticle(
          x: localPos.dx + (_random.nextDouble() - 0.5) * 30,
          y: localPos.dy + (_random.nextDouble() - 0.5) * 30,
          dx: math.cos(angle) * speed,
          dy: math.sin(angle) * speed - 2.5, // gentle upward drift
          emoji: emojiPool[_random.nextInt(emojiPool.length)],
          scale: 0.7 + _random.nextDouble() * 0.6,
        ),
      );
    }
    if (!_particleTicker.isAnimating) {
      _particleTicker.repeat();
    }
  }

  void _onPetLeo(Offset pos) {
    HapticFeedback.mediumImpact();
    ref.read(audioServiceProvider).playCue(SoundCue.mascotRoar);

    _squashController.forward(from: 0.0);
    _spawnParticles(pos, count: 7);

    setState(() {
      _temporarySpeech = null;
      _speechIndex = (_speechIndex + 1) % _voiceQuotes.length;
    });

    widget.onLeoTapped?.call();
  }

  void _onFeedApple() {
    HapticFeedback.lightImpact();
    ref.read(audioServiceProvider).playCue(SoundCue.snap);

    _feedController.forward(from: 0.0).then((_) {
      ref.read(audioServiceProvider).playCue(SoundCue.magic);
      _spawnParticles(
        Offset(widget.size * 0.6, widget.size * 0.45),
        count: 10,
        emojis: ['🍎', '✨', '😋', '⭐', '💖'],
      );
      setState(() {
        _temporarySpeech = 'Crunch crunch! Yum, delicious apple! 🍎😋';
      });
      _squashController.forward(from: 0.0);
    });

    widget.onFeedTapped?.call();
  }

  void _onPlayBall() {
    HapticFeedback.mediumImpact();
    ref.read(audioServiceProvider).playCue(SoundCue.press);

    _ballController.forward(from: 0.0).then((_) {
      ref.read(audioServiceProvider).playCue(SoundCue.cheer);
      _spawnParticles(
        Offset(widget.size * 0.5, widget.size * 0.4),
        count: 8,
        emojis: ['🎾', '🎉', '⭐', '🎈', '🐾'],
      );
      setState(() {
        _temporarySpeech = 'Wheee! High bounce! You\'re an amazing playmate! 🎾🌟';
      });
      _squashController.forward(from: 0.0);
    });
  }

  void _onBlockTap(String letter) {
    HapticFeedback.lightImpact();
    ref.read(audioServiceProvider).playCue(SoundCue.snap);

    setState(() {
      _temporarySpeech = null;
      _speechIndex = letter == 'A' ? 0 : (letter == 'B' ? 2 : 3);
    });

    widget.onBlockTapped?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final LeoOutfit outfit = widget.outfit ?? ref.watch(mascotWardrobeProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _idleController,
        _waveController,
        _squashController,
        _feedController,
        _ballController,
      ]),
      builder: (context, child) {
        final breath = _idleController.value;
        final squashVal = _squashController.value;

        // Squash & stretch physics calculation
        final scaleX = 1.0 + math.sin(squashVal * math.pi) * 0.12;
        final scaleY = 1.0 - math.sin(squashVal * math.pi) * 0.10;

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Living Speech Bubble
              if (widget.showSpeechBubble)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildSpeechBubble(s),
                ),

              // 3D Pixar Prince Leo Interactive Play Area
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _onPetLeo(details.localPosition),
                onPanUpdate: (details) {
                  if (_random.nextDouble() < 0.25) {
                    _spawnParticles(details.localPosition, count: 2);
                  }
                },
                child: SizedBox(
                  width: s,
                  height: s * 0.95,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Ambient magical aura glow behind Leo
                      Positioned(
                        top: s * 0.12,
                        child: Container(
                          width: s * 0.72,
                          height: s * 0.72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFD54F).withOpacity(0.35 + breath * 0.12),
                                const Color(0xFFFF9800).withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Floating Background Puzzle Piece (Sky Blue)
                      Positioned(
                        top: s * 0.10,
                        right: s * 0.04,
                        child: _buildFloatingPuzzlePiece(
                          size: s * 0.20,
                          color: const Color(0xFF29B6F6),
                          rotation: 0.18 + breath * 0.06,
                        ),
                      ),

                      // Floating Background Puzzle Piece (Cherry Pink)
                      Positioned(
                        top: s * 0.28,
                        right: -s * 0.03,
                        child: _buildFloatingPuzzlePiece(
                          size: s * 0.18,
                          color: const Color(0xFFFF4081),
                          rotation: -0.15 - breath * 0.05,
                        ),
                      ),

                      // Floating Smiling Stars
                      Positioned(
                        top: s * 0.03,
                        right: s * 0.22,
                        child: _buildSmilingStar(size: s * 0.13, delay: breath),
                      ),
                      Positioned(
                        bottom: s * 0.24,
                        left: -s * 0.02,
                        child: _buildSmilingStar(size: s * 0.11, delay: 1 - breath),
                      ),

                      // 3D PIXAR LION PET HERO STAGE
                      Positioned(
                        top: s * 0.06 - breath * 4,
                        child: Transform(
                          alignment: Alignment.bottomCenter,
                          transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
                          child: _build3DPixarLionCharacter(s, outfit),
                        ),
                      ),

                      // 3D Toy Alphabet Blocks (A, B, C)
                      if (!widget.hideBlocks)
                        Positioned(
                          bottom: 0,
                          left: s * 0.02,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => _onBlockTap('B'),
                                child: _buildToyBlock(
                                  letter: 'B',
                                  color: const Color(0xFF29B6F6),
                                  size: s * 0.22,
                                ),
                              ),
                              SizedBox(width: s * 0.02),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _onBlockTap('A'),
                                    child: _buildToyBlock(
                                      letter: 'A',
                                      color: const Color(0xFFFF5252),
                                      size: s * 0.21,
                                    ),
                                  ),
                                  SizedBox(height: s * 0.01),
                                  GestureDetector(
                                    onTap: () => _onBlockTap('C'),
                                    child: _buildToyBlock(
                                      letter: 'C',
                                      color: const Color(0xFF66BB6A),
                                      size: s * 0.23,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // Dynamic Snack Feeding Animation Overlay (Flying Apple)
                      if (_feedController.isAnimating)
                        _buildFlyingAppleSnack(s),

                      // Dynamic Bouncing Ball Play Animation Overlay
                      if (_ballController.isAnimating)
                        _buildBouncingPlayBall(s),

                      // Tactile Petting Particle Fountain
                      ..._particles.map((p) => Positioned(
                            left: p.x + p.dx * (1.0 - p.opacity) * 12,
                            top: p.y + p.dy * (1.0 - p.opacity) * 12,
                            child: Opacity(
                              opacity: p.opacity.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: p.scale * p.opacity,
                                child: Text(
                                  p.emoji,
                                  style: TextStyle(fontSize: s * 0.12),
                                ),
                              ),
                            ),
                          )),

                      // Interactive "Pet Me!" badge helper on hover/idle
                      Positioned(
                        top: s * 0.14,
                        left: s * 0.08,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🐾', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                'PET ME!',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFE65100),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Pet Play Action Ribbon (Feed, Ball, Wardrobe, Roar)
              if (widget.showQuickActions)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildQuickActionRibbon(s),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 3D Pixar Lion Pet Avatar Stage with Golden Trim & Wardrobe Overlays
  Widget _build3DPixarLionCharacter(double s, LeoOutfit outfit) {
    final petDiameter = s * 0.76;

    return SizedBox(
      width: petDiameter,
      height: petDiameter,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Outer Gold Beveled Ring
          Container(
            width: petDiameter,
            height: petDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFEE58), // Bright gold highlight
                  Color(0xFFFFB300), // Rich amber gold
                  Color(0xFFF57C00), // Deep warm gold shadow
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8F00).withOpacity(0.45),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF9C4), // Warm light cream inner border
              ),
              padding: const EdgeInsets.all(2.5),
              child: ClipOval(
                child: Image.asset(
                  'assets/art/app_icon.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFFFCC80),
                    child: const Center(
                      child: Text('🦁', style: TextStyle(fontSize: 68)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dynamic Wardrobe Overlays (Custom hats/accessories)
          if (outfit.crown == LeoCrown.diamondTiara)
            Positioned(
              top: -petDiameter * 0.14,
              child: const Text('💎', style: TextStyle(fontSize: 40)),
            )
          else if (outfit.crown == LeoCrown.emeraldLaurel)
            Positioned(
              top: -petDiameter * 0.10,
              child: const Text('🌿👑🌿', style: TextStyle(fontSize: 26)),
            )
          else if (outfit.crown == LeoCrown.pirateBandana)
            Positioned(
              top: -petDiameter * 0.16,
              child: const Text('🏴‍☠️', style: TextStyle(fontSize: 40)),
            )
          else if (outfit.crown == LeoCrown.starryNightcap)
            Positioned(
              top: -petDiameter * 0.16,
              child: const Text('🌙✨', style: TextStyle(fontSize: 36)),
            ),

          if (outfit.accessory == LeoAccessory.starShades)
            Positioned(
              top: petDiameter * 0.32,
              child: const Text('⭐🕶️', style: TextStyle(fontSize: 34)),
            )
          else if (outfit.accessory == LeoAccessory.brassGoggles)
            Positioned(
              top: petDiameter * 0.30,
              child: const Text('🥽', style: TextStyle(fontSize: 34)),
            )
          else if (outfit.accessory == LeoAccessory.pinkBowtie)
            Positioned(
              bottom: petDiameter * 0.02,
              child: const Text('🎀', style: TextStyle(fontSize: 32)),
            ),
        ],
      ),
    );
  }

  /// Flying Apple Snack Animation
  Widget _buildFlyingAppleSnack(double s) {
    final t = _feedController.value;
    final startX = s * 0.2;
    final startY = s * 0.9;
    final endX = s * 0.55;
    final endY = s * 0.45;

    // Parabolic arc trajectory
    final curX = startX + (endX - startX) * t;
    final curY = startY + (endY - startY) * t - math.sin(t * math.pi) * (s * 0.25);
    final rot = t * math.pi * 3;

    return Positioned(
      left: curX,
      top: curY,
      child: Transform.rotate(
        angle: rot,
        child: Text(
          '🍎',
          style: TextStyle(fontSize: s * 0.18),
        ),
      ),
    );
  }

  /// Bouncing Play Ball Animation
  Widget _buildBouncingPlayBall(double s) {
    final t = _ballController.value;
    final curX = s * 0.1 + (s * 0.8) * t;
    final curY = s * 0.7 - math.sin(t * math.pi * 2).abs() * (s * 0.35);
    final rot = t * math.pi * 4;

    return Positioned(
      left: curX,
      top: curY,
      child: Transform.rotate(
        angle: rot,
        child: Text(
          '🎾',
          style: TextStyle(fontSize: s * 0.16),
        ),
      ),
    );
  }

  /// Interactive Quick Pet Action Ribbon (Feed, Ball, Wardrobe, Roar)
  Widget _buildQuickActionRibbon(double s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB300), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withOpacity(0.16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            label: 'Feed',
            emoji: '🍎',
            color: const Color(0xFFFF5252),
            onTap: _onFeedApple,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: 'Ball',
            emoji: '🎾',
            color: const Color(0xFF4CAF50),
            onTap: _onPlayBall,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: 'Dress Up',
            emoji: '👑',
            color: const Color(0xFFFFB300),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onWardrobeTapped?.call();
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: 'Roar!',
            emoji: '🦁',
            color: const Color(0xFFFF7043),
            onTap: () => _onPetLeo(Offset(s * 0.5, s * 0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.bubblegumSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(double s) {
    final text = _temporarySpeech ?? (widget.customSpeech ?? _voiceQuotes[_speechIndex]);

    return Container(
      constraints: BoxConstraints(maxWidth: s * 1.35),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withOpacity(0.18),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🦁', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.bubblegumSans(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4A3418),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToyBlock({
    required String letter,
    required Color color,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.bubblegumSans(
            fontSize: size * 0.65,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.35),
                offset: const Offset(1, 1.5),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPuzzlePiece({
    required double size,
    required Color color,
    required double rotation,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.25),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.extension_rounded,
            color: Colors.white,
            size: size * 0.7,
          ),
        ),
      ),
    );
  }

  Widget _buildSmilingStar({required double size, required double delay}) {
    return Transform.scale(
      scale: 0.9 + delay * 0.2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD54F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '⭐',
            style: TextStyle(fontSize: size * 0.75),
          ),
        ),
      ),
    );
  }
}
