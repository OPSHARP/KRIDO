import 'dart:async';
import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class RhymeItem {
  final String id;
  final String wordEn;
  final String wordHi;
  final String emoji;
  final bool isRhyme;

  const RhymeItem({
    required this.id,
    required this.wordEn,
    required this.wordHi,
    required this.emoji,
    required this.isRhyme,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'wordEn': wordEn,
        'wordHi': wordHi,
        'emoji': emoji,
        'isRhyme': isRhyme,
      };

  factory RhymeItem.fromMap(Map<String, dynamic> map) => RhymeItem(
        id: map['id'] as String,
        wordEn: map['wordEn'] as String,
        wordHi: map['wordHi'] as String,
        emoji: map['emoji'] as String,
        isRhyme: map['isRhyme'] as bool? ?? false,
      );
}

class RhymeTargetSet {
  final String id;
  final String targetWord;
  final String targetWordHi;
  final String targetEmoji;
  final String rhymeFamily; // e.g. '-AT', '-OG', '-AR'
  final List<RhymeItem> rhymePool;
  final List<RhymeItem> distractorPool;

  const RhymeTargetSet({
    required this.id,
    required this.targetWord,
    required this.targetWordHi,
    required this.targetEmoji,
    required this.rhymeFamily,
    required this.rhymePool,
    required this.distractorPool,
  });
}

class G078Controller extends GameController {
  static const List<RhymeTargetSet> bank = [
    RhymeTargetSet(
      id: 'cat',
      targetWord: 'CAT',
      targetWordHi: 'कैट (बिल्ली)',
      targetEmoji: '🐱',
      rhymeFamily: '-AT',
      rhymePool: [
        RhymeItem(id: 'hat', wordEn: 'HAT', wordHi: 'टोपी', emoji: '🎩', isRhyme: true),
        RhymeItem(id: 'bat', wordEn: 'BAT', wordHi: 'बल्ला', emoji: '🦇', isRhyme: true),
        RhymeItem(id: 'mat', wordEn: 'MAT', wordHi: 'चटाई', emoji: '🧘', isRhyme: true),
      ],
      distractorPool: [
        RhymeItem(id: 'dog', wordEn: 'DOG', wordHi: 'कुत्ता', emoji: '🐶', isRhyme: false),
        RhymeItem(id: 'cup', wordEn: 'CUP', wordHi: 'कप', emoji: '🥤', isRhyme: false),
        RhymeItem(id: 'sun', wordEn: 'SUN', wordHi: 'सूरज', emoji: '☀️', isRhyme: false),
      ],
    ),
    RhymeTargetSet(
      id: 'frog',
      targetWord: 'FROG',
      targetWordHi: 'फ्रॉग (मेंढक)',
      targetEmoji: '🐸',
      rhymeFamily: '-OG',
      rhymePool: [
        RhymeItem(id: 'log', wordEn: 'LOG', wordHi: 'लकड़ी', emoji: '🪵', isRhyme: true),
        RhymeItem(id: 'dog_r', wordEn: 'DOG', wordHi: 'कुत्ता', emoji: '🐶', isRhyme: true),
      ],
      distractorPool: [
        RhymeItem(id: 'fish', wordEn: 'FISH', wordHi: 'मछली', emoji: '🐟', isRhyme: false),
        RhymeItem(id: 'bird', wordEn: 'BIRD', wordHi: 'चिड़िया', emoji: '🐦', isRhyme: false),
        RhymeItem(id: 'car', wordEn: 'CAR', wordHi: 'गाड़ी', emoji: '🚗', isRhyme: false),
      ],
    ),
    RhymeTargetSet(
      id: 'star',
      targetWord: 'STAR',
      targetWordHi: 'स्टार (तारा)',
      targetEmoji: '⭐',
      rhymeFamily: '-AR',
      rhymePool: [
        RhymeItem(id: 'car_r', wordEn: 'CAR', wordHi: 'गाड़ी', emoji: '🚗', isRhyme: true),
        RhymeItem(id: 'jar', wordEn: 'JAR', wordHi: 'जार', emoji: '🫙', isRhyme: true),
      ],
      distractorPool: [
        RhymeItem(id: 'moon', wordEn: 'MOON', wordHi: 'चाँद', emoji: '🌙', isRhyme: false),
        RhymeItem(id: 'ball', wordEn: 'BALL', wordHi: 'गेंद', emoji: '⚽', isRhyme: false),
        RhymeItem(id: 'tree', wordEn: 'TREE', wordHi: 'पेड़', emoji: '🌳', isRhyme: false),
      ],
    ),
    RhymeTargetSet(
      id: 'bee',
      targetWord: 'BEE',
      targetWordHi: 'बी (मधुमक्खी)',
      targetEmoji: '🐝',
      rhymeFamily: '-EE',
      rhymePool: [
        RhymeItem(id: 'tree_r', wordEn: 'TREE', wordHi: 'पेड़', emoji: '🌳', isRhyme: true),
        RhymeItem(id: 'sea', wordEn: 'SEA', wordHi: 'समुद्र', emoji: '🌊', isRhyme: true),
      ],
      distractorPool: [
        RhymeItem(id: 'ant', wordEn: 'ANT', wordHi: 'चींटी', emoji: '🐜', isRhyme: false),
        RhymeItem(id: 'flower', wordEn: 'ROSE', wordHi: 'गुलाब', emoji: '🌹', isRhyme: false),
        RhymeItem(id: 'bear', wordEn: 'BEAR', wordHi: 'भालू', emoji: '🐻', isRhyme: false),
      ],
    ),
    RhymeTargetSet(
      id: 'fox',
      targetWord: 'FOX',
      targetWordHi: 'फॉक्स (लोमड़ी)',
      targetEmoji: '🦊',
      rhymeFamily: '-OX',
      rhymePool: [
        RhymeItem(id: 'box', wordEn: 'BOX', wordHi: 'डिब्बा', emoji: '📦', isRhyme: true),
        RhymeItem(id: 'socks', wordEn: 'SOCKS', wordHi: 'मोज़े', emoji: '🧦', isRhyme: true),
      ],
      distractorPool: [
        RhymeItem(id: 'lion', wordEn: 'LION', wordHi: 'शेर', emoji: '🦁', isRhyme: false),
        RhymeItem(id: 'duck', wordEn: 'DUCK', wordHi: 'बत्तख', emoji: '🦆', isRhyme: false),
        RhymeItem(id: 'apple', wordEn: 'APPLE', wordHi: 'सेब', emoji: '🍎', isRhyme: false),
      ],
    ),
    RhymeTargetSet(
      id: 'king',
      targetWord: 'KING',
      targetWordHi: 'किंग (राजा)',
      targetEmoji: '👑',
      rhymeFamily: '-ING',
      rhymePool: [
        RhymeItem(id: 'ring', wordEn: 'RING', wordHi: 'अंगूठी', emoji: '💍', isRhyme: true),
        RhymeItem(id: 'wing', wordEn: 'WING', wordHi: 'पंख', emoji: '🪽', isRhyme: true),
      ],
      distractorPool: [
        RhymeItem(id: 'crown', wordEn: 'CROWN', wordHi: 'मुकुट', emoji: '👑', isRhyme: false),
        RhymeItem(id: 'book', wordEn: 'BOOK', wordHi: 'किताब', emoji: '📖', isRhyme: false),
        RhymeItem(id: 'shoe', wordEn: 'SHOE', wordHi: 'जूता', emoji: '👟', isRhyme: false),
      ],
    ),
  ];

  int currentRound = 0;
  final int totalRounds;

  late RhymeTargetSet currentSet;
  List<RhymeItem> options = [];

  String? selectedOptionId;
  String? wrongOptionId;
  bool isRoundCorrect = false;

  G078Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  })  : totalRounds = (challenge.taskData['totalRounds'] as int?) ?? 5,
        super(challenge: challenge, profile: profile, seed: seed);

  @override
  Future<void> initialize() async {
    _setupRound();
    await super.initialize();
  }

  void _setupRound() {
    isRoundCorrect = false;
    selectedOptionId = null;
    wrongOptionId = null;
    clearHint();

    final rng = SeededRng(seed + (currentRound * 37));
    final setIndex = (seed + currentRound) % bank.length;
    currentSet = bank[setIndex];

    // Pick 1 correct rhyme and 3 distractors for a 4-choice mini game
    final correctPick = rng.pickUnique(currentSet.rhymePool, 1).first;
    final distractorPicks = rng.pickUnique(currentSet.distractorPool, 3);

    final List<RhymeItem> roundOptions = [correctPick, ...distractorPicks];
    options = rng.shuffle(roundOptions);
  }

  @override
  void applyHint() {
    if (isRoundCorrect) return;
    final correct = options.firstWhere((o) => o.isRhyme);
    hintHighlightId = correct.id;
    AudioService().playCue(SoundCue.hint);
    notifyListeners();
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state != GameLifecycleState.playing) return;
    if (isRoundCorrect) return;
    if (wrongOptionId != null) return;

    if (action.type == GameActionType.tap) {
      final optId = action.targetId;
      if (optId == null) return;
      playTapSound();

      final option = options.firstWhere((o) => o.id == optId, orElse: () => options.first);

      if (option.isRhyme) {
        // Correct Rhyme match!
        isRoundCorrect = true;
        selectedOptionId = optId;
        wrongOptionId = null;
        recordCorrectAction(wasAssisted: hintHighlightId == optId);
        clearHint();
        AudioService().playCue(SoundCue.correct);
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 1400));

        if (currentRound + 1 >= totalRounds) {
          completeGame();
        } else {
          currentRound++;
          _setupRound();
          notifyListeners();
        }
      } else {
        // Friendly incorrect wobble feedback
        wrongOptionId = optId;
        selectedOptionId = null;
        recordIncorrectAction();
        AudioService().playCue(SoundCue.wrong);
        notifyListeners();

        // Clear shake after 600ms
        await Future.delayed(const Duration(milliseconds: 600));
        if (wrongOptionId == optId) {
          wrongOptionId = null;
          notifyListeners();
        }
      }
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'currentRound': currentRound,
      'targetId': currentSet.id,
      'isRoundCorrect': isRoundCorrect,
      'options': options.map((o) => o.toMap()).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      currentRound = map['currentRound'] as int? ?? 0;
      isRoundCorrect = map['isRoundCorrect'] as bool? ?? false;
      final tId = map['targetId'] as String?;
      if (tId != null) {
        currentSet = bank.firstWhere((b) => b.id == tId, orElse: () => bank.first);
      }
      if (map['options'] != null) {
        options = (map['options'] as List)
            .map((e) => RhymeItem.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _setupRound();
    }
  }

  void reset() {
    currentRound = 0;
    _setupRound();
    start();
  }
}
