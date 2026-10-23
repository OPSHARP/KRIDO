import 'package:flutter/material.dart';
import '../audio/procedural_sfx_engine.dart';

/// Interactive 3D Perspective Tilt Card
/// Responds to parallax tiltX and tiltY by rotating in 3D space,
/// casting responsive drop shadows, and shifting an interactive gloss glare reflection.
class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final double tiltX;
  final double tiltY;
  final double maxTiltAngle;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? glowColor;

  const Tilt3DCard({
    super.key,
    required this.child,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
    this.maxTiltAngle = 0.16, // In radians
    this.onTap,
    this.borderRadius = 24.0,
    this.glowColor,
  });

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressAnimController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3D Perspective Matrix
    final rotateY = widget.tiltX * widget.maxTiltAngle;
    final rotateX = -widget.tiltY * widget.maxTiltAngle;

    final transformMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0014) // Perspective depth
      ..rotateY(rotateY)
      ..rotateX(rotateX);

    final shadowOffsetX = -widget.tiltX * 14.0;
    final shadowOffsetY = 10.0 - (widget.tiltY * 8.0);

    return GestureDetector(
      onTapDown: (_) {
        _pressAnimController.forward();
        ProceduralSfxEngine().playPop();
      },
      onTapUp: (_) {
        _pressAnimController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _pressAnimController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform(
              transform: transformMatrix,
              alignment: FractionalOffset.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    // Dynamic parallax shadow opposite to tilt
                    BoxShadow(
                      color: (widget.glowColor ?? Colors.black).withOpacity(0.22),
                      offset: Offset(shadowOffsetX, shadowOffsetY),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Stack(
                    children: [
                      // Main Card Content
                      widget.child,

                      // Specular Gloss Glare reflection moving with tilt
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(
                                  -widget.tiltX * 1.5 - 0.5,
                                  -widget.tiltY * 1.5 - 0.5,
                                ),
                                end: Alignment(
                                  -widget.tiltX * 1.5 + 0.5,
                                  -widget.tiltY * 1.5 + 0.5,
                                ),
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
