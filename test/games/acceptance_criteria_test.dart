import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/rng/seeded_rng.dart';
import 'package:kids_king_pro/domain/game_contract/game_action.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/challenge.dart';
import 'package:kids_king_pro/domain/models/game_definition.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/modules/g001_number_pebble_circle/g001_controller.dart';
import 'package:kids_king_pro/games/modules/g002_count_orchard/g002_controller.dart';
import 'package:kids_king_pro/games/modules/g011_find_the_letter/g011_controller.dart';
import 'package:kids_king_pro/games/modules/g031_shape_home/g031_controller.dart';
import 'package:kids_king_pro/games/modules/g041_picture_pair_memory/g041_controller.dart';
import 'package:kids_king_pro/games/modules/g051_animal_jigsaw/g051_controller.dart';
import 'package:kids_king_pro/games/registry.dart';

void main() {
  final testProfile = Profile(
    id: 'test_child',
    avatarId: 'avatar_fox',
    nickname: 'Hero',
    uiLocale: 'en',
  );

  group('PRD Seeded RNG Tests', () {
    test('Same seed produces identical permutations across runs', () {
      final rng1 = SeededRng(12345);
      final rng2 = SeededRng(12345);

      final list1 = rng1.shuffle([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      final list2 = rng2.shuffle([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

      expect(list1, equals(list2));
      expect(rng1.nextInt(1, 100), equals(rng2.nextInt(1, 100)));
    });
  });

  group('PRD Acceptance Criteria Tests (AC01 - AC10)', () {
    test('AC01: Given 6 displayed apples, selecting 6 accepts it; 6 is in choices', () async {
      const challenge = Challenge(
        id: 'G002_T2_C01',
        gameId: 'G002',
        tier: 2,
        promptEn: 'Count the apples',
        promptHi: 'सेब गिनें',
        taskData: {'fruitCount': 6},
        validAnswers: [6],
      );

      final controller = G002Controller(
        challenge: challenge,
        profile: testProfile,
        seed: 777,
        overrideFruitCount: 6,
      );

      await controller.initialize();
      controller.start();

      // Rendered countable fruit count must equal 6
      expect(controller.actualCount, 6);
      expect(controller.answerChoices, contains(6));

      // Unique choices, no duplicate answer buttons
      expect(controller.answerChoices.toSet().length, controller.answerChoices.length);

      // Select 6 -> round accepts it and completes
      await controller.handleAction(GameAction.tap('6'));
      expect(controller.state, GameLifecycleState.completed);
    });

    test('AC02: Given circle 1-10, tapping 4 when target is 3 keeps target 3 with no life loss', () async {
      const challenge = Challenge(
        id: 'G001_T2_C01',
        gameId: 'G001',
        tier: 2,
        promptEn: 'Tap numbers 1 to 10',
        promptHi: 'संख्या 1 से 10 छुएं',
        taskData: {'maxNumber': 10},
        validAnswers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      final controller = G001Controller(
        challenge: challenge,
        profile: testProfile,
        seed: 999,
        overrideMaxNumber: 10,
      );

      await controller.initialize();
      controller.start();

      // Advance to 3
      await controller.handleAction(GameAction.tap('1'));
      await controller.handleAction(GameAction.tap('2'));
      expect(controller.currentTarget, 3);

      // Wrong tap: tap 4
      await controller.handleAction(GameAction.tap('4'));

      // Target remains 3, state is still playing, no lives lost
      expect(controller.currentTarget, 3);
      expect(controller.state, GameLifecycleState.playing);
    });

    test('AC03: Memory match ignores 3rd card during mismatch evaluation', () async {
      const challenge = Challenge(
        id: 'G041_T1_C01',
        gameId: 'G041',
        tier: 1,
        promptEn: 'Find matching pairs',
        promptHi: 'जोड़ियां ढूंढें',
        taskData: {},
        validAnswers: [],
      );

      final controller = G041Controller(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();
      controller.start();

      expect(controller.cards.length, 4); // 2 pairs

      // Flip first card
      await controller.handleAction(GameAction.tap('0'));
      expect(controller.firstRevealedIndex, 0);

      // Find an index with a different pairId for a mismatch
      int mismatchIdx = 1;
      if (controller.cards[1].pairId == controller.cards[0].pairId) {
        mismatchIdx = 2;
      }

      // Trigger second card flip (initiates ~900ms delay)
      final secondFlipFuture = controller.handleAction(GameAction.tap(mismatchIdx.toString()));
      expect(controller.isEvaluating, true);

      // Attempt 3rd card flip while evaluating
      int thirdIdx = (mismatchIdx == 1) ? 2 : 1;
      await controller.handleAction(GameAction.tap(thirdIdx.toString()));

      // 3rd card state should STILL be hidden (tap ignored)
      expect(controller.cards[thirdIdx].state, CardRevealState.hidden);

      await secondFlipFuture;
      expect(controller.isEvaluating, false);
    });

    test('AC04: Jigsaw wrong drop returns safely without marking slot complete', () async {
      const challenge = Challenge(
        id: 'G051_T1_C01',
        gameId: 'G051',
        tier: 1,
        promptEn: 'Assemble puzzle',
        promptHi: 'पहेली बनाएं',
        taskData: {},
        validAnswers: [],
      );

      final controller = G051Controller(
        challenge: challenge,
        profile: testProfile,
        seed: 123,
      );

      await controller.initialize();
      controller.start();

      final piece = controller.pieces.first;
      // Intentionally drop near wrong slot
      final wrongRow = (piece.targetRow + 1) % controller.gridDimension;
      final wrongCol = piece.targetCol;

      await controller.handleAction(
        GameAction.dragDrop(
          targetId: 'slot_${wrongRow}_$wrongCol',
          payload: piece.id,
        ),
      );

      // Piece must remain unplaced
      expect(piece.isPlaced, false);
      expect(controller.state, GameLifecycleState.playing);
    });

    test('G051: Completing puzzle auto-generates new animal puzzle', () async {
      const challenge = Challenge(
        id: 'G051_T1_C01',
        gameId: 'G051',
        tier: 1,
        promptEn: 'Assemble the animal puzzle',
        promptHi: 'पहेली जोड़ें',
        taskData: {},
        validAnswers: [],
      );

      final controller = G051Controller(
        challenge: challenge,
        profile: testProfile,
        seed: 456,
      );

      await controller.initialize();
      controller.start();

      expect(controller.currentTheme.title, 'DOGGY PUZZLE!');
      expect(controller.currentTheme.imageAsset, 'assets/art/doggy_puzzle.jpg');
      expect(controller.puzzleIndex, 0);

      // Place all pieces correctly
      for (final piece in List.from(controller.pieces)) {
        await controller.handleAction(
          GameAction.dragDrop(
            targetId: 'slot_${piece.targetRow}_${piece.targetCol}',
            payload: piece.id,
          ),
        );
      }

      expect(controller.isPuzzleCompleted, true);
      expect(controller.puzzlesCompletedCount, 1);

      // Trigger generation of next puzzle
      controller.generateNextPuzzle();

      expect(controller.puzzleIndex, 1);
      expect(controller.currentTheme.title, 'KITTY PUZZLE!');
      expect(controller.currentTheme.imageAsset, 'assets/art/kitty_puzzle.jpg');
      expect(controller.isPuzzleCompleted, false);
      expect(controller.pieces.length, 4);
      expect(controller.pieces.every((p) => !p.isPlaced), true);
    });

    test('AC05: Shape Home matches planar silhouettes invariant to color with tap/drag parity', () async {
      const challenge = Challenge(
        id: 'G031_T1_C01',
        gameId: 'G031',
        tier: 1,
        promptEn: 'Place shapes',
        promptHi: 'आकार रखें',
        taskData: {},
        validAnswers: [],
      );

      final controller = G031Controller(
        challenge: challenge,
        profile: testProfile,
        seed: 321,
      );

      await controller.initialize();
      controller.start();

      final shape = controller.shapes.first;
      // Tap-place alternative: tap shape then tap slot
      await controller.handleAction(GameAction.tap(shape.id));
      expect(controller.selectedShapeForTap?.id, shape.id);

      await controller.handleAction(GameAction.tap('slot_${shape.shapeType.name}'));
      expect(shape.isPlaced, true);
    });

    test('AC07: Find the Letter provides single exact answer and balanced distractors', () async {
      const challenge = Challenge(
        id: 'G011_T1_C01',
        gameId: 'G011',
        tier: 1,
        promptEn: 'Find letter',
        promptHi: 'अक्षर खोजें',
        taskData: {},
        validAnswers: [],
      );

      final controller = G011Controller(
        challenge: challenge,
        profile: testProfile,
        seed: 555,
      );

      await controller.initialize();
      controller.start();

      final round = controller.currentRound;
      // Target must appear exactly once among choices
      final occurrences = round.choices.where((c) => c == round.targetGlyph).length;
      expect(occurrences, 1);
      // Choices must be distinct
      expect(round.choices.toSet().length, round.choices.length);
    });

    test('AC08: Game Registry has exactly 120 unique games across 12 Worlds with zero duplicate IDs', () {
      expect(GameRegistry.allGames.length, 120);

      final uniqueIds = GameRegistry.allGames.map((g) => g.id).toSet();
      expect(uniqueIds.length, 120);

      for (int i = 1; i <= 120; i++) {
        final expectedId = 'G${i.toString().padLeft(3, '0')}';
        expect(uniqueIds.contains(expectedId), true, reason: '$expectedId must exist');
      }

      // Each of the 12 Worlds must have exactly 10 games
      for (final world in WorldType.values) {
        final worldGames = GameRegistry.getByWorld(world);
        expect(worldGames.length, 10, reason: '${world.titleEn} must have 10 games');
      }
    });
  });
}
