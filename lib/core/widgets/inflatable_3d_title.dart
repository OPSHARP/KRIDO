import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 3D Inflatable Glossy Title Widget for KRIDO
/// Featuring bubbly balloon letters for "KRIDO" (K: Gold + Crown, R: Coral, I: Green, D: Blue, O: Purple),
/// and the playful slogan "Little Games. Big Discoveries."
class Inflatable3DTitle extends StatelessWidget {
  final double scale;
  final bool showSubtitle;
  final VoidCallback? onTap;

  const Inflatable3DTitle({
    super.key,
    this.scale = 1.0,
    this.showSubtitle = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letterSize = 34.0 * scale;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row 1: "KRIDO" Inflatable 3D Balloon Letters
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInflatableLetter(
                letter: 'K',
                size: letterSize,
                colors: const [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                shadowColor: const Color(0xFFE65100),
                crown: true,
              ),
              SizedBox(width: 3.5 * scale),
              _buildInflatableLetter(
                letter: 'R',
                size: letterSize,
                colors: const [Color(0xFFFF5252), Color(0xFFFF1744)],
                shadowColor: const Color(0xFF880E4F),
              ),
              SizedBox(width: 3.5 * scale),
              _buildInflatableLetter(
                letter: 'I',
                size: letterSize,
                colors: const [Color(0xFFB2FF59), Color(0xFF00E676)],
                shadowColor: const Color(0xFF1B5E20),
              ),
              SizedBox(width: 3.5 * scale),
              _buildInflatableLetter(
                letter: 'D',
                size: letterSize,
                colors: const [Color(0xFF40C4FF), Color(0xFF2979FF)],
                shadowColor: const Color(0xFF0D47A1),
              ),
              SizedBox(width: 3.5 * scale),
              _buildInflatableLetter(
                letter: 'O',
                size: letterSize,
                colors: const [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                shadowColor: const Color(0xFF4A148C),
              ),
            ],
          ),

          // Row 2: Subtitle slogan
          if (showSubtitle) ...[
            SizedBox(height: 3 * scale),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * scale,
                vertical: 2 * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(10 * scale),
                border: Border.all(
                  color: const Color(0xFF0D254C).withOpacity(0.2),
                  width: 1.2 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: Offset(0, 2 * scale),
                    blurRadius: 3 * scale,
                  ),
                ],
              ),
              child: Text(
                'Play • Learn • Discover',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0D254C),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInflatableLetter({
    required String letter,
    required double size,
    required List<Color> colors,
    required Color shadowColor,
    bool crown = false,
  }) {
    final letterBox = Container(
      width: size * 0.95,
      height: size * 1.15,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(size * 0.38),
        border: Border.all(color: const Color(0xFF0D254C), width: 3.0 * scale),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.85),
            offset: Offset(0, 3.5 * scale),
            blurRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF0D254C).withOpacity(0.4),
            offset: Offset(1.5 * scale, 4.5 * scale),
            blurRadius: 2 * scale,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Specular Gloss Highlight Pill at top
          Positioned(
            top: size * 0.12,
            left: size * 0.16,
            child: Container(
              width: size * 0.32,
              height: size * 0.16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
            ),
          ),

          // The Letter Character
          Text(
            letter,
            style: GoogleFonts.bubblegumSans(
              fontSize: size * 0.82,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.35),
                  offset: Offset(1 * scale, 1.5 * scale),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!crown) return letterBox;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        letterBox,
        Positioned(
          top: -size * 0.35,
          left: -size * 0.12,
          child: Transform.rotate(
            angle: -0.22,
            child: Text(
              '👑',
              style: TextStyle(fontSize: size * 0.44),
            ),
          ),
        ),
      ],
    );
  }
}
