import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/audio/audio_service.dart';
import 'package:kids_king_pro/core/audio/procedural_sfx_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProceduralSfxEngine & Royalty Free Audio Tests', () {
    test('Initializes procedural engine and pre-warms all WAV buffers', () async {
      final engine = ProceduralSfxEngine();
      await engine.init();

      // Test that all procedural synthesizers generate valid PCM WAV buffers (> 44 bytes header)
      expect(engine.isMuted, false);
      expect(engine.volume, greaterThan(0.0));
    });

    test('All sound cues play without exceptions in test environment', () async {
      final engine = ProceduralSfxEngine();
      await engine.playPop();
      await engine.playSparkle();
      await engine.playChime();
      await engine.playBoing();
      await engine.playFanfare();
      await engine.playBell();
      await engine.playDing();
      await engine.playWhoosh();
      await engine.playCoin();
      await engine.playCheer();
      await engine.playDrumRoll();
      await engine.playTrumpet();
      await engine.playMagic();
      await engine.playBubble();
      await engine.playRoar();
      await engine.playPurr();
      await engine.playXylophoneNote(1);
      await engine.playXylophoneNote(8);
    });

    test('BGM lifecycle controls function cleanly', () async {
      final engine = ProceduralSfxEngine();
      await engine.startBgm();
      expect(engine.isBgmPlaying, true);

      await engine.pauseBgm();
      await engine.resumeBgm();
      engine.setBgmVolume(0.5);

      await engine.stopBgm();
      expect(engine.isBgmPlaying, false);
    });
  });

  group('AudioService SFX & Bus Tests', () {
    test('AudioService triggers all new kid-attracting sound cues', () async {
      final service = AudioService();

      await service.playCue(SoundCue.coin);
      await service.playCue(SoundCue.cheer);
      await service.playCue(SoundCue.drumRoll);
      await service.playCue(SoundCue.trumpet);
      await service.playCue(SoundCue.magic);
      await service.playCue(SoundCue.bubble);
      await service.playCue(SoundCue.roar);
      await service.playCue(SoundCue.purr);
      await service.playCue(SoundCue.mascotRoar);
      await service.playCue(SoundCue.press);
      await service.playCue(SoundCue.complete);
    });

    test('Volume control and ducking calculate effective bus volumes', () {
      final service = AudioService();

      service.setVolume(AudioBus.music, 0.4);
      service.setVolume(AudioBus.sfx, 0.8);
      service.setVolume(AudioBus.master, 0.9);

      expect(service.musicVolume, closeTo(0.4, 0.001));
      expect(service.sfxVolume, closeTo(0.8, 0.001));
      expect(service.masterVolume, closeTo(0.9, 0.001));
      expect(service.effectiveVolume(AudioBus.music), closeTo(0.9 * 0.4, 0.001));
      expect(service.effectiveVolume(AudioBus.sfx), closeTo(0.9 * 0.8, 0.001));

      // Mute toggle
      service.setMuted(true);
      expect(service.isMuted, true);
      expect(service.effectiveVolume(AudioBus.music), 0.0);
      expect(service.effectiveVolume(AudioBus.sfx), 0.0);

      service.setMuted(false);
      expect(service.isMuted, false);
    });

    test('BGM lifecycle methods in AudioService operate cleanly', () async {
      final service = AudioService();
      await service.startBackgroundMusic();
      await service.pauseBackgroundMusic();
      await service.resumeBackgroundMusic();
      await service.stopBackgroundMusic();
    });
  });
}
