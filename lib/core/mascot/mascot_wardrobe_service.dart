import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LeoCrown {
  classicGold,
  diamondTiara,
  emeraldLaurel,
  pirateBandana,
  starryNightcap;

  String get displayName {
    switch (this) {
      case LeoCrown.classicGold:
        return 'Classic Gold';
      case LeoCrown.diamondTiara:
        return 'Ice Tiara';
      case LeoCrown.emeraldLaurel:
        return 'Leaf Wreath';
      case LeoCrown.pirateBandana:
        return 'Pirate Bandana';
      case LeoCrown.starryNightcap:
        return 'Star Nightcap';
    }
  }

  String get emoji {
    switch (this) {
      case LeoCrown.classicGold:
        return '👑';
      case LeoCrown.diamondTiara:
        return '💎';
      case LeoCrown.emeraldLaurel:
        return '🌿';
      case LeoCrown.pirateBandana:
        return '🏴‍☠️';
      case LeoCrown.starryNightcap:
        return '🌙';
    }
  }
}

enum LeoCape {
  royalPurple,
  crimsonHero,
  azureKnight,
  goldenSun;

  String get displayName {
    switch (this) {
      case LeoCape.royalPurple:
        return 'Royal Purple';
      case LeoCape.crimsonHero:
        return 'Hero Crimson';
      case LeoCape.azureKnight:
        return 'Knight Azure';
      case LeoCape.goldenSun:
        return 'Solar Gold';
    }
  }

  Color get color {
    switch (this) {
      case LeoCape.royalPurple:
        return const Color(0xFF7B1FA2);
      case LeoCape.crimsonHero:
        return const Color(0xFFE53935);
      case LeoCape.azureKnight:
        return const Color(0xFF1E88E5);
      case LeoCape.goldenSun:
        return const Color(0xFFFFB300);
    }
  }

  String get emoji {
    switch (this) {
      case LeoCape.royalPurple:
        return '💜';
      case LeoCape.crimsonHero:
        return '❤️';
      case LeoCape.azureKnight:
        return '💙';
      case LeoCape.goldenSun:
        return '💛';
    }
  }
}

enum LeoAccessory {
  none,
  starShades,
  brassGoggles,
  pinkBowtie;

  String get displayName {
    switch (this) {
      case LeoAccessory.none:
        return 'None';
      case LeoAccessory.starShades:
        return 'Star Shades';
      case LeoAccessory.brassGoggles:
        return 'Explorer Goggles';
      case LeoAccessory.pinkBowtie:
        return 'Royal Bowtie';
    }
  }

  String get emoji {
    switch (this) {
      case LeoAccessory.none:
        return '✨';
      case LeoAccessory.starShades:
        return '🕶️';
      case LeoAccessory.brassGoggles:
        return '🥽';
      case LeoAccessory.pinkBowtie:
        return '🎀';
    }
  }
}

class LeoOutfit {
  final LeoCrown crown;
  final LeoCape cape;
  final LeoAccessory accessory;

  const LeoOutfit({
    this.crown = LeoCrown.classicGold,
    this.cape = LeoCape.royalPurple,
    this.accessory = LeoAccessory.none,
  });

  LeoOutfit copyWith({
    LeoCrown? crown,
    LeoCape? cape,
    LeoAccessory? accessory,
  }) {
    return LeoOutfit(
      crown: crown ?? this.crown,
      cape: cape ?? this.cape,
      accessory: accessory ?? this.accessory,
    );
  }
}

class MascotWardrobeNotifier extends Notifier<LeoOutfit> {
  static const _prefCrown = 'leo_wardrobe_crown';
  static const _prefCape = 'leo_wardrobe_cape';
  static const _prefAccessory = 'leo_wardrobe_accessory';

  @override
  LeoOutfit build() {
    _loadSavedOutfit();
    return const LeoOutfit();
  }

  Future<void> _loadSavedOutfit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final crownIdx = prefs.getInt(_prefCrown) ?? 0;
      final capeIdx = prefs.getInt(_prefCape) ?? 0;
      final accIdx = prefs.getInt(_prefAccessory) ?? 0;

      final crown = LeoCrown.values[crownIdx.clamp(0, LeoCrown.values.length - 1)];
      final cape = LeoCape.values[capeIdx.clamp(0, LeoCape.values.length - 1)];
      final acc = LeoAccessory.values[accIdx.clamp(0, LeoAccessory.values.length - 1)];

      state = LeoOutfit(crown: crown, cape: cape, accessory: acc);
    } catch (_) {}
  }

  Future<void> setCrown(LeoCrown crown) async {
    state = state.copyWith(crown: crown);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefCrown, crown.index);
    } catch (_) {}
  }

  Future<void> setCape(LeoCape cape) async {
    state = state.copyWith(cape: cape);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefCape, cape.index);
    } catch (_) {}
  }

  Future<void> setAccessory(LeoAccessory accessory) async {
    state = state.copyWith(accessory: accessory);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefAccessory, accessory.index);
    } catch (_) {}
  }
}

final mascotWardrobeProvider =
    NotifierProvider<MascotWardrobeNotifier, LeoOutfit>(
  MascotWardrobeNotifier.new,
);
