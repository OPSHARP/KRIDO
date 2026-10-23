import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/features/worlds/game_adventure_map_screen.dart';
import 'package:kids_king_pro/features/worlds/worlds_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorldsScreen & GameAdventureMapScreen Tests', () {
    testWidgets('WorldsScreen renders GameAdventureMapScreen and contains no GridView',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WorldsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // No GridView exists anywhere in WorldsScreen
      expect(find.byType(GridView), findsNothing);

      // Adventure Map screen is rendered directly
      expect(find.byType(GameAdventureMapScreen), findsOneWidget);
      expect(find.text('ADVENTURE MAP'), findsOneWidget);
      expect(find.textContaining('Games Unlocked — Tap Any to Play!'), findsOneWidget);
    });

    testWidgets('Adventure Map displays unlocked game stations and category filters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameAdventureMapScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Stations are rendered
      expect(find.text('Pebble Circle'), findsOneWidget);
      expect(find.text('UNLOCKED'), findsWidgets);

      // Tap on Category Filter (e.g. Numbers)
      expect(find.text('Numbers'), findsOneWidget);
      await tester.tap(find.text('Numbers'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Pebble Circle'), findsOneWidget);
      expect(find.text('Count the Orchard'), findsOneWidget);
    });

    testWidgets('Tapping station opens preview sheet with Pixar mascot and PLAY button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameAdventureMapScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Pebble Circle station card
      await tester.tap(find.text('Pebble Circle'));
      await tester.pump(const Duration(milliseconds: 300));

      // Bottom sheet with 100% UNLOCKED and PLAY NOW
      expect(find.text('100% UNLOCKED'), findsOneWidget);
      expect(find.text('PLAY NOW! ▶'), findsOneWidget);
    });
  });
}
