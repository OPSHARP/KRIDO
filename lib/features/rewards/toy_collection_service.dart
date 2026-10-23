import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/audio/audio_service.dart';

enum ToyRarity {
  common,
  rare,
  epic,
  legendary;

  String get displayName {
    switch (this) {
      case ToyRarity.common:
        return 'Common ⭐️';
      case ToyRarity.rare:
        return 'Rare 🌟';
      case ToyRarity.epic:
        return 'Epic 💫';
      case ToyRarity.legendary:
        return 'Legendary 👑';
    }
  }

  Color get color {
    switch (this) {
      case ToyRarity.common:
        return const Color(0xFF42A5F5);
      case ToyRarity.rare:
        return const Color(0xFFAB47BC);
      case ToyRarity.epic:
        return const Color(0xFFFF7043);
      case ToyRarity.legendary:
        return const Color(0xFFFFD700);
    }
  }
}

class ToyItem {
  final String id;
  final String name;
  final String hindiName;
  final String emoji;
  final String tagline;
  final ToyRarity rarity;
  final Color primaryColor;
  final Color accentColor;

  const ToyItem({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.emoji,
    required this.tagline,
    required this.rarity,
    required this.primaryColor,
    required this.accentColor,
  });
}

class ToyCollectionState {
  final List<String> unlockedToyIds;
  final int eggsAvailable;

  const ToyCollectionState({
    required this.unlockedToyIds,
    required this.eggsAvailable,
  });

  ToyCollectionState copyWith({
    List<String>? unlockedToyIds,
    int? eggsAvailable,
  }) {
    return ToyCollectionState(
      unlockedToyIds: unlockedToyIds ?? this.unlockedToyIds,
      eggsAvailable: eggsAvailable ?? this.eggsAvailable,
    );
  }
}

class ToyCollectionNotifier extends Notifier<ToyCollectionState> {
  static const _prefUnlockedKey = 'krido_unlocked_toys';
  static const _prefEggsKey = 'krido_gacha_eggs_count';

  static const List<ToyItem> allToys = [
    ToyItem(
      id: 'leo_gold',
      name: 'Golden Prince Leo',
      hindiName: 'स्वर्ण राजकुमार लियो',
      emoji: '🦁',
      tagline: 'The brave royal lion who guides your learning adventures!',
      rarity: ToyRarity.legendary,
      primaryColor: Color(0xFFFFB300),
      accentColor: Color(0xFFFF6F00),
    ),
    ToyItem(
      id: 'rocket_space',
      name: 'Star Hopper Rocket',
      hindiName: 'तारों का रॉकेट',
      emoji: '🚀',
      tagline: '3... 2... 1... Blastoff to the colorful galaxy!',
      rarity: ToyRarity.rare,
      primaryColor: Color(0xFF00E5FF),
      accentColor: Color(0xFF0091EA),
    ),
    ToyItem(
      id: 'dino_rex',
      name: 'Baby Dino Rex',
      hindiName: 'छोटा डायनासोर',
      emoji: '🦖',
      tagline: 'Stomps with tiny feet and roars with joy!',
      rarity: ToyRarity.epic,
      primaryColor: Color(0xFF66BB6A),
      accentColor: Color(0xFF2E7D32),
    ),
    ToyItem(
      id: 'unicorn_sparkle',
      name: 'Rainbow Unicorn',
      hindiName: 'इंद्रधनुषी गेंडा',
      emoji: '🦄',
      tagline: 'Spreads magic rainbow dust wherever it gallops!',
      rarity: ToyRarity.legendary,
      primaryColor: Color(0xFFFF80AB),
      accentColor: Color(0xFFC2185B),
    ),
    ToyItem(
      id: 'racecar_zoom',
      name: 'Speedy Turbo Kart',
      hindiName: 'तेज़ कार',
      emoji: '🏎️',
      tagline: 'Zoom zoom! The fastest wheels in the kingdom!',
      rarity: ToyRarity.common,
      primaryColor: Color(0xFFFF5252),
      accentColor: Color(0xFFD32F2F),
    ),
    ToyItem(
      id: 'teddy_plush',
      name: 'Honey Teddy Bear',
      hindiName: 'मीठा टेडी भालू',
      emoji: '🧸',
      tagline: 'Soft, cuddly, and loves sleepy night hugs!',
      rarity: ToyRarity.common,
      primaryColor: Color(0xFFFFB74D),
      accentColor: Color(0xFFE65100),
    ),
    ToyItem(
      id: 'robot_beep',
      name: 'Robo Pal 3000',
      hindiName: 'रोबो साथी',
      emoji: '🤖',
      tagline: 'Beep boop! Dances and computes fun kid games!',
      rarity: ToyRarity.rare,
      primaryColor: Color(0xFF7E57C2),
      accentColor: Color(0xFF4527A0),
    ),
    ToyItem(
      id: 'crown_jewel',
      name: 'Imperial Royal Crown',
      hindiName: 'शाही मुकुट',
      emoji: '👑',
      tagline: 'Glows with emeralds and rubies for the grand champion!',
      rarity: ToyRarity.epic,
      primaryColor: Color(0xFFFFD54F),
      accentColor: Color(0xFFFF8F00),
    ),
  ];

  @override
  ToyCollectionState build() {
    _loadState();
    return const ToyCollectionState(
      unlockedToyIds: ['teddy_plush'],
      eggsAvailable: 3, // Start kids with 3 exciting surprise eggs!
    );
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_prefUnlockedKey) ?? ['teddy_plush'];
      final eggs = prefs.getInt(_prefEggsKey) ?? 3;
      state = ToyCollectionState(
        unlockedToyIds: ids,
        eggsAvailable: eggs,
      );
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefUnlockedKey, state.unlockedToyIds);
      await prefs.setInt(_prefEggsKey, state.eggsAvailable);
    } catch (_) {}
  }

  Future<void> addEggs(int count) async {
    state = state.copyWith(eggsAvailable: state.eggsAvailable + count);
    await _saveState();
  }

  /// Hatch an egg: returns the hatched toy item
  ToyItem hatchEgg() {
    final rng = Random();
    // Prioritize locked toys so child regularly gets new toys
    final lockedToys = allToys.where((t) => !state.unlockedToyIds.contains(t.id)).toList();
    final ToyItem selectedToy;
    if (lockedToys.isNotEmpty) {
      selectedToy = lockedToys[rng.nextInt(lockedToys.length)];
    } else {
      selectedToy = allToys[rng.nextInt(allToys.length)];
    }

    final updatedUnlocked = Set<String>.from(state.unlockedToyIds)..add(selectedToy.id);
    final updatedEggs = (state.eggsAvailable - 1).clamp(0, 9999);

    state = ToyCollectionState(
      unlockedToyIds: updatedUnlocked.toList(),
      eggsAvailable: updatedEggs,
    );

    _saveState();
    AudioService().playCue(SoundCue.complete);
    AudioService().playCue(SoundCue.star);
    return selectedToy;
  }
}

final toyCollectionProvider =
    NotifierProvider<ToyCollectionNotifier, ToyCollectionState>(
  ToyCollectionNotifier.new,
);
