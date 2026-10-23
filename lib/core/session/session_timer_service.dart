import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionTimerService extends ChangeNotifier {
  static const String _limitMinutesKey = 'session_limit_minutes';

  int _limitMinutes = 10; // Default 10 minutes per PRD Section 1
  int _elapsedSeconds = 0;
  Timer? _ticker;
  bool _isPaused = false;
  bool _hasWarnedOneMinute = false;
  bool _isBreakTime = false;

  int get limitMinutes => _limitMinutes;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isPaused => _isPaused;
  bool get hasWarnedOneMinute => _hasWarnedOneMinute;
  bool get isBreakTime => _isBreakTime;

  int get remainingSeconds {
    if (_limitMinutes <= 0) return 999999; // Unlimited
    final total = _limitMinutes * 60;
    return (total - _elapsedSeconds).clamp(0, total);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _limitMinutes = prefs.getInt(_limitMinutesKey) ?? 10;
    startTimer();
  }

  void setLimitMinutes(int minutes) async {
    _limitMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_limitMinutesKey, minutes);
    notifyListeners();
  }

  void startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused || _limitMinutes <= 0) return;

      _elapsedSeconds++;

      final rem = remainingSeconds;
      if (rem <= 60 && !_hasWarnedOneMinute && rem > 0) {
        _hasWarnedOneMinute = true;
        notifyListeners();
      }

      if (rem <= 0 && !_isBreakTime) {
        _isBreakTime = true;
        _ticker?.cancel();
        notifyListeners();
      }
    });
  }

  void pause() {
    _isPaused = true;
    notifyListeners();
  }

  void stopTimer() {
    _ticker?.cancel();
    _ticker = null;
  }

  void resume() {
    _isPaused = false;
    notifyListeners();
  }

  /// Reset or extend session after parent gate authorization
  void extendSession(int additionalMinutes) {
    _elapsedSeconds = 0;
    _hasWarnedOneMinute = false;
    _isBreakTime = false;
    _limitMinutes = additionalMinutes;
    startTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
