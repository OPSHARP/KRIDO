import 'dart:async';
import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class AnimalQuizItem {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final String soundText;
  final int colorValue;

  const AnimalQuizItem({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.soundText,
    required this.colorValue,
  });
}

class G077Controller extends GameController {
  static const List<AnimalQuizItem> animalCatalog = [
    AnimalQuizItem(
      id: 'lion',
      nameEn: 'Lion',
      nameHi: 'शेर',
      emoji: '🦁',
      soundText: 'ROAAR!',
      colorValue: 0xFFFFA726,
    ),
    AnimalQuizItem(
      id: 'elephant',
      nameEn: 'Elephant',
      nameHi: 'हाथी',
      emoji: '🐘',
      soundText: 'PAWOOO!',
      colorValue: 0xFF90A4AE,
    ),
    AnimalQuizItem(
      id: 'giraffe',
      nameEn: 'Giraffe',
      nameHi: 'जिराफ़',
      emoji: '🦒',
      soundText: 'MUNCH!',
      colorValue: 0xFFFFCA28,
    ),
    AnimalQuizItem(
      id: 'monkey',
      nameEn: 'Monkey',
      nameHi: 'बंदर',
      emoji: '🐵',
      soundText: 'OOH-AAH!',
      colorValue: 0xFF8D6E63,
    ),
    AnimalQuizItem(
      id: 'panda',
      nameEn: 'Panda',
      nameHi: 'पांडा',
      emoji: '🐼',
      soundText: 'CRUNCH!',
      colorValue: 0xFF78909C,
    ),
    AnimalQuizItem(
      id: 'tiger',
      nameEn: 'Tiger',
      nameHi: 'बाघ',
      emoji: '🐯',
      soundText: 'GRRR!',
      colorValue: 0xFFFF7043,
    ),
    AnimalQuizItem(
      id: 'zebra',
      nameEn: 'Zebra',
      nameHi: 'ज़ेबरा',
      emoji: '🦓',
      soundText: 'WHINNY!',
      colorValue: 0xFF546E7A,
    ),
    AnimalQuizItem(
      id: 'dog',
      nameEn: 'Dog',
      nameHi: 'कुत्ता',
      emoji: '🐶',
      soundText: 'WOOF WOOF!',
      colorValue: 0xFFA1887F,
    ),
    AnimalQuizItem(
      id: 'cat',
      nameEn: 'Cat',
      nameHi: 'बिल्ली',
      emoji: '🐱',
      soundText: 'MEOW MEOW!',
      colorValue: 0xFFFF8A80,
    ),
    AnimalQuizItem(
      id: 'cow',
      nameEn: 'Cow',
      nameHi: 'गाय',
      emoji: '🐮',
      soundText: 'MOOO!',
      colorValue: 0xFF42A5F5,
    ),
    AnimalQuizItem(
      id: 'duck',
      nameEn: 'Duck',
      nameHi: 'बत्तख',
      emoji: '🦆',
      soundText: 'QUACK QUACK!',
      colorValue: 0xFFFFD54F,
    ),
    AnimalQuizItem(
      id: 'frog',
      nameEn: 'Frog',
      nameHi: 'मेंढक',
      emoji: '🐸',
      soundText: 'RIBBIT!',
      colorValue: 0xFF66BB6A,
    ),
    AnimalQuizItem(
      id: 'penguin',
      nameEn: 'Penguin',
      nameHi: 'पेंगुइन',
      emoji: '🐧',
      soundText: 'HONK!',
      colorValue: 0xFF26C6DA,
    ),
    AnimalQuizItem(
      id: 'bear',
      nameEn: 'Bear',
      nameHi: 'भालू',
      emoji: '🐻',
      soundText: 'GROWL!',
      colorValue: 0xFF6D4C41,
    ),
    AnimalQuizItem(
      id: 'rabbit',
      nameEn: 'Rabbit',
      nameHi: 'खरगोश',
      emoji: '🐰',
      soundText: 'HOP HOP!',
      colorValue: 0xFFF48FB1,
    ),
    AnimalQuizItem(
      id: 'dolphin',
      nameEn: 'Dolphin',
      nameHi: 'डॉल्फ़िन',
      emoji: '🐬',
      soundText: 'CLICK CLICK!',
      colorValue: 0xFF00E5FF,
    ),
  ];

  int currentRound = 0;
  final int totalRounds;
  int levelIndex = 0;

  late AnimalQuizItem targetAnimal;
  List<AnimalQuizItem> choices = [];

  AnimalQuizItem? selectedChoice;
  AnimalQuizItem? wrongChoice;
  bool isRoundCorrect = false;

  G077Controller({
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
    isRoundCorrect = false;
    selectedChoice = null;
    wrongChoice = null;
    clearHint();

    final rng = SeededRng(seed + (levelIndex * 53) + (currentRound * 31));

    // Pick 1 target animal and 3 distractors
    final picked = rng.pickUnique(animalCatalog, 4);
    targetAnimal = picked[0];
    choices = rng.shuffle(picked);
  }

  @override
  void applyHint() {
    if (isRoundCorrect) return;
    hintHighlightId = 'choice_${targetAnimal.id}';
    AudioService().playCue(SoundCue.hint);
    notifyListeners();
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;
    if (isRoundCorrect) return;

    if (action.type == GameActionType.tap || action.type == GameActionType.select) {
      final target = action.targetId ?? '';
      if (!target.startsWith('choice_')) return;

      final animalId = target.replaceFirst('choice_', '');
      final tapped = choices.firstWhere(
        (a) => a.id == animalId,
        orElse: () => choices.first,
      );

      selectedChoice = tapped;
      playTapSound();

      if (tapped.id == targetAnimal.id) {
        // Correct answer!
        isRoundCorrect = true;
        wrongChoice = null;
        clearHint();
        AudioService().playCue(SoundCue.correct);
        recordCorrectAction(wasAssisted: hintHighlightId == 'choice_${targetAnimal.id}');
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
        // Wrong answer: gentle shake and retry
        wrongChoice = tapped;
        AudioService().playCue(SoundCue.wrong);
        recordIncorrectAction();
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (wrongChoice?.id == tapped.id) {
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
      'target': targetAnimal.id,
      'isCorrect': isRoundCorrect,
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
