import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/game_definition.dart';
import '../../games/registry.dart';

enum CurriculumPreset {
  toddler(
    id: 'toddler',
    titleEn: 'Little Cubs (Ages 2–3)',
    titleHi: 'छोटे शावक (आयु 2–3)',
    subtitleEn: 'Sensory sounds, big shapes & motor touch',
    subtitleHi: 'ध्वनियां, बड़े आकार और आसान स्पर्श',
    emoji: '🐣',
    minAge: 2,
    maxAge: 3,
  ),
  preschool(
    id: 'preschool',
    titleEn: 'Curious Explorers (Ages 4–5)',
    titleHi: 'जिज्ञासु खोजकर्ता (आयु 4–5)',
    subtitleEn: 'Letters A-Z, counting to 20, rhymes & pairs',
    subtitleHi: 'वर्णमाला A-Z, 1 से 20 गिनती, तुकबंदी',
    emoji: '🎨',
    minAge: 4,
    maxAge: 5,
  ),
  earlyReader(
    id: 'earlyReader',
    titleEn: 'Kingdom Scholars (Ages 6–8)',
    titleHi: 'राजशाही विद्वान (आयु 6–8)',
    subtitleEn: 'Spelling, math additions & complex logic',
    subtitleHi: 'वर्तनी, गणितीय जोड़ व तर्क पहेलियां',
    emoji: '🧠',
    minAge: 6,
    maxAge: 8,
  ),
  allAges(
    id: 'allAges',
    titleEn: 'All Ages (Full Kingdom)',
    titleHi: 'सभी उम्र (सम्पूर्ण राज्य)',
    subtitleEn: 'Explore all games and learning islands freely',
    subtitleHi: 'सभी खेलों और द्वीपों को बिना रोक-टोक खेलें',
    emoji: '👑',
    minAge: 2,
    maxAge: 12,
  );

  final String id;
  final String titleEn;
  final String titleHi;
  final String subtitleEn;
  final String subtitleHi;
  final String emoji;
  final int minAge;
  final int maxAge;

  const CurriculumPreset({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    required this.subtitleEn,
    required this.subtitleHi,
    required this.emoji,
    required this.minAge,
    required this.maxAge,
  });

  String title(String locale) => locale == 'hi' ? titleHi : titleEn;
  String subtitle(String locale) => locale == 'hi' ? subtitleHi : subtitleEn;
}

class AgeCurriculumNotifier extends Notifier<CurriculumPreset> {
  static const String _prefKey = 'curriculum_preset_v1';

  @override
  CurriculumPreset build() {
    _loadFromStorage();
    return CurriculumPreset.allAges;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null) {
        state = CurriculumPreset.values.firstWhere(
          (p) => p.id == saved,
          orElse: () => CurriculumPreset.allAges,
        );
      }
    } catch (_) {}
  }

  Future<void> setPreset(CurriculumPreset preset) async {
    state = preset;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, preset.id);
    } catch (_) {}
  }

  List<GameDefinition> filterGames(List<GameDefinition> games) {
    if (state == CurriculumPreset.allAges) return games;
    return games.where((g) {
      // Overlap logic: game's minAge <= preset.maxAge AND game's maxAge >= preset.minAge
      return g.minAge <= state.maxAge && g.maxAge >= state.minAge;
    }).toList();
  }
}

final curriculumPresetProvider =
    NotifierProvider<AgeCurriculumNotifier, CurriculumPreset>(
  AgeCurriculumNotifier.new,
);

final filteredGamesProvider = Provider<List<GameDefinition>>((ref) {
  final presetNotifier = ref.watch(curriculumPresetProvider.notifier);
  // Watch preset state so this provider updates when preset changes
  ref.watch(curriculumPresetProvider);
  return presetNotifier.filterGames(GameRegistry.allGames);
});
