import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/game_contract/game_action.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/challenge.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/modules/g001_number_pebble_circle/g001_controller.dart';

void main() {
  group('Game Contract & Lifecycle Tests', () {
    late Profile testProfile;
    late Challenge testChallenge;

    setUp(() {
      testProfile = Profile(
        id: 'test_child',
        avatarId: 'avatar_fox',
        nickname: 'Tester',
      );
      testChallenge = const Challenge(
        id: 'G001_T1_C01',
        gameId: 'G001',
        tier: 1,
        promptEn: 'Tap numbers 1 to 5',
        promptHi: 'संख्या 1 से 5 छुएं',
        taskData: {'maxNumber': 5},
        validAnswers: [1, 2, 3, 4, 5],
      );
    });

    test('Initializes in introduction state and transitions to playing', () async {
      final controller = G001Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();
      expect(controller.state, GameLifecycleState.introduction);

      controller.start();
      expect(controller.state, GameLifecycleState.playing);
      expect(controller.activeElapsedMs, greaterThanOrEqualTo(0));
    });

    test('Pausing stops active monotonic timer and resume restarts it', () async {
      final controller = G001Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();
      controller.start();
      await Future.delayed(const Duration(milliseconds: 50));
      controller.pause();
      expect(controller.state, GameLifecycleState.paused);

      final elapsedAtPause = controller.activeElapsedMs;
      await Future.delayed(const Duration(milliseconds: 50));
      // Elapsed time should NOT have grown while paused
      expect(controller.activeElapsedMs, equals(elapsedAtPause));

      controller.resume();
      expect(controller.state, GameLifecycleState.playing);
    });

    test('Checkpoints can be serialized and accurately restored', () async {
      final controller = G001Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();
      controller.start();

      // Tap 1
      await controller.handleAction(GameAction.tap('1'));
      expect(controller.currentTarget, 2);

      final checkpoint = controller.serializeCheckpoint();
      expect(checkpoint.gameId, 'G001');

      // Create new fresh controller and restore
      final restoredController = G001Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );
      restoredController.restoreCheckpoint(checkpoint);
      expect(restoredController.currentTarget, 2);
    });

    test('Result computation computes stars and accuracy properly', () async {
      final controller = G001Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();
      controller.start();

      // Tap 1 through 5 in order without hints
      for (int i = 1; i <= 5; i++) {
        await controller.handleAction(GameAction.tap(i.toString()));
      }

      expect(controller.state, GameLifecycleState.completed);
      final result = controller.computeResult();
      expect(result.completed, true);
      expect(result.independentCorrectActions, 5);
      expect(result.hintsUsed, 0);
      expect(result.starsEarned, 3);
    });
  });
}
