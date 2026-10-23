import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/ads/ad_service.dart';
import 'package:kids_king_pro/domain/game_contract/game_action.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/challenge.dart';
import 'package:kids_king_pro/domain/models/game_result.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/features/parent/skills_radar_chart.dart';
import 'package:kids_king_pro/games/modules/g061_pattern_path/g061_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final testProfile = Profile(
    id: 'test_child',
    avatarId: 'avatar_lion',
    nickname: 'Leo',
    uiLocale: 'en',
  );

  const testChallenge = Challenge(
    id: 'G061_T1_C01',
    gameId: 'G061',
    tier: 1,
    promptEn: 'Find the one that does not belong!',
    promptHi: 'जो अलग है उसे पहचानें!',
    taskData: {},
    validAnswers: [],
  );

  group('G061 Odd One Out Controller Tests', () {
    test('Initializes with 4 rounds and correctly detects odd item', () async {
      final controller = G061Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 42,
        totalRounds: 4,
      );

      await controller.initialize();
      controller.start();

      expect(controller.state, equals(GameLifecycleState.playing));
      expect(controller.rounds.length, equals(4));

      final round = controller.currentRound;
      expect(round.items.contains(round.oddItem), isTrue);

      // Select the correct odd item
      await controller.handleAction(GameAction.select(round.oddItem));

      // Independent action recorded
      expect(controller.assessedActions, greaterThanOrEqualTo(1));
    });

    test('State serialization and deserialization retains round progress', () async {
      final controller = G061Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 999,
        totalRounds: 4,
      );

      await controller.initialize();
      controller.start();
      controller.currentRoundIndex = 2;

      final serialized = controller.serializeGameState();

      final restoredController = G061Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 999,
        totalRounds: 4,
      );
      await restoredController.initialize();
      restoredController.deserializeGameState(serialized);

      expect(restoredController.currentRoundIndex, equals(2));
      expect(restoredController.rounds.length, equals(4));
    });

    test('applyHint highlights the odd item and marks assisted', () async {
      final controller = G061Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 777,
      );

      await controller.initialize();
      controller.start();
      controller.requestHint();

      expect(controller.hintHighlightId, equals(controller.currentRound.oddItem));
      expect(controller.isAssisted, isTrue);
    });
  });

  group('SkillsRadarChart Tests', () {
    test('Calculates 6-axis scores correctly from attempts', () {
      final attempts = [
        GameResult(
          completionId: 'c1',
          profileId: 'test_child',
          gameId: 'G001',
          challengeId: 'ch1',
          seed: 1,
          difficultyTier: 1,
          completed: true,
          activeDurationMs: 15000,
          independentCorrectActions: 5,
          assessedActions: 5,
          hintsUsed: 0,
          assisted: false,
        ),
        GameResult(
          completionId: 'c2',
          profileId: 'test_child',
          gameId: 'G011',
          challengeId: 'ch2',
          seed: 1,
          difficultyTier: 1,
          completed: true,
          activeDurationMs: 12000,
          independentCorrectActions: 5,
          assessedActions: 5,
          hintsUsed: 0,
          assisted: false,
        ),
      ];

      final chart = SkillsRadarChart(attempts: attempts);
      final scores = chart.computeSkillScores();

      expect(scores.length, equals(6));
      expect(scores.any((s) => s.nameEn == 'Numeracy'), isTrue);
      expect(scores.any((s) => s.nameEn == 'Literacy'), isTrue);
      expect(scores.any((s) => s.nameEn == 'Logic & Shapes'), isTrue);
      expect(scores.any((s) => s.nameEn == 'Focus'), isTrue);

      final numeracyScore = scores.firstWhere((s) => s.nameEn == 'Numeracy').score;
      expect(numeracyScore, greaterThan(0.5));
    });
  });

  group('AdService COPPA & Test IDs Tests', () {
    test('AdService exposes official Google AdMob test IDs', () {
      expect(AdService.bannerAdUnitId, isNotEmpty);
      expect(AdService.rewardedAdUnitId, isNotEmpty);
      final adService = AdService();
      expect(adService.bannerEnabled, isTrue);
    });
  });
}
