import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/ads/ad_service.dart';
import '../core/audio/audio_service.dart';
import '../core/database/app_database.dart';
import '../core/health/step_tracker_service.dart';
import '../core/pet/virtual_pet_service.dart';
import '../core/session/parent_gate_service.dart';
import '../core/session/session_timer_service.dart';
import '../domain/models/daily_adventure.dart';
import '../domain/models/profile.dart';
import '../domain/models/virtual_pet_model.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final adServiceProvider = ChangeNotifierProvider<AdService>((ref) {
  return AdService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final parentGateServiceProvider = ChangeNotifierProvider<ParentGateService>((ref) {
  final service = ParentGateService();
  service.init();
  return service;
});

final sessionTimerServiceProvider = ChangeNotifierProvider<SessionTimerService>((ref) {
  final service = SessionTimerService();
  service.init();
  return service;
});

final profilesListProvider = FutureProvider<List<Profile>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getProfiles();
});

class CurrentProfileNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => null;

  void selectProfile(Profile profile) {
    state = profile;
  }

  Future<void> createOrUpdateProfile(Profile profile) async {
    final db = ref.read(databaseProvider);
    await db.saveProfile(profile);
    state = profile;
  }

  Future<void> deleteCurrentProfile() async {
    if (state != null) {
      final db = ref.read(databaseProvider);
      await db.deleteProfile(state!.id);
      state = null;
    }
  }
}

final currentProfileProvider =
    NotifierProvider<CurrentProfileNotifier, Profile?>(
  CurrentProfileNotifier.new,
);

class DailyAdventureNotifier extends Notifier<DailyAdventure?> {
  @override
  DailyAdventure? build() {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return null;
    Future.microtask(() => _loadDailyAdventure(profile.id));
    return null;
  }

  Future<void> _loadDailyAdventure(String profileId) async {
    final db = ref.read(databaseProvider);
    final today = DateTime.now().toIso8601String().split('T').first;
    var adventure = await db.getDailyAdventure(profileId, today);

    if (adventure == null) {
      adventure = DailyAdventure(
        profileId: profileId,
        localDate: today,
        challengeIds: ['G001', 'G011', 'G051'],
        completionFlags: [false, false, false],
        rewardClaimed: false,
      );
      await db.saveDailyAdventure(adventure);
    }

    // Refresh against attempts completed today
    final attempts = await db.getAttemptsForProfile(profileId);
    final todayAttempts = attempts.where((a) => a.completedAt.toIso8601String().startsWith(today)).toList();
    final updatedFlags = List<bool>.from(adventure.completionFlags);
    for (int i = 0; i < adventure.challengeIds.length; i++) {
      final gId = adventure.challengeIds[i];
      if (todayAttempts.any((a) => a.gameId == gId && a.completed)) {
        updatedFlags[i] = true;
      }
    }

    if (updatedFlags.toString() != adventure.completionFlags.toString()) {
      adventure = DailyAdventure(
        profileId: adventure.profileId,
        localDate: adventure.localDate,
        challengeIds: adventure.challengeIds,
        completionFlags: updatedFlags,
        rewardClaimed: adventure.rewardClaimed,
      );
      await db.saveDailyAdventure(adventure);
    }

    if (ref.read(currentProfileProvider)?.id != profileId) return;
    state = adventure;
  }

  Future<bool> claimReward() async {
    final current = state;
    if (current == null || !current.isAllCompleted || current.rewardClaimed) {
      return false;
    }
    final db = ref.read(databaseProvider);
    await db.unlockSticker(
      profileId: current.profileId,
      stickerId: 'stk_trophy',
      sourceCompletionId: 'daily_${current.localDate}',
    );

    final updated = DailyAdventure(
      profileId: current.profileId,
      localDate: current.localDate,
      challengeIds: current.challengeIds,
      completionFlags: current.completionFlags,
      rewardClaimed: true,
    );
    await db.saveDailyAdventure(updated);
    state = updated;
    return true;
  }

  Future<void> refresh() async {
    final profile = ref.read(currentProfileProvider);
    if (profile != null) {
      await _loadDailyAdventure(profile.id);
    }
  }
}

final dailyAdventureProvider =
    NotifierProvider<DailyAdventureNotifier, DailyAdventure?>(
  DailyAdventureNotifier.new,
);

final virtualPetProvider =
    NotifierProvider<VirtualPetNotifier, VirtualPetState>(
  VirtualPetNotifier.new,
);

final stepTrackerProvider =
    NotifierProvider<StepTrackerNotifier, StepTrackerState>(
  StepTrackerNotifier.new,
);
