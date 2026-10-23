import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../core/widgets/pixar_3d_animal_art.dart';
import '../../../domain/game_contract/game_action.dart';
import 'g041_controller.dart';

class G041View extends StatelessWidget {
  final G041Controller controller;

  static const List<Map<String, Color>> cardThemeStyles = [
    {'bg': Color(0xFF29B6F6), 'accent': Color(0xFFFFD54F)}, // Blue & Yellow
    {'bg': Color(0xFFFFA726), 'accent': Color(0xFF29B6F6)}, // Orange & Blue
    {'bg': Color(0xFF81C784), 'accent': Color(0xFFFFB74D)}, // Green & Orange
    {'bg': Color(0xFFFF5252), 'accent': Color(0xFF81C784)}, // Red & Green
    {'bg': Color(0xFFAB47BC), 'accent': Color(0xFFFFD54F)}, // Purple & Yellow
    {'bg': Color(0xFF26C6DA), 'accent': Color(0xFFFF8A80)}, // Teal & Pink
  ];

  const G041View({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final totalCards = controller.cards.length;

        return Stack(
          children: [
            // Animated confetti wallpaper background
            Positioned.fill(
              child: _AnimatedConfettiBackground(
                matchCount: controller.matchedPairsCount,
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 500;
                  return Column(
                    children: [
                      // Top Header: MATCHES card, MEMORY MATCH title, LEVEL/MOVES card
                      _buildHeaderRow(isCompact),

                      SizedBox(height: isCompact ? 4 : 8),

                      // Main Board with Purple Ribbon on left & grid
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 14),
                          child: LayoutBuilder(
                            builder: (context, boardConstraints) {
                              final isWide = boardConstraints.maxWidth > 520;
                              return isWide
                                  ? Row(
                                      children: [
                                        _buildPurpleRibbonBanner(),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildMemoryBoard(totalCards, boardConstraints),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildPurpleRibbonBanner(isHorizontal: true),
                                        const SizedBox(height: 6),
                                        Expanded(
                                          child: _buildMemoryBoard(totalCards, boardConstraints),
                                        ),
                                      ],
                                    );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: isCompact ? 4 : 8),

                      // Bottom Bar: Combo, Score Badge & RESET Button
                      _buildBottomBar(),

                      SizedBox(height: isCompact ? 4 : 8),
                    ],
                  );
                },
              ),
            ),

            // Combo multiplier popup
            if (controller.comboMultiplier >= 2)
              _ComboPopup(combo: controller.comboMultiplier),

            // Victory overlay
            if (controller.isGameComplete)
              _VictoryOverlay(
                starRating: controller.starRating,
                totalScore: controller.totalScore,
                moveCount: controller.moveCount,
                bestCombo: controller.bestCombo,
                onPlayAgain: () => controller.initialize(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderRow(bool isCompact) {
    final fontSize = isCompact ? 8.0 : 10.0;
    final valueFontSize = isCompact ? 10.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: isCompact ? 2 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back Button + MATCHES/SCORE Card
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) => CandyPillButton(
                  width: 36,
                  height: 36,
                  color: const Color(0xFF80C94A),
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 6),
              _StatCard(
                children: [
                  _StatLabel('MATCHES', fontSize: fontSize),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.matchedPairsCount}/${controller.pairCount}',
                        style: GoogleFonts.nunito(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text('⭐', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Center: 3D Bubble Title "MEMORY MATCH"
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: BubbleTitle(
                  text: 'MEMORY MATCH',
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // Right: MOVES & LEVEL
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatCard(
                children: [
                  _StatLabel('MOVES', fontSize: fontSize),
                  Text(
                    '${controller.moveCount}',
                    style: GoogleFonts.nunito(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              _StatCard(
                children: [
                  _StatLabel('LEVEL', fontSize: fontSize),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.challenge.tier}',
                        style: GoogleFonts.nunito(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const CartoonSun(size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Purple arrow ribbon banner: "FIND THE MATCHES!"
  Widget _buildPurpleRibbonBanner({bool isHorizontal = false}) {
    return isHorizontal
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF845EF7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  offset: const Offset(0, 3),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                controller.comboMultiplier >= 2
                    ? '🔥 ${controller.comboMultiplier}× COMBO! 🔥'
                    : 'FIND THE MATCHES!',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          )
        : Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            decoration: BoxDecoration(
              color: controller.comboMultiplier >= 2
                  ? const Color(0xFFFF6D00)
                  : const Color(0xFF845EF7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  offset: const Offset(2, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  controller.comboMultiplier >= 2
                      ? '🔥 ${controller.comboMultiplier}× COMBO!'
                      : 'FIND THE MATCHES!',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildMemoryBoard(int totalCards, BoxConstraints constraints) {
    final is16Cards = totalCards >= 16;
    final crossAxisCount = totalCards <= 4 ? 2 : (totalCards <= 6 ? 3 : 4);
    final rows = (totalCards / crossAxisCount).ceil();

    // Responsive sizing: calculate card size based on available space
    final availW = constraints.maxWidth - (is16Cards ? 8 : 12) * (crossAxisCount - 1) - 24;
    final availH = constraints.maxHeight - (is16Cards ? 8 : 12) * (rows - 1) - 24;
    final maxCardW = availW / crossAxisCount;
    final maxCardH = availH / rows;
    final cardSize = math.min(maxCardW, maxCardH).clamp(40.0, 120.0);

    return WoodenTabletFrame(
      borderWidth: 8,
      cornerRadius: 22,
      trayColor: const Color(0xFFFFF9EE),
      child: Center(
        child: Wrap(
          spacing: is16Cards ? 8 : 12,
          runSpacing: is16Cards ? 8 : 12,
          alignment: WrapAlignment.center,
          children: List.generate(totalCards, (index) {
            final card = controller.cards[index];
            final isRevealed = card.state != CardRevealState.hidden;
            final isMatched = card.state == CardRevealState.matched;
            final isJustMatched = (index == controller.lastMatchIndex1 ||
                index == controller.lastMatchIndex2);
            final isMismatch = (index == controller.lastMismatchIndex1 ||
                index == controller.lastMismatchIndex2);
            final style = cardThemeStyles[index % cardThemeStyles.length];

            return SizedBox(
              width: cardSize,
              height: cardSize,
              child: _EnhancedMemoryCard(
                card: card,
                index: index,
                isRevealed: isRevealed,
                isMatched: isMatched,
                isJustMatched: isJustMatched,
                isMismatch: isMismatch,
                bgColor: style['bg']!,
                accentColor: style['accent']!,
                isCompact: is16Cards || cardSize < 70,
                onTap: () {
                  controller.handleAction(GameAction.tap(index.toString()));
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final matchedPairs = controller.matchedPairsCount;
    final score = matchedPairs * 100 + controller.bestCombo * 50;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gold Coin Score Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9EE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB300), width: 2.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 5),
                Text(
                  'SCORE: $score',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Orange RESET Pill Button
          CandyPillButton(
            width: 100,
            height: 38,
            borderRadius: 20,
            color: const Color(0xFFFF9800),
            borderColor: Colors.white,
            onPressed: () {
              controller.initialize();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RESET',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final List<Widget> children;
  const _StatCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC89658), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  const _StatLabel(this.text, {this.fontSize = 9});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF8D5B28),
      ),
    );
  }
}

// ─── Animated Confetti Background ─────────────────────────────

class _AnimatedConfettiBackground extends StatefulWidget {
  final int matchCount;
  const _AnimatedConfettiBackground({required this.matchCount});

  @override
  State<_AnimatedConfettiBackground> createState() => _AnimatedConfettiBackgroundState();
}

class _AnimatedConfettiBackgroundState extends State<_AnimatedConfettiBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(
            progress: _controller.value,
            intensity: widget.matchCount,
          ),
          child: Container(color: const Color(0xFFFFF8E7).withOpacity(0.92)),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final int intensity;

  _ConfettiPainter({required this.progress, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final count = 12 + intensity * 3;
    final colors = [
      const Color(0xFFFF6B6B), const Color(0xFFFFD93D),
      const Color(0xFF6BCB77), const Color(0xFF4D96FF),
      const Color(0xFFFF8E9E), const Color(0xFFA78BFA),
    ];

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final y = (baseY + progress * speed * size.height * 0.5) % (size.height + 20);
      final radius = 2.0 + rng.nextDouble() * 4.0;
      final colorIdx = i % colors.length;

      final paint = Paint()
        ..color = colors[colorIdx].withOpacity(0.25 + rng.nextDouble() * 0.2)
        ..style = PaintingStyle.fill;

      if (i % 3 == 0) {
        // Circle confetti
        canvas.drawCircle(Offset(x, y), radius, paint);
      } else if (i % 3 == 1) {
        // Star shape
        _drawStar(canvas, Offset(x, y), radius * 1.2, paint);
      } else {
        // Diamond
        final path = Path()
          ..moveTo(x, y - radius)
          ..lineTo(x + radius * 0.6, y)
          ..lineTo(x, y + radius)
          ..lineTo(x - radius * 0.6, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;
      final outerX = center.dx + radius * math.cos(angle);
      final outerY = center.dy + radius * math.sin(angle);
      final innerX = center.dx + radius * 0.4 * math.cos(innerAngle);
      final innerY = center.dy + radius * 0.4 * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      progress != old.progress || intensity != old.intensity;
}

// ─── Enhanced Memory Card (3D Flip + Bounce + Shake + Glow) ───

class _EnhancedMemoryCard extends StatefulWidget {
  final MemoryCard card;
  final int index;
  final bool isRevealed;
  final bool isMatched;
  final bool isJustMatched;
  final bool isMismatch;
  final Color bgColor;
  final Color accentColor;
  final bool isCompact;
  final VoidCallback onTap;

  const _EnhancedMemoryCard({
    required this.card,
    required this.index,
    required this.isRevealed,
    required this.isMatched,
    required this.isJustMatched,
    required this.isMismatch,
    required this.bgColor,
    required this.accentColor,
    required this.isCompact,
    required this.onTap,
  });

  @override
  State<_EnhancedMemoryCard> createState() => _EnhancedMemoryCardState();
}

class _EnhancedMemoryCardState extends State<_EnhancedMemoryCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.isRevealed ? 1.0 : 0.0,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeOutBack),
    );

    // Bounce-in on tap
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.08), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeOut));

    // Shake on mismatch
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -6, end: 3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 3, end: 0), weight: 25),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    // Staggered entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );

    // Glow pulse for matched cards
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Staggered entrance: each card enters with a slight delay
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _entranceController.forward();
    });

    if (widget.isMatched) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _EnhancedMemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Flip animation
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _bounceController.forward(from: 0);
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }

    // Shake on mismatch
    if (widget.isMismatch && !oldWidget.isMismatch) {
      _shakeController.forward(from: 0);
    }

    // Glow on match
    if (widget.isJustMatched && !oldWidget.isJustMatched) {
      _bounceController.forward(from: 0);
      _glowController.repeat(reverse: true);
    }

    // Reset entrance on re-initialize
    if (!widget.isRevealed && !widget.isMatched && oldWidget.isMatched) {
      _glowController.stop();
      _glowController.reset();
      _entranceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _bounceController.dispose();
    _shakeController.dispose();
    _entranceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _mapPairIdToPixarAnimal(String pairId) {
    switch (pairId) {
      case 'puppy':
        return 'dog';
      case 'kitten':
        return 'cat';
      case 'bunny':
        return 'rabbit';
      default:
        return pairId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _flipAnimation,
        _bounceAnimation,
        _shakeAnimation,
        _entranceAnimation,
        _glowAnimation,
      ]),
      builder: (context, _) {
        final entrance = _entranceAnimation.value;
        if (entrance < 0.01) return const SizedBox.shrink();

        final angle = _flipAnimation.value;
        final isUnder = angle > (math.pi / 2);
        final scale = _bounceController.isAnimating
            ? _bounceAnimation.value
            : 1.0;
        final shakeOffset = _shakeController.isAnimating
            ? _shakeAnimation.value
            : 0.0;

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(angle);

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Transform.scale(
            scale: scale * entrance.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Transform(
                transform: transform,
                alignment: Alignment.center,
                child: isUnder
                    ? Transform(
                        transform: Matrix4.identity()..rotateY(math.pi),
                        alignment: Alignment.center,
                        child: _buildCardFront(),
                      )
                    : _buildCardBack(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardFront() {
    final animalId = _mapPairIdToPixarAnimal(widget.card.pairId);
    final isMatched = widget.isMatched;
    final glowValue = _glowAnimation.value;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMatched ? const Color(0xFFFFD54F) : const Color(0xFFC89658),
          width: isMatched ? 3.5 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isMatched
                ? Color.lerp(
                    const Color(0xFFFFB300).withOpacity(0.3),
                    const Color(0xFFFFB300).withOpacity(0.7),
                    glowValue,
                  )!
                : Colors.black.withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: isMatched ? 8 + glowValue * 8 : 5,
            spreadRadius: isMatched ? 1 + glowValue * 3 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle ceramic gloss
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFFFDE7),
                      Color(0xFFF5F5F5),
                    ],
                  ),
                ),
              ),
            ),

            // Top gloss specular highlight
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 16,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Match Sparkles
            if (isMatched) ...[
              const Positioned(
                top: 2,
                right: 2,
                child: Text('✨', style: TextStyle(fontSize: 10)),
              ),
              const Positioned(
                bottom: 2,
                left: 2,
                child: Text('⭐', style: TextStyle(fontSize: 9)),
              ),
            ],

            // 3D Animal Art + label
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Pixar3DAnimalArt(
                  animalId: animalId,
                  size: widget.isCompact ? 34 : 48,
                ),
                const SizedBox(height: 1),
                Text(
                  widget.card.label,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: widget.isCompact ? 8 : 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4E342E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.bgColor,
            widget.bgColor.withOpacity(0.85),
            widget.accentColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 2.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            offset: const Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative pattern
            Positioned.fill(
              child: CustomPaint(
                painter: MemoryTilePatternPainter(
                  primaryColor: widget.bgColor,
                  accentColor: widget.accentColor,
                ),
              ),
            ),

            // Embossed center crown
            Container(
              width: widget.isCompact ? 24 : 32,
              height: widget.isCompact ? 24 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFF9C4), Color(0xFFFFB300), Color(0xFFE65100)],
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Text('👑',
                    style: TextStyle(fontSize: widget.isCompact ? 10 : 13)),
              ),
            ),

            // Top gloss
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 16,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.55),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Combo Popup ──────────────────────────────────────────────

class _ComboPopup extends StatefulWidget {
  final int combo;
  const _ComboPopup({required this.combo});

  @override
  State<_ComboPopup> createState() => _ComboPopupState();
}

class _ComboPopupState extends State<_ComboPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _ComboPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.combo != oldWidget.combo) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: _opacityAnim.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scaleAnim.value.clamp(0.0, 2.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6D00), Color(0xFFFFAB00)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6D00).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '🔥 ${widget.combo}× COMBO! 🔥',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Victory Overlay ──────────────────────────────────────────

class _VictoryOverlay extends StatefulWidget {
  final int starRating;
  final int totalScore;
  final int moveCount;
  final int bestCombo;
  final VoidCallback onPlayAgain;

  const _VictoryOverlay({
    required this.starRating,
    required this.totalScore,
    required this.moveCount,
    required this.bestCombo,
    required this.onPlayAgain,
  });

  @override
  State<_VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<_VictoryOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _contentController;
  late Animation<double> _bgOpacity;
  late Animation<double> _contentScale;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bgOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.elasticOut),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _bgController.forward().then((_) {
      _contentController.forward().then((_) {
        _starController.forward();
      });
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bgOpacity, _contentScale, _starController]),
      builder: (context, _) {
        return Positioned.fill(
          child: Opacity(
            opacity: _bgOpacity.value.clamp(0.0, 1.0),
            child: Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Transform.scale(
                  scale: _contentScale.value.clamp(0.0, 2.0),
                  child: Container(
                    width: 300,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.82,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFF9EE), Color(0xFFFFE0B2)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFFFB300), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        // Trophy
                        const Text('🏆', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 8),

                        // "GREAT JOB!"
                        Text(
                          'GREAT JOB!',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFE65100),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: const Offset(1, 2),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final starDelay = i * 0.3;
                            final starProgress = (_starController.value - starDelay).clamp(0.0, 0.4) / 0.4;
                            final isFilled = i < widget.starRating;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Transform.scale(
                                scale: isFilled ? 0.5 + starProgress * 0.5 : 0.8,
                                child: Text(
                                  isFilled ? '⭐' : '☆',
                                  style: TextStyle(
                                    fontSize: 38,
                                    color: isFilled
                                        ? null
                                        : const Color(0xFFBDBDBD),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),

                        // Stats
                        _victoryStatRow('🪙 Score', '${widget.totalScore}'),
                        _victoryStatRow('🎯 Moves', '${widget.moveCount}'),
                        _victoryStatRow('🔥 Best Combo', '${widget.bestCombo}×'),
                        const SizedBox(height: 20),

                        // Play Again Button
                        CandyPillButton(
                          width: 160,
                          height: 44,
                          borderRadius: 22,
                          color: const Color(0xFF4CAF50),
                          borderColor: Colors.white,
                          onPressed: widget.onPlayAgain,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'PLAY AGAIN',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _victoryStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5D4037),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }
}
