import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class DinoBone {
  final String id;
  final String nameEn;
  final String nameHi;
  final int gridRow;
  final int gridCol;
  bool isExcavated;

  DinoBone({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.gridRow,
    required this.gridCol,
    this.isExcavated = false,
  });
}

class DigCell {
  final int row;
  final int col;
  bool isDug;
  bool hasBone;
  String? boneId;

  DigCell({
    required this.row,
    required this.col,
    this.isDug = false,
    this.hasBone = false,
    this.boneId,
  });
}

class G088Controller extends GameController {
  static const int gridSize = 5;
  List<List<DigCell>> grid = [];
  List<DinoBone> bones = [];
  int bonesFound = 0;
  int totalBones = 6;
  int digCount = 0;
  String dinoNameEn = 'T-Rex';
  String dinoNameHi = 'टी-रेक्स';

  G088Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  @override
  Future<void> initialize() async {
    // Initialize grid
    grid = List.generate(gridSize, (r) =>
        List.generate(gridSize, (c) => DigCell(row: r, col: c)));

    // Place bones randomly
    final rng = Random(seed);
    final allPositions = <List<int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        allPositions.add([r, c]);
      }
    }
    allPositions.shuffle(rng);

    final boneNames = [
      ['Skull', 'खोपड़ी', '💀'],
      ['Rib', 'पसली', '🦴'],
      ['Leg', 'पैर', '🦵'],
      ['Tail', 'पूंछ', '🦎'],
      ['Spine', 'रीढ़', '🔗'],
      ['Claw', 'पंजा', '🦶'],
    ];

    for (int i = 0; i < totalBones; i++) {
      final pos = allPositions[i];
      final bone = DinoBone(
        id: 'bone_$i',
        nameEn: boneNames[i][0],
        nameHi: boneNames[i][1],
        gridRow: pos[0],
        gridCol: pos[1],
      );
      bones.add(bone);
      grid[pos[0]][pos[1]].hasBone = true;
      grid[pos[0]][pos[1]].boneId = bone.id;
    }

    await super.initialize();
  }

  void digCell(int row, int col) {
    if (state != GameLifecycleState.playing) return;
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) return;

    final cell = grid[row][col];
    if (cell.isDug) return;

    cell.isDug = true;
    digCount++;
    assessedActions++;

    if (cell.hasBone) {
      final bone = bones.firstWhere((b) => b.id == cell.boneId);
      bone.isExcavated = true;
      bonesFound++;
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);
      AudioService().playCue(SoundCue.cheer);

      if (bonesFound >= totalBones) {
        completeGame();
        return;
      }
    } else {
      playTapSound();
    }
    notifyListeners();
  }

  int getProximityHint(int row, int col) {
    // Returns count of adjacent bones (like minesweeper)
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr, nc = col + dc;
        if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
          if (grid[nr][nc].hasBone) count++;
        }
      }
    }
    return count;
  }

  @override
  void applyHint() {
    // Reveal the nearest un-excavated bone
    final unexcavated = bones.where((b) => !b.isExcavated).toList();
    if (unexcavated.isNotEmpty) {
      final bone = unexcavated.first;
      hintHighlightId = '${bone.gridRow}_${bone.gridCol}';
      notifyListeners();
    }
  }

  @override
  String serializeGameState() {
    final dugCells = <String>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isDug) dugCells.add('${r}_$c');
      }
    }
    return jsonEncode({'dugCells': dugCells, 'bonesFound': bonesFound});
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final dugList = (data['dugCells'] as List?)?.cast<String>() ?? [];
      for (final cellId in dugList) {
        final parts = cellId.split('_');
        if (parts.length == 2) {
          final r = int.parse(parts[0]), c = int.parse(parts[1]);
          if (r < gridSize && c < gridSize) {
            grid[r][c].isDug = true;
            if (grid[r][c].hasBone) {
              bones.firstWhere((b) => b.id == grid[r][c].boneId).isExcavated = true;
            }
          }
        }
      }
      bonesFound = (data['bonesFound'] as int?) ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
