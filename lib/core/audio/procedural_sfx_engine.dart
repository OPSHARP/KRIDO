import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 100% Royalty-Free, Offline Procedural Sound Effects & Music Engine.
/// Synthesizes PCM 16-bit WAV audio in memory with zero external assets,
/// zero copyright restrictions, zero network dependencies, and instant playback.
class ProceduralSfxEngine {
  static final ProceduralSfxEngine _instance = ProceduralSfxEngine._internal();
  factory ProceduralSfxEngine() => _instance;
  ProceduralSfxEngine._internal();

  // SFX Player Pool (4 players) for multi-voice concurrent sound effects
  final List<AudioPlayer> _sfxPool = [];
  int _sfxPoolIndex = 0;

  // Dedicated Background Music (BGM) Player
  AudioPlayer? _bgmPlayer;
  Uint8List? _bgmWavBytes;
  bool _isBgmPlaying = false;
  double _bgmVolume = 0.35;

  FlutterTts? _flutterTts;
  bool _ttsInitialized = false;
  bool _ttsAvailable = true;

  bool get _isTestEnvironment {
    try {
      return !kIsWeb && io.Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  AudioPlayer? _getNextSfxPlayer() {
    if (_isTestEnvironment) return null;
    if (_sfxPool.isEmpty) {
      for (int i = 0; i < 4; i++) {
        try {
          final p = AudioPlayer();
          p.setVolume(_volume);
          _sfxPool.add(p);
        } catch (_) {}
      }
    }
    if (_sfxPool.isEmpty) return null;
    final player = _sfxPool[_sfxPoolIndex % _sfxPool.length];
    _sfxPoolIndex++;
    return player;
  }

  AudioPlayer? _getBgmPlayer() {
    if (_isTestEnvironment) return null;
    if (_bgmPlayer == null) {
      try {
        _bgmPlayer = AudioPlayer();
        _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
        _bgmPlayer!.setVolume(_isMuted ? 0.0 : (_volume * _bgmVolume));
      } catch (_) {}
    }
    return _bgmPlayer;
  }

  // Cached procedural WAV byte buffers for instant latency-free playback
  Uint8List? _popWavBytes;
  Uint8List? _sparkleWavBytes;
  Uint8List? _boingWavBytes;
  Uint8List? _fanfareWavBytes;
  Uint8List? _bellWavBytes;
  Uint8List? _dingWavBytes;
  Uint8List? _whooshWavBytes;
  Uint8List? _coinWavBytes;
  Uint8List? _cheerWavBytes;
  Uint8List? _drumRollWavBytes;
  Uint8List? _trumpetWavBytes;
  Uint8List? _magicWavBytes;
  Uint8List? _bubbleWavBytes;
  Uint8List? _roarWavBytes;
  Uint8List? _purrWavBytes;
  Uint8List? _buzzerWavBytes;
  Uint8List? _barkWavBytes;
  Uint8List? _meowWavBytes;
  Uint8List? _mooWavBytes;
  Uint8List? _quackWavBytes;
  Uint8List? _baaWavBytes;
  Uint8List? _ribbitWavBytes;
  Uint8List? _elephantWavBytes;
  Uint8List? _monkeyWavBytes;
  Uint8List? _bearWavBytes;

  final Map<int, Uint8List> _xyloWavBytes = {};

  bool _isMuted = false;
  double _volume = 0.85;

  bool get isMuted => _isMuted;
  double get volume => _volume;
  bool get isBgmPlaying => _isBgmPlaying;

  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      try {
        for (final p in _sfxPool) {
          p.stop().catchError((_) {});
        }
        _bgmPlayer?.pause().catchError((_) {});
        _flutterTts?.stop().catchError((_) {});
      } catch (_) {}
    } else {
      if (_isBgmPlaying) {
        _bgmPlayer?.resume().catchError((_) {});
      }
    }
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    try {
      for (final p in _sfxPool) {
        p.setVolume(_isMuted ? 0.0 : _volume).catchError((_) {});
      }
      _bgmPlayer?.setVolume(_isMuted ? 0.0 : (_volume * _bgmVolume)).catchError((_) {});
      _flutterTts?.setVolume(_isMuted ? 0.0 : _volume).catchError((_) {});
    } catch (_) {}
  }

  /// Light, zero-overhead initialization. Audio buffers are synthesized on-demand in <1ms.
  Future<void> init() async {
    // Zero heavy work on startup - all SFX are synthesized on-demand
  }

