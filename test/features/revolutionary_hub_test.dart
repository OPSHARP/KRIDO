import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/environment/celestial_time_engine.dart';
import 'package:kids_king_pro/core/motion/parallax_tilt_controller.dart';
import 'package:kids_king_pro/core/voice/voice_navigation_controller.dart';

void main() {
  group('CelestialTimeEngine Tests', () {
    test('Default initialization resolves a valid phase', () {
      final engine = CelestialTimeEngine();
      expect(engine.currentPhase, isNotNull);
      expect(engine.isAutoRealTime, isTrue);
    });

    test('Cycle next phase changes phase in sequence and sets manual override', () {
      final engine = CelestialTimeEngine(initialPhase: CelestialPhase.dawn);
      expect(engine.currentPhase, CelestialPhase.dawn);

      engine.cycleNextPhase();
      expect(engine.currentPhase, CelestialPhase.day);
      expect(engine.isAutoRealTime, isFalse);

      engine.cycleNextPhase();
      expect(engine.currentPhase, CelestialPhase.sunset);

      engine.cycleNextPhase();
      expect(engine.currentPhase, CelestialPhase.night);

      engine.cycleNextPhase();
      expect(engine.currentPhase, CelestialPhase.dawn);
    });

    test('Set phase directly updates current phase', () {
      final engine = CelestialTimeEngine();
      engine.setPhase(CelestialPhase.night);
      expect(engine.currentPhase, CelestialPhase.night);
    });
  });

  group('ParallaxTiltController Tests', () {
    test('Calculates normalized tilt and clamps within [-1.0, 1.0]', () {
      final controller = ParallaxTiltController();

      controller.updatePan(const Offset(800, 400), const Size(800, 400));
      expect(controller.tiltX, inInclusiveRange(-1.0, 1.0));
      expect(controller.tiltY, inInclusiveRange(-1.0, 1.0));
      expect(controller.isDragging, isTrue);

      controller.releasePan();
      expect(controller.isDragging, isFalse);
    });

    test('updateAmbientTick adjusts tilt gracefully when not dragging', () {
      final controller = ParallaxTiltController();
      controller.updateAmbientTick(1.0);
      expect(controller.tiltX, isNotNull);
      expect(controller.tiltY, isNotNull);
    });
  });

  group('VoiceNavigationController Tests', () {
    test('Executes verbal command for games correctly', () {
      final controller = VoiceNavigationController();

      controller.executeVerbalCommand('play puppy puzzle');
      expect(controller.currentDialogue, contains('Doggy Puzzle'));

      controller.executeVerbalCommand('count orchard apples please');
      expect(controller.currentDialogue, contains('apples'));

      controller.executeVerbalCommand('find the letter');
      expect(controller.currentDialogue, contains('Letter'));
    });

    test('Executes verbal command for celestial time shift', () {
      final controller = VoiceNavigationController();
      CelestialPhase? targetPhase;
      controller.onChangePhase = (phase) {
        targetPhase = phase;
      };

      controller.executeVerbalCommand('make it nighttime stars');
      expect(targetPhase, CelestialPhase.night);
      expect(controller.currentDialogue, contains('Starry Night'));

      controller.executeVerbalCommand('good morning sunny daytime');
      expect(targetPhase, CelestialPhase.day);
      expect(controller.currentDialogue, contains('Sunny Day'));
    });

    test('Mascot poke reaction triggers playful response', () {
      final controller = VoiceNavigationController();
      controller.pokeMascot();
      expect(controller.mood, MascotMood.excited);
      expect(controller.currentDialogue.isNotEmpty, isTrue);
    });
  });
}
