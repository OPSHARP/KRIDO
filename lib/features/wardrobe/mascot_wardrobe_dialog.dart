import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../core/audio/audio_service.dart';
import '../../core/mascot/mascot_wardrobe_service.dart';
import '../../core/widgets/interactive_prince_leo.dart';
import '../../core/widgets/playful_bouncing_effects.dart';

/// Prince Leo's Royal Wardrobe & Dressing Room Modal
class MascotWardrobeDialog extends ConsumerStatefulWidget {
  const MascotWardrobeDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Wardrobe',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim, secondaryAnim) => const MascotWardrobeDialog(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<MascotWardrobeDialog> createState() => _MascotWardrobeDialogState();
}

class _MascotWardrobeDialogState extends ConsumerState<MascotWardrobeDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outfit = ref.watch(mascotWardrobeProvider);
    final audio = ref.read(audioServiceProvider);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 520,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.94,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF8E1), // Soft cream warm gold
                Color(0xFFFFECB3),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFFD54F), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Plaque
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'LEO\'S ROYAL WARDROBE',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.35),
                              offset: const Offset(1, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: () {
                        audio.playCue(SoundCue.press);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              // Scrollable Wardrobe Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Interactive Mirror Stage: Live Prince Leo Preview wearing chosen outfit
                      Container(
                        height: 190,
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment.center,
                    radius: 0.85,
                    colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0288D1).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sparkles background
                    Positioned(
                      top: 12,
                      left: 20,
                      child: Text('✨', style: TextStyle(fontSize: 18, color: Colors.amber.shade300)),
                    ),
                    Positioned(
                      top: 16,
                      right: 24,
                      child: Text('⭐', style: TextStyle(fontSize: 20, color: Colors.amber.shade300)),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 32,
                      child: Text('✨', style: TextStyle(fontSize: 16, color: Colors.amber.shade300)),
                    ),

                    // Prince Leo live model
                    InteractivePrinceLeo(
                      size: 155,
                      showSpeechBubble: false,
                      outfit: outfit,
                      onLeoTapped: () {
                        HapticFeedback.mediumImpact().catchError((_) {});
                        audio.playCue(SoundCue.mascotRoar);
                      },
                    ),
                  ],
                ),
              ),

              // Category Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF6A1B9A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6A1B9A),
                  labelStyle: GoogleFonts.bubblegumSans(fontSize: 15, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: '👑 Crowns'),
                    Tab(text: '💜 Capes'),
                    Tab(text: '🕶️ Glasses'),
                  ],
                ),
              ),

              // Tab Views
              SizedBox(
                height: 180,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. Crowns Tab
                    _buildSelectionGrid<LeoCrown>(
                      items: LeoCrown.values,
                      selected: outfit.crown,
                      titleGetter: (c) => c.displayName,
                      emojiGetter: (c) => c.emoji,
                      onSelect: (c) {
                        HapticFeedback.lightImpact().catchError((_) {});
                        audio.playCue(SoundCue.star);
                        ref.read(mascotWardrobeProvider.notifier).setCrown(c);
                      },
                    ),

                    // 2. Capes Tab
                    _buildSelectionGrid<LeoCape>(
                      items: LeoCape.values,
                      selected: outfit.cape,
                      titleGetter: (c) => c.displayName,
                      emojiGetter: (c) => c.emoji,
                      onSelect: (c) {
                        HapticFeedback.lightImpact().catchError((_) {});
                        audio.playCue(SoundCue.star);
                        ref.read(mascotWardrobeProvider.notifier).setCape(c);
                      },
                    ),

                    // 3. Accessories Tab
                    _buildSelectionGrid<LeoAccessory>(
                      items: LeoAccessory.values,
                      selected: outfit.accessory,
                      titleGetter: (a) => a.displayName,
                      emojiGetter: (a) => a.emoji,
                      onSelect: (a) {
                        HapticFeedback.lightImpact().catchError((_) {});
                        audio.playCue(SoundCue.star);
                        ref.read(mascotWardrobeProvider.notifier).setAccessory(a);
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Confirmation Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact().catchError((_) {});
                      audio.playCue(SoundCue.complete);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'LOOKING MAJESTIC! 👑',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
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
    );
  }

  Widget _buildSelectionGrid<T>({
    required List<T> items,
    required T selected,
    required String Function(T) titleGetter,
    required String Function(T) emojiGetter,
    required ValueChanged<T> onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.88,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;

          return BouncyBounceTap(
            onTap: () => onSelect(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF176) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF8F00) : Colors.grey.shade300,
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFFF8F00).withOpacity(0.3)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emojiGetter(item), style: const TextStyle(fontSize: 34)),
                  const SizedBox(height: 6),
                  Text(
                    titleGetter(item),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? const Color(0xFFE65100) : const Color(0xFF424242),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
