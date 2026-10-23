import 'dart:convert';
import 'dart:math';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class SortingItem {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final String targetBinId;
  bool isSorted;

  SortingItem({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.targetBinId,
    this.isSorted = false,
  });
}

class SortingBin {
  final String id;
  final String nameEn;
  final String nameHi;
  final String emoji;
  final int colorHex;

  const SortingBin({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.colorHex,
  });
}

class G081Controller extends GameController {
  List<SortingBin> bins = [];
  List<SortingItem> items = [];
  SortingItem? activeSelectedItem;

  G081Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  @override
  Future<void> initialize() async {
    bins = [
      const SortingBin(id: 'red', nameEn: 'Red Bin', nameHi: 'लाल डिब्बा', emoji: '🔴', colorHex: 0xFFEF5350),
      const SortingBin(id: 'blue', nameEn: 'Blue Bin', nameHi: 'नीला डिब्बा', emoji: '🔵', colorHex: 0xFF42A5F5),
      const SortingBin(id: 'yellow', nameEn: 'Yellow Bin', nameHi: 'पीला डिब्बा', emoji: '🟡', colorHex: 0xFFFFCA28),
    ];

    items = [
      SortingItem(id: 'item_1', nameEn: 'Red Apple', nameHi: 'लाल सेब', emoji: '🍎', targetBinId: 'red'),
      SortingItem(id: 'item_2', nameEn: 'Blueberry', nameHi: 'नीली बेरी', emoji: '🫐', targetBinId: 'blue'),
      SortingItem(id: 'item_3', nameEn: 'Yellow Banana', nameHi: 'पीला केला', emoji: '🍌', targetBinId: 'yellow'),
      SortingItem(id: 'item_4', nameEn: 'Red Strawberry', nameHi: 'लाल स्ट्रॉबेरी', emoji: '🍓', targetBinId: 'red'),
      SortingItem(id: 'item_5', nameEn: 'Blue Gem', nameHi: 'नीला रत्न', emoji: '💎', targetBinId: 'blue'),
      SortingItem(id: 'item_6', nameEn: 'Yellow Star', nameHi: 'पीला तारा', emoji: '⭐', targetBinId: 'yellow'),
    ];

    items.shuffle(Random(seed));
    await super.initialize();
  }

  void selectItem(SortingItem item) {
    if (state != GameLifecycleState.playing || item.isSorted) return;
    activeSelectedItem = item;
    playTapSound();
    notifyListeners();
  }

  bool sortItemIntoBin(SortingItem item, SortingBin bin) {
    if (state != GameLifecycleState.playing) return false;

    assessedActions++;
    if (item.targetBinId == bin.id) {
      item.isSorted = true;
      activeSelectedItem = null;
      independentCorrectActions++;
      AudioService().playCue(SoundCue.match);
      AudioService().playCue(SoundCue.snap);

      if (items.every((i) => i.isSorted)) {
        completeGame();
      } else {
        notifyListeners();
      }
      return true;
    } else {
      AudioService().playCue(SoundCue.wrong);
      notifyListeners();
      return false;
    }
  }

  @override
  void applyHint() {
    final unsorted = items.where((i) => !i.isSorted).toList();
    if (unsorted.isNotEmpty) {
      activeSelectedItem = unsorted.first;
      hintHighlightId = unsorted.first.targetBinId;
      notifyListeners();
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'sortedIds': items.where((i) => i.isSorted).map((i) => i.id).toList(),
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final list = (data['sortedIds'] as List?)?.cast<String>() ?? [];
      for (final it in items) {
        if (list.contains(it.id)) it.isSorted = true;
      }
      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> handleAction(GameAction action) async {}
}
