class SkillProgress {
  final String profileId;
  final String skillId;
  final String languageTrack;
  final int tier;
  final int independentSuccesses;
  final int assistedSuccesses;
  final int totalOpportunities;
  final DateTime lastPracticedAt;
  final bool parentDifficultyLock;

  SkillProgress({
    required this.profileId,
    required this.skillId,
    this.languageTrack = 'standard',
    this.tier = 1,
    this.independentSuccesses = 0,
    this.assistedSuccesses = 0,
    this.totalOpportunities = 0,
    DateTime? lastPracticedAt,
    this.parentDifficultyLock = false,
  }) : lastPracticedAt = lastPracticedAt ?? DateTime.now();

  double get independentRate {
    if (totalOpportunities == 0) return 1.0;
    return independentSuccesses / totalOpportunities;
  }

  String get parentMasteryLabel {
    if (totalOpportunities == 0) return 'Not yet practiced';
    if (independentRate >= 0.8 && totalOpportunities >= 5) {
      return 'Often independent';
    }
    if (independentRate >= 0.5) return 'Developing steadily';
    return 'Benefits from gentle help';
  }

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'skillId': skillId,
      'languageTrack': languageTrack,
      'tier': tier,
      'independentSuccesses': independentSuccesses,
      'assistedSuccesses': assistedSuccesses,
      'totalOpportunities': totalOpportunities,
      'lastPracticedAt': lastPracticedAt.toIso8601String(),
      'parentDifficultyLock': parentDifficultyLock ? 1 : 0,
    };
  }

  factory SkillProgress.fromMap(Map<String, dynamic> map) {
    return SkillProgress(
      profileId: map['profileId'] as String,
      skillId: map['skillId'] as String,
      languageTrack: map['languageTrack'] as String? ?? 'standard',
      tier: map['tier'] as int? ?? 1,
      independentSuccesses: map['independentSuccesses'] as int? ?? 0,
      assistedSuccesses: map['assistedSuccesses'] as int? ?? 0,
      totalOpportunities: map['totalOpportunities'] as int? ?? 0,
      lastPracticedAt:
          DateTime.tryParse(map['lastPracticedAt'] as String? ?? '') ??
              DateTime.now(),
      parentDifficultyLock: (map['parentDifficultyLock'] as int? ?? 0) == 1,
    );
  }
}

class DailyAdventure {
  final String profileId;
  final String localDate; // YYYY-MM-DD
  final List<String> challengeIds;
  final List<bool> completionFlags;
  final bool rewardClaimed;

  DailyAdventure({
    required this.profileId,
    required this.localDate,
    required this.challengeIds,
    required this.completionFlags,
    this.rewardClaimed = false,
  });

  bool get isAllCompleted =>
      completionFlags.isNotEmpty && completionFlags.every((f) => f);

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'localDate': localDate,
      'challengeIds': challengeIds.join(','),
      'completionFlags': completionFlags.map((f) => f ? '1' : '0').join(','),
      'rewardClaimed': rewardClaimed ? 1 : 0,
    };
  }

  factory DailyAdventure.fromMap(Map<String, dynamic> map) {
    final ids = (map['challengeIds'] as String? ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();
    final flags = (map['completionFlags'] as String? ?? '')
        .split(',')
        .map((s) => s == '1')
        .toList();
    return DailyAdventure(
      profileId: map['profileId'] as String,
      localDate: map['localDate'] as String,
      challengeIds: ids,
      completionFlags: flags,
      rewardClaimed: (map['rewardClaimed'] as int? ?? 0) == 1,
    );
  }
}
