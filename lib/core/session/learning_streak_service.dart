import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningStreakState {
  final int currentStreak;
  final int longestStreak;
  final String lastActiveDate;
  final bool day3RewardClaimed;
  final bool day7RewardClaimed;

  const LearningStreakState({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    this.day3RewardClaimed = false,
    this.day7RewardClaimed = false,
  });

  bool get isDay3Unlocked => currentStreak >= 3;
  bool get isDay7Unlocked => currentStreak >= 7;

  LearningStreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDate,
    bool? day3RewardClaimed,
    bool? day7RewardClaimed,
  }) {
    return LearningStreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      day3RewardClaimed: day3RewardClaimed ?? this.day3RewardClaimed,
      day7RewardClaimed: day7RewardClaimed ?? this.day7RewardClaimed,
    );
  }
}

class LearningStreakNotifier extends Notifier<LearningStreakState> {
  static const _keyCurrentStreak = 'streak_current_v1';
  static const _keyLongestStreak = 'streak_longest_v1';
  static const _keyLastDate = 'streak_last_date_v1';
  static const _keyDay3Claimed = 'streak_day3_claimed_v1';
  static const _keyDay7Claimed = 'streak_day7_claimed_v1';

  @override
  LearningStreakState build() {
    _loadFromStorage();
    return const LearningStreakState(
      currentStreak: 1,
      longestStreak: 1,
      lastActiveDate: '',
    );
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyCurrentStreak) ?? 1;
      final longest = prefs.getInt(_keyLongestStreak) ?? 1;
      final lastDate = prefs.getString(_keyLastDate) ?? '';
      final day3 = prefs.getBool(_keyDay3Claimed) ?? false;
      final day7 = prefs.getBool(_keyDay7Claimed) ?? false;

      state = LearningStreakState(
        currentStreak: current,
        longestStreak: longest,
        lastActiveDate: lastDate,
        day3RewardClaimed: day3,
        day7RewardClaimed: day7,
      );

      // Check if we should advance or maintain streak today
      _recordActivityToday();
    } catch (e) {
      debugPrint('LearningStreakNotifier error: $e');
    }
  }

  Future<void> recordGameCompleted() async {
    await _recordActivityToday();
  }

  Future<void> _recordActivityToday() async {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      if (state.lastActiveDate == todayStr) {
        // Already recorded today!
        return;
      }

      int newStreak = state.currentStreak;
      if (state.lastActiveDate.isEmpty) {
        newStreak = 1;
      } else {
        try {
          final parts = state.lastActiveDate.split('-');
          final lastDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          final diff = DateTime(now.year, now.month, now.day).difference(lastDate).inDays;
          if (diff == 1) {
            // Consecutive day!
            newStreak += 1;
          } else if (diff > 1) {
            // Broken streak, restart from 1
            newStreak = 1;
          }
        } catch (_) {
          newStreak = 1;
        }
      }

      final newLongest = newStreak > state.longestStreak ? newStreak : state.longestStreak;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCurrentStreak, newStreak);
      await prefs.setInt(_keyLongestStreak, newLongest);
      await prefs.setString(_keyLastDate, todayStr);

      state = state.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastActiveDate: todayStr,
      );
    } catch (e) {
      debugPrint('Error recording streak: $e');
    }
  }

  Future<bool> claimMilestoneReward(int milestoneDay) async {
    final prefs = await SharedPreferences.getInstance();
    if (milestoneDay == 3 && state.isDay3Unlocked && !state.day3RewardClaimed) {
      await prefs.setBool(_keyDay3Claimed, true);
      state = state.copyWith(day3RewardClaimed: true);
      return true;
    } else if (milestoneDay == 7 && state.isDay7Unlocked && !state.day7RewardClaimed) {
      await prefs.setBool(_keyDay7Claimed, true);
      state = state.copyWith(day7RewardClaimed: true);
      return true;
    }
    return false;
  }
}

final learningStreakProvider =
    NotifierProvider<LearningStreakNotifier, LearningStreakState>(
  LearningStreakNotifier.new,
);
