import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../core/widgets/playful_bouncing_effects.dart';
import '../../core/ads/ad_banner_widget.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/environment/celestial_time_engine.dart';
import '../../core/motion/parallax_tilt_controller.dart';
import '../../core/voice/voice_navigation_controller.dart';
import '../../core/widgets/cartoon_ui_components.dart';
import '../../core/widgets/interactive_island_map_view.dart';
import '../../core/widgets/inflatable_3d_title.dart';
import '../../core/widgets/interactive_prince_leo.dart';
import '../../core/widgets/pixar_3d_icons.dart';
import '../../core/widgets/pixar_meadow_world_engine.dart';
import '../../domain/models/daily_adventure.dart';
import '../../domain/models/profile.dart';
import '../../games/registry.dart';
import '../game_shell/game_shell_screen.dart';
import '../parent/parent_dashboard_screen.dart';
import '../parent/parent_gate_dialog.dart';
import '../daily_quest/daily_treasure_chest_dialog.dart';
import '../wardrobe/mascot_wardrobe_dialog.dart';
import '../storybook/interactive_storybook_screen.dart';
import '../world_builder/kingdom_world_builder_screen.dart';
import '../../core/widgets/magic_touch_overlay.dart';
import '../rewards/gacha_machine_dialog.dart';
import '../rewards/toy_collection_shelf_dialog.dart';
import '../pet/prince_leo_care_sheet.dart';
import '../bedtime/bedtime_wind_down_dialog.dart';
import '../certificates/royal_diploma_dialog.dart';
import '../worlds/game_adventure_map_screen.dart';
import '../stickers/sticker_book_screen.dart';

/// Krido - Adventure Island World Hub Screen
/// Implements the exact visual theme and characters from the hero photo:
/// - Sunny cerulean sky with drifting clouds, rolling hills, blooming daisies & turquoise lake
/// - Inflatable 3D balloon "KIDS" typography and 3D "KING PRO"
/// - Prince Leo with jigsaw-puzzle mane, tilted golden crown, waving paw, and ABC blocks
/// - 6 Floating 3D Island Stepping Stones (Puzzles, Math, ABC, Shapes, Memory, Magic Studio)
/// - Multi-touch magical sparkle dust, floating interactive puzzle pieces & smiling stars
/// - Dual-Orientation support: Panoramic Landscape Meadow Trail & Portrait Winding Path
class LandscapeLearningHubScreen extends ConsumerStatefulWidget {
  const LandscapeLearningHubScreen({super.key});

  @override
  ConsumerState<LandscapeLearningHubScreen> createState() =>
      _LandscapeLearningHubScreenState();
}

