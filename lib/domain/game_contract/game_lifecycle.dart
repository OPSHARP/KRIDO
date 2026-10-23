enum GameLifecycleState {
  loading,
  introduction,
  demonstration,
  playing,
  feedback,
  paused,
  completed,
  results,
  error;

  bool get isInteractive =>
      this == GameLifecycleState.playing || this == GameLifecycleState.feedback;

  bool get canPause =>
      this == GameLifecycleState.introduction ||
      this == GameLifecycleState.demonstration ||
      this == GameLifecycleState.playing ||
      this == GameLifecycleState.feedback;
}
