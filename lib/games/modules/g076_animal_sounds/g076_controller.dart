import 'dart:async';
import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class AnimalSoundItem {
  final String id;
  final String nameEn;
  final String nameHi;
  final String soundText;
  final String emoji;
  final int colorValue;

  const AnimalSoundItem({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.soundText,
    required this.emoji,
    required this.colorValue,
  });
}

class G076Controller extends GameController {
  static const List<AnimalSoundItem> animalBank = [
    AnimalSoundItem(
      id: 'cat',
      nameEn: 'Cat',
      nameHi: 'बिल्ली',
      soundText: 'MEOW MEOW!',
      emoji: '🐱',
      colorValue: 0xFFFF7043,
    ),
    AnimalSoundItem(
      id: 'dog',
      nameEn: 'Dog',
      nameHi: 'कुत्ता',
      soundText: 'WOOF WOOF!',
      emoji: '🐶',
      colorValue: 0xFF8D6E63,
    ),
    AnimalSoundItem(
      id: 'cow',
      nameEn: 'Cow',
      nameHi: 'गाय',
      soundText: 'MOOO MOOO!',
      emoji: '🐮',
      colorValue: 0xFF42A5F5,
    ),
    AnimalSoundItem(
      id: 'duck',
      nameEn: 'Duck',
      nameHi: 'बत्तख',
      soundText: 'QUACK QUACK!',
      emoji: '🦆',
      colorValue: 0xFFFFCA28,
    ),
    AnimalSoundItem(
      id: 'lion',
      nameEn: 'Lion',
      nameHi: 'शेर',
      soundText: 'ROAAR!',
      emoji: '🦁',
      colorValue: 0xFFFFA726,
    ),
    AnimalSoundItem(
      id: 'sheep',
      nameEn: 'Sheep',
      nameHi: 'भेड़',
      soundText: 'BAA BAA!',
      emoji: '🐑',
      colorValue: 0xFF78909C,
    ),
    AnimalSoundItem(
      id: 'frog',
      nameEn: 'Frog',
      nameHi: 'मेंढक',
      soundText: 'RIBBIT RIBBIT!',
      emoji: '🐸',
      colorValue: 0xFF66BB6A,
    ),
    AnimalSoundItem(
      id: 'monkey',
      nameEn: 'Monkey',
      nameHi: 'बंदर',
      soundText: 'OO OO AA AA!',
      emoji: '🐵',
      colorValue: 0xFF8D6E63,
    ),
    AnimalSoundItem(
      id: 'tiger',
      nameEn: 'Tiger',
      nameHi: 'बाघ',
      soundText: 'GRRR ROAR!',
      emoji: '🐯',
      colorValue: 0xFFFF9800,
    ),
    AnimalSoundItem(
      id: 'bear',
      nameEn: 'Bear',
      nameHi: 'भालू',
      soundText: 'GROWL GROWL!',
      emoji: '🐻',
      colorValue: 0xFF6D4C41,
    ),
    AnimalSoundItem(
      id: 'penguin',
      nameEn: 'Penguin',
      nameHi: 'पेंगुइन',
      soundText: 'HONK HONK!',
      emoji: '🐧',
      colorValue: 0xFF37474F,
    ),
    AnimalSoundItem(
      id: 'elephant',
      nameEn: 'Elephant',
      nameHi: 'हाथी',
      soundText: 'PAWOOO!',
      emoji: '🐘',
      colorValue: 0xFF90A4AE,
    ),
  ];

  int currentRound = 0;
  final int totalRounds;
  int levelIndex = 0;

  late AnimalSoundItem targetAnimal;
  List<AnimalSoundItem> choices = [];

  AnimalSoundItem? selectedAnimal;
  AnimalSoundItem? wrongAnimal;
  bool isRoundCorrect = false;

  G076Controller({
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
    selectedAnimal = null;
    wrongAnimal = null;
    clearHint();

    final rng = SeededRng(seed + (levelIndex * 61) + (currentRound * 29));

    // Pick target animal and 3 distractors
    final picked = rng.pickUnique(animalBank, 4);
    targetAnimal = picked[0];
    choices = rng.shuffle(picked);
  }

  @override
  void applyHint() {
    if (isRoundCorrect) return;
    hintHighlightId = 'animal_${targetAnimal.id}';
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
      if (!target.startsWith('animal_')) return;

      final animalId = target.replaceFirst('animal_', '');
      final tapped = choices.firstWhere(
        (a) => a.id == animalId,
        orElse: () => choices.first,
      );

      selectedAnimal = tapped;
      playTapSound();

      if (tapped.id == targetAnimal.id) {
        // Correct animal chosen!
        isRoundCorrect = true;
        wrongAnimal = null;
        clearHint();
        AudioService().playCue(SoundCue.correct);
        recordCorrectAction(wasAssisted: hintHighlightId == 'animal_${targetAnimal.id}');
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
        // Wrong animal
        wrongAnimal = tapped;
        AudioService().playCue(SoundCue.wrong);
        recordIncorrectAction();
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (wrongAnimal?.id == tapped.id) {
            wrongAnimal = null;
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