class _LandscapeLearningHubScreenState
    extends ConsumerState<LandscapeLearningHubScreen>
    with TickerProviderStateMixin {
  late CelestialTimeEngine _celestialEngine;
  late ParallaxTiltController _tiltController;
  late VoiceNavigationController _voiceController;

  late AnimationController _idleBreathingController;
  final ScrollController _islandsScrollController = ScrollController();
  final ScrollController _portraitScrollController = ScrollController();
  bool _isMascotMinimized = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();

    // Automatically sync celestial lighting to real-world device clock (Dawn, Day, Sunset, Night)
    _celestialEngine = CelestialTimeEngine();
    _tiltController = ParallaxTiltController();
    _voiceController = VoiceNavigationController();

    // Hook voice navigation to game launch and celestial changes
    _voiceController.onLaunchGame = (gameId) {
      _launchGameById(gameId);
    };
    _voiceController.onChangePhase = (phase) {
      _celestialEngine.setPhase(phase, disableAuto: false);
      ref.read(audioServiceProvider).playCue(SoundCue.timeShift);
    };

    // Idle ambient breathing animation for living parallax
    _idleBreathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        _tiltController.updateAmbientTick(_idleBreathingController.value * 10);
      })
      ..repeat();
  }

  @override
  void dispose() {
    _idleBreathingController.dispose();
    _islandsScrollController.dispose();
    _portraitScrollController.dispose();
    _celestialEngine.dispose();
    _tiltController.dispose();
    _voiceController.dispose();
    super.dispose();
  }

  void _launchGameById(String gameId) {
    ref.read(audioServiceProvider).playCue(SoundCue.press);
    HapticFeedback.mediumImpact().catchError((_) {});

    if (gameId == 'WORLD_BUILDER') {
      Navigator.push(
        context,
        BouncyPageRoute(
          page: const KingdomWorldBuilderScreen(),
        ),
      );
      return;
    }

    if (gameId == 'STORYBOOK') {
      Navigator.push(
        context,
        BouncyPageRoute(
          page: const InteractiveStorybookScreen(),
        ),
      );
      return;
    }

    final definition =
        GameRegistry.getById(gameId) ?? GameRegistry.getFlagships().first;

    Navigator.push(
      context,
      BouncyPageRoute(
        page: GameShellScreen(gameId: definition.id),
      ),
    );
  }

  List<Map<String, dynamic>> _getIslands() {
    return [
      {
        'id': 'G001',
        'title': '1-1000 MOSAIC',
        'subtitle': '1 to 1000 Number Journey',
        'pixarType': PixarIconType.mosaic,
        'tag': '1-1000 MAP',
        'islandColor': const Color(0xFF1E88E5), // Deep Sapphire Focus Blue
        'accent': const Color(0xFFFF5252),
        'stars': 3,
      },
      {
        'id': 'G011',
        'title': 'LEARN ABCD',
        'subtitle': 'Graphic Cards & Phonics SFX',
        'pixarType': PixarIconType.letter,
        'tag': 'A-Z PHONICS',
        'islandColor': const Color(0xFFAB47BC), // Candy Lilac
        'accent': const Color(0xFFFFD54F),
        'stars': 3,
      },
      {
        'id': 'G012',
        'title': 'ALPHA GRID',
        'subtitle': 'Tap A-Z In Order!',
        'pixarType': PixarIconType.alphaGrid,
        'tag': 'ABC GRID',
        'islandColor': const Color(0xFF1565C0), // Royal Sapphire
        'accent': const Color(0xFF69F0AE),
        'stars': 3,
      },
      {
        'id': 'G072',
        'title': 'WORD BUILDER',
        'subtitle': 'Spell CAT, DOG, MILK!',
        'pixarType': PixarIconType.wordBuilder,
        'tag': 'SPELLING',
        'islandColor': const Color(0xFF00897B), // Deep Teal
        'accent': const Color(0xFFFFCA28),
        'stars': 3,
      },
      {
        'id': 'G002',
        'title': 'COUNT APPLES',
        'subtitle': 'Sunny Tree Orchard',
        'pixarType': PixarIconType.apple,
        'tag': 'NUMBERS',
        'islandColor': const Color(0xFF66BB6A), // Lush Meadow Green
        'accent': const Color(0xFFFF5252),
        'stars': 3,
      },
      {
        'id': 'G051',
        'title': 'ANIMAL PUZZLE',
        'subtitle': '4-Piece Animal Jigsaw',
        'pixarType': PixarIconType.doggy,
        'tag': 'PUZZLES',
        'islandColor': const Color(0xFFFFAB40), // Warm Peach Orange
        'accent': const Color(0xFF69F0AE),
        'stars': 3,
      },
      {
        'id': 'G031',
        'title': 'SHAPE MATCH',
        'subtitle': 'Living Objects Mountain',
        'pixarType': PixarIconType.shapes,
        'tag': 'SHAPES',
        'islandColor': const Color(0xFF29B6F6), // Azure Sky
        'accent': const Color(0xFFFF8A65),
        'stars': 3,
      },
      {
        'id': 'G041',
        'title': 'MEMORY MATCH',
        'subtitle': '4x4 Patterned Sun Tiles',
        'pixarType': PixarIconType.memory,
        'tag': 'MEMORY',
        'islandColor': const Color(0xFFFFCA28), // Golden Honey
        'accent': const Color(0xFFAB47BC),
        'stars': 3,
      },
      {
        'id': 'G073',
        'title': 'SPELLING PUZZLE',
        'subtitle': 'Tap Illustrated Words!',
        'pixarType': PixarIconType.spellingPuzzle,
        'tag': 'SPELLING',
        'islandColor': const Color(0xFFE91E63), // Rose Candy
        'accent': const Color(0xFFFFEB3B),
        'stars': 3,
      },
      {
        'id': 'G074',
        'title': 'KID MATH',
        'subtitle': 'Count & Add Together!',
        'pixarType': PixarIconType.star,
        'tag': 'MATH',
        'islandColor': const Color(0xFF43A047), // Apple Orchard Green
        'accent': const Color(0xFFFFD54F),
        'stars': 3,
      },
      {
        'id': 'G075',
        'title': 'PATTERN PATH',
        'subtitle': 'Complete The Sequence!',
        'pixarType': PixarIconType.mosaic,
        'tag': 'PATTERNS',
        'islandColor': const Color(0xFF00ACC1), // Cyan Wave
        'accent': const Color(0xFFFF7043),
        'stars': 3,
      },
      {
        'id': 'G076',
        'title': 'ANIMAL SOUNDS',
        'subtitle': 'Who Says That Sound?',
        'pixarType': PixarIconType.speaker,
        'tag': 'ANIMALS',
        'islandColor': const Color(0xFFFF7043), // Warm Tangerine
        'accent': const Color(0xFF81D4FA),
        'stars': 3,
      },
      {
        'id': 'G077',
        'title': 'ANIMAL QUIZ',
        'subtitle': 'Pick The Correct Name!',
        'pixarType': PixarIconType.animalQuiz,
        'tag': 'ANIMALS',
        'islandColor': const Color(0xFFFFA000), // Safari Honey
        'accent': const Color(0xFF00E5FF),
        'stars': 3,
      },
      {
        'id': 'G078',
        'title': 'RHYME MATCH',
        'subtitle': 'Find Rhyming Friends!',
        'pixarType': PixarIconType.wordBuilder,
        'tag': 'RHYMES',
        'islandColor': const Color(0xFFBA68C8), // Violet Magic
        'accent': const Color(0xFFFFD54F),
        'stars': 3,
      },
      {
        'id': 'G079',
        'title': 'LETTER TRACE',
        'subtitle': 'Trace ABC with Finger!',
        'pixarType': PixarIconType.letter,
        'tag': 'TRACING',
        'islandColor': const Color(0xFF26A69A), // Teal Jade
        'accent': const Color(0xFFFF4081),
        'stars': 3,
      },
      {
        'id': 'G080',
        'title': 'RAINBOW XYLO',
        'subtitle': '8-Note Musical Island',
        'pixarType': PixarIconType.shapes,
        'tag': 'MUSIC',
        'islandColor': const Color(0xFFE91E63), // Vibrant Rose Pink
        'accent': const Color(0xFFFFD54F),
        'stars': 3,
      },
      {
        'id': 'STORYBOOK',
        'title': 'PRINCE LEO STORY',
        'subtitle': 'Read-To-Me Storybook',
        'pixarType': PixarIconType.letter,
        'tag': 'STORY',
        'islandColor': const Color(0xFF7E57C2), // Royal Lavender
        'accent': const Color(0xFFFFEB3B),
        'stars': 3,
      },
      {
        'id': 'WORLD_BUILDER',
        'title': 'WORLD BUILDER',
        'subtitle': 'Sticker Diorama Sandbox',
        'pixarType': PixarIconType.art,
        'tag': 'SANDBOX',
        'islandColor': const Color(0xFF00B0FF), // Cerulean
        'accent': const Color(0xFFFF9100),
        'stars': 3,
      },
      {
        'id': 'G081',
        'title': 'SORTING FACTORY',
        'subtitle': 'Color & Shape Sorting',
        'pixarType': PixarIconType.shapes,
        'tag': 'SHAPES',
        'islandColor': const Color(0xFFFF9800),
        'accent': const Color(0xFFFFD54F),
        'stars': 3,
      },
      {
        'id': 'G082',
        'title': 'HABITAT MATCH',
        'subtitle': 'Animal Home Matching',
        'pixarType': PixarIconType.animalQuiz,
        'tag': 'ANIMALS',
        'islandColor': const Color(0xFF4CAF50),
        'accent': const Color(0xFF69F0AE),
        'stars': 3,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider);
    final dailyAdventure = ref.watch(dailyAdventureProvider);
    final profile = ref.watch(currentProfileProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                profile?.uiLocale == 'hi'
                    ? 'बाहर निकलने के लिए फिर से वापस दबाएं'
                    : 'Press back again to exit KRIDO',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
            final isLandscape = constraints.maxWidth >= constraints.maxHeight;

            return ListenableBuilder(
              listenable: Listenable.merge([_celestialEngine, _tiltController]),
              builder: (context, _) {
                final tiltX = _tiltController.tiltX;
                final tiltY = _tiltController.tiltY;
                final phase = _celestialEngine.currentPhase;

                return Listener(
                  onPointerMove: (event) {
                    _tiltController.updatePan(event.localPosition, screenSize);
                  },
                  onPointerUp: (_) {
                    _tiltController.releasePan();
                  },
                  child: PixarMeadowWorldEngine(
                    phase: phase,
                    tiltX: tiltX,
                    tiltY: tiltY,
                    onPlayCue: (cue) => audioService.playCue(cue),
                    child: MagicTouchOverlay(
                      child: Builder(
                        builder: (ctx) {
                          final safeInsets = MediaQuery.of(ctx).padding;
                          final dynamicLeft = math.max(6.0, safeInsets.left * 0.7);
                          final dynamicRight = math.max(6.0, safeInsets.right * 0.7);
                          final dynamicTop = math.max(4.0, safeInsets.top * 0.4);
                          final dynamicBottom = math.max(2.0, safeInsets.bottom * 0.4);

                          return Padding(
                            padding: EdgeInsets.only(
                              left: dynamicLeft,
                              right: dynamicRight,
                              top: dynamicTop,
                              bottom: dynamicBottom,
                            ),
                            child: isLandscape
                                ? _buildLandscapeLayout(
                                    tiltX,
                                    tiltY,
                                    audioService,
                                    dailyAdventure,
                                    profile,
                                  )
                                : _buildPortraitLayout(
                                    tiltX,
                                    tiltY,
                                    audioService,
                                    dailyAdventure,
                                    profile,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// LANDSCAPE MODE (Panoramic Meadow Path + Prince Leo Knox)
  /// --------------------------------------------------------------------------
  Widget _buildLandscapeLayout(
    double tiltX,
    double tiltY,
    AudioService audioService,
    DailyAdventure? dailyAdventure,
    Profile? profile,
  ) {
    final stars = dailyAdventure?.completionFlags.where((f) => f).length ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ZONE 1: Left Prince Leo Meadow Knox with 3D Inflatable Title
        _buildLandscapeHeroMascotKnoll(),

        // ZONE 2: Center Floating 3D Island Stepping-Stone Trail
        Expanded(
          child: _buildLandscapeIslandTrail(tiltX, tiltY),
        ),

        // ZONE 3: Right Kingdom Control Dock
        _buildRightControlStrip(audioService, stars, profile?.nickname),
      ],
    );
  }

  /// Left Hero Mascot Knoll in Landscape
  Widget _buildLandscapeHeroMascotKnoll() {
    return Container(
      width: 290,
      padding: const EdgeInsets.fromLTRB(10, 6, 8, 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 3D Inflatable "KRIDO" Title
          const Inflatable3DTitle(
            scale: 0.88,
            showSubtitle: true,
          ),

          // Interactive Prince Leo Mascot with Puzzle Mane & Wardrobe Dressing Room
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: InteractivePrinceLeo(
                    size: 195,
                    showSpeechBubble: true,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BouncyBounceTap(
                        onTap: () {
                          HapticFeedback.lightImpact().catchError((_) {});
                          MascotWardrobeDialog.show(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8F00).withOpacity(0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('👑', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                'Dress Up',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5D4037),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BouncyBounceTap(
                        onTap: () {
                          HapticFeedback.lightImpact().catchError((_) {});
                          PrinceLeoCareSheet.show(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD32F2F).withOpacity(0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🍎', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                'Feed Leo',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Center 3D Island Stepping-Stone Trail in Landscape
  Widget _buildLandscapeIslandTrail(double tiltX, double tiltY) {
    final islands = _getIslands();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Adventure Path Header Ribbon
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 4, bottom: 2, right: 8),
          child: Row(
            children: [
              BouncyBounceTap(
                onTap: () {
                  HapticFeedback.mediumImpact().catchError((_) {});
                  ProceduralSfxEngine().playSparkle();
                  Navigator.push(
                    context,
                    BouncyPageRoute(
                      page: const GameAdventureMapScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0288D1).withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🗺️', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 4),
                      Text(
                        'ADVENTURE MAP',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8F00).withOpacity(0.4),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Pixar3DIcon(type: PixarIconType.star, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'MINI GAMES',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4A3418),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Scroll Map! 🗺️',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuickActionBadge(
                        emoji: '🥚',
                        label: 'Gacha',
                        color: const Color(0xFFFF5252),
                        onTap: () => GachaMachineDialog.show(context),
                      ),
                      const SizedBox(width: 6),
                      _buildQuickActionBadge(
                        emoji: '🧸',
                        label: 'Toys',
                        color: const Color(0xFF7E57C2),
                        onTap: () => ToyCollectionShelfDialog.show(context),
                      ),
                      const SizedBox(width: 6),
                      _buildQuickActionBadge(
                        emoji: '🌙',
                        label: 'Bedtime',
                        color: const Color(0xFF3F51B5),
                        onTap: () => BedtimeWindDownDialog.show(context),
                      ),
                      const SizedBox(width: 6),
                      _buildQuickActionBadge(
                        emoji: '📜',
                        label: 'Diploma',
                        color: const Color(0xFF43A047),
                        onTap: () => RoyalDiplomaDialog.show(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable Island Adventure Map Trail (All 18 Games 100% Unlocked!)
        Expanded(
          child: InteractiveIslandMapView(
            islands: islands,
            isLandscape: true,
            onLaunchGame: _launchGameById,
          ),
        ),

        // Child-Safe Justified Bottom AdMob Banner Dock
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Center(
            child: AdBannerWidget(),
          ),
        ),
      ],
    );
  }

  /// Right Zone in Landscape: Celestial Dial & Star Vault & Audio Controls
  Widget _buildRightControlStrip(
    AudioService audioService,
    int stars,
    String? nickname,
  ) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Star Vault Pill & Daily Mystery Chest Entry
          BouncyBounceTap(
            onTap: () {
              HapticFeedback.lightImpact().catchError((_) {});
              DailyTreasureChestDialog.show(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9EE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC89658), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 3),
                  Text(
                    '$stars/3',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4A3418),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Interactive Celestial Time Dial (Tap to switch Day / Sunset / Night)
          BouncyBounceTap(
            onTap: () {
              audioService.playCue(SoundCue.timeShift);
              _celestialEngine.cycleNextPhase();
              _voiceController.speak(
                "Switched to ${_celestialEngine.currentPhase.displayName}!",
                mood: MascotMood.excited,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.94),
                border: Border.all(color: const Color(0xFFE5A866), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Pixar3DIcon(type: PixarIconType.timeDial, size: 30),
                  Text(
                    'TIME',
                    style: GoogleFonts.nunito(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF6D4C41),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Audio Mute / Unmute Button with Pixar 3D Speaker
          CandyPillButton(
            width: 48,
            height: 48,
            borderRadius: 24,
            color: audioService.isMuted
                ? const Color(0xFFFF7043)
                : const Color(0xFF42A5F5),
            borderColor: Colors.white,
            onPressed: () {
              audioService.toggleMute();
            },
            child: const Pixar3DIcon(type: PixarIconType.speaker, size: 26),
          ),

          // 4. Parental Gate Button
          CandyPillButton(
            width: 48,
            height: 48,
            borderRadius: 24,
            color: const Color(0xFF7E57C2),
            borderColor: Colors.white,
            onPressed: () {
              HapticFeedback.lightImpact().catchError((_) {});
              ParentGateDialog.show(
                context,
                onSuccess: () {
                  Navigator.push(
                    context,
                    BouncyPageRoute(
                      page: const ParentDashboardScreen(),
                    ),
                  );
                },
              );
            },
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// PORTRAIT MODE (Hero Inflatable Title + Prince Leo + Adventure Island Grid)
  /// --------------------------------------------------------------------------
  Widget _buildPortraitLayout(
    double tiltX,
    double tiltY,
    AudioService audioService,
    DailyAdventure? dailyAdventure,
    Profile? profile,
  ) {
    final stars = dailyAdventure?.completionFlags.where((f) => f).length ?? 0;
    final islands = _getIslands();

    return Column(
      children: [
        // Full screen unified scrollable view:
        // Top Header Cluster + Leo Hero Knoll + Ribbon + Island Map Trail
        // When user scrolls the map up, all top elements smoothly scroll off-screen,
        // giving the adventure map full-screen display space!
        Expanded(
          child: InteractiveIslandMapView(
            islands: islands,
            isLandscape: false,
            onLaunchGame: _launchGameById,
            header: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Header Cluster: 3D Inflatable Title ("KRIDO") + Stars + Time Dial + Audio Mute + Shield
                _buildPortraitTopCluster(audioService, stars),

                const SizedBox(height: 4),

                // 2. Minimizable / Collapsible Prince Leo Hero Knoll
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutBack,
                  child: _buildPortraitLeoHeroKnoll(),
                ),

                // 3. Mini Games Header Ribbon with Minimize/Expand Toggle & Quick Actions
                _buildPortraitRibbon(audioService),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ),

        // Child-Safe Justified Bottom Dock: Always-Visible AdMob Banner
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(0, -3),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: const Center(
            child: AdBannerWidget(),
          ),
        ),
      ],
    );
  }

  /// Mini Games Header Ribbon with Minimize/Expand Toggle & Quick Actions
  Widget _buildPortraitRibbon(AudioService audioService) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BouncyBounceTap(
                    onTap: () {
                      HapticFeedback.mediumImpact().catchError((_) {});
                      ProceduralSfxEngine().playSparkle();
                      Navigator.push(
                        context,
                        BouncyPageRoute(
                          page: const GameAdventureMapScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0288D1).withOpacity(0.35),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🗺️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            'MAP',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8F00).withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Pixar3DIcon(type: PixarIconType.star, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'MINI GAMES',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF4A3418),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Mascot Minimize / Expand Quick Toggle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact().catchError((_) {});
                      audioService.playCue(SoundCue.press);
                      setState(() {
                        _isMascotMinimized = !_isMascotMinimized;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isMascotMinimized
                                ? Icons.unfold_more_rounded
                                : Icons.unfold_less_rounded,
                            size: 14,
                            color: const Color(0xFF6A1B9A),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _isMascotMinimized ? 'EXPAND' : 'MINIMIZE',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF6A1B9A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  _buildMiniActionIcon('🥚', onTap: () => GachaMachineDialog.show(context)),
                  const SizedBox(width: 4),
                  _buildMiniActionIcon('🧸', onTap: () => ToyCollectionShelfDialog.show(context)),
                  const SizedBox(width: 4),
                  _buildMiniActionIcon('🎨', onTap: () {
                    HapticFeedback.lightImpact().catchError((_) {});
                    ProceduralSfxEngine().playSparkle();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StickerBookScreen()));
                  }),
                  const SizedBox(width: 4),
                  _buildMiniActionIcon('🍎', onTap: () => PrinceLeoCareSheet.show(context)),
                  const SizedBox(width: 4),
                  _buildMiniActionIcon('🌙', onTap: () => BedtimeWindDownDialog.show(context)),
                  const SizedBox(width: 4),
                  _buildMiniActionIcon('📜', onTap: () => RoyalDiplomaDialog.show(context)),
                  const SizedBox(width: 6),
                  Text(
                    'Scroll Map 🗺️',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
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

  /// Portrait Top Cluster: Title + Star Vault + Time Dial + Audio
  Widget _buildPortraitTopCluster(AudioService audioService, int stars) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D Inflatable Title (Compact)
                  const Inflatable3DTitle(
                    scale: 0.70,
                    showSubtitle: true,
                  ),

                  const SizedBox(width: 10),

                  // Utility Action Dock
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Star Vault
                      BouncyBounceTap(
                        onTap: () {
                          HapticFeedback.lightImpact().catchError((_) {});
                          DailyTreasureChestDialog.show(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9EE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFC89658), width: 1.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Pixar3DIcon(type: PixarIconType.star, size: 15),
                              const SizedBox(width: 2),
                              Text(
                                '$stars/3',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF4A3418),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Celestial Time Dial
                      BouncyBounceTap(
                        onTap: () {
                          audioService.playCue(SoundCue.timeShift);
                          _celestialEngine.cycleNextPhase();
                          _voiceController.speak(
                            "Switched to ${_celestialEngine.currentPhase.displayName}!",
                            mood: MascotMood.excited,
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.95),
                            border: Border.all(
                                color: const Color(0xFFE5A866), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Pixar3DIcon(type: PixarIconType.timeDial, size: 26),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Audio Toggle Button
                      CandyPillButton(
                        width: 40,
                        height: 40,
                        borderRadius: 20,
                        color: audioService.isMuted
                            ? const Color(0xFFFF7043)
                            : const Color(0xFF42A5F5),
                        borderColor: Colors.white,
                        onPressed: () {
                          audioService.toggleMute();
                        },
                        child: const Pixar3DIcon(type: PixarIconType.speaker, size: 22),
                      ),

                      const SizedBox(width: 8),

                      // Parental Controls Shield Button
                      CandyPillButton(
                        width: 40,
                        height: 40,
                        borderRadius: 20,
                        color: const Color(0xFF7E57C2),
                        borderColor: Colors.white,
                        onPressed: () {
                          HapticFeedback.lightImpact().catchError((_) {});
                          ParentGateDialog.show(
                            context,
                            onSuccess: () {
                              Navigator.push(
                                context,
                                BouncyPageRoute(
                                  page: const ParentDashboardScreen(),
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Portrait Prince Leo Hero Knoll
  Widget _buildPortraitLeoHeroKnoll() {
    if (_isMascotMinimized) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: BouncyBounceTap(
          onTap: () {
            HapticFeedback.lightImpact().catchError((_) {});
            setState(() {
              _isMascotMinimized = false;
            });
            _voiceController.speak(
              "I'm back! Let's explore together! 🦁",
              mood: MascotMood.happy,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB300), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🦁', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prince Leo: "Tap an island to play!" 👑',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5D4037),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'EXPAND 👆',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InteractivePrinceLeo(
            size: 145,
            showSpeechBubble: true,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BouncyBounceTap(
                  onTap: () {
                    HapticFeedback.lightImpact().catchError((_) {});
                    MascotWardrobeDialog.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'Dress Up',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BouncyBounceTap(
                  onTap: () {
                    HapticFeedback.lightImpact().catchError((_) {});
                    PrinceLeoCareSheet.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🍎', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'Feed Leo',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBadge({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncyBounceTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.bubblegumSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniActionIcon(String emoji, {VoidCallback? onTap}) {
    return BouncyBounceTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
