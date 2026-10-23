import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_controller.dart';
import '../../../domain/models/challenge.dart';
import '../../../domain/models/profile.dart';

class TracingWaypoint {
  final double x;
  final double y;
  bool isHit;

  TracingWaypoint({required this.x, required this.y, this.isHit = false});

  Map<String, dynamic> toMap() => {'x': x, 'y': y, 'isHit': isHit};
  factory TracingWaypoint.fromMap(Map<String, dynamic> map) => TracingWaypoint(
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        isHit: map['isHit'] as bool? ?? false,
      );
}

class LetterStroke {
  final int strokeNumber;
  final List<TracingWaypoint> waypoints;

  LetterStroke({required this.strokeNumber, required this.waypoints});
}

class TracingLetterItem {
  final String letter;
  final String word;
  final String wordHi;
  final String emoji;
  final List<LetterStroke> strokes;

  TracingLetterItem({
    required this.letter,
    required this.word,
    required this.wordHi,
    required this.emoji,
    required this.strokes,
  });
}

class G079Controller extends GameController {
  static List<TracingLetterItem> buildAlphabet() {
    return [
      // Letter A
      TracingLetterItem(
        letter: 'A',
        word: 'Apple',
        wordHi: 'सेब',
        emoji: '🍎',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.5, y: 0.15),
              TracingWaypoint(x: 0.42, y: 0.32),
              TracingWaypoint(x: 0.35, y: 0.50),
              TracingWaypoint(x: 0.28, y: 0.68),
              TracingWaypoint(x: 0.20, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.5, y: 0.15),
              TracingWaypoint(x: 0.58, y: 0.32),
              TracingWaypoint(x: 0.65, y: 0.50),
              TracingWaypoint(x: 0.72, y: 0.68),
              TracingWaypoint(x: 0.80, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.32, y: 0.58),
              TracingWaypoint(x: 0.44, y: 0.58),
              TracingWaypoint(x: 0.56, y: 0.58),
              TracingWaypoint(x: 0.68, y: 0.58),
            ],
          ),
        ],
      ),
      // Letter B
      TracingLetterItem(
        letter: 'B',
        word: 'Ball',
        wordHi: 'गेंद',
        emoji: '⚽',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.38),
              TracingWaypoint(x: 0.30, y: 0.62),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.55, y: 0.15),
              TracingWaypoint(x: 0.68, y: 0.32),
              TracingWaypoint(x: 0.55, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.50),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.60, y: 0.50),
              TracingWaypoint(x: 0.72, y: 0.68),
              TracingWaypoint(x: 0.60, y: 0.85),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter C
      TracingLetterItem(
        letter: 'C',
        word: 'Cat',
        wordHi: 'बिल्ली',
        emoji: '🐱',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.75, y: 0.25),
              TracingWaypoint(x: 0.55, y: 0.15),
              TracingWaypoint(x: 0.32, y: 0.28),
              TracingWaypoint(x: 0.25, y: 0.50),
              TracingWaypoint(x: 0.32, y: 0.72),
              TracingWaypoint(x: 0.55, y: 0.85),
              TracingWaypoint(x: 0.75, y: 0.75),
            ],
          ),
        ],
      ),
      // Letter D
      TracingLetterItem(
        letter: 'D',
        word: 'Dog',
        wordHi: 'कुत्ता',
        emoji: '🐶',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.58, y: 0.18),
              TracingWaypoint(x: 0.75, y: 0.40),
              TracingWaypoint(x: 0.75, y: 0.60),
              TracingWaypoint(x: 0.58, y: 0.82),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter E
      TracingLetterItem(
        letter: 'E',
        word: 'Elephant',
        wordHi: 'हाथी',
        emoji: '🐘',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.52, y: 0.15),
              TracingWaypoint(x: 0.75, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.62, y: 0.50),
            ],
          ),
          LetterStroke(
            strokeNumber: 4,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.85),
              TracingWaypoint(x: 0.52, y: 0.85),
              TracingWaypoint(x: 0.75, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter F
      TracingLetterItem(
        letter: 'F',
        word: 'Fish',
        wordHi: 'मछली',
        emoji: '🐟',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.52, y: 0.15),
              TracingWaypoint(x: 0.75, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.62, y: 0.50),
            ],
          ),
        ],
      ),
      // Letter G
      TracingLetterItem(
        letter: 'G',
        word: 'Grapes',
        wordHi: 'अंगूर',
        emoji: '🍇',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.75, y: 0.25),
              TracingWaypoint(x: 0.55, y: 0.15),
              TracingWaypoint(x: 0.32, y: 0.28),
              TracingWaypoint(x: 0.25, y: 0.50),
              TracingWaypoint(x: 0.32, y: 0.72),
              TracingWaypoint(x: 0.55, y: 0.85),
              TracingWaypoint(x: 0.75, y: 0.85),
              TracingWaypoint(x: 0.75, y: 0.55),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.75, y: 0.55),
              TracingWaypoint(x: 0.52, y: 0.55),
            ],
          ),
        ],
      ),
      // Letter H
      TracingLetterItem(
        letter: 'H',
        word: 'Hat',
        wordHi: 'टोपी',
        emoji: '🎩',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.70, y: 0.15),
              TracingWaypoint(x: 0.70, y: 0.50),
              TracingWaypoint(x: 0.70, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.50, y: 0.50),
              TracingWaypoint(x: 0.70, y: 0.50),
            ],
          ),
        ],
      ),
      // Letter I
      TracingLetterItem(
        letter: 'I',
        word: 'Ice Cream',
        wordHi: 'आइसक्रीम',
        emoji: '🍦',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.50, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.50),
              TracingWaypoint(x: 0.50, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.35, y: 0.15),
              TracingWaypoint(x: 0.65, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.35, y: 0.85),
              TracingWaypoint(x: 0.65, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter J
      TracingLetterItem(
        letter: 'J',
        word: 'Juice',
        wordHi: 'जूस',
        emoji: '🧃',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.35, y: 0.15),
              TracingWaypoint(x: 0.70, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.60, y: 0.15),
              TracingWaypoint(x: 0.60, y: 0.65),
              TracingWaypoint(x: 0.50, y: 0.85),
              TracingWaypoint(x: 0.35, y: 0.80),
              TracingWaypoint(x: 0.30, y: 0.68),
            ],
          ),
        ],
      ),
      // Letter K
      TracingLetterItem(
        letter: 'K',
        word: 'Kite',
        wordHi: 'पतंग',
        emoji: '🪁',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.72, y: 0.18),
              TracingWaypoint(x: 0.52, y: 0.38),
              TracingWaypoint(x: 0.32, y: 0.52),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.40, y: 0.48),
              TracingWaypoint(x: 0.58, y: 0.68),
              TracingWaypoint(x: 0.75, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter L
      TracingLetterItem(
        letter: 'L',
        word: 'Lion',
        wordHi: 'शेर',
        emoji: '🦁',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.85),
              TracingWaypoint(x: 0.52, y: 0.85),
              TracingWaypoint(x: 0.75, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter M
      TracingLetterItem(
        letter: 'M',
        word: 'Monkey',
        wordHi: 'बंदर',
        emoji: '🐵',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.25, y: 0.85),
              TracingWaypoint(x: 0.25, y: 0.50),
              TracingWaypoint(x: 0.25, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.25, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.55),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.50, y: 0.55),
              TracingWaypoint(x: 0.75, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 4,
            waypoints: [
              TracingWaypoint(x: 0.75, y: 0.15),
              TracingWaypoint(x: 0.75, y: 0.50),
              TracingWaypoint(x: 0.75, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter N
      TracingLetterItem(
        letter: 'N',
        word: 'Nest',
        wordHi: 'घोंसला',
        emoji: '🪺',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.28, y: 0.85),
              TracingWaypoint(x: 0.28, y: 0.50),
              TracingWaypoint(x: 0.28, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.28, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.50),
              TracingWaypoint(x: 0.72, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.72, y: 0.85),
              TracingWaypoint(x: 0.72, y: 0.50),
              TracingWaypoint(x: 0.72, y: 0.15),
            ],
          ),
        ],
      ),
      // Letter O
      TracingLetterItem(
        letter: 'O',
        word: 'Orange',
        wordHi: 'संतरा',
        emoji: '🍊',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.50, y: 0.15),
              TracingWaypoint(x: 0.28, y: 0.32),
              TracingWaypoint(x: 0.25, y: 0.50),
              TracingWaypoint(x: 0.28, y: 0.68),
              TracingWaypoint(x: 0.50, y: 0.85),
              TracingWaypoint(x: 0.72, y: 0.68),
              TracingWaypoint(x: 0.75, y: 0.50),
              TracingWaypoint(x: 0.72, y: 0.32),
              TracingWaypoint(x: 0.50, y: 0.15),
            ],
          ),
        ],
      ),
      // Letter P
      TracingLetterItem(
        letter: 'P',
        word: 'Panda',
        wordHi: 'पांडा',
        emoji: '🐼',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.58, y: 0.15),
              TracingWaypoint(x: 0.72, y: 0.32),
              TracingWaypoint(x: 0.58, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.50),
            ],
          ),
        ],
      ),
      // Letter Q
      TracingLetterItem(
        letter: 'Q',
        word: 'Queen',
        wordHi: 'रानी',
        emoji: '👑',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.50, y: 0.15),
              TracingWaypoint(x: 0.28, y: 0.32),
              TracingWaypoint(x: 0.25, y: 0.50),
              TracingWaypoint(x: 0.28, y: 0.68),
              TracingWaypoint(x: 0.50, y: 0.85),
              TracingWaypoint(x: 0.72, y: 0.68),
              TracingWaypoint(x: 0.75, y: 0.50),
              TracingWaypoint(x: 0.72, y: 0.32),
              TracingWaypoint(x: 0.50, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.58, y: 0.68),
              TracingWaypoint(x: 0.78, y: 0.88),
            ],
          ),
        ],
      ),
      // Letter R
      TracingLetterItem(
        letter: 'R',
        word: 'Rabbit',
        wordHi: 'खरगोश',
        emoji: '🐰',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.58, y: 0.15),
              TracingWaypoint(x: 0.72, y: 0.32),
              TracingWaypoint(x: 0.58, y: 0.50),
              TracingWaypoint(x: 0.30, y: 0.50),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.45, y: 0.50),
              TracingWaypoint(x: 0.60, y: 0.68),
              TracingWaypoint(x: 0.75, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter S
      TracingLetterItem(
        letter: 'S',
        word: 'Sun',
        wordHi: 'सूरज',
        emoji: '☀️',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.72, y: 0.25),
              TracingWaypoint(x: 0.50, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.28),
              TracingWaypoint(x: 0.50, y: 0.48),
              TracingWaypoint(x: 0.72, y: 0.68),
              TracingWaypoint(x: 0.50, y: 0.85),
              TracingWaypoint(x: 0.28, y: 0.75),
            ],
          ),
        ],
      ),
      // Letter T
      TracingLetterItem(
        letter: 'T',
        word: 'Tiger',
        wordHi: 'बाघ',
        emoji: '🐯',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.25, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.15),
              TracingWaypoint(x: 0.75, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.50, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.50),
              TracingWaypoint(x: 0.50, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter U
      TracingLetterItem(
        letter: 'U',
        word: 'Umbrella',
        wordHi: 'छाता',
        emoji: '☂️',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.30, y: 0.15),
              TracingWaypoint(x: 0.30, y: 0.65),
              TracingWaypoint(x: 0.50, y: 0.85),
              TracingWaypoint(x: 0.70, y: 0.65),
              TracingWaypoint(x: 0.70, y: 0.15),
            ],
          ),
        ],
      ),
      // Letter V
      TracingLetterItem(
        letter: 'V',
        word: 'Violin',
        wordHi: 'वायलिन',
        emoji: '🎻',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.25, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.50, y: 0.85),
              TracingWaypoint(x: 0.75, y: 0.15),
            ],
          ),
        ],
      ),
      // Letter W
      TracingLetterItem(
        letter: 'W',
        word: 'Watch',
        wordHi: 'घड़ी',
        emoji: '⌚',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.22, y: 0.15),
              TracingWaypoint(x: 0.35, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.35, y: 0.85),
              TracingWaypoint(x: 0.50, y: 0.45),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.50, y: 0.45),
              TracingWaypoint(x: 0.65, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 4,
            waypoints: [
              TracingWaypoint(x: 0.65, y: 0.85),
              TracingWaypoint(x: 0.78, y: 0.15),
            ],
          ),
        ],
      ),
      // Letter X
      TracingLetterItem(
        letter: 'X',
        word: 'Xylophone',
        wordHi: 'जाइलोफोन',
        emoji: '🎵',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.28, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.50),
              TracingWaypoint(x: 0.72, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.72, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.50),
              TracingWaypoint(x: 0.28, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter Y
      TracingLetterItem(
        letter: 'Y',
        word: 'Yacht',
        wordHi: 'नाव',
        emoji: '⛵',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.25, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.50),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.75, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.50),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.50, y: 0.50),
              TracingWaypoint(x: 0.50, y: 0.85),
            ],
          ),
        ],
      ),
      // Letter Z
      TracingLetterItem(
        letter: 'Z',
        word: 'Zebra',
        wordHi: 'ज़ेब्रा',
        emoji: '🦓',
        strokes: [
          LetterStroke(
            strokeNumber: 1,
            waypoints: [
              TracingWaypoint(x: 0.28, y: 0.15),
              TracingWaypoint(x: 0.72, y: 0.15),
            ],
          ),
          LetterStroke(
            strokeNumber: 2,
            waypoints: [
              TracingWaypoint(x: 0.72, y: 0.15),
              TracingWaypoint(x: 0.50, y: 0.50),
              TracingWaypoint(x: 0.28, y: 0.85),
            ],
          ),
          LetterStroke(
            strokeNumber: 3,
            waypoints: [
              TracingWaypoint(x: 0.28, y: 0.85),
              TracingWaypoint(x: 0.72, y: 0.85),
            ],
          ),
        ],
      ),
    ];
  }

  int currentLetterIndex = 0;
  late List<TracingLetterItem> letterDeck;

  TracingLetterItem get currentLetter => letterDeck[currentLetterIndex];

  List<List<Offset>> userDrawnStrokes = [];
  bool isLetterCompleted = false;

  void selectLetter(int index) {
    if (index >= 0 && index < letterDeck.length) {
      currentLetterIndex = index;
      _resetLetterState();
      resetToPlaying();
      AudioService().playCue(SoundCue.press);
      notifyListeners();
    }
  }

  G079Controller({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  }) : super(challenge: challenge, profile: profile, seed: seed) {
    letterDeck = buildAlphabet();
  }

  @override
  Future<void> initialize() async {
    _resetLetterState();
    await super.initialize();
  }

  void _resetLetterState() {
    userDrawnStrokes.clear();
    isLetterCompleted = false;
    for (final stroke in currentLetter.strokes) {
      for (final wp in stroke.waypoints) {
        wp.isHit = false;
      }
    }
  }

  double get completionRatio {
    int total = 0;
    int hit = 0;
    for (final stroke in currentLetter.strokes) {
      for (final wp in stroke.waypoints) {
        total++;
        if (wp.isHit) hit++;
      }
    }
    return total > 0 ? (hit / total) : 0.0;
  }

  void onPanStart(Offset normPoint) {
    if (isLetterCompleted) return;
    playTapSound();
    userDrawnStrokes.add([normPoint]);
    _checkWaypointsContinuous(normPoint, normPoint);
    notifyListeners();
  }

  void onPanUpdate(Offset normPoint) {
    if (isLetterCompleted) return;
    if (userDrawnStrokes.isNotEmpty) {
      final lastPoint = userDrawnStrokes.last.isNotEmpty
          ? userDrawnStrokes.last.last
          : normPoint;
      userDrawnStrokes.last.add(normPoint);
      _checkWaypointsContinuous(lastPoint, normPoint);
      notifyListeners();
    }
  }

  void onPanEnd() {
    if (isLetterCompleted) return;
    // Kid-friendly completion threshold on stroke release
    if (completionRatio >= 0.60) {
      _celebrateLetter();
    }
  }

  static double _distToSegmentSquared(Offset p, Offset v, Offset w) {
    final l2 = (v.dx - w.dx) * (v.dx - w.dx) + (v.dy - w.dy) * (v.dy - w.dy);
    if (l2 == 0) {
      final dx = p.dx - v.dx;
      final dy = p.dy - v.dy;
      return (dx * dx) + (dy * dy);
    }
    final t = (((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2).clamp(0.0, 1.0);
    final projX = v.dx + t * (w.dx - v.dx);
    final projY = v.dy + t * (w.dy - v.dy);
    final dx = p.dx - projX;
    final dy = p.dy - projY;
    return (dx * dx) + (dy * dy);
  }

  void _checkWaypointsContinuous(Offset p1, Offset p2) {
    bool newlyHit = false;
    for (final stroke in currentLetter.strokes) {
      for (final wp in stroke.waypoints) {
        if (!wp.isHit) {
          final wpOffset = Offset(wp.x, wp.y);
          final distSq = _distToSegmentSquared(wpOffset, p1, p2);
          // 0.025 squared distance corresponds to ~0.16 normalized radius (~55px)
          if (distSq <= 0.025) {
            wp.isHit = true;
            newlyHit = true;
          }
        }
      }
    }

    if (newlyHit) {
      AudioService().playCue(SoundCue.bubble);
    }

    // Generous threshold: 0.70 completion is enough for young children
    if (completionRatio >= 0.70 && !isLetterCompleted) {
      _celebrateLetter();
    }
  }

  void _celebrateLetter() {
    isLetterCompleted = true;
    recordCorrectAction(wasAssisted: hintHighlightId != null);
    clearHint();
    AudioService().playCue(SoundCue.complete);
    AudioService().playCue(SoundCue.star);
    notifyListeners();
  }

  void nextLetter() {
    if (currentLetterIndex + 1 < letterDeck.length) {
      currentLetterIndex++;
      _resetLetterState();
      notifyListeners();
    } else {
      completeGame();
    }
  }

  void clearCanvas() {
    _resetLetterState();
    notifyListeners();
  }

  void reset() {
    currentLetterIndex = 0;
    _resetLetterState();
    start();
  }

  @override
  void applyHint() {
    // Show arrow directions
    hintHighlightId = 'tracing_hint';
    AudioService().playCue(SoundCue.hint);
    notifyListeners();
  }

  @override
  Future<void> handleAction(GameAction action) async {
    if (action.type == GameActionType.select && action.targetId == 'next') {
      nextLetter();
    } else if (action.type == GameActionType.reset ||
        (action.type == GameActionType.select && action.targetId == 'clear')) {
      clearCanvas();
    }
  }

  @override
  String serializeGameState() {
    return jsonEncode({
      'currentLetterIndex': currentLetterIndex,
      'isLetterCompleted': isLetterCompleted,
    });
  }

  @override
  void deserializeGameState(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      currentLetterIndex = map['currentLetterIndex'] as int? ?? 0;
      isLetterCompleted = map['isLetterCompleted'] as bool? ?? false;
    } catch (_) {
      _resetLetterState();
    }
  }
}
