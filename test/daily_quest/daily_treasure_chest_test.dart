import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/models/daily_adventure.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyAdventure & Treasure Chest Model Tests', () {
    test('isAllCompleted returns false when some quests are unfinished', () {
      final adventure = DailyAdventure(
        profileId: 'test_child',
        localDate: '2026-09-17',
        challengeIds: ['G001', 'G011', 'G051'],
        completionFlags: [true, false, true],
        rewardClaimed: false,
      );

      expect(adventure.isAllCompleted, false);
      expect(adventure.rewardClaimed, false);
    });

    test('isAllCompleted returns true when all quests are finished', () {
      final adventure = DailyAdventure(
        profileId: 'test_child',
        localDate: '2026-09-17',
        challengeIds: ['G001', 'G011', 'G051'],
        completionFlags: [true, true, true],
        rewardClaimed: false,
      );

      expect(adventure.isAllCompleted, true);
    });

    test('toMap and fromMap preserves all quest flags and reward status', () {
      final original = DailyAdventure(
        profileId: 'test_child',
        localDate: '2026-09-17',
        challengeIds: ['G001', 'G080', 'G031'],
        completionFlags: [true, true, true],
        rewardClaimed: true,
      );

      final map = original.toMap();
      final restored = DailyAdventure.fromMap(map);

      expect(restored.profileId, original.profileId);
      expect(restored.localDate, original.localDate);
      expect(restored.challengeIds, original.challengeIds);
      expect(restored.completionFlags, original.completionFlags);
      expect(restored.rewardClaimed, true);
      expect(restored.isAllCompleted, true);
    });
  });
}
