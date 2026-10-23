import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../audio/procedural_sfx_engine.dart';

/// ---------------------------------------------------------------------------
/// KAWAII FACE WIDGET
/// Renders the signature expressive cartoon smiling face seen across all 5
/// reference images: black oval eyes with dual white specular highlights,
/// rosy pink blush cheeks, and a happy smiling curved mouth.
/// ---------------------------------------------------------------------------
class KawaiiFace extends StatelessWidget {
  final double size;
  final bool isWinking;
  final Color eyeColor;
  final Color mouthColor;
  final Color blushColor;
  final double eyeSpacing;

  const KawaiiFace({
    super.key,
    this.size = 48,
    this.isWinking = false,
    this.eyeColor = const Color(0xFF1E272E),
    this.mouthColor = const Color(0xFF1E272E),
    this.blushColor = const Color(0xFFFF8DA1),
    this.eyeSpacing = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.55,
      child: CustomPaint(
        painter: _KawaiiFacePainter(
          isWinking: isWinking,
          eyeColor: eyeColor,
          mouthColor: mouthColor,
          blushColor: blushColor,
          eyeSpacing: eyeSpacing,
        ),
      ),
    );
  }
}

class _KawaiiFacePainter extends CustomPainter {
  final bool isWinking;
  final Color eyeColor;
  final Color mouthColor;
  final Color blushColor;
  final double eyeSpacing;

  _KawaiiFacePainter({
    required this.isWinking,
    required this.eyeColor,
    required this.mouthColor,
    required this.blushColor,
    required this.eyeSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    final gleamPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final blushPaint = Paint()
      ..color = blushColor.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    final mouthPaint = Paint()
      ..color = mouthColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, size.width * 0.05)
      ..strokeCap = StrokeCap.round;

    final eyeRadius = size.height * 0.22;
    final halfSpacing = (size.width * eyeSpacing) / 2;
    final leftEyeCenter = Offset(size.width / 2 - halfSpacing, size.height * 0.35);
    final rightEyeCenter = Offset(size.width / 2 + halfSpacing, size.height * 0.35);

    // Left Eye
    canvas.drawOval(
      Rect.fromCenter(
        center: leftEyeCenter,
        width: eyeRadius * 1.5,
        height: eyeRadius * 1.9,
      ),
      eyePaint,
    );
    // Left Eye Highlights (Dual white sparkles)
    canvas.drawCircle(
      Offset(leftEyeCenter.dx - eyeRadius * 0.25, leftEyeCenter.dy - eyeRadius * 0.35),
      eyeRadius * 0.45,
      gleamPaint,
    );
    canvas.drawCircle(
      Offset(leftEyeCenter.dx + eyeRadius * 0.3, leftEyeCenter.dy + eyeRadius * 0.35),
      eyeRadius * 0.22,
      gleamPaint,
    );

    // Right Eye (Open or Winking)
    if (isWinking) {
      final winkPath = Path()
        ..moveTo(rightEyeCenter.dx - eyeRadius, rightEyeCenter.dy)
        ..quadraticBezierTo(
          rightEyeCenter.dx,
          rightEyeCenter.dy - eyeRadius * 0.8,
          rightEyeCenter.dx + eyeRadius,
          rightEyeCenter.dy,
        );
      canvas.drawPath(winkPath, mouthPaint);
    } else {
      canvas.drawOval(
        Rect.fromCenter(
          center: rightEyeCenter,
          width: eyeRadius * 1.5,
          height: eyeRadius * 1.9,
        ),
        eyePaint,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx - eyeRadius * 0.25, rightEyeCenter.dy - eyeRadius * 0.35),
        eyeRadius * 0.45,
        gleamPaint,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx + eyeRadius * 0.3, rightEyeCenter.dy + eyeRadius * 0.35),
        eyeRadius * 0.22,
        gleamPaint,
      );
    }

    // Rosy Blush Cheeks
    final blushRadius = eyeRadius * 1.2;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftEyeCenter.dx - eyeRadius * 0.8, leftEyeCenter.dy + eyeRadius * 1.0),
        width: blushRadius * 1.4,
        height: blushRadius * 0.8,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rightEyeCenter.dx + eyeRadius * 0.8, rightEyeCenter.dy + eyeRadius * 1.0),
        width: blushRadius * 1.4,
        height: blushRadius * 0.8,
      ),
      blushPaint,
    );

    // Happy Smiling Mouth
    final mouthCenter = Offset(size.width / 2, size.height * 0.65);
    final mouthPath = Path()
      ..moveTo(mouthCenter.dx - size.width * 0.12, mouthCenter.dy)
      ..quadraticBezierTo(
        mouthCenter.dx,
        mouthCenter.dy + size.height * 0.32,
        mouthCenter.dx + size.width * 0.12,
        mouthCenter.dy,
      );
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant _KawaiiFacePainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------------
/// CARTOON SUN WIDGET
/// Smiling sun with cute cheeks and golden rays, present in all screenshots.
/// ---------------------------------------------------------------------------
class CartoonSun extends StatelessWidget {
  final double size;

