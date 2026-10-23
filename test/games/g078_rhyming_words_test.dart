import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/game_contract/game_action.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/challenge.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/modules/g078_rhyming_words/g078_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProfile = Profile(
    id: 'child_tester',
    avatarId: 'avatar_bunny',
    nickname: 'Priya',
    uiLocale: 'en',
  );

  const testChallenge = Challenge(
    id: 'G078_T1_C01',
    gameId: 'G078',
    tier: 1,
    promptEn: 'Match the rhyming word!',
    promptHi: 'तुक मिलाने वाला शब्द खोजें!',
    taskData: {'totalRounds': 3},
    validAnswers: [],
  );

  group('G078 Rhyming Word Match Mini-Game Tests', () {
    test('Initializes with target word and 4 options containing exactly 1 rhyming word', () async {
      final controller = G078Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );

      await controller.initialize();
      controller.start();

      expect(controller.currentSet.targetWord.isNotEmpty, true);
      expect(controller.currentSet.targetEmoji.isNotEmpty, true);
      expect(controller.options.length, 4);

      final rhymes = controller.options.where((o) => o.isRhyme).toList();
      final distractors = controller.options.where((o) => !o.isRhyme).toList();

      expect(rhymes.length, 1, reason: 'Exactly 1 option must rhyme with the target');
      expect(distractors.length, 3, reason: '3 options must be distractors');
    });

    test('Selecting the rhyming option completes round and advances', () async {
      final controller = G078Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      final correctRhyme = controller.options.firstWhere((o) => o.isRhyme);

      final future = controller.handleAction(
        GameAction(type: GameActionType.tap, targetId: correctRhyme.id),
      );

      expect(controller.isRoundCorrect, true);
      expect(controller.selectedOptionId, correctRhyme.id);
      expect(controller.wrongOptionId, null);

      await future;

      expect(controller.currentRound, 1);
      expect(controller.isRoundCorrect, false);
      expect(controller.selectedOptionId, null);
    });

    test('Selecting incorrect option flags wrong option for gentle wobble without ending game', () async {
      final controller = G078Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      final distractor = controller.options.firstWhere((o) => !o.isRhyme);

      final future = controller.handleAction(
        GameAction(type: GameActionType.tap, targetId: distractor.id),
      );

      expect(controller.wrongOptionId, distractor.id);
      expect(controller.isRoundCorrect, false);

      await future;

      expect(controller.wrongOptionId, null);
      expect(controller.currentRound, 0); // round did not advance
      expect(controller.state, GameLifecycleState.playing);
    });

    test('applyHint sets hintHighlightId to the correct rhyming option', () async {
      final controller = G078Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      final correctRhyme = controller.options.firstWhere((o) => o.isRhyme);

      controller.applyHint();

      expect(controller.hintHighlightId, correctRhyme.id);
    });

    test('Completing all rounds completes the game', () async {
      final controller = G078Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      // Complete 3 rounds
      for (int r = 0; r < 3; r++) {
        final correct = controller.options.firstWhere((o) => o.isRhyme);
        await controller.handleAction(
          GameAction(type: GameActionType.tap, targetId: correct.id),
        );
      }

      expect(controller.state, GameLifecycleState.completed);
    });
  });
}
