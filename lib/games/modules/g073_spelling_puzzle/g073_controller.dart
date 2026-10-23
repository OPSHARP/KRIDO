import 'dart:async';
import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class SpellingWord {
  final String word;
  final String emoji;
  final String hindiWord;
  final String category;

  const SpellingWord({
    required this.word,
    required this.emoji,
    required this.hindiWord,
    required this.category,
  });
}

class G073Controller extends GameController {
  static const List<SpellingWord> wordBank = [
    SpellingWord(word: 'CAT', emoji: '🐱', hindiWord: 'बिल्ली', category: 'Animals'),
    SpellingWord(word: 'DOG', emoji: '🐶', hindiWord: 'कुत्ता', category: 'Animals'),
    SpellingWord(word: 'BAT', emoji: '🦇', hindiWord: 'चमगादड़', category: 'Animals'),
    SpellingWord(word: 'COW', emoji: '🐮', hindiWord: 'गाय', category: 'Animals'),
    SpellingWord(word: 'PIG', emoji: '🐷', hindiWord: 'सुअर', category: 'Animals'),
    SpellingWord(word: 'FOX', emoji: '🦊', hindiWord: 'लोमड़ी', category: 'Animals'),
    SpellingWord(word: 'BEE', emoji: '🐝', hindiWord: 'मधुमक्खी', category: 'Animals'),
    SpellingWord(word: 'SUN', emoji: '☀️', hindiWord: 'सूरज', category: 'Nature'),
    SpellingWord(word: 'BUS', emoji: '🚌', hindiWord: 'बस', category: 'Vehicles'),
    SpellingWord(word: 'CAR', emoji: '🚗', hindiWord: 'गाड़ी', category: 'Vehicles'),
    SpellingWord(word: 'CUP', emoji: '☕', hindiWord: 'कप', category: 'Objects'),
    SpellingWord(word: 'HAT', emoji: '🎩', hindiWord: 'टोपी', category: 'Objects'),
    SpellingWord(word: 'BED', emoji: '🛏️', hindiWord: 'बिस्तर', category: 'Objects'),
    SpellingWord(word: 'BOX', emoji: '📦', hindiWord: 'डिब्बा', category: 'Objects'),
    SpellingWord(word: 'FISH', emoji: '🐟', hindiWord: 'मछली', category: 'Animals'),
    SpellingWord(word: 'DUCK', emoji: '🦆', hindiWord: 'बत्तख', category: 'Animals'),
    SpellingWord(word: 'LION', emoji: '🦁', hindiWord: 'शेर', category: 'Animals'),
    SpellingWord(word: 'BEAR', emoji: '🐻', hindiWord: 'भालू', category: 'Animals'),
    SpellingWord(word: 'FROG', emoji: '🐸', hindiWord: 'मेंढक', category: 'Animals'),
    SpellingWord(word: 'STAR', emoji: '⭐', hindiWord: 'तारा', category: 'Nature'),
    SpellingWord(word: 'MOON', emoji: '🌙', hindiWord: 'चाँद', category: 'Nature'),
    SpellingWord(word: 'BOOK', emoji: '📖', hindiWord: 'किताब', category: 'Objects'),
    SpellingWord(word: 'BALL', emoji: '⚽', hindiWord: 'गेंद', category: 'Toys'),
    SpellingWord(word: 'MILK', emoji: '🥛', hindiWord: 'दूध', category: 'Food'),
    SpellingWord(word: 'APPLE', emoji: '🍎', hindiWord: 'सेब', category: 'Food'),
  ];

  int currentRound = 0;
  final int totalRounds = 5;
  int levelIndex = 0;

  late SpellingWord currentWord;
  List<String> scrambledLetters = [];
  List<int> selectedTileIndices = [];
  int? lastWrongTileIndex;
  bool isWordSolved = false;

  G073Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  }) : super(challenge: challenge, profile: profile, seed: seed);

  String get targetWord => currentWord.word;
  String get targetEmoji => currentWord.emoji;
  String get targetHindi => currentWord.hindiWord;

  String get currentSpelledWord {
    return selectedTileIndices.map((i) => scrambledLetters[i]).join();
  }

  @override
  Future<void> initialize() async {
    _setupRound();
    await super.initialize();
  }

  void _setupRound() {
    isWordSolved = false;
    selectedTileIndices.clear();
    lastWrongTileIndex = null;
    clearHint();

    final rng = SeededRng(seed + (levelIndex * 97) + (currentRound * 17));

    // Filter by tier: Tier 1 -> 3 letter words; Tier 2 -> 3-4 letters; Tier 3 -> 4-5 letters
    List<SpellingWord> candidates;
    if (challenge.tier == 1) {
      candidates = wordBank.where((w) => w.word.length == 3).toList();
    } else if (challenge.tier == 2) {
      candidates = wordBank.where((w) => w.word.length <= 4).toList();
    } else {
      candidates = wordBank;
    }

    if (candidates.isEmpty) candidates = wordBank;
    currentWord = rng.pickOne(candidates);

    // Scramble letters
    final letters = currentWord.word.split('');
    scrambledLetters = rng.shuffle(List.from(letters));

    // Ensure scrambled letters are not already in correct order if word length > 2
    if (scrambledLetters.join() == currentWord.word && scrambledLetters.length > 2) {
      final temp = scrambledLetters[0];
      scrambledLetters[0] = scrambledLetters[1];
      scrambledLetters[1] = temp;
    }
  }

  @override
  void applyHint() {
    if (isWordSolved) return;
    final nextCharIndex = selectedTileIndices.length;
    if (nextCharIndex >= targetWord.length) return;

    final neededLetter = targetWord[nextCharIndex];
    // Find first unselected tile with this letter
    for (int i = 0; i < scrambledLetters.length; i++) {
      if (!selectedTileIndices.contains(i) && scrambledLetters[i] == neededLetter) {
        hintHighlightId = 'tile_$i';
        AudioService().playCue(SoundCue.hint);
        notifyListeners();
        break;
      }
    }
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;
    if (isWordSolved) return;

    if (action.type == GameActionType.tap || action.type == GameActionType.select) {
      final target = action.targetId ?? '';
      if (!target.startsWith('tile_')) return;

      final tileIndex = int.tryParse(target.replaceFirst('tile_', ''));
      if (tileIndex == null || tileIndex < 0 || tileIndex >= scrambledLetters.length) return;

      // Already selected
      if (selectedTileIndices.contains(tileIndex)) return;

      final tappedLetter = scrambledLetters[tileIndex];
      playTapSound();
      final nextExpectedIndex = selectedTileIndices.length;
      final expectedLetter = targetWord[nextExpectedIndex];

      if (tappedLetter == expectedLetter) {
        // Correct letter tapped!
        selectedTileIndices.add(tileIndex);
        lastWrongTileIndex = null;
        clearHint();
        AudioService().playCue(SoundCue.match);
        recordCorrectAction(wasAssisted: hintHighlightId == 'tile_$tileIndex');
        notifyListeners();

        // Check if word is complete
        if (selectedTileIndices.length == targetWord.length) {
          isWordSolved = true;
          AudioService().playCue(SoundCue.correct);
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
        }
      } else {
        // Wrong letter
        lastWrongTileIndex = tileIndex;
        AudioService().playCue(SoundCue.wrong);
        recordIncorrectAction();
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 400), () {
          if (lastWrongTileIndex == tileIndex) {
            lastWrongTileIndex = null;
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
      'currentWord': currentWord.word,
      'scrambled': scrambledLetters,
      'selected': selectedTileIndices,
      'solved': isWordSolved,
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
