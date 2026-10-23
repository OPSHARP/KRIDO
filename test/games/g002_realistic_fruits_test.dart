import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/games/modules/g002_count_orchard/realistic_fruit_painter.dart';
import 'package:kids_king_pro/games/modules/g002_count_orchard/g002_controller.dart';
import 'package:kids_king_pro/games/modules/g002_count_orchard/g002_view.dart';
import 'package:kids_king_pro/games/game_factory.dart';
import 'package:kids_king_pro/domain/models/profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProfile = Profile(
    id: 'test_child_fruit',
    avatarId: 'avatar_fox',
    nickname: 'Foxie',
    uiLocale: 'en',
  );

  group('Realistic Fruit Rendering Tests (G002 Count Orchard)', () {
    testWidgets('RealisticFruitWidget renders for all 8 fruit varieties without throwing', (tester) async {
      const fruits = [
        'apple',
        'banana',
        'orange',
        'strawberry',
        'watermelon',
        'grapes',
        'mango',
        'cherry',
      ];

      for (final fruitId in fruits) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: RealisticFruitWidget(
                  fruitKindId: fruitId,
                  size: 60,
                  isCountTapped: true,
                  tapOrder: 1,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(RealisticFruitWidget), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      }
    });

    testWidgets('G002View renders realistic fruits on the living tree and question banner', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G002', tier: 1);
      final controller = G002Controller(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
        overrideFruitCount: 5,
      );

      await controller.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: G002View(controller: controller),
          ),
        ),
      );
      await tester.pump();

      // Verify that RealisticFruitWidgets are rendered in the view
      expect(find.byType(RealisticFruitWidget), findsWidgets);

      // Verify actual fruit count matches
      expect(controller.actualCount, equals(5));
      expect(controller.fruits.length, equals(5));
    });
  });
}
