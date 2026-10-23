import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/widgets/interactive_floating_island.dart';
import 'package:kids_king_pro/core/widgets/interactive_island_map_view.dart';
import 'package:kids_king_pro/core/widgets/pixar_3d_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testIslandData = {
    'id': 'G011',
    'title': 'LEARN ABCD',
    'subtitle': 'Graphic Cards & Phonics',
    'pixarType': PixarIconType.letter,
    'tag': 'A-Z PHONICS',
    'islandColor': const Color(0xFFAB47BC),
    'accent': const Color(0xFFFFD54F),
    'stars': 3,
  };

  group('InteractiveFloatingIsland Tests', () {
    testWidgets('Renders floating island elements, title, tag, and play button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: InteractiveFloatingIsland(
                islandData: testIslandData,
                index: 0,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('LEARN ABCD'), findsOneWidget);
      expect(find.text('A-Z PHONICS'), findsOneWidget);
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.byType(InteractiveFloatingIsland), findsOneWidget);
    });

    testWidgets('Touch gesture triggers tap response and callback',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: InteractiveFloatingIsland(
                islandData: testIslandData,
                index: 1,
                onTap: () {
                  wasTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap on the island
      await tester.tap(find.text('LEARN ABCD'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(wasTapped, isTrue);
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('InteractiveIslandMapView Tests', () {
    final islands = [
      testIslandData,
      {
        'id': 'G002',
        'title': 'COUNT APPLES',
        'subtitle': 'Living Orchard',
        'pixarType': PixarIconType.apple,
        'tag': 'NUMBERS',
        'islandColor': const Color(0xFF66BB6A),
        'accent': const Color(0xFFFF5252),
        'stars': 3,
      },
      {
        'id': 'G077',
        'title': 'ANIMAL QUIZ',
        'subtitle': 'Name The Animal',
        'pixarType': PixarIconType.animalQuiz,
        'tag': 'ANIMALS',
        'islandColor': const Color(0xFFFFA000),
        'accent': const Color(0xFF00E5FF),
        'stars': 3,
      },
    ];

    testWidgets('Renders in Landscape mode along winding archipelago trail',
        (WidgetTester tester) async {
      String? launchedGame;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 400,
              child: InteractiveIslandMapView(
                islands: islands,
                isLandscape: true,
                onLaunchGame: (id) => launchedGame = id,
              ),
            ),
          ),
        ),
      );

      expect(find.text('LEARN ABCD'), findsOneWidget);
      expect(find.text('COUNT APPLES'), findsOneWidget);
      expect(find.text('ANIMAL QUIZ'), findsOneWidget);

      await tester.tap(find.text('ANIMAL QUIZ'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(launchedGame, equals('G077'));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('Renders in Portrait mode with S-curve vertical trail',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 700,
              child: InteractiveIslandMapView(
                islands: islands,
                isLandscape: false,
                onLaunchGame: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('LEARN ABCD'), findsOneWidget);
      expect(find.text('COUNT APPLES'), findsOneWidget);
      expect(find.text('ANIMAL QUIZ'), findsOneWidget);
    });
  });
}
