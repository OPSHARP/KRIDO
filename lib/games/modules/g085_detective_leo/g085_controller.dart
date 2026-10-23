import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class Clue {
  final String textEn;
  final String textHi;
  final String correctAnswerId;
  bool isSolved;

  Clue({
    required this.textEn,
    required this.textHi,
    required this.correctAnswerId,
    this.isSolved = false,
  });
}

class Suspect {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final String descEn;
  final String descHi;

  const Suspect({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.descEn,
    required this.descHi,
  });
}

class DetectiveCase {
  final String id;
  final String titleEn;
  final String titleHi;
  final String storyEn;
  final String storyHi;
  final List<Clue> clues;
  final List<Suspect> suspects;
  final String culpritId;
  bool isSolved;

  DetectiveCase({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    required this.storyEn,
    required this.storyHi,
    required this.clues,
    required this.suspects,
    required this.culpritId,
    this.isSolved = false,
  });
}

class G085Controller extends GameController {
  List<DetectiveCase> cases = [];
  int currentCaseIndex = 0;
  int currentClueIndex = 0;
  bool showingStory = true;
  bool showingResult = false;
  bool lastGuessCorrect = false;
  List<String> revealedClues = [];

  G085Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  DetectiveCase get currentCase => cases[currentCaseIndex];

  @override
  Future<void> initialize() async {
    cases = [
      DetectiveCase(
        id: 'case_cookie',
        titleEn: 'The Missing Cookie',
        titleHi: 'गायब कुकी',
        storyEn: 'Someone ate the last cookie from the jar! Help Detective Leo find who did it.',
        storyHi: 'किसी ने जार से आखिरी कुकी खा ली! जासूस लियो की मदद करो।',
        clues: [
          Clue(textEn: '🐾 Paw prints near the cookie jar', textHi: '🐾 जार के पास पंजों के निशान', correctAnswerId: 'cat'),
          Clue(textEn: '🍫 Chocolate crumbs on the floor', textHi: '🍫 फर्श पर चॉकलेट के टुकड़े', correctAnswerId: 'cat'),
          Clue(textEn: '😺 Whiskers with crumbs', textHi: '😺 टुकड़ों वाली मूंछें', correctAnswerId: 'cat'),
        ],
        suspects: [
          const Suspect(id: 'cat', nameEn: 'Kitty Cat', nameHi: 'बिल्ली', emoji: '🐱', descEn: 'Loves cookies', descHi: 'कुकी पसंद'),
          const Suspect(id: 'dog', nameEn: 'Buddy Dog', nameHi: 'कुत्ता', emoji: '🐶', descEn: 'Prefers bones', descHi: 'हड्डी पसंद'),
          const Suspect(id: 'bird', nameEn: 'Tweet Bird', nameHi: 'चिड़िया', emoji: '🐦', descEn: 'Eats seeds', descHi: 'बीज खाती है'),
        ],
        culpritId: 'cat',
      ),
      DetectiveCase(
        id: 'case_crayon',
        titleEn: 'The Crayon Mystery',
        titleHi: 'क्रेयॉन रहस्य',
        storyEn: 'Someone drew on the wall! Find who used the crayons.',
        storyHi: 'किसी ने दीवार पर चित्र बनाया! पता लगाओ किसने।',
        clues: [
          Clue(textEn: '🎨 Rainbow colored fingers spotted', textHi: '🎨 इंद्रधनुषी रंग वाली उंगलियां', correctAnswerId: 'monkey'),
          Clue(textEn: '🍌 Banana peels near the wall', textHi: '🍌 दीवार के पास केले के छिलके', correctAnswerId: 'monkey'),
          Clue(textEn: '🐒 Small footprints going up', textHi: '🐒 ऊपर जाते छोटे पैर', correctAnswerId: 'monkey'),
        ],
        suspects: [
          const Suspect(id: 'monkey', nameEn: 'Milo Monkey', nameHi: 'बंदर', emoji: '🐵', descEn: 'Loves art', descHi: 'कला पसंद'),
          const Suspect(id: 'rabbit', nameEn: 'Ruby Rabbit', nameHi: 'खरगोश', emoji: '🐰', descEn: 'Likes carrots', descHi: 'गाजर पसंद'),
          const Suspect(id: 'bear', nameEn: 'Benny Bear', nameHi: 'भालू', emoji: '🐻', descEn: 'Likes honey', descHi: 'शहद पसंद'),
        ],
        culpritId: 'monkey',
      ),
      DetectiveCase(
        id: 'case_flower',
        titleEn: 'The Garden Flower Thief',
        titleHi: 'बगीचे का फूल चोर',
        storyEn: 'The prettiest flower in the garden has vanished! Who took it?',
        storyHi: 'बगीचे का सबसे सुंदर फूल गायब है! किसने लिया?',
        clues: [
          Clue(textEn: '🌸 Petals found in a burrow', textHi: '🌸 बिल में पंखुड़ियां मिलीं', correctAnswerId: 'bunny'),
          Clue(textEn: '🥕 Carrot tops left behind', textHi: '🥕 गाजर के डंठल पड़े हैं', correctAnswerId: 'bunny'),
          Clue(textEn: '🐾 Soft fur on a thorn', textHi: '🐾 कांटे पर नरम फर', correctAnswerId: 'bunny'),
        ],
        suspects: [
          const Suspect(id: 'bunny', nameEn: 'Bella Bunny', nameHi: 'खरगोश', emoji: '🐰', descEn: 'Loves flowers', descHi: 'फूल पसंद'),
          const Suspect(id: 'snail', nameEn: 'Sam Snail', nameHi: 'घोंघा', emoji: '🐌', descEn: 'Eats leaves', descHi: 'पत्ते खाता है'),
          const Suspect(id: 'bee', nameEn: 'Buzz Bee', nameHi: 'मधुमक्खी', emoji: '🐝', descEn: 'Collects pollen', descHi: 'पराग इकट्ठा करती है'),
        ],
        culpritId: 'bunny',
      ),
    ];

    cases.shuffle(Random(seed));
    await super.initialize();
  }

