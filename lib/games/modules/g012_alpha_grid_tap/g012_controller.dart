import 'dart:async';
import 'dart:convert';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

/// A single cell in the 5×6 alphabet grid
class AlphaGridCell {
  final int gridIndex; // 0..29
  final String label;  // 'A'..'Z' or '⭐' for filler
  final bool isFiller;

  AlphaGridCell({
    required this.gridIndex,
    required this.label,
    this.isFiller = false,
  });

  Map<String, dynamic> toMap() => {
    'gridIndex': gridIndex,
    'label': label,
    'isFiller': isFiller,
  };

  factory AlphaGridCell.fromMap(Map<String, dynamic> map) => AlphaGridCell(
    gridIndex: map['gridIndex'] as int,
    label: map['label'] as String,
    isFiller: map['isFiller'] as bool? ?? false,
  );
}

/// Controller for G012: Alpha Grid Tap
/// Kids tap shuffled letters A→Z in alphabetical order on a 5×6 grid.
class G012Controller extends GameController {
  static const List<String> alphabet = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  static const List<String> fillerEmojis = ['⭐','🌟','✨','💫'];

  List<AlphaGridCell> cells = [];
  int currentTargetIndex = 0; // index into alphabet (0='A', 25='Z')
  final Set<int> completedIndices = {}; // grid indices that are done

  // Stopwatch timer
  int elapsedSeconds = 0;
  Timer? _stopwatchTimer;

  // Shake feedback
  int? lastWrongGridIndex;

  int levelIndex = 0;

  G012Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  }) : super(challenge: challenge, profile: profile, seed: seed);

  String get currentTargetLetter => alphabet[currentTargetIndex];

  bool get isGridComplete => currentTargetIndex >= alphabet.length;

  /// Formatted timer "MM:SS"
  String get timerString {
    final m = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Star rating based on completion time
  int get starRating {
    if (elapsedSeconds < 45) return 3;
    if (elapsedSeconds < 90) return 2;
    return 1;
  }

  @override
  Future<void> initialize() async {
    _generateGrid();
    _startTimer();
    await super.initialize();
  }

  void _generateGrid() {
    cells.clear();
    completedIndices.clear();
    currentTargetIndex = 0;
    lastWrongGridIndex = null;
    elapsedSeconds = 0;

    final rng = SeededRng(seed + (levelIndex * 41));

    // 26 letters + 4 fillers = 30 cells for 5×6 grid
    final List<String> labels = List<String>.from(alphabet);
    for (int i = 0; i < 4; i++) {
      labels.add(fillerEmojis[i % fillerEmojis.length]);
    }

    final shuffled = rng.shuffle(labels);
    for (int i = 0; i < shuffled.length; i++) {
      final label = shuffled[i];
      cells.add(AlphaGridCell(
        gridIndex: i,
        label: label,
        isFiller: !alphabet.contains(label),
      ));
    }
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

  /// Restart with a new shuffle
  void restartGame() {
    levelIndex++;
    _generateGrid();
    _startTimer();
    resetToPlaying();
  }

  @override
  void applyHint() {
    hintHighlightId = currentTargetLetter;
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;

    if (action.type == GameActionType.tap || action.type == GameActionType.select) {
      playTapSound();
      String? tappedLabel;
      int? tappedGridIndex;
      if (action.payload is Map) {
        final map = action.payload as Map;
        tappedLabel = map['label'] as String?;
        tappedGridIndex = map['gridIndex'] as int?;
      } else {
        tappedLabel = (action.payload ?? action.targetId) as String?;
      }
      if (tappedLabel == null) return;

      if (tappedLabel == currentTargetLetter) {
        // Correct!
        if (tappedGridIndex != null) {
          completedIndices.add(tappedGridIndex);
        }
        recordCorrectAction(wasAssisted: hintHighlightId == currentTargetLetter);
        clearHint();
        lastWrongGridIndex = null;
        currentTargetIndex++;
        notifyListeners();

        if (isGridComplete) {
          _stopwatchTimer?.cancel();
          await Future.delayed(const Duration(milliseconds: 400));
          completeGame();
        }
      } else {
        // Wrong
        lastWrongGridIndex = tappedGridIndex;
        recordIncorrectAction();
        notifyListeners();
      }
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'levelIndex': levelIndex,
      'currentTargetIndex': currentTargetIndex,
      'completedIndices': completedIndices.toList(),
      'elapsedSeconds': elapsedSeconds,
      'cells': cells.map((c) => c.toMap()).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      levelIndex = map['levelIndex'] as int? ?? 0;
      currentTargetIndex = map['currentTargetIndex'] as int? ?? 0;
      elapsedSeconds = map['elapsedSeconds'] as int? ?? 0;
      if (map['completedIndices'] != null) {
        completedIndices.clear();
        for (final idx in map['completedIndices'] as List) {
          completedIndices.add(idx as int);
        }
      }
      if (map['cells'] != null) {
        cells = (map['cells'] as List)
            .map((c) => AlphaGridCell.fromMap(c as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _generateGrid();
    }
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    super.dispose();
  }
}
