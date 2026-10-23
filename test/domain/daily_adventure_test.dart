import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/models/daily_adventure.dart';

void main() {
  group('DailyAdventure Model Tests', () {
    test('Correctly computes isAllCompleted when all flags are true', () {
      final adventure = DailyAdventure(
        profileId: 'child_1',
        localDate: '2026-09-16',
        challengeIds: ['G001', 'G011', 'G051'],
        completionFlags: [true, true, true],
        rewardClaimed: false,
      );

      expect(adventure.isAllCompleted, isTrue);
      expect(adventure.rewardClaimed, isFalse);
    });

    test('Computes isAllCompleted as false if any quest is incomplete', () {
      final adventure = DailyAdventure(
        profileId: 'child_1',
        localDate: '2026-09-16',
        challengeIds: ['G001', 'G011', 'G051'],
        completionFlags: [true, false, true],
        rewardClaimed: false,
      );

      expect(adventure.isAllCompleted, isFalse);
    });

    test('Serializes to Map and deserializes from Map identically', () {
      final original = DailyAdventure(
        profileId: 'child_abc',
        localDate: '2026-09-16',
        challengeIds: ['G001', 'G011', 'G051'],
        completionFlags: [true, true, false],
        rewardClaimed: false,
      );

      final map = original.toMap();
      final reconstructed = DailyAdventure.fromMap(map);

      expect(reconstructed.profileId, original.profileId);
      expect(reconstructed.localDate, original.localDate);
      expect(reconstructed.challengeIds, original.challengeIds);
      expect(reconstructed.completionFlags, original.completionFlags);
      expect(reconstructed.rewardClaimed, original.rewardClaimed);
    });
  });
}
