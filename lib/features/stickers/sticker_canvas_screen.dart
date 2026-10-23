import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/providers.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/cartoon_ui_components.dart';
import '../../core/widgets/confetti_celebration.dart';
import '../../domain/models/sticker.dart';

enum CanvasTheme {
  jungle('🌴 Jungle', 'जंगल', [Color(0xFF2ED573), Color(0xFF1B8A44)], '🌿'),
  castle('🏰 Castle', 'महल', [Color(0xFF8B68DE), Color(0xFF4834D4)], '✨'),
  galaxy('🚀 Galaxy', 'अंतरिक्ष', [Color(0xFF1E272E), Color(0xFF0C2461)], '⭐'),
  ocean('🌊 Ocean', 'सागर', [Color(0xFF00D2D3), Color(0xFF01A3A4)], '🐠'),
  candy('🍭 Candy Land', 'कैंडी लैंड', [Color(0xFFFF80AB), Color(0xFFFF4081)], '🍬'),
  bedroom('🧸 Leo\'s Bedroom', 'लियो का कमरा', [Color(0xFFFFF3E0), Color(0xFFFFCC80)], '🛏️'),
  white('📄 Sketchpad', 'सफेद पन्ना', [Color(0xFFFBFBFB), Color(0xFFEEEEEE)], '🎨');

  final String titleEn;
  final String titleHi;
  final List<Color> gradientColors;
  final String ambientEmoji;

  const CanvasTheme(this.titleEn, this.titleHi, this.gradientColors, this.ambientEmoji);

  String localizedTitle(String locale) => locale == 'hi' ? titleHi : titleEn;
}

enum BrushType {
  normal('🖍️ Color', 'रंग', Color(0xFFFF5722)),
  rainbow('🌈 Rainbow', 'इंद्रधनुष', Color(0xFF7E57C2)),
  glitter('✨ Glitter', 'चमक', Color(0xFFFFD700)),
  neon('🌟 Neon', 'नियॉन', Color(0xFF00E5FF)),
  eraser('🧽 Eraser', 'रबर', Color(0xFF9E9E9E));

  final String labelEn;
  final String labelHi;
  final Color accentColor;
  const BrushType(this.labelEn, this.labelHi, this.accentColor);

  String localized(String locale) => locale == 'hi' ? labelHi : labelEn;
}

enum CanvasStencil {
  blank('Blank', 'खाली', '🎨'),
  lion('Leo Lion', 'बब्बर शेर', '🦁'),
  puppy('Puppy Dog', 'पिल्ला', '🐶'),
  rocket('Space Rocket', 'रॉकेट', '🚀'),
  cake('Birthday Cake', 'केक', '🎂'),
  castle('Royal Castle', 'महल', '🏰'),
  star('Super Star', 'तारा', '⭐');

  final String titleEn;
  final String titleHi;
  final String emoji;
  const CanvasStencil(this.titleEn, this.titleHi, this.emoji);

  String localizedTitle(String locale) => locale == 'hi' ? titleHi : titleEn;
}

enum StampCategory {
  numbers1to20('0-20', '0-20', '🔢'),
  tensAnd100('Tens & 100', 'दहाई और 100', '🔟'),
  math('Math & Symbols', 'गणित व चिह्न', '➕'),
  animals('Animals', 'जानवर', '🦁'),
  toys('Toys & Treats', 'खिलौने व मिठाई', '🚀');

  final String titleEn;
  final String titleHi;
  final String icon;
  const StampCategory(this.titleEn, this.titleHi, this.icon);

  String localizedTitle(String locale) => locale == 'hi' ? titleHi : titleEn;
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final BrushType brushType;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.brushType = BrushType.normal,
  });
}

class PlacedSticker {
  final String id;
  final Sticker sticker;
  double x;
  double y;
  double scale;
  double rotation;
  Color? customColor;

  PlacedSticker({
    required this.id,
    required this.sticker,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.customColor,
  });
}

class StickerCanvasScreen extends ConsumerStatefulWidget {
  final CanvasTheme initialTheme;
  const StickerCanvasScreen({super.key, this.initialTheme = CanvasTheme.jungle});

  @override
  ConsumerState<StickerCanvasScreen> createState() => _StickerCanvasScreenState();
}

