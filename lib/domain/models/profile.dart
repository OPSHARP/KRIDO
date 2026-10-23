enum AgeBand {
  explorer('Explorer (3–4 years)', 3, 4),
  builder('Builder (5–6 years)', 5, 6),
  thinker('Thinker (7–8 years)', 7, 8);

  final String label;
  final int minAge;
  final int maxAge;

  const AgeBand(this.label, this.minAge, this.maxAge);
}

class Profile {
  final String id;
  final String avatarId;
  final String? nickname;
  final AgeBand ageBand;
  final String uiLocale; // 'en' or 'hi'
  final String learningTrack;
  final bool soundEffectsEnabled;
  final bool narrationEnabled;
  final bool backgroundMusicEnabled;
  final bool reducedMotion;
  final bool highContrast;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.avatarId,
    this.nickname,
    this.ageBand = AgeBand.builder,
    this.uiLocale = 'en',
    this.learningTrack = 'standard',
    this.soundEffectsEnabled = true,
    this.narrationEnabled = true,
    this.backgroundMusicEnabled = true,
    this.reducedMotion = false,
    this.highContrast = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get displayName =>
      nickname?.isNotEmpty == true ? nickname! : 'Adventurer';

  Profile copyWith({
    String? avatarId,
    String? nickname,
    AgeBand? ageBand,
    String? uiLocale,
    String? learningTrack,
    bool? soundEffectsEnabled,
    bool? narrationEnabled,
    bool? backgroundMusicEnabled,
    bool? reducedMotion,
    bool? highContrast,
  }) {
    return Profile(
      id: id,
      avatarId: avatarId ?? this.avatarId,
      nickname: nickname ?? this.nickname,
      ageBand: ageBand ?? this.ageBand,
      uiLocale: uiLocale ?? this.uiLocale,
      learningTrack: learningTrack ?? this.learningTrack,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      narrationEnabled: narrationEnabled ?? this.narrationEnabled,
      backgroundMusicEnabled:
          backgroundMusicEnabled ?? this.backgroundMusicEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      highContrast: highContrast ?? this.highContrast,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avatarId': avatarId,
      'nickname': nickname,
      'ageBand': ageBand.name,
      'uiLocale': uiLocale,
      'learningTrack': learningTrack,
      'soundEffectsEnabled': soundEffectsEnabled ? 1 : 0,
      'narrationEnabled': narrationEnabled ? 1 : 0,
      'backgroundMusicEnabled': backgroundMusicEnabled ? 1 : 0,
      'reducedMotion': reducedMotion ? 1 : 0,
      'highContrast': highContrast ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      avatarId: map['avatarId'] as String? ?? 'avatar_fox',
      nickname: map['nickname'] as String?,
      ageBand: AgeBand.values.firstWhere(
        (b) => b.name == map['ageBand'],
        orElse: () => AgeBand.builder,
      ),
      uiLocale: map['uiLocale'] as String? ?? 'en',
      learningTrack: map['learningTrack'] as String? ?? 'standard',
      soundEffectsEnabled: (map['soundEffectsEnabled'] as int? ?? 1) == 1,
      narrationEnabled: (map['narrationEnabled'] as int? ?? 1) == 1,
      backgroundMusicEnabled:
          (map['backgroundMusicEnabled'] as int? ?? 1) == 1,
      reducedMotion: (map['reducedMotion'] as int? ?? 0) == 1,
      highContrast: (map['highContrast'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
