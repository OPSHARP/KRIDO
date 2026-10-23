import 'dart:convert';
import 'dart:math';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class PlacedWord {
  final String word;
  final String emoji;
  final int startRow;
  final int startCol;
  final int endRow;
  final int endCol;
  bool isFound;

  PlacedWord({
    required this.word,
    required this.emoji,
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
    this.isFound = false,
  });

  Map<String, dynamic> toMap() => {
        'word': word,
        'emoji': emoji,
        'startRow': startRow,
        'startCol': startCol,
        'endRow': endRow,
        'endCol': endCol,
        'isFound': isFound,
      };

  factory PlacedWord.fromMap(Map<String, dynamic> map) => PlacedWord(
        word: map['word'] as String,
        emoji: map['emoji'] as String? ?? '⭐',
        startRow: map['startRow'] as int,
        startCol: map['startCol'] as int,
        endRow: map['endRow'] as int,
        endCol: map['endCol'] as int,
        isFound: map['isFound'] as bool? ?? false,
      );
}

class G021Controller extends GameController {
  final int gridSize;
  late List<List<String>> grid;
  List<PlacedWord> words = [];
  Point<int>? selectedStart;
  Point<int>? selectedEnd;

  G021Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  })  : gridSize = challenge.tier == 1 ? 4 : (challenge.tier == 2 ? 5 : 6),
        super(
          challenge: challenge,
          profile: profile,
          seed: seed,
        );

  @override
  Future<void> initialize() async {
    _generateGrid();
    await super.initialize();
  }

  void _generateGrid() {
    final rng = SeededRng(seed);

    final candidateWords = [
      {'word': 'CAT', 'emoji': '🐱'},
      {'word': 'DOG', 'emoji': '🐶'},
      {'word': 'SUN', 'emoji': '☀️'},
      {'word': 'STAR', 'emoji': '⭐'},
      {'word': 'BIRD', 'emoji': '🐦'},
      {'word': 'FISH', 'emoji': '🐟'},
      {'word': 'TREE', 'emoji': '🌳'},
      {'word': 'MOON', 'emoji': '🌙'},
    ];

    // Initialize blank grid
    grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    words.clear();

    final targetWordCount = challenge.tier == 1 ? 2 : (challenge.tier == 2 ? 3 : 4);
    final chosen = rng.pickUnique(candidateWords, targetWordCount);

    for (final item in chosen) {
      final word = item['word']!;
      final emoji = item['emoji']!;
      bool placed = false;

      // Try horizontal placement first
      for (int attempt = 0; attempt < 20 && !placed; attempt++) {
        final isHorizontal = challenge.tier == 1 ? true : rng.nextDouble() > 0.5;
        if (isHorizontal) {
          if (word.length <= gridSize) {
            final row = rng.nextInt(0, gridSize - 1);
            final col = rng.nextInt(0, gridSize - word.length);

            bool fits = true;
            for (int i = 0; i < word.length; i++) {
              if (grid[row][col + i].isNotEmpty && grid[row][col + i] != word[i]) {
                fits = false;
                break;
              }
            }

            if (fits) {
              for (int i = 0; i < word.length; i++) {
                grid[row][col + i] = word[i];
              }
              words.add(PlacedWord(
                word: word,
                emoji: emoji,
                startRow: row,
                startCol: col,
                endRow: row,
                endCol: col + word.length - 1,
              ));
              placed = true;
            }
          }
        } else {
          // Vertical placement
          if (word.length <= gridSize) {
            final row = rng.nextInt(0, gridSize - word.length);
            final col = rng.nextInt(0, gridSize - 1);

            bool fits = true;
            for (int i = 0; i < word.length; i++) {
              if (grid[row + i][col].isNotEmpty && grid[row + i][col] != word[i]) {
                fits = false;
                break;
              }
            }

            if (fits) {
              for (int i = 0; i < word.length; i++) {
                grid[row + i][col] = word[i];
              }
              words.add(PlacedWord(
                word: word,
                emoji: emoji,
                startRow: row,
                startCol: col,
                endRow: row + word.length - 1,
                endCol: col,
              ));
              placed = true;
            }
          }
        }
      }
    }

    // Fill remaining empty cells with random letters
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c] = alphabet[rng.nextInt(0, alphabet.length - 1)];
        }
      }
    }
  }

  @override
  void applyHint() {
    final unfound = words.where((w) => !w.isFound).toList();
    if (unfound.isNotEmpty) {
      hintHighlightId = unfound.first.word;
    }
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state != GameLifecycleState.playing) return;

    if (action.type == GameActionType.tap ||
        action.type == GameActionType.dragStart ||
        action.type == GameActionType.select) {
      playTapSound();
      final payload = action.payload;
      if (payload is Map) {
        final row = payload['row'] as int;
        final col = payload['col'] as int;

        if (selectedStart == null) {
          selectedStart = Point(row, col);
          selectedEnd = null;
        } else {
          selectedEnd = Point(row, col);
          _evaluateSelection();
        }
        notifyListeners();
      }
    }
  }

  void _evaluateSelection() {
    if (selectedStart == null || selectedEnd == null) return;

    final start = selectedStart!;
    final end = selectedEnd!;

    // Check if matching any uncompleted word (forward or reverse)
    PlacedWord? matchedWord;
    for (final pw in words) {
      if (pw.isFound) continue;

      final matchesForward = (pw.startRow == start.x &&
          pw.startCol == start.y &&
          pw.endRow == end.x &&
          pw.endCol == end.y);

      final matchesReverse = (pw.startRow == end.x &&
          pw.startCol == end.y &&
          pw.endRow == start.x &&
          pw.endCol == start.y);

      if (matchesForward || matchesReverse) {
        matchedWord = pw;
        break;
      }
    }

    if (matchedWord != null) {
      matchedWord.isFound = true;
      recordCorrectAction(wasAssisted: hintHighlightId == matchedWord.word);
      clearHint();

      if (words.every((w) => w.isFound)) {
        completeGame();
      }
    } else {
      recordIncorrectAction();
    }

    selectedStart = null;
    selectedEnd = null;
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'gridSize': gridSize,
      'grid': grid,
      'words': words.map((w) => w.toMap()).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      if (map['grid'] != null) {
        grid = (map['grid'] as List)
            .map((row) => List<String>.from(row as List))
            .toList();
      }
      if (map['words'] != null) {
        words = (map['words'] as List)
            .map((w) => PlacedWord.fromMap(w as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _generateGrid();
    }
  }
}
