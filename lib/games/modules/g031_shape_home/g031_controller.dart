import 'dart:convert';
import '../../../core/audio/audio_service.dart';
import '../../../core/rng/seeded_rng.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

enum ShapeType {
  circle('Circle', 'वृत्त', '⚪', 0xFFFF4081), // Candy Pink
  square('Square', 'वर्ग', '⬛', 0xFF2196F3), // Electric Blue
  triangle('Triangle', 'त्रिकोण', '🔺', 0xFFFFC107), // Sunny Yellow
  star('Star', 'तारा', '⭐', 0xFFFF9800), // Golden Orange
  heart('Heart', 'हृदय', '❤️', 0xFFE53935), // Ruby Red
  diamond('Diamond', 'हीरा', '🔷', 0xFF9C27B0), // Royal Purple
  crescent('Moon', 'चांद', '🌙', 0xFF5C6BC0), // Moon Indigo
  cloud('Cloud', 'बादल', '☁️', 0xFF00BCD4), // Sky Cyan
  oval('Oval', 'अंडाकार', '🥚', 0xFF7CB342); // Lime Green

  final String nameEn;
  final String nameHi;
  final String icon;
  final int defaultColor;
  const ShapeType(this.nameEn, this.nameHi, this.icon, this.defaultColor);
}

class ShapeItem {
  final String id;
  final ShapeType shapeType;
  final int colorValue;
  bool isPlaced;

  ShapeItem({
    required this.id,
    required this.shapeType,
    required this.colorValue,
    this.isPlaced = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'shapeType': shapeType.name,
        'colorValue': colorValue,
        'isPlaced': isPlaced,
      };

  factory ShapeItem.fromMap(Map<String, dynamic> map) => ShapeItem(
        id: map['id'] as String,
        shapeType: ShapeType.values.firstWhere(
          (s) => s.name == map['shapeType'],
          orElse: () => ShapeType.circle,
        ),
        colorValue: map['colorValue'] as int,
        isPlaced: map['isPlaced'] as bool? ?? false,
      );
}

class G031Controller extends GameController {
  int levelIndex = 0;
  List<ShapeItem> shapes = [];
  List<ShapeType> silhouettes = [];
  ShapeItem? selectedShapeForTap;
  String? justMatchedShapeId;

  G031Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  }) : super(
          challenge: challenge,
          profile: profile,
          seed: seed,
        );

  @override
  Future<void> initialize() async {
    _generateShapes();
    await super.initialize();
  }

  void _generateShapes() {
    final rng = SeededRng(seed + (levelIndex * 41));
    final count = challenge.tier == 1 ? 3 : (challenge.tier == 2 ? 4 : 5);

    final chosenTypes = rng.pickUnique(ShapeType.values, count);

    shapes.clear();
    for (int i = 0; i < count; i++) {
      shapes.add(
        ShapeItem(
          id: 'shape_${chosenTypes[i].name}',
          shapeType: chosenTypes[i],
          colorValue: chosenTypes[i].defaultColor,
        ),
      );
    }

    // Silhouettes are shuffled to test matching independent of display order
    silhouettes = rng.shuffle(chosenTypes);
  }

  /// Endless Auto-Generation: Generates the next level with fresh shapes and colors!
  void generateNextLevel() {
    levelIndex++;
    selectedShapeForTap = null;
    justMatchedShapeId = null;
    clearHint();
    _generateShapes();
    resetToPlaying();
  }

  @override
  void applyHint() {
    final unplaced = shapes.where((s) => !s.isPlaced).toList();
    if (unplaced.isNotEmpty) {
      hintHighlightId = unplaced.first.id;
      AudioService().playCue(SoundCue.hint);
    }
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state == GameLifecycleState.introduction) {
      start();
    }
    if (state != GameLifecycleState.playing) return;

    if (action.type == GameActionType.dragDrop) {
      final droppedShapeId = action.payload as String?;
      final targetSilhouetteName = action.targetId;

      if (droppedShapeId == null || targetSilhouetteName == null) return;

      final shape = shapes.firstWhere(
        (s) => s.id == droppedShapeId,
        orElse: () => ShapeItem(id: '', shapeType: ShapeType.circle, colorValue: 0),
      );

      if (shape.id.isEmpty || shape.isPlaced) return;

      if (shape.shapeType.name == targetSilhouetteName) {
        shape.isPlaced = true;
        justMatchedShapeId = shape.id;
        AudioService().playCue(SoundCue.match);
        recordCorrectAction(wasAssisted: hintHighlightId == shape.id);
        clearHint();
        notifyListeners();

        if (shapes.every((s) => s.isPlaced)) {
          AudioService().playCue(SoundCue.complete);
          completeGame();
        }
      } else {
        AudioService().playCue(SoundCue.wrong);
        recordIncorrectAction();
        notifyListeners();
      }
    } else if (action.type == GameActionType.tap || action.type == GameActionType.select) {
      final target = action.targetId ?? '';
      if (target.startsWith('shape_')) {
        selectedShapeForTap = shapes.firstWhere((s) => s.id == target);
        AudioService().playCue(SoundCue.press);
        notifyListeners();
      } else if (target.startsWith('slot_') && selectedShapeForTap != null) {
        final slotTypeName = target.replaceFirst('slot_', '');
        if (selectedShapeForTap!.shapeType.name == slotTypeName) {
          selectedShapeForTap!.isPlaced = true;
          justMatchedShapeId = selectedShapeForTap!.id;
          AudioService().playCue(SoundCue.match);
          recordCorrectAction(wasAssisted: hintHighlightId == selectedShapeForTap!.id);
          clearHint();
          selectedShapeForTap = null;
          notifyListeners();

          if (shapes.every((s) => s.isPlaced)) {
            AudioService().playCue(SoundCue.complete);
            completeGame();
          }
        } else {
          AudioService().playCue(SoundCue.wrong);
          recordIncorrectAction();
          selectedShapeForTap = null;
          notifyListeners();
        }
      }
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'levelIndex': levelIndex,
      'shapes': shapes.map((s) => s.toMap()).toList(),
      'silhouettes': silhouettes.map((s) => s.name).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      levelIndex = map['levelIndex'] as int? ?? 0;
      if (map['shapes'] != null) {
        shapes = (map['shapes'] as List)
            .map((s) => ShapeItem.fromMap(s as Map<String, dynamic>))
            .toList();
      }
      if (map['silhouettes'] != null) {
        silhouettes = (map['silhouettes'] as List)
            .map((name) => ShapeType.values.firstWhere((s) => s.name == name))
            .toList();
      }
    } catch (_) {
      _generateShapes();
    }
  }
}
