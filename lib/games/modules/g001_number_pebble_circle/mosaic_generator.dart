import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Single cell in the circular mosaic
class MosaicCell {
  final int index; // 0 to 49
  int number; // e.g. 1 to 50, 51 to 100, etc.
  final Offset seed; // Normalized center site
  final List<Offset> normalizedVertices;
  final Offset normalizedCentroid;
  Size? _cachedPathSize;
  Path? _cachedPath;

  MosaicCell({
    required this.index,
    required this.number,
    required this.seed,
    required this.normalizedVertices,
  }) : normalizedCentroid = _computeNormalizedCentroid(normalizedVertices);

  static Offset _computeNormalizedCentroid(List<Offset> vertices) {
    if (vertices.isEmpty) return const Offset(0.5, 0.5);
    double sumX = 0;
    double sumY = 0;
    for (final v in vertices) {
      sumX += v.dx;
      sumY += v.dy;
    }
    return Offset(sumX / vertices.length, sumY / vertices.length);
  }

  /// Compute centroid of the polygon for any board size
  Offset getCentroid(Size size) {
    return Offset(normalizedCentroid.dx * size.width, normalizedCentroid.dy * size.height);
  }

  /// Create path scaled to board size with rounded corners
  Path getPath(Size size) {
    if (_cachedPath != null && _cachedPathSize == size) return _cachedPath!;
    _cachedPathSize = size;
    final path = Path();
    if (normalizedVertices.isEmpty) return path;

    final points = normalizedVertices
        .map((v) => Offset(v.dx * size.width, v.dy * size.height))
        .toList();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    _cachedPath = path;
    return path;
  }

  /// Hit-test if a touch coordinate falls within this mosaic cell
  bool containsPoint(Offset localPoint, Size size) {
    final path = getPath(size);
    return path.contains(localPoint);
  }
}

/// Circular Voronoi Tessellation Generator
/// Generates organic, interlocking cobblestone cells inside a circle (10 cells for 1-100 stages, 50 cells after 100)
class MosaicGenerator {
  static const int defaultCellCount = 50;

  /// Generate mosaic cells for a given random seed and count (10 or 50)
  static List<MosaicCell> generateCells({
    required int seed,
    required int rangeStart,
    int count = 50,
  }) {
    final random = math.Random(seed);

    // 1. Generate seed sites distributed in concentric rings
    // Center: (0.5, 0.5), Radius: 0.475
    const center = Offset(0.5, 0.5);
    const maxRadius = 0.475;

    final List<Offset> sites = [];

    if (count <= 10) {
      // 10 sites for 1 to 100 in groups of 10
      // Outer ring: 7 cells at ~0.66 radius
      const int outerCount = 7;
      final double outerBaseAngle = random.nextDouble() * 2 * math.pi;
      for (int i = 0; i < outerCount; i++) {
        final angle = outerBaseAngle + (i * 2 * math.pi / outerCount) + (random.nextDouble() - 0.5) * 0.08;
        final r = maxRadius * (0.68 + (random.nextDouble() - 0.5) * 0.04);
        sites.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
      }

      // Inner ring: 3 cells at ~0.24 radius
      const int innerCount = 3;
      final double innerBaseAngle = outerBaseAngle + (math.pi / outerCount);
      for (int i = 0; i < innerCount; i++) {
        final angle = innerBaseAngle + (i * 2 * math.pi / innerCount) + (random.nextDouble() - 0.5) * 0.08;
        final r = maxRadius * (0.24 + (random.nextDouble() - 0.5) * 0.03);
        sites.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
      }
    } else {
      // 50 sites for stages after 100 (in groups of 50)
      // Outer Ring: 22 cells at ~0.80 radius
      const int outerCount = 22;
      final double outerBaseAngle = random.nextDouble() * 2 * math.pi;
      for (int i = 0; i < outerCount; i++) {
        final angle = outerBaseAngle + (i * 2 * math.pi / outerCount) + (random.nextDouble() - 0.5) * 0.08;
        final r = maxRadius * (0.80 + (random.nextDouble() - 0.5) * 0.05);
        sites.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
      }

      // Middle Ring: 17 cells at ~0.53 radius
      const int midCount = 17;
      final double midBaseAngle = random.nextDouble() * 2 * math.pi;
      for (int i = 0; i < midCount; i++) {
        final angle = midBaseAngle + (i * 2 * math.pi / midCount) + (random.nextDouble() - 0.5) * 0.10;
        final r = maxRadius * (0.53 + (random.nextDouble() - 0.5) * 0.05);
        sites.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
      }

      // Inner Ring: 9 cells at ~0.27 radius
      const int innerCount = 9;
      final double innerBaseAngle = random.nextDouble() * 2 * math.pi;
      for (int i = 0; i < innerCount; i++) {
        final angle = innerBaseAngle + (i * 2 * math.pi / innerCount) + (random.nextDouble() - 0.5) * 0.12;
        final r = maxRadius * (0.27 + (random.nextDouble() - 0.5) * 0.04);
        sites.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
      }

      // Center Core: 2 cells near center
      sites.add(Offset(center.dx - 0.045, center.dy));
      sites.add(Offset(center.dx + 0.045, center.dy));
    }

    final effectiveCellCount = sites.length;

    // 2. Base bounding circle polygon (approximated by 36-gon)
    const int circleSegments = 36;
    final List<Offset> baseCirclePolygon = [];
    for (int i = 0; i < circleSegments; i++) {
      final angle = i * 2 * math.pi / circleSegments;
      baseCirclePolygon.add(Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      ));
    }

