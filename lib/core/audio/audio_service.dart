import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'procedural_sfx_engine.dart';

enum AudioBus { master, music, sfx, narration }

enum SoundCue {
  press,
  correct,
  wrong,
  match,
  snap,
  hint,
  complete,
  star,
  drop,
  pageTurn,
  tiltWhoosh,
  timeShift,
  micListen,
  mascotRoar,
  cardHover,
  coin,
  cheer,
  drumRoll,
  trumpet,
  magic,
  bubble,
  roar,
  purr,
}

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  double _masterVolume = 0.70;
  double _musicVolume = 0.25;
  double _sfxVolume = 0.55;
  double _narrationVolume = 0.80;

  bool _isMuted = false;
  bool _isDucked = false;
  bool _isGentleMode = false;

  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get narrationVolume => _narrationVolume;
  bool get isMuted => _isMuted;
  bool get isGentleMode => _isGentleMode;

  void setGentleMode(bool enabled) {
    if (_isGentleMode != enabled) {
      _isGentleMode = enabled;
      if (_isGentleMode) {
        _masterVolume = 0.40;
        _sfxVolume = 0.35;
        _musicVolume = 0.20;
      } else {
        _masterVolume = 0.70;
        _sfxVolume = 0.55;
        _musicVolume = 0.25;
      }
      ProceduralSfxEngine().setVolume(_masterVolume * _sfxVolume);
      ProceduralSfxEngine().setBgmVolume(_musicVolume);
      notifyListeners();
    }
  }

  // Debouncing identical audio cues
  final Map<SoundCue, int> _lastPlayedCueMs = {};

  void setVolume(AudioBus bus, double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    switch (bus) {
      case AudioBus.master:
        _masterVolume = clamped;
        ProceduralSfxEngine().setVolume(_masterVolume * _sfxVolume);
        ProceduralSfxEngine().setBgmVolume(_musicVolume);
        break;
      case AudioBus.music:
        _musicVolume = clamped;
        ProceduralSfxEngine().setBgmVolume(_musicVolume);
        break;
      case AudioBus.sfx:
        _sfxVolume = clamped;
        ProceduralSfxEngine().setVolume(_masterVolume * _sfxVolume);
        break;
      case AudioBus.narration:
        _narrationVolume = clamped;
        break;
    }
    notifyListeners();
  }

  void toggleMute() {
    setMuted(!_isMuted);
  }

  void setMuted(bool mute) {
    if (_isMuted != mute) {
      _isMuted = mute;
      ProceduralSfxEngine().setMuted(mute);
      notifyListeners();
    }
  }

  /// Start looping royalty-free background music
  Future<void> startBackgroundMusic() async {
    if (!_isMuted) {
      await ProceduralSfxEngine().startBgm();
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    await ProceduralSfxEngine().stopBgm();
  }

  /// Pause background music when leaving the foreground
  Future<void> pauseBackgroundMusic() async {
    await ProceduralSfxEngine().pauseBgm();
  }

  /// Resume background music when returning to the app
  Future<void> resumeBackgroundMusic() async {
    if (!_isMuted) {
      await ProceduralSfxEngine().resumeBgm();
    }
  }

  /// Play animal vocalization sound
  Future<void> playAnimalSound(String soundText, String animalId, {bool isHindi = false}) async {
    if (_isMuted) return;
    await ProceduralSfxEngine().playAnimalSound(soundText, animalId, isHindi: isHindi);
  }

  /// Play a sound effect with safety debounce and fallback
  Future<void> playCue(SoundCue cue) async {
    if (_isMuted || _masterVolume == 0 || _sfxVolume == 0) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastPlayedCueMs[cue] ?? 0;
    if (now - lastTime < 100) return; // 100ms debounce
    _lastPlayedCueMs[cue] = now;

    // Procedural sound effect playback (100% royalty free)
    try {
      final sfx = ProceduralSfxEngine();
      switch (cue) {
        case SoundCue.press:
        case SoundCue.drop:
          sfx.playPop();
          break;
        case SoundCue.correct:
        case SoundCue.match:
        case SoundCue.snap:
          sfx.playDing();
          break;
        case SoundCue.wrong:
          sfx.playWrongBuzzer();
          break;
        case SoundCue.complete:
          sfx.playFanfare();
          break;
        case SoundCue.star:
          sfx.playSparkle();
          break;
        case SoundCue.hint:
          sfx.playBell();
          break;
        case SoundCue.pageTurn:
        case SoundCue.tiltWhoosh:
        case SoundCue.cardHover:
          sfx.playWhoosh();
          break;
        case SoundCue.mascotRoar:
        case SoundCue.roar:
          sfx.playRoar();
          break;
        case SoundCue.purr:
          sfx.playPurr();
          break;
        case SoundCue.coin:
          sfx.playCoin();
          break;
        case SoundCue.cheer:
          sfx.playCheer();
          break;
        case SoundCue.drumRoll:
          sfx.playDrumRoll();
          break;
        case SoundCue.trumpet:
          sfx.playTrumpet();
          break;
        case SoundCue.magic:
          sfx.playMagic();
          break;
        case SoundCue.bubble:
          sfx.playBubble();
          break;
        default:
          sfx.playPop();
          break;
      }
    } catch (_) {
      // Ignored in test environment
    }

    // Tactile haptic feedback mapped to cue intensity
    try {
      Future<void>? hapticFuture;
      switch (cue) {
        case SoundCue.press:
        case SoundCue.drop:
        case SoundCue.pageTurn:
        case SoundCue.timeShift:
        case SoundCue.micListen:
        case SoundCue.coin:
        case SoundCue.magic:
        case SoundCue.bubble:
        case SoundCue.purr:
          hapticFuture = HapticFeedback.lightImpact();
          break;
        case SoundCue.correct:
        case SoundCue.match:
        case SoundCue.snap:
        case SoundCue.mascotRoar:
        case SoundCue.roar:
        case SoundCue.trumpet:
          hapticFuture = HapticFeedback.mediumImpact();
          break;
        case SoundCue.complete:
        case SoundCue.star:
        case SoundCue.cheer:
          hapticFuture = HapticFeedback.heavyImpact();
          break;
        case SoundCue.wrong:
          hapticFuture = HapticFeedback.vibrate();
          break;
        case SoundCue.hint:
        case SoundCue.tiltWhoosh:
        case SoundCue.cardHover:
        case SoundCue.drumRoll:
          hapticFuture = HapticFeedback.selectionClick();
          break;
      }
      hapticFuture.catchError((_) {});
    } catch (_) {
      // Graceful fallback on unsupported platforms/tests
    }
  }

  /// Spoken instruction or letter pronunciation
  Future<void> playNarration(String textOrKey) async {
    if (_isMuted || _masterVolume == 0 || _narrationVolume == 0) return;

    // Duck music by 12dB (~50% linear drop) while narration is playing
    _isDucked = true;
    ProceduralSfxEngine().setBgmVolume(_musicVolume * 0.35);
    notifyListeners();

    try {
      await ProceduralSfxEngine().speakWord(textOrKey);
    } catch (_) {}

    // Complete narration
    await Future.delayed(const Duration(milliseconds: 500));
    _isDucked = false;
    ProceduralSfxEngine().setBgmVolume(_musicVolume);
    notifyListeners();
  }

  double effectiveVolume(AudioBus bus) {
    if (_isMuted) return 0.0;
    switch (bus) {
      case AudioBus.master:
        return _masterVolume;
      case AudioBus.music:
        return _masterVolume * _musicVolume * (_isDucked ? 0.35 : 1.0);
      case AudioBus.sfx:
        return _masterVolume * _sfxVolume;
      case AudioBus.narration:
        return _masterVolume * _narrationVolume;
    }
  }
}
