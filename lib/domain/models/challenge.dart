class Challenge {
  final String id;
  final String gameId;
  final int tier;
  final String promptEn;
  final String promptHi;
  final String? voicePromptKey;
  final Map<String, dynamic> taskData;
  final List<dynamic> validAnswers;
  final List<String> helpStepsEn;
  final List<String> helpStepsHi;
  final int? seed;

  const Challenge({
    required this.id,
    required this.gameId,
    required this.tier,
    required this.promptEn,
    required this.promptHi,
    this.voicePromptKey,
    required this.taskData,
    required this.validAnswers,
    this.helpStepsEn = const [],
    this.helpStepsHi = const [],
    this.seed,
  });

  String localizedPrompt(String locale) => locale == 'hi' ? promptHi : promptEn;

  List<String> localizedHelp(String locale) =>
      locale == 'hi' ? helpStepsHi : helpStepsEn;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameId': gameId,
      'tier': tier,
      'promptEn': promptEn,
      'promptHi': promptHi,
      'voicePromptKey': voicePromptKey,
      'taskData': taskData,
      'validAnswers': validAnswers,
      'helpStepsEn': helpStepsEn,
      'helpStepsHi': helpStepsHi,
      'seed': seed,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      gameId: map['gameId'] as String,
      tier: map['tier'] as int? ?? 1,
      promptEn: map['promptEn'] as String? ?? '',
      promptHi: map['promptHi'] as String? ?? '',
      voicePromptKey: map['voicePromptKey'] as String?,
      taskData: Map<String, dynamic>.from(map['taskData'] as Map? ?? {}),
      validAnswers: List<dynamic>.from(map['validAnswers'] as List? ?? []),
      helpStepsEn: List<String>.from(map['helpStepsEn'] as List? ?? []),
      helpStepsHi: List<String>.from(map['helpStepsHi'] as List? ?? []),
      seed: map['seed'] as int?,
    );
  }
}
