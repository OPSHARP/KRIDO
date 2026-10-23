import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';
import 'mosaic_generator.dart';

/// Controller for the 1-1000 Number Focus Mosaic Quiz (50 Numbers per Stage)
class G001Controller extends GameController {
  static const int totalStages = 28; // 1-10 (10 stages of 10) + 11-28 (18 stages of 50)
  static const String _storageKeyPrefix = 'g001_saved_stage_';
  static const String _highestKeyPrefix = 'g001_highest_stage_';
  static const String _fallbackStorageKey = 'g001_saved_stage';

  final int? overrideMaxNumber;

  int currentStage = 1;
  late int rangeStart;
  late int rangeEnd;

  List<MosaicCell> cells = [];
  int currentTarget = 1;
  final Set<int> completedNumbers = {};
  int? hintedNumber;

  // Real-time stopwatch timer (matching "00:03" in photo)
  int elapsedSeconds = 0;
  Timer? _stopwatchTimer;

  // Shake / error feedback
  int? lastTappedWrongNumber;

  /// Calculate the range for a given stage
  /// Stages 1-10: Groups of 10 (1-10, 11-20, ..., 91-100)
  /// Stages 11-28: Groups of 50 (101-150, 151-200, ..., 951-1000)
  static (int, int) getStageRange(int stage) {
    final s = stage.clamp(1, totalStages);
    if (s <= 10) {
      final start = (s - 1) * 10 + 1;
      return (start, s * 10);
    } else {
      final start = 101 + (s - 11) * 50;
      final end = (start + 49).clamp(101, 1000);
      return (start, end);
    }
  }

