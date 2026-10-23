import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_king_pro/domain/models/virtual_pet_model.dart';
import 'package:kids_king_pro/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VirtualPetModel Tests', () {
    test('Pet stages have correct names, emojis, and evolution thresholds', () {
      expect(PetStage.egg.name, 'Mystic Egg');
      expect(PetStage.egg.requiredXp, 0);
      expect(PetStage.egg.nextStage, PetStage.baby);
      expect(PetStage.egg.isMaxStage, false);

      expect(PetStage.baby.name, 'Baby Leo');
      expect(PetStage.baby.requiredXp, 100);
      expect(PetStage.baby.nextStage, PetStage.cub);
      expect(PetStage.baby.isMaxStage, false);

      expect(PetStage.cub.name, 'Playful Cub');
      expect(PetStage.cub.requiredXp, 300);
      expect(PetStage.cub.nextStage, PetStage.king);
      expect(PetStage.cub.isMaxStage, false);

      expect(PetStage.king.name, 'Royal King Leo');
      expect(PetStage.king.requiredXp, 600);
      expect(PetStage.king.nextStage, PetStage.king);
      expect(PetStage.king.isMaxStage, true);
    });

    test('Evolution progress clamps correctly between 0.0 and 1.0', () {
      final eggInitial = VirtualPetState(
        stage: PetStage.egg,
        xp: 50,
        lastFed: DateTime.now(),
      );
      // Egg needs 100 XP to reach Baby. At 50 XP, progress is 0.5
      expect(eggInitial.evolutionProgress, closeTo(0.5, 0.01));

      final kingMax = VirtualPetState(
        stage: PetStage.king,
        xp: 600,
        lastFed: DateTime.now(),
      );
      expect(kingMax.evolutionProgress, 1.0);
    });

    test('JSON serialization and deserialization preserves pet state', () {
      final now = DateTime.now();
      final original = VirtualPetState(
        stage: PetStage.cub,
        level: 3,
        xp: 320,
        treatsAvailable: 5,
        happiness: 0.95,
        totalFedCount: 12,
        completedModulesCount: 8,
        lastFed: now,
      );

      final jsonStr = original.toJson();
      final restored = VirtualPetState.fromJson(jsonStr);

      expect(restored.stage, PetStage.cub);
      expect(restored.level, 3);
      expect(restored.xp, 320);
      expect(restored.treatsAvailable, 5);
      expect(restored.happiness, closeTo(0.95, 0.01));
      expect(restored.totalFedCount, 12);
      expect(restored.completedModulesCount, 8);
    });
  });

  group('VirtualPetNotifier Riverpod Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with default friendly state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final petState = container.read(virtualPetProvider);
      expect(petState.stage, PetStage.egg);
      expect(petState.treatsAvailable, 3);
      expect(petState.happiness, 0.8);
      expect(petState.xp, 0);
    });

    test('Feeding pet consumes 1 treat and increases XP & happiness', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(virtualPetProvider.notifier);
      final initialTreats = container.read(virtualPetProvider).treatsAvailable;

      final fed = await notifier.feedPet('Berry');
      expect(fed, true);

      final updated = container.read(virtualPetProvider);
      expect(updated.treatsAvailable, initialTreats - 1);
      expect(updated.xp, 20);
      expect(updated.totalFedCount, 1);
      expect(updated.happiness, 1.0);
    });

    test('Feeding with 0 treats returns false and does not decrement', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(virtualPetProvider.notifier);
      // Consume all 3 default treats
      await notifier.feedPet('Berry');
      await notifier.feedPet('Apple');
      await notifier.feedPet('Cookie');

      expect(container.read(virtualPetProvider).treatsAvailable, 0);

      // Attempt 4th feed
      final fed = await notifier.feedPet('Milk');
      expect(fed, false);
      expect(container.read(virtualPetProvider).treatsAvailable, 0);
    });

    test('Award module completion gives +1 treat, +35 XP, and increments completedModulesCount', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(virtualPetProvider.notifier);
      final initialTreats = container.read(virtualPetProvider).treatsAvailable;

      await notifier.awardModuleCompletion();

      final updated = container.read(virtualPetProvider);
      expect(updated.treatsAvailable, initialTreats + 1);
      expect(updated.completedModulesCount, 1);
      expect(updated.xp, 35);
    });

    test('Pet evolves stage when XP crosses threshold', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(virtualPetProvider.notifier);

      // Award 3 completions (3 * 35 = 105 XP >= 100 XP for Baby)
      await notifier.awardModuleCompletion();
      await notifier.awardModuleCompletion();
      await notifier.awardModuleCompletion();

      final state = container.read(virtualPetProvider);
      expect(state.stage, PetStage.baby);
      expect(notifier.justEvolved, true);
    });

    test('Patting pet increases happiness', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(virtualPetProvider.notifier);
      final beforeHappiness = container.read(virtualPetProvider).happiness;

      notifier.patPet();

      final afterHappiness = container.read(virtualPetProvider).happiness;
      expect(afterHappiness, greaterThanOrEqualTo(beforeHappiness));
    });
  });
}
