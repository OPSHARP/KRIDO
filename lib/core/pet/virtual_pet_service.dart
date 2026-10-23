import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/providers.dart';
import '../../domain/models/virtual_pet_model.dart';
import '../audio/audio_service.dart';

class VirtualPetNotifier extends Notifier<VirtualPetState> {
  bool _justEvolved = false;
  String _profileId = 'default_profile';

  bool get justEvolved => _justEvolved;
  void clearEvolvedFlag() => _justEvolved = false;

  String get _storageKey => 'virtual_pet_state_$_profileId';

  AudioService? get _audioService {
    try {
      return AudioService();
    } catch (_) {
      return null;
    }
  }

  @override
  VirtualPetState build() {
    final profile = ref.watch(currentProfileProvider);
    _profileId = profile?.id ?? 'default_profile';

    Future.microtask(() {
      if (ref.mounted) {
        _loadState();
      }
    });

    return VirtualPetState(lastFed: DateTime.now());
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && ref.mounted) {
        state = VirtualPetState.fromJson(raw);
      }
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, state.toJson());
    } catch (_) {}
  }

  /// Feeds the pet one treat
  Future<bool> feedPet(String treatType) async {
    if (state.treatsAvailable <= 0) {
      _audioService?.playCue(SoundCue.wrong);
      return false;
    }

    final newTreats = state.treatsAvailable - 1;
    final newFedCount = state.totalFedCount + 1;
    final newXp = state.xp + 20;

    _audioService?.playCue(SoundCue.star);

    _applyProgress(newTreats: newTreats, newXp: newXp, newFedCount: newFedCount, happiness: 1.0);
    return true;
  }

  /// Interacts with the pet (pat/hug)
  void patPet() {
    _audioService?.playCue(SoundCue.mascotRoar);
    state = state.copyWith(
      happiness: (state.happiness + 0.1).clamp(0.0, 1.0),
    );
    _saveState();
  }

  /// Awards rewards when child completes any learning challenge/game
  Future<void> awardModuleCompletion() async {
    final newTreats = state.treatsAvailable + 1; // +1 snack treat earned!
    final newModules = state.completedModulesCount + 1;
    final newXp = state.xp + 35; // +35 XP growth towards evolution

    _applyProgress(
      newTreats: newTreats,
      newXp: newXp,
      newModules: newModules,
    );
  }

  void _applyProgress({
    int? newTreats,
    int? newXp,
    int? newFedCount,
    int? newModules,
    double? happiness,
  }) {
    final currentXp = newXp ?? state.xp;
    PetStage currentStage = state.stage;

    // Check evolution
    if (!currentStage.isMaxStage && currentXp >= currentStage.nextStage.requiredXp) {
      currentStage = currentStage.nextStage;
      _justEvolved = true;
      _audioService?.playCue(SoundCue.complete);
    }

    final newLevel = (currentXp ~/ 100) + 1;

    state = state.copyWith(
      stage: currentStage,
      level: newLevel,
      xp: currentXp,
      treatsAvailable: newTreats ?? state.treatsAvailable,
      totalFedCount: newFedCount ?? state.totalFedCount,
      completedModulesCount: newModules ?? state.completedModulesCount,
      happiness: happiness ?? state.happiness,
      lastFed: DateTime.now(),
    );

    _saveState();
  }

  /// Reset pet for testing or new adventure
  Future<void> resetPet() async {
    state = VirtualPetState(
      stage: PetStage.egg,
      level: 1,
      xp: 0,
      treatsAvailable: 3,
      happiness: 0.8,
      totalFedCount: 0,
      completedModulesCount: 0,
      lastFed: DateTime.now(),
    );
    await _saveState();
  }
}
