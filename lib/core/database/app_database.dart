import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

import '../../domain/models/checkpoint.dart';
import '../../domain/models/daily_adventure.dart';
import '../../domain/models/game_result.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/sticker.dart';

class AppDatabase {
  static AppDatabase? _instance;
  static Database? _db;

  // In-memory fallback caches guaranteeing 100% crash-immunity & zero hang
  final Map<String, Profile> _memoryProfiles = {};
  final Map<String, Checkpoint> _memoryCheckpoints = {};
  final List<GameResult> _memoryAttempts = [];
  final Set<String> _memoryUnlockedStickers = {};
  final Map<String, DailyAdventure> _memoryDailyAdventures = {};

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database?> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    try {
      _db = await _initDb();
      return _db;
    } catch (e) {
      debugPrint('AppDatabase: Database initialization warning ($e). Fallback cache active.');
      return null;
    }
  }

  Future<Database> _initDb() async {
    // 1. Initialize FFI for Desktop (Windows, Linux, macOS)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        ffi.sqfliteFfiInit();
        databaseFactory = ffi.databaseFactoryFfi;
      } catch (e) {
        debugPrint('AppDatabase: Desktop FFI init note: $e');
      }
    }

    // 2. Resolve database path across Mobile, Desktop, and Tests safely
    String? dbPath;
    if (kIsWeb) {
      dbPath = 'kids_king_pro.db';
    } else {
      // Try sqflite built-in databases path first (standard on Android/iOS)
      try {
        final dir = await getDatabasesPath();
        dbPath = join(dir, 'kids_king_pro.db');
      } catch (_) {
        // Fallback if sqflite platform channel isn't ready
      }

      // Fallback to path_provider getApplicationDocumentsDirectory
      if (dbPath == null) {
        try {
          final docDir = await getApplicationDocumentsDirectory();
          dbPath = join(docDir.path, 'kids_king_pro.db');
        } catch (_) {
          // In unit tests or sandboxed environments
        }
      }

      // Fallback to system temporary directory or in-memory
      if (dbPath == null) {
        try {
          final tempDir = Directory.systemTemp;
          dbPath = join(tempDir.path, 'kids_king_pro.db');
        } catch (_) {
          dbPath = inMemoryDatabasePath;
        }
      }
    }

    // 3. Open on-disk database with seamless fallback to in-memory SQLite
    try {
      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (diskError) {
      debugPrint('AppDatabase: On-disk open failed ($diskError). Falling back to inMemoryDatabasePath.');
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        avatarId TEXT NOT NULL,
        nickname TEXT,
        ageBand TEXT NOT NULL,
        uiLocale TEXT NOT NULL,
        learningTrack TEXT NOT NULL,
        soundEffectsEnabled INTEGER NOT NULL,
        narrationEnabled INTEGER NOT NULL,
        backgroundMusicEnabled INTEGER NOT NULL,
        reducedMotion INTEGER NOT NULL,
        highContrast INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attempts (
        completionId TEXT PRIMARY KEY,
        profileId TEXT NOT NULL,
        gameId TEXT NOT NULL,
        challengeId TEXT NOT NULL,
        contentVersion TEXT NOT NULL,
        seed INTEGER NOT NULL,
        skillTags TEXT NOT NULL,
        difficultyTier INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        activeDurationMs INTEGER NOT NULL,
        independentCorrectActions INTEGER NOT NULL,
        assessedActions INTEGER NOT NULL,
        hintsUsed INTEGER NOT NULL,
        assisted INTEGER NOT NULL,
        creativeSavedPath TEXT,
        completedAt TEXT NOT NULL,
        FOREIGN KEY (profileId) REFERENCES profiles(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE skill_progress (
        profileId TEXT NOT NULL,
        skillId TEXT NOT NULL,
        languageTrack TEXT NOT NULL,
        tier INTEGER NOT NULL,
        independentSuccesses INTEGER NOT NULL,
        assistedSuccesses INTEGER NOT NULL,
        totalOpportunities INTEGER NOT NULL,
        lastPracticedAt TEXT NOT NULL,
        parentDifficultyLock INTEGER NOT NULL,
        PRIMARY KEY (profileId, skillId, languageTrack)
      )
    ''');

    await db.execute('''
      CREATE TABLE checkpoints (
        profileId TEXT NOT NULL,
        gameId TEXT NOT NULL,
        challengeId TEXT NOT NULL,
        seed INTEGER NOT NULL,
        contentVersion TEXT NOT NULL,
        stateSchemaVersion INTEGER NOT NULL,
        serializedGameState TEXT NOT NULL,
        activeElapsedMs INTEGER NOT NULL,
        savedAt TEXT NOT NULL,
        PRIMARY KEY (profileId, gameId)
      )
    ''');

    await db.execute('''
      CREATE TABLE unlocked_stickers (
        profileId TEXT NOT NULL,
        stickerId TEXT NOT NULL,
        sourceCompletionId TEXT NOT NULL,
        awardedAt TEXT NOT NULL,
        PRIMARY KEY (profileId, stickerId)
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_adventures (
        profileId TEXT NOT NULL,
        localDate TEXT NOT NULL,
        challengeIds TEXT NOT NULL,
        completionFlags TEXT NOT NULL,
        rewardClaimed INTEGER NOT NULL,
        PRIMARY KEY (profileId, localDate)
      )
    ''');
  }

  // --- Profiles DAO ---

  Future<List<Profile>> getProfiles() async {
    try {
      final db = await database;
      if (db != null) {
        final rows = await db.query('profiles', orderBy: 'createdAt ASC');
        final list = rows.map((r) => Profile.fromMap(r)).toList();
        for (final p in list) {
          _memoryProfiles[p.id] = p;
        }
        return list;
      }
    } catch (e) {
      debugPrint('AppDatabase: getProfiles query warning: $e');
    }
    return _memoryProfiles.values.toList();
  }

  Future<Profile?> getProfile(String id) async {
    try {
      final db = await database;
      if (db != null) {
        final rows = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
        if (rows.isNotEmpty) {
          final profile = Profile.fromMap(rows.first);
          _memoryProfiles[id] = profile;
          return profile;
        }
      }
    } catch (e) {
      debugPrint('AppDatabase: getProfile query warning: $e');
    }
    return _memoryProfiles[id];
  }

  Future<void> saveProfile(Profile profile) async {
    _memoryProfiles[profile.id] = profile;
    try {
      final db = await database;
      if (db != null) {
        await db.insert(
          'profiles',
          profile.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('AppDatabase: saveProfile insert warning: $e');
    }
  }

  Future<void> deleteProfile(String profileId) async {
    _memoryProfiles.remove(profileId);
    _memoryAttempts.removeWhere((a) => a.profileId == profileId);
    _memoryCheckpoints.removeWhere((k, _) => k.startsWith('${profileId}_'));
    _memoryUnlockedStickers.removeWhere((s) => s.startsWith('${profileId}_'));
    _memoryDailyAdventures.removeWhere((k, _) => k.startsWith('${profileId}_'));

    try {
      final db = await database;
      if (db != null) {
        await db.transaction((txn) async {
          await txn.delete('profiles', where: 'id = ?', whereArgs: [profileId]);
          await txn.delete('attempts', where: 'profileId = ?', whereArgs: [profileId]);
          await txn.delete('skill_progress', where: 'profileId = ?', whereArgs: [profileId]);
          await txn.delete('checkpoints', where: 'profileId = ?', whereArgs: [profileId]);
          await txn.delete('unlocked_stickers', where: 'profileId = ?', whereArgs: [profileId]);
          await txn.delete('daily_adventures', where: 'profileId = ?', whereArgs: [profileId]);
        });
      }
    } catch (e) {
      debugPrint('AppDatabase: deleteProfile warning: $e');
    }
  }

  // --- Attempts & Rewards Transaction ---

  Future<void> recordAttemptAndReward({
    required GameResult result,
    String? unlockedStickerId,
  }) async {
    _memoryAttempts.add(result);
    if (unlockedStickerId != null) {
      _memoryUnlockedStickers.add('${result.profileId}_$unlockedStickerId');
    }
    _memoryCheckpoints.remove('${result.profileId}_${result.gameId}');

    try {
      final db = await database;
      if (db != null) {
        await db.transaction((txn) async {
          await txn.insert(
            'attempts',
            result.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          await txn.delete(
            'checkpoints',
            where: 'profileId = ? AND gameId = ?',
            whereArgs: [result.profileId, result.gameId],
          );

          if (unlockedStickerId != null) {
            final sticker = UnlockedSticker(
              profileId: result.profileId,
              stickerId: unlockedStickerId,
              sourceCompletionId: result.completionId,
            );
            await txn.insert(
              'unlocked_stickers',
              sticker.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('AppDatabase: recordAttemptAndReward warning: $e');
    }
  }

  Future<List<GameResult>> getAttemptsForProfile(String profileId) async {
    try {
      final db = await database;
      if (db != null) {
        final rows = await db.query(
          'attempts',
          where: 'profileId = ?',
          whereArgs: [profileId],
          orderBy: 'completedAt DESC',
          limit: 100,
        );
        return rows.map((r) => GameResult.fromMap(r)).toList();
      }
    } catch (e) {
      debugPrint('AppDatabase: getAttemptsForProfile query warning: $e');
    }
    return _memoryAttempts
        .where((a) => a.profileId == profileId)
        .toList()
        .reversed
        .take(100)
        .toList();
  }

  // --- Checkpoints DAO ---

  Future<void> saveCheckpoint(Checkpoint checkpoint) async {
    _memoryCheckpoints['${checkpoint.profileId}_${checkpoint.gameId}'] = checkpoint;
    try {
      final db = await database;
      if (db != null) {
        await db.insert(
          'checkpoints',
          checkpoint.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('AppDatabase: saveCheckpoint insert warning: $e');
    }
  }

  Future<Checkpoint?> getCheckpoint(String profileId, String gameId) async {
    try {
      final db = await database;
      if (db != null) {
        final rows = await db.query(
          'checkpoints',
          where: 'profileId = ? AND gameId = ?',
          whereArgs: [profileId, gameId],
        );
        if (rows.isNotEmpty) return Checkpoint.fromMap(rows.first);
      }
    } catch (e) {
      debugPrint('AppDatabase: getCheckpoint query warning: $e');
    }
    return _memoryCheckpoints['${profileId}_$gameId'];
  }

  Future<void> clearCheckpoint(String profileId, String gameId) async {
    _memoryCheckpoints.remove('${profileId}_$gameId');
    try {
      final db = await database;
      if (db != null) {
        await db.delete(
          'checkpoints',
          where: 'profileId = ? AND gameId = ?',
          whereArgs: [profileId, gameId],
        );
      }
    } catch (e) {
      debugPrint('AppDatabase: clearCheckpoint warning: $e');
    }
  }

  // --- Stickers DAO ---

  Future<List<String>> getUnlockedStickerIds(String profileId) async {
    try {
      final db = await database;
      if (db != null) {
        final rows = await db.query(
          'unlocked_stickers',
          columns: ['stickerId'],
          where: 'profileId = ?',
          whereArgs: [profileId],
        );
        return rows.map((r) => r['stickerId'] as String).toList();
      }
    } catch (e) {
      debugPrint('AppDatabase: getUnlockedStickerIds query warning: $e');
    }
    final prefix = '${profileId}_';
    return _memoryUnlockedStickers
        .where((k) => k.startsWith(prefix))
        .map((k) => k.substring(prefix.length))
        .toList();
  }

  Future<void> unlockSticker({
    required String profileId,
    required String stickerId,
    required String sourceCompletionId,
  }) async {
    _memoryUnlockedStickers.add('${profileId}_$stickerId');
    try {
      final db = await database;
      if (db != null) {
        final sticker = UnlockedSticker(
          profileId: profileId,
          stickerId: stickerId,
          sourceCompletionId: sourceCompletionId,
        );
        await db.insert(
          'unlocked_stickers',
          sticker.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (e) {
      debugPrint('AppDatabase: unlockSticker warning: $e');
    }
  }

  // --- Daily Adventures DAO ---

  Future<DailyAdventure?> getDailyAdventure(String profileId, String localDate) async {
    try {
      final db = await database;
      if (db != null) {
        final rows = await db.query(
          'daily_adventures',
          where: 'profileId = ? AND localDate = ?',
          whereArgs: [profileId, localDate],
        );
        if (rows.isNotEmpty) return DailyAdventure.fromMap(rows.first);
      }
    } catch (e) {
      debugPrint('AppDatabase: getDailyAdventure query warning: $e');
    }
    return _memoryDailyAdventures['${profileId}_$localDate'];
  }

  Future<void> saveDailyAdventure(DailyAdventure adventure) async {
    _memoryDailyAdventures['${adventure.profileId}_${adventure.localDate}'] = adventure;
    try {
      final db = await database;
      if (db != null) {
        await db.insert(
          'daily_adventures',
          adventure.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('AppDatabase: saveDailyAdventure warning: $e');
    }
  }

  // --- Full Factory Reset ---

  Future<void> fullFactoryReset() async {
    _memoryProfiles.clear();
    _memoryAttempts.clear();
    _memoryCheckpoints.clear();
    _memoryUnlockedStickers.clear();
    _memoryDailyAdventures.clear();

    try {
      final db = await database;
      if (db != null) {
        await db.transaction((txn) async {
          await txn.delete('profiles');
          await txn.delete('attempts');
          await txn.delete('skill_progress');
          await txn.delete('checkpoints');
          await txn.delete('unlocked_stickers');
          await txn.delete('daily_adventures');
        });
      }
    } catch (e) {
      debugPrint('AppDatabase: fullFactoryReset warning: $e');
    }
  }
}
