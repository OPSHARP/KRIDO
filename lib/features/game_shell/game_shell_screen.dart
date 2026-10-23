import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/game_contract/game_controller.dart';
import '../../domain/game_contract/game_lifecycle.dart';
import '../../domain/models/profile.dart';
import '../../games/game_factory.dart';
import '../../games/modules/g001_number_pebble_circle/g001_controller.dart';
import '../../games/modules/g001_number_pebble_circle/g001_view.dart';
import '../../games/modules/g002_count_orchard/g002_controller.dart';
import '../../games/modules/g002_count_orchard/g002_view.dart';
import '../../games/modules/g011_find_the_letter/g011_controller.dart';
import '../../games/modules/g011_find_the_letter/g011_view.dart';
import '../../games/modules/g021_picture_word_search/g021_controller.dart';
import '../../games/modules/g021_picture_word_search/g021_view.dart';
import '../../games/modules/g031_shape_home/g031_controller.dart';
import '../../games/modules/g031_shape_home/g031_view.dart';
import '../../games/modules/g041_picture_pair_memory/g041_controller.dart';
import '../../games/modules/g041_picture_pair_memory/g041_view.dart';
import '../../games/modules/g051_animal_jigsaw/g051_controller.dart';
import '../../games/modules/g051_animal_jigsaw/g051_view.dart';
import '../../games/modules/g061_pattern_path/g061_controller.dart';
import '../../games/modules/g061_pattern_path/g061_view.dart';
import '../../games/modules/g012_alpha_grid_tap/g012_controller.dart';
import '../../games/modules/g012_alpha_grid_tap/g012_view.dart';
import '../../games/modules/g072_word_builder/g072_controller.dart';
import '../../games/modules/g072_word_builder/g072_view.dart';
import '../../games/modules/g073_spelling_puzzle/g073_controller.dart';
import '../../games/modules/g073_spelling_puzzle/g073_view.dart';
import '../../games/modules/g074_kid_math/g074_controller.dart';
import '../../games/modules/g074_kid_math/g074_view.dart';
import '../../games/modules/g075_pattern_sequence/g075_controller.dart';
import '../../games/modules/g075_pattern_sequence/g075_view.dart';
import '../../games/modules/g076_animal_sounds/g076_controller.dart';
import '../../games/modules/g076_animal_sounds/g076_view.dart';
import '../../games/modules/g077_animal_quiz/g077_controller.dart';
import '../../games/modules/g077_animal_quiz/g077_view.dart';
import '../../games/modules/g078_rhyming_words/g078_controller.dart';
import '../../games/modules/g078_rhyming_words/g078_view.dart';
import '../../games/modules/g079_letter_tracing/g079_controller.dart';
import '../../games/modules/g079_letter_tracing/g079_view.dart';
import '../../games/modules/g080_musical_xylophone/g080_controller.dart';
import '../../games/modules/g080_musical_xylophone/g080_view.dart';
import '../../games/modules/g081_sorting_factory/g081_controller.dart';
import '../../games/modules/g081_sorting_factory/g081_view.dart';
import '../../games/modules/g082_habitat_match/g082_controller.dart';
import '../../games/modules/g082_habitat_match/g082_view.dart';
import '../../games/modules/g083_color_mixing_lab/g083_controller.dart';
import '../../games/modules/g083_color_mixing_lab/g083_view.dart';
import '../../games/modules/g084_toothbrush_hero/g084_controller.dart';
import '../../games/modules/g084_toothbrush_hero/g084_view.dart';
import '../../games/modules/g085_detective_leo/g085_controller.dart';
import '../../games/modules/g085_detective_leo/g085_view.dart';
import '../../games/modules/g086_space_explorer/g086_controller.dart';
import '../../games/modules/g086_space_explorer/g086_view.dart';
import '../../games/modules/g087_feeling_mirror/g087_controller.dart';
import '../../games/modules/g087_feeling_mirror/g087_view.dart';
import '../../games/modules/g088_dino_bone_digger/g088_controller.dart';
import '../../games/modules/g088_dino_bone_digger/g088_view.dart';
import '../../games/modules/g089_balloon_fiesta/g089_controller.dart';
import '../../games/modules/g089_balloon_fiesta/g089_view.dart';
import '../../games/modules/g090_size_stacker/g090_controller.dart';
import '../../games/modules/g090_size_stacker/g090_view.dart';
import '../../core/session/learning_streak_service.dart';
import '../../core/voice/celebration_praise_service.dart';
import '../stickers/sticker_canvas_screen.dart';

