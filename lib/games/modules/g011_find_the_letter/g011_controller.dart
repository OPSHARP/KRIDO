import 'dart:convert';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class PhonicsInfo {
  final String letter;
  final String wordEn;
  final String wordHi;
  final String emoji;

  const PhonicsInfo(this.letter, this.wordEn, this.wordHi, this.emoji);
}

final Map<String, PhonicsInfo> phonicsData = {
  'A': const PhonicsInfo('A', 'Apple', 'सेब', '🍎'),
  'B': const PhonicsInfo('B', 'Butterfly', 'तितली', '🦋'),
  'C': const PhonicsInfo('C', 'Cat', 'बिल्ली', '🐱'),
  'D': const PhonicsInfo('D', 'Dog', 'कुत्ता', '🐶'),
  'E': const PhonicsInfo('E', 'Elephant', 'हाथी', '🐘'),
  'F': const PhonicsInfo('F', 'Fish', 'मछली', '🐟'),
  'G': const PhonicsInfo('G', 'Giraffe', 'जिराफ़', '🦒'),
  'H': const PhonicsInfo('H', 'Horse', 'घोड़ा', '🐴'),
  'I': const PhonicsInfo('I', 'Ice Cream', 'आइसक्रीम', '🍦'),
  'J': const PhonicsInfo('J', 'Jellyfish', 'जेलीफ़िश', '🪼'),
  'K': const PhonicsInfo('K', 'Kangaroo', 'कंगारू', '🦘'),
  'L': const PhonicsInfo('L', 'Lion', 'शेर', '🦁'),
  'M': const PhonicsInfo('M', 'Monkey', 'बंदर', '🐵'),
  'N': const PhonicsInfo('N', 'Nest', 'घोंसला', '🪺'),
  'O': const PhonicsInfo('O', 'Owl', 'उल्लू', '🦉'),
  'P': const PhonicsInfo('P', 'Panda', 'पांडा', '🐼'),
  'Q': const PhonicsInfo('Q', 'Queen', 'रानी', '👑'),
  'R': const PhonicsInfo('R', 'Rabbit', 'खरगोश', '🐰'),
  'S': const PhonicsInfo('S', 'Sun', 'सूरज', '☀️'),
  'T': const PhonicsInfo('T', 'Tiger', 'बाघ', '🐯'),
  'U': const PhonicsInfo('U', 'Umbrella', 'छाता', '☂️'),
  'V': const PhonicsInfo('V', 'Violin', 'वायलिन', '🎻'),
  'W': const PhonicsInfo('W', 'Watermelon', 'तरबूज', '🍉'),
  'X': const PhonicsInfo('X', 'Xylophone', 'ज़ाइलोफ़ोन', '🎵'),
  'Y': const PhonicsInfo('Y', 'Yacht', 'नाव', '⛵'),
  'Z': const PhonicsInfo('Z', 'Zebra', 'ज़ेब्रा', '🦓'),
  'अ': const PhonicsInfo('अ', 'अनार', 'अनार', '🍎'),
  'आ': const PhonicsInfo('आ', 'आम', 'आम', '🥭'),
  'इ': const PhonicsInfo('इ', 'इमली', 'इमली', '🫒'),
  'ई': const PhonicsInfo('ई', 'ईख', 'ईख', '🎋'),
  'उ': const PhonicsInfo('उ', 'उल्लू', 'उल्लू', '🦉'),
  'क': const PhonicsInfo('क', 'कमल', 'कमल', '🪷'),
  'ख': const PhonicsInfo('ख', 'खरगोश', 'खरगोश', '🐰'),
  'ग': const PhonicsInfo('ग', 'गमला', 'गमला', '🪴'),
  'घ': const PhonicsInfo('घ', 'घर', 'घर', '🏡'),
  'म': const PhonicsInfo('म', 'मछली', 'मछली', '🐟'),
  'त': const PhonicsInfo('त', 'तोता', 'तोता', '🦜'),
  'प': const PhonicsInfo('प', 'पतंग', 'पतंग', '🪁'),
};

class LetterRound {
  final String targetGlyph;
  final List<String> choices;
  final int correctIndex;

