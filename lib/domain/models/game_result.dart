class GameResult {
  final String completionId;
  final String profileId;
  final String gameId;
  final String challengeId;
  final String contentVersion;
  final int seed;
  final List<String> skillTags;
  final int difficultyTier;
  final bool completed;
  final int activeDurationMs;
  final int independentCorrectActions;
  final int assessedActions;
  final int hintsUsed;
  final bool assisted;
  final String? creativeSavedPath;
  final DateTime completedAt;

  GameResult({
    required this.completionId,
    required this.profileId,
    required this.gameId,
    required this.challengeId,
    this.contentVersion = '1.0.0',
    required this.seed,
    this.skillTags = const [],
    this.difficultyTier = 1,
    required this.completed,
    required this.activeDurationMs,
    required this.independentCorrectActions,
    required this.assessedActions,
    required this.hintsUsed,
    required this.assisted,
    this.creativeSavedPath,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  double get accuracy {
    if (assessedActions == 0) return 1.0;
    return (independentCorrectActions / assessedActions).clamp(0.0, 1.0);
  }

  int get starsEarned {
    if (!completed) return 0;
    if (!assisted && hintsUsed == 0 && accuracy >= 0.8) return 3;
    if (hintsUsed <= 1) return 2;
    return 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'completionId': completionId,
      'profileId': profileId,
      'gameId': gameId,
      'challengeId': challengeId,
      'contentVersion': contentVersion,
      'seed': seed,
      'skillTags': skillTags.join(','),
      'difficultyTier': difficultyTier,
      'completed': completed ? 1 : 0,
      'activeDurationMs': activeDurationMs,
      'independentCorrectActions': independentCorrectActions,
      'assessedActions': assessedActions,
      'hintsUsed': hintsUsed,
      'assisted': assisted ? 1 : 0,
      'creativeSavedPath': creativeSavedPath,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      completionId: map['completionId'] as String,
      profileId: map['profileId'] as String,
      gameId: map['gameId'] as String,
      challengeId: map['challengeId'] as String,
      contentVersion: map['contentVersion'] as String? ?? '1.0.0',
      seed: map['seed'] as int? ?? 0,
      skillTags: (map['skillTags'] as String? ?? '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      difficultyTier: map['difficultyTier'] as int? ?? 1,
      completed: (map['completed'] as int? ?? 0) == 1,
      activeDurationMs: map['activeDurationMs'] as int? ?? 0,
      independentCorrectActions:
          map['independentCorrectActions'] as int? ?? 0,
      assessedActions: map['assessedActions'] as int? ?? 0,
      hintsUsed: map['hintsUsed'] as int? ?? 0,
      assisted: (map['assisted'] as int? ?? 0) == 1,
      creativeSavedPath: map['creativeSavedPath'] as String?,
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
