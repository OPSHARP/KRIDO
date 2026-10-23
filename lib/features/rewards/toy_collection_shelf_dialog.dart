import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../app/theme.dart';
import '../../core/widgets/cartoon_ui_components.dart';
import 'gacha_machine_dialog.dart';
import 'toy_collection_service.dart';

/// 3D Wooden Toy Shelf Dialog showcasing collectible Pixar-styled toys.
class ToyCollectionShelfDialog extends ConsumerStatefulWidget {
  const ToyCollectionShelfDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ToyCollectionShelfDialog',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) => const ToyCollectionShelfDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<ToyCollectionShelfDialog> createState() => _ToyCollectionShelfDialogState();
}

class _ToyCollectionShelfDialogState extends ConsumerState<ToyCollectionShelfDialog> {
  ToyItem? _selectedToy;

  void _onToyTapped(ToyItem toy, bool isUnlocked) {
    HapticFeedback.selectionClick().catchError((_) {});
    if (isUnlocked) {
      AudioService().playCue(SoundCue.star);
      setState(() {
        _selectedToy = toy;
      });
    } else {
      AudioService().playCue(SoundCue.snap);
      setState(() {
        _selectedToy = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(toyCollectionProvider);
    final allToys = ToyCollectionNotifier.allToys;
    final unlockedCount = state.unlockedToyIds.length;
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: math.min(isLandscape ? 660.0 : 360.0, screenSize.width * 0.95),
          height: math.min(isLandscape ? 390.0 : 560.0, screenSize.height * 0.94),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8D6E63), // Warm wood tone
                Color(0xFF5D4037),
                Color(0xFF3E2723),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFFD54F), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFFB300), width: 2),
                    ),
                    child: Text(
                      '🏆 $unlockedCount / ${allToys.length} Collected',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Royal Toy Shelf 🧸',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: isLandscape ? 22 : 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black45, offset: Offset(1, 2), blurRadius: 4),
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
                      child: const Icon(Icons.close_rounded, color: Colors.brown, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Wooden Shelves Grid
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0x33000000),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF8D6E63), width: 2),
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLandscape ? 4 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: allToys.length,
                    itemBuilder: (context, index) {
                      final toy = allToys[index];
                      final isUnlocked = state.unlockedToyIds.contains(toy.id);
                      final isSelected = _selectedToy?.id == toy.id;

                      return GestureDetector(
                        onTap: () => _onToyTapped(toy, isUnlocked),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isUnlocked
                                  ? [
                                      Colors.white,
                                      toy.primaryColor.withOpacity(0.35),
                                    ]
                                  : [
                                      Colors.white24,
                                      Colors.black38,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.yellowAccent
                                  : isUnlocked
                                      ? toy.rarity.color
                                      : Colors.white24,
                              width: isSelected ? 3.5 : 2,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.yellowAccent.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isUnlocked ? toy.emoji : '❓',
                                style: TextStyle(
                                  fontSize: isLandscape ? 38 : 32,
                                  color: isUnlocked ? null : Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isUnlocked ? toy.name : 'Surprise Egg',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isUnlocked ? AppTheme.textNavy : Colors.white70,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: toy.rarity.color.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  toy.rarity.name.toUpperCase(),
                                  style: GoogleFonts.nunito(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Selected Toy Tagline Display
              if (_selectedToy != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedToy!.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_selectedToy!.name} — ${_selectedToy!.tagline}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CandyPillButton(
                    width: 170,
                    height: 40,
                    color: const Color(0xFFFF5252),
                    borderColor: Colors.white,
                    onPressed: () {
                      ProceduralSfxEngine().playPop();
                      Navigator.of(context).pop();
                      GachaMachineDialog.show(context);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🥚', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            'Gacha Machine',
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
