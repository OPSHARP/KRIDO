import 'dart:async';
import 'dart:convert';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

/// A word with its emoji illustration
class KidWord {
  final String word;
  final String emoji;

  const KidWord(this.word, this.emoji);
}

/// Single cell in the word builder grid
class WordGridCell {
  final int row;
  final int col;
  final String letter;

  WordGridCell({required this.row, required this.col, required this.letter});

  Map<String, dynamic> toMap() => {'row': row, 'col': col, 'letter': letter};

  factory WordGridCell.fromMap(Map<String, dynamic> map) => WordGridCell(
    row: map['row'] as int,
    col: map['col'] as int,
    letter: map['letter'] as String,
  );
}

/// A target word placement on the grid
class WordPlacement {
  final KidWord word;
  final List<int> cellIndices; // indices into grid cells for each letter
  bool isFound;

  WordPlacement({required this.word, required this.cellIndices, this.isFound = false});
}

/// Controller for G072: Word Builder Grid
/// Kids drag/tap adjacent letters to form simple words (CAT, DOG, BAT, etc.)
class G072Controller extends GameController {
  static const int gridRows = 5;
  static const int gridCols = 5;
  static const int wordsPerRound = 3;

  static const List<KidWord> wordBank = [
    KidWord('CAT', '🐱'), KidWord('DOG', '🐶'), KidWord('BAT', '🦇'),
    KidWord('COW', '🐮'), KidWord('HEN', '🐔'), KidWord('PIG', '🐷'),
    KidWord('BUS', '🚌'), KidWord('CUP', '☕'), KidWord('HAT', '🎩'),
    KidWord('RAT', '🐀'), KidWord('SUN', '☀️'), KidWord('MOP', '🧹'),
    KidWord('JAM', '🍓'), KidWord('FAN', '🌀'), KidWord('PEN', '🖊️'),
    KidWord('BED', '🛏️'), KidWord('MUG', '☕'), KidWord('RUG', '🟤'),
    KidWord('RED', '🔴'), KidWord('BIG', '🔵'), KidWord('HOP', '🐰'),
    KidWord('RUN', '🏃'), KidWord('SIT', '🪑'), KidWord('CUT', '✂️'),
    KidWord('MAP', '🗺️'), KidWord('NET', '🥅'), KidWord('BOX', '📦'),
    KidWord('FOX', '🦊'), KidWord('MIX', '🥄'), KidWord('ZIP', '🤐'),
    KidWord('MILK', '🥛'), KidWord('FISH', '🐟'), KidWord('BIRD', '🐦'),
    KidWord('FROG', '🐸'), KidWord('DUCK', '🦆'), KidWord('BEAR', '🐻'),
  ];

  List<WordGridCell> cells = [];
  List<WordPlacement> targetWords = [];
  List<int> currentDragPath = []; // cell indices being dragged
  String currentDragWord = '';

  int roundIndex = 0;
  int totalRounds = 3;

  int elapsedSeconds = 0;
  Timer? _stopwatchTimer;

