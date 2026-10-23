import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/widgets/confetti_celebration.dart';

enum DioramaBackdrop {
  royalMeadow(
    nameEn: 'Royal Meadow',
    nameHi: 'शाही घास का मैदान',
    icon: '🏰',
    skyColors: [Color(0xFF81D4FA), Color(0xFFE1F5FE)],
    groundColor: Color(0xFF66BB6A),
    groundHills: Color(0xFF43A047),
  ),
  magicForest(
    nameEn: 'Enchanted Forest',
    nameHi: 'जादुई जंगल',
    icon: '🌲',
    skyColors: [Color(0xFF3F51B5), Color(0xFF7E57C2)],
    groundColor: Color(0xFF2E7D32),
    groundHills: Color(0xFF1B5E20),
  ),
  sunnyBeach(
    nameEn: 'Sunny Beach',
    nameHi: 'धूप वाला समुद्र तट',
    icon: '🏖️',
    skyColors: [Color(0xFF4FC3F7), Color(0xFFFFF9C4)],
    groundColor: Color(0xFFFFD54F),
    groundHills: Color(0xFFFFA000),
  ),
  cosmicGalaxy(
    nameEn: 'Cosmic Galaxy',
    nameHi: 'ब्रह्मांडीय आकाशगंगा',
    icon: '🚀',
    skyColors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
    groundColor: Color(0xFF415A77),
    groundHills: Color(0xFF2E3D4F),
  );

  final String nameEn;
  final String nameHi;
  final String icon;
  final List<Color> skyColors;
  final Color groundColor;
  final Color groundHills;

  const DioramaBackdrop({
    required this.nameEn,
    required this.nameHi,
    required this.icon,
    required this.skyColors,
    required this.groundColor,
    required this.groundHills,
  });

  String localized(String locale) => locale == 'hi' ? nameHi : nameEn;
}

class DioramaItem {
  final String id;
  final String emoji;
  final String nameEn;
  final String nameHi;
  Offset position;
  double scale;
  double rotation;

