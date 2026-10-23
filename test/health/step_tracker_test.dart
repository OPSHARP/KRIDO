import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_king_pro/core/health/step_tracker_service.dart';
import 'package:kids_king_pro/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StepTrackerState Tests', () {
    test('Calculates goalProgress, calories, and distance correctly', () {
      const state = StepTrackerState(
        stepsToday: 1500,
        dailyGoal: 3000,
        activeMinutes: 15,
        dateKey: '2026-09-17',
      );

      expect(state.goalProgress, 0.5);
      expect(state.caloriesBurned, (1500 * 0.04).round());
      expect(state.distanceKm, closeTo(0.9, 0.01));
    });

    test('Goal progress clamps at 1.0 when exceeding daily goal', () {
      const state = StepTrackerState(
        stepsToday: 4000,
        dailyGoal: 3000,
        activeMinutes: 40,
        dateKey: '2026-09-17',
      );

      expect(state.goalProgress, 1.0);
    });

    test('Serialization toMap and fromMap retains state values', () {
      const original = StepTrackerState(
        stepsToday: 2350,
        dailyGoal: 4000,
        activeMinutes: 35,
        dateKey: '2026-09-17',
        unlockedBadges: ['Meadow Hopper 🐰', 'Forest Trekker 🌲'],
      );

      final map = original.toMap();
      final restored = StepTrackerState.fromMap(map);

      expect(restored.stepsToday, 2350);
      expect(restored.dailyGoal, 4000);
      expect(restored.activeMinutes, 35);
      expect(restored.dateKey, '2026-09-17');
      expect(restored.unlockedBadges, containsAll(['Meadow Hopper 🐰', 'Forest Trekker 🌲']));
    });
  });

  group('StepTrackerNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('addSteps increments steps, active minutes, and unlocks milestone badges', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(stepTrackerProvider.notifier);

      // Start from clean 0 steps
      container.read(stepTrackerProvider); // initialize
      notifier.addSteps(600);
      expect(container.read(stepTrackerProvider).stepsToday, 1420 + 600); // 2020 steps

      final badges = container.read(stepTrackerProvider).unlockedBadges;
      expect(badges, contains('Meadow Hopper 🐰'));
      expect(badges, contains('Forest Trekker 🌲'));
    });

    test('Crossing 3000 steps unlocks Kingdom Champion 👑 badge', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(stepTrackerProvider.notifier);
      notifier.addSteps(2000); // 1420 + 2000 = 3420 >= 3000

      final badges = container.read(stepTrackerProvider).unlockedBadges;
      expect(badges, contains('Kingdom Champion 👑'));
    });

    test('setGoal updates daily step target', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(stepTrackerProvider.notifier);
      notifier.setGoal(5000);

      expect(container.read(stepTrackerProvider).dailyGoal, 5000);
    });
  });
}
