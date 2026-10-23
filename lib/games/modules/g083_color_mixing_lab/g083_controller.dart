import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class ColorMix {
  final String id;
  final String nameEn;
  final String nameHi;
  final int colorHex;
  final List<String> ingredients; // IDs of primary colors needed
  bool isMixed;

  ColorMix({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.colorHex,
    required this.ingredients,
    this.isMixed = false,
  });
}

class PrimaryColor {
  final String id;
  final String nameEn;
  final String nameHi;
  final int colorHex;
  final String emoji;

  const PrimaryColor({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.colorHex,
    required this.emoji,
  });
}

class G083Controller extends GameController {
  List<PrimaryColor> primaryColors = [];
  List<ColorMix> targetMixes = [];
  int currentMixIndex = 0;
  List<String> selectedPrimaries = [];
  bool showResult = false;
  int resultColorHex = 0;
  bool lastMixCorrect = false;

  G083Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  ColorMix get currentTarget => targetMixes[currentMixIndex];

  @override
  Future<void> initialize() async {
    primaryColors = const [
      PrimaryColor(id: 'red', nameEn: 'Red', nameHi: 'लाल', colorHex: 0xFFE53935, emoji: '🔴'),
      PrimaryColor(id: 'blue', nameEn: 'Blue', nameHi: 'नीला', colorHex: 0xFF1E88E5, emoji: '🔵'),
      PrimaryColor(id: 'yellow', nameEn: 'Yellow', nameHi: 'पीला', colorHex: 0xFFFDD835, emoji: '🟡'),
      PrimaryColor(id: 'white', nameEn: 'White', nameHi: 'सफेद', colorHex: 0xFFFFFFFF, emoji: '⚪'),
    ];

    targetMixes = [
      ColorMix(id: 'orange', nameEn: 'Orange', nameHi: 'नारंगी', colorHex: 0xFFFF9800, ingredients: ['red', 'yellow']),
      ColorMix(id: 'green', nameEn: 'Green', nameHi: 'हरा', colorHex: 0xFF4CAF50, ingredients: ['blue', 'yellow']),
      ColorMix(id: 'purple', nameEn: 'Purple', nameHi: 'बैंगनी', colorHex: 0xFF9C27B0, ingredients: ['red', 'blue']),
      ColorMix(id: 'pink', nameEn: 'Pink', nameHi: 'गुलाबी', colorHex: 0xFFE91E63, ingredients: ['red', 'white']),
      ColorMix(id: 'lightblue', nameEn: 'Light Blue', nameHi: 'हल्का नीला', colorHex: 0xFF81D4FA, ingredients: ['blue', 'white']),
    ];

    targetMixes.shuffle(Random(seed));
    await super.initialize();
  }

  void togglePrimary(String colorId) {
    if (state != GameLifecycleState.playing || showResult) return;
    if (selectedPrimaries.contains(colorId)) {
      selectedPrimaries.remove(colorId);
    } else {
      if (selectedPrimaries.length < 2) {
        selectedPrimaries.add(colorId);
      }
    }
    playTapSound();
    notifyListeners();
  }

  void mixColors() {
    if (state != GameLifecycleState.playing || selectedPrimaries.length != 2) return;

    assessedActions++;
    showResult = true;

    final target = currentTarget;
    final sortedSelected = List<String>.from(selectedPrimaries)..sort();
    final sortedIngredients = List<String>.from(target.ingredients)..sort();

    if (sortedSelected.join(',') == sortedIngredients.join(',')) {
      lastMixCorrect = true;
      resultColorHex = target.colorHex;
      target.isMixed = true;
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);
      AudioService().playCue(SoundCue.cheer);
    } else {
      lastMixCorrect = false;
      resultColorHex = _computeMixedColor(selectedPrimaries);
      AudioService().playCue(SoundCue.wrong);
    }
    notifyListeners();
  }

  void nextRound() {
    showResult = false;
    selectedPrimaries.clear();

    if (lastMixCorrect) {
      if (targetMixes.every((m) => m.isMixed)) {
        completeGame();
        return;
      }
      currentMixIndex = targetMixes.indexWhere((m) => !m.isMixed);
    }
    notifyListeners();
  }

  int _computeMixedColor(List<String> ids) {
    final map = {for (var c in primaryColors) c.id: c.colorHex};
    if (ids.length == 2) {
      final c1 = map[ids[0]] ?? 0xFF888888;
      final c2 = map[ids[1]] ?? 0xFF888888;
      final r = (((c1 >> 16) & 0xFF) + ((c2 >> 16) & 0xFF)) ~/ 2;
      final g = (((c1 >> 8) & 0xFF) + ((c2 >> 8) & 0xFF)) ~/ 2;
      final b = ((c1 & 0xFF) + (c2 & 0xFF)) ~/ 2;
      return 0xFF000000 | (r << 16) | (g << 8) | b;
    }
    return 0xFF888888;
  }

  @override
  void applyHint() {
    final target = currentTarget;
    if (selectedPrimaries.isEmpty) {
      hintHighlightId = target.ingredients.first;
    } else if (selectedPrimaries.length == 1) {
      hintHighlightId = target.ingredients.firstWhere(
        (i) => !selectedPrimaries.contains(i),
        orElse: () => target.ingredients.last,
      );
    }
    notifyListeners();
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'mixedIds': targetMixes.where((m) => m.isMixed).map((m) => m.id).toList(),
      'currentMixIndex': currentMixIndex,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['mixedIds'] as List?)?.cast<String>() ?? [];
      for (final m in targetMixes) {
        if (list.contains(m.id)) m.isMixed = true;
      }
      currentMixIndex = (data['currentMixIndex'] as int?) ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
