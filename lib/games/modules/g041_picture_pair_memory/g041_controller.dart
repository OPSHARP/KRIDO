import 'dart:convert';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

enum CardRevealState { hidden, revealed, matched }

class MemoryCard {
  final int index;
  final String pairId;
  final String emoji;
  final String label;
  CardRevealState state;

  MemoryCard({
    required this.index,
    required this.pairId,
    required this.emoji,
    required this.label,
    this.state = CardRevealState.hidden,
  });

  Map<String, dynamic> toMap() => {
        'index': index,
        'pairId': pairId,
        'emoji': emoji,
        'label': label,
        'state': state.name,
      };

  factory MemoryCard.fromMap(Map<String, dynamic> map) => MemoryCard(
        index: map['index'] as int,
        pairId: map['pairId'] as String,
        emoji: map['emoji'] as String,
        label: map['label'] as String,
        state: CardRevealState.values.firstWhere(
          (s) => s.name == map['state'],
          orElse: () => CardRevealState.hidden,
        ),
      );
}

class G041Controller extends GameController {
  final int pairCount;
  List<MemoryCard> cards = [];
  int? firstRevealedIndex;
  bool isEvaluating = false;

  // === Enhanced mechanics ===
  int moveCount = 0;
  int comboStreak = 0;
  int bestCombo = 0;
  int totalScore = 0;
  int starRating = 0; // 1-3 stars awarded at completion
  DateTime? _gameStartTime;
  Duration elapsedTime = Duration.zero;
  bool isGameComplete = false;
  int? lastMatchIndex1;
  int? lastMatchIndex2;
  int? lastMismatchIndex1;
  int? lastMismatchIndex2;