  const CartoonSun({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sun rays
          CustomPaint(
            size: Size(size, size),
            painter: _SunRaysPainter(),
          ),
          // Sun Body
          Container(
            width: size * 0.68,
            height: size * 0.68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFF176), Color(0xFFFFB300)],
                center: Alignment(-0.2, -0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: KawaiiFace(
                size: size * 0.44,
                blushColor: const Color(0xFFFF7043),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFFFCA28)
      ..style = PaintingStyle.fill;

    const count = 12;
    final rOuter = size.width * 0.48;
    final rInner = size.width * 0.35;

    final path = Path();
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count;
      final midAngle = angle + (math.pi / count);

      final x1 = center.dx + rInner * math.cos(angle);
      final y1 = center.dy + rInner * math.sin(angle);
      final xPeak = center.dx + rOuter * math.cos(midAngle);
      final yPeak = center.dy + rOuter * math.sin(midAngle);
      final x2 = center.dx + rInner * math.cos(angle + 2 * math.pi / count);
      final y2 = center.dy + rInner * math.sin(angle + 2 * math.pi / count);

      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.quadraticBezierTo(xPeak, yPeak, x2, y2);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------------
/// 3D BUBBLE TITLE WIDGET
/// Multi-colored 3D cartoon title with bold white outline, drop shadow,
/// and optional plaque container as seen in "FIND THE B!", "DOGGY PUZZLE!",
/// "SHAPE MATCH!", "MEMORY MATCH", and "COUNT THE APPLES!".
/// ---------------------------------------------------------------------------
class BubbleTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final List<Color>? rainbowColors;
  final bool showPlaque;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const BubbleTitle({
    super.key,
    required this.text,
    this.fontSize = 28,
    this.rainbowColors,
    this.showPlaque = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  static const List<Color> defaultRainbow = [
    Color(0xFFFF4B4B), // Red
    Color(0xFFFFA502), // Orange
    Color(0xFFFFD43B), // Yellow
    Color(0xFF2ED573), // Green
    Color(0xFF1E90FF), // Blue
    Color(0xFF845EF7), // Purple
    Color(0xFFFF6B81), // Pink
  ];

  @override
  Widget build(BuildContext context) {
    final colors = rainbowColors ?? defaultRainbow;

    Widget titleRow = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 8),
          ],
          ...List.generate(text.length, (index) {
            final char = text[index];
            if (char == ' ') {
              return SizedBox(width: fontSize * 0.35);
            }
            final color = colors[index % colors.length];
            return _BubbleLetter(
              char: char,
              color: color,
              fontSize: fontSize,
            );
          }),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            trailingIcon!,
          ],
        ],
      ),
    );

    if (!showPlaque) {
      return titleRow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFC89658), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D5B28).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white,
            offset: const Offset(0, -2),
            blurRadius: 0,
          ),
        ],
      ),
      child: titleRow,
    );
  }
}

class _BubbleLetter extends StatelessWidget {
  final String char;
  final Color color;
  final double fontSize;

