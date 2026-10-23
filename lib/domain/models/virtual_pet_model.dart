import 'dart:convert';

enum PetStage {
  egg(
    name: 'Mystic Egg',
    nameHi: 'जादुई अंडा',
    description: 'Keep completing learning games to help the egg hatch!',
    descriptionHi: 'अंडे से बच्चा निकालने के लिए खेल पूरे करें!',
    requiredXp: 0,
    emoji: '🥚',
  ),
  baby(
    name: 'Baby Leo',
    nameHi: 'छोटा लियो',
    description: 'A cheerful baby cub learning his first words and numbers!',
    descriptionHi: 'एक नन्हा शेर का बच्चा जो नए शब्द और संख्याएं सीख रहा है!',
    requiredXp: 100,
    emoji: '🦁',
  ),
  cub(
    name: 'Playful Cub',
    nameHi: 'नटखट शावक',
    description: 'Growing bigger and wiser with every puzzle solved!',
    descriptionHi: 'हर पहेली के साथ और बड़ा और बुद्धिमान होता जा रहा है!',
    requiredXp: 300,
    emoji: '🦁',
  ),
  king(
    name: 'Royal King Leo',
    nameHi: 'राजसी राजा लियो',
    description: 'The wise and proud ruler of the KRIDO Kingdom!',
    descriptionHi: 'क्रीडो साम्राज्य का बुद्धिमान और गर्वित राजा!',
    requiredXp: 600,
    emoji: '👑',
  );

  final String name;
  final String nameHi;
  final String description;
  final String descriptionHi;
  final int requiredXp;
  final String emoji;

  const PetStage({
    required this.name,
    required this.nameHi,
    required this.description,
    required this.descriptionHi,
    required this.requiredXp,
    required this.emoji,
  });

  PetStage get nextStage {
    switch (this) {
      case PetStage.egg:
        return PetStage.baby;
      case PetStage.baby:
        return PetStage.cub;
      case PetStage.cub:
        return PetStage.king;
      case PetStage.king:
        return PetStage.king;
    }
  }

  bool get isMaxStage => this == PetStage.king;
}

class VirtualPetState {
  final PetStage stage;
  final int level;
  final int xp;
  final int treatsAvailable;
  final double happiness; // 0.0 to 1.0
  final int totalFedCount;
  final int completedModulesCount;
  final DateTime lastFed;

  const VirtualPetState({
    this.stage = PetStage.egg,
    this.level = 1,
    this.xp = 0,
    this.treatsAvailable = 3, // Starter treats
    this.happiness = 0.8,
    this.totalFedCount = 0,
    this.completedModulesCount = 0,
    required this.lastFed,
  });

  VirtualPetState copyWith({
    PetStage? stage,
    int? level,
    int? xp,
    int? treatsAvailable,
    double? happiness,
    int? totalFedCount,
    int? completedModulesCount,
    DateTime? lastFed,
  }) {
    return VirtualPetState(
      stage: stage ?? this.stage,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      treatsAvailable: treatsAvailable ?? this.treatsAvailable,
      happiness: happiness ?? this.happiness,
      totalFedCount: totalFedCount ?? this.totalFedCount,
      completedModulesCount:
          completedModulesCount ?? this.completedModulesCount,
      lastFed: lastFed ?? this.lastFed,
    );
  }

  int get xpForNextStage {
    if (stage.isMaxStage) return stage.requiredXp;
    return stage.nextStage.requiredXp;
  }

  double get evolutionProgress {
    if (stage.isMaxStage) return 1.0;
    final startXp = stage.requiredXp;
    final targetXp = stage.nextStage.requiredXp;
    final currentInStage = (xp - startXp).clamp(0, targetXp - startXp);
    return currentInStage / (targetXp - startXp);
  }

  int get xpNeededToEvolve {
    if (stage.isMaxStage) return 0;
    return (stage.nextStage.requiredXp - xp).clamp(0, 9999);
  }

  Map<String, dynamic> toMap() => {
        'stage': stage.name,
        'level': level,
        'xp': xp,
        'treatsAvailable': treatsAvailable,
        'happiness': happiness,
        'totalFedCount': totalFedCount,
        'completedModulesCount': completedModulesCount,
        'lastFed': lastFed.toIso8601String(),
      };

  factory VirtualPetState.fromMap(Map<String, dynamic> map) {
    final stageName = map['stage'] as String? ?? 'egg';
    final stage = PetStage.values.firstWhere(
      (s) => s.name == stageName,
      orElse: () => PetStage.egg,
    );
    return VirtualPetState(
      stage: stage,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      treatsAvailable: map['treatsAvailable'] as int? ?? 3,
      happiness: (map['happiness'] as num?)?.toDouble() ?? 0.8,
      totalFedCount: map['totalFedCount'] as int? ?? 0,
      completedModulesCount: map['completedModulesCount'] as int? ?? 0,
      lastFed: map['lastFed'] != null
          ? DateTime.tryParse(map['lastFed'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory VirtualPetState.fromJson(String source) =>
      VirtualPetState.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
