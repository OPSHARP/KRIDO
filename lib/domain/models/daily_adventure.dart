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
