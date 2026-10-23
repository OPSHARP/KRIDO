class Sticker {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final String category; // 'animals', 'space', 'nature', 'fantasy', 'sports'

  const Sticker({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.category,
  });

  String localizedName(String locale) => locale == 'hi' ? nameHi : nameEn;
}

class UnlockedSticker {
  final String profileId;
  final String stickerId;
  final String sourceCompletionId;
  final DateTime awardedAt;

  UnlockedSticker({
    required this.profileId,
    required this.stickerId,
    required this.sourceCompletionId,
    DateTime? awardedAt,
  }) : awardedAt = awardedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'stickerId': stickerId,
      'sourceCompletionId': sourceCompletionId,
      'awardedAt': awardedAt.toIso8601String(),
    };
  }

  factory UnlockedSticker.fromMap(Map<String, dynamic> map) {
    return UnlockedSticker(
      profileId: map['profileId'] as String,
      stickerId: map['stickerId'] as String,
      sourceCompletionId: map['sourceCompletionId'] as String,
      awardedAt: DateTime.tryParse(map['awardedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
