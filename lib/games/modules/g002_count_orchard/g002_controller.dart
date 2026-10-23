import 'dart:convert';
import 'dart:math';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class FruitKind {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final int primaryColorValue;
  final int secondaryColorValue;

  const FruitKind({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.primaryColorValue,
    required this.secondaryColorValue,
  });
}

class FruitInstance {
  final int id;
  final double normalizedX;
  final double normalizedY;
  final String emoji;
  final String fruitKindId;
  bool isCountTapped;

  FruitInstance({
    required this.id,
    required this.normalizedX,
    required this.normalizedY,
    required this.emoji,
    this.fruitKindId = 'apple',
    this.isCountTapped = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'x': normalizedX,
        'y': normalizedY,
        'emoji': emoji,
        'fruitKindId': fruitKindId,
        'isCountTapped': isCountTapped,
      };

  factory FruitInstance.fromMap(Map<String, dynamic> map) => FruitInstance(
        id: map['id'] as int,
        normalizedX: (map['x'] as num).toDouble(),
        normalizedY: (map['y'] as num).toDouble(),
        emoji: map['emoji'] as String? ?? '🍎',
        fruitKindId: map['fruitKindId'] as String? ?? 'apple',
        isCountTapped: map['isCountTapped'] as bool? ?? false,
      );
}

class G002Controller extends GameController {
  static const List<FruitKind> fruitKinds = [
    FruitKind(
      id: 'apple',
      nameEn: 'Apples',
      nameHi: 'सेब',
      emoji: '🍎',
      primaryColorValue: 0xFFFF1744,
      secondaryColorValue: 0xFFB71C1C,
    ),
    FruitKind(
      id: 'banana',
      nameEn: 'Bananas',
      nameHi: 'केले',
      emoji: '🍌',
      primaryColorValue: 0xFFFFD54F,
      secondaryColorValue: 0xFFF57F17,
    ),
    FruitKind(
      id: 'orange',
      nameEn: 'Oranges',
      nameHi: 'संतरे',
      emoji: '🍊',
      primaryColorValue: 0xFFFF9800,
      secondaryColorValue: 0xFFE65100,
    ),
    FruitKind(
      id: 'strawberry',
      nameEn: 'Strawberries',
      nameHi: 'स्ट्रॉबेरी',
      emoji: '🍓',
      primaryColorValue: 0xFFE91E63,
      secondaryColorValue: 0xFF880E4F,
    ),
    FruitKind(
      id: 'watermelon',
      nameEn: 'Watermelons',
      nameHi: 'तरबूज',
      emoji: '🍉',
      primaryColorValue: 0xFF43A047,
      secondaryColorValue: 0xFF1B5E20,
    ),
    FruitKind(
      id: 'grapes',
      nameEn: 'Grapes',
      nameHi: 'अंगूर',
      emoji: '🍇',
      primaryColorValue: 0xFF8E24AA,
      secondaryColorValue: 0xFF4A148C,
    ),
    FruitKind(
      id: 'mango',
      nameEn: 'Mangoes',
      nameHi: 'आम',
      emoji: '🥭',
      primaryColorValue: 0xFFFFB300,
      secondaryColorValue: 0xFFFF6F00,
    ),
    FruitKind(
      id: 'cherry',
      nameEn: 'Cherries',
      nameHi: 'चेरी',
      emoji: '🍒',
      primaryColorValue: 0xFFC2185B,
      secondaryColorValue: 0xFF880E4F,
    ),
  ];

  int levelIndex = 0;
  int currentFruitCount;
  FruitKind currentFruit = fruitKinds[0];
  List<FruitInstance> fruits = [];
  List<int> answerChoices = [];
  int? selectedAnswer;

