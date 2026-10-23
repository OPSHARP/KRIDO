import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/audio/audio_service.dart';
import '../models/challenge.dart';
import '../models/checkpoint.dart';
import '../models/game_result.dart';
import '../models/profile.dart';
import 'game_action.dart';
import 'game_lifecycle.dart';

abstract class GameController extends ChangeNotifier {
  final Challenge challenge;
  final Profile profile;
  final int seed;

  GameLifecycleState _state = GameLifecycleState.loading;
  GameLifecycleState get state => _state;

  GameLifecycleState _stateBeforePause = GameLifecycleState.playing;

  // Active monotonic timer tracking
  final Stopwatch _activeStopwatch = Stopwatch();
  int _accumulatedElapsedMs = 0;

  int get activeElapsedMs =>
      _accumulatedElapsedMs + _activeStopwatch.elapsedMilliseconds;

  int independentCorrectActions = 0;
  int assessedActions = 0;
  int hintsUsed = 0;
  bool isAssisted = false;
  String? hintHighlightId;

  GameController({
    required this.challenge,
    required this.profile,
    required this.seed,
  });

  @mustCallSuper
  Future<void> initialize() async {
    _state = GameLifecycleState.introduction;
    notifyListeners();
  }

  @mustCallSuper
  void start() {
    _state = GameLifecycleState.playing;
    _activeStopwatch.start();
    AudioService().startBackgroundMusic();
    notifyListeners();
  }

  @mustCallSuper
  void pause() {
    if (_state.canPause) {
      _stateBeforePause = _state;
      _state = GameLifecycleState.paused;
      _activeStopwatch.stop();
      notifyListeners();
    }
  }

  @mustCallSuper
  void resume() {
    if (_state == GameLifecycleState.paused) {
      _state = _stateBeforePause;
      _activeStopwatch.start();
      notifyListeners();
    }
  }

  @mustCallSuper
  void requestHint() {
    hintsUsed++;
    isAssisted = true;
    AudioService().playCue(SoundCue.hint);
    applyHint();
    notifyListeners();
  }

  /// Subclasses provide specific hint logic (e.g., highlight next target, eliminate 1 distractor).
  void applyHint();

  void clearHint() {
    hintHighlightId = null;
    notifyListeners();
  }

  /// Subclasses handle concrete game actions.
  Future<void> handleAction(GameAction action);

  /// Called when a correct answer is executed.
  @protected
  void recordCorrectAction({bool wasAssisted = false}) {
    assessedActions++;
    if (!wasAssisted && !isAssisted) {
      independentCorrectActions++;
    }
    AudioService().playCue(SoundCue.correct);
  }

  /// Called when an incorrect answer is executed.
  @protected
  void recordIncorrectAction() {
    assessedActions++;
    AudioService().playCue(SoundCue.wrong);
  }

  @protected
  void completeGame() {
    _activeStopwatch.stop();
    _state = GameLifecycleState.completed;
    AudioService().playCue(SoundCue.complete);
    notifyListeners();
  }

  /// Utility to play instant tactile tap sound
  void playTapSound() {
    AudioService().playCue(SoundCue.press);
  }

  @protected
  void resetToPlaying() {
    _state = GameLifecycleState.playing;
    _activeStopwatch.start();
    notifyListeners();
  }

  GameResult computeResult() {
    return GameResult(
      completionId: const Uuid().v4(),
      profileId: profile.id,
      gameId: challenge.gameId,
      challengeId: challenge.id,
      seed: seed,
      difficultyTier: challenge.tier,
      completed: _state == GameLifecycleState.completed,
      activeDurationMs: activeElapsedMs,
      independentCorrectActions: independentCorrectActions,
      assessedActions: assessedActions,
      hintsUsed: hintsUsed,
      assisted: isAssisted,
    );
  }

  Checkpoint serializeCheckpoint() {
    return Checkpoint(
      profileId: profile.id,
      gameId: challenge.gameId,
      challengeId: challenge.id,
      seed: seed,
      serializedGameState: serializeGameState(),
      activeElapsedMs: activeElapsedMs,
    );
  }

  void restoreCheckpoint(Checkpoint checkpoint) {
    _accumulatedElapsedMs = checkpoint.activeElapsedMs;
    deserializeGameState(checkpoint.serializedGameState);
    notifyListeners();
  }

  String serializeGameState();
  void deserializeGameState(String rawJson);

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  @mustCallSuper
  void dispose() {
    _isDisposed = true;
    _activeStopwatch.stop();
    super.dispose();
  }
}
