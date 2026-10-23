import 'dart:convert';
import '../../../core/audio/procedural_sfx_engine.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/game_contract/game_lifecycle.dart';

class XyloSong {
  final String title;
  final String emoji;
  final List<int> notes; // Note indices (0-7)

  const XyloSong({
    required this.title,
    required this.emoji,
    required this.notes,
  });
}

class G080Controller extends GameController {
  G080Controller({
    required super.challenge,
    required super.profile,
    required super.seed,
  });

  static const List<String> noteNames = ['C', 'D', 'E', 'F', 'G', 'A', 'B', 'C5'];
  static const List<String> solfege = ['Do', 'Re', 'Mi', 'Fa', 'Sol', 'La', 'Ti', 'Do'];

  final List<XyloSong> songs = const [
    XyloSong(
      title: 'Twinkle Twinkle Little Star',
      emoji: '⭐',
      notes: [0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0],
    ),
    XyloSong(
      title: 'Mary Had a Little Lamb',
      emoji: '🐑',
      notes: [2, 1, 0, 1, 2, 2, 2, 1, 1, 1, 2, 4, 4],
    ),
    XyloSong(
      title: 'Old MacDonald Had a Farm',
      emoji: '🚜',
      notes: [4, 4, 4, 1, 2, 2, 1, 6, 6, 5, 5, 4],
    ),
  ];

  bool _isFreePlay = false;
  bool get isFreePlay => _isFreePlay;

  int _currentSongIndex = 0;
  int get currentSongIndex => _currentSongIndex;
  XyloSong get currentSong => songs[_currentSongIndex];

  int _songStep = 0;
  int get songStep => _songStep;

  int? _lastTappedNote;
  int? get lastTappedNote => _lastTappedNote;

  int _notesPlayed = 0;
  int get notesPlayed => _notesPlayed;

  int _completedSongsCount = 0;
  int get completedSongsCount => _completedSongsCount;

  bool _isSongCompleted = false;
  bool get isSongCompleted => _isSongCompleted;

  int get targetNoteIndex =>
      _isFreePlay || _songStep >= currentSong.notes.length
          ? -1
          : currentSong.notes[_songStep];

  @override
  Future<void> initialize() async {
    await super.initialize();
    start();
  }

  double get songProgress =>
      currentSong.notes.isEmpty ? 0.0 : (_songStep / currentSong.notes.length).clamp(0.0, 1.0);

  void toggleMode() {
    _isFreePlay = !_isFreePlay;
    _songStep = 0;
    _isSongCompleted = false;
    notifyListeners();
  }

  void toggleFreePlay() => toggleMode();

  void setSong(int index) {
    if (index >= 0 && index < songs.length) {
      _currentSongIndex = index;
      _songStep = 0;
      _isSongCompleted = false;
      _isFreePlay = false;
      notifyListeners();
    }
  }

  Future<void> tapNote(int noteIndex) async {
    _lastTappedNote = noteIndex;
    _notesPlayed++;

    // Play synthesized acoustic musical note
    ProceduralSfxEngine().playXylophoneNote(noteIndex);

    if (!_isFreePlay && !_isSongCompleted) {
      assessedActions++;
      if (noteIndex == targetNoteIndex) {
        independentCorrectActions++;
        _songStep++;
        if (_songStep >= currentSong.notes.length) {
          // Song Completed!
          _isSongCompleted = true;
          _completedSongsCount++;
          ProceduralSfxEngine().playFanfare();
          if (_completedSongsCount >= 1) {
            completeGame();
          }
        }
      }
    }

    notifyListeners();
  }

  void nextSong() {
    _currentSongIndex = (_currentSongIndex + 1) % songs.length;
    _songStep = 0;
    _isSongCompleted = false;
    notifyListeners();
  }

  void restartSong() {
    _songStep = 0;
    _isSongCompleted = false;
    notifyListeners();
  }

  void restart() {
    restartSong();
    resetToPlaying();
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (state != GameLifecycleState.playing) return;
    if (action.type == GameActionType.tap) {
      final note = (action.payload is Map) ? (action.payload['noteIndex'] as int? ?? 0) : 0;
      await tapNote(note);
    }
  }

  @override
  void applyHint() {
    hintHighlightId = targetNoteIndex.toString();
    notifyListeners();
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'isFreePlay': _isFreePlay,
      'currentSongIndex': _currentSongIndex,
      'songStep': _songStep,
      'notesPlayed': _notesPlayed,
      'completedSongsCount': _completedSongsCount,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        _isFreePlay = decoded['isFreePlay'] as bool? ?? false;
        _currentSongIndex = (decoded['currentSongIndex'] as int? ?? 0).clamp(0, songs.length - 1);
        _songStep = decoded['songStep'] as int? ?? 0;
        _notesPlayed = decoded['notesPlayed'] as int? ?? 0;
        _completedSongsCount = decoded['completedSongsCount'] as int? ?? 0;
        notifyListeners();
      }
    } catch (_) {}
  }
}
