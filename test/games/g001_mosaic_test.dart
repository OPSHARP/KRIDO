import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_king_pro/domain/game_contract/game_action.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/modules/g001_number_pebble_circle/g001_controller.dart';
import 'package:kids_king_pro/games/game_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProfile = Profile(
    id: 'test_child_123',
    avatarId: 'avatar_lion',
    nickname: 'Leo',
    uiLocale: 'en',
  );

  final defaultChallenge = GameFactory.createDefaultChallenge('G001');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('G001 1-1000 Mosaic Stage Progression & Persistence Tests', () {
    test('Default stage without saved progress starts at Stage 1 (1 to 10)', () async {
      final controller = G001Controller(
        challenge: defaultChallenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();

      expect(controller.currentStage, equals(1));
      expect(controller.rangeStart, equals(1));
      expect(controller.rangeEnd, equals(10));
      expect(controller.currentTarget, equals(1));
      expect(controller.cells.length, equals(10));
    });

    test('Stage persistence: Loads saved stage (e.g. Stage 3: 21-30, Stage 11: 101-150)', () async {
      // Simulate child has progressed to Stage 3 previously
      SharedPreferences.setMockInitialValues({
        'g001_saved_stage_${testProfile.id}': 3,
      });

      final controller = G001Controller(
        challenge: defaultChallenge,
        profile: testProfile,
        seed: 42,
      );

      await controller.initialize();

      // Should automatically resume at Stage 3 (21 to 30)
      expect(controller.currentStage, equals(3));
      expect(controller.rangeStart, equals(21));
      expect(controller.rangeEnd, equals(30));
      expect(controller.currentTarget, equals(21));
      expect(controller.cells.length, equals(10));
      expect(controller.cells.any((c) => c.number == 21), isTrue);
      expect(controller.cells.any((c) => c.number == 30), isTrue);

      // Now test Stage 11 (first stage after 100 -> 101 to 150)
      await controller.selectStage(11);
      expect(controller.currentStage, equals(11));
      expect(controller.rangeStart, equals(101));
      expect(controller.rangeEnd, equals(150));
      expect(controller.currentTarget, equals(101));
      expect(controller.cells.length, equals(50));
      expect(controller.cells.any((c) => c.number == 101), isTrue);
      expect(controller.cells.any((c) => c.number == 150), isTrue);
    });

    test('Stage navigation: selectStage, nextStage, and prevStage update range and persist to SharedPreferences', () async {
      final controller = G001Controller(
        challenge: defaultChallenge,
        profile: testProfile,
        seed: 42,
      );
      await controller.initialize();
      controller.start();

      // Select Stage 5 (41-50)
      await controller.selectStage(5);
      expect(controller.currentStage, equals(5));
      expect(controller.rangeStart, equals(41));
      expect(controller.rangeEnd, equals(50));
      expect(controller.currentTarget, equals(41));

      // Verify saved in prefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('g001_saved_stage_${testProfile.id}'), equals(5));

      // Next stage -> Stage 6 (51-60)
      await controller.nextStage();
      expect(controller.currentStage, equals(6));
      expect(controller.rangeStart, equals(51));
      expect(controller.rangeEnd, equals(60));
      expect(prefs.getInt('g001_saved_stage_${testProfile.id}'), equals(6));

      // Previous stage -> Stage 5 (41-50)
      await controller.prevStage();
      expect(controller.currentStage, equals(5));
      expect(controller.rangeStart, equals(41));
      expect(controller.rangeEnd, equals(50));
      expect(prefs.getInt('g001_saved_stage_${testProfile.id}'), equals(5));
    });

    test('Stage 28 reaches up to 1000', () async {
      final controller = G001Controller(
        challenge: defaultChallenge,
        profile: testProfile,
        seed: 42,
      );
      await controller.initialize();

      await controller.selectStage(28);
      expect(controller.currentStage, equals(28));
      expect(controller.rangeStart, equals(951));
      expect(controller.rangeEnd, equals(1000));
      expect(controller.currentTarget, equals(951));
      expect(controller.cells.any((c) => c.number == 1000), isTrue);
      expect(controller.cells.length, equals(50));
    });

    test('Completing a stage persists the next stage so future launch advances', () async {
      // Use overrideMaxNumber = 2 on Stage 1 for quick completion test
      final controller = G001Controller(
        challenge: defaultChallenge,
        profile: testProfile,
        seed: 777,
        overrideMaxNumber: 2,
      );
      await controller.initialize();
      controller.start();

      // Tap 1 then 2 to complete stage
      await controller.handleAction(GameAction.tap('mosaic_cell_1'));
      await controller.handleAction(GameAction.tap('mosaic_cell_2'));

      expect(controller.state, equals(GameLifecycleState.completed));

      // Next stage (Stage 2) should be persisted in prefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('g001_saved_stage_${testProfile.id}'), equals(2));

      // Launching a new session now automatically starts on Stage 2 (11-20)
      final newSessionController = G001Controller(
        challenge: defaultChallenge,
        profile: testProfile,
        seed: 888,
      );
      await newSessionController.initialize();
      expect(newSessionController.currentStage, equals(2));
      expect(newSessionController.rangeStart, equals(11));
      expect(newSessionController.rangeEnd, equals(20));
    });
  });
}
