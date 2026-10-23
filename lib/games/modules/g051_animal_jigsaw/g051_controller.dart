import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class JigsawPiece {
  final int id;
  final int targetRow;
  final int targetCol;
  final String emoji;
  final String label;
  bool isPlaced;

  JigsawPiece({
    required this.id,
    required this.targetRow,
    required this.targetCol,
    required this.emoji,
    required this.label,
    this.isPlaced = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'targetRow': targetRow,
        'targetCol': targetCol,
        'emoji': emoji,
        'label': label,
        'isPlaced': isPlaced,
      };

  factory JigsawPiece.fromMap(Map<String, dynamic> map) => JigsawPiece(
        id: map['id'] as int,
        targetRow: map['targetRow'] as int,
        targetCol: map['targetCol'] as int,
        emoji: map['emoji'] as String,
        label: map['label'] as String,
        isPlaced: map['isPlaced'] as bool? ?? false,
      );
}

/// Animal puzzle theme configuration with cute quadrant illustrations
class PuzzleAnimalTheme {
  final String title;
  final String animalName;
  final String mainEmoji;
  final List<String> quadrantEmojis;
  final List<String> quadrantLabels;
  final List<Color> quadrantBorderColors;
  final String? imageAsset;

  const PuzzleAnimalTheme({
    required this.title,
    required this.animalName,
    required this.mainEmoji,
    required this.quadrantEmojis,
    required this.quadrantLabels,
    required this.quadrantBorderColors,
    this.imageAsset,
  });
}

class G051Controller extends GameController {
  final int gridDimension; // 2 (4 pieces) or 3 (9 pieces)

  // Endless auto-generating puzzle sequence
  int puzzleIndex = 0;
  bool isPuzzleCompleted = false;
  int puzzlesCompletedCount = 0;

  List<JigsawPiece> pieces = [];
  bool showGhostHint = false;
  JigsawPiece? selectedPieceForTap;

  static const List<PuzzleAnimalTheme> animalThemes = [
    // 1. Playful Puppy (Realistic Animal Puzzle)
    PuzzleAnimalTheme(
      title: 'DOGGY PUZZLE!',
      animalName: 'Playful Puppy',
      mainEmoji: '🐶',
      imageAsset: 'assets/art/doggy_puzzle.jpg',
      quadrantEmojis: ['🐕', '🐶', '🐾', '🦴'],
      quadrantLabels: ['Forehead & Ear', 'Eyes & Muzzle', 'Chest & Left Paw', 'Right Paw & Meadow'],
      quadrantBorderColors: [
        Color(0xFFFFD54F),
        Color(0xFF4DD0E1),
        Color(0xFF81C784),
        Color(0xFFFF8A65),
      ],
    ),
    // 2. Cute Kitten
    PuzzleAnimalTheme(
      title: 'KITTY PUZZLE!',
      animalName: 'Cute Kitten',
      mainEmoji: '🐱',
      imageAsset: 'assets/art/kitty_puzzle.jpg',
      quadrantEmojis: ['😺', '🐱', '🐾', '🧶'],
      quadrantLabels: ['Ears & Crown', 'Green Eyes', 'Paws & Blanket', 'Fluffy Tail & Yarn'],
      quadrantBorderColors: [
        Color(0xFFFF80AB),
        Color(0xFFB388FF),
        Color(0xFF80D8FF),
        Color(0xFFFFD180),
      ],
    ),
    // 3. Royal Leo Lion
    PuzzleAnimalTheme(
      title: 'LION PUZZLE!',
      animalName: 'Leo the Lion',
      mainEmoji: '🦁',
      imageAsset: 'assets/art/lion_puzzle.jpg',
      quadrantEmojis: ['👑', '🦁', '🐾', '🌴'],
      quadrantLabels: ['Ears & Brow', 'Eyes & Nose', 'Chest & Left Paw', 'Right Paw & Rock'],
      quadrantBorderColors: [
        Color(0xFFFFB300),
        Color(0xFFFF7043),
        Color(0xFF81C784),
        Color(0xFF4FC3F7),
      ],
    ),
    // 4. Bouncy Bunny
    PuzzleAnimalTheme(
      title: 'BUNNY PUZZLE!',
      animalName: 'Bouncy Bunny',
      mainEmoji: '🐰',
      imageAsset: 'assets/art/bunny_puzzle.jpg',
      quadrantEmojis: ['🐰', '🥕', '🐾', '🌸'],
      quadrantLabels: ['Lop Ears', 'Eyes & Whiskers', 'Paws & Meadow', 'Wild Carrots'],
      quadrantBorderColors: [
        Color(0xFFFF8A80),
        Color(0xFFFFD54F),
        Color(0xFFBA68C8),
        Color(0xFF80CBC4),
      ],
    ),
    // 5. Bamboo Panda
    PuzzleAnimalTheme(
      title: 'PANDA PUZZLE!',
      animalName: 'Bamboo Panda',
      mainEmoji: '🐼',
      imageAsset: 'assets/art/panda_puzzle.jpg',
      quadrantEmojis: ['🐼', '🎍', '🐾', '🎋'],
      quadrantLabels: ['Ears & Patches', 'Eyes & Bamboo', 'Furry Body', 'Paws & Moss'],
      quadrantBorderColors: [
        Color(0xFF81C784),
        Color(0xFF4DD0E1),
        Color(0xFFAED581),
        Color(0xFFFFB74D),
      ],
    ),
    // 6. Sweet Teddy
    PuzzleAnimalTheme(
      title: 'TEDDY PUZZLE!',
      animalName: 'Sweet Teddy Bear',
      mainEmoji: '🐻',
      quadrantEmojis: ['🐻', '🍯', '🐾', '⭐'],
      quadrantLabels: ['Ears', 'Honey', 'Paws', 'Star'],
      quadrantBorderColors: [
        Color(0xFFFFB74D),
        Color(0xFF8D6E63),
        Color(0xFF4FC3F7),
        Color(0xFFFFD54F),
      ],
    ),
    // 7. Clever Fox
    PuzzleAnimalTheme(
      title: 'FOX PUZZLE!',
      animalName: 'Clever Fox',
      mainEmoji: '🦊',
      quadrantEmojis: ['🦊', '🍂', '🐾', '🌲'],
      quadrantLabels: ['Ears', 'Autumn', 'Paws', 'Forest'],
      quadrantBorderColors: [
        Color(0xFFFF7043),
        Color(0xFFFFCA28),
        Color(0xFF81C784),
        Color(0xFF26C6DA),
      ],
    ),
    // 8. Happy Elephant
    PuzzleAnimalTheme(
      title: 'ELEPHANT PUZZLE!',
      animalName: 'Jumbo Elephant',
      mainEmoji: '🐘',
      quadrantEmojis: ['🐘', '💧', '🐾', '🥜'],
      quadrantLabels: ['Trunk', 'Water', 'Feet', 'Peanut'],
      quadrantBorderColors: [
        Color(0xFF42A5F5),
        Color(0xFF26A69A),
        Color(0xFFAB47BC),
        Color(0xFFFFCA28),
      ],
    ),
    // 9. Cheeky Monkey
    PuzzleAnimalTheme(
      title: 'MONKEY PUZZLE!',
      animalName: 'Playful Monkey',
      mainEmoji: '🐵',
      quadrantEmojis: ['🐵', '🍌', '🐾', '🌴'],
      quadrantLabels: ['Face', 'Banana', 'Paws', 'Tree'],
      quadrantBorderColors: [
        Color(0xFFFFCA28),
        Color(0xFFFF8A65),
        Color(0xFF66BB6A),
        Color(0xFF29B6F6),
      ],
    ),
    // 10. Striped Tiger
    PuzzleAnimalTheme(
      title: 'TIGER PUZZLE!',
      animalName: 'Striped Tiger',
      mainEmoji: '🐯',
      quadrantEmojis: ['🐯', '🔥', '🐾', '🌿'],
      quadrantLabels: ['Stripes', 'Courage', 'Paws', 'Grass'],
      quadrantBorderColors: [
        Color(0xFFFF6D00),
        Color(0xFFFFD600),
        Color(0xFF00E676),
        Color(0xFF00B0FF),
      ],
    ),
  ];

  PuzzleAnimalTheme get currentTheme =>
      animalThemes[puzzleIndex % animalThemes.length];

  String get animalName => currentTheme.animalName;
  String get animalEmoji => currentTheme.mainEmoji;

  G051Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  })  : gridDimension = challenge.tier == 1 ? 2 : 3,
        super(
          challenge: challenge,
          profile: profile,
          seed: seed,
        );

  @override
  Future<void> initialize() async {
    _generatePieces();
    await super.initialize();
  }

  void _generatePieces() {
    pieces.clear();
    isPuzzleCompleted = false;
    showGhostHint = false;
    selectedPieceForTap = null;

    final theme = currentTheme;
    final labels = gridDimension == 2
        ? theme.quadrantLabels
        : [
            'Top Left', 'Top Center', 'Top Right',
            'Mid Left', 'Center Mane', 'Mid Right',
            'Bottom Left', 'Paws', 'Tail'
          ];

    int idCounter = 0;
    for (int r = 0; r < gridDimension; r++) {
      for (int c = 0; c < gridDimension; c++) {
        pieces.add(
          JigsawPiece(
            id: idCounter,
            targetRow: r,
            targetCol: c,
            emoji: theme.mainEmoji,
            label: labels[idCounter % labels.length],
            isPlaced: false,
          ),
        );
        idCounter++;
      }
    }

    // Shuffle deterministically based on seed + puzzleIndex
    final rng = SeededRng(seed + puzzleIndex * 31);
    pieces = rng.shuffle(pieces);
  }

  /// Automatically generates the next fresh animal puzzle for the kid!
  void generateNextPuzzle() {
    puzzleIndex++;
    puzzlesCompletedCount++;
    _generatePieces();
    notifyListeners();
  }

  /// Resets current puzzle to try again
  void resetCurrentPuzzle() {
    _generatePieces();
    notifyListeners();
  }

  @override
  void applyHint() {
    showGhostHint = true;
    final unplaced = pieces.where((p) => !p.isPlaced).toList();
    if (unplaced.isNotEmpty) {
      hintHighlightId = unplaced.first.id.toString();
    }
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;

    if (action.type == GameActionType.dragDrop) {
      // payload is pieceId (int), targetId is 'slot_{row}_{col}'
      final pieceId = action.payload as int?;
      final slotStr = action.targetId ?? '';

      if (pieceId == null || !slotStr.startsWith('slot_')) return;

      final parts = slotStr.replaceFirst('slot_', '').split('_');
      if (parts.length != 2) return;
      final targetRow = int.tryParse(parts[0]);
      final targetCol = int.tryParse(parts[1]);

      final piece = pieces.firstWhere((p) => p.id == pieceId);
      if (piece.isPlaced) return;

      if (piece.targetRow == targetRow && piece.targetCol == targetCol) {
        piece.isPlaced = true;
        recordCorrectAction(
            wasAssisted: hintHighlightId == piece.id.toString());
        clearHint();

        if (pieces.every((p) => p.isPlaced)) {
          isPuzzleCompleted = true;
          puzzlesCompletedCount++;
        }
        notifyListeners();
      } else {
        // Return piece to tray safely per PRD AC04
        recordIncorrectAction();
        notifyListeners();
      }
    } else if (action.type == GameActionType.tap ||
        action.type == GameActionType.select) {
      playTapSound();
      // Tap-place equivalent: tap piece then tap target slot
      final target = action.targetId ?? '';
      if (target.startsWith('piece_')) {
        final id = int.tryParse(target.replaceFirst('piece_', ''));
        if (id != null) {
          selectedPieceForTap = pieces.firstWhere((p) => p.id == id);
          notifyListeners();
        }
      } else if (target.startsWith('slot_')) {
        final parts = target.replaceFirst('slot_', '').split('_');
        if (parts.length == 2) {
          final row = int.tryParse(parts[0]);
          final col = int.tryParse(parts[1]);

          final unplaced = pieces.where((p) => !p.isPlaced).toList();
          final pieceToPlace = selectedPieceForTap ??
              (unplaced.isNotEmpty ? unplaced.first : null);

          if (pieceToPlace != null && row != null && col != null) {
            if (pieceToPlace.targetRow == row && pieceToPlace.targetCol == col) {
              pieceToPlace.isPlaced = true;
              recordCorrectAction(
                  wasAssisted: hintHighlightId == pieceToPlace.id.toString());
              clearHint();
              selectedPieceForTap = null;

              if (pieces.every((p) => p.isPlaced)) {
                isPuzzleCompleted = true;
                puzzlesCompletedCount++;
              }
              notifyListeners();
            } else {
              recordIncorrectAction();
              selectedPieceForTap = null;
              notifyListeners();
            }
          }
        }
      }
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'gridDimension': gridDimension,
      'puzzleIndex': puzzleIndex,
      'puzzlesCompletedCount': puzzlesCompletedCount,
      'animalName': animalName,
      'pieces': pieces.map((p) => p.toMap()).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      if (map['puzzleIndex'] != null) {
        puzzleIndex = map['puzzleIndex'] as int;
      }
      if (map['puzzlesCompletedCount'] != null) {
        puzzlesCompletedCount = map['puzzlesCompletedCount'] as int;
      }
      if (map['pieces'] != null) {
        pieces = (map['pieces'] as List)
            .map((p) => JigsawPiece.fromMap(p as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _generatePieces();
    }
  }
}