  G041Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  })  : pairCount = (challenge.taskData['pairCount'] as int?) ??
            (challenge.tier == 1 ? 2 : (challenge.tier == 2 ? 4 : 8)),
        super(
          challenge: challenge,
          profile: profile,
          seed: seed,
        );

  @override
  Future<void> initialize() async {
    _generateCards();
    moveCount = 0;
    comboStreak = 0;
    bestCombo = 0;
    totalScore = 0;
    starRating = 0;
    elapsedTime = Duration.zero;
    isGameComplete = false;
    lastMatchIndex1 = null;
    lastMatchIndex2 = null;
    lastMismatchIndex1 = null;
    lastMismatchIndex2 = null;
    _gameStartTime = DateTime.now();
    await super.initialize();
  }

  void _generateCards() {
    cards.clear();
    final rng = SeededRng(seed);

    final candidatePairs = [
      {'id': 'lion', 'emoji': '🦁', 'label': 'Lion'},
      {'id': 'puppy', 'emoji': '🐶', 'label': 'Puppy'},
      {'id': 'kitten', 'emoji': '🐱', 'label': 'Kitten'},
      {'id': 'panda', 'emoji': '🐼', 'label': 'Panda'},
      {'id': 'monkey', 'emoji': '🐵', 'label': 'Monkey'},
      {'id': 'elephant', 'emoji': '🐘', 'label': 'Elephant'},
      {'id': 'bunny', 'emoji': '🐰', 'label': 'Bunny'},
      {'id': 'bear', 'emoji': '🐻', 'label': 'Bear'},
      {'id': 'penguin', 'emoji': '🐧', 'label': 'Penguin'},
      {'id': 'fox', 'emoji': '🦊', 'label': 'Fox'},
      {'id': 'koala', 'emoji': '🐨', 'label': 'Koala'},
      {'id': 'tiger', 'emoji': '🐯', 'label': 'Tiger'},
    ];

    final selected = rng.pickUnique(candidatePairs, pairCount);
    final List<Map<String, String>> deck = [];
    for (final p in selected) {
      deck.add(p);
      deck.add(p); // exactly 2 instances per identity
    }

    final shuffled = rng.shuffle(deck);
    for (int i = 0; i < shuffled.length; i++) {
      cards.add(
        MemoryCard(
          index: i,
          pairId: shuffled[i]['id']!,
          emoji: shuffled[i]['emoji']!,
          label: shuffled[i]['label']!,
        ),
      );
    }
  }

  /// Perfect moves = exactly pairCount moves. Stars based on excess moves.
  void _calculateStarRating() {
    final perfectMoves = pairCount;
    final excessMoves = moveCount - perfectMoves;
    if (excessMoves <= 0) {
      starRating = 3; // Perfect game!
    } else if (excessMoves <= pairCount) {
      starRating = 2; // Good game
    } else {
      starRating = 1; // Completed
    }
  }

  void _calculateFinalScore() {
    final matchedPairs = cards.where((c) => c.state == CardRevealState.matched).length ~/ 2;
    final baseScore = matchedPairs * 100;
    final comboBonus = bestCombo * 50;
    final moveEfficiency = pairCount > 0 ? ((pairCount / moveCount.clamp(1, 999)) * 200).round() : 0;
    totalScore = baseScore + comboBonus + moveEfficiency;
  }

  void _updateElapsedTime() {
    if (_gameStartTime != null) {
      elapsedTime = DateTime.now().difference(_gameStartTime!);
    }
  }

  int get matchedPairsCount => cards.where((c) => c.state == CardRevealState.matched).length ~/ 2;

  /// Combo multiplier displayed to user
  int get comboMultiplier => comboStreak >= 2 ? comboStreak : 0;

  @override
  void applyHint() {
    // Reveal one hidden pair briefly
    final hiddenCards = cards.where((c) => c.state == CardRevealState.hidden).toList();
    if (hiddenCards.isNotEmpty) {
      final targetPairId = hiddenCards.first.pairId;
      hintHighlightId = targetPairId;
    }
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state != GameLifecycleState.playing) return;
    if (isEvaluating) return; // Prevent 3 simultaneous card flips per PRD Section 12.3

    if (action.type == GameActionType.tap) {
      playTapSound();
      final cardIdx = int.tryParse(action.targetId ?? '');
      if (cardIdx == null || cardIdx < 0 || cardIdx >= cards.length) return;

      final card = cards[cardIdx];
      if (card.state != CardRevealState.hidden) return; // Ignore already revealed or matched

      // Clear mismatch markers
      lastMismatchIndex1 = null;
      lastMismatchIndex2 = null;

      card.state = CardRevealState.revealed;
      notifyListeners();

      if (firstRevealedIndex == null) {
        // First card of the pair
        firstRevealedIndex = cardIdx;
      } else {
        // Second card of the pair
        final firstIdx = firstRevealedIndex!;
        if (firstIdx == cardIdx) return; // Same card guard

        isEvaluating = true;
        moveCount++;
        final firstCard = cards[firstIdx];

        if (firstCard.pairId == card.pairId) {
          // Pair match!
          firstCard.state = CardRevealState.matched;
          card.state = CardRevealState.matched;
          comboStreak++;
          if (comboStreak > bestCombo) bestCombo = comboStreak;

          // Set match indices for visual feedback
          lastMatchIndex1 = firstIdx;
          lastMatchIndex2 = cardIdx;

          recordCorrectAction(wasAssisted: hintHighlightId == card.pairId);
          clearHint();
          firstRevealedIndex = null;
          isEvaluating = false;
          _updateElapsedTime();
          notifyListeners();

          if (cards.every((c) => c.state == CardRevealState.matched)) {
            _calculateStarRating();
            _calculateFinalScore();
            isGameComplete = true;
            notifyListeners();
            // Short delay before triggering completion
            await Future.delayed(const Duration(milliseconds: 800));
            completeGame();
          }
        } else {
          // Mismatch: keep visible for ~900ms per PRD Section 12.3, then hide
          comboStreak = 0; // Reset combo on mismatch
          lastMismatchIndex1 = firstIdx;
          lastMismatchIndex2 = cardIdx;
          recordIncorrectAction();
          _updateElapsedTime();
          notifyListeners();

          await Future.delayed(const Duration(milliseconds: 900));

          firstCard.state = CardRevealState.hidden;
          card.state = CardRevealState.hidden;
          lastMismatchIndex1 = null;
          lastMismatchIndex2 = null;
          firstRevealedIndex = null;
          isEvaluating = false;
          notifyListeners();
        }
      }
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'pairCount': pairCount,
      'firstRevealedIndex': firstRevealedIndex,
      'moveCount': moveCount,
      'comboStreak': comboStreak,
      'bestCombo': bestCombo,
      'cards': cards.map((c) => c.toMap()).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      firstRevealedIndex = map['firstRevealedIndex'] as int?;
      moveCount = (map['moveCount'] as int?) ?? 0;
      comboStreak = (map['comboStreak'] as int?) ?? 0;
      bestCombo = (map['bestCombo'] as int?) ?? 0;
      if (map['cards'] != null) {
        cards = (map['cards'] as List)
            .map((c) => MemoryCard.fromMap(c as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _generateCards();
    }
  }
}
