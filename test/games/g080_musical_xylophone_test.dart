import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/domain/game_contract/game_action.dart';
import 'package:kids_king_pro/domain/game_contract/game_lifecycle.dart';
import 'package:kids_king_pro/domain/models/challenge.dart';
import 'package:kids_king_pro/domain/models/profile.dart';
import 'package:kids_king_pro/games/modules/g080_musical_xylophone/g080_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testProfile = Profile(
    id: 'child_tester',
    avatarId: 'avatar_cat',
    nickname: 'Leo',
    uiLocale: 'en',
  );

  const testChallenge = Challenge(
    id: 'G080_T1_C01',
    gameId: 'G080',
    tier: 1,
    promptEn: 'Tap the rainbow bars to play musical melodies!',
    promptHi: 'संगीत की धुन बजाने के लिए इंद्रधनुषी पट्टियों को छुएं!',
    taskData: {'songIndex': 0},
    validAnswers: [],
  );

  group('G080 Musical Rainbow Xylophone Tests', () {
    test('Initializes with Song Play-Along mode and 8 notes', () async {
      final controller = G080Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );

      await controller.initialize();
      controller.start();

      expect(controller.state, GameLifecycleState.playing);
      expect(controller.isFreePlay, false);
      expect(controller.songs.length, 3);
      expect(controller.currentSong.title, 'Twinkle Twinkle Little Star');
      expect(controller.targetNoteIndex, 0);
      expect(controller.songProgress, 0.0);
    });

    test('Tapping target notes advances song progress to completion', () async {
      final controller = G080Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      final songNotes = List<int>.from(controller.currentSong.notes);
      for (int i = 0; i < songNotes.length; i++) {
        expect(controller.targetNoteIndex, songNotes[i]);
        await controller.tapNote(songNotes[i]);
      }

      expect(controller.isSongCompleted, true);
      expect(controller.completedSongsCount, 1);
      expect(controller.notesPlayed, songNotes.length);
    });

    test('Free Play mode allows freely tapping any notes without failure', () async {
      final controller = G080Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      controller.toggleFreePlay();
      expect(controller.isFreePlay, true);

      await controller.tapNote(3);
      await controller.tapNote(7);
      await controller.tapNote(0);

      expect(controller.notesPlayed, 3);
    });

    test('Hint highlights target note index', () async {
      final controller = G080Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      controller.applyHint();
      expect(controller.hintHighlightId, controller.targetNoteIndex.toString());
    });

    test('Serialization and deserialization restores state correctly', () async {
      final controller = G080Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      await controller.tapNote(0);
      await controller.tapNote(0);
      final serialized = controller.serializeGameState();

      final newController = G080Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      newController.deserializeGameState(serialized);

      expect(newController.songStep, 2);
      expect(newController.notesPlayed, 2);
    });

    test('Action dispatching handles tap with noteIndex', () async {
      final controller = G080Controller(
        challenge: testChallenge,
        profile: testProfile,
        seed: 101,
      );
      await controller.initialize();
      controller.start();

      await controller.handleAction(GameAction(
        type: GameActionType.tap,
        payload: {'noteIndex': 0},
      ));

      expect(controller.songStep, 1);
    });
  });
}