  DioramaItem({
    required this.id,
    required this.emoji,
    required this.nameEn,
    required this.nameHi,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class StickerOption {
  final String emoji;
  final String nameEn;
  final String nameHi;

  const StickerOption(this.emoji, this.nameEn, this.nameHi);
}

class KingdomWorldBuilderScreen extends ConsumerStatefulWidget {
  const KingdomWorldBuilderScreen({super.key});

  @override
  ConsumerState<KingdomWorldBuilderScreen> createState() =>
      _KingdomWorldBuilderScreenState();
}

class _KingdomWorldBuilderScreenState
    extends ConsumerState<KingdomWorldBuilderScreen> {
  DioramaBackdrop _currentBackdrop = DioramaBackdrop.royalMeadow;
  final List<DioramaItem> _placedItems = [];
  String? _selectedItemId;
  bool _showConfetti = false;

  final Map<String, List<StickerOption>> _stickerCatalog = {
    '👑 Kingdom': const [
      StickerOption('🦁', 'Leo Lion', 'शेर'),
      StickerOption('👑', 'Crown', 'मुकुट'),
      StickerOption('🏰', 'Castle', 'महल'),
      StickerOption('🦄', 'Unicorn', 'यूनिकॉर्न'),
      StickerOption('🐉', 'Dragon', 'ड्रैगन'),
      StickerOption('🧚', 'Fairy', 'परी'),
      StickerOption('🧙', 'Wizard', 'जादूगर'),
    ],
    '🌿 Nature': const [
      StickerOption('🌳', 'Tree', 'पेड़'),
      StickerOption('🌺', 'Flower', 'फूल'),
      StickerOption('🍄', 'Mushroom', 'मशरूम'),
      StickerOption('🌈', 'Rainbow', 'इंद्रधनुष'),
      StickerOption('🌴', 'Palm', 'ताड़'),
      StickerOption('🌻', 'Sunflower', 'सूरजमुखी'),
    ],
    '🐾 Animals': const [
      StickerOption('🐰', 'Bunny', 'खरगोश'),
      StickerOption('🐬', 'Dolphin', 'डॉल्फ़िन'),
      StickerOption('🦉', 'Owl', 'उल्लू'),
      StickerOption('🐙', 'Octopus', 'ऑक्टोपस'),
      StickerOption('🦋', 'Butterfly', 'तितली'),
      StickerOption('🐢', 'Turtle', 'कछुआ'),
    ],
    '🚀 Cosmos': const [
      StickerOption('🚀', 'Rocket', 'रॉकेट'),
      StickerOption('🛸', 'UFO', 'यूएफओ'),
      StickerOption('⭐', 'Star', 'तारा'),
      StickerOption('🌙', 'Moon', 'चाँद'),
      StickerOption('🪐', 'Planet', 'ग्रह'),
      StickerOption('☄️', 'Comet', 'धूमकेतु'),
    ],
  };

  late String _activeCategory;

  @override
  void initState() {
    super.initState();
    _activeCategory = _stickerCatalog.keys.first;

    // Add 3 default starter stickers
    _placedItems.addAll([
      DioramaItem(
        id: 'default_1',
        emoji: '🏰',
        nameEn: 'Castle',
        nameHi: 'महल',
        position: const Offset(120, 150),
        scale: 1.4,
      ),
      DioramaItem(
        id: 'default_2',
        emoji: '🦁',
        nameEn: 'Prince Leo',
        nameHi: 'शेर',
        position: const Offset(230, 220),
        scale: 1.2,
      ),
      DioramaItem(
        id: 'default_3',
        emoji: '🌈',
        nameEn: 'Rainbow',
        nameHi: 'इंद्रधनुष',
        position: const Offset(300, 80),
        scale: 1.1,
      ),
    ]);
  }

  void _addSticker(StickerOption opt) {
    HapticFeedback.lightImpact().catchError((_) {});
    ProceduralSfxEngine().playBubble();

    final size = MediaQuery.of(context).size;
    final item = DioramaItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emoji: opt.emoji,
      nameEn: opt.nameEn,
      nameHi: opt.nameHi,
      position: Offset(
        size.width * 0.4 + (math.Random().nextDouble() * 60 - 30),
        size.height * 0.4 + (math.Random().nextDouble() * 60 - 30),
      ),
      scale: 1.0,
    );

    setState(() {
      _placedItems.add(item);
      _selectedItemId = item.id;
    });
  }

  void _celebrateWorld() {
    HapticFeedback.heavyImpact().catchError((_) {});
    ProceduralSfxEngine().playTrumpet();
    ProceduralSfxEngine().playCheer();
    setState(() {
      _showConfetti = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(currentProfileProvider)?.uiLocale ?? 'en';
    final isHindi = locale == 'hi';

    return Scaffold(
      body: Stack(
        children: [
          // 1. Scenic Diorama Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedItemId = null);
              },
              child: CustomPaint(
                painter: _DioramaBackdropPainter(backdrop: _currentBackdrop),
              ),
            ),
          ),

          // 2. Placed Interactive Diorama Stickers
          ..._placedItems.map((item) {
            final isSelected = item.id == _selectedItemId;

            return Positioned(
              left: item.position.dx,
              top: item.position.dy,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick().catchError((_) {});
                  ProceduralSfxEngine().playBoing();
                  setState(() {
                    _selectedItemId = item.id;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    item.position += details.delta;
                    _selectedItemId = item.id;
                  });
                },
                child: Transform.rotate(
                  angle: item.rotation,
                  child: Transform.scale(
                    scale: item.scale,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFFFFD54F),
                                width: 2.5,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Colors.white.withOpacity(0.25)
                            : Colors.transparent,
                      ),
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // 3. Top Action Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 48,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Back Button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Color(0xFF37474F), size: 26),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // World Title Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_currentBackdrop.icon,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(
                              _currentBackdrop.localized(locale),
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF263238),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Backdrop Switcher Buttons
                      ...DioramaBackdrop.values.map((bd) {
                        final isCurrent = bd == _currentBackdrop;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact().catchError((_) {});
                              ProceduralSfxEngine().playPop();
                              setState(() => _currentBackdrop = bd);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? const Color(0xFFFFB300)
                                    : Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: isCurrent
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(bd.icon,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(width: 8),

                      // Celebrate Snap Button
                      ElevatedButton.icon(
                        onPressed: _celebrateWorld,
                        icon: const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 18),
                        label: Text(
                          isHindi ? 'वाह!' : 'Celebrate!',
                          style: GoogleFonts.bubblegumSans(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Selected Item Controls (Scale, Rotate, Delete)
          if (_selectedItemId != null)
            Positioned(
              top: 76,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_in_rounded,
                          color: Color(0xFF1976D2)),
                      tooltip: 'Grow',
                      onPressed: () {
                        setState(() {
                          final item = _placedItems
                              .firstWhere((it) => it.id == _selectedItemId);
                          item.scale = (item.scale + 0.15).clamp(0.5, 3.0);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out_rounded,
                          color: Color(0xFF1976D2)),
                      tooltip: 'Shrink',
                      onPressed: () {
                        setState(() {
                          final item = _placedItems
                              .firstWhere((it) => it.id == _selectedItemId);
                          item.scale = (item.scale - 0.15).clamp(0.5, 3.0);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.rotate_right_rounded,
                          color: Color(0xFF388E3C)),
                      tooltip: 'Rotate',
                      onPressed: () {
                        setState(() {
                          final item = _placedItems
                              .firstWhere((it) => it.id == _selectedItemId);
                          item.rotation += math.pi / 8;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFD32F2F)),
                      tooltip: 'Delete',
                      onPressed: () {
                        setState(() {
                          _placedItems
                              .removeWhere((it) => it.id == _selectedItemId);
                          _selectedItemId = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

          // 5. Bottom Sticker Picker Drawer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Category Tabs
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _stickerCatalog.keys.map((cat) {
                        final isSelected = cat == _activeCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8, top: 6),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF37474F),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF7C4DFF),
                            backgroundColor: const Color(0xFFEDE7F6),
                            onSelected: (_) {
                              setState(() => _activeCategory = cat);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Stickers Horizontal Strip
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: _stickerCatalog[_activeCategory]!.length,
                      itemBuilder: (context, idx) {
                        final opt = _stickerCatalog[_activeCategory]![idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: InkWell(
                            onTap: () => _addSticker(opt),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFE0E0E0), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  opt.emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Confetti
          if (_showConfetti) const ConfettiCelebration(),
        ],
      ),
    );
  }
}

class _DioramaBackdropPainter extends CustomPainter {
  final DioramaBackdrop backdrop;

  _DioramaBackdropPainter({required this.backdrop});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: backdrop.skyColors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Distant Hills
    final hillPaint = Paint()
      ..color = backdrop.groundHills.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final hillPath = Path();
    hillPath.moveTo(0, size.height * 0.65);
    hillPath.quadraticBezierTo(
        size.width * 0.25, size.height * 0.52, size.width * 0.5, size.height * 0.63);
    hillPath.quadraticBezierTo(
        size.width * 0.78, size.height * 0.50, size.width, size.height * 0.64);
    hillPath.lineTo(size.width, size.height);
    hillPath.lineTo(0, size.height);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);

    // 3. Foreground Rolling Ground
    final groundPaint = Paint()
      ..color = backdrop.groundColor
      ..style = PaintingStyle.fill;

    final groundPath = Path();
    groundPath.moveTo(0, size.height * 0.72);
    groundPath.quadraticBezierTo(
        size.width * 0.4, size.height * 0.64, size.width * 0.8, size.height * 0.75);
    groundPath.quadraticBezierTo(
        size.width * 0.92, size.height * 0.78, size.width, size.height * 0.76);
    groundPath.lineTo(size.width, size.height);
    groundPath.lineTo(0, size.height);
    groundPath.close();
    canvas.drawPath(groundPath, groundPaint);
  }

  @override
  bool shouldRepaint(covariant _DioramaBackdropPainter oldDelegate) =>
      oldDelegate.backdrop != backdrop;
}