    // 3. Clip each site against perpendicular bisectors to other sites
    final List<MosaicCell> cells = [];

    // Prepare numbers list (rangeStart to rangeStart + effectiveCellCount - 1)
    final List<int> numbers = List.generate(effectiveCellCount, (i) => rangeStart + i);
    // Shuffle numbers across the sites
    numbers.shuffle(random);

    for (int i = 0; i < effectiveCellCount; i++) {
      final pI = sites[i];
      List<Offset> poly = List.from(baseCirclePolygon);

      for (int j = 0; j < effectiveCellCount; j++) {
        if (i == j) continue;
        final pJ = sites[j];

        // Midpoint
        final m = Offset((pI.dx + pJ.dx) / 2, (pI.dy + pJ.dy) / 2);
        // Normal pointing from pI toward pJ
        final normal = Offset(pJ.dx - pI.dx, pJ.dy - pI.dy);

        poly = _clipPolygon(poly, m, normal);
        if (poly.isEmpty) break;
      }

      // Slightly shrink polygon toward site for organic cobblestone gap
      final shrunkPoly = _shrinkPolygon(poly, pI, 0.96);

      cells.add(MosaicCell(
        index: i,
        number: numbers[i],
        seed: pI,
        normalizedVertices: shrunkPoly.isNotEmpty ? shrunkPoly : poly,
      ));
    }

    return cells;
  }

  /// Sutherland-Hodgman polygon clipper against half-plane: (X - M) . Normal <= 0
  static List<Offset> _clipPolygon(List<Offset> poly, Offset m, Offset normal) {
    final List<Offset> output = [];
    if (poly.isEmpty) return output;

    for (int i = 0; i < poly.length; i++) {
      final current = poly[i];
      final next = poly[(i + 1) % poly.length];

      final d1 = (current.dx - m.dx) * normal.dx + (current.dy - m.dy) * normal.dy;
      final d2 = (next.dx - m.dx) * normal.dx + (next.dy - m.dy) * normal.dy;

      if (d1 <= 0) {
        output.add(current);
      }

      if ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) {
        // Line intersection with edge
        final t = d1 / (d1 - d2);
        output.add(Offset(
          current.dx + t * (next.dx - current.dx),
          current.dy + t * (next.dy - current.dy),
        ));
      }
    }

    return output;
  }

  /// Shrink polygon slightly toward center for clean grout lines
  static List<Offset> _shrinkPolygon(List<Offset> poly, Offset center, double scale) {
    final List<Offset> shrunk = [];
    for (final pt in poly) {
      shrunk.add(Offset(
        center.dx + (pt.dx - center.dx) * scale,
        center.dy + (pt.dy - center.dy) * scale,
      ));
    }
    return shrunk;
  }
}
