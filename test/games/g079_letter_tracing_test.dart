import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/challenge.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/modules/g079_letter_tracing/g079_controller.dart';
import 'package:kids_king_pro/games/modules/g079_letter_tracing/g079_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProfile = Profile(
    id: 'child_tester',
    avatarId: 'avatar_cat',
    nickname: 'Ananya',
    uiLocale: 'en',
  );

  const testChallenge = Challenge(
    id: 'G079_T1_C01',
    gameId: 'G079',
    tier: 1,
    promptEn: 'Trace the letter with your finger!',
    promptHi: 'उंगली से अक्षर बनाएं!',
    taskData: {},
    validAnswers: [],
  );

  group('G079 Letter Tracing Mini-Game Tests', () {
    test('Initializes with alphabet deck starting on Letter A with stroke waypoints', () async {
      final controller = G079Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 102,
      );

      await controller.initialize();

      expect(controller.letterDeck.length, greaterThanOrEqualTo(5));
      expect(controller.currentLetter.letter, 'A');
      expect(controller.currentLetter.word, 'Apple');
      expect(controller.currentLetter.emoji, '🍎');
      expect(controller.currentLetter.strokes.isNotEmpty, true);
      expect(controller.completionRatio, 0.0);
      expect(controller.isLetterCompleted, false);
    });

    test('Panning over waypoints registers hits and computes completion ratio', () async {
      final controller = G079Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 102,
      );
      await controller.initialize();

      final firstStroke = controller.currentLetter.strokes.first;
      final wp1 = firstStroke.waypoints[0];
      final wp2 = firstStroke.waypoints[1];

      controller.onPanStart(Offset(wp1.x, wp1.y));
      expect(wp1.isHit, true);
      expect(controller.completionRatio, greaterThan(0.0));

      controller.onPanUpdate(Offset(wp2.x, wp2.y));
      expect(wp2.isHit, true);
      expect(controller.userDrawnStrokes.isNotEmpty, true);
    });

    test('Tracing through all waypoints triggers letter completion and star celebration', () async {
      final controller = G079Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 102,
      );
      await controller.initialize();

      // Pan through all waypoints of Letter A
      for (final stroke in controller.currentLetter.strokes) {
        if (stroke.waypoints.isEmpty) continue;
        final start = stroke.waypoints.first;
        controller.onPanStart(Offset(start.x, start.y));

        for (final wp in stroke.waypoints) {
          controller.onPanUpdate(Offset(wp.x, wp.y));
        }
      }

      controller.onPanEnd();

      expect(controller.isLetterCompleted, true);
      expect(controller.completionRatio, greaterThanOrEqualTo(0.85));
    });

    test('nextLetter advances to Letter B and resets strokes', () async {
      final controller = G079Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 102,
      );
      await controller.initialize();

      // Mark letter A complete
      controller.onPanStart(const Offset(0.5, 0.15));
      controller.nextLetter();

      expect(controller.currentLetter.letter, 'B');
      expect(controller.currentLetter.word, 'Ball');
      expect(controller.isLetterCompleted, false);
      expect(controller.completionRatio, 0.0);
      expect(controller.userDrawnStrokes.isEmpty, true);
    });

    test('Completing all letters in deck completes the mini-game', () async {
      final controller = G079Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 102,
      );
      await controller.initialize();

      // Advance through all letters
      final totalLetters = controller.letterDeck.length;
      for (int i = 0; i < totalLetters; i++) {
        controller.nextLetter();
      }

      expect(controller.state, GameLifecycleState.completed);
    });

    testWidgets('G079View renders cleanly on mobile screen without overflows and supports controls', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = G079Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 102,
      );
      await controller.initialize();
      controller.start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: G079View(controller: controller),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Header and active letter banner
      expect(find.textContaining('A for Apple'), findsOneWidget);
      expect(find.text('Erase'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next button to advance to B
      await tester.tap(find.text('Next'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(controller.currentLetter.letter, 'B');
      expect(find.textContaining('B for Ball'), findsOneWidget);
    });
  });
}
