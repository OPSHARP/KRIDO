enum GameActionType {
  tap,
  dragStart,
  dragUpdate,
  dragDrop,
  select,
  submit,
  undo,
  reset,
}

class GameAction {
  final GameActionType type;
  final String? targetId;
  final dynamic payload;
  final double? x;
  final double? y;
  final DateTime timestamp;

  GameAction({
    required this.type,
    this.targetId,
    this.payload,
    this.x,
    this.y,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory GameAction.tap(String targetId, [dynamic payload]) => GameAction(
        type: GameActionType.tap,
        targetId: targetId,
        payload: payload,
      );

  factory GameAction.select(dynamic payload) => GameAction(
        type: GameActionType.select,
        payload: payload,
      );

  factory GameAction.dragDrop({
    required String targetId,
    required dynamic payload,
    double? x,
    double? y,
  }) =>
      GameAction(
        type: GameActionType.dragDrop,
        targetId: targetId,
        payload: payload,
        x: x,
        y: y,
      );
}