class _StickerCanvasScreenState extends ConsumerState<StickerCanvasScreen> {
  late CanvasTheme _selectedTheme;
  CanvasStencil _selectedStencil = CanvasStencil.blank;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.initialTheme;
  }
  final List<DrawingStroke> _strokes = [];
  final List<PlacedSticker> _placedStickers = [];
  bool _showCelebration = false;
  PlacedSticker? _selectedSticker;

  // Active Drawing Tool State
  bool _isDrawingMode = true; // true = Paint Brush, false = Stickers & Numbers
  BrushType _activeBrush = BrushType.normal;
  Color _selectedColor = const Color(0xFFFF1744); // Radiant red default
  double _brushWidth = 7.0;
  StampCategory _selectedStampCategory = StampCategory.numbers1to20;

  final List<Color> _paletteColors = [
    const Color(0xFFFF1744), // Ruby Red
    const Color(0xFFFF9100), // Tangerine Orange
    const Color(0xFFFFEA00), // Sunshine Yellow
    const Color(0xFF76FF03), // Lime Green
    const Color(0xFF00E676), // Emerald Green
    const Color(0xFF00E5FF), // Aqua Blue
    const Color(0xFF2979FF), // Royal Blue
    const Color(0xFFD500F9), // Purple
    const Color(0xFFFF4081), // Bubblegum Pink
    const Color(0xFF795548), // Warm Brown
    Colors.white,            // Pure White
    Colors.black87,          // Ink Black
  ];

  final List<Color> _candyStickerColors = [
    const Color(0xFFFF5722),
    const Color(0xFF29B6F6),
    const Color(0xFF66BB6A),
    const Color(0xFFAB47BC),
    const Color(0xFFFFB300),
    const Color(0xFFFF4081),
    const Color(0xFF26A69A),
    const Color(0xFF42A5F5),
  ];

  // 1. Numbers 0 to 20
  final List<Sticker> _numbers0to20 = List.generate(21, (index) {
    return Sticker(
      id: 'num_$index',
      nameEn: '$index',
      nameHi: '$index',
      emoji: '$index',
      category: 'numbers',
    );
  });

  // 2. Tens & Hundreds (10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 500, 1000)
  final List<Sticker> _tensAndHundreds = [
    const Sticker(id: 'num_10_t', nameEn: '10', nameHi: '10', emoji: '10', category: 'numbers'),
    const Sticker(id: 'num_20_t', nameEn: '20', nameHi: '20', emoji: '20', category: 'numbers'),
    const Sticker(id: 'num_30', nameEn: '30', nameHi: '30', emoji: '30', category: 'numbers'),
    const Sticker(id: 'num_40', nameEn: '40', nameHi: '40', emoji: '40', category: 'numbers'),
    const Sticker(id: 'num_50_t', nameEn: '50', nameHi: '50', emoji: '50', category: 'numbers'),
    const Sticker(id: 'num_60', nameEn: '60', nameHi: '60', emoji: '60', category: 'numbers'),
    const Sticker(id: 'num_70', nameEn: '70', nameHi: '70', emoji: '70', category: 'numbers'),
    const Sticker(id: 'num_80', nameEn: '80', nameHi: '80', emoji: '80', category: 'numbers'),
    const Sticker(id: 'num_90', nameEn: '90', nameHi: '90', emoji: '90', category: 'numbers'),
    const Sticker(id: 'num_100_t', nameEn: '100', nameHi: '100', emoji: '100', category: 'numbers'),
    const Sticker(id: 'num_200', nameEn: '200', nameHi: '200', emoji: '200', category: 'numbers'),
    const Sticker(id: 'num_500', nameEn: '500', nameHi: '500', emoji: '500', category: 'numbers'),
    const Sticker(id: 'num_1000', nameEn: '1000', nameHi: '1000', emoji: '1000', category: 'numbers'),
  ];

  // 3. Math & Logic Symbols
  final List<Sticker> _mathSymbols = [
    const Sticker(id: 'sym_plus', nameEn: 'Plus', nameHi: 'जोड़', emoji: '➕', category: 'math'),
    const Sticker(id: 'sym_minus', nameEn: 'Minus', nameHi: 'घटाव', emoji: '➖', category: 'math'),
    const Sticker(id: 'sym_mult', nameEn: 'Multiply', nameHi: 'गुणा', emoji: '✖️', category: 'math'),
    const Sticker(id: 'sym_div', nameEn: 'Divide', nameHi: 'भाग', emoji: '➗', category: 'math'),
    const Sticker(id: 'sym_equal', nameEn: 'Equal', nameHi: 'बराबर', emoji: '🟰', category: 'math'),
    const Sticker(id: 'sym_greater', nameEn: 'Greater', nameHi: 'बड़ा', emoji: '>', category: 'math'),
    const Sticker(id: 'sym_less', nameEn: 'Less', nameHi: 'छोटा', emoji: '<', category: 'math'),
    const Sticker(id: 'sym_qmark', nameEn: 'Question', nameHi: 'सवाल', emoji: '❓', category: 'math'),
    const Sticker(id: 'sym_excl', nameEn: 'Exclamation', nameHi: 'विस्मय', emoji: '❗', category: 'math'),
    const Sticker(id: 'sym_100', nameEn: '100 Points', nameHi: 'सौ अंक', emoji: '💯', category: 'math'),
    const Sticker(id: 'sym_dice', nameEn: 'Dice', nameHi: 'पासा', emoji: '🎲', category: 'math'),
    const Sticker(id: 'sym_coin', nameEn: 'Coin', nameHi: 'सिक्का', emoji: '🪙', category: 'math'),
    const Sticker(id: 'sym_abacus', nameEn: 'Abacus', nameHi: 'गिनतारा', emoji: '🧮', category: 'math'),
    const Sticker(id: 'sym_star', nameEn: 'Star Bonus', nameHi: 'तारा', emoji: '⭐', category: 'math'),
  ];

  // 4. Animals
  final List<Sticker> _animalStickers = [
    const Sticker(id: 'ani_lion', nameEn: 'Leo the Lion', nameHi: 'शेर लियो', emoji: '🦁', category: 'animals'),
    const Sticker(id: 'ani_dog', nameEn: 'Puppy Dog', nameHi: 'कुत्ता', emoji: '🐶', category: 'animals'),
    const Sticker(id: 'ani_cat', nameEn: 'Kitten', nameHi: 'बिल्ली', emoji: '🐱', category: 'animals'),
    const Sticker(id: 'ani_bunny', nameEn: 'Bunny', nameHi: 'खरगोश', emoji: '🐰', category: 'animals'),
    const Sticker(id: 'ani_panda', nameEn: 'Panda', nameHi: 'पांडा', emoji: '🐼', category: 'animals'),
    const Sticker(id: 'ani_fox', nameEn: 'Fox', nameHi: 'लोमड़ी', emoji: '🦊', category: 'animals'),
    const Sticker(id: 'ani_bear', nameEn: 'Teddy Bear', nameHi: 'भालू', emoji: '🐻', category: 'animals'),
    const Sticker(id: 'ani_frog', nameEn: 'Froggy', nameHi: 'मेंढक', emoji: '🐸', category: 'animals'),
    const Sticker(id: 'ani_dino', nameEn: 'Dino', nameHi: 'डायनासोर', emoji: '🦖', category: 'animals'),
    const Sticker(id: 'ani_unicorn', nameEn: 'Unicorn', nameHi: 'यूनिकॉर्न', emoji: '🦄', category: 'animals'),
    const Sticker(id: 'ani_butterfly', nameEn: 'Butterfly', nameHi: 'तितली', emoji: '🦋', category: 'animals'),
    const Sticker(id: 'ani_chick', nameEn: 'Baby Chick', nameHi: 'चूजा', emoji: '🐥', category: 'animals'),
    const Sticker(id: 'ani_dolphin', nameEn: 'Dolphin', nameHi: 'डॉल्फ़िन', emoji: '🐬', category: 'animals'),
    const Sticker(id: 'ani_penguin', nameEn: 'Penguin', nameHi: 'पेंगुइन', emoji: '🐧', category: 'animals'),
    const Sticker(id: 'ani_monkey', nameEn: 'Monkey', nameHi: 'बंदर', emoji: '🐵', category: 'animals'),
  ];

  // 5. Toys, Treats & Fantasy
  final List<Sticker> _toyStickers = [
    const Sticker(id: 'toy_apple', nameEn: 'Red Apple', nameHi: 'सेब', emoji: '🍎', category: 'toys'),
    const Sticker(id: 'toy_strawberry', nameEn: 'Strawberry', nameHi: 'स्ट्रॉबेरी', emoji: '🍓', category: 'toys'),
    const Sticker(id: 'toy_icecream', nameEn: 'Ice Cream', nameHi: 'आइसक्रीम', emoji: '🍦', category: 'toys'),
    const Sticker(id: 'toy_lollipop', nameEn: 'Lollipop', nameHi: 'लॉलीपॉप', emoji: '🍭', category: 'toys'),
    const Sticker(id: 'toy_crown', nameEn: 'Royal Crown', nameHi: 'मुकुट', emoji: '👑', category: 'toys'),
    const Sticker(id: 'toy_rocket', nameEn: 'Rocket', nameHi: 'रॉकेट', emoji: '🚀', category: 'toys'),
    const Sticker(id: 'toy_rainbow', nameEn: 'Rainbow', nameHi: 'इंद्रधनुष', emoji: '🌈', category: 'toys'),
    const Sticker(id: 'toy_balloon', nameEn: 'Balloon', nameHi: 'गुब्बारा', emoji: '🎈', category: 'toys'),
    const Sticker(id: 'toy_car', nameEn: 'Race Car', nameHi: 'कार', emoji: '🚗', category: 'toys'),
    const Sticker(id: 'toy_train', nameEn: 'Toy Train', nameHi: 'रेलगाड़ी', emoji: '🚂', category: 'toys'),
    const Sticker(id: 'toy_soccer', nameEn: 'Soccer Ball', nameHi: 'फुटबॉल', emoji: '⚽', category: 'toys'),
    const Sticker(id: 'toy_wand', nameEn: 'Magic Wand', nameHi: 'जादुई छड़ी', emoji: '🪄', category: 'toys'),
    const Sticker(id: 'toy_cake', nameEn: 'Birthday Cake', nameHi: 'केक', emoji: '🎂', category: 'toys'),
    const Sticker(id: 'toy_gift', nameEn: 'Gift Box', nameHi: 'उपहार', emoji: '🎁', category: 'toys'),
    const Sticker(id: 'toy_gem', nameEn: 'Sparkle Gem', nameHi: 'रत्न', emoji: '💎', category: 'toys'),
    const Sticker(id: 'toy_flower', nameEn: 'Flower', nameHi: 'फूल', emoji: '🌺', category: 'toys'),
  ];

  void _addSticker(Sticker sticker) {
    HapticFeedback.lightImpact();
    ref.read(audioServiceProvider).playCue(SoundCue.snap);

    setState(() {
      final newPlaced = PlacedSticker(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sticker: sticker,
        x: 0.5 + (Random().nextDouble() - 0.5) * 0.25,
        y: 0.45 + (Random().nextDouble() - 0.5) * 0.25,
      );
      _placedStickers.add(newPlaced);
      _selectedSticker = newPlaced;
    });
  }

  void _undo() {
    HapticFeedback.selectionClick();
    ref.read(audioServiceProvider).playCue(SoundCue.press);
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.removeLast();
      } else if (_placedStickers.isNotEmpty) {
        _placedStickers.removeLast();
        _selectedSticker = _placedStickers.isNotEmpty ? _placedStickers.last : null;
      }
    });
  }

  void _clearCanvas() {
    HapticFeedback.mediumImpact();
    ref.read(audioServiceProvider).playCue(SoundCue.drop);
    setState(() {
      _strokes.clear();
      _placedStickers.clear();
      _selectedSticker = null;
    });
  }

  void _saveArtwork() {
    HapticFeedback.heavyImpact();
    ref.read(audioServiceProvider).playCue(SoundCue.complete);
    setState(() {
      _showCelebration = true;
    });

    final isHindi = ref.read(currentProfileProvider)?.uiLocale == 'hi';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: const Color(0xFFFFF9EE),
        title: Text(
          isHindi ? 'कलाकृति सहेजी गई! 🎨' : 'Masterpiece Saved! 🎨',
          textAlign: TextAlign.center,
          style: GoogleFonts.bubblegumSans(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A3418),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑 🎨 🌟 💯', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 12),
            Text(
              isHindi
                  ? 'आपकी सुंदर ड्राइंग, नंबर और स्टैम्प शाही आर्ट गैलरी में सहेज लिए गए हैं!'
                  : 'Your royal painting, numbers, and stencils are saved to your gallery!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Center(
            child: CandyPillButton(
              width: 140,
              height: 42,
              color: const Color(0xFF81C784),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _showCelebration = false;
                });
              },
              child: Text(
                isHindi ? 'शानदार!' : 'HOORAY!',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final locale = profile?.uiLocale ?? 'en';
    final isHindi = locale == 'hi';

    final hasContent = _strokes.isNotEmpty || _placedStickers.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF1E272E),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // 1. Top Modern Studio Header
                _buildStudioHeader(isHindi, hasContent),

                // 2. Interactive Ribbon (Modes, Themes, Stencils)
                _buildStudioRibbon(locale),

                // 3. Main Drawing & Sticker Canvas Viewport
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: WoodenTabletFrame(
                      borderWidth: 8,
                      cornerRadius: 20,
                      trayColor: const Color(0xFFD7CCC8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return _buildCanvasViewport(constraints, locale);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Bottom Creative Studio Toolbox (Draw colors / Numbers / Stamps)
                _buildCreativeToolbox(locale),
              ],
            ),
          ),

          // Confetti celebration overlay
          if (_showCelebration)
            const Positioned.fill(
              child: IgnorePointer(
                child: ConfettiCelebration(),
              ),
            ),
        ],
      ),
    );
  }

  /// Top Studio App Bar: Exit, Title, Undo, Clear, Save (Compact & Overflow-proof)
  Widget _buildStudioHeader(bool isHindi, bool hasContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFFFFF9EE),
      child: Row(
        children: [
          // Back Button
          CandyPillButton(
            width: 36,
            height: 36,
            borderRadius: 18,
            color: const Color(0xFF29B6F6),
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),

          // Studio Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isHindi ? 'क्रिएटिव स्टूडियो PRO' : 'CREATIVE STUDIO PRO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4A3418),
                  ),
                ),
                Text(
                  isHindi ? 'रंग, जादू, 0-100 नंबर और स्टैम्प्स' : 'Magic Paint, 0-100 Numbers & Stamps',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),

          // Undo Button
          IconButton(
            icon: const Icon(Icons.undo_rounded, color: Color(0xFF5D4037), size: 22),
            tooltip: 'Undo',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: hasContent ? _undo : null,
          ),

          // Clear Button
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFFF5252), size: 22),
            tooltip: 'Clear',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: hasContent ? _clearCanvas : null,
          ),

          const SizedBox(width: 4),

          // Save Artwork Button
          CandyPillButton(
            width: 72,
            height: 34,
            color: const Color(0xFF66BB6A),
            onPressed: hasContent ? _saveArtwork : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 15),
                const SizedBox(width: 3),
                Text(
                  isHindi ? 'सहेजें' : 'SAVE',
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Ribbon: DRAW vs 123 STAMPS, Themes & Stencils
  Widget _buildStudioRibbon(String locale) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 3),
      color: const Color(0xFFFFF9EE),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // Mode Switcher: 🖌️ DRAW vs 123 STAMPS
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isDrawingMode = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isDrawingMode ? const Color(0xFFFF7043) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🖌️', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 3),
                        Text(
                          'DRAW',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: _isDrawingMode ? Colors.white : const Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isDrawingMode = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: !_isDrawingMode ? const Color(0xFF7E57C2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('123', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 3),
                        Text(
                          'STAMPS',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: !_isDrawingMode ? Colors.white : const Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          const VerticalDivider(width: 1, thickness: 1, indent: 4, endIndent: 4, color: Color(0xFFD7CCC8)),
          const SizedBox(width: 8),

          // Stencil Picker Dropdown / Pill
          _buildStencilDropdown(locale),

          const SizedBox(width: 8),
          const VerticalDivider(width: 1, thickness: 1, indent: 4, endIndent: 4, color: Color(0xFFD7CCC8)),
          const SizedBox(width: 8),

          // Themes Chips
          ...CanvasTheme.values.map((theme) {
            final isSelected = _selectedTheme == theme;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ChoiceChip(
                label: Text(
                  theme.localizedTitle(locale),
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : const Color(0xFF5D4037),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF7E57C2),
                backgroundColor: const Color(0xFFEFEBE9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (selected) {
                  if (selected) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTheme = theme);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Stencil Selector Button
  Widget _buildStencilDropdown(String locale) {
    return GestureDetector(
      onTap: () => _showStencilPicker(context, locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _selectedStencil != CanvasStencil.blank
              ? const Color(0xFFFFB300)
              : const Color(0xFFEFEBE9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedStencil.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              _selectedStencil == CanvasStencil.blank
                  ? (locale == 'hi' ? 'आउटलाइन' : 'STENCIL')
                  : _selectedStencil.localizedTitle(locale),
              style: GoogleFonts.bubblegumSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: _selectedStencil != CanvasStencil.blank ? Colors.white : const Color(0xFF5D4037),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.palette_rounded,
              size: 15,
              color: _selectedStencil != CanvasStencil.blank ? Colors.white : const Color(0xFF5D4037),
            ),
          ],
        ),
      ),
    );
  }

  void _showStencilPicker(BuildContext context, String locale) {
    HapticFeedback.selectionClick();
    ref.read(audioServiceProvider).playCue(SoundCue.press);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF9EE),
        title: Text(
          locale == 'hi' ? 'कलरिंग आउटलाइन चुनें 🎨' : 'Choose Coloring Stencil 🎨',
          textAlign: TextAlign.center,
          style: GoogleFonts.bubblegumSans(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A3418),
          ),
        ),
        content: SizedBox(
          width: 320,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: CanvasStencil.values.map((stencil) {
              final isSelected = _selectedStencil == stencil;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(audioServiceProvider).playCue(SoundCue.snap);
                  setState(() => _selectedStencil = stencil);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFB300) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.white : const Color(0xFFD7CCC8),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(stencil.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text(
                        stencil.localizedTitle(locale),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : const Color(0xFF4A3418),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Main Interactive Canvas Viewport
  Widget _buildCanvasViewport(BoxConstraints constraints, String locale) {
    final canvasWidth = constraints.maxWidth;
    final canvasHeight = constraints.maxHeight;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Tap on empty space deselects sticker
        if (_selectedSticker != null) {
          setState(() => _selectedSticker = null);
        }
      },
      onPanStart: _isDrawingMode
          ? (details) {
              final localPoint = details.localPosition;
              setState(() {
                _strokes.add(
                  DrawingStroke(
                    points: [localPoint],
                    color: _selectedColor,
                    strokeWidth: _brushWidth,
                    brushType: _activeBrush,
                  ),
                );
              });
            }
          : null,
      onPanUpdate: _isDrawingMode
          ? (details) {
              if (_strokes.isEmpty) return;
              setState(() {
                _strokes.last.points.add(details.localPosition);
              });
            }
          : null,
      child: Container(
        width: canvasWidth,
        height: canvasHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _selectedTheme.gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Ambient theme emojis
            Positioned(
              top: 16,
              left: 20,
              child: Opacity(
                opacity: 0.28,
                child: Text(_selectedTheme.ambientEmoji, style: const TextStyle(fontSize: 60)),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 24,
              child: Opacity(
                opacity: 0.25,
                child: Text(_selectedTheme.ambientEmoji, style: const TextStyle(fontSize: 64)),
              ),
            ),

            // Stencil Background Guide (if enabled)
            if (_selectedStencil != CanvasStencil.blank)
              Positioned.fill(
                child: CustomPaint(
                  painter: StencilGuidePainter(stencil: _selectedStencil),
                ),
              ),

            // Freehand Painted Strokes Layer
            CustomPaint(
              size: Size(canvasWidth, canvasHeight),
              painter: StudioCanvasPainter(
                strokes: _strokes,
                backgroundColor: _selectedTheme.gradientColors.first,
              ),
            ),

            // Placed Stickers & Numbers Layer (Draggable & Selectable)
            ..._placedStickers.map((placed) {
              final isSelected = _selectedSticker == placed;
              final isNumber = placed.sticker.category == 'numbers' || placed.sticker.category == 'math';

              final posX = (placed.x * canvasWidth) - 30;
              final posY = (placed.y * canvasHeight) - 30;

              return Positioned(
                left: posX,
                top: posY,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(audioServiceProvider).playCue(SoundCue.press);
                    setState(() => _selectedSticker = placed);
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      placed.x += details.delta.dx / canvasWidth;
                      placed.y += details.delta.dy / canvasHeight;
                      placed.x = placed.x.clamp(0.05, 0.95);
                      placed.y = placed.y.clamp(0.05, 0.95);
                    });
                  },
                  child: Transform.rotate(
                    angle: placed.rotation,
                    child: Container(
                      decoration: isSelected
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.85),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            )
                          : null,
                      padding: const EdgeInsets.all(4),
                      child: isNumber
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: placed.customColor != null
                                      ? [placed.customColor!.withOpacity(0.85), placed.customColor!]
                                      : const [Color(0xFFFF9E80), Color(0xFFFF5722)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: const Offset(0, 3),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Text(
                                placed.sticker.emoji,
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 34 * placed.scale,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.4),
                                      offset: const Offset(1, 2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Text(
                              placed.sticker.emoji,
                              style: TextStyle(fontSize: 44 * placed.scale),
                            ),
                    ),
                  ),
                ),
              );
            }),

            // Floating Sticker Action Bubble (When sticker is selected)
            if (_selectedSticker != null)
              _buildFloatingStickerToolbar(canvasWidth, canvasHeight),
          ],
        ),
      ),
    );
  }

  /// Floating control toolbar for scaling, rotating, recoloring, or deleting selected sticker
  Widget _buildFloatingStickerToolbar(double canvasWidth, double canvasHeight) {
    final placed = _selectedSticker!;
    // Clamp toolbar position nicely inside canvas
    final toolbarLeft = ((placed.x * canvasWidth) - 100).clamp(10.0, max(10.0, canvasWidth - 210.0)).toDouble();
    final toolbarTop = ((placed.y * canvasHeight) - 75).clamp(10.0, max(10.0, canvasHeight - 65.0)).toDouble();

    final isNumber = placed.sticker.category == 'numbers' || placed.sticker.category == 'math';

    return Positioned(
      left: toolbarLeft,
      top: toolbarTop,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3436).withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ➕ Enlarge
            _buildToolbarIcon(
              icon: Icons.zoom_in_rounded,
              color: const Color(0xFF69F0AE),
              tooltip: 'Enlarge',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  placed.scale = (placed.scale + 0.2).clamp(0.6, 2.5);
                });
              },
            ),

            // ➖ Shrink
            _buildToolbarIcon(
              icon: Icons.zoom_out_rounded,
              color: const Color(0xFFFFD54F),
              tooltip: 'Shrink',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  placed.scale = (placed.scale - 0.2).clamp(0.6, 2.5);
                });
              },
            ),

            // 🔄 Rotate 45°
            _buildToolbarIcon(
              icon: Icons.rotate_right_rounded,
              color: const Color(0xFF40C4FF),
              tooltip: 'Rotate 45°',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  placed.rotation += pi / 4;
                });
              },
            ),

            // 🎨 Recolor (if number)
            if (isNumber)
              _buildToolbarIcon(
                icon: Icons.color_lens_rounded,
                color: const Color(0xFFFF4081),
                tooltip: 'Cycle Color',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    final currIndex = placed.customColor != null
                        ? _candyStickerColors.indexOf(placed.customColor!)
                        : 0;
                    final nextIndex = (currIndex + 1) % _candyStickerColors.length;
                    placed.customColor = _candyStickerColors[nextIndex];
                  });
                },
              ),

            // 🗑️ Delete
            _buildToolbarIcon(
              icon: Icons.delete_rounded,
              color: const Color(0xFFFF5252),
              tooltip: 'Delete',
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(audioServiceProvider).playCue(SoundCue.drop);
                setState(() {
                  _placedStickers.remove(placed);
                  _selectedSticker = null;
                });
              },
            ),

            // ❌ Deselect
            _buildToolbarIcon(
              icon: Icons.close_rounded,
              color: Colors.white70,
              tooltip: 'Done',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedSticker = null);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  /// Bottom Creative Studio Toolbox
  Widget _buildCreativeToolbox(String locale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFFFFF9EE),
      child: _isDrawingMode
          ? _buildDrawingPalette(locale)
          : _buildStickersAndNumbersTray(locale),
    );
  }

  /// Color palette, Rainbow, Glitter, Neon, Eraser brushes and stroke widths
  Widget _buildDrawingPalette(String locale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Brush Types Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: BrushType.values.map((brush) {
              final isSelected = _activeBrush == brush;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(audioServiceProvider).playCue(SoundCue.press);
                  setState(() => _activeBrush = brush);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? brush.accentColor : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? Colors.white : const Color(0xFFD7CCC8),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: brush.accentColor.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    brush.localized(locale),
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : const Color(0xFF5D4037),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 6),

        // 2. Palette Colors (shown when not in Eraser/Rainbow mode)
        if (_activeBrush != BrushType.rainbow && _activeBrush != BrushType.eraser)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _paletteColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white70,
                        width: isSelected ? 3.5 : 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.65),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 4),

        // 3. Brush Thickness Pill Selectors
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSizePill('Fine', 3.0, '✏️'),
            const SizedBox(width: 8),
            _buildSizePill('Medium', 7.0, '🖌️'),
            const SizedBox(width: 8),
            _buildSizePill('Chunky', 14.0, '🖍️'),
            const SizedBox(width: 8),
            _buildSizePill('Jumbo', 22.0, '🎨'),
          ],
        ),
      ],
    );
  }

  Widget _buildSizePill(String label, double width, String icon) {
    final isSelected = _brushWidth == width;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _brushWidth = width);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A3418) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.bubblegumSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFF4A3418),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stickers and Numbers Tray: Categorized into 0-20, Tens & 100, Math, Animals, Toys
  Widget _buildStickersAndNumbersTray(String locale) {
    // Determine active stamp list based on chosen category
    List<Sticker> activeStickers;
    switch (_selectedStampCategory) {
      case StampCategory.numbers1to20:
        activeStickers = _numbers0to20;
        break;
      case StampCategory.tensAnd100:
        activeStickers = _tensAndHundreds;
        break;
      case StampCategory.math:
        activeStickers = _mathSymbols;
        break;
      case StampCategory.animals:
        activeStickers = _animalStickers;
        break;
      case StampCategory.toys:
        activeStickers = _toyStickers;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: StampCategory.values.map((cat) {
              final isSelected = _selectedStampCategory == cat;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(audioServiceProvider).playCue(SoundCue.press);
                  setState(() => _selectedStampCategory = cat);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7E57C2) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.white : const Color(0xFFD7CCC8),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7E57C2).withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        cat.localizedTitle(locale),
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : const Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 6),

        // Stamps Horizontal Scrollable Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(activeStickers.length, (index) {
              final stk = activeStickers[index];
              final bg = _candyStickerColors[index % _candyStickerColors.length];
              final isNumberOrMath = stk.category == 'numbers' || stk.category == 'math';

              return GestureDetector(
                onTap: () => _addSticker(stk),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: isNumberOrMath
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 5)
                      : const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: isNumberOrMath
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [bg.withOpacity(0.9), bg],
                          )
                        : null,
                    color: !isNumberOrMath ? Colors.white : null,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isNumberOrMath ? Colors.white : const Color(0xFF7E57C2),
                      width: isNumberOrMath ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isNumberOrMath ? bg : Colors.black).withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: isNumberOrMath
                      ? Text(
                          stk.emoji,
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(1, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        )
                      : Text(stk.emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter that renders normal, rainbow, glitter, neon, and eraser strokes
class StudioCanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final Color backgroundColor;

  StudioCanvasPainter({required this.strokes, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    const rainbowColors = [
      Color(0xFFFF1744),
      Color(0xFFFF9100),
      Color(0xFFFFEA00),
      Color(0xFF00E676),
      Color(0xFF2979FF),
      Color(0xFFD500F9),
    ];

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      switch (stroke.brushType) {
        case BrushType.normal:
          final paint = Paint()
            ..color = stroke.color
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = stroke.strokeWidth
            ..style = PaintingStyle.stroke;

          _drawConnectedPath(canvas, stroke.points, paint);
          break;

        case BrushType.rainbow:
          final paint = Paint()
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = stroke.strokeWidth
            ..style = PaintingStyle.stroke;

          if (stroke.points.length == 1) {
            paint.color = rainbowColors[0];
            canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
          } else {
            for (int i = 0; i < stroke.points.length - 1; i++) {
              paint.color = rainbowColors[i % rainbowColors.length];
              canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
            }
          }
          break;

        case BrushType.glitter:
          // Draw main stroke + twinkling particles
          final basePaint = Paint()
            ..color = stroke.color.withOpacity(0.85)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = stroke.strokeWidth
            ..style = PaintingStyle.stroke;

          _drawConnectedPath(canvas, stroke.points, basePaint);

          // Twinkling stars/particles along the stroke
          final starPaint = Paint()..style = PaintingStyle.fill;
          for (int i = 0; i < stroke.points.length; i += 3) {
            final pt = stroke.points[i];
            final starColor = (i % 2 == 0) ? Colors.white : const Color(0xFFFFD700);
            starPaint.color = starColor.withOpacity(0.9);
            canvas.drawCircle(pt + Offset(sin(i.toDouble()) * 4, cos(i.toDouble()) * 4), 2.5, starPaint);
          }
          break;

        case BrushType.neon:
          // Outer glowing halo
          final glowPaint = Paint()
            ..color = stroke.color.withOpacity(0.4)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = stroke.strokeWidth * 2.2
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
            ..style = PaintingStyle.stroke;

          _drawConnectedPath(canvas, stroke.points, glowPaint);

          // Hot bright center core
          final corePaint = Paint()
            ..color = Colors.white
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = max(2.0, stroke.strokeWidth * 0.45)
            ..style = PaintingStyle.stroke;

          _drawConnectedPath(canvas, stroke.points, corePaint);
          break;

        case BrushType.eraser:
          final eraserPaint = Paint()
            ..color = backgroundColor
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = stroke.strokeWidth * 1.5
            ..style = PaintingStyle.stroke;

          _drawConnectedPath(canvas, stroke.points, eraserPaint);
          break;
      }
    }
  }

  void _drawConnectedPath(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length == 1) {
      canvas.drawCircle(points.first, paint.strokeWidth / 2, paint..style = PaintingStyle.fill);
    } else {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StudioCanvasPainter oldDelegate) => true;
}

/// CustomPainter that renders friendly, dashed cartoon coloring stencil outlines
class StencilGuidePainter extends CustomPainter {
  final CanvasStencil stencil;

  StencilGuidePainter({required this.stencil});

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    switch (stencil) {
      case CanvasStencil.lion:
        // Mane circle
        canvas.drawCircle(center, 90, guidePaint);
        // Face circle
        canvas.drawCircle(center, 65, guidePaint);
        // Ears
        canvas.drawCircle(center + const Offset(-50, -50), 22, guidePaint);
        canvas.drawCircle(center + const Offset(50, -50), 22, guidePaint);
        // Eyes
        canvas.drawCircle(center + const Offset(-25, -10), 8, guidePaint..style = PaintingStyle.fill);
        canvas.drawCircle(center + const Offset(25, -10), 8, guidePaint..style = PaintingStyle.fill);
        guidePaint.style = PaintingStyle.stroke;
        // Nose triangle
        final nosePath = Path()
          ..moveTo(center.dx - 12, center.dy + 12)
          ..lineTo(center.dx + 12, center.dy + 12)
          ..lineTo(center.dx, center.dy + 24)
          ..close();
        canvas.drawPath(nosePath, guidePaint);
        break;

      case CanvasStencil.puppy:
        // Head
        canvas.drawOval(Rect.fromCenter(center: center, width: 130, height: 110), guidePaint);
        // Floppy ears
        canvas.drawOval(Rect.fromCenter(center: center + const Offset(-65, 0), width: 35, height: 75), guidePaint);
        canvas.drawOval(Rect.fromCenter(center: center + const Offset(65, 0), width: 35, height: 75), guidePaint);
        // Snout
        canvas.drawOval(Rect.fromCenter(center: center + const Offset(0, 20), width: 55, height: 40), guidePaint);
        // Nose
        canvas.drawCircle(center + const Offset(0, 15), 10, guidePaint..style = PaintingStyle.fill);
        guidePaint.style = PaintingStyle.stroke;
        break;

      case CanvasStencil.rocket:
        // Rocket fuselage
        final rocketPath = Path()
          ..moveTo(center.dx, center.dy - 100) // Nose tip
          ..quadraticBezierTo(center.dx + 45, center.dy, center.dx + 35, center.dy + 70)
          ..lineTo(center.dx - 35, center.dy + 70)
          ..quadraticBezierTo(center.dx - 45, center.dy, center.dx, center.dy - 100)
          ..close();
        canvas.drawPath(rocketPath, guidePaint);

        // Porthole window
        canvas.drawCircle(center + const Offset(0, -15), 24, guidePaint);

        // Fins
        final leftFin = Path()
          ..moveTo(center.dx - 35, center.dy + 30)
          ..lineTo(center.dx - 65, center.dy + 80)
          ..lineTo(center.dx - 35, center.dy + 70)
          ..close();
        final rightFin = Path()
          ..moveTo(center.dx + 35, center.dy + 30)
          ..lineTo(center.dx + 65, center.dy + 80)
          ..lineTo(center.dx + 35, center.dy + 70)
          ..close();
        canvas.drawPath(leftFin, guidePaint);
        canvas.drawPath(rightFin, guidePaint);
        break;

      case CanvasStencil.cake:
        // Bottom layer
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center + const Offset(0, 50), width: 150, height: 50),
            const Radius.circular(10),
          ),
          guidePaint,
        );
        // Top layer
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center + const Offset(0, 5), width: 100, height: 45),
            const Radius.circular(8),
          ),
          guidePaint,
        );
        // Candle
        canvas.drawRect(
          Rect.fromCenter(center: center + const Offset(0, -35), width: 12, height: 35),
          guidePaint,
        );
        // Flame
        canvas.drawOval(
          Rect.fromCenter(center: center + const Offset(0, -60), width: 14, height: 20),
          guidePaint,
        );
        break;

      case CanvasStencil.castle:
        // Main base
        canvas.drawRect(
          Rect.fromCenter(center: center + const Offset(0, 30), width: 120, height: 70),
          guidePaint,
        );
        // Left tower
        canvas.drawRect(
          Rect.fromCenter(center: center + const Offset(-60, 10), width: 35, height: 110),
          guidePaint,
        );
        // Right tower
        canvas.drawRect(
          Rect.fromCenter(center: center + const Offset(60, 10), width: 35, height: 110),
          guidePaint,
        );
        // Center tower
        canvas.drawRect(
          Rect.fromCenter(center: center + const Offset(0, -25), width: 45, height: 80),
          guidePaint,
        );
        // Center cone roof
        final roof = Path()
          ..moveTo(center.dx - 25, center.dy - 65)
          ..lineTo(center.dx + 25, center.dy - 65)
          ..lineTo(center.dx, center.dy - 105)
          ..close();
        canvas.drawPath(roof, guidePaint);
        break;

      case CanvasStencil.star:
        final path = Path();
        const numPoints = 5;
        const outerRadius = 85.0;
        const innerRadius = 38.0;

        for (int i = 0; i < numPoints * 2; i++) {
          final r = i.isEven ? outerRadius : innerRadius;
          final angle = (i * pi / numPoints) - (pi / 2);
          final pt = center + Offset(cos(angle) * r, sin(angle) * r);
          if (i == 0) {
            path.moveTo(pt.dx, pt.dy);
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
        }
        path.close();
        canvas.drawPath(path, guidePaint);
        break;

      case CanvasStencil.blank:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant StencilGuidePainter oldDelegate) =>
      oldDelegate.stencil != stencil;
}
