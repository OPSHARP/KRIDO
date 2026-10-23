import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../app/theme.dart';
import '../../core/widgets/cartoon_ui_components.dart';
import 'toy_collection_service.dart';
import 'toy_collection_shelf_dialog.dart';

/// 3D Surprise Egg Gacha Machine Dialog:
/// Features turning crank knob, rolling surprise egg chute,
/// and interactive 3-tap egg cracking sequence revealing collectible 3D toys.
class GachaMachineDialog extends ConsumerStatefulWidget {
  const GachaMachineDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'GachaMachineDialog',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) => const GachaMachineDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<GachaMachineDialog> createState() => _GachaMachineDialogState();
}

enum _GachaPhase {
  ready,
  cranking,
  eggDropped,
  cracking,
  revealed,
}

class _GachaMachineDialogState extends ConsumerState<GachaMachineDialog>
    with TickerProviderStateMixin {
  _GachaPhase _phase = _GachaPhase.ready;
  int _crackTaps = 0;
  ToyItem? _hatchedToy;

  late AnimationController _crankController;
  late AnimationController _eggDropController;
  late AnimationController _wobbleController;
  late AnimationController _revealController;

  static const List<Color> _eggColors = [
    Color(0xFFFF5252),
    Color(0xFFFFB300),
    Color(0xFF00E5FF),
    Color(0xFFE040FB),
    Color(0xFF69F0AE),
  ];
  Color _currentEggColor = const Color(0xFFFFB300);

  @override
  void initState() {
    super.initState();

    _crankController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _eggDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _crankController.dispose();
    _eggDropController.dispose();
    _wobbleController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _onTurnCrank() {
    final state = ref.read(toyCollectionProvider);
    if (state.eggsAvailable <= 0) {
      AudioService().playCue(SoundCue.wrong);
      return;
    }

    HapticFeedback.heavyImpact().catchError((_) {});
    AudioService().playCue(SoundCue.drumRoll);

    setState(() {
      _phase = _GachaPhase.cranking;
      _currentEggColor = _eggColors[math.Random().nextInt(_eggColors.length)];
      _crackTaps = 0;
    });

    _crankController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      AudioService().playCue(SoundCue.drop);
      setState(() {
        _phase = _GachaPhase.eggDropped;
      });
      _eggDropController.forward(from: 0.0).then((_) {
        if (!mounted) return;
        setState(() {
          _phase = _GachaPhase.cracking;
        });
      });
    });
  }

  void _onTapEgg() {
    if (_phase != _GachaPhase.cracking) return;

    HapticFeedback.mediumImpact().catchError((_) {});
    _wobbleController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      _wobbleController.reverse();
    });

    setState(() {
      _crackTaps++;
    });

    if (_crackTaps == 1) {
      AudioService().playCue(SoundCue.snap);
    } else if (_crackTaps == 2) {
      AudioService().playCue(SoundCue.snap);
      AudioService().playCue(SoundCue.star);
    } else if (_crackTaps >= 3) {
      // BURST OPEN!
      final hatched = ref.read(toyCollectionProvider.notifier).hatchEgg();
      setState(() {
        _hatchedToy = hatched;
        _phase = _GachaPhase.revealed;
      });
      _revealController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionState = ref.watch(toyCollectionProvider);
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: math.min(isLandscape ? 620.0 : 360.0, screenSize.width * 0.95),
          height: math.min(isLandscape ? 380.0 : 540.0, screenSize.height * 0.94),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF8A80),
                Color(0xFFFF5252),
                Color(0xFFD50000),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFFD54F), width: 5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Eggs count pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFB300), width: 2),
                    ),
                    child: Row(
                      children: [
                        const Text('🥚', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          '${collectionState.eggsAvailable} Eggs Left',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFD84315),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'KRIDO Gacha Machine 🎁',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: isLandscape ? 22 : 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black38, offset: Offset(1, 2), blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ProceduralSfxEngine().playPop();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Main Stage Body
              Expanded(
                child: _phase == _GachaPhase.revealed
                    ? _buildRevealedToyView()
                    : _buildMachineStage(collectionState, isLandscape),
              ),

              const SizedBox(height: 8),

              // Bottom buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CandyPillButton(
                    width: 140,
                    height: 40,
                    color: const Color(0xFF7E57C2),
                    borderColor: Colors.white,
                    onPressed: () {
                      ProceduralSfxEngine().playPop();
                      Navigator.of(context).pop();
                      ToyCollectionShelfDialog.show(context);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🧸', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            'Toy Shelf',
                            style: GoogleFonts.bubblegumSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_phase == _GachaPhase.revealed) ...[
                    const SizedBox(width: 16),
                    CandyPillButton(
                      width: 150,
                      height: 40,
                      color: const Color(0xFF4CAF50),
                      borderColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          _phase = _GachaPhase.ready;
                          _crackTaps = 0;
                          _hatchedToy = null;
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Open Another! 🥚',
                          style: GoogleFonts.bubblegumSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineStage(ToyCollectionState state, bool isLandscape) {
    if (_phase == _GachaPhase.cracking || _phase == _GachaPhase.eggDropped) {
      return _buildEggCrackStage();
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // Glass Bubble Dispenser
        Container(
          width: isLandscape ? 220 : 160,
          height: isLandscape ? 220 : 160,
          decoration: BoxDecoration(
            color: const Color(0x66FFFFFF),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: const [
                Text('🥚', style: TextStyle(fontSize: 32)),
                Text('🥚', style: TextStyle(fontSize: 34)),
                Text('🥚', style: TextStyle(fontSize: 30)),
                Text('🥚', style: TextStyle(fontSize: 32)),
                Text('🥚', style: TextStyle(fontSize: 36)),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Crank Handle Column
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.eggsAvailable > 0
                  ? 'Turn Crank to Dispense!'
                  : 'Complete games to earn Eggs!',
              style: GoogleFonts.bubblegumSans(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),

            // Turning crank
            GestureDetector(
              onTap: state.eggsAvailable > 0 ? _onTurnCrank : null,
              child: AnimatedBuilder(
                animation: _crankController,
                builder: (context, _) {
                  return Transform.rotate(
                    angle: _crankController.value * math.pi * 4,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFF6F00)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.refresh_rounded, size: 48, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            if (state.eggsAvailable > 0)
              CandyPillButton(
                width: 140,
                height: 38,
                color: const Color(0xFFFFB300),
                borderColor: Colors.white,
                onPressed: _onTurnCrank,
                child: Text(
                  'TURN CRANK! 🔄',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF3E2723),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildEggCrackStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _crackTaps == 0
              ? 'Tap Egg to Crack It Open! (1/3)'
              : _crackTaps == 1
                  ? 'Tap Again! It\'s Wiggling! (2/3)'
                  : 'ONE MORE TAP! It\'s Hatching! (3/3)',
          style: GoogleFonts.bubblegumSans(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _onTapEgg,
          child: AnimatedBuilder(
            animation: _wobbleController,
            builder: (context, _) {
              final wobble = math.sin(_wobbleController.value * math.pi * 4) * 0.15;
              return Transform.rotate(
                angle: wobble,
                child: Container(
                  width: 120,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        _currentEggColor,
                        _currentEggColor.withOpacity(0.8),
                      ],
                      radius: 0.8,
                    ),
                    borderRadius: const BorderRadius.all(Radius.elliptical(120, 150)),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: _currentEggColor.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_crackTaps >= 1)
                        const Text('⚡️', style: TextStyle(fontSize: 36)),
                      if (_crackTaps >= 2)
                        Positioned(
                          top: 25,
                          child: const Text('💥', style: TextStyle(fontSize: 42)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRevealedToyView() {
    final toy = _hatchedToy;
    if (toy == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, _) {
        final scale = CurvedAnimation(
          parent: _revealController,
          curve: Curves.elasticOut,
        ).value;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: toy.rarity.color, width: 4),
              boxShadow: [
                BoxShadow(
                  color: toy.rarity.color.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Toy 3D Badge
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.white, toy.primaryColor.withOpacity(0.4)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: toy.rarity.color, width: 3),
                  ),
                  child: Center(
                    child: Text(toy.emoji, style: const TextStyle(fontSize: 52)),
                  ),
                ),

                const SizedBox(width: 20),

                // Details
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: toy.rarity.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          toy.rarity.displayName,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        toy.name,
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textNavy,
                        ),
                      ),
                      Text(
                        toy.hindiName,
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        toy.tagline,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
