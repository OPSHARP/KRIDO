import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class SpacePlanet {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final String factEn;
  final String factHi;
  final int colorHex;
  bool isVisited;

  SpacePlanet({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.factEn,
    required this.factHi,
    required this.colorHex,
    this.isVisited = false,
  });
}

class SpaceQuestion {
  final String questionEn;
  final String questionHi;
  final List<String> optionsEn;
  final List<String> optionsHi;
  final int correctIndex;

  const SpaceQuestion({
    required this.questionEn,
    required this.questionHi,
    required this.optionsEn,
    required this.optionsHi,
    required this.correctIndex,
  });
}

class G086Controller extends GameController {
  List<SpacePlanet> planets = [];
  int currentPlanetIndex = 0;
  SpaceQuestion? currentQuestion;
  bool showingFact = false;
  bool showingQuestion = false;
  int? selectedOptionIndex;
  bool lastAnswerCorrect = false;

  static const List<SpaceQuestion> _allQuestions = [
    SpaceQuestion(
      questionEn: 'Which planet is closest to the Sun?',
      questionHi: 'सूर्य के सबसे करीब कौन सा ग्रह है?',
      optionsEn: ['Mercury', 'Venus', 'Earth', 'Mars'],
      optionsHi: ['बुध', 'शुक्र', 'पृथ्वी', 'मंगल'],
      correctIndex: 0,
    ),
    SpaceQuestion(
      questionEn: 'What color is Mars often called?',
      questionHi: 'मंगल ग्रह को किस रंग से जाना जाता है?',
      optionsEn: ['Blue', 'Green', 'Red', 'Yellow'],
      optionsHi: ['नीला', 'हरा', 'लाल', 'पीला'],
      correctIndex: 2,
    ),
    SpaceQuestion(
      questionEn: 'Which planet has beautiful rings?',
      questionHi: 'किस ग्रह के सुंदर छल्ले हैं?',
      optionsEn: ['Jupiter', 'Saturn', 'Neptune', 'Earth'],
      optionsHi: ['बृहस्पति', 'शनि', 'नेपच्यून', 'पृथ्वी'],
      correctIndex: 1,
    ),
    SpaceQuestion(
      questionEn: 'Where do we live?',
      questionHi: 'हम कहाँ रहते हैं?',
      optionsEn: ['Mars', 'Moon', 'Earth', 'Sun'],
      optionsHi: ['मंगल', 'चंद्रमा', 'पृथ्वी', 'सूरज'],
      correctIndex: 2,
    ),
    SpaceQuestion(
      questionEn: 'Which is the biggest planet?',
      questionHi: 'सबसे बड़ा ग्रह कौन सा है?',
      optionsEn: ['Earth', 'Saturn', 'Jupiter', 'Neptune'],
      optionsHi: ['पृथ्वी', 'शनि', 'बृहस्पति', 'नेपच्यून'],
      correctIndex: 2,
    ),
  ];

  G086Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  SpacePlanet get currentPlanet => planets[currentPlanetIndex];

  @override
  Future<void> initialize() async {
    planets = [
      SpacePlanet(id: 'mercury', nameEn: 'Mercury', nameHi: 'बुध', emoji: '☿️', factEn: 'Mercury is the smallest planet!', factHi: 'बुध सबसे छोटा ग्रह है!', colorHex: 0xFFB0BEC5),
      SpacePlanet(id: 'earth', nameEn: 'Earth', nameHi: 'पृथ्वी', emoji: '🌍', factEn: 'Earth has water and life!', factHi: 'पृथ्वी पर पानी और जीवन है!', colorHex: 0xFF4FC3F7),
      SpacePlanet(id: 'mars', nameEn: 'Mars', nameHi: 'मंगल', emoji: '🔴', factEn: 'Mars is called the Red Planet!', factHi: 'मंगल को लाल ग्रह कहते हैं!', colorHex: 0xFFEF5350),
      SpacePlanet(id: 'jupiter', nameEn: 'Jupiter', nameHi: 'बृहस्पति', emoji: '🪐', factEn: 'Jupiter is the biggest planet!', factHi: 'बृहस्पति सबसे बड़ा ग्रह है!', colorHex: 0xFFFFB74D),
      SpacePlanet(id: 'saturn', nameEn: 'Saturn', nameHi: 'शनि', emoji: '💫', factEn: 'Saturn has beautiful rings!', factHi: 'शनि के सुंदर छल्ले हैं!', colorHex: 0xFFFFD54F),
    ];

    await super.initialize();
  }

  void visitPlanet() {
    if (state != GameLifecycleState.playing) return;
    showingFact = true;
    playTapSound();
    notifyListeners();
  }

  void startQuestion() {
    showingFact = false;
    showingQuestion = true;
    selectedOptionIndex = null;
    lastAnswerCorrect = false;
    // Pick a relevant question
    currentQuestion = _allQuestions[currentPlanetIndex % _allQuestions.length];
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (state != GameLifecycleState.playing || selectedOptionIndex != null) return;

    assessedActions++;
    selectedOptionIndex = index;

    if (index == currentQuestion!.correctIndex) {
      lastAnswerCorrect = true;
      currentPlanet.isVisited = true;
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);
      AudioService().playCue(SoundCue.cheer);
    } else {
      lastAnswerCorrect = false;
      AudioService().playCue(SoundCue.wrong);
    }
    notifyListeners();
  }

  void nextPlanet() {
    showingQuestion = false;
    selectedOptionIndex = null;

    if (lastAnswerCorrect) {
      if (planets.every((p) => p.isVisited)) {
        completeGame();
        return;
      }
      currentPlanetIndex = planets.indexWhere((p) => !p.isVisited);
    }
    notifyListeners();
  }

  @override
  void applyHint() {
    if (showingQuestion && currentQuestion != null) {
      hintHighlightId = 'option_${currentQuestion!.correctIndex}';
    }
    notifyListeners();
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'visitedIds': planets.where((p) => p.isVisited).map((p) => p.id).toList(),
      'currentPlanetIndex': currentPlanetIndex,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['visitedIds'] as List?)?.cast<String>() ?? [];
      for (final p in planets) {
        if (list.contains(p.id)) p.isVisited = true;
      }
      currentPlanetIndex = (data['currentPlanetIndex'] as int?) ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
