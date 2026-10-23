import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class Emotion {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final String descEn;
  final String descHi;
  final int colorHex;

  const Emotion({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.descEn,
    required this.descHi,
    required this.colorHex,
  });
}

class EmotionScenario {
  final String scenarioEn;
  final String scenarioHi;
  final String correctEmotionId;
  bool isSolved;

  EmotionScenario({
    required this.scenarioEn,
    required this.scenarioHi,
    required this.correctEmotionId,
    this.isSolved = false,
  });
}

class G087Controller extends GameController {
  List<Emotion> emotions = [];
  List<EmotionScenario> scenarios = [];
  int currentScenarioIndex = 0;
  bool showingResult = false;
  bool lastAnswerCorrect = false;
  String? selectedEmotionId;

  G087Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  EmotionScenario get currentScenario => scenarios[currentScenarioIndex];

  @override
  Future<void> initialize() async {
    emotions = const [
      Emotion(id: 'happy', nameEn: 'Happy', nameHi: 'खुश', emoji: '😊', descEn: 'Feeling joyful', descHi: 'खुशी महसूस करना', colorHex: 0xFFFFC107),
      Emotion(id: 'sad', nameEn: 'Sad', nameHi: 'उदास', emoji: '😢', descEn: 'Feeling down', descHi: 'उदासी', colorHex: 0xFF42A5F5),
      Emotion(id: 'angry', nameEn: 'Angry', nameHi: 'गुस्सा', emoji: '😠', descEn: 'Feeling mad', descHi: 'गुस्सा', colorHex: 0xFFEF5350),
      Emotion(id: 'scared', nameEn: 'Scared', nameHi: 'डर', emoji: '😨', descEn: 'Feeling afraid', descHi: 'डर लगना', colorHex: 0xFF7E57C2),
      Emotion(id: 'surprised', nameEn: 'Surprised', nameHi: 'हैरान', emoji: '😲', descEn: 'Feeling amazed', descHi: 'हैरानी', colorHex: 0xFFFF7043),
      Emotion(id: 'love', nameEn: 'Loving', nameHi: 'प्यार', emoji: '🥰', descEn: 'Feeling loved', descHi: 'प्यार महसूस करना', colorHex: 0xFFEC407A),
    ];

    scenarios = [
      EmotionScenario(scenarioEn: '🎂 Your friend gave you a birthday cake!', scenarioHi: '🎂 दोस्त ने जन्मदिन का केक दिया!', correctEmotionId: 'happy'),
      EmotionScenario(scenarioEn: '🧸 You lost your favorite toy.', scenarioHi: '🧸 तुम्हारा पसंदीदा खिलौना खो गया।', correctEmotionId: 'sad'),
      EmotionScenario(scenarioEn: '😡 Someone broke your crayon on purpose!', scenarioHi: '😡 किसी ने जानबूझकर तुम्हारी क्रेयॉन तोड़ दी!', correctEmotionId: 'angry'),
      EmotionScenario(scenarioEn: '👻 You heard a strange noise at night.', scenarioHi: '👻 रात को अजीब आवाज आई।', correctEmotionId: 'scared'),
      EmotionScenario(scenarioEn: '🎁 You got an unexpected gift!', scenarioHi: '🎁 अचानक एक तोहफा मिला!', correctEmotionId: 'surprised'),
      EmotionScenario(scenarioEn: '🤗 Grandma gave you a big warm hug!', scenarioHi: '🤗 दादी ने गले लगाया!', correctEmotionId: 'love'),
      EmotionScenario(scenarioEn: '🎈 You won a prize at the fair!', scenarioHi: '🎈 मेले में इनाम जीता!', correctEmotionId: 'happy'),
      EmotionScenario(scenarioEn: '🐶 Your pet ran away from home.', scenarioHi: '🐶 तुम्हारा पालतू भाग गया।', correctEmotionId: 'sad'),
    ];

    scenarios.shuffle(Random(seed));
    await super.initialize();
  }

  void selectEmotion(String emotionId) {
    if (state != GameLifecycleState.playing || showingResult) return;

    assessedActions++;
    selectedEmotionId = emotionId;
    showingResult = true;

    if (emotionId == currentScenario.correctEmotionId) {
      lastAnswerCorrect = true;
      currentScenario.isSolved = true;
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);
      AudioService().playCue(SoundCue.cheer);
    } else {
      lastAnswerCorrect = false;
      AudioService().playCue(SoundCue.wrong);
    }
    notifyListeners();
  }

  void nextScenario() {
    showingResult = false;
    selectedEmotionId = null;

    if (lastAnswerCorrect) {
      final remaining = scenarios.where((s) => !s.isSolved).toList();
      if (remaining.isEmpty) {
        completeGame();
        return;
      }
      currentScenarioIndex = scenarios.indexOf(remaining.first);
    }
    notifyListeners();
  }

  @override
  void applyHint() {
    hintHighlightId = currentScenario.correctEmotionId;
    notifyListeners();
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'solvedIndices': scenarios.asMap().entries.where((e) => e.value.isSolved).map((e) => e.key).toList(),
      'currentScenarioIndex': currentScenarioIndex,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['solvedIndices'] as List?)?.cast<int>() ?? [];
      for (final i in list) {
        if (i < scenarios.length) scenarios[i].isSolved = true;
      }
      currentScenarioIndex = (data['currentScenarioIndex'] as int?) ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
