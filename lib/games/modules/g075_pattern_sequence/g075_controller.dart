import 'dart:async';
import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class PatternItem {
  final String id;
  final String emoji;
  final String label;
  final String labelHi;

  const PatternItem({
    required this.id,
    required this.emoji,
    required this.label,
    required this.labelHi,
  });
}

class G075Controller extends GameController {
  static const List<PatternItem> itemPool = [
    PatternItem(id: 'apple', emoji: '🍎', label: 'Apple', labelHi: 'सेब'),
    PatternItem(id: 'banana', emoji: '🍌', label: 'Banana', labelHi: 'केला'),
    PatternItem(id: 'grapes', emoji: '🍇', label: 'Grapes', labelHi: 'अंगूर'),
    PatternItem(id: 'orange', emoji: '🍊', label: 'Orange', labelHi: 'संतरा'),
    PatternItem(id: 'star', emoji: '⭐', label: 'Star', labelHi: 'तारा'),
    PatternItem(id: 'moon', emoji: '🌙', label: 'Moon', labelHi: 'चांद'),
    PatternItem(id: 'sun', emoji: '☀️', label: 'Sun', labelHi: 'सूरज'),
    PatternItem(id: 'heart', emoji: '💖', label: 'Heart', labelHi: 'दिल'),
    PatternItem(id: 'red_circle', emoji: '🔴', label: 'Red', labelHi: 'लाल'),
    PatternItem(id: 'blue_circle', emoji: '🔵', label: 'Blue', labelHi: 'नीला'),
    PatternItem(id: 'green_circle', emoji: '🟢', label: 'Green', labelHi: 'हरा'),
    PatternItem(id: 'yellow_circle', emoji: '🟡', label: 'Yellow', labelHi: 'पीला'),
  ];

  int currentRound = 0;
  final int totalRounds;
  int levelIndex = 0;

  List<PatternItem> displaySequence = [];
  late PatternItem correctItem;
  List<PatternItem> choices = [];

  PatternItem? selectedChoice;
  PatternItem? wrongChoice;
  bool isPatternComplete = false;

  G075Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  })  : totalRounds = (challenge.taskData['totalRounds'] as int?) ?? 5,
        super(challenge: challenge, profile: profile, seed: seed);

  @override
  Future<void> initialize() async {
    _setupRound();
    await super.initialize();
  }

  void _setupRound() {
    isPatternComplete = false;
    selectedChoice = null;
    wrongChoice = null;
    clearHint();

    final rng = SeededRng(seed + (levelIndex * 73) + (currentRound * 23));

    // Choose 2 or 3 distinct items
    final bool isThreeItemPattern = challenge.tier >= 2 && currentRound >= 2;
    final int distinctCount = isThreeItemPattern ? 3 : 2;

    final pickedItems = rng.pickUnique(itemPool, distinctCount);
    final itemA = pickedItems[0];
    final itemB = pickedItems[1];
    final itemC = isThreeItemPattern ? pickedItems[2] : pickedItems[0];

    List<PatternItem> fullSequence;
    if (!isThreeItemPattern) {
      // ABABAB pattern: 5 items shown, 6th is answer
      fullSequence = [itemA, itemB, itemA, itemB, itemA, itemB];
    } else {
      // ABCABC pattern: 5 items shown, 6th is answer
      fullSequence = [itemA, itemB, itemC, itemA, itemB, itemC];
    }

    correctItem = fullSequence.last;
    displaySequence = fullSequence.sublist(0, fullSequence.length - 1);

    // Choices: 3 or 4 options containing correctItem
    final targetLength = challenge.tier == 1 ? 3 : 4;
    final choiceSet = <PatternItem>{correctItem, ...pickedItems};
    final unused = itemPool.where((item) => !choiceSet.contains(item)).toList();
    final needed = targetLength - choiceSet.length;
    if (needed > 0) {
      choiceSet.addAll(rng.pickUnique(unused, needed));
    }

    choices = rng.shuffle(choiceSet.toList());
  }

  @override
  void applyHint() {
    if (isPatternComplete) return;
    hintHighlightId = 'opt_${correctItem.id}';
    AudioService().playCue(SoundCue.hint);
    notifyListeners();
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;
    if (isPatternComplete) return;

    if (action.type == GameActionType.tap || action.type == GameActionType.select) {
      final target = action.targetId ?? '';
      if (!target.startsWith('opt_')) return;

      final itemId = target.replaceFirst('opt_', '');
      final tappedItem = choices.firstWhere(
        (c) => c.id == itemId,
        orElse: () => choices.first,
      );

      selectedChoice = tappedItem;
      playTapSound();

      if (tappedItem.id == correctItem.id) {
        // Correct match!
        isPatternComplete = true;
        wrongChoice = null;
        clearHint();
        AudioService().playCue(SoundCue.correct);
        recordCorrectAction(wasAssisted: hintHighlightId == 'opt_${correctItem.id}');
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 1400));

        if (currentRound + 1 >= totalRounds) {
          AudioService().playCue(SoundCue.complete);
          completeGame();
        } else {
          currentRound++;
          _setupRound();
          notifyListeners();
        }
      } else {
        // Wrong item
        wrongChoice = tappedItem;
        AudioService().playCue(SoundCue.wrong);
        recordIncorrectAction();
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (wrongChoice?.id == tappedItem.id) {
            wrongChoice = null;
            notifyListeners();
          }
        });
      }
    }
  }

  void nextLevel() {
    levelIndex++;
    currentRound = 0;
    _setupRound();
    resetToPlaying();
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'levelIndex': levelIndex,
      'currentRound': currentRound,
      'correct': correctItem.id,
      'isComplete': isPatternComplete,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      levelIndex = map['levelIndex'] as int? ?? 0;
      currentRound = map['currentRound'] as int? ?? 0;
      _setupRound();
    } catch (_) {
      _setupRound();
    }
  }
}
