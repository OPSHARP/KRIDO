class Checkpoint {
  final String profileId;
  final String gameId;
  final String challengeId;
  final int seed;
  final String contentVersion;
  final int stateSchemaVersion;
  final String serializedGameState;
  final int activeElapsedMs;
  final DateTime savedAt;

  Checkpoint({
    required this.profileId,
    required this.gameId,
    required this.challengeId,
    required this.seed,
    this.contentVersion = '1.0.0',
    this.stateSchemaVersion = 1,
    required this.serializedGameState,
    required this.activeElapsedMs,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'gameId': gameId,
      'challengeId': challengeId,
      'seed': seed,
      'contentVersion': contentVersion,
      'stateSchemaVersion': stateSchemaVersion,
      'serializedGameState': serializedGameState,
      'activeElapsedMs': activeElapsedMs,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory Checkpoint.fromMap(Map<String, dynamic> map) {
    return Checkpoint(
      profileId: map['profileId'] as String,
      gameId: map['gameId'] as String,
      challengeId: map['challengeId'] as String,
      seed: map['seed'] as int? ?? 0,
      contentVersion: map['contentVersion'] as String? ?? '1.0.0',
      stateSchemaVersion: map['stateSchemaVersion'] as int? ?? 1,
      serializedGameState: map['serializedGameState'] as String? ?? '{}',
      activeElapsedMs: map['activeElapsedMs'] as int? ?? 0,
      savedAt: DateTime.tryParse(map['savedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
