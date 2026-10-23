import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class HabitatAnimal {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final String targetHabitatId;
  bool isMatched;

  HabitatAnimal({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.targetHabitatId,
    this.isMatched = false,
  });
}

class AnimalHabitat {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final int colorHex;

  const AnimalHabitat({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.colorHex,
  });
}

class G082Controller extends GameController {
  List<AnimalHabitat> habitats = [];
  List<HabitatAnimal> animals = [];
  HabitatAnimal? activeSelectedAnimal;

  G082Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  @override
  Future<void> initialize() async {
    habitats = [
      const AnimalHabitat(id: 'kennel', nameEn: 'Kennel', nameHi: 'कुत्ते का घर', emoji: '🏠', colorHex: 0xFFFFB74D),
      const AnimalHabitat(id: 'nest', nameEn: 'Tree Nest', nameHi: 'घोंसला', emoji: '🪺', colorHex: 0xFF81C784),
      const AnimalHabitat(id: 'cave', nameEn: 'Jungle Den', nameHi: 'गुफा', emoji: '🏕️', colorHex: 0xFFFF8A65),
      const AnimalHabitat(id: 'ocean', nameEn: 'Blue Ocean', nameHi: 'समुद्र', emoji: '🌊', colorHex: 0xFF4FC3F7),
    ];

    animals = [
      HabitatAnimal(id: 'dog', nameEn: 'Puppy', nameHi: 'पिल्ला', emoji: '🐶', targetHabitatId: 'kennel'),
      HabitatAnimal(id: 'bird', nameEn: 'Little Bird', nameHi: 'चिड़िया', emoji: '🐦', targetHabitatId: 'nest'),
      HabitatAnimal(id: 'lion', nameEn: 'Lion Cub', nameHi: 'शेर का बच्चा', emoji: '🦁', targetHabitatId: 'cave'),
      HabitatAnimal(id: 'fish', nameEn: 'Goldfish', nameHi: 'मछली', emoji: '🐠', targetHabitatId: 'ocean'),
    ];

    animals.shuffle(Random(seed));
    await super.initialize();
  }

  void selectAnimal(HabitatAnimal animal) {
    if (state != GameLifecycleState.playing || animal.isMatched) return;
    activeSelectedAnimal = animal;
    playTapSound();
    notifyListeners();
  }

  bool matchAnimalToHabitat(HabitatAnimal animal, AnimalHabitat habitat) {
    if (state != GameLifecycleState.playing) return false;

    assessedActions++;
    if (animal.targetHabitatId == habitat.id) {
      animal.isMatched = true;
      activeSelectedAnimal = null;
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);
      AudioService().playCue(SoundCue.cheer);

      if (animals.every((a) => a.isMatched)) {
        completeGame();
      } else {
        notifyListeners();
      }
      return true;
    } else {
      AudioService().playCue(SoundCue.wrong);
      notifyListeners();
      return false;
    }
  }

  @override
  void applyHint() {
    final unmatched = animals.where((a) => !a.isMatched).toList();
    if (unmatched.isNotEmpty) {
      activeSelectedAnimal = unmatched.first;
      hintHighlightId = unmatched.first.targetHabitatId;
      notifyListeners();
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'matchedIds': animals.where((a) => a.isMatched).map((a) => a.id).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['matchedIds'] as List?)?.cast<String>() ?? [];
      for (final a in animals) {
        if (list.contains(a.id)) a.isMatched = true;
      }
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