  G072Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  }) : super(challenge: challenge, profile: profile, seed: seed);

  bool get allWordsFound => targetWords.isNotEmpty && targetWords.every((w) => w.isFound);
  int get foundCount => targetWords.where((w) => w.isFound).length;

  String get timerString {
    final m = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get starRating {
    if (elapsedSeconds < 60) return 3;
    if (elapsedSeconds < 120) return 2;
    return 1;
  }

  @override
  Future<void> initialize() async {
    _generateRound();
    _startTimer();
    await super.initialize();
  }

  void _generateRound() {
    cells.clear();
    targetWords.clear();
    currentDragPath.clear();
    currentDragWord = '';

    final rng = SeededRng(seed + (roundIndex * 53));

    // Pick random words for this round
    final available = List<KidWord>.from(wordBank);
    final selected = rng.pickUnique(available, wordsPerRound);

    // Create an empty grid
    final List<String?> grid = List.filled(gridRows * gridCols, null);

    // Place each word into the grid
    for (final kidWord in selected) {
      final placement = _placeWord(grid, kidWord, rng);
      if (placement != null) {
        targetWords.add(placement);
      }
    }

    // If any selected word couldn't be placed, try alternative words
    if (targetWords.length < wordsPerRound) {
      final remaining = wordBank.where((w) => !targetWords.any((tw) => tw.word.word == w.word)).toList();
      for (final altWord in rng.shuffle(remaining)) {
        if (targetWords.length >= wordsPerRound) break;
        final placement = _placeWord(grid, altWord, rng);
        if (placement != null) {
          targetWords.add(placement);
        }
      }
    }

    // Safety fallback: ensure at least one word is placed
    if (targetWords.isEmpty) {
      const fallback = KidWord('CAT', '🐱');
      for (int i = 0; i < 3; i++) {
        grid[i] = fallback.word[i];
      }
      targetWords.add(WordPlacement(word: fallback, cellIndices: [0, 1, 2]));
    }

    // Fill remaining cells with random letters
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int i = 0; i < grid.length; i++) {
      grid[i] ??= letters[rng.nextInt(0, 25)];
    }

    // Build cell objects
    for (int i = 0; i < grid.length; i++) {
      final row = i ~/ gridCols;
      final col = i % gridCols;
      cells.add(WordGridCell(row: row, col: col, letter: grid[i]!));
    }
  }

  /// Try to place a word on the grid (horizontal, vertical, or diagonal)
  WordPlacement? _placeWord(List<String?> grid, KidWord kidWord, SeededRng rng) {
    final word = kidWord.word;
    final directions = rng.shuffle([
      [0, 1],  // horizontal right
      [1, 0],  // vertical down
      [1, 1],  // diagonal down-right
      [0, -1], // horizontal left
      [-1, 0], // vertical up
      [-1, -1], // diagonal up-left
      [1, -1],  // diagonal down-left
      [-1, 1],  // diagonal up-right
    ]);

    // Try each direction with random starting positions
    for (final dir in directions) {
      final starts = <List<int>>[];
      for (int r = 0; r < gridRows; r++) {
        for (int c = 0; c < gridCols; c++) {
          starts.add([r, c]);
        }
      }
      final shuffledStarts = rng.shuffle(starts);

      for (final start in shuffledStarts) {
        if (_canPlace(grid, word, start[0], start[1], dir[0], dir[1])) {
          final indices = <int>[];
          for (int i = 0; i < word.length; i++) {
            final r = start[0] + i * dir[0];
            final c = start[1] + i * dir[1];
            final idx = r * gridCols + c;
            grid[idx] = word[i];
            indices.add(idx);
          }
          return WordPlacement(word: kidWord, cellIndices: indices);
        }
      }
    }
    return null;
  }

  bool _canPlace(List<String?> grid, String word, int startR, int startC, int dr, int dc) {
    for (int i = 0; i < word.length; i++) {
      final r = startR + i * dr;
      final c = startC + i * dc;
      if (r < 0 || r >= gridRows || c < 0 || c >= gridCols) return false;
      final idx = r * gridCols + c;
      final existing = grid[idx];
      if (existing != null && existing != word[i]) return false;
    }
    return true;
  }

  void _startTimer() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == GameLifecycleState.playing) {
        elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  /// Called when drag starts on a cell
  void startDrag(int cellIndex) {
    if (state != GameLifecycleState.playing) return;
    playTapSound();
    currentDragPath = [cellIndex];
    currentDragWord = cells[cellIndex].letter;
    notifyListeners();
  }

  /// Called when drag moves over a new cell
  void continueDrag(int cellIndex) {
    if (state != GameLifecycleState.playing) return;
    if (currentDragPath.isEmpty) return;
    if (currentDragPath.contains(cellIndex)) return;

    // Check adjacency with last cell
    final lastIdx = currentDragPath.last;
    if (!_isAdjacent(lastIdx, cellIndex)) return;

    // Limit path length to longest word (4 letters max for now)
    if (currentDragPath.length >= 5) return;

    playTapSound();
    currentDragPath.add(cellIndex);
    currentDragWord += cells[cellIndex].letter;
    notifyListeners();
  }

  /// Called when drag ends
  void endDrag() {
    if (state != GameLifecycleState.playing) return;
    _checkWord();
    currentDragPath.clear();
    currentDragWord = '';
    notifyListeners();
  }

  bool _isAdjacent(int idx1, int idx2) {
    final r1 = idx1 ~/ gridCols, c1 = idx1 % gridCols;
    final r2 = idx2 ~/ gridCols, c2 = idx2 % gridCols;
    return (r1 - r2).abs() <= 1 && (c1 - c2).abs() <= 1 && idx1 != idx2;
  }

  void _checkWord() {
    if (currentDragWord.isEmpty) return;

    for (final placement in targetWords) {
      if (placement.isFound) continue;

      // Check forward and backward match
      final forward = currentDragWord == placement.word.word;
      final backward = currentDragWord == placement.word.word.split('').reversed.join();

      if (forward || backward) {
        placement.isFound = true;
        recordCorrectAction();
        notifyListeners();

        if (allWordsFound) {
          _onRoundComplete();
        }
        return;
      }
    }

    // No match
    recordIncorrectAction();
  }

  void _onRoundComplete() {
    if (roundIndex < totalRounds - 1) {
      // Next round after a delay
      Future.delayed(const Duration(milliseconds: 800), () {
        roundIndex++;
        _generateRound();
        notifyListeners();
      });
    } else {
      // All rounds done
      _stopwatchTimer?.cancel();
      Future.delayed(const Duration(milliseconds: 500), () {
        completeGame();
      });
    }
  }

  @override
  void applyHint() {
    // Highlight first unfound word's first letter
    for (final placement in targetWords) {
      if (!placement.isFound && placement.cellIndices.isNotEmpty) {
        hintHighlightId = placement.cellIndices.first.toString();
        return;
      }
    }
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    // Drag actions are handled via startDrag/continueDrag/endDrag
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'roundIndex': roundIndex,
      'elapsedSeconds': elapsedSeconds,
      'cells': cells.map((c) => c.toMap()).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      roundIndex = map['roundIndex'] as int? ?? 0;
      elapsedSeconds = map['elapsedSeconds'] as int? ?? 0;
      if (map['cells'] != null) {
        cells = (map['cells'] as List)
            .map((c) => WordGridCell.fromMap(c as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _generateRound();
    }
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    super.dispose();
  }
}
