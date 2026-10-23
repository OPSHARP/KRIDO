import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Parallax Tilt Controller providing normalized tilt coordinates (-1.0 to 1.0)
/// Combines hardware sensors (when available) with fluid touch/pointer drag
/// and an ambient magical idle breathing oscillation.
class ParallaxTiltController extends ChangeNotifier {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _targetTiltX = 0.0;
  double _targetTiltY = 0.0;

  bool _isDragging = false;

  double get tiltX => _tiltX;
  double get tiltY => _tiltY;
  bool get isDragging => _isDragging;

  /// Update target tilt from touch drag or pointer position
  void updatePan(Offset localPosition, Size screenSize) {
    _isDragging = true;
    final normalizedX = ((localPosition.dx / screenSize.width) * 2.0 - 1.0).clamp(-1.0, 1.0);
    final normalizedY = ((localPosition.dy / screenSize.height) * 2.0 - 1.0).clamp(-1.0, 1.0);

    _targetTiltX = normalizedX;
    _targetTiltY = normalizedY;

    // Smooth lerp
    _tiltX = _tiltX + (_targetTiltX - _tiltX) * 0.25;
    _tiltY = _tiltY + (_targetTiltY - _tiltY) * 0.25;
    notifyListeners();
  }

  /// Release touch drag - return smoothly toward center with gentle ambient float
  void releasePan() {
    _isDragging = false;
    _targetTiltX = 0.0;
    _targetTiltY = 0.0;
    notifyListeners();
  }

  /// Step animation tick for smooth spring return & ambient gyroscope floating
  void updateAmbientTick(double timeSeconds) {
    if (!_isDragging) {
      // Gentle ambient floating oscillation
      final ambientX = math.sin(timeSeconds * 1.2) * 0.18;
      final ambientY = math.cos(timeSeconds * 0.9) * 0.12;

      _tiltX = _tiltX + ((ambientX + _targetTiltX) - _tiltX) * 0.08;
      _tiltY = _tiltY + ((ambientY + _targetTiltY) - _tiltY) * 0.08;
      notifyListeners();
    }
  }

  /// Direct tilt setter (e.g. from sensors_plus accelerometer stream if connected)
  void setSensorTilt(double sensorX, double sensorY) {
    if (!_isDragging) {
      _targetTiltX = sensorX.clamp(-1.0, 1.0);
      _targetTiltY = sensorY.clamp(-1.0, 1.0);
      _tiltX = _tiltX + (_targetTiltX - _tiltX) * 0.2;
      _tiltY = _tiltY + (_targetTiltY - _tiltY) * 0.2;
      notifyListeners();
    }
  }
}
