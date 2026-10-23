import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentGateService extends ChangeNotifier {
  static const String _pinKey = 'parent_gate_pin';
  static const String _failedAttemptsKey = 'parent_gate_fails';
  static const String _lockoutTimestampKey = 'parent_gate_lockout';

  String _pin = '1234'; // Default initial PIN
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  int get failedAttempts => _failedAttempts;
  bool get isLockedOut =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  int get remainingLockoutSeconds {
    if (!isLockedOut || _lockoutUntil == null) return 0;
    final diff = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff <= 0 ? 1 : diff;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _pin = prefs.getString(_pinKey) ?? '1234';
    _failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    final lockoutMs = prefs.getInt(_lockoutTimestampKey);
    if (lockoutMs != null) {
      _lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutMs);
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    if (isLockedOut) return false;

    if (enteredPin == _pin) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_failedAttemptsKey, 0);
      await prefs.remove(_lockoutTimestampKey);
      notifyListeners();
      return true;
    } else {
      _failedAttempts++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_failedAttemptsKey, _failedAttempts);

      // Rate limiting: 5 fails -> 30 seconds lockout
      if (_failedAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
        await prefs.setInt(
          _lockoutTimestampKey,
          _lockoutUntil!.millisecondsSinceEpoch,
        );
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> updatePin(String newPin) async {
    _pin = newPin;
    _failedAttempts = 0;
    _lockoutUntil = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
    await prefs.setInt(_failedAttemptsKey, 0);
    await prefs.remove(_lockoutTimestampKey);
    notifyListeners();
  }
}
