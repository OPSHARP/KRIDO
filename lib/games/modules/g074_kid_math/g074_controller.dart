import 'dart:async';
import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

enum MathMode { counting, addition }

class MathQuestion {
  final MathMode mode;
  final int countA;
  final int countB;
  final int answer;
  final String itemEmoji;
  final String itemName;
  final List<int> options;

  const MathQuestion({
    required this.mode,
    required this.countA,
    required this.countB,
    required this.answer,
    required this.itemEmoji,
    required this.itemName,
    required this.options,
  });
}

class G074Controller extends GameController {
  static const List<Map<String, String>> itemPool = [
    {'emoji': '🍎', 'name': 'Apples'},
    {'emoji': '⭐', 'name': 'Stars'},
    {'emoji': '🍭', 'name': 'Candies'},
    {'emoji': '🎈', 'name': 'Balloons'},
    {'emoji': '🍓', 'name': 'Berries'},
    {'emoji': '🍪', 'name': 'Cookies'},
  ];

  int currentRound = 0;
  final int totalRounds;
  int levelIndex = 0;

  late MathQuestion currentQuestion;
  int? selectedOption;
  int? wrongOption;
  bool isRoundAnswered = false;

  G074Controller({
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
    isRoundAnswered = false;
    selectedOption = null;
    wrongOption = null;
    clearHint();

    final rng = SeededRng(seed + (levelIndex * 89) + (currentRound * 19));
    final item = rng.pickOne(itemPool);

    final mode = (challenge.tier == 1 || (challenge.tier == 2 && currentRound < 2))
        ? MathMode.counting
        : MathMode.addition;

    int countA;
    int countB = 0;
    int answer;

    if (mode == MathMode.counting) {
      countA = rng.nextInt(1, 5);
      answer = countA;
    } else {
      countA = rng.nextInt(1, 3);
      countB = rng.nextInt(1, 3);
      answer = countA + countB;
    }

    // Generate 4 unique options including answer safely
    final pool = [for (int i = 1; i <= 10; i++) if (i != answer) i];
    final distractors = rng.pickUnique(pool, 3);
    final options = rng.shuffle([answer, ...distractors]);

    currentQuestion = MathQuestion(
      mode: mode,
      countA: countA,
      countB: countB,
      answer: answer,
      itemEmoji: item['emoji']!,
      itemName: item['name']!,
      options: options,
    );
  }

  @override
  void applyHint() {
    if (isRoundAnswered) return;
    hintHighlightId = 'opt_${currentQuestion.answer}';
    AudioService().playCue(SoundCue.hint);
    notifyListeners();
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;
    if (isRoundAnswered) return;

    if (action.type == GameActionType.tap || action.type == GameActionType.select) {
      final target = action.targetId ?? '';
      if (!target.startsWith('opt_')) return;

      final chosen = int.tryParse(target.replaceFirst('opt_', ''));
      if (chosen == null) return;

      selectedOption = chosen;
      playTapSound();

      if (chosen == currentQuestion.answer) {
        // Correct answer!
        isRoundAnswered = true;
        wrongOption = null;
        clearHint();
        AudioService().playCue(SoundCue.correct);
        recordCorrectAction(wasAssisted: hintHighlightId == 'opt_$chosen');
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
        // Wrong answer
        wrongOption = chosen;
        AudioService().playCue(SoundCue.wrong);
        recordIncorrectAction();
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (wrongOption == chosen) {
            wrongOption = null;
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
      'mode': currentQuestion.mode.name,
      'answer': currentQuestion.answer,
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
