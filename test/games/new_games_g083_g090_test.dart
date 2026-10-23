import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/game_factory.dart';
import 'package:kids_king_pro/games/modules/g083_color_mixing_lab/g083_controller.dart';
import 'package:kids_king_pro/games/modules/g083_color_mixing_lab/g083_view.dart';
import 'package:kids_king_pro/games/modules/g084_toothbrush_hero/g084_controller.dart';
import 'package:kids_king_pro/games/modules/g084_toothbrush_hero/g084_view.dart';
import 'package:kids_king_pro/games/modules/g085_detective_leo/g085_controller.dart';
import 'package:kids_king_pro/games/modules/g085_detective_leo/g085_view.dart';
import 'package:kids_king_pro/games/modules/g086_space_explorer/g086_controller.dart';
import 'package:kids_king_pro/games/modules/g086_space_explorer/g086_view.dart';
import 'package:kids_king_pro/games/modules/g087_feeling_mirror/g087_controller.dart';
import 'package:kids_king_pro/games/modules/g087_feeling_mirror/g087_view.dart';
import 'package:kids_king_pro/games/modules/g088_dino_bone_digger/g088_controller.dart';
import 'package:kids_king_pro/games/modules/g088_dino_bone_digger/g088_view.dart';
import 'package:kids_king_pro/games/modules/g089_balloon_fiesta/g089_controller.dart';
import 'package:kids_king_pro/games/modules/g089_balloon_fiesta/g089_view.dart';
import 'package:kids_king_pro/games/modules/g090_size_stacker/g090_controller.dart';
import 'package:kids_king_pro/games/modules/g090_size_stacker/g090_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProfile = Profile(
    id: 'test_child',
    avatarId: 'avatar_fox',
    nickname: 'Hero',
    uiLocale: 'en',
  );

  group('New Mini-Games (G083 to G090) Tests', () {
    testWidgets('G083 Color Mixing Lab lifecycle and view render', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G083');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      ) as G083Controller;

      await controller.initialize();
      controller.start();
      expect(controller.state, GameLifecycleState.playing);
      expect(controller.primaryColors.length, greaterThanOrEqualTo(3));

      // Pump View inside fixed phone size
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: G083View(controller: controller)));
      await tester.pump();
      expect(find.byType(G083View), findsOneWidget);
    });

    testWidgets('G084 Toothbrush Hero lifecycle and view render', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G084');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      ) as G084Controller;

      await controller.initialize();
      controller.start();
      expect(controller.state, GameLifecycleState.playing);
      expect(controller.zones.length, greaterThanOrEqualTo(4));

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: G084View(controller: controller)));
      await tester.pump();
      expect(find.byType(G084View), findsOneWidget);
    });

    testWidgets('G085 Detective Leo lifecycle and view render', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G085');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      ) as G085Controller;

      await controller.initialize();
      controller.start();
      expect(controller.state, GameLifecycleState.playing);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: G085View(controller: controller)));
      await tester.pump();
      expect(find.byType(G085View), findsOneWidget);
    });

    testWidgets('G086 Space Explorer lifecycle and view render', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G086');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      ) as G086Controller;

      await controller.initialize();
      controller.start();
      expect(controller.state, GameLifecycleState.playing);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: G086View(controller: controller)));
      await tester.pump();
      expect(find.byType(G086View), findsOneWidget);
    });

    testWidgets('G087 Feeling Mirror lifecycle and view render', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G087');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      ) as G087Controller;

      await controller.initialize();
      controller.start();
      expect(controller.state, GameLifecycleState.playing);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: G087View(controller: controller)));
      await tester.pump();
      expect(find.byType(G087View), findsOneWidget);
    });

    testWidgets('G088 Dino Bone Digger lifecycle and view render', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G088');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      ) as G088Controller;

      await controller.initialize();
      controller.start();
      expect(controller.state, GameLifecycleState.playing);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: G088View(controller: controller)));
      await tester.pump();
      expect(find.byType(G088View), findsOneWidget);
    });

    testWidgets('G089 Balloon Fiesta lifecycle and view render', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G089');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      ) as G089Controller;

      await controller.initialize();
      controller.start();
      expect(controller.state, GameLifecycleState.playing);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: G089View(controller: controller)));
      await tester.pump();
      expect(find.byType(G089View), findsOneWidget);
    });

    testWidgets('G090 Size Stacker lifecycle and view render', (tester) async {
      final challenge = GameFactory.createDefaultChallenge('G090');
      final controller = GameFactory.createController(
        challenge: challenge,
        profile: testProfile,
        seed: 42,
      ) as G090Controller;

      await controller.initialize();
      controller.start();
      expect(controller.state, GameLifecycleState.playing);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(home: G090View(controller: controller)));
      await tester.pump();
      expect(find.byType(G090View), findsOneWidget);
    });
  });
}
