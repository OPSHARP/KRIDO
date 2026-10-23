import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models/sticker.dart';
import 'sticker_canvas_screen.dart';

class StickerBookScreen extends ConsumerWidget {
  const StickerBookScreen({super.key});

  static const List<Sticker> availableStickers = [
    Sticker(id: 'stk_star', nameEn: 'Golden Star', nameHi: 'सुनहरा तारा', emoji: '⭐', category: 'achievement'),
    Sticker(id: 'stk_apple', nameEn: 'Sweet Apple', nameHi: 'मीठा सेब', emoji: '🍎', category: 'nature'),
    Sticker(id: 'stk_book', nameEn: 'Story Book', nameHi: 'कहानी की किताब', emoji: '📚', category: 'learning'),
    Sticker(id: 'stk_pencil', nameEn: 'Magic Pencil', nameHi: 'जादूई पेंसिल', emoji: '✏️', category: 'creative'),
    Sticker(id: 'stk_palette', nameEn: 'Color Palette', nameHi: 'रंग पैलेट', emoji: '🎨', category: 'creative'),
    Sticker(id: 'stk_brain', nameEn: 'Memory Spark', nameHi: 'स्मृति चमक', emoji: '🧠', category: 'achievement'),
    Sticker(id: 'stk_lion', nameEn: 'Playful Lion', nameHi: 'नटखट शेर', emoji: '🦁', category: 'animals'),
    Sticker(id: 'stk_rocket', nameEn: 'Space Rocket', nameHi: 'अंतरिक्ष रॉकेट', emoji: '🚀', category: 'space'),
    Sticker(id: 'stk_rainbow', nameEn: 'Sunny Rainbow', nameHi: 'इंद्रधनुष', emoji: '🌈', category: 'nature'),
    Sticker(id: 'stk_butterfly', nameEn: 'Blue Butterfly', nameHi: 'तितली', emoji: '🦋', category: 'nature'),
    Sticker(id: 'stk_trophy', nameEn: 'King Crown', nameHi: 'राजा का मुकुट', emoji: '👑', category: 'achievement'),
    Sticker(id: 'stk_balloon', nameEn: 'Party Balloon', nameHi: 'गुब्बारा', emoji: '🎈', category: 'fun'),
    Sticker(id: 'stk_bed', nameEn: 'Cozy Bed', nameHi: 'आरामदायक बिस्तर', emoji: '🛏️', category: 'room'),
    Sticker(id: 'stk_lamp', nameEn: 'Night Lamp', nameHi: 'रात का लैंप', emoji: '💡', category: 'room'),
    Sticker(id: 'stk_teddy', nameEn: 'Teddy Bear', nameHi: 'टेडी बियर', emoji: '🧸', category: 'room'),
    Sticker(id: 'stk_clock', nameEn: 'Alarm Clock', nameHi: 'घड़ी', emoji: '⏰', category: 'room'),
    Sticker(id: 'stk_plant', nameEn: 'Green Plant', nameHi: 'पौधा', emoji: '🪴', category: 'room'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final db = ref.watch(databaseProvider);
    final isHindi = profile?.uiLocale == 'hi';

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.purple, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isHindi ? 'मेरी स्टिकर डायरी' : 'My Sticker Book',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.textNavy,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: profile != null
            ? db.getUnlockedStickerIds(profile.id)
            : Future.value([]),
        builder: (context, snapshot) {
          final unlockedIds = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      Text(
                        isHindi
                            ? 'संग्रह: ${unlockedIds.length} / ${availableStickers.length} स्टिकर'
                            : 'Collected: ${unlockedIds.length} / ${availableStickers.length} Stickers',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Creative Canvas Launch Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StickerCanvasScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9F1A), Color(0xFFFF5252)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎨', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'क्रिएटिव कैनवस खोलें' : 'Open Creative Canvas',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Decorate Leo's Bedroom Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StickerCanvasScreen(
                          initialTheme: CanvasTheme.bedroom,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFAB47BC), Color(0xFF7E57C2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🧸', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'लियो का कमरा सजाएं' : 'Decorate Leo\'s Bedroom',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Stickers Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: availableStickers.length,
                    itemBuilder: (context, index) {
                      final sticker = availableStickers[index];
                      final isUnlocked = unlockedIds.contains(sticker.id);

                      return Container(
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? AppTheme.cardWhite
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isUnlocked
                                ? AppTheme.sunGold
                                : Colors.grey.shade300,
                            width: isUnlocked ? 2.5 : 1.5,
                          ),
                          boxShadow: isUnlocked
                              ? [
                                  BoxShadow(
                                    color: AppTheme.sunGold.withOpacity(0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isUnlocked ? sticker.emoji : '🔒',
                              style: TextStyle(
                                fontSize: isUnlocked ? 46 : 32,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isUnlocked
                                  ? sticker.localizedName(profile?.uiLocale ?? 'en')
                                  : '???',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked
                                    ? AppTheme.textNavy
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