  void dismissStory() {
    showingStory = false;
    notifyListeners();
  }

  void revealNextClue() {
    if (state != GameLifecycleState.playing) return;
    final clues = currentCase.clues;
    if (revealedClues.length < clues.length) {
      revealedClues.add(clues[revealedClues.length].textEn);
      playTapSound();
      notifyListeners();
    }
  }

  void accuseSuspect(String suspectId) {
    if (state != GameLifecycleState.playing) return;

    assessedActions++;
    showingResult = true;

    if (suspectId == currentCase.culpritId) {
      lastGuessCorrect = true;
      currentCase.isSolved = true;
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);
      AudioService().playCue(SoundCue.cheer);
    } else {
      lastGuessCorrect = false;
      AudioService().playCue(SoundCue.wrong);
    }
    notifyListeners();
  }

  void nextCase() {
    showingResult = false;
    revealedClues.clear();
    showingStory = true;

    if (lastGuessCorrect) {
      if (cases.every((c) => c.isSolved)) {
        completeGame();
        return;
      }
      currentCaseIndex = cases.indexWhere((c) => !c.isSolved);
    }
    notifyListeners();
  }

  @override
  void applyHint() {
    hintHighlightId = currentCase.culpritId;
    // Also reveal all clues
    revealedClues = currentCase.clues.map((c) => c.textEn).toList();
    notifyListeners();
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'solvedCaseIds': cases.where((c) => c.isSolved).map((c) => c.id).toList(),
      'currentCaseIndex': currentCaseIndex,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['solvedCaseIds'] as List?)?.cast<String>() ?? [];
      for (final c in cases) {
        if (list.contains(c.id)) c.isSolved = true;
      }
      currentCaseIndex = (data['currentCaseIndex'] as int?) ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
