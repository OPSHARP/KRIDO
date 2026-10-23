import 'package:flutter/services.dart';

/// AppHaptics provides safe wrappers around Flutter's [HapticFeedback] platform channel.
/// Prevents unhandled asynchronous exceptions in widget tests, desktop, web, or
/// platforms without native vibrator/haptic hardware.
class AppHaptics {
  AppHaptics._();

  /// Subtle tactile tap feedback (e.g. tile tap, letter select, toggle)
  static void lightImpact() {
    HapticFeedback.lightImpact().catchError((_) {});
  }

  /// Medium tactile tap feedback (e.g. button press, island tap)
  static void mediumImpact() {
    HapticFeedback.mediumImpact().catchError((_) {});
  }

  /// Heavy tactile feedback (e.g. puzzle victory, stamp drop)
  static void heavyImpact() {
    HapticFeedback.heavyImpact().catchError((_) {});
  }

  /// Smooth selection click (e.g. sticker carousel scroll, slider)
  static void selectionClick() {
    HapticFeedback.selectionClick().catchError((_) {});
  }

  /// Error or attention vibrate
  static void vibrate() {
    HapticFeedback.vibrate().catchError((_) {});
  }
}
