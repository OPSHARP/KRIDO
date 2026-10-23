import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/curriculum/age_curriculum_service.dart';
import 'package:kids_king_pro/games/registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AgeCurriculumService Tests', () {
    test('Defaults to allAges preset and includes all games', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialPreset = container.read(curriculumPresetProvider);
      expect(initialPreset, CurriculumPreset.allAges);

      final filtered = container.read(curriculumPresetProvider.notifier).filterGames(GameRegistry.allGames);
      expect(filtered.length, GameRegistry.allGames.length);
    });

    test('Toddler preset filters games strictly appropriate for ages 2-3', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(curriculumPresetProvider.notifier).setPreset(CurriculumPreset.toddler);
      final filtered = container.read(curriculumPresetProvider.notifier).filterGames(GameRegistry.allGames);

      expect(filtered.isNotEmpty, true);
      for (final g in filtered) {
        expect(g.minAge <= 3 && g.maxAge >= 2, true);
      }
    });

    test('Preschool preset filters games for ages 4-5', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(curriculumPresetProvider.notifier).setPreset(CurriculumPreset.preschool);
      final filtered = container.read(curriculumPresetProvider.notifier).filterGames(GameRegistry.allGames);

      expect(filtered.isNotEmpty, true);
      for (final g in filtered) {
        expect(g.minAge <= 5 && g.maxAge >= 4, true);
      }
    });

    test('Early Reader preset filters games for ages 6-8', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(curriculumPresetProvider.notifier).setPreset(CurriculumPreset.earlyReader);
      final filtered = container.read(curriculumPresetProvider.notifier).filterGames(GameRegistry.allGames);

      expect(filtered.isNotEmpty, true);
      for (final g in filtered) {
        expect(g.minAge <= 8 && g.maxAge >= 6, true);
      }
    });
  });
}
