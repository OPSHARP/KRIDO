import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/providers.dart';

class StepTrackerState {
  final int stepsToday;
  final int dailyGoal;
  final int activeMinutes;
  final String dateKey; // YYYY-MM-DD
  final List<String> unlockedBadges;

  const StepTrackerState({
    this.stepsToday = 1420,
    this.dailyGoal = 3000,
    this.activeMinutes = 24,
    required this.dateKey,
    this.unlockedBadges = const ['Meadow Hopper 🐰'],
  });

  double get goalProgress => (stepsToday / dailyGoal).clamp(0.0, 1.0);
  int get caloriesBurned => (stepsToday * 0.04).round();
  double get distanceKm => (stepsToday * 0.0006).clamp(0.0, 999.0);

  StepTrackerState copyWith({
    int? stepsToday,
    int? dailyGoal,
    int? activeMinutes,
    String? dateKey,
    List<String>? unlockedBadges,
  }) {
    return StepTrackerState(
      stepsToday: stepsToday ?? this.stepsToday,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      dateKey: dateKey ?? this.dateKey,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
    );
  }

  Map<String, dynamic> toMap() => {
        'stepsToday': stepsToday,
        'dailyGoal': dailyGoal,
        'activeMinutes': activeMinutes,
        'dateKey': dateKey,
        'unlockedBadges': unlockedBadges,
      };

  factory StepTrackerState.fromMap(Map<String, dynamic> map) {
    return StepTrackerState(
      stepsToday: map['stepsToday'] as int? ?? 1420,
      dailyGoal: map['dailyGoal'] as int? ?? 3000,
      activeMinutes: map['activeMinutes'] as int? ?? 24,
      dateKey: map['dateKey'] as String? ?? _todayKey(),
      unlockedBadges: (map['unlockedBadges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Meadow Hopper 🐰'],
    );
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class StepTrackerNotifier extends Notifier<StepTrackerState> {
  String _profileId = 'default_profile';

  String get _storageKey => 'step_tracker_$_profileId';

  @override
  StepTrackerState build() {
    final profile = ref.watch(currentProfileProvider);
    _profileId = profile?.id ?? 'default_profile';

    Future.microtask(() {
      if (ref.mounted) {
        _loadState();
      }
    });

    return StepTrackerState(dateKey: StepTrackerState._todayKey());
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && ref.mounted) {
        final loaded = StepTrackerState.fromMap(jsonDecode(raw) as Map<String, dynamic>);
        if (loaded.dateKey == StepTrackerState._todayKey()) {
          state = loaded;
        } else {
          state = StepTrackerState(
            dateKey: StepTrackerState._todayKey(),
            dailyGoal: loaded.dailyGoal,
            stepsToday: 0,
            activeMinutes: 0,
            unlockedBadges: loaded.unlockedBadges,
          );
          _saveState();
        }
      }
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toMap()));
    } catch (_) {}
  }

  void addSteps(int steps) {
    final newSteps = state.stepsToday + steps;
    final newMinutes = state.activeMinutes + (steps ~/ 100);
    final badges = List<String>.from(state.unlockedBadges);

    if (newSteps >= 1000 && !badges.contains('Meadow Hopper 🐰')) {
      badges.add('Meadow Hopper 🐰');
    }
    if (newSteps >= 2000 && !badges.contains('Forest Trekker 🌲')) {
      badges.add('Forest Trekker 🌲');
    }
    if (newSteps >= 3000 && !badges.contains('Kingdom Champion 👑')) {
      badges.add('Kingdom Champion 👑');
    }

    state = state.copyWith(
      stepsToday: newSteps,
      activeMinutes: newMinutes,
      unlockedBadges: badges,
    );

    _saveState();
  }

  void setGoal(int newGoal) {
    state = state.copyWith(dailyGoal: newGoal);
    _saveState();
  }
}
