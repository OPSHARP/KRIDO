import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../audio/procedural_sfx_engine.dart';

class CelebrationPraiseService {
  static final CelebrationPraiseService _instance = CelebrationPraiseService._internal();
  factory CelebrationPraiseService() => _instance;
  CelebrationPraiseService._internal();

  final math.Random _random = math.Random();

  static const List<String> _englishPraises = [
    "Pawsome! You're super smart! 🐾",
    "Hooray! You solved it! ⭐",
    "Incredible job, little genius! 🦁",
    "Superstar! Leo is so proud of you! 👑",
    "Brilliant! High five, champion! ✋",
    "Wonderful! You did it so fast! 🚀",
    "Outstanding work! Keep shining! ✨",
  ];

  static const List<String> _hindiPraises = [
    "वाह! एकदम सही जवाब! 🌟",
    "शाबाश! तुम तो सुपर स्मार्ट हो! 🦁",
    "लियो को तुम पर गर्व है! 👑",
    "कमाल कर दिया छोटे उस्ताद! 🚀",
    "बहुत बढ़िया! तुम तो चैंपियन हो! 🏆",
    "अद्भुत! ऐसे ही आगे बढ़ो! 🐾",
    "सुपर स्टार! शाबाशी! ✨",
  ];

  String getRandomPraise({required bool isHindi}) {
    final list = isHindi ? _hindiPraises : _englishPraises;
    return list[_random.nextInt(list.length)];
  }

  /// Triggers full celebration: Voice praise via TTS + Fanfare SFX + Haptic vibration
  Future<void> celebrateGameSuccess({required bool isHindi}) async {
    try {
      HapticFeedback.mediumImpact().catchError((_) {});
      ProceduralSfxEngine().playCheer();
      ProceduralSfxEngine().playTrumpet();

      final praise = getRandomPraise(isHindi: isHindi);
      // Clean emojis for clean TTS speech
      final speechText = praise.replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '').trim();
      await Future.delayed(const Duration(milliseconds: 300));
      await ProceduralSfxEngine().speak(speechText, isHindi: isHindi);
    } catch (_) {}
  }
}