  Future<void> _initTts() async {
    if (_isTestEnvironment || _ttsInitialized || !_ttsAvailable) return;
    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage('en-US');
      await _flutterTts!.setSpeechRate(0.44);
      await _flutterTts!.setPitch(1.20);
      await _flutterTts!.setVolume(_volume);
      try {
        await _flutterTts!.awaitSpeakCompletion(true);
      } catch (_) {}
      _ttsInitialized = true;
    } catch (_) {
      _ttsAvailable = false;
    }
  }

  // ===========================================================================
  // BACKGROUND MUSIC (BGM) (100% Royalty Free, Looping In Memory)
  // ===========================================================================

  /// Start playing the royalty-free gentle Kingdom BGM with continuous looping
  Future<void> startBgm() async {
    _isBgmPlaying = true;
    if (_isTestEnvironment) return;
    try {
      final player = _getBgmPlayer();
      if (player == null) return;
      _bgmWavBytes ??= _synthesizeKingdomBgmWav();
      await player.stop().catchError((_) {});
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_isMuted ? 0.0 : (_volume * _bgmVolume));
      await player.play(BytesSource(_bgmWavBytes!, mimeType: 'audio/wav'));
    } catch (_) {}
  }

  /// Stop background music
  Future<void> stopBgm() async {
    _isBgmPlaying = false;
    try {
      await _bgmPlayer?.stop();
    } catch (_) {}
  }

  /// Pause background music (e.g. when app goes to background)
  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer?.pause();
    } catch (_) {}
  }

  /// Resume background music
  Future<void> resumeBgm() async {
    if (!_isBgmPlaying || _isMuted) return;
    try {
      if (_bgmPlayer == null) {
        await startBgm();
      } else {
        await _bgmPlayer?.resume();
      }
    } catch (_) {}
  }

  /// Set BGM volume ratio (0.0 to 1.0)
  void setBgmVolume(double vol) {
    _bgmVolume = vol.clamp(0.0, 1.0);
    try {
      _bgmPlayer?.setVolume(_isMuted ? 0.0 : (_volume * _bgmVolume)).catchError((_) {});
    } catch (_) {}
  }

  /// Cleanly release audio resources
  Future<void> dispose() async {
    for (final p in _sfxPool) {
      try {
        await p.dispose();
      } catch (_) {}
    }
    _sfxPool.clear();
    try {
      await _bgmPlayer?.dispose();
    } catch (_) {}
    _bgmPlayer = null;
    try {
      await _flutterTts?.stop();
    } catch (_) {}
  }

  // ===========================================================================
  // PROCEDURAL SOUND EFFECTS (100% Royalty Free, Instant Multi-Voice Playback)
  // ===========================================================================

  Future<void> _playWav(Uint8List wavBytes, String sfxName) async {
    if (_isMuted) return;
    try {
      final player = _getNextSfxPlayer();
      if (player != null) {
        await player.stop().catchError((_) {});
        await player.setVolume(_volume);
        await player.play(BytesSource(wavBytes, mimeType: 'audio/wav'));
      }
    } catch (_) {}
  }

  int _lastPopTimestamp = 0;

  /// Cheerful bubble pop for letter tap / button tap with tactile physical feedback
  Future<void> playPop() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastPopTimestamp < 45) return;
    _lastPopTimestamp = now;
    HapticFeedback.lightImpact().catchError((_) {});
    _popWavBytes ??= _synthesizePopWav();
    await _playWav(_popWavBytes!, 'playPop');
  }

  /// Magical fairy sparkle chime arpeggio for star / letter transition
  Future<void> playSparkle() async {
    _sparkleWavBytes ??= _synthesizeSparkleWav();
    await _playWav(_sparkleWavBytes!, 'playSparkle');
  }

  /// Alias for pleasant sparkling chime
  Future<void> playChime() => playSparkle();

  /// Cartoon spring bounce for graphic image tap with medium bounce haptic
  Future<void> playBoing() async {
    HapticFeedback.mediumImpact().catchError((_) {});
    _boingWavBytes ??= _synthesizeBoingWav();
    await _playWav(_boingWavBytes!, 'playBoing');
  }

  /// Friendly cartoon wrong answer buzzer (~0.85s dual-pulse BZZT-BZZT)
  Future<void> playWrongBuzzer() async {
    _buzzerWavBytes ??= _synthesizeWrongBuzzerWav();
    await _playWav(_buzzerWavBytes!, 'playWrongBuzzer');
  }

  /// Play playful cartoon dog woof bark
  Future<void> playBark() async {
    _barkWavBytes ??= _synthesizeBarkWav();
    await _playWav(_barkWavBytes!, 'playBark');
  }

  /// Play sweet melodious cat meow
  Future<void> playMeow() async {
    _meowWavBytes ??= _synthesizeMeowWav();
    await _playWav(_meowWavBytes!, 'playMeow');
  }

  /// Play resonant warm cow moo
  Future<void> playMoo() async {
    _mooWavBytes ??= _synthesizeMooWav();
    await _playWav(_mooWavBytes!, 'playMoo');
  }

  /// Play lively nasal duck quack
  Future<void> playQuack() async {
    _quackWavBytes ??= _synthesizeQuackWav();
    await _playWav(_quackWavBytes!, 'playQuack');
  }

  /// Play friendly sheep baa bleat
  Future<void> playBaa() async {
    _baaWavBytes ??= _synthesizeBaaWav();
    await _playWav(_baaWavBytes!, 'playBaa');
  }

  /// Play cheerful frog ribbit croak
  Future<void> playRibbit() async {
    _ribbitWavBytes ??= _synthesizeRibbitWav();
    await _playWav(_ribbitWavBytes!, 'playRibbit');
  }

  /// Play grand royal elephant trumpet blast
  Future<void> playElephant() async {
    _elephantWavBytes ??= _synthesizeElephantWav();
    await _playWav(_elephantWavBytes!, 'playElephant');
  }

  /// Play playful monkey whoop chatter
  Future<void> playMonkey() async {
    _monkeyWavBytes ??= _synthesizeMonkeyWav();
    await _playWav(_monkeyWavBytes!, 'playMonkey');
  }

  /// Play deep friendly bear growl
  Future<void> playBear() async {
    _bearWavBytes ??= _synthesizeBearWav();
    await _playWav(_bearWavBytes!, 'playBear');
  }

  /// Play animal vocalization sound for quiz
  Future<void> playAnimalSound(String soundText, String animalId, {bool isHindi = false}) async {
    if (_isMuted) return;
    switch (animalId.toLowerCase()) {
      case 'dog':
        await playBark();
        break;
      case 'cat':
        await playMeow();
        break;
      case 'cow':
        await playMoo();
        break;
      case 'duck':
        await playQuack();
        break;
      case 'lion':
      case 'tiger':
        await playRoar();
        break;
      case 'sheep':
        await playBaa();
        break;
      case 'frog':
        await playRibbit();
        break;
      case 'elephant':
        await playElephant();
        break;
      case 'monkey':
        await playMonkey();
        break;
      case 'bear':
        await playBear();
        break;
      default:
        await playPop();
    }
    // Articulate with clear multi-sensory speech
    await _speakText(soundText, isHindi: isHindi);
  }

  /// Happy victory fanfare chord for round completion
  Future<void> playFanfare() async {
    _fanfareWavBytes ??= _synthesizeFanfareWav();
    await _playWav(_fanfareWavBytes!, 'playFanfare');
  }

  /// Sweet crystal glockenspiel bell ding
  Future<void> playBell() async {
    _bellWavBytes ??= _synthesizeBellWav();
    await _playWav(_bellWavBytes!, 'playBell');
  }

  /// Quick pleasant positive ding
  Future<void> playDing() async {
    _dingWavBytes ??= _synthesizeDingWav();
    await _playWav(_dingWavBytes!, 'playDing');
  }

  /// Soft card slide whoosh
  Future<void> playWhoosh() async {
    _whooshWavBytes ??= _synthesizeWhooshWav();
    await _playWav(_whooshWavBytes!, 'playWhoosh');
  }

  /// Shiny gold coin pickup chime
  Future<void> playCoin() async {
    _coinWavBytes ??= _synthesizeCoinWav();
    await _playWav(_coinWavBytes!, 'playCoin');
  }

  /// Cheerful crowd celebration cheer
  Future<void> playCheer() async {
    _cheerWavBytes ??= _synthesizeCheerWav();
    await _playWav(_cheerWavBytes!, 'playCheer');
  }

  /// Suspenseful drum roll for unboxing treasure chests
  Future<void> playDrumRoll() async {
    _drumRollWavBytes ??= _synthesizeDrumRollWav();
    await _playWav(_drumRollWavBytes!, 'playDrumRoll');
  }

  /// Regal royal trumpet fanfare
  Future<void> playTrumpet() async {
    _trumpetWavBytes ??= _synthesizeTrumpetWav();
    await _playWav(_trumpetWavBytes!, 'playTrumpet');
  }

  /// Fairy magic wand sweep
  Future<void> playMagic() async {
    _magicWavBytes ??= _synthesizeMagicWav();
    await _playWav(_magicWavBytes!, 'playMagic');
  }

  /// Plop bubble pop
  Future<void> playBubble() async {
    _bubbleWavBytes ??= _synthesizeBubbleWav();
    await _playWav(_bubbleWavBytes!, 'playBubble');
  }

  /// Friendly lion cub roar
  Future<void> playRoar() async {
    _roarWavBytes ??= _synthesizeRoarWav();
    await _playWav(_roarWavBytes!, 'playRoar');
  }

  /// Soft cuddly purr
  Future<void> playPurr() async {
    _purrWavBytes ??= _synthesizePurrWav();
    await _playWav(_purrWavBytes!, 'playPurr');
  }

  /// Play clean mathematical musical note for rainbow xylophone (0 to 7: C4 to C5)
  Future<void> playXylophoneNote(int noteIndex) async {
    const frequencies = [
      261.63, // 0: C4 (Red)
      293.66, // 1: D4 (Orange)
      329.63, // 2: E4 (Yellow)
      349.23, // 3: F4 (Green)
      392.00, // 4: G4 (Cyan)
      440.00, // 5: A4 (Blue)
      493.88, // 6: B4 (Purple)
      523.25, // 7: C5 (Pink)
    ];
    final idx = noteIndex.clamp(0, frequencies.length - 1);
    _xyloWavBytes[idx] ??= _synthesizeXylophoneWav(frequencies[idx]);
    await _playWav(_xyloWavBytes[idx]!, 'xylophone_$idx');
  }

  static Uint8List _synthesizeXylophoneWav(double freq) {
    const sampleRate = 44100;
    const durationSec = 0.50;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-7.5 * t);
      final f1 = math.sin(2.0 * math.pi * freq * t);
      final f2 = 0.30 * math.sin(2.0 * math.pi * freq * 2.76 * t);
      final f3 = 0.12 * math.sin(2.0 * math.pi * freq * 5.40 * t);
      samples[i] = (f1 + f2 + f3) * envelope * 0.85;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  // ===========================================================================
  // PHONICS & LETTER NARRATION (Natural Child-Friendly Voice)
  // ===========================================================================

  /// Speak letter pronunciation (e.g. "A", "B", "C")
  Future<void> speakLetter(String letter, {bool isHindi = false}) async {
    if (_isMuted) return;
    await playPop();
    await _speakText(letter, isHindi: isHindi);
  }

  /// Speak word pronunciation (e.g. "Apple", "Butterfly")
  Future<void> speakWord(String word, {bool isHindi = false}) async {
    if (_isMuted) return;
    await playDing();
    await _speakText(word, isHindi: isHindi);
  }

  /// Speak full phonics phrase (e.g. "A is for Apple! Apple!")
  Future<void> speakPhonics(String letter, String word, {bool isHindi = false}) async {
    if (_isMuted) return;
    await playSparkle();
    final phrase = isHindi ? '$letter से $word! $word!' : '$letter is for $word! $word!';
    await _speakText(phrase, isHindi: isHindi);
  }

  /// Speak full story sentence or paragraph with pause/cancel capability
  Future<void> speakSentence(String text, {bool isHindi = false}) async {
    if (_isMuted) return;
    await _speakText(text, isHindi: isHindi);
  }

  /// Stop any active speech synthesis immediately
  Future<void> stopSpeech() async {
    try {
      await _flutterTts?.stop();
    } catch (_) {}
  }

  /// Speak text via TTS synthesis in English or Hindi
  Future<void> speak(String text, {bool isHindi = false}) async {
    await _speakText(text, isHindi: isHindi);
  }

  Future<void> _speakText(String text, {bool isHindi = false}) async {
    if (_isMuted) return;
    try {
      if (!_ttsInitialized) {
        await _initTts();
      }
      if (_ttsAvailable && _flutterTts != null) {
        final lang = isHindi ? 'hi-IN' : 'en-US';
        await _flutterTts!.setLanguage(lang);
        await _flutterTts!.stop();
        await _flutterTts!.speak(text);
      }
    } catch (_) {}
  }

  // ===========================================================================
  // MATHEMATICAL WAV AUDIO SYNTHESIS
  // Standard 16-bit Mono RIFF WAVE Byte Array Construction
  // ===========================================================================

  /// Synthesizes a soothing, cheerful 8-measure nursery Kingdom music box loop (~8.8s)
  static Uint8List _synthesizeKingdomBgmWav() {
    const sampleRate = 11025; // Lightweight nursery music box loop (~190KB)
    const bpm = 108.0;
    const beatSec = 60.0 / bpm;
    // 8 bars * 4 beats = 32 beats
    const totalDurationSec = 32 * (beatSec / 2.0); // 16 beats = ~8.88s
    final totalSamples = (sampleRate * totalDurationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    // Melodic notes sequence (frequency, startBeat, durationBeats)
    final notes = <_MusicNote>[
      // Measure 1: C Major (Arpeggio)
      _MusicNote(261.63, 0.0, 1.8), // C4
      _MusicNote(329.63, 0.5, 1.5), // E4
      _MusicNote(392.00, 1.0, 1.5), // G4
      _MusicNote(523.25, 1.5, 2.0), // C5
      // Measure 2: F Major
      _MusicNote(349.23, 2.0, 1.8), // F4
      _MusicNote(440.00, 2.5, 1.5), // A4
      _MusicNote(523.25, 3.0, 1.5), // C5
      _MusicNote(698.46, 3.5, 2.0), // F5
      // Measure 3: G Major
      _MusicNote(392.00, 4.0, 1.8), // G4
      _MusicNote(493.88, 4.5, 1.5), // B4
      _MusicNote(587.33, 5.0, 1.5), // D5
      _MusicNote(783.99, 5.5, 2.0), // G5
      // Measure 4: C Major resolving phrase
      _MusicNote(659.25, 6.0, 1.5), // E5
      _MusicNote(587.33, 6.5, 1.5), // D5
      _MusicNote(523.25, 7.0, 1.8), // C5
      _MusicNote(392.00, 7.5, 2.0), // G4
      // Measure 5: A Minor
      _MusicNote(440.00, 8.0, 1.8), // A4
      _MusicNote(523.25, 8.5, 1.5), // C5
      _MusicNote(659.25, 9.0, 1.8), // E5
      _MusicNote(440.00, 9.5, 2.0), // A4
      // Measure 6: F Major
      _MusicNote(349.23, 10.0, 1.8), // F4
      _MusicNote(440.00, 10.5, 1.5), // A4
      _MusicNote(523.25, 11.0, 1.8), // C5
      _MusicNote(349.23, 11.5, 2.0), // F4
      // Measure 7: G Major
      _MusicNote(293.66, 12.0, 1.5), // D4
      _MusicNote(392.00, 12.5, 1.5), // G4
      _MusicNote(493.88, 13.0, 1.5), // B4
      _MusicNote(587.33, 13.5, 2.0), // D5
      // Measure 8: Warm C Major finale
      _MusicNote(261.63, 14.0, 2.5), // C4
      _MusicNote(392.00, 14.5, 2.0), // G4
      _MusicNote(329.63, 15.0, 2.2), // E4
      _MusicNote(523.25, 15.5, 2.8), // C5
    ];

    // Warm bass line (root notes on downbeats)
    final bassNotes = <_MusicNote>[
      _MusicNote(130.81, 0.0, 2.0), // C3
      _MusicNote(87.31, 2.0, 2.0), // F2
      _MusicNote(98.00, 4.0, 2.0), // G2
      _MusicNote(130.81, 6.0, 2.0), // C3
      _MusicNote(110.00, 8.0, 2.0), // A2
      _MusicNote(87.31, 10.0, 2.0), // F2
      _MusicNote(98.00, 12.0, 2.0), // G2
      _MusicNote(130.81, 14.0, 2.0), // C3
    ];

    // Render melody notes
    for (final note in notes) {
      final startSample = (note.startBeat * beatSec * sampleRate).toInt();
      final noteDurationSamples = (note.durationBeats * beatSec * sampleRate).toInt();
      final endSample = math.min(totalSamples, startSample + noteDurationSamples);

      for (int i = startSample; i < endSample; i++) {
        final t = (i - startSample) / sampleRate;
        final envelope = math.exp(-3.2 * t);
        final tone = math.sin(2.0 * math.pi * note.freq * t) +
            (0.25 * math.sin(2.0 * math.pi * note.freq * 2.0 * t)) +
            (0.08 * math.sin(2.0 * math.pi * note.freq * 3.0 * t));
        samples[i] += tone * envelope * 0.18;
      }
    }

    // Render warm bass notes
    for (final b in bassNotes) {
      final startSample = (b.startBeat * beatSec * sampleRate).toInt();
      final noteDurationSamples = (b.durationBeats * beatSec * sampleRate).toInt();
      final endSample = math.min(totalSamples, startSample + noteDurationSamples);

      for (int i = startSample; i < endSample; i++) {
        final t = (i - startSample) / sampleRate;
        final envelope = math.exp(-2.5 * t);
        final bassTone = math.sin(2.0 * math.pi * b.freq * t) +
            (0.15 * math.sin(2.0 * math.pi * b.freq * 2.0 * t));
        samples[i] += bassTone * envelope * 0.14;
      }
    }

    // Smooth loop crossfade at beginning and end to eliminate clicks
    const fadeSamples = 400;
    for (int i = 0; i < fadeSamples; i++) {
      final progress = i / fadeSamples;
      samples[i] *= progress;
      samples[totalSamples - 1 - i] *= progress;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a quick playful bubble pop (400Hz -> 850Hz upward chirp)
  static Uint8List _synthesizePopWav() {
    const sampleRate = 44100;
    const durationSec = 0.08;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final freq = 420.0 + (460.0 * progress);
      final envelope = math.exp(-t * 45.0);
      samples[i] = math.sin(2.0 * math.pi * freq * t) * envelope * 0.8;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a magical sparkle arpeggio (C6, E6, G6, B6, C7)
  static Uint8List _synthesizeSparkleWav() {
    const sampleRate = 44100;
    const durationSec = 0.45;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final notes = [1046.50, 1318.51, 1567.98, 1975.53, 2093.00];
    const noteInterval = 0.05;

    for (int n = 0; n < notes.length; n++) {
      final freq = notes[n];
      final startSample = (n * noteInterval * sampleRate).toInt();

      for (int i = startSample; i < totalSamples; i++) {
        final t = (i - startSample) / sampleRate;
        final envelope = math.exp(-t * 14.0);
        final tone = math.sin(2.0 * math.pi * freq * t);
        samples[i] += tone * envelope * 0.22;
      }
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a cartoon spring boing (sweeping 180Hz to 380Hz)
  static Uint8List _synthesizeBoingWav() {
    const sampleRate = 44100;
    const durationSec = 0.32;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final wobble = math.sin(2.0 * math.pi * 28.0 * t);
      final carrierFreq = 220.0 + (160.0 * (1.0 - progress)) + (wobble * 45.0);
      final envelope = math.exp(-t * 9.0);
      samples[i] = math.sin(2.0 * math.pi * carrierFreq * t) * envelope * 0.75;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a cheerful major triad fanfare (C5, E5, G5, C6)
  static Uint8List _synthesizeFanfareWav() {
    const sampleRate = 44100;
    const durationSec = 0.55;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final chord = [523.25, 659.25, 783.99, 1046.50];

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = (1.0 - math.pow(i / totalSamples, 0.6)) * math.exp(-t * 3.5);
      double mix = 0.0;
      for (final freq in chord) {
        mix += math.sin(2.0 * math.pi * freq * t);
        mix += 0.25 * math.sin(2.0 * math.pi * freq * 2.0 * t);
      }
      samples[i] = (mix / chord.length) * envelope * 0.7;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a crystal bell chime
  static Uint8List _synthesizeBellWav() {
    const sampleRate = 44100;
    const durationSec = 0.35;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    const freq = 1318.51; // E6
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-t * 8.0);
      final tone = math.sin(2.0 * math.pi * freq * t) +
          (0.3 * math.sin(2.0 * math.pi * freq * 2.0 * t)) +
          (0.15 * math.sin(2.0 * math.pi * freq * 3.0 * t));
      samples[i] = tone * envelope * 0.5;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a pleasant ding
  static Uint8List _synthesizeDingWav() {
    const sampleRate = 44100;
    const durationSec = 0.22;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    const freq = 880.0; // A5
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-t * 12.0);
      samples[i] = math.sin(2.0 * math.pi * freq * t) * envelope * 0.65;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a soft air whoosh
  static Uint8List _synthesizeWhooshWav() {
    const sampleRate = 44100;
    const durationSec = 0.12;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final rng = math.Random(42);
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.sin(math.pi * (i / totalSamples));
      final noise = (rng.nextDouble() * 2.0) - 1.0;
      final sweepFreq = 300.0 + (600.0 * (i / totalSamples));
      final tone = math.sin(2.0 * math.pi * sweepFreq * t);
      samples[i] = ((tone * 0.4) + (noise * 0.6)) * envelope * 0.35;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize crystal gold coin pickup chime
  static Uint8List _synthesizeCoinWav() {
    const sampleRate = 44100;
    const durationSec = 0.28;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final chord = [987.77, 1318.51]; // B5, E6
    const step = 0.06;

    for (int c = 0; c < chord.length; c++) {
      final freq = chord[c];
      final start = (c * step * sampleRate).toInt();
      for (int i = start; i < totalSamples; i++) {
        final t = (i - start) / sampleRate;
        final envelope = math.exp(-t * 16.0);
        final tone = math.sin(2.0 * math.pi * freq * t);
        samples[i] += tone * envelope * 0.42;
      }
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a celebratory crowd applause & cheer
  static Uint8List _synthesizeCheerWav() {
    const sampleRate = 44100;
    const durationSec = 0.65;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final rng = math.Random(1337);
    final chord = [523.25, 659.25, 783.99, 1046.50];

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final env = math.sin(math.pi * progress) * math.exp(-t * 1.5);
      final clapNoise = (rng.nextDouble() * 2.0 - 1.0) * (rng.nextDouble() > 0.65 ? 1.0 : 0.2);

      double chordMix = 0.0;
      for (final f in chord) {
        chordMix += math.sin(2.0 * math.pi * f * t);
      }

      samples[i] = ((chordMix * 0.15) + (clapNoise * 0.45)) * env * 0.7;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize suspenseful drum roll
  static Uint8List _synthesizeDrumRollWav() {
    const sampleRate = 44100;
    const durationSec = 0.70;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final rng = math.Random(88);
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final envelope = 0.3 + (0.7 * progress); // Accelerating volume
      // Rapid rhythmic taps
      final tapMod = (math.sin(2.0 * math.pi * (25.0 + 35.0 * progress) * t) > 0.0) ? 1.0 : 0.0;
      final noise = (rng.nextDouble() * 2.0 - 1.0) * tapMod;
      final sub = math.sin(2.0 * math.pi * 140.0 * t) * tapMod * 0.4;
      samples[i] = (noise * 0.6 + sub) * envelope * 0.5;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize royal coronation trumpet herald
  static Uint8List _synthesizeTrumpetWav() {
    const sampleRate = 44100;
    const durationSec = 0.60;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final notes = [523.25, 659.25, 783.99]; // C5, E5, G5
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = (1.0 - math.pow(i / totalSamples, 0.8)) * (1.0 - math.exp(-t * 30.0));
      double mix = 0.0;
      for (final f in notes) {
        mix += math.sin(2.0 * math.pi * f * t) +
            (0.35 * math.sin(2.0 * math.pi * f * 2.0 * t)) +
            (0.18 * math.sin(2.0 * math.pi * f * 3.0 * t));
      }
      samples[i] = (mix / notes.length) * envelope * 0.65;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize magic fairy wand sweep
  static Uint8List _synthesizeMagicWav() {
    const sampleRate = 44100;
    const durationSec = 0.45;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final sweepFreq = 600.0 + (1800.0 * progress);
      final vibrato = math.sin(2.0 * math.pi * 18.0 * t) * 80.0;
      final envelope = math.sin(math.pi * progress);
      final tone = math.sin(2.0 * math.pi * (sweepFreq + vibrato) * t);
      samples[i] = tone * envelope * 0.55;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize liquid bubble pop
  static Uint8List _synthesizeBubbleWav() {
    const sampleRate = 44100;
    const durationSec = 0.14;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final freq = 280.0 + (680.0 * math.pow(progress, 2.0));
      final envelope = math.exp(-t * 32.0);
      samples[i] = math.sin(2.0 * math.pi * freq * t) * envelope * 0.75;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize playful cartoon lion cub roar
  static Uint8List _synthesizeRoarWav() {
    const sampleRate = 44100;
    const durationSec = 0.40;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final rng = math.Random(7);
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final freq = 130.0 + (160.0 * math.sin(math.pi * progress));
      final growl = math.sin(2.0 * math.pi * 42.0 * t);
      final noise = (rng.nextDouble() * 2.0 - 1.0) * 0.25;
      final envelope = math.sin(math.pi * progress) * math.exp(-t * 2.5);
      final tone = math.sin(2.0 * math.pi * (freq + (growl * 30.0)) * t);
      samples[i] = (tone + noise) * envelope * 0.7;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize soft warm friendly purr
  static Uint8List _synthesizePurrWav() {
    const sampleRate = 44100;
    const durationSec = 0.50;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final mod = (math.sin(2.0 * math.pi * 26.0 * t) + 1.0) * 0.5;
      final tone = math.sin(2.0 * math.pi * 85.0 * t) * mod;
      final envelope = math.sin(math.pi * (i / totalSamples));
      samples[i] = tone * envelope * 0.55;
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize playful cartoon dog woof bark
  static Uint8List _synthesizeBarkWav() {
    const sampleRate = 44100;
    const durationSec = 0.45;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final p1End = (sampleRate * 0.18).toInt();
    final p2Start = (sampleRate * 0.22).toInt();
    final p2End = (sampleRate * 0.42).toInt();

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      if (i < p1End) {
        final progress = i / p1End;
        final freq = 340.0 - (160.0 * progress);
        final env = math.sin(math.pi * progress) * math.exp(-progress * 2.0);
        final tone = math.sin(2.0 * math.pi * freq * t) +
            0.35 * math.sin(2.0 * math.pi * freq * 2.0 * t);
        samples[i] = tone * env * 0.75;
      } else if (i >= p2Start && i < p2End) {
        final progress = (i - p2Start) / (p2End - p2Start);
        final freq = 310.0 - (150.0 * progress);
        final env = math.sin(math.pi * progress) * math.exp(-progress * 2.0);
        final tone = math.sin(2.0 * math.pi * freq * t) +
            0.35 * math.sin(2.0 * math.pi * freq * 2.0 * t);
        samples[i] = tone * env * 0.75;
      }
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize sweet melodious cat meow
  static Uint8List _synthesizeMeowWav() {
    const sampleRate = 44100;
    const durationSec = 0.55;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final freq = 420.0 + (260.0 * math.sin(math.pi * progress * 0.85));
      final env = math.sin(math.pi * progress) * (1.0 - (progress * 0.3));
      final vibrato = 1.0 + 0.02 * math.sin(2.0 * math.pi * 7.0 * t);
      final tone = math.sin(2.0 * math.pi * freq * vibrato * t) +
          0.30 * math.sin(2.0 * math.pi * freq * 2.0 * t) +
          0.12 * math.sin(2.0 * math.pi * freq * 3.0 * t);
      samples[i] = tone * env * 0.65;
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize warm resonant cow moo
  static Uint8List _synthesizeMooWav() {
    const sampleRate = 44100;
    const durationSec = 0.85;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final freq = 115.0 + (15.0 * math.sin(math.pi * progress));
      final vibrato = 1.0 + 0.015 * math.sin(2.0 * math.pi * 5.0 * t);
      final env = math.sin(math.pi * math.pow(progress, 0.7));
      final tone = math.sin(2.0 * math.pi * freq * vibrato * t) +
          0.45 * math.sin(2.0 * math.pi * freq * 1.5 * t) +
          0.25 * math.sin(2.0 * math.pi * freq * 2.0 * t);
      samples[i] = tone * env * 0.70;
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize lively duck quack
  static Uint8List _synthesizeQuackWav() {
    const sampleRate = 44100;
    const durationSec = 0.42;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final p1 = (sampleRate * 0.18).toInt();
    final p2Start = (sampleRate * 0.22).toInt();

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      if (i < p1) {
        final progress = i / p1;
        final freq = 340.0 - (60.0 * progress);
        final env = math.sin(math.pi * progress) * math.exp(-progress * 2.5);
        final tone = math.sin(2.0 * math.pi * freq * t) +
            0.4 * (math.sin(2.0 * math.pi * freq * t) > 0 ? 1.0 : -1.0);
        samples[i] = tone * env * 0.60;
      } else if (i >= p2Start) {
        final progress = (i - p2Start) / (totalSamples - p2Start);
        final freq = 310.0 - (50.0 * progress);
        final env = math.sin(math.pi * progress) * math.exp(-progress * 2.5);
        final tone = math.sin(2.0 * math.pi * freq * t) +
            0.4 * (math.sin(2.0 * math.pi * freq * t) > 0 ? 1.0 : -1.0);
        samples[i] = tone * env * 0.60;
      }
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize warm sheep baa bleat
  static Uint8List _synthesizeBaaWav() {
    const sampleRate = 44100;
    const durationSec = 0.65;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final tremolo = 1.0 + 0.35 * math.sin(2.0 * math.pi * 9.0 * t);
      final env = math.sin(math.pi * progress) * tremolo;
      final tone = math.sin(2.0 * math.pi * 260.0 * t) +
          0.3 * math.sin(2.0 * math.pi * 520.0 * t);
      samples[i] = tone * env * 0.60;
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize cheerful frog ribbit croak
  static Uint8List _synthesizeRibbitWav() {
    const sampleRate = 44100;
    const durationSec = 0.40;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final flutter = math.sin(2.0 * math.pi * 45.0 * t);
      final freq = 180.0 + (120.0 * progress) + (flutter * 30.0);
      final env = math.sin(math.pi * progress);
      samples[i] = math.sin(2.0 * math.pi * freq * t) * env * 0.70;
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize elephant royal trumpet fanfare
  static Uint8List _synthesizeElephantWav() {
    const sampleRate = 44100;
    const durationSec = 0.60;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final freq = 220.0 + (320.0 * math.pow(progress, 1.8));
      final env = math.sin(math.pi * progress);
      final tone = math.sin(2.0 * math.pi * freq * t) +
          0.45 * math.sin(2.0 * math.pi * freq * 2.0 * t) +
          0.20 * math.sin(2.0 * math.pi * freq * 3.0 * t);
      samples[i] = tone * env * 0.75;
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize playful monkey whoop
  static Uint8List _synthesizeMonkeyWav() {
    const sampleRate = 44100;
    const durationSec = 0.45;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final freq = 550.0 + (280.0 * math.sin(math.pi * progress * 2.0));
      final env = math.sin(math.pi * progress);
      samples[i] = math.sin(2.0 * math.pi * freq * t) * env * 0.65;
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize deep friendly bear growl
  static Uint8List _synthesizeBearWav() {
    const sampleRate = 44100;
    const durationSec = 0.65;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final rng = math.Random(19);
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;
      final freq = 75.0 + (30.0 * math.sin(math.pi * progress));
      final wobble = math.sin(2.0 * math.pi * 28.0 * t);
      final noise = (rng.nextDouble() * 2.0 - 1.0) * 0.3;
      final env = math.sin(math.pi * progress);
      final tone = math.sin(2.0 * math.pi * (freq + (wobble * 20.0)) * t);
      samples[i] = (tone + noise) * env * 0.70;
    }
    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Synthesize a friendly cartoon wrong answer buzzer (~0.85s dual-pulse BZZT-BZZT)
  static Uint8List _synthesizeWrongBuzzerWav() {
    const sampleRate = 44100;
    const durationSec = 0.85;
    final totalSamples = (sampleRate * durationSec).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    final pulse1End = (0.36 * sampleRate).toInt();
    final pulse2Start = (0.44 * sampleRate).toInt();
    final pulse2End = (0.84 * sampleRate).toInt();

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      if (i < pulse1End) {
        final pt = t / 0.36;
        final env = math.sin(math.pi * pt);
        final wobble = 1.0 + 0.04 * math.sin(2.0 * math.pi * 50.0 * t);
        final f1 = 155.0 * wobble;
        final f2 = 232.0 * wobble;
        final tone = 0.55 * math.sin(2.0 * math.pi * f1 * t) +
            0.28 * math.sin(2.0 * math.pi * f1 * 3.0 * t) +
            0.35 * math.sin(2.0 * math.pi * f2 * t) +
            0.15 * math.sin(2.0 * math.pi * f2 * 2.0 * t);
        samples[i] = tone * env * 0.65;
      } else if (i >= pulse2Start && i < pulse2End) {
        final pt = (t - 0.44) / 0.40;
        final env = math.sin(math.pi * pt);
        final wobble = 1.0 + 0.04 * math.sin(2.0 * math.pi * 46.0 * t);
        final f1 = 138.0 * wobble;
        final f2 = 208.0 * wobble;
        final tone = 0.55 * math.sin(2.0 * math.pi * f1 * t) +
            0.28 * math.sin(2.0 * math.pi * f1 * 3.0 * t) +
            0.35 * math.sin(2.0 * math.pi * f2 * t) +
            0.15 * math.sin(2.0 * math.pi * f2 * 2.0 * t);
        samples[i] = tone * env * 0.65;
      }
    }

    return _createWavBytes(samples, sampleRate: sampleRate);
  }

  /// Constructs a valid 44-byte RIFF/WAVE header + 16-bit PCM bytes
  static Uint8List _createWavBytes(List<double> samples, {int sampleRate = 44100}) {
    final numSamples = samples.length;
    const numChannels = 1; // mono
    const bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    const blockAlign = numChannels * (bitsPerSample ~/ 8);
    final dataSize = numSamples * numChannels * (bitsPerSample ~/ 8);
    final fileSize = 36 + dataSize;

    final header = ByteData(44);
    // "RIFF"
    header.setUint8(0, 0x52);
    header.setUint8(1, 0x49);
    header.setUint8(2, 0x46);
    header.setUint8(3, 0x46);
    header.setUint32(4, fileSize, Endian.little);
    // "WAVE"
    header.setUint8(8, 0x57);
    header.setUint8(9, 0x41);
    header.setUint8(10, 0x56);
    header.setUint8(11, 0x45);
    // "fmt "
    header.setUint8(12, 0x66);
    header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74);
    header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little); // AudioFormat = PCM
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    // "data"
    header.setUint8(36, 0x64);
    header.setUint8(37, 0x61);
    header.setUint8(38, 0x74);
    header.setUint8(39, 0x61);
    header.setUint32(40, dataSize, Endian.little);

    final out = Uint8List(44 + dataSize);
    out.setRange(0, 44, header.buffer.asUint8List());

    final dataView = ByteData.view(out.buffer, 44, dataSize);
    for (int i = 0; i < numSamples; i++) {
      final clamped = samples[i].clamp(-1.0, 1.0);
      final int sample16 = (clamped * 32767).toInt();
      dataView.setInt16(i * 2, sample16, Endian.little);
    }

    return out;
  }
}

class _MusicNote {
  final double freq;
  final double startBeat;
  final double durationBeats;

  const _MusicNote(this.freq, this.startBeat, this.durationBeats);
}
