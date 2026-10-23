import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class BalloonItem {
  final String id;
  final String emoji;
  final int colorHex;
  final int value; // number shown on balloon
  bool isPopped;

  BalloonItem({
    required this.id,
    required this.emoji,
    required this.colorHex,
    required this.value,
    this.isPopped = false,
  });
}

class BalloonRound {
  final int targetNumber;
  final List<BalloonItem> balloons;
  bool isComplete;

  BalloonRound({
    required this.targetNumber,
    required this.balloons,
    this.isComplete = false,
  });
}

class G089Controller extends GameController {
  List<BalloonRound> rounds = [];
  int currentRoundIndex = 0;
  int score = 0;
  bool showingResult = false;
  bool lastPopCorrect = false;

  G089Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  BalloonRound get currentRound => rounds[currentRoundIndex];

  @override
  Future<void> initialize() async {
    final rng = Random(seed);
    final balloonEmojis = ['🎈', '🎈', '🎈', '🎈', '🎈'];
    final colors = [0xFFEF5350, 0xFF42A5F5, 0xFF66BB6A, 0xFFFFC107, 0xFFAB47BC, 0xFFFF7043];

    for (int round = 0; round < 5; round++) {
      final target = rng.nextInt(8) + 2; // target 2-9
      final balloons = <BalloonItem>[];

      // Add correct balloon
      balloons.add(BalloonItem(
        id: 'b_${round}_correct',
        emoji: balloonEmojis[round % balloonEmojis.length],
        colorHex: colors[rng.nextInt(colors.length)],
        value: target,
      ));

      // Add distractors
      final usedValues = {target};
      for (int i = 0; i < 4; i++) {
        int val;
        do {
          val = rng.nextInt(9) + 1;
        } while (usedValues.contains(val));
        usedValues.add(val);
        balloons.add(BalloonItem(
          id: 'b_${round}_$i',
          emoji: balloonEmojis[i % balloonEmojis.length],
          colorHex: colors[rng.nextInt(colors.length)],
          value: val,
        ));
      }

      balloons.shuffle(rng);
      rounds.add(BalloonRound(targetNumber: target, balloons: balloons));
    }

    await super.initialize();
  }

  void popBalloon(String balloonId) {
    if (state != GameLifecycleState.playing || showingResult) return;

    final balloon = currentRound.balloons.firstWhere((b) => b.id == balloonId);
    if (balloon.isPopped) return;

    assessedActions++;

    if (balloon.value == currentRound.targetNumber) {
      balloon.isPopped = true;
      lastPopCorrect = true;
      currentRound.isComplete = true;
      score += 10;
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);
      AudioService().playCue(SoundCue.cheer);
    } else {
      balloon.isPopped = true;
      lastPopCorrect = false;
      AudioService().playCue(SoundCue.wrong);
    }

    showingResult = true;
    notifyListeners();
  }

  void nextRound() {
    showingResult = false;

    if (lastPopCorrect) {
      if (rounds.every((r) => r.isComplete)) {
        completeGame();
        return;
      }
      currentRoundIndex = rounds.indexWhere((r) => !r.isComplete);
    }
    notifyListeners();
  }

  @override
  void applyHint() {
    final correct = currentRound.balloons.firstWhere(
      (b) => b.value == currentRound.targetNumber && !b.isPopped,
      orElse: () => currentRound.balloons.first,
    );
    hintHighlightId = correct.id;
    notifyListeners();
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'completedRounds': rounds.asMap().entries.where((e) => e.value.isComplete).map((e) => e.key).toList(),
      'currentRoundIndex': currentRoundIndex,
      'score': score,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['completedRounds'] as List?)?.cast<int>() ?? [];
      for (final i in list) {
        if (i < rounds.length) rounds[i].isComplete = true;
      }
      currentRoundIndex = (data['currentRoundIndex'] as int?) ?? 0;
      score = (data['score'] as int?) ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
