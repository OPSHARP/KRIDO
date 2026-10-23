import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/game_contract/game_action.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/challenge.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/modules/g041_picture_pair_memory/g041_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProfile = Profile(
    id: 'child_tester',
    avatarId: 'avatar_lion',
    nickname: 'Leo',
    uiLocale: 'en',
  );

  const testChallenge = Challenge(
    id: 'G041_T3_C01',
    gameId: 'G041',
    tier: 3,
    promptEn: 'Match the animal pairs!',
    promptHi: 'जानवरों के जोड़े मिलाएं!',
    taskData: {'pairCount': 8},
    validAnswers: [],
  );

  group('G041 4x4 Animal Card Matching Game Tests', () {
    test('Initializes with 16 cards (8 pairs, 4x4 grid) in Tier 3 with animal illustrations', () async {
      final controller = G041Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();
      controller.start();

      expect(controller.cards.length, 16, reason: '4x4 grid requires exactly 16 cards');
      expect(controller.pairCount, 8, reason: '8 unique animal pairs');

      // Verify all cards start face down (hidden)
      for (final card in controller.cards) {
        expect(card.state, CardRevealState.hidden);
        expect(card.emoji.isNotEmpty, true);
        expect(card.label.isNotEmpty, true);
      }

      // Verify each animal pair appears exactly twice
      final pairCountMap = <String, int>{};
      for (final card in controller.cards) {
        pairCountMap[card.pairId] = (pairCountMap[card.pairId] ?? 0) + 1;
      }
      expect(pairCountMap.length, 8);
      for (final entry in pairCountMap.entries) {
        expect(entry.value, 2, reason: 'Animal ${entry.key} must appear in a matched pair');
      }
    });

    test('Flipping first card reveals it', () async {
      final controller = G041Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );
      await controller.initialize();
      controller.start();

      await controller.handleAction(
        GameAction(type: GameActionType.tap, targetId: '0'),
      );

      expect(controller.cards[0].state, CardRevealState.revealed);
      expect(controller.firstRevealedIndex, 0);
      expect(controller.isEvaluating, false);
    });

    test('Flipping two matching animal cards keeps them face up in matched state', () async {
      final controller = G041Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );
      await controller.initialize();
      controller.start();

      // Find the pair for index 0
      final firstCard = controller.cards[0];
      final secondCardIndex = controller.cards.indexWhere(
        (c) => c.index != 0 && c.pairId == firstCard.pairId,
      );

      // Flip first card
      await controller.handleAction(
        GameAction(type: GameActionType.tap, targetId: '0'),
      );
      // Flip matching second card
      await controller.handleAction(
        GameAction(type: GameActionType.tap, targetId: '$secondCardIndex'),
      );

      expect(controller.cards[0].state, CardRevealState.matched);
      expect(controller.cards[secondCardIndex].state, CardRevealState.matched);
      expect(controller.firstRevealedIndex, null);
      expect(controller.isEvaluating, false);
    });

    test('Flipping two mismatched cards flips them back after evaluation delay', () async {
      final controller = G041Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );
      await controller.initialize();
      controller.start();

      // Find a card with different pairId than card 0
      final firstCard = controller.cards[0];
      final mismatchIndex = controller.cards.indexWhere(
        (c) => c.pairId != firstCard.pairId,
      );

      // Flip card 0
      await controller.handleAction(
        GameAction(type: GameActionType.tap, targetId: '0'),
      );

      // Flip mismatched card
      final future = controller.handleAction(
        GameAction(type: GameActionType.tap, targetId: '$mismatchIndex'),
      );

      // During evaluation delay, isEvaluating is true
      expect(controller.isEvaluating, true);

      // Wait for delay to complete
      await future;

      // Both cards are flipped back to hidden
      expect(controller.cards[0].state, CardRevealState.hidden);
      expect(controller.cards[mismatchIndex].state, CardRevealState.hidden);
      expect(controller.firstRevealedIndex, null);
      expect(controller.isEvaluating, false);
    });

    test('Matching all 8 pairs completes the game with victory state', () async {
      final controller = G041Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );
      await controller.initialize();
      controller.start();

      // Match all 8 pairs
      final handledPairIds = <String>{};
      for (final card in controller.cards) {
        if (handledPairIds.contains(card.pairId)) continue;
        handledPairIds.add(card.pairId);

        final matches = controller.cards.where((c) => c.pairId == card.pairId).toList();
        await controller.handleAction(
          GameAction(type: GameActionType.tap, targetId: '${matches[0].index}'),
        );
        await controller.handleAction(
          GameAction(type: GameActionType.tap, targetId: '${matches[1].index}'),
        );
      }

      expect(controller.state, GameLifecycleState.completed);
      expect(controller.cards.every((c) => c.state == CardRevealState.matched), true);
    });
  });
}