import 'dart:math' as math;
import '../../core/audio/audio_service.dart';
import '../../core/widgets/confetti_celebration.dart';
import '../../core/widgets/playful_bouncing_effects.dart';
import '../rewards/toy_collection_service.dart';

class GameShellScreen extends ConsumerStatefulWidget {
  final String gameId;
  final int tier;

  const GameShellScreen({
    super.key,
    required this.gameId,
    this.tier = 1,
  });

  @override
  ConsumerState<GameShellScreen> createState() => _GameShellScreenState();
}

class _GameShellScreenState extends ConsumerState<GameShellScreen>
    with WidgetsBindingObserver {
  late GameController _controller;
  bool _isInitialized = false;
  bool _hasSavedResult = false;
  String? _unlockedStickerEmoji;

  late int _currentTier;
  Timer? _shellAutoAdvanceTimer;
  int _autoAdvanceSeconds = 4;
  Timer? _idleHintTimer;
  bool _isHintPulsing = false;

  void _resetIdleTimer() {
    _idleHintTimer?.cancel();
    if (_isHintPulsing) {
      if (mounted) {
        setState(() {
          _isHintPulsing = false;
        });
      }
    }
    if (!_isInitialized || _controller.state != GameLifecycleState.playing) {
      return;
    }
    _idleHintTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted || _controller.state != GameLifecycleState.playing) return;
      setState(() {
        _isHintPulsing = true;
      });
      final isHindi = _controller.profile.uiLocale == 'hi';
      ref.read(audioServiceProvider).playNarration(
        isHindi ? 'मदद चाहिए? पीले बल्ब को छुओ!' : 'Need a hint? Tap the yellow lightbulb!',
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _currentTier = widget.tier;
    WidgetsBinding.instance.addObserver(this);
    _initGame();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isInitialized && _controller.state.canPause) {
        _controller.pause();
        final db = ref.read(databaseProvider);
        db.saveCheckpoint(_controller.serializeCheckpoint());
      }
    }
  }

  void _initGame() {
    _shellAutoAdvanceTimer?.cancel();
    _idleHintTimer?.cancel();
    if (_isInitialized) {
      _controller.removeListener(_onControllerStateChange);
      _controller.dispose();
      _isInitialized = false;
    }
    final profile = ref.read(currentProfileProvider) ??
        Profile(id: 'guest', avatarId: 'avatar_fox', uiLocale: 'en');

    final challenge = GameFactory.createDefaultChallenge(
      widget.gameId,
      tier: _currentTier,
    );

    final seed = DateTime.now().millisecondsSinceEpoch;
    _controller = GameFactory.createController(
      challenge: challenge,
      profile: profile,
      seed: seed,
    );

    _controller.addListener(_onControllerStateChange);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (_hasCustomCartoonShell) {
          _controller.start();
          _resetIdleTimer();
        }
      }
    });
  }

  void _onControllerStateChange() {
    _resetIdleTimer();
    if (_controller.state == GameLifecycleState.completed && !_hasSavedResult) {
      _hasSavedResult = true;
      _idleHintTimer?.cancel();
      final audio = ref.read(audioServiceProvider);
      audio.playCue(SoundCue.complete);
      audio.playCue(SoundCue.star);

      // Dynamic voice praises & celebration variations + haptics
      final isHindi = _controller.profile.uiLocale == 'hi';
      CelebrationPraiseService().celebrateGameSuccess(isHindi: isHindi);

      // Record daily learning streak
      ref.read(learningStreakProvider.notifier).recordGameCompleted();

      _saveCompletion();
      ref.read(virtualPetProvider.notifier).awardModuleCompletion();
      ref.read(toyCollectionProvider.notifier).addEggs(1);
      _startAutoAdvanceCountdown();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _startAutoAdvanceCountdown() {
    _shellAutoAdvanceTimer?.cancel();
    setState(() {
      _autoAdvanceSeconds = 4;
    });

    _shellAutoAdvanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _controller.state != GameLifecycleState.completed) {
        timer.cancel();
        return;
      }
      if (_autoAdvanceSeconds > 1) {
        setState(() {
          _autoAdvanceSeconds--;
        });
      } else {
        timer.cancel();
        _advanceToNextPuzzleNow();
      }
    });
  }

  void _advanceToNextPuzzleNow() {
    _shellAutoAdvanceTimer?.cancel();
    if (!mounted) return;
    _hasSavedResult = false;
    _currentTier = _currentTier >= 3 ? 1 : _currentTier + 1;
    _initGame();
    _controller.start();
  }

  Future<void> _saveCompletion() async {
    final result = _controller.computeResult();
    final db = ref.read(databaseProvider);

    // Deterministic sticker unlock based on game ID
    final stickerMap = {
      'G001': {'id': 'stk_star', 'emoji': '⭐'},
      'G002': {'id': 'stk_apple', 'emoji': '🍎'},
      'G011': {'id': 'stk_book', 'emoji': '📚'},
      'G021': {'id': 'stk_pencil', 'emoji': '✏️'},
      'G031': {'id': 'stk_palette', 'emoji': '🎨'},
      'G041': {'id': 'stk_brain', 'emoji': '🧠'},
      'G051': {'id': 'stk_lion', 'emoji': '🦁'},
      'G061': {'id': 'stk_rocket', 'emoji': '🚀'},
      'G012': {'id': 'stk_grid', 'emoji': '🔤'},
      'G072': {'id': 'stk_word', 'emoji': '🧩'},
      'G073': {'id': 'stk_spell', 'emoji': '📖'},
      'G074': {'id': 'stk_math', 'emoji': '🔢'},
      'G075': {'id': 'stk_pattern', 'emoji': '🎯'},
      'G076': {'id': 'stk_sound', 'emoji': '🎵'},
      'G077': {'id': 'stk_animal', 'emoji': '🐾'},
      'G078': {'id': 'stk_rhyme', 'emoji': '🪶'},
      'G079': {'id': 'stk_trace', 'emoji': '✍️'},
      'G080': {'id': 'stk_music', 'emoji': '🎶'},
      'G081': {'id': 'stk_palette', 'emoji': '🎨'},
      'G082': {'id': 'stk_animal', 'emoji': '🐾'},
    };

    final stickerInfo = stickerMap[widget.gameId];
    _unlockedStickerEmoji = stickerInfo?['emoji'];

    await db.recordAttemptAndReward(
      result: result,
      unlockedStickerId: stickerInfo?['id'],
    );
  }

  @override
  void dispose() {
    _idleHintTimer?.cancel();
    _shellAutoAdvanceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerStateChange);
    _controller.dispose();
    super.dispose();
  }

  Widget _buildGameView() {
    switch (widget.gameId) {
      case 'G001':
        return G001View(controller: _controller as G001Controller);
      case 'G002':
        return G002View(controller: _controller as G002Controller);
      case 'G011':
        return G011View(controller: _controller as G011Controller);
      case 'G021':
        return G021View(controller: _controller as G021Controller);
      case 'G031':
        return G031View(controller: _controller as G031Controller);
      case 'G041':
        return G041View(controller: _controller as G041Controller);
      case 'G051':
        return G051View(controller: _controller as G051Controller);
      case 'G061':
        return G061View(controller: _controller as G061Controller);
      case 'G012':
        return G012View(controller: _controller as G012Controller);
      case 'G072':
        return G072View(controller: _controller as G072Controller);
      case 'G073':
        return G073View(controller: _controller as G073Controller);
      case 'G074':
        return G074View(controller: _controller as G074Controller);
      case 'G075':
        return G075View(controller: _controller as G075Controller);
      case 'G076':
        return G076View(controller: _controller as G076Controller);
      case 'G077':
        return G077View(controller: _controller as G077Controller);
      case 'G078':
        return G078View(controller: _controller as G078Controller);
      case 'G079':
        return G079View(controller: _controller as G079Controller);
      case 'G080':
        return G080View(controller: _controller as G080Controller);
      case 'G081':
        return G081View(controller: _controller as G081Controller);
      case 'G082':
        return G082View(controller: _controller as G082Controller);
      case 'G083':
        return G083View(controller: _controller as G083Controller);
      case 'G084':
        return G084View(controller: _controller as G084Controller);
      case 'G085':
        return G085View(controller: _controller as G085Controller);
      case 'G086':
        return G086View(controller: _controller as G086Controller);
      case 'G087':
        return G087View(controller: _controller as G087Controller);
      case 'G088':
        return G088View(controller: _controller as G088Controller);
      case 'G089':
        return G089View(controller: _controller as G089Controller);
      case 'G090':
        return G090View(controller: _controller as G090Controller);
      case 'G091':
        return const StickerCanvasScreen();
      default:
        return G001View(controller: _controller as G001Controller);
    }
  }

  void _showPauseDialog() {
    _controller.pause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: AppTheme.cardWhite,
          title: Center(
            child: Text(
              _controller.profile.uiLocale == 'hi' ? 'खेल रुका है' : 'Game Paused',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.textNavy,
              ),
            ),
          ),
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle_filled_rounded,
                    size: 64, color: AppTheme.purple),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _controller.resume();
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(
                    _controller.profile.uiLocale == 'hi' ? 'जारी रखें' : 'Resume Play',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppTheme.sky, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _initGame();
                  },
                  icon: const Icon(Icons.refresh_rounded, color: AppTheme.textNavy),
                  label: Text(
                    _controller.profile.uiLocale == 'hi' ? 'पुनः प्रयास करें' : 'Try Again',
                    style: const TextStyle(color: AppTheme.textNavy, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.home_rounded, color: AppTheme.coral),
                  label: Text(
                    _controller.profile.uiLocale == 'hi' ? 'मुख्य पृष्ठ' : 'Go Home',
                    style: const TextStyle(color: AppTheme.coral, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(EdgeInsets mediaPadding) {
    final dynamicLeft = math.max(12.0, mediaPadding.left * 0.7);
    final dynamicRight = math.max(12.0, mediaPadding.right * 0.7);
    final dynamicTop = math.max(8.0, mediaPadding.top * 0.8);

    return Container(
      padding: EdgeInsets.only(
        left: dynamicLeft,
        right: dynamicRight,
        top: dynamicTop,
        bottom: 8,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          // Back button
          BouncyBounceTap(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.purple, size: 28),
            ),
          ),

          // Replay Instruction button
          BouncyBounceTap(
            onTap: () {
              final audio = ref.read(audioServiceProvider);
              audio.playNarration(
                _controller.challenge.localizedPrompt(_controller.profile.uiLocale),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.volume_up_rounded, color: AppTheme.sunGold, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    _controller.profile.uiLocale == 'hi' ? 'सुनो' : 'Listen',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textNavy,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Row(
            children: [
              // Hint button with smart idle pulsing
              BouncyBounceTap(
                onTap: () {
                  _resetIdleTimer();
                  _controller.requestHint();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isHintPulsing ? const Color(0xFFFFD54F) : AppTheme.sunGold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isHintPulsing
                            ? const Color(0xFFFFB300).withOpacity(0.7)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: _isHintPulsing ? 14 : 6,
                        spreadRadius: _isHintPulsing ? 3 : 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 12),

              // Pause button
              BouncyBounceTap(
                onTap: _showPauseDialog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.pause_circle_outline_rounded, color: AppTheme.textNavy, size: 26),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildIntroOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎮', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  _controller.challenge.localizedPrompt(_controller.profile.uiLocale),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textNavy,
                  ),
                ),
                const SizedBox(height: 24),
                BouncyBounceTap(
                  onTap: () {
                    _controller.start();
                  },
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 56),
                    ),
                    onPressed: () {
                      _controller.start();
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 36),
                    label: Text(
                      _controller.profile.uiLocale == 'hi' ? 'खेलें!' : 'Let\'s Play!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionOverlay() {
    final result = _controller.computeResult();
    final stars = result.starsEarned;

    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.sunGold, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 6),
              Text(
                _controller.profile.uiLocale == 'hi'
                    ? 'शानदार खेल!'
                    : 'Wonderful Job!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.purple,
                ),
              ),
              const SizedBox(height: 16),

              // Star progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.star_rounded,
                      size: 48,
                      color: i < stars ? AppTheme.sunGold : Colors.grey.shade300,
                    ),
                  );
                }),
              ),

              if (_unlockedStickerEmoji != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.sunGold, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _unlockedStickerEmoji!,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _controller.profile.uiLocale == 'hi'
                            ? 'नया स्टिकर मिला!'
                            : 'New Sticker Unlocked!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Auto-Generating Next Puzzle Countdown Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.green, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _controller.profile.uiLocale == 'hi'
                              ? 'अगली पहेली ${_autoAdvanceSeconds}s में स्वतः शुरू होगी...'
                              : 'Next Puzzle Auto-Generating in ${_autoAdvanceSeconds}s...',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  BouncyBounceTap(
                    onTap: () {
                      _shellAutoAdvanceTimer?.cancel();
                      _hasSavedResult = false;
                      _initGame();
                      _controller.start();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.purple, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.replay_rounded, color: AppTheme.purple, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            _controller.profile.uiLocale == 'hi' ? 'दोबारा खेलें' : 'Play Again',
                            style: const TextStyle(
                              color: AppTheme.purple,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  BouncyBounceTap(
                    onTap: _advanceToNextPuzzleNow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.4),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.skip_next_rounded, color: Colors.white, size: 24),
                          const SizedBox(width: 6),
                          Text(
                            _controller.profile.uiLocale == 'hi' ? 'अगली पहेली ⏭️' : 'NEXT PUZZLE NOW ⏭️',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  BouncyBounceTap(
                    onTap: () {
                      _shellAutoAdvanceTimer?.cancel();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.coral, width: 2),
                      ),
                      child: const Icon(Icons.home_rounded, color: AppTheme.coral, size: 26),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  bool get _hasCustomCartoonShell =>
      !['G021', 'G061'].contains(widget.gameId);

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.purple),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _shellAutoAdvanceTimer?.cancel();
      },
      child: Scaffold(
        backgroundColor: AppTheme.cream,
        body: Listener(
          onPointerDown: (_) => _resetIdleTimer(),
          behavior: HitTestBehavior.translucent,
          child: Builder(
            builder: (context) {
            final mediaPadding = MediaQuery.of(context).padding;

            return Stack(
              children: [
                _hasCustomCartoonShell
                    ? RepaintBoundary(child: _buildGameView())
                    : Column(
                        children: [
                          _buildTopBar(mediaPadding),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: math.max(8.0, mediaPadding.left * 0.7),
                                right: math.max(8.0, mediaPadding.right * 0.7),
                                bottom: math.max(6.0, mediaPadding.bottom * 0.7),
                              ),
                              child: RepaintBoundary(
                                child: _buildGameView(),
                              ),
                            ),
                          ),
                        ],
                      ),

                if (_controller.state == GameLifecycleState.introduction && !_hasCustomCartoonShell)
                  _buildIntroOverlay(),

                if (_controller.state == GameLifecycleState.completed) ...[
                  _buildCompletionOverlay(),
                  const Positioned.fill(
                    child: ConfettiCelebration(),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    ),
  );
}
}
