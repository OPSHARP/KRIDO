import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/game_contract/game_action.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/challenge.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/modules/g073_spelling_puzzle/g073_controller.dart';
import 'package:kids_king_pro/games/modules/g074_kid_math/g074_controller.dart';
import 'package:kids_king_pro/games/modules/g075_pattern_sequence/g075_controller.dart';
import 'package:kids_king_pro/games/modules/g076_animal_sounds/g076_controller.dart';
import 'package:kids_king_pro/games/modules/g077_animal_quiz/g077_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProfile = Profile(
    id: 'child_tester',
    avatarId: 'avatar_lion',
    nickname: 'Leo',
    uiLocale: 'en',
  );

  group('G073 Spelling Puzzle Controller Tests', () {
    const testChallenge = Challenge(
      id: 'G073_C01',
      gameId: 'G073',
      tier: 1,
      promptEn: 'Spell the word!',
      promptHi: 'शब्द बनाएं!',
      taskData: {},
      validAnswers: [],
    );

    test('Initializes with target word and scrambled letter tiles', () async {
      final controller = G073Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 123,
      );

      await controller.initialize();
      controller.start();

      expect(controller.state, equals(GameLifecycleState.playing));
      expect(controller.targetWord.isNotEmpty, isTrue);
      expect(controller.scrambledLetters.length, equals(controller.targetWord.length));
      expect(controller.selectedTileIndices.isEmpty, isTrue);
      expect(controller.isWordSolved, isFalse);
    });

    test('Spelling letters sequentially completes word and advances round', () async {
      final controller = G073Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();
      controller.start();

      final targetWord = controller.targetWord;

      for (int i = 0; i < targetWord.length; i++) {
        final expectedLetter = targetWord[i];
        final tileIdx = controller.scrambledLetters.asMap().entries.firstWhere(
          (entry) => entry.value == expectedLetter && !controller.selectedTileIndices.contains(entry.key),
        ).key;

        await controller.handleAction(GameAction.tap('tile_$tileIdx'));
      }

      // After 1400ms celebration delay in handleAction, controller advances to next round
      expect(controller.currentRound, equals(1));
      expect(controller.assessedActions, equals(targetWord.length));
    });

    test('State serialization and deserialization retains round index', () async {
      final controller = G073Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 99,
      );

      await controller.initialize();
      controller.start();
      controller.currentRound = 2;

      final serialized = controller.serializeGameState();

      final restored = G073Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 99,
      );
      await restored.initialize();
      restored.deserializeGameState(serialized);

      expect(restored.currentRound, equals(2));
    });
  });

  group('G074 Kid Math Controller Tests', () {
    const testChallenge = Challenge(
      id: 'G074_C01',
      gameId: 'G074',
      tier: 1,
      promptEn: 'Count and add!',
      promptHi: 'गिनें और जोड़ें!',
      taskData: {},
      validAnswers: [],
    );

    test('Generates deterministic choices with correct answer', () async {
      final controller = G074Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 777,
      );

      await controller.initialize();
      controller.start();

      final q = controller.currentQuestion;
      expect(q.options.length, equals(4));
      expect(q.options.toSet().length, equals(4),
          reason: 'Options must be 4 distinct choices');
      expect(q.options.contains(q.answer), isTrue,
          reason: 'Options must contain correct answer');
    });

    test('Selecting correct option completes round and advances', () async {
      final controller = G074Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 555,
      );

      await controller.initialize();
      controller.start();

      final correctAns = controller.currentQuestion.answer;
      await controller.handleAction(GameAction.tap('opt_$correctAns'));

      // Round advances to 1 after celebration delay
      expect(controller.currentRound, equals(1));
      expect(controller.assessedActions, equals(1));
    });

    test('Selecting incorrect option handles wrong feedback gracefully', () async {
      final controller = G074Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 555,
      );

      await controller.initialize();
      controller.start();

      final wrongAns = controller.currentQuestion.options.firstWhere(
        (opt) => opt != controller.currentQuestion.answer,
      );

      await controller.handleAction(GameAction.tap('opt_$wrongAns'));

      expect(controller.isRoundAnswered, isFalse);
      expect(controller.wrongOption, equals(wrongAns));
      expect(controller.assessedActions, equals(1));
    });

    test('State serialization and deserialization retains round', () async {
      final controller = G074Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 888,
      );

      await controller.initialize();
      controller.start();
      controller.currentRound = 3;

      final serialized = controller.serializeGameState();

      final restored = G074Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 888,
      );
      await restored.initialize();
      restored.deserializeGameState(serialized);

      expect(restored.currentRound, equals(3));
    });
  });

  group('G075 Pattern Sequence Controller Tests', () {
    const testChallenge = Challenge(
      id: 'G075_C01',
      gameId: 'G075',
      tier: 1,
      promptEn: 'Complete the pattern!',
      promptHi: 'क्रम पूरा करें!',
      taskData: {},
      validAnswers: [],
    );

    test('Initializes valid pattern with distinct choices containing target', () async {
      final controller = G075Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 333,
      );

      await controller.initialize();
      controller.start();

      expect(controller.displaySequence.length, greaterThanOrEqualTo(4));
      // In tier 1, targetLength is 3 for toddler accessibility
      expect(controller.choices.length, equals(3));
      expect(controller.choices.map((c) => c.id).toSet().length, equals(3),
          reason: 'Choices must be unique');
      expect(
        controller.choices.any((c) => c.id == controller.correctItem.id),
        isTrue,
        reason: 'Choices must include correct item',
      );
      expect(controller.isPatternComplete, isFalse);
    });

    test('Selecting target pattern item completes sequence and advances', () async {
      final controller = G075Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );

      await controller.initialize();
      controller.start();

      final target = controller.correctItem;
      await controller.handleAction(GameAction.tap('opt_${target.id}'));

      // Round advances to 1 after celebration delay
      expect(controller.currentRound, equals(1));
      expect(controller.assessedActions, equals(1));
    });

    test('Selecting incorrect pattern choice triggers shake without ending game', () async {
      final controller = G075Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );

      await controller.initialize();
      controller.start();

      final wrong = controller.choices.firstWhere(
        (c) => c.id != controller.correctItem.id,
      );
      await controller.handleAction(GameAction.tap('opt_${wrong.id}'));

      expect(controller.isPatternComplete, isFalse);
      expect(controller.wrongChoice?.id, equals(wrong.id));
      expect(controller.state, equals(GameLifecycleState.playing));
    });
  });

  group('G076 Animal Sounds Controller Tests', () {
    const testChallenge = Challenge(
      id: 'G076_C01',
      gameId: 'G076',
      tier: 1,
      promptEn: 'Listen and choose the animal!',
      promptHi: 'आवाज़ सुनें और जानवर चुनें!',
      taskData: {},
      validAnswers: [],
    );

    test('Generates rounds with megaphone sound prompt and 4 unique animals', () async {
      final controller = G076Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 404,
      );

      await controller.initialize();
      controller.start();

      expect(controller.targetAnimal.soundText.isNotEmpty, isTrue);
      expect(controller.choices.length, equals(4));
      expect(controller.choices.map((c) => c.id).toSet().length, equals(4));
      expect(
        controller.choices.any((c) => c.id == controller.targetAnimal.id),
        isTrue,
      );
      expect(controller.isRoundCorrect, isFalse);
    });

    test('Selecting correct animal advances round and awards progress', () async {
      final controller = G076Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 808,
      );

      await controller.initialize();
      controller.start();

      final target = controller.targetAnimal;
      await controller.handleAction(GameAction.tap('animal_${target.id}'));

      // Round advances to 1 after celebration delay
      expect(controller.currentRound, equals(1));
      expect(controller.assessedActions, equals(1));
    });

    test('Selecting incorrect animal provides friendly shake', () async {
      final controller = G076Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 808,
      );

      await controller.initialize();
      controller.start();

      final wrong = controller.choices.firstWhere(
        (c) => c.id != controller.targetAnimal.id,
      );
      await controller.handleAction(GameAction.tap('animal_${wrong.id}'));

      expect(controller.isRoundCorrect, isFalse);
      expect(controller.wrongAnimal?.id, equals(wrong.id));
    });

    test('State serialization and deserialization retains round', () async {
      final controller = G076Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 999,
      );

      await controller.initialize();
      controller.start();
      controller.currentRound = 2;

      final serialized = controller.serializeGameState();

      final restored = G076Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 999,
      );
      await restored.initialize();
      restored.deserializeGameState(serialized);

      expect(restored.currentRound, equals(2));
    });
  });

  group('G077 Animal Quiz Controller Tests', () {
    const testChallenge = Challenge(
      id: 'G077_C01',
      gameId: 'G077',
      tier: 1,
      promptEn: 'Which animal is this? Tap the right name!',
      promptHi: 'यह कौन सा जानवर है? सही नाम चुनें!',
      taskData: {},
      validAnswers: [],
    );

    test('Initializes with target animal and 4 choices containing the target', () async {
      final controller = G077Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 456,
      );

      await controller.initialize();
      controller.start();

      expect(controller.state, equals(GameLifecycleState.playing));
      expect(controller.targetAnimal.nameEn.isNotEmpty, isTrue);
      expect(controller.choices.length, equals(4));
      expect(controller.choices.any((c) => c.id == controller.targetAnimal.id), isTrue);
      expect(controller.isRoundCorrect, isFalse);
    });

    test('Selecting correct animal name advances round and scores stars', () async {
      final controller = G077Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 789,
      );

      await controller.initialize();
      controller.start();

      final target = controller.targetAnimal;
      await controller.handleAction(GameAction.tap('choice_${target.id}'));

      // Round advances to 1
      expect(controller.currentRound, equals(1));
      expect(controller.assessedActions, equals(1));
      expect(controller.independentCorrectActions, equals(1));
    });

    test('Selecting incorrect animal name gives friendly feedback without life deduction', () async {
      final controller = G077Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 789,
      );

      await controller.initialize();
      controller.start();

      final wrong = controller.choices.firstWhere(
        (c) => c.id != controller.targetAnimal.id,
      );
      await controller.handleAction(GameAction.tap('choice_${wrong.id}'));

      expect(controller.isRoundCorrect, isFalse);
      expect(controller.wrongChoice?.id, equals(wrong.id));
      expect(controller.state, equals(GameLifecycleState.playing));
    });

    test('State serialization and deserialization retains round state', () async {
      final controller = G077Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );

      await controller.initialize();
      controller.start();
      controller.currentRound = 3;

      final serialized = controller.serializeGameState();

      final restored = G077Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await restored.initialize();
      restored.deserializeGameState(serialized);

      expect(restored.currentRound, equals(3));
    });
  });
}
