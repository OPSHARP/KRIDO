import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../audio/procedural_sfx_engine.dart';

/// ---------------------------------------------------------------------------
/// BOUNCY BOUNCE TAP WIDGET
/// Wraps any UI element with responsive squishy physics:
/// - Shrinks & tilts playfully on finger touch down (0.88 scale + slight spring tilt)
/// - Bounces back with an elastic cartoon overshoot on finger lift (Curves.elasticOut)
/// - Triggers subtle haptic clicks and optional bubble pop sound cues
/// ---------------------------------------------------------------------------
class BouncyBounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double squishScale;
  final bool playSound;
  final bool enableHaptic;
  final HitTestBehavior behavior;

  const BouncyBounceTap({
    super.key,
    required this.child,
    this.onTap,
    this.squishScale = 0.88,
    this.playSound = true,
    this.enableHaptic = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BouncyBounceTap> createState() => _BouncyBounceTapState();
}

class _BouncyBounceTapState extends State<BouncyBounceTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.squishScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuad,
        reverseCurve: Curves.elasticOut,
      ),
    );

    _tiltAnimation = Tween<double>(
      begin: 0.0,
      end: -0.03,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuad,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didUpdateWidget(BouncyBounceTap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.squishScale != widget.squishScale) {
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.squishScale,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOutQuad,
          reverseCurve: Curves.elasticOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    if (widget.playSound) {
      ProceduralSfxEngine().playPop();
    } else if (widget.enableHaptic) {
      HapticFeedback.lightImpact().catchError((_) {});
    }
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap == null) return;
    if (_controller.isAnimating || _controller.value > 0) {
      _controller.reverse();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (mounted && (_controller.isAnimating || _controller.value > 0)) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _tiltAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// PLAYFUL WOBBLE TEXT
/// Makes title text, points, or badges playfully bob up and down with
/// an organic cartoon wobble rhythm.
/// ---------------------------------------------------------------------------
class PlayfulWobbleText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration period;
  final double wobbleDegrees;

  const PlayfulWobbleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.period = const Duration(milliseconds: 2000),
    this.wobbleDegrees = 2.0,
  });

  @override
  State<PlayfulWobbleText> createState() => _PlayfulWobbleTextState();
}

class _PlayfulWobbleTextState extends State<PlayfulWobbleText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final val = _animController.value;
        final angle = (math.sin(val * math.pi * 2) * widget.wobbleDegrees) *
            (math.pi / 180.0);
        final translateY = math.sin(val * math.pi * 2) * 2.5;

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.rotate(
            angle: angle,
            child: child,
          ),
        );
      },
      child: Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// FLOATING BOUNCY BOB
/// Gives characters, trophies, stars, and mascots a gentle breathing/floating
/// motion so the UI feels continuously animated and vibrant.
/// ---------------------------------------------------------------------------
class FloatingBouncyBob extends StatefulWidget {
  final Widget child;
  final double bobDistance;
  final Duration duration;
  final bool animateScale;

  const FloatingBouncyBob({
    super.key,
    required this.child,
    this.bobDistance = 5.0,
    this.duration = const Duration(milliseconds: 2200),
    this.animateScale = true,
  });

  @override
  State<FloatingBouncyBob> createState() => _FloatingBouncyBobState();
}

class _FloatingBouncyBobState extends State<FloatingBouncyBob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
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
      builder: (context, child) {
        final val = _controller.value;
        final dy = math.sin(val * math.pi) * widget.bobDistance;
        final scale = widget.animateScale
            ? 1.0 + (math.sin(val * math.pi) * 0.035)
            : 1.0;

        return Transform.translate(
          offset: Offset(0, -dy),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// ---------------------------------------------------------------------------
/// BOUNCY PAGE ROUTE TRANSITION
/// Cartoon-like elastic scale/zoom transition for smooth child-friendly
/// navigation between screens.
/// ---------------------------------------------------------------------------
class BouncyPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  BouncyPageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeInBack,
              ),
            );
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        );
}
