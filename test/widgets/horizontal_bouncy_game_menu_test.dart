import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/widgets/horizontal_bouncy_game_menu.dart';
import 'package:kids_king_pro/core/widgets/pixar_3d_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleIslands = [
    {
      'id': 'G001',
      'title': '1-1000 MOSAIC',
      'subtitle': '1 to 1000 Number Journey',
      'pixarType': PixarIconType.mosaic,
      'tag': '1-1000 MAP',
      'islandColor': const Color(0xFF1E88E5),
      'accent': const Color(0xFFFF5252),
    },
    {
      'id': 'G011',
      'title': 'LEARN ABCD',
      'subtitle': 'Graphic Cards & Phonics SFX',
      'pixarType': PixarIconType.letter,
      'tag': 'A-Z PHONICS',
      'islandColor': const Color(0xFFAB47BC),
      'accent': const Color(0xFFFFD54F),
    },
    {
      'id': 'G080',
      'title': 'RAINBOW XYLO',
      'subtitle': '8-Note Musical Island',
      'pixarType': PixarIconType.shapes,
      'tag': 'MUSIC',
      'islandColor': const Color(0xFFE91E63),
      'accent': const Color(0xFFFFD54F),
    },
  ];

  testWidgets('HorizontalBouncyGameMenu displays one game at a time with swipe controls', (tester) async {
    String? launchedGameId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: HorizontalBouncyGameMenu(
              islands: sampleIslands,
              onLaunchGame: (id) => launchedGameId = id,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify initial state: Game 1 of 3 (1-1000 MOSAIC)
    expect(find.text('Game 1 of 3'), findsOneWidget);
    expect(find.text('1-1000 MOSAIC'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsWidgets);

    // Tap to launch game
    await tester.tap(find.text('1-1000 MOSAIC'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(launchedGameId, equals('G001'));

    // Swipe horizontally to next game (from right to left to advance page)
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify second game is now shown
    expect(find.text('Game 2 of 3'), findsOneWidget);
    expect(find.text('LEARN ABCD'), findsOneWidget);

    // Tap right arrow to advance to third game
    final forwardArrowFinder = find.byIcon(Icons.arrow_forward_ios_rounded);
    expect(forwardArrowFinder, findsOneWidget);
    await tester.tap(forwardArrowFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify third game is now shown
    expect(find.text('Game 3 of 3'), findsOneWidget);
    expect(find.text('RAINBOW XYLO'), findsOneWidget);
  });

  testWidgets('HorizontalBouncyGameMenu renders toyBox and dioramaStage styles cleanly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: HorizontalBouncyGameMenu(
              islands: sampleIslands,
              cardStyle: GameCardStyle.toyBox,
              onLaunchGame: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('1-1000 MOSAIC'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsWidgets);
  });
}
