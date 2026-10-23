import 'dart:async';
import 'package:flutter/material.dart';
import '../environment/celestial_time_engine.dart';

enum MascotMood {
  happy,
  talking,
  listening,
  excited,
  waving;

  String get mascotEmoji {
    switch (this) {
      case MascotMood.happy:
        return '🦁';
      case MascotMood.talking:
        return '🗣️';
      case MascotMood.listening:
        return '👂';
      case MascotMood.excited:
        return '🤩';
      case MascotMood.waving:
        return '👋';
    }
  }
}

/// Controller managing voice commands, verbal character dialogue, and microphone listening
class VoiceNavigationController extends ChangeNotifier {
  MascotMood _mood = MascotMood.happy;
  String _currentDialogue = "Roar! Welcome to KRIDO Kingdom! 👑";
  bool _isListening = false;
  Timer? _speechResetTimer;

  // Callback to parent screen when a game should launch
  void Function(String gameId)? onLaunchGame;
  // Callback when a voice command changes the sky
  void Function(CelestialPhase phase)? onChangePhase;

  MascotMood get mood => _mood;
  String get currentDialogue => _currentDialogue;
  bool get isListening => _isListening;

  /// Trigger mascot speech with animated dialogue
  void speak(String text, {MascotMood mood = MascotMood.talking, Duration? duration}) {
    _speechResetTimer?.cancel();
    _currentDialogue = text;
    _mood = mood;
    notifyListeners();

    _speechResetTimer = Timer(duration ?? const Duration(seconds: 4), () {
      _mood = MascotMood.happy;
      notifyListeners();
    });
  }

  /// Start kid microphone listening mode with glowing waveform
  void startListening() {
    _isListening = true;
    _mood = MascotMood.listening;
    _currentDialogue = "I'm listening! Tell me: 'Play Puzzle', 'Count Apples', 'Night'...";
    notifyListeners();
  }

  /// Stop microphone listening
  void stopListening() {
    _isListening = false;
    _mood = MascotMood.happy;
    notifyListeners();
  }

  /// Execute a verbal voice command
  void executeVerbalCommand(String command) {
    final lower = command.toLowerCase().trim();
    _isListening = false;

    if (lower.contains('puzzle') || lower.contains('animal') || lower.contains('doggy') || lower.contains('puppy') || lower.contains('kutta') || lower.contains('janwar')) {
      speak("Pawsome! Let's solve the Doggy Puzzle! 🐶", mood: MascotMood.excited);
      Future.delayed(const Duration(milliseconds: 700), () {
        onLaunchGame?.call('G051');
      });
    } else if (lower.contains('apple') || lower.contains('count') || lower.contains('seb')) {
      speak("Sweet! Let's count apples on the friendly tree! 🍎", mood: MascotMood.excited);
      Future.delayed(const Duration(milliseconds: 700), () {
        onLaunchGame?.call('G002');
      });
    } else if (lower.contains('letter') || lower.contains('find b') || lower.contains('abc')) {
      speak("Hooray! Let's Find the Letter B! 🔤", mood: MascotMood.excited);
      Future.delayed(const Duration(milliseconds: 700), () {
        onLaunchGame?.call('G011');
      });
    } else if (lower.contains('shape') || lower.contains('match')) {
      speak("Awesome! Let's match shapes in the mountains! 🔺", mood: MascotMood.excited);
      Future.delayed(const Duration(milliseconds: 700), () {
        onLaunchGame?.call('G031');
      });
    } else if (lower.contains('memory') || lower.contains('pair') || lower.contains('card')) {
      speak("Super mind! Let's play Memory Match! ☀️", mood: MascotMood.excited);
      Future.delayed(const Duration(milliseconds: 700), () {
        onLaunchGame?.call('G041');
      });
    } else if (lower.contains('creative') || lower.contains('paint') || lower.contains('draw') || lower.contains('color') || lower.contains('sticker') || lower.contains('art') || lower.contains('world')) {
      speak("Let's build a wonder kingdom! 🏰", mood: MascotMood.excited);
      Future.delayed(const Duration(milliseconds: 700), () {
        onLaunchGame?.call('WORLD_BUILDER');
      });
    } else if (lower.contains('night') || lower.contains('moon') || lower.contains('star')) {
      speak("Shhh! Turning on the magical Starry Night! 🌙", mood: MascotMood.happy);
      onChangePhase?.call(CelestialPhase.night);
    } else if (lower.contains('day') || lower.contains('sun')) {
      speak("Rise and shine! Hello Sunny Day! ☀️", mood: MascotMood.happy);
      onChangePhase?.call(CelestialPhase.day);
    } else if (lower.contains('sunset') || lower.contains('evening')) {
      speak("Look at the glowing golden sunset! 🌇", mood: MascotMood.happy);
      onChangePhase?.call(CelestialPhase.sunset);
    } else if (lower.contains('morning') || lower.contains('dawn')) {
      speak("Good morning! The sweet birds are singing! 🌅", mood: MascotMood.happy);
      onChangePhase?.call(CelestialPhase.dawn);
    } else if (lower.contains('surprise') || lower.contains('random')) {
      final games = ['G002', 'G011', 'G031', 'G041', 'G051'];
      games.shuffle();
      final picked = games.first;
      speak("Surprise Adventure! Here we go! 🚀", mood: MascotMood.excited);
      Future.delayed(const Duration(milliseconds: 700), () {
        onLaunchGame?.call(picked);
      });
    } else {
      speak("Roar! I heard '$command'! Try saying 'Play Puzzle' or 'Count Apples'!", mood: MascotMood.happy);
    }
  }

  /// Interactive Mascot Poke Reaction
  void pokeMascot() {
    final phrases = [
      "Hehehe! That tickles! 🦁✨",
      "Roar!! You are the King! 👑",
      "Ready for another adventure?",
      "High five! Let's learn and play! 🖐️",
    ];
    phrases.shuffle();
    speak(phrases.first, mood: MascotMood.excited);
  }

  @override
  void dispose() {
    _speechResetTimer?.cancel();
    super.dispose();
  }
}