  G001Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
    int initialStage = 1,
    this.overrideMaxNumber,
  })  : currentStage = initialStage.clamp(1, totalStages),
        super(
          challenge: challenge,
          profile: profile,
          seed: seed,
        ) {
    _updateRange();
  }

  void _updateRange() {
    final (start, end) = getStageRange(currentStage);
    rangeStart = start;
    if (overrideMaxNumber != null && currentStage == 1) {
      rangeEnd = overrideMaxNumber!;
    } else if (challenge.taskData['maxNumber'] != null && currentStage == 1) {
      rangeEnd = (challenge.taskData['maxNumber'] as num).toInt();
    } else {
      rangeEnd = end;
    }
    currentTarget = rangeStart;
  }

  @override
  Future<void> initialize() async {
    await _loadSavedStage();
    _loadStage();
    _startTimer();
    await super.initialize();
  }

  Future<void> _loadSavedStage() async {
    // If challenge explicitly specifies a stage, prioritize that
    final challengeStage = challenge.taskData['stage'] as int?;
    if (challengeStage != null && challengeStage >= 1 && challengeStage <= totalStages) {
      currentStage = challengeStage;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt('$_storageKeyPrefix${profile.id}') ??
                    prefs.getInt(_fallbackStorageKey);
      if (saved != null && saved >= 1 && saved <= totalStages) {
        currentStage = saved;
      }
    } catch (_) {}
  }

  Future<void> _saveStage(int stage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_storageKeyPrefix${profile.id}', stage);
      await prefs.setInt(_fallbackStorageKey, stage);
      final highestKey = '$_highestKeyPrefix${profile.id}';
      final highest = prefs.getInt(highestKey) ?? 1;
      if (stage > highest) {
        await prefs.setInt(highestKey, stage);
      }
    } catch (_) {}
  }

  void _loadStage() {
    _updateRange();
    completedNumbers.clear();
    hintedNumber = null;
    lastTappedWrongNumber = null;
    elapsedSeconds = 0;

    // Generate circular Voronoi mosaic cells for current stage & seed
    final stageSeed = seed + currentStage * 997;
    final count = rangeEnd - rangeStart + 1;
    cells = MosaicGenerator.generateCells(
      seed: stageSeed,
      rangeStart: rangeStart,
      count: count,
    );
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

  /// Formatted timer string "MM:SS" (e.g. "00:03" like reference photo)
  String get timerString {
    final m = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Calculate stars based on speed:
  /// < 90 seconds -> 3 Stars ⭐⭐⭐
  /// < 180 seconds -> 2 Stars ⭐⭐
  /// Finished -> 1 Star ⭐
  int get starsEarned {
    if (elapsedSeconds <= 90) return 3;
    if (elapsedSeconds <= 180) return 2;
    return 1;
  }

  double get progressFraction {
    final total = (rangeEnd - rangeStart + 1).clamp(1, 1000);
    return completedNumbers.length / total;
  }

  /// Handle tap on a cell
  void onCellTapped(MosaicCell cell) {
    playTapSound();
    tapNumber(cell.number);
  }

  /// Tap a specific number in sequence
  void tapNumber(int number) {
    if (state == GameLifecycleState.completed) return;

    if (number == currentTarget) {
      // Correct sequential hit!
      completedNumbers.add(number);
      hintedNumber = null;
      lastTappedWrongNumber = null;
      recordCorrectAction(wasAssisted: isAssisted);

      if (currentTarget >= rangeEnd) {
        // Stage completed!
        _stopwatchTimer?.cancel();
        final next = (currentStage < totalStages) ? currentStage + 1 : 1;
        _saveStage(next);
        completeGame();
      } else {
        currentTarget++;
        notifyListeners();
      }
    } else {
      // Wrong number tapped in sequence
      lastTappedWrongNumber = number;
      recordIncorrectAction();
      notifyListeners();

      // Clear wrong highlight after 600ms
      Future.delayed(const Duration(milliseconds: 600), () {
        if (lastTappedWrongNumber == number) {
          lastTappedWrongNumber = null;
          notifyListeners();
        }
      });
    }
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (action.type == GameActionType.tap && action.targetId != null) {
      final numStr = action.targetId!.replaceAll('mosaic_cell_', '');
      final parsed = int.tryParse(numStr);
      if (parsed != null) {
        tapNumber(parsed);
      }
    }
  }

  /// Subclasses provide specific hint logic
  @override
  void applyHint() {
    useHint();
  }

  /// Provide a hint: pulses the currentTarget cell with golden aura
  void useHint() {
    hintedNumber = currentTarget;
    notifyListeners();

    Future.delayed(const Duration(seconds: 4), () {
      if (hintedNumber == currentTarget) {
        hintedNumber = null;
        notifyListeners();
      }
    });
  }

  /// Jump to any stage from 1 to 20
  Future<void> selectStage(int stage) async {
    if (stage < 1 || stage > totalStages) return;
    currentStage = stage;
    resetToPlaying();
    _loadStage();
    _startTimer();
    await _saveStage(stage);
    notifyListeners();
  }

  /// Go back to the previous 50-number stage
  Future<void> prevStage() async {
    if (currentStage > 1) {
      await selectStage(currentStage - 1);
    } else {
      await selectStage(totalStages); // Cycle to stage 20
    }
  }

  /// Advance to the next 50-number stage
  Future<void> nextStage() async {
    if (currentStage < totalStages) {
      await selectStage(currentStage + 1);
    } else {
      await selectStage(1); // Cycle back to 1
    }
  }

  /// Restart current stage
  Future<void> restartStage() async {
    await selectStage(currentStage);
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'stage': currentStage,
      'target': currentTarget,
      'completed': completedNumbers.toList(),
      'elapsed': elapsedSeconds,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      currentStage = data['stage'] as int? ?? 1;
      _updateRange();
      currentTarget = data['target'] as int? ?? rangeStart;
      elapsedSeconds = data['elapsed'] as int? ?? 0;
      final completed = (data['completed'] as List?)?.cast<int>() ?? [];
      completedNumbers
        ..clear()
        ..addAll(completed);
    } catch (_) {}
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    super.dispose();
  }
}