  G002Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
    int? overrideFruitCount,
  })  : currentFruitCount = overrideFruitCount ??
            (challenge.taskData['fruitCount'] as int? ??
                (challenge.tier == 1 ? 4 : (challenge.tier == 2 ? 6 : 8))),
        super(
          challenge: challenge,
          profile: profile,
          seed: seed,
        );

  int get actualCount => fruits.length;

  String get questionEn => 'How many ${currentFruit.nameEn} are on the tree?';
  String get questionHi => 'पेड़ पर कितने ${currentFruit.nameHi} हैं?';
  String get titleEn => 'COUNT THE ${currentFruit.nameEn.toUpperCase()}!';
  String get titleHi => '${currentFruit.nameHi} गिनें!';
  String get tapHintEn => 'Tap ${currentFruit.nameEn.toLowerCase()} to count! 👆';
  String get tapHintHi => '${currentFruit.nameHi} को गिनने के लिए छुएं! 👆';

  @override
  Future<void> initialize() async {
    _generateOrchard();
    await super.initialize();
  }

  void _generateOrchard({FruitKind? specificFruit}) {
    fruits.clear();
    final rng = SeededRng(seed + (levelIndex * 47));
    if (specificFruit != null) {
      currentFruit = specificFruit;
    } else {
      currentFruit = fruitKinds[levelIndex % fruitKinds.length];
    }

    // Tree canopy bounds: normalized x between 0.18 and 0.82, y between 0.16 and 0.58
    for (int i = 0; i < currentFruitCount; i++) {
      final double angle = i * 2.399963229728653;
      final double r = 0.28 * sqrt((i + 0.6) / currentFruitCount);

      final double jitterX = (rng.nextDouble() - 0.5) * 0.05;
      final double jitterY = (rng.nextDouble() - 0.5) * 0.05;

      final double x = (0.5 + r * cos(angle) + jitterX).clamp(0.18, 0.82);
      final double y = (0.36 + r * sin(angle) * 0.70 + jitterY).clamp(0.16, 0.58);

      fruits.add(
        FruitInstance(
          id: i + 1,
          normalizedX: x,
          normalizedY: y,
          emoji: currentFruit.emoji,
          fruitKindId: currentFruit.id,
        ),
      );
    }

    // Generate 5 answer choices (user requested more numbers to select)
    final Set<int> choices = {actualCount};
    const choiceCount = 5;
    final deltas = [-4, -3, -2, -1, 1, 2, 3, 4];
    for (final delta in rng.shuffle(deltas)) {
      if (choices.length >= choiceCount) break;
      final cand = (actualCount + delta).clamp(1, 12);
      choices.add(cand);
    }
    while (choices.length < choiceCount) {
      final fallback = rng.nextInt(1, 10);
      choices.add(fallback);
    }

    answerChoices = rng.shuffle(choices.toList());
  }

  /// Automatically generates a brand-new orchard puzzle with fresh fruit counts and number options
  void generateNextOrchard() {
    levelIndex++;
    // Vary fruit counts nicely across levels (3 to 9 fruits)
    final levelCounts = [3, 5, 4, 6, 7, 5, 8, 9, 6, 10];
    currentFruitCount = levelCounts[levelIndex % levelCounts.length];
    selectedAnswer = null;
    clearHint();
    _generateOrchard();
    resetToPlaying();
  }

  /// Allows the child to switch to any fruit immediately
  void selectFruit(FruitKind fruit) {
    selectedAnswer = null;
    clearHint();
    _generateOrchard(specificFruit: fruit);
    resetToPlaying();
    notifyListeners();
  }

  @override
  void applyHint() {
    hintHighlightId = actualCount.toString();
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;

    if (action.type == GameActionType.tap || action.type == GameActionType.select) {
      playTapSound();
      final target = (action.payload ?? action.targetId ?? '').toString();

      if (target.startsWith('fruit_')) {
        // Tap-to-count feature: highlights fruit and speaks ordinal count without removing it
        final fruitId = int.tryParse(target.replaceFirst('fruit_', ''));
        if (fruitId != null) {
          final f = fruits.firstWhere((item) => item.id == fruitId);
          f.isCountTapped = true;
          notifyListeners();
        }
      } else {
        // Answer choice selected
        final answer = int.tryParse(target);
        if (answer == null) return;

        selectedAnswer = answer;
        if (answer == actualCount) {
          recordCorrectAction(wasAssisted: hintHighlightId == actualCount.toString());
          clearHint();
          notifyListeners();
          completeGame();
        } else {
          recordIncorrectAction();
          notifyListeners();
        }
      }
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'targetFruitCount': currentFruitCount,
      'fruits': fruits.map((f) => f.toMap()).toList(),
      'answerChoices': answerChoices,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      if (map['fruits'] != null) {
        fruits = (map['fruits'] as List)
            .map((f) => FruitInstance.fromMap(f as Map<String, dynamic>))
            .toList();
      }
      if (map['answerChoices'] != null) {
        answerChoices = List<int>.from(map['answerChoices'] as List);
      }
    } catch (_) {
      _generateOrchard();
    }
  }
}
