import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class SizeItem {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final double relativeSize; // 0.0 to 1.0 representing how big
  bool isPlaced;

  SizeItem({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.relativeSize,
    this.isPlaced = false,
  });
}

class SizeRound {
  final String instructionEn;
  final String instructionHi;
  final List<SizeItem> items;
  final bool smallestFirst; // true = arrange smallest to largest
  bool isComplete;

  SizeRound({
    required this.instructionEn,
    required this.instructionHi,
    required this.items,
    required this.smallestFirst,
    this.isComplete = false,
  });

  List<SizeItem> get correctOrder {
    final sorted = List<SizeItem>.from(items);
    sorted.sort((a, b) => smallestFirst
        ? a.relativeSize.compareTo(b.relativeSize)
        : b.relativeSize.compareTo(a.relativeSize));
    return sorted;
  }
}

class G090Controller extends GameController {
  List<SizeRound> rounds = [];
  int currentRoundIndex = 0;
  List<SizeItem> placedItems = [];
  bool showingResult = false;
  bool lastRoundCorrect = false;

  G090Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  SizeRound get currentRound => rounds[currentRoundIndex];
  List<SizeItem> get unplacedItems => currentRound.items.where((i) => !i.isPlaced).toList();

  @override
  Future<void> initialize() async {
    rounds = [
      SizeRound(
        instructionEn: 'Stack animals: Smallest to Biggest! 🐾',
        instructionHi: 'जानवरों को छोटे से बड़े सजाओ! 🐾',
        smallestFirst: true,
        items: [
          SizeItem(id: 'ant', nameEn: 'Ant', nameHi: 'चींटी', emoji: '🐜', relativeSize: 0.1),
          SizeItem(id: 'cat', nameEn: 'Cat', nameHi: 'बिल्ली', emoji: '🐱', relativeSize: 0.3),
          SizeItem(id: 'dog', nameEn: 'Dog', nameHi: 'कुत्ता', emoji: '🐶', relativeSize: 0.5),
          SizeItem(id: 'horse', nameEn: 'Horse', nameHi: 'घोड़ा', emoji: '🐴', relativeSize: 0.7),
          SizeItem(id: 'elephant', nameEn: 'Elephant', nameHi: 'हाथी', emoji: '🐘', relativeSize: 1.0),
        ],
      ),
      SizeRound(
        instructionEn: 'Stack fruits: Biggest to Smallest! 🍎',
        instructionHi: 'फलों को बड़े से छोटे सजाओ! 🍎',
        smallestFirst: false,
        items: [
          SizeItem(id: 'grape', nameEn: 'Grape', nameHi: 'अंगूर', emoji: '🍇', relativeSize: 0.15),
          SizeItem(id: 'lemon', nameEn: 'Lemon', nameHi: 'नींबू', emoji: '🍋', relativeSize: 0.3),
          SizeItem(id: 'apple', nameEn: 'Apple', nameHi: 'सेब', emoji: '🍎', relativeSize: 0.5),
          SizeItem(id: 'pineapple', nameEn: 'Pineapple', nameHi: 'अनानास', emoji: '🍍', relativeSize: 0.75),
          SizeItem(id: 'watermelon', nameEn: 'Watermelon', nameHi: 'तरबूज', emoji: '🍉', relativeSize: 1.0),
        ],
      ),
      SizeRound(
        instructionEn: 'Stack vehicles: Smallest to Biggest! 🚗',
        instructionHi: 'वाहनों को छोटे से बड़े सजाओ! 🚗',
        smallestFirst: true,
        items: [
          SizeItem(id: 'bicycle', nameEn: 'Bicycle', nameHi: 'साइकिल', emoji: '🚲', relativeSize: 0.15),
          SizeItem(id: 'car', nameEn: 'Car', nameHi: 'कार', emoji: '🚗', relativeSize: 0.35),
          SizeItem(id: 'bus', nameEn: 'Bus', nameHi: 'बस', emoji: '🚌', relativeSize: 0.6),
          SizeItem(id: 'train', nameEn: 'Train', nameHi: 'ट्रेन', emoji: '🚂', relativeSize: 0.8),
          SizeItem(id: 'ship', nameEn: 'Ship', nameHi: 'जहाज', emoji: '🚢', relativeSize: 1.0),
        ],
      ),
    ];

    // Shuffle item order within each round
    final rng = Random(seed);
    for (final round in rounds) {
      round.items.shuffle(rng);
    }
    rounds.shuffle(rng);

    await super.initialize();
  }

  void placeItem(String itemId) {
    if (state != GameLifecycleState.playing || showingResult) return;

    final item = currentRound.items.firstWhere((i) => i.id == itemId);
    if (item.isPlaced) return;

    final correctOrder = currentRound.correctOrder;
    final expectedItem = correctOrder[placedItems.length];

    assessedActions++;

    if (item.id == expectedItem.id) {
      item.isPlaced = true;
      placedItems.add(item);
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);

      if (placedItems.length == currentRound.items.length) {
        currentRound.isComplete = true;
        lastRoundCorrect = true;
        showingResult = true;
        AudioService().playCue(SoundCue.cheer);
      }
    } else {
      AudioService().playCue(SoundCue.wrong);
      // Reset placed items for this round
      for (final i in currentRound.items) {
        i.isPlaced = false;
      }
      placedItems.clear();
    }
    notifyListeners();
  }

  void nextRound() {
    showingResult = false;
    placedItems.clear();

    if (rounds.every((r) => r.isComplete)) {
      completeGame();
      return;
    }
    currentRoundIndex = rounds.indexWhere((r) => !r.isComplete);
    notifyListeners();
  }

  @override
  void applyHint() {
    final correctOrder = currentRound.correctOrder;
    if (placedItems.length < correctOrder.length) {
      hintHighlightId = correctOrder[placedItems.length].id;
      notifyListeners();
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'completedRounds': rounds.asMap().entries.where((e) => e.value.isComplete).map((e) => e.key).toList(),
      'currentRoundIndex': currentRoundIndex,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['completedRounds'] as List?)?.cast<int>() ?? [];
      for (final i in list) {
        if (i < rounds.length) rounds[i].isComplete = true;
      }
      currentRoundIndex = (data['currentRoundIndex'] as int?) ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