  LetterRound({
    required this.targetGlyph,
    required this.choices,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() => {
        'targetGlyph': targetGlyph,
        'choices': choices,
        'correctIndex': correctIndex,
      };

  factory LetterRound.fromMap(Map<String, dynamic> map) => LetterRound(
        targetGlyph: map['targetGlyph'] as String,
        choices: List<String>.from(map['choices'] as List),
        correctIndex: map['correctIndex'] as int,
      );
}

class G011Controller extends GameController {
  final int totalRounds;
  int currentRoundIndex = 0;
  int levelIndex = 0;
  List<LetterRound> rounds = [];
  String? selectedChoice;

  G011Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
    this.totalRounds = 5,
  }) : super(
          challenge: challenge,
          profile: profile,
          seed: seed,
        );

  LetterRound get currentRound => rounds[currentRoundIndex];

  List<String> get fullAlphabet => profile.uiLocale == 'hi'
      ? ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ', 'क', 'ख', 'ग', 'घ', 'च', 'छ', 'ज', 'ट', 'त', 'प', 'म', 'य', 'र', 'ल', 'व', 'श', 'स', 'ह']
      : ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  PhonicsInfo get currentPhonics =>
      phonicsData[currentRound.targetGlyph] ??
      PhonicsInfo(currentRound.targetGlyph, 'Magic Star', 'जादूई तारा', '⭐');

  PhonicsInfo getPhonics(String letter) =>
      phonicsData[letter] ?? PhonicsInfo(letter, 'Magic Star', 'जादूई तारा', '⭐');

  @override
  Future<void> initialize() async {
    _generateRounds();
    await super.initialize();
  }

  void _generateRounds() {
    rounds.clear();
    final rng = SeededRng(seed + (levelIndex * 29));
    final isHindi = profile.uiLocale == 'hi';

    final List<String> alphabet = isHindi
        ? ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ', 'क', 'ख', 'ग', 'घ', 'च', 'छ', 'ज', 'ट', 'त', 'प', 'म', 'य', 'र', 'ल', 'व', 'श', 'स', 'ह']
        : ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

    final int choiceCount = challenge.tier == 1 ? 2 : (challenge.tier == 2 ? 3 : 4);

    // If English Level 1, ensure 'B' is the 1st target to fulfill "Find the B!"
    final List<String> selectedTargets = [];
    if (!isHindi && levelIndex == 0) {
      selectedTargets.add('B');
      final remaining = alphabet.where((l) => l != 'B').toList();
      selectedTargets.addAll(rng.pickUnique(remaining, totalRounds - 1));
    } else {
      selectedTargets.addAll(rng.pickUnique(alphabet, totalRounds));
    }

    for (final target in selectedTargets) {
      final otherLetters = alphabet.where((l) => l != target).toList();
      final distractors = rng.pickUnique(otherLetters, choiceCount - 1);
      final allChoices = rng.shuffle([target, ...distractors]);
      final correctIdx = allChoices.indexOf(target);

      rounds.add(
        LetterRound(
          targetGlyph: target,
          choices: allChoices,
          correctIndex: correctIdx,
        ),
      );
    }
  }

  /// Endless Auto-Generation: Advances to the next fresh letter hunt level!
  void generateNextLevel() {
    levelIndex++;
    currentRoundIndex = 0;
    selectedChoice = null;
    clearHint();
    _generateRounds();
    resetToPlaying();
  }

  @override
  void applyHint() {
    hintHighlightId = currentRound.targetGlyph;
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;

    if (action.type == GameActionType.select || action.type == GameActionType.tap) {
      final choice = (action.payload ?? action.targetId) as String?;
      if (choice == null) return;

      selectedChoice = choice;
      final isCorrect = choice == currentRound.targetGlyph;

      if (isCorrect) {
        recordCorrectAction(wasAssisted: hintHighlightId == currentRound.targetGlyph);
        clearHint();
        notifyListeners();

        // Brief delay for positive visual feedback before next round
        await Future.delayed(const Duration(milliseconds: 650));
        selectedChoice = null;

        if (currentRoundIndex < totalRounds - 1) {
          currentRoundIndex++;
          notifyListeners();
        } else {
          completeGame();
        }
      } else {
        recordIncorrectAction();
        notifyListeners();
      }
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'levelIndex': levelIndex,
      'currentRoundIndex': currentRoundIndex,
      'rounds': rounds.map((r) => r.toMap()).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      levelIndex = map['levelIndex'] as int? ?? 0;
      currentRoundIndex = map['currentRoundIndex'] as int? ?? 0;
      if (map['rounds'] != null) {
        rounds = (map['rounds'] as List)
            .map((r) => LetterRound.fromMap(r as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _generateRounds();
    }
  }
}
