enum WorldType {
  numberKingdom(1, 'Number Kingdom', 'संख्या राज्य', 0xFF80C94A, '🔢'),
  letterSoundForest(2, 'Letter and Sound Forest', 'वर्ण और ध्वनि वन', 0xFF7150B8, '🔤'),
  wordStoryVillage(3, 'Word and Story Village', 'शब्द और कहानी गाँव', 0xFFF67C72, '📖'),
  shapeColorStudio(4, 'Shape and Color Studio', 'आकार और रंग स्टूडियो', 0xFF75DDF2, '🎨'),
  memoryMeadow(5, 'Memory Meadow', 'स्मृति मैदान', 0xFFFFB236, '🧠'),
  puzzleCastle(6, 'Puzzle Castle', 'पहेली किला', 0xFFE056FD, '🧩'),
  logicLab(7, 'Logic Lab', 'तर्क प्रयोगशाला', 0xFF4834D4, '💡'),
  mathMarket(8, 'Math Market', 'गणित बाज़ार', 0xFF22A6B3, '🍎'),
  natureEveryday(9, 'Nature and Everyday World', 'प्रकृति और दैनिक दुनिया', 0xFF6AB04C, '🌿'),
  creativeArtMusic(10, 'Creative Art and Music', 'रचनात्मक कला और संगीत', 0xFFFF7979, '🎵'),
  movementCoordination(11, 'Movement and Coordination', 'गति और समन्वय', 0xFFF9CA24, '🏃'),
  thinkingAdventures(12, 'Thinking Adventures', 'सोच और खोज यात्रा', 0xFF30336B, '🧭');

  final int id;
  final String titleEn;
  final String titleHi;
  final int colorValue;
  final String iconEmoji;

  const WorldType(this.id, this.titleEn, this.titleHi, this.colorValue, this.iconEmoji);

  String localizedTitle(String locale) => locale == 'hi' ? titleHi : titleEn;
}

class GameDefinition {
  final String id; // e.g. 'G001'
  final WorldType world;
  final String nameEn;
  final String nameHi;
  final String summaryEn;
  final String summaryHi;
  final String interactionEngineId; // E01..E12
  final List<String> skillTags;
  final int minAge;
  final int maxAge;
  final bool isFlagship;
  final bool isPlayable;

  const GameDefinition({
    required this.id,
    required this.world,
    required this.nameEn,
    required this.nameHi,
    required this.summaryEn,
    required this.summaryHi,
    required this.interactionEngineId,
    required this.skillTags,
    this.minAge = 3,
    this.maxAge = 8,
    this.isFlagship = false,
    this.isPlayable = false,
  });

  String localizedName(String locale) => locale == 'hi' ? nameHi : nameEn;
  String localizedSummary(String locale) => locale == 'hi' ? summaryHi : summaryEn;
}
