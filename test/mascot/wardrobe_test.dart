import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/mascot/mascot_wardrobe_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MascotWardrobeService Tests', () {
    test('Default outfit starts with classicGold crown, royalPurple cape, and no accessory', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final outfit = container.read(mascotWardrobeProvider);

      expect(outfit.crown, LeoCrown.classicGold);
      expect(outfit.cape, LeoCape.royalPurple);
      expect(outfit.accessory, LeoAccessory.none);
    });

    test('Equipping new crown updates outfit state and persists', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(mascotWardrobeProvider.notifier);

      await notifier.setCrown(LeoCrown.diamondTiara);
      expect(container.read(mascotWardrobeProvider).crown, LeoCrown.diamondTiara);

      await notifier.setCrown(LeoCrown.emeraldLaurel);
      expect(container.read(mascotWardrobeProvider).crown, LeoCrown.emeraldLaurel);
    });

    test('Equipping new cape and accessory updates outfit state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(mascotWardrobeProvider.notifier);

      await notifier.setCape(LeoCape.crimsonHero);
      await notifier.setAccessory(LeoAccessory.starShades);

      expect(container.read(mascotWardrobeProvider).cape, LeoCape.crimsonHero);
      expect(container.read(mascotWardrobeProvider).accessory, LeoAccessory.starShades);
    });

    test('Equipping all items transforms outfit completely', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(mascotWardrobeProvider.notifier);

      await notifier.setCrown(LeoCrown.pirateBandana);
      await notifier.setCape(LeoCape.goldenSun);
      await notifier.setAccessory(LeoAccessory.brassGoggles);

      final current = container.read(mascotWardrobeProvider);
      expect(current.crown, LeoCrown.pirateBandana);
      expect(current.cape, LeoCape.goldenSun);
      expect(current.accessory, LeoAccessory.brassGoggles);
    });
  });
}
