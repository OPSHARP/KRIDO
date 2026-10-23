import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class OddOneOutRound {
  final String categoryPromptEn;
  final String categoryPromptHi;
  final List<String> items;
  final String oddItem;
  final String reasonEn;
  final String reasonHi;

  OddOneOutRound({
    required this.categoryPromptEn,
    required this.categoryPromptHi,
    required this.items,
    required this.oddItem,
    required this.reasonEn,
    required this.reasonHi,
  });

  Map<String, dynamic> toMap() => {
        'categoryPromptEn': categoryPromptEn,
        'categoryPromptHi': categoryPromptHi,
        'items': items,
        'oddItem': oddItem,
        'reasonEn': reasonEn,
        'reasonHi': reasonHi,
      };

  factory OddOneOutRound.fromMap(Map<String, dynamic> map) => OddOneOutRound(
        categoryPromptEn: map['categoryPromptEn'] as String,
        categoryPromptHi: map['categoryPromptHi'] as String,
        items: List<String>.from(map['items'] as List),
        oddItem: map['oddItem'] as String,
        reasonEn: map['reasonEn'] as String,
        reasonHi: map['reasonHi'] as String,
      );
}

class G061Controller extends GameController {
  final int totalRounds;
  int currentRoundIndex = 0;
  List<OddOneOutRound> rounds = [];
  String? selectedItem;

  G061Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
    this.totalRounds = 4,
  }) : super(
          challenge: challenge,
          profile: profile,
          seed: seed,
        );

  OddOneOutRound get currentRound => rounds[currentRoundIndex];

  static final List<OddOneOutRound> _roundPool = [
    OddOneOutRound(
      categoryPromptEn: 'Which one is NOT a fruit?',
      categoryPromptHi: 'इनमें से कौन सा फल नहीं है?',
      items: ['🍎', '🍌', '🍇', '🚗'],
      oddItem: '🚗',
      reasonEn: 'Car is a vehicle, not a fruit!',
      reasonHi: 'कार एक वाहन है, फल नहीं!',
    ),
    OddOneOutRound(
      categoryPromptEn: 'Which one is NOT an animal?',
      categoryPromptHi: 'इनमें से कौन सा जानवर नहीं है?',
      items: ['🐶', '🐱', '🐰', '🍕'],
      oddItem: '🍕',
      reasonEn: 'Pizza is food, not an animal!',
      reasonHi: 'पिज्जा भोजन है, जानवर नहीं!',
    ),
    OddOneOutRound(
      categoryPromptEn: 'Which one is NOT a ball?',
      categoryPromptHi: 'इनमें से कौन सी गेंद नहीं है?',
      items: ['⚽', '🏀', '🏈', '🎸'],
      oddItem: '🎸',
      reasonEn: 'Guitar is an instrument, not a ball!',
      reasonHi: 'गिटार वाद्य यंत्र है, गेंद नहीं!',
    ),
    OddOneOutRound(
      categoryPromptEn: 'Which one does NOT fly in the sky?',
      categoryPromptHi: 'इनमें से कौन आसमान में नहीं उड़ता?',
      items: ['✈️', '🚀', '🚁', '🐠'],
      oddItem: '🐠',
      reasonEn: 'Fish swims in water, it does not fly!',
      reasonHi: 'मछली पानी में तैरती है, उड़ती नहीं!',
    ),
    OddOneOutRound(
      categoryPromptEn: 'Which one is NOT a vehicle?',
      categoryPromptHi: 'इनमें से कौन सा वाहन नहीं है?',
      items: ['🚗', '🚌', '🚂', '🌸'],
      oddItem: '🌸',
      reasonEn: 'Flower is a plant, not a vehicle!',
      reasonHi: 'फूल एक पौधा है, वाहन नहीं!',
    ),
    OddOneOutRound(
      categoryPromptEn: 'Which one is NOT sweet dessert?',
      categoryPromptHi: 'इनमें से कौन सी मीठी मिठाई नहीं है?',
      items: ['🍦', '🍩', '🎂', '🥕'],
      oddItem: '🥕',
      reasonEn: 'Carrot is a healthy vegetable, not a dessert!',
      reasonHi: 'गाजर एक सब्जी है, मिठाई नहीं!',
    ),
  ];

  @override
  Future<void> initialize() async {
    _generateRounds();
    await super.initialize();
  }

  void _generateRounds() {
    rounds.clear();
    final rng = SeededRng(seed);
    final shuffledPool = rng.shuffle(List<OddOneOutRound>.from(_roundPool));
    rounds = shuffledPool.take(totalRounds).toList();

    // Shuffle items within each round deterministically
    for (int i = 0; i < rounds.length; i++) {
      final r = rounds[i];
      final shuffledItems = rng.shuffle(List<String>.from(r.items));
      rounds[i] = OddOneOutRound(
        categoryPromptEn: r.categoryPromptEn,
        categoryPromptHi: r.categoryPromptHi,
        items: shuffledItems,
        oddItem: r.oddItem,
        reasonEn: r.reasonEn,
        reasonHi: r.reasonHi,
      );
    }
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state != GameLifecycleState.playing) return;

    if (action.type == GameActionType.select) {
      final item = action.payload as String;
      playTapSound();
      selectedItem = item;
      final round = currentRound;
      final isCorrect = item == round.oddItem;

      notifyListeners();

      if (isCorrect) {
        AudioService().playCue(SoundCue.correct);
        recordCorrectAction(wasAssisted: hintHighlightId != null);
        hintHighlightId = null;

        await Future.delayed(const Duration(milliseconds: 700));
        selectedItem = null;
        if (currentRoundIndex + 1 < totalRounds) {
          currentRoundIndex++;
          notifyListeners();
        } else {
          completeGame();
        }
      } else {
        AudioService().playCue(SoundCue.wrong);
        recordIncorrectAction();

        await Future.delayed(const Duration(milliseconds: 600));
        selectedItem = null;
        notifyListeners();
      }
    }
  }

  @override
  void applyHint() {
    hintHighlightId = currentRound.oddItem;
    AudioService().playCue(SoundCue.hint);
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'currentRoundIndex': currentRoundIndex,
      'rounds': rounds.map((r) => r.toMap()).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    final map = jsonDecode(rawJson) as Map<String, dynamic>;
    currentRoundIndex = map['currentRoundIndex'] as int;
    final rList = (map['rounds'] as List).map((r) => OddOneOutRound.fromMap(r as Map<String, dynamic>)).toList();
    rounds = rList;
    notifyListeners();
  }
}