  const _BubbleLetter({
    required this.char,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.bubblegumSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
    );

    return Stack(
      children: [
        // 1. Dark bottom 3D shadow
        Text(
          char,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = fontSize * 0.22
              ..color = const Color(0xFF1E272E).withOpacity(0.4),
          ),
        ),
        // 2. Thick White Outline
        Text(
          char,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = fontSize * 0.18
              ..color = Colors.white,
          ),
        ),
        // 3. Colored Core
        Text(
          char,
          style: style.copyWith(
            color: color,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(1, 2),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// GLOSSY CANDY PILL BUTTON
/// High-gloss 3D rounded button with colored bevel, highlight shine gradient,
/// and bouncy press feel (e.g. Sound 🔊, Music 🎵, Undo ↩️, Home 🏠, Reset).
/// ---------------------------------------------------------------------------
class CandyPillButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color? borderColor;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CandyPillButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color = AppTheme.candyOrange,
    this.borderColor,
    this.width = 52,
    this.height = 52,
    this.borderRadius = 26,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<CandyPillButton> createState() => _CandyPillButtonState();
}

class _CandyPillButtonState extends State<CandyPillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.borderColor ?? Colors.white.withOpacity(0.9);
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              widget.onPressed?.call();
            }
          : null,
      onTapDown: isEnabled
          ? (_) {
              setState(() => _isPressed = true);
              HapticFeedback.lightImpact().catchError((_) {});
              ProceduralSfxEngine().playPop();
            }
          : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
            }
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        curve: _isPressed ? Curves.easeInOutQuad : Curves.elasticOut,
        duration: Duration(milliseconds: _isPressed ? 80 : 360),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HSLColor.fromColor(widget.color).withLightness(
                  (HSLColor.fromColor(widget.color).lightness + 0.12).clamp(0.0, 1.0),
                ).toColor(),
                widget.color,
                HSLColor.fromColor(widget.color).withLightness(
                  (HSLColor.fromColor(widget.color).lightness - 0.12).clamp(0.0, 1.0),
                ).toColor(),
              ],
            ),
            border: Border.all(color: border, width: 3.2),
            boxShadow: [
              BoxShadow(
                color: HSLColor.fromColor(widget.color)
                    .withLightness((HSLColor.fromColor(widget.color).lightness - 0.25).clamp(0.0, 1.0))
                    .toColor(),
                offset: _isPressed ? const Offset(0, 1.5) : const Offset(0, 4),
                blurRadius: _isPressed ? 1 : 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                offset: const Offset(0, 5),
                blurRadius: 6,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gloss highlight at the top half
              Positioned(
                top: 2,
                left: 4,
                right: 4,
                height: (widget.height / 2) - 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(widget.borderRadius - 2),
                      bottom: Radius.elliptical(widget.width / 2, 8),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.45),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              Center(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// CHUNKY CANDY CARD TILE
/// Squircle block with glossy shine and thick contrasting border (e.g. C, B, D
/// cards in Image 1, or Memory match cards in Image 4).
/// ---------------------------------------------------------------------------
class CandyCardTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double width;
  final double height;
  final double borderRadius;
  final bool isSelected;
  final bool showSparkles;

  const CandyCardTile({
    super.key,
    required this.child,
    this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    this.width = 110,
    this.height = 110,
    this.borderRadius = 28,
    this.isSelected = false,
    this.showSparkles = false,
  });

  @override
  State<CandyCardTile> createState() => _CandyCardTileState();
}

class _CandyCardTileState extends State<CandyCardTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick().catchError((_) {});
        ProceduralSfxEngine().playPop();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : (widget.isSelected ? 1.06 : 1.0),
        curve: _isPressed ? Curves.easeInOutQuad : Curves.elasticOut,
        duration: Duration(milliseconds: _isPressed ? 90 : 380),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.borderColor,
              width: widget.isSelected ? 5.5 : 4.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.borderColor.withOpacity(0.4),
                offset: const Offset(0, 5),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(0, 7),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius - 4),
            child: Stack(
              children: [
                // Top Gloss Crescent Shine
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: widget.height * 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.42),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sparkles (if highlighted/correct)
                if (widget.showSparkles) ...[
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Text('✨', style: TextStyle(fontSize: 16)),
                  ),
                  const Positioned(
                    bottom: 8,
                    left: 8,
                    child: Text('✨', style: TextStyle(fontSize: 14)),
                  ),
                ],

                Center(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// CARVED WOODEN TABLET FRAME
/// Carved natural wood border (`#C89658`) with beveled 3D rim and warm cream
/// playfield tray, housing games in Images 2, 3, and 5.
/// ---------------------------------------------------------------------------
class WoodenTabletFrame extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final double cornerRadius;
  final bool showCornerLeaves;
  final Color trayColor;

  const WoodenTabletFrame({
    super.key,
    required this.child,
    this.borderWidth = 12.0,
    this.cornerRadius = 28.0,
    this.showCornerLeaves = false,
    this.trayColor = const Color(0xFFFFF9EE),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC89658),
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: const Color(0xFF8D5B28), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A3816).withOpacity(0.4),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
          const BoxShadow(
            color: Color(0xFFE5C290),
            offset: Offset(0, -2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: trayColor,
            borderRadius: BorderRadius.circular(cornerRadius - borderWidth / 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5A3816).withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius - borderWidth / 2),
            child: Stack(
              children: [
                child,
                if (showCornerLeaves) ...[
                  // Decorative corner leaves
                  Positioned(
                    top: 4,
                    left: 4,
                    child: _buildLeafCluster(0),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _buildLeafCluster(math.pi / 2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeafCluster(double angle) {
    return Transform.rotate(
      angle: angle,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, color: Color(0xFF80C94A), size: 20),
          Icon(Icons.eco_rounded, color: Color(0xFFFFA502), size: 16),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// CARTOON TOP BAR
/// Universal top bar matching the layouts of Images 1, 2, 3, 5:
/// - Left: Stars pill or Back pill
/// - Center: Sun + 3D Title banner
/// - Right: Progress/Level pill, 🎵 Music, 🔊 Sound, 🏠 Home
/// ---------------------------------------------------------------------------
class CartoonTopBar extends StatelessWidget {
  final Widget? leftWidget;
  final Widget? centerWidget;
  final Widget? rightWidget;
  final VoidCallback? onHomeTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onMusicToggle;
  final VoidCallback? onSoundToggle;
  final bool isMusicMuted;
  final bool isSoundMuted;

  const CartoonTopBar({
    super.key,
    this.leftWidget,
    this.centerWidget,
    this.rightWidget,
    this.onHomeTap,
    this.onBackTap,
    this.onMusicToggle,
    this.onSoundToggle,
    this.isMusicMuted = false,
    this.isSoundMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    return Container(
      padding: EdgeInsets.only(
        left: math.max(12.0, safePadding.left),
        right: math.max(12.0, safePadding.right),
        top: math.max(4.0, safePadding.top * 0.4),
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Area
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onBackTap != null) ...[
                CandyPillButton(
                  width: 44,
                  height: 44,
                  color: AppTheme.candyGreen,
                  onPressed: onBackTap,
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 8),
              ],
              ?leftWidget,
            ],
          ),

          // Center Area (Title plaque or Sun)
          if (centerWidget != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: centerWidget!,
              ),
            ),

          // Right Area (Progress, Sound, Music, Home)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rightWidget != null) ...[
                rightWidget!,
                const SizedBox(width: 8),
              ],
              if (onMusicToggle != null) ...[
                CandyPillButton(
                  width: 44,
                  height: 44,
                  color: AppTheme.candyHotPink,
                  onPressed: onMusicToggle,
                  child: Icon(
                    isMusicMuted ? Icons.music_off_rounded : Icons.music_note_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (onSoundToggle != null) ...[
                CandyPillButton(
                  width: 44,
                  height: 44,
                  color: AppTheme.candyOrange,
                  onPressed: onSoundToggle,
                  child: Icon(
                    isSoundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (onHomeTap != null) ...[
                CandyPillButton(
                  width: 44,
                  height: 44,
                  color: AppTheme.coral,
                  onPressed: onHomeTap,
                  child: const Icon(Icons.home_rounded, color: Colors.white, size: 26),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// PILL BADGE WIDGET
/// Used for "STARS: ⭐⭐", "4/10 ⭐", "LEVEL 1-2", "SCORE: 100"
/// ---------------------------------------------------------------------------
class PillBadge extends StatelessWidget {
  final Widget content;
  final Color backgroundColor;
  final Color borderColor;
  final double height;
  final EdgeInsetsGeometry padding;

  const PillBadge({
    super.key,
    required this.content,
    this.backgroundColor = const Color(0xFF7150B8),
    this.borderColor = Colors.white,
    this.height = 38,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(child: content),
    );
  }
}

/// ---------------------------------------------------------------------------
/// CARTOON SCENIC BACKGROUND
/// Outdoor sunny blue sky, puffy white clouds, distant green hills,
/// floating balloons, and playful stars.
/// ---------------------------------------------------------------------------
class CartoonScenicBackground extends StatelessWidget {
  final Widget child;

  const CartoonScenicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sky Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF67B6F6),
                Color(0xFFADE3FE),
                Color(0xFFE2F4FD),
              ],
              stops: [0.0, 0.65, 1.0],
            ),
          ),
        ),

        // Puffy Clouds & Ambient Stars
        Positioned(
          top: 30,
          left: 40,
          child: _buildCloud(80, 45),
        ),
        Positioned(
          top: 60,
          right: 60,
          child: _buildCloud(110, 55),
        ),
        Positioned(
          top: 110,
          left: 180,
          child: _buildCloud(70, 40),
        ),

        // Colorful Little Stars
        const Positioned(
          top: 80,
          left: 130,
          child: Text('⭐', style: TextStyle(fontSize: 16)),
        ),
        const Positioned(
          top: 140,
          right: 120,
          child: Text('⭐', style: TextStyle(fontSize: 20)),
        ),
        const Positioned(
          top: 190,
          right: 40,
          child: Text('✨', style: TextStyle(fontSize: 18)),
        ),

        // Rolling Hills at the bottom
        Positioned(
          bottom: -40,
          left: -40,
          right: -40,
          height: 140,
          child: CustomPaint(
            painter: _RollingHillsPainter(),
          ),
        ),

        child,
      ],
    );
  }

  Widget _buildCloud(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _RollingHillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBack = Paint()
      ..color = const Color(0xFF90DB5E)
      ..style = PaintingStyle.fill;

    final paintFront = Paint()
      ..color = const Color(0xFF76C844)
      ..style = PaintingStyle.fill;

    // Back Hill
    final pathBack = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.1, size.width * 0.7, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.6, size.width, size.height * 0.35)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathBack, paintBack);

    // Front Hill
    final pathFront = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.35, size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathFront, paintFront);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------------
/// POLKA DOT PATTERN PAINTER
/// For letters and balls (as seen on B in Image 1 and Red Ball in Image 3).
/// ---------------------------------------------------------------------------
class PolkaDotPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double radius;

  PolkaDotPainter({
    this.dotColor = const Color(0xFFFFB300),
    this.spacing = 18.0,
    this.radius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double y = radius; y < size.height; y += spacing) {
      final offsetX = ((y ~/ spacing) % 2) * (spacing / 2);
      for (double x = radius + offsetX; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PolkaDotPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------------
/// MEMORY TILE ORNAMENTAL PATTERN PAINTER
/// Matches the decorative star and swirl pattern from Image 4.
/// ---------------------------------------------------------------------------
class MemoryTilePatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  MemoryTilePatternPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = accentColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Corner decorative dots
    const pad = 10.0;
    canvas.drawCircle(const Offset(pad, pad), 3.0, accentPaint);
    canvas.drawCircle(Offset(size.width - pad, pad), 3.0, accentPaint);
    canvas.drawCircle(Offset(pad, size.height - pad), 3.0, accentPaint);
    canvas.drawCircle(Offset(size.width - pad, size.height - pad), 3.0, accentPaint);

    // Decorative corner curl swirls
    final r = size.width * 0.22;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(pad * 1.5, pad * 1.5), radius: r * 0.6),
      0,
      math.pi / 2,
      false,
      strokePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - pad * 1.5, size.height - pad * 1.5), radius: r * 0.6),
      math.pi,
      math.pi / 2,
      false,
      strokePaint,
    );

    // Center star
    _drawStar(canvas, center, 5, size.width * 0.22, size.width * 0.11, accentPaint);
  }

  void _drawStar(Canvas canvas, Offset center, int points, double outerR, double innerR, Paint paint) {
    final path = Path();
    final step = math.pi / points;
    double angle = -math.pi / 2;

    for (int i = 0; i < 2 * points; i++) {
      final r = (i % 2 == 0) ? outerR : innerR;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MemoryTilePatternPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------------
/// CARTOON GAME SCAFFOLD
/// Uniform candy-themed scaffold for mini-games with back button, header,
/// pastel gradient backdrop, and safe area layout.
/// ---------------------------------------------------------------------------
class CartoonGameScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onHint;
  final Widget child;
  final List<Color>? backgroundColors;

  const CartoonGameScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.onHint,
    required this.child,
    this.backgroundColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = backgroundColors ?? const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)];

    return Scaffold(
      backgroundColor: colors.first,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors,
                  ),
                ),
              ),
            ),

            // Main layout
            Column(
              children: [
                // Top Header Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (onBack != null)
                        CandyPillButton(
                          width: 44,
                          height: 40,
                          borderRadius: 20,
                          color: const Color(0xFFFFCC80),
                          borderColor: Colors.white,
                          onPressed: onBack!,
                          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFE65100), size: 24),
                        )
                      else
                        const SizedBox(width: 44),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (onHint != null)
                        CandyPillButton(
                          width: 44,
                          height: 40,
                          borderRadius: 20,
                          color: const Color(0xFFFFF176),
                          borderColor: Colors.white,
                          onPressed: onHint!,
                          child: const Icon(Icons.lightbulb_rounded, color: Color(0xFFF57F17), size: 24),
                        ),
                    ],
                  ),
                ),

                // Game Content Body
                Expanded(child: child),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// CARTOON BUTTON
/// Playful bouncy rounded button with bubblegum typography and shadow.
/// ---------------------------------------------------------------------------
class CartoonButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const CartoonButton({
    super.key,
    required this.text,
    required this.color,
    this.onPressed,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  State<CartoonButton> createState() => _CartoonButtonState();
}

class _CartoonButtonState extends State<CartoonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final effectiveColor = isEnabled ? widget.color : Colors.grey.shade400;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: isEnabled && !_isPressed
                ? [
                    BoxShadow(
                      color: effectiveColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.bubblegumSans(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

