import 'dart:math';

/// A deterministic pseudo-random number generator for reproducible child challenges.
class SeededRng {
  final int seed;
  late final Random _random;

  SeededRng(this.seed) {
    _random = Random(seed);
  }

  /// Returns a random integer in range [min, max] inclusive.
  int nextInt(int min, int max) {
    if (min >= max) return min;
    return min + _random.nextInt(max - min + 1);
  }

  /// Returns a random double in range [0.0, 1.0).
  double nextDouble() => _random.nextDouble();

  /// Shuffles a list deterministically.
  List<T> shuffle<T>(List<T> items) {
    final copy = List<T>.from(items);
    for (int i = copy.length - 1; i > 0; i--) {
      int j = _random.nextInt(i + 1);
      final temp = copy[i];
      copy[i] = copy[j];
      copy[j] = temp;
    }
    return copy;
  }

  /// Deterministically picks N unique elements from a list.
  List<T> pickUnique<T>(List<T> items, int count) {
    if (count <= 0) return [];
    final shuffled = shuffle(items);
    return shuffled.take(min(count, shuffled.length)).toList();
  }

  /// Deterministically picks one element from a non-empty list.
  T pickOne<T>(List<T> items) {
    if (items.isEmpty) throw ArgumentError('items cannot be empty');
    return items[nextInt(0, items.length - 1)];
  }
}
