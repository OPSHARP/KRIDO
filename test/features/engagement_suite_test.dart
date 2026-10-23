import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_king_pro/core/widgets/magic_touch_overlay.dart';
import 'package:kids_king_pro/features/rewards/toy_collection_service.dart';
import 'package:kids_king_pro/features/rewards/gacha_machine_dialog.dart';
import 'package:kids_king_pro/features/rewards/toy_collection_shelf_dialog.dart';
import 'package:kids_king_pro/features/pet/prince_leo_care_sheet.dart';
import 'package:kids_king_pro/features/bedtime/bedtime_wind_down_dialog.dart';
import 'package:kids_king_pro/features/certificates/royal_diploma_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Toy Collection & Gacha Machine Tests', () {
    test('ToyCollectionNotifier starts with starter toy and hatchEgg awards new toys', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = container.read(toyCollectionProvider);
      expect(initial.unlockedToyIds, contains('teddy_plush'));
      expect(initial.eggsAvailable, greaterThanOrEqualTo(1));

      final prevEggs = initial.eggsAvailable;
      final hatchedToy = container.read(toyCollectionProvider.notifier).hatchEgg();

      expect(hatchedToy, isNotNull);
      expect(hatchedToy.name.isNotEmpty, isTrue);

      final updated = container.read(toyCollectionProvider);
      expect(updated.eggsAvailable, equals(prevEggs - 1));
      expect(updated.unlockedToyIds, contains(hatchedToy.id));
    });

    test('addEggs increases egg count for gacha machine', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final before = container.read(toyCollectionProvider).eggsAvailable;
      await container.read(toyCollectionProvider.notifier).addEggs(3);
      final after = container.read(toyCollectionProvider).eggsAvailable;
      expect(after, equals(before + 3));
    });
  });

  group('MagicTouchOverlay Tests', () {
    testWidgets('MagicTouchOverlay renders child and responds to drag/pointer gestures without consuming taps', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MagicTouchOverlay(
              child: Center(
                child: ElevatedButton(
                  onPressed: () => tapped = true,
                  child: const Text('Tap Me Button'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me Button'), findsOneWidget);

      // Perform a drag across the screen to generate magic particles
      await tester.dragFrom(const Offset(50, 50), const Offset(150, 150));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the button through the overlay
      await tester.tap(find.text('Tap Me Button'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, isTrue);
    });
  });

  group('Engagement Dialogs Widget Tests', () {
    testWidgets('GachaMachineDialog renders crank and egg counter', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GachaMachineDialog(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('KRIDO Gacha Machine'), findsOneWidget);
      expect(find.textContaining('Eggs Left'), findsOneWidget);
      expect(find.textContaining('Toy Shelf'), findsOneWidget);
    });

    testWidgets('ToyCollectionShelfDialog renders all 8 toy pedestals', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ToyCollectionShelfDialog(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Royal Toy Shelf'), findsOneWidget);
      expect(find.textContaining('Collected'), findsOneWidget);
      expect(find.text('Honey Teddy Bear'), findsOneWidget);
    });

    testWidgets('PrinceLeoCareSheet renders pantry snacks and Prince Leo mascot', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PrinceLeoCareSheet(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Prince Leo Pantry'), findsOneWidget);
      expect(find.textContaining('Crispy Apple'), findsOneWidget);
      expect(find.textContaining('Fresh Milk'), findsOneWidget);
    });

    testWidgets('BedtimeWindDownDialog renders cozy bedtime mode', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BedtimeWindDownDialog(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Bedtime Wind-Down'), findsOneWidget);
      expect(find.textContaining('Goodnight Leo'), findsOneWidget);
    });

    testWidgets('RoyalDiplomaDialog renders diploma of excellence and print action', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RoyalDiplomaDialog(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('ROYAL KINGDOM OF KRIDO'), findsOneWidget);
      expect(find.text('DIPLOMA OF EXCELLENCE'), findsOneWidget);
      expect(find.textContaining('Save & Print'), findsOneWidget);
    });

    testWidgets('GachaMachineDialog supports turn crank and egg crack sequence on mobile portrait', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GachaMachineDialog(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('TURN CRANK!'), findsOneWidget);

      // Tap turn crank
      await tester.tap(find.textContaining('TURN CRANK!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 950));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump();

      // Should now be in egg cracking stage
      expect(find.textContaining('Tap Egg to Crack It Open!'), findsOneWidget);
    });

    testWidgets('PrinceLeoCareSheet feeds Leo a snack and updates speech reaction on mobile portrait', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PrinceLeoCareSheet(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Crispy Apple'), findsOneWidget);

      // Tap snack to feed Leo
      await tester.tap(find.textContaining('Crispy Apple'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Crunch crunch!'), findsOneWidget);
    });

    testWidgets('All engagement dialogs render cleanly in landscape mobile (640x360)', (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Gacha
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: GachaMachineDialog()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('KRIDO Gacha Machine'), findsOneWidget);

      // Toy Shelf
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: ToyCollectionShelfDialog()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Royal Toy Shelf'), findsOneWidget);

      // Bedtime
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BedtimeWindDownDialog()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Bedtime Wind-Down'), findsOneWidget);

      // Diploma
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: RoyalDiplomaDialog()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('ROYAL KINGDOM OF KRIDO'), findsOneWidget);
    });
  });
}
