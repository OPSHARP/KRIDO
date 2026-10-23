import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../domain/models/game_result.dart';

class SkillScore {
  final String nameEn;
  final String nameHi;
  final double score; // 0.0 to 1.0
  final String icon;

  const SkillScore({
    required this.nameEn,
    required this.nameHi,
    required this.score,
    required this.icon,
  });

  String localizedName(String locale) => locale == 'hi' ? nameHi : nameEn;
}

class SkillsRadarChart extends StatelessWidget {
  final List<GameResult> attempts;
  final String locale;

  const SkillsRadarChart({
    super.key,
    required this.attempts,
    this.locale = 'en',
  });

  List<SkillScore> computeSkillScores() {
    double numeracy = 0.5;
    double literacy = 0.5;
    double logic = 0.5;
    double memory = 0.5;
    double motor = 0.5;
    double focus = 0.5;

    for (final a in attempts) {
      final isSuccess = a.completed;
      final boost = isSuccess ? 0.08 : 0.02;

      // Group by game prefix or tags
      if (a.gameId.startsWith('G00') || a.gameId.startsWith('G07') || a.gameId.startsWith('G08')) {
        numeracy = (numeracy + boost).clamp(0.0, 1.0);
      }
      if (a.gameId.startsWith('G01') || a.gameId.startsWith('G02')) {
        literacy = (literacy + boost).clamp(0.0, 1.0);
      }
      if (a.gameId.startsWith('G03') || a.gameId.startsWith('G06')) {
        logic = (logic + boost).clamp(0.0, 1.0);
      }
      if (a.gameId.startsWith('G04')) {
        memory = (memory + boost).clamp(0.0, 1.0);
      }
      if (a.gameId.startsWith('G05') || a.gameId.startsWith('G10')) {
        motor = (motor + boost).clamp(0.0, 1.0);
      }
      if (!a.assisted && a.hintsUsed == 0 && a.completed) {
        focus = (focus + 0.07).clamp(0.0, 1.0);
      }
    }

    return [
      SkillScore(nameEn: 'Numeracy', nameHi: 'संख्या ज्ञान', score: numeracy, icon: '🔢'),
      SkillScore(nameEn: 'Literacy', nameHi: 'भाषा व वर्ण', score: literacy, icon: '🔤'),
      SkillScore(nameEn: 'Logic & Shapes', nameHi: 'तर्क व आकार', score: logic, icon: '🧩'),
      SkillScore(nameEn: 'Memory', nameHi: 'स्मृति शक्ति', score: memory, icon: '🧠'),
      SkillScore(nameEn: 'Motor Skills', nameHi: 'हाथ-आँख समन्वय', score: motor, icon: '🎯'),
      SkillScore(nameEn: 'Focus', nameHi: 'एकाग्रता', score: focus, icon: '⭐'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final skills = computeSkillScores();
    final isHindi = locale == 'hi';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'विकासात्मक कौशल विश्लेषण' : 'Developmental Skills Radar',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textNavy,
                      ),
                    ),
                    Text(
                      isHindi
                          ? 'सक्रिय खेलों के आधार पर 6-धुरी विश्लेषण'
                          : '6-axis learning matrix from active gameplay',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Radar Chart Canvas
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: _RadarChartPainter(skills: skills, locale: locale),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Skills Breakdown Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) {
              final percent = (s.score * 100).round();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.sky.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '${s.localizedName(locale)}: ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textNavy,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.purple,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<SkillScore> skills;
  final String locale;

  _RadarChartPainter({required this.skills, required this.locale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.38;
    final int count = skills.length;
    final double angleStep = 2 * pi / count;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final spokePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw concentric web rings (25%, 50%, 75%, 100%)
    for (int ring = 1; ring <= 4; ring++) {
      final r = radius * (ring / 4);
      final ringPath = Path();
      for (int i = 0; i < count; i++) {
        final angle = -pi / 2 + (i * angleStep);
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // Draw spokes and labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < count; i++) {
      final angle = -pi / 2 + (i * angleStep);
      final spokeEnd = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, spokeEnd, spokePaint);

      // Label text
      final labelPos = Offset(
        center.dx + (radius + 18) * cos(angle),
        center.dy + (radius + 18) * sin(angle),
      );
      textPainter.text = TextSpan(
        text: skills[i].icon,
        style: const TextStyle(fontSize: 16),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2),
      );
    }

    // Data polygon
    final dataPath = Path();
    final pointOffsets = <Offset>[];

    for (int i = 0; i < count; i++) {
      final angle = -pi / 2 + (i * angleStep);
      final r = radius * skills[i].score;
      final point = Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
      pointOffsets.add(point);
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    // Fill data polygon
    final fillPaint = Paint()
      ..color = AppTheme.purple.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Border of data polygon
    final borderPaint = Paint()
      ..color = AppTheme.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(dataPath, borderPaint);

    // Vertex dots
    final dotPaint = Paint()..color = AppTheme.sunGold;
    for (final pt in pointOffsets) {
      canvas.drawCircle(pt, 4.5, dotPaint);
      canvas.drawCircle(pt, 4.5, borderPaint..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}
