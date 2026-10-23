import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/widgets/horizontal_bouncy_game_menu.dart';
import 'package:kids_king_pro/core/widgets/pixar_3d_icons.dart';
import 'package:kids_king_pro/features/parent/parent_gate_dialog.dart';
import 'package:kids_king_pro/games/game_factory.dart';
import 'package:kids_king_pro/games/modules/g080_musical_xylophone/g080_controller.dart';
import 'package:kids_king_pro/games/modules/g080_musical_xylophone/g080_view.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/features/game_shell/game_shell_screen.dart';
import 'package:kids_king_pro/games/modules/g001_number_pebble_circle/g001_controller.dart';
import 'package:kids_king_pro/games/modules/g001_number_pebble_circle/g001_view.dart';
import 'package:kids_king_pro/games/modules/g012_alpha_grid_tap/g012_controller.dart';
import 'package:kids_king_pro/games/modules/g012_alpha_grid_tap/g012_view.dart';
import 'package:kids_king_pro/games/modules/g031_shape_home/g031_controller.dart';
import 'package:kids_king_pro/games/modules/g031_shape_home/g031_view.dart';
import 'package:kids_king_pro/games/modules/g051_animal_jigsaw/g051_controller.dart';
import 'package:kids_king_pro/games/modules/g051_animal_jigsaw/g051_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_king_pro/features/world_builder/kingdom_world_builder_screen.dart';
import 'package:kids_king_pro/features/hub/landscape_learning_hub_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Senior Developer Audit Regression Tests', () {
    testWidgets('G080View renders back button in header and supports popping', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G080', tier: 1);
      final profile = Profile(id: 'p1', avatarId: 'avatar_lion', uiLocale: 'en');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: profile,
        seed: 1234,
      ) as G080Controller;
      await controller.initialize();

      bool didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => G080View(controller: controller),
                      ),
                    ).then((_) => didPop = true);
                  },
                  child: const Text('Open G080'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap to open G080
      await tester.tap(find.text('Open G080'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Find the back arrow button in G080 top header
      final backIcon = find.byIcon(Icons.arrow_back_rounded);
      expect(backIcon, findsOneWidget);

      // Tap back button
      await tester.tap(backIcon);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(didPop, isTrue);
      controller.dispose();
    });

    testWidgets('ParentGateDialog renders without overflow on 320px compact screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 320,
                height: 480,
                child: ParentGateDialog(onAuthenticated: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Parents Only'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('HorizontalBouncyGameMenu smoothly handles orientation switch in didUpdateWidget', (tester) async {
      final sampleIslands = [
        {
          'id': 'G001',
          'title': '1-1000 MOSAIC',
          'subtitle': 'Number Journey',
          'pixarType': PixarIconType.mosaic,
          'tag': '1-1000 MAP',
          'islandColor': const Color(0xFF1E88E5),
          'accent': const Color(0xFFFF5252),
        },
        {
          'id': 'G011',
          'title': 'LEARN ABCD',
          'subtitle': 'Phonics',
          'pixarType': PixarIconType.letter,
          'tag': 'A-Z PHONICS',
          'islandColor': const Color(0xFFAB47BC),
          'accent': const Color(0xFFFFD54F),
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalBouncyGameMenu(
              islands: sampleIslands,
              onLaunchGame: (_) {},
              isLandscape: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to landscape
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalBouncyGameMenu(
              islands: sampleIslands,
              onLaunchGame: (_) {},
              isLandscape: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Game 1 of 2'), findsOneWidget);
    });

    testWidgets('KingdomWorldBuilderScreen top action bar renders without overflow on narrow portrait screens', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: KingdomWorldBuilderScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Celebrate!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LandscapeLearningHubScreen renders cleanly without RenderFlex overflows in narrow portrait', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LandscapeLearningHubScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('MINI GAMES'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
    testWidgets('G001View renders back button in top-left corner and supports popping', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G001', tier: 1);
      final profile = Profile(id: 'p1', avatarId: 'avatar_lion', uiLocale: 'en');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: profile,
        seed: 1234,
      );
      await controller.initialize();

      bool didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => G001View(controller: controller as G001Controller),
                      ),
                    ).then((_) => didPop = true);
                  },
                  child: const Text('Open G001'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open G001'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      final backIcon = find.byIcon(Icons.arrow_back_rounded);
      expect(backIcon, findsOneWidget);

      await tester.tap(backIcon);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(didPop, isTrue);
      controller.dispose();
    });

    testWidgets('G051View renders back button in top-left and supports popping', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G051', tier: 1);
      final profile = Profile(id: 'p1', avatarId: 'avatar_lion', uiLocale: 'en');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: profile,
        seed: 1234,
      ) as G051Controller;
      await controller.initialize();

      bool didPop = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => G051View(controller: controller),
                      ),
                    ).then((_) => didPop = true);
                  },
                  child: const Text('Open G051'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open G051'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      final backIcon = find.byIcon(Icons.arrow_back_rounded);
      expect(backIcon, findsOneWidget);

      await tester.tap(backIcon);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(didPop, isTrue);
      controller.dispose();
    });

    testWidgets('G012View renders back button in top-left', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G012', tier: 1);
      final profile = Profile(id: 'p1', avatarId: 'avatar_lion', uiLocale: 'en');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: profile,
        seed: 1234,
      ) as G012Controller;
      await controller.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: G012View(controller: controller),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      controller.dispose();
    });

    testWidgets('G031View and G073View render back arrow in top-left instead of EXIT text', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G031', tier: 1);
      final profile = Profile(id: 'p1', avatarId: 'avatar_lion', uiLocale: 'en');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: profile,
        seed: 1234,
      ) as G031Controller;
      await controller.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: G031View(controller: controller),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('EXIT'), findsNothing);
      controller.dispose();
    });

    testWidgets('GameShellScreen top bar renders back button with arrow_back_rounded', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameShellScreen(gameId: 'G021', tier: 1),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  });
}

