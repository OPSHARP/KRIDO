import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/widgets/cartoon_ui_components.dart';
import '../../core/widgets/funny_pixar_characters.dart';
import '../../core/widgets/playful_bouncing_effects.dart';
import '../game_shell/game_shell_screen.dart';

/// ---------------------------------------------------------------------------
/// GAME ADVENTURE MAP SCREEN
/// Interactive winding adventure path for kids with:
/// - 100% of all games UNLOCKED from the start for total child freedom
/// - High quality 3D Pixar-style animated characters along the trail
/// - Vibrant greedy cartoon aesthetic (lush hills, cobblestone path, daisies, rainbow)
/// - Responsive support for both Landscape and Portrait orientations
/// - Zero overflow design with bouncy tactile haptic interactions
/// ---------------------------------------------------------------------------
class GameAdventureMapScreen extends ConsumerStatefulWidget {
  final String? initialGameId;

  const GameAdventureMapScreen({super.key, this.initialGameId});

  @override
  ConsumerState<GameAdventureMapScreen> createState() =>
      _GameAdventureMapScreenState();
}

class _GameAdventureMapScreenState extends ConsumerState<GameAdventureMapScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _sparklePulseController;
  String? _selectedCategory;

  // The 18 fully playable flagship game stations along the path
  static const List<Map<String, dynamic>> _pathStations = [
    {
      'id': 'G001',
      'nameEn': 'Pebble Circle',
      'nameHi': 'संख्या कंकड़',
      'descEn': 'Tap numbers 1 to 10 in order!',
      'category': 'Numbers',
      'accent': Color(0xFF00C9A7),
      'colorValue': 0xFF00C9A7,
    },
    {
      'id': 'G002',
      'nameEn': 'Count the Orchard',
      'nameHi': 'फल गिनो',
      'descEn': 'Count juicy fruits in the tree!',
      'category': 'Numbers',
      'accent': Color(0xFFFF805D),
      'colorValue': 0xFFFF805D,
    },
    {
      'id': 'G011',
      'nameEn': 'Learn ABCD',
      'nameHi': 'अक्षर सीखो',
      'descEn': 'Find matching alphabet letters!',
      'category': 'Phonics',
      'accent': Color(0xFFFFB800),
      'colorValue': 0xFFFFB800,
    },
    {
      'id': 'G012',
      'nameEn': 'Alpha Grid Tap',
      'nameHi': 'ग्रिड टैप',
      'descEn': 'Fast reaction letter tapping!',
      'category': 'Phonics',
      'accent': Color(0xFF339AF0),
      'colorValue': 0xFF339AF0,
    },
    {
      'id': 'G021',
      'nameEn': 'Word Search',
      'nameHi': 'शब्द खोज',
      'descEn': 'Discover hidden word pictures!',
      'category': 'Reading',
      'accent': Color(0xFF845EF7),
      'colorValue': 0xFF845EF7,
    },
    {
      'id': 'G031',
      'nameEn': 'Shape Home',
      'nameHi': 'आकार घर',
      'descEn': 'Sort circles, stars & triangles!',
      'category': 'Shapes',
      'accent': Color(0xFF51CF66),
      'colorValue': 0xFF51CF66,
    },
    {
      'id': 'G041',
      'nameEn': 'Pair Memory',
      'nameHi': 'जोड़ी याद',
      'descEn': 'Flip cards and find animal pairs!',
      'category': 'Memory',
      'accent': Color(0xFFFF6B81),
      'colorValue': 0xFFFF6B81,
    },
    {
      'id': 'G051',
      'nameEn': 'Animal Puzzle',
      'nameHi': 'पशु पहेली',
      'descEn': 'Snap puzzle pieces into place!',
      'category': 'Puzzles',
      'accent': Color(0xFFFF922B),
      'colorValue': 0xFFFF922B,
    },
    {
      'id': 'G061',
      'nameEn': 'Pattern Path',
      'nameHi': 'पैटर्न पथ',
      'descEn': 'Guide the cosmic space rocket!',
      'category': 'Logic',
      'accent': Color(0xFF20C997),
      'colorValue': 0xFF20C997,
    },
    {
      'id': 'G072',
      'nameEn': 'Word Builder',
      'nameHi': 'शब्द निर्माता',
      'descEn': 'Build three-letter phonics words!',
      'category': 'Reading',
      'accent': Color(0xFFE599F7),
      'colorValue': 0xFFE599F7,
    },
    {
      'id': 'G073',
      'nameEn': 'Spelling Bee',
      'nameHi': 'वर्तनी पहेली',
      'descEn': 'Spell cute animal names!',
      'category': 'Reading',
      'accent': Color(0xFFFCC419),
      'colorValue': 0xFFFCC419,
    },
    {
      'id': 'G074',
      'nameEn': 'Kid Math',
      'nameHi': 'बाल गणित',
      'descEn': 'Fun visual addition & counting!',
      'category': 'Numbers',
      'accent': Color(0xFF74C0FC),
      'colorValue': 0xFF74C0FC,
    },
    {
      'id': 'G075',
      'nameEn': 'Pattern Sequencer',
      'nameHi': 'रंग क्रम',
      'descEn': 'Find what comes next in sequence!',
      'category': 'Logic',
      'accent': Color(0xFF69DB7C),
      'colorValue': 0xFF69DB7C,
    },
    {
      'id': 'G076',
      'nameEn': 'Animal Sounds',
      'nameHi': 'जानवरों की आवाज',
      'descEn': 'Listen and guess who makes the sound!',
      'category': 'Animals',
      'accent': Color(0xFFFF922B),
      'colorValue': 0xFFFF922B,
    },
    {
      'id': 'G077',
      'nameEn': 'Animal Quiz',
      'nameHi': 'जानवर प्रश्नोत्तरी',
      'descEn': 'Discover fun animal facts!',
      'category': 'Animals',
      'accent': Color(0xFFFF6B6B),
      'colorValue': 0xFFFF6B6B,
    },
    {
      'id': 'G078',
      'nameEn': 'Rhyming Match',
      'nameHi': 'तुकांत शब्द',
      'descEn': 'Connect words that sound alike!',
      'category': 'Phonics',
      'accent': Color(0xFF748FFC),
      'colorValue': 0xFF748FFC,
    },
    {
      'id': 'G079',
      'nameEn': 'Letter Tracing',
      'nameHi': 'अक्षर अनुरेखण',
      'descEn': 'Trace letters with magic sparkles!',
      'category': 'Phonics',
      'accent': Color(0xFFDA77F2),
      'colorValue': 0xFFDA77F2,
    },
    {
      'id': 'G080',
      'nameEn': 'Rainbow Xylo',
      'nameHi': 'इंद्रधनुष जाइलो',
      'descEn': 'Tap colorful notes & make music!',
      'category': 'Music',
      'accent': Color(0xFF38D9A9),
      'colorValue': 0xFF38D9A9,
    },
    {
      'id': 'G081',
      'nameEn': 'Sorting Factory',
      'nameHi': 'रंग आकार छंटाई',
      'descEn': 'Sort colorful geometric gems!',
      'category': 'Shapes',
      'accent': Color(0xFFFF922B),
      'colorValue': 0xFFFF922B,
    },
    {
      'id': 'G082',
      'nameEn': 'Habitat Match',
      'nameHi': 'जानवर और उनके घर',
      'descEn': 'Guide animals to their lovely home!',
      'category': 'Animals',
      'accent': Color(0xFF20C997),
      'colorValue': 0xFF20C997,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _sparklePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sparklePulseController.dispose();
    super.dispose();
  }

  void _launchGame(String gameId) {
    HapticFeedback.mediumImpact().catchError((_) {});
    ProceduralSfxEngine().playSparkle();
    ref.read(audioServiceProvider).playCue(SoundCue.press);
    Navigator.push(
      context,
      BouncyPageRoute(
        page: GameShellScreen(gameId: gameId),
      ),
    );
  }

  void _showGamePreviewSheet(
    BuildContext context,
    Map<String, dynamic> station,
    bool isHindi,
  ) {
    HapticFeedback.lightImpact().catchError((_) {});
    ProceduralSfxEngine().playPop();
    final gameId = station['id'] as String;
    final charInfo = FunnyCharacterInfo.forGameId(gameId);
    final accent = station['accent'] as Color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pull Handle Bar
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7CCC8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 12),

              // Top Tag: Unlocked Badge + Category
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white, width: 1.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_open_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '100% UNLOCKED',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white, width: 1.8),
                    ),
                    child: Text(
                      station['category'].toString().toUpperCase(),
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3D Pixar Character Animation Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FunnyPixarCharacterWidget(
                    type: charInfo.type,
                    size: 96,
                    animate: true,
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? station['nameHi'] : station['nameEn'],
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
                          ),
                          child: Text(
                            charInfo.speechQuote,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A3418),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Big Juicy Play Now Button
              SizedBox(
                width: double.infinity,
                child: BouncyBounceTap(
                  onTap: () {
                    Navigator.pop(ctx);
                    _launchGame(gameId);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'अभी खेलें! ▶' : 'PLAY NOW! ▶',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
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
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final isHindi = profile?.uiLocale == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFF70D2FA), // Vibrant Sunny Cerulean Sky
      body: Builder(
        builder: (context) {
          final mediaPadding = MediaQuery.of(context).padding;

          return Column(
            children: [
              // 1. Top Adventure Banner (snaps flush to edge with dynamic safe padding)
              _buildTopAppBar(context, isHindi, mediaPadding),

              // 2. Category Quick Filter Bar
              _buildCategoryFilterBar(mediaPadding),

              // 3. Winding Adventure Map Trail (Fully Unlocked Path)
              Expanded(
                child: Stack(
                  children: [
                    // Rolling Hill Parallax Background Canvas
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AdventureMeadowBackgroundPainter(),
                      ),
                    ),

                    // Interactive Winding Stepping Stone Trail
                    ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(
                        math.max(14.0, mediaPadding.left * 0.7),
                        16,
                        math.max(14.0, mediaPadding.right * 0.7),
                        math.max(80.0, mediaPadding.bottom + 40.0),
                      ),
                      itemCount: _filteredStations.length,
                      itemBuilder: (context, index) {
                        final station = _filteredStations[index];
                        return _buildPathNode(context, station, index, isHindi);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredStations {
    if (_selectedCategory == null) return _pathStations;
    return _pathStations
        .where((s) => s['category'] == _selectedCategory)
        .toList();
  }

  Widget _buildTopAppBar(BuildContext context, bool isHindi, EdgeInsets mediaPadding) {
    final dynamicLeft = math.max(12.0, mediaPadding.left * 0.7);
    final dynamicRight = math.max(12.0, mediaPadding.right * 0.7);
    final dynamicTop = math.max(10.0, mediaPadding.top);

    return Container(
      padding: EdgeInsets.only(
        left: dynamicLeft,
        right: dynamicRight,
        top: dynamicTop,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouncy Back Button
          CandyPillButton(
            width: 44,
            height: 44,
            borderRadius: 22,
            color: const Color(0xFFFF5252),
            borderColor: Colors.white,
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),

          // Header Title Plaque
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🗺️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        isHindi ? 'रोमांचक नक्शा' : 'ADVENTURE MAP',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  isHindi
                      ? 'सभी ${_pathStations.length} खेल खुले हैं — कोई भी खेलें!'
                      : 'All ${_pathStations.length} Games Unlocked — Tap Any to Play!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF388E3C),
                  ),
                ),
              ],
            ),
          ),

          // All Unlocked Star Trophy Badge
          BouncyBounceTap(
            onTap: () {
              HapticFeedback.lightImpact().catchError((_) {});
              ProceduralSfxEngine().playSparkle();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${_pathStations.length}/${_pathStations.length}',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4A3418),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterBar(EdgeInsets mediaPadding) {
    const categories = ['All', 'Numbers', 'Phonics', 'Shapes', 'Reading', 'Animals', 'Logic', 'Music'];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: math.max(12.0, mediaPadding.left * 0.7),
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = (_selectedCategory == null && cat == 'All') ||
              (_selectedCategory == cat);

          return BouncyBounceTap(
            onTap: () {
              HapticFeedback.selectionClick().catchError((_) {});
              ProceduralSfxEngine().playPop();
              setState(() {
                _selectedCategory = cat == 'All' ? null : cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF9800) : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.white : const Color(0xFFB0BEC5),
                  width: isSelected ? 2.5 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withOpacity(0.4),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF37474F),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPathNode(
    BuildContext context,
    Map<String, dynamic> station,
    int index,
    bool isHindi,
  ) {
    final gameId = station['id'] as String;
    final charInfo = FunnyCharacterInfo.forGameId(gameId);
    final accent = station['accent'] as Color;

    // S-curve winding alignment: nodes alternate slightly Left, Center, Right
    final alignments = [
      Alignment.centerLeft,
      Alignment.center,
      Alignment.centerRight,
      Alignment.center,
    ];
    final alignment = alignments[index % alignments.length];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: alignment,
        child: BouncyBounceTap(
          onTap: () => _showGamePreviewSheet(context, station, isHindi),
          child: AnimatedBuilder(
            animation: _sparklePulseController,
            builder: (context, child) {
              final scale = 1.0 + (_sparklePulseController.value * 0.03);

              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFFFF9E6),
                    Color.lerp(accent, Colors.white, 0.7)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.35),
                    offset: const Offset(0, 8),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Station Number & 3D Pixar Mascot Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.20),
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 2.5),
                        ),
                      ),
                      FunnyPixarCharacterWidget(
                        type: charInfo.type,
                        size: 64,
                        animate: true,
                      ),
                      // Station # Pill
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3E50),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Game Name + "UNLOCKED 🔓" Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isHindi ? station['nameHi'] : station['nameEn'],
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2C3E50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          station['descEn'],
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF546E7A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Green Unlocked Pill
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF4CAF50), width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 12),
                                  const SizedBox(width: 3),
                                  Text(
                                    'UNLOCKED',
                                    style: GoogleFonts.bubblegumSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            BouncyBounceTap(
                              onTap: () => _launchGame(gameId),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dynamic Painter rendering cartoon rolling green hills and winding cobblestone trail
class _AdventureMeadowBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft rolling emerald hills
    final hillPaint1 = Paint()
      ..color = const Color(0xFF81C784).withOpacity(0.55)
      ..style = PaintingStyle.fill;

    final hillPath1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.25, size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath1, hillPaint1);

    final hillPaint2 = Paint()
      ..color = const Color(0xFF66BB6A).withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final hillPath2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.5, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath2, hillPaint2);

    // 2. Winding dotted path line
    final pathPaint = Paint()
      ..color = Colors.white.withOpacity(0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final trailPath = Path()
      ..moveTo(size.width * 0.25, 0)
      ..cubicTo(
        size.width * 0.8,
        size.height * 0.3,
        size.width * 0.1,
        size.height * 0.7,
        size.width * 0.5,
        size.height,
      );
    canvas.drawPath(trailPath, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
