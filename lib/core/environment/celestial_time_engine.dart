import 'dart:async';
import 'package:flutter/material.dart';

/// 4 Distinct real-time celestial phases of the day
enum CelestialPhase {
  dawn,
  day,
  sunset,
  night;

  String get displayName {
    switch (this) {
      case CelestialPhase.dawn:
        return 'Morning Dawn';
      case CelestialPhase.day:
        return 'Sunny Day';
      case CelestialPhase.sunset:
        return 'Golden Sunset';
      case CelestialPhase.night:
        return 'Starry Night';
    }
  }

  String get emoji {
    switch (this) {
      case CelestialPhase.dawn:
        return '🌅';
      case CelestialPhase.day:
        return '☀️';
      case CelestialPhase.sunset:
        return '🌇';
      case CelestialPhase.night:
        return '🌙';
    }
  }

  bool get isNight => this == CelestialPhase.night;

  List<Color> get skyGradient {
    switch (this) {
      case CelestialPhase.dawn:
        return const [
          Color(0xFFFF8A80), // Rose coral
          Color(0xFFFFD180), // Apricot glow
          Color(0xFFE1BEE7), // Soft lavender
          Color(0xFFFFF9E6), // Morning cream
        ];
      case CelestialPhase.day:
        return const [
          Color(0xFF29B6F6), // Bright azure
          Color(0xFF81D4FA), // Sky blue
          Color(0xFFE1F5FE), // Pale cyan
          Color(0xFFFFFDE7), // Sunlight warm
        ];
      case CelestialPhase.sunset:
        return const [
          Color(0xFF5E35B1), // Deep violet twilight
          Color(0xFFD81B60), // Magenta crimson
          Color(0xFFFF7043), // Amber orange
          Color(0xFFFFCA28), // Golden horizon
        ];
      case CelestialPhase.night:
        return const [
          Color(0xFF0D1B2A), // Deep navy cosmos
          Color(0xFF1B263B), // Midnight indigo
          Color(0xFF415A77), // Twilight blue
          Color(0xFF1A1A3A), // Dark starry mist
        ];
    }
  }

  Color get sunMoonHaloColor {
    switch (this) {
      case CelestialPhase.dawn:
        return const Color(0xFFFFAB91).withOpacity(0.4);
      case CelestialPhase.day:
        return const Color(0xFFFFE082).withOpacity(0.5);
      case CelestialPhase.sunset:
        return const Color(0xFFFF7043).withOpacity(0.6);
      case CelestialPhase.night:
        return const Color(0xFFE0E7FF).withOpacity(0.45);
    }
  }

  Color get hillColorPrimary {
    switch (this) {
      case CelestialPhase.dawn:
        return const Color(0xFF81C784);
      case CelestialPhase.day:
        return const Color(0xFF66BB6A);
      case CelestialPhase.sunset:
        return const Color(0xFF8D6E63);
      case CelestialPhase.night:
        return const Color(0xFF1B3B2B);
    }
  }

  Color get hillColorSecondary {
    switch (this) {
      case CelestialPhase.dawn:
        return const Color(0xFF66BB6A);
      case CelestialPhase.day:
        return const Color(0xFF43A047);
      case CelestialPhase.sunset:
        return const Color(0xFF6D4C41);
      case CelestialPhase.night:
        return const Color(0xFF102A1E);
    }
  }
}

/// Dynamic Real-Time Time-of-Day Engine
class CelestialTimeEngine extends ChangeNotifier {
  CelestialPhase _currentPhase;
  bool _isAutoRealTime = true;
  Timer? _clockSyncTimer;

  CelestialTimeEngine({CelestialPhase? initialPhase})
      : _currentPhase = initialPhase ?? _resolveCurrentClockPhase() {
    _startClockSync();
  }

  CelestialPhase get currentPhase => _currentPhase;
  bool get isAutoRealTime => _isAutoRealTime;

  static CelestialPhase _resolveCurrentClockPhase() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 9) {
      return CelestialPhase.dawn;
    } else if (hour >= 9 && hour < 17) {
      return CelestialPhase.day;
    } else if (hour >= 17 && hour < 20) {
      return CelestialPhase.sunset;
    } else {
      return CelestialPhase.night;
    }
  }

  void _startClockSync() {
    _clockSyncTimer?.cancel();
    _clockSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isAutoRealTime) {
        final newPhase = _resolveCurrentClockPhase();
        if (newPhase != _currentPhase) {
          _currentPhase = newPhase;
          notifyListeners();
        }
      }
    });
  }

  /// Manually override celestial phase for interactive kid exploration
  void setPhase(CelestialPhase phase, {bool disableAuto = true}) {
    if (disableAuto) {
      _isAutoRealTime = false;
    }
    if (_currentPhase != phase) {
      _currentPhase = phase;
      notifyListeners();
    }
  }

  /// Cycle to next phase (kid quick tap)
  void cycleNextPhase() {
    final nextIndex = (_currentPhase.index + 1) % CelestialPhase.values.length;
    setPhase(CelestialPhase.values[nextIndex], disableAuto: true);
  }

  /// Return to live real-world time sync
  void resetToRealTime() {
    _isAutoRealTime = true;
    _currentPhase = _resolveCurrentClockPhase();
    notifyListeners();
  }

  @override
  void dispose() {
    _clockSyncTimer?.cancel();
    super.dispose();
  }
}
