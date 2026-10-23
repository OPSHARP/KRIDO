import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class ToothZone {
  final String id;
  final String nameEn;
  final String nameHi;
  bool isBrushed;

  ToothZone({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    this.isBrushed = false,
  });
}

class G084Controller extends GameController {
  List<ToothZone> zones = [];
  int brushStrokes = 0;
  int requiredStrokesPerZone = 3;
  Map<String, int> strokesPerZone = {};
  String? activeZoneId;
  int sparkleCount = 0;
  double timerSeconds = 120.0;

  G084Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  int get totalBrushed => zones.where((z) => z.isBrushed).length;

  @override
  Future<void> initialize() async {
    zones = [
      ToothZone(id: 'top_left', nameEn: 'Top Left', nameHi: 'ऊपर बाएं'),
      ToothZone(id: 'top_front', nameEn: 'Top Front', nameHi: 'ऊपर सामने'),
      ToothZone(id: 'top_right', nameEn: 'Top Right', nameHi: 'ऊपर दाएं'),
      ToothZone(id: 'bottom_left', nameEn: 'Bottom Left', nameHi: 'नीचे बाएं'),
      ToothZone(id: 'bottom_front', nameEn: 'Bottom Front', nameHi: 'नीचे सामने'),
      ToothZone(id: 'bottom_right', nameEn: 'Bottom Right', nameHi: 'नीचे दाएं'),
    ];

    for (var z in zones) {
      strokesPerZone[z.id] = 0;
    }

    // Randomize brushing order
    zones.shuffle(Random(seed));
    activeZoneId = zones.first.id;

    await super.initialize();
  }

  void brushZone(String zoneId) {
    if (state != GameLifecycleState.playing) return;
    if (zones.firstWhere((z) => z.id == zoneId).isBrushed) return;

    strokesPerZone[zoneId] = (strokesPerZone[zoneId] ?? 0) + 1;
    brushStrokes++;

    if (strokesPerZone[zoneId]! >= requiredStrokesPerZone) {
      zones.firstWhere((z) => z.id == zoneId).isBrushed = true;
      sparkleCount++;
      independentCorrectActions++;
      assessedActions++;
      AudioService().playCue(SoundCue.match);

      // Move to next unbrushed zone
      final nextUnbrushed = zones.where((z) => !z.isBrushed).toList();
      if (nextUnbrushed.isEmpty) {
        completeGame();
        return;
      }
      activeZoneId = nextUnbrushed.first.id;
    } else {
      playTapSound();
    }
    notifyListeners();
  }

  double getZoneProgress(String zoneId) {
    return (strokesPerZone[zoneId] ?? 0) / requiredStrokesPerZone;
  }

  @override
  void applyHint() {
    final unbrushed = zones.where((z) => !z.isBrushed).toList();
    if (unbrushed.isNotEmpty) {
      hintHighlightId = unbrushed.first.id;
      activeZoneId = unbrushed.first.id;
      notifyListeners();
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'brushedIds': zones.where((z) => z.isBrushed).map((z) => z.id).toList(),
      'strokesPerZone': strokesPerZone,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['brushedIds'] as List?)?.cast<String>() ?? [];
      for (final z in zones) {
        if (list.contains(z.id)) z.isBrushed = true;
      }
      final strokes = (data['strokesPerZone'] as Map?)?.cast<String, dynamic>() ?? {};
      for (final entry in strokes.entries) {
        strokesPerZone[entry.key] = (entry.value as num).toInt();
      }
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
