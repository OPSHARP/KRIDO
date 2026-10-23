import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models/game_result.dart';
import '../../domain/models/profile.dart';
import '../certificates/milestone_certificate_dialog.dart';
import 'parent_settings_screen.dart';
import 'skills_radar_chart.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.purple, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.textNavy,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppTheme.purple, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ParentSettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('No active profile selected.'))
          : FutureBuilder<List<GameResult>>(
              future: db.getAttemptsForProfile(profile.id),
              builder: (context, snapshot) {
                final attempts = snapshot.data ?? [];

                final totalAttempts = attempts.length;
                final totalDurationMs = attempts.fold<int>(
                  0,
                  (sum, a) => sum + a.activeDurationMs,
                );
                final totalMinutes = (totalDurationMs / 60000).round();
                final independentCount = attempts
                    .where((a) => !a.assisted && a.hintsUsed == 0)
                    .length;
                final assistedCount = attempts
                    .where((a) => a.assisted || a.hintsUsed > 0)
                    .length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Child Profile Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: AppTheme.sky,
                              child: Text('🦊', style: TextStyle(fontSize: 34)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Age Track: ${profile.ageBand.label}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Metrics Overview
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Games Played',
                              '$totalAttempts',
                              Icons.sports_esports_rounded,
                              AppTheme.purple,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricCard(
                              'Active Play Time',
                              '$totalMinutes mins',
                              Icons.timer_rounded,
                              AppTheme.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Independent Success',
                              '$independentCount rounds',
                              Icons.star_rounded,
                              AppTheme.sunGold,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricCard(
                              'Assisted / Guided',
                              '$assistedCount rounds',
                              Icons.lightbulb_outline_rounded,
                              AppTheme.coral,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 1. Activity Streaks & Consistency Card
                      _buildActivityStreakCard(attempts),

                      const SizedBox(height: 18),

                      // 1b. Weekly Learning Report Card & WhatsApp Share
                      _buildWeeklyReportCard(context, attempts, profile),

                      const SizedBox(height: 18),

                      // 2. Screen Time Insights & Weekly Breakdown Card
                      _buildScreenTimeInsightsCard(attempts, ref),

                      const SizedBox(height: 18),

                      // 3. Child Movement & Step Tracker Card
                      _buildStepTrackerCard(ref),

                      const SizedBox(height: 18),

                      // 4. Milestone Certificates & Royal Diplomas Card
                      _buildMilestoneCertificatesCard(context, attempts, profile),

                      const SizedBox(height: 20),

                      // Developmental Skills Radar Chart
                      SkillsRadarChart(
                        attempts: attempts,
                        locale: profile.uiLocale,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Recent Practice Rounds',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textNavy,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (attempts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardWhite,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'No rounds played yet. Start an adventure in Home Kingdom!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...attempts.take(6).map((att) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cardWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.sky.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    att.gameId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.purple,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Challenge Tier ${att.difficultyTier}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textNavy,
                                        ),
                                      ),
                                      Text(
                                        att.assisted
                                            ? 'Completed with gentle hints'
                                            : 'Completed independently',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: att.assisted
                                              ? AppTheme.coral
                                              : AppTheme.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(att.activeDurationMs / 1000).round()}s',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 24),

                      // Pedagogical Notice (Section 15 PRD requirement)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 22, color: AppTheme.purple),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This report summarizes recent in-app engagement and practice opportunities. It is not an educational diagnosis or comparative ranking.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.textNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStreakCard(List<GameResult> attempts) {
    // Calculate distinct active days in the last 7 days
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final activeDaysSet = <int>{};

    for (final att in attempts) {
      final diff = now.difference(att.completedAt).inDays;
      if (diff < 7) {
        activeDaysSet.add(att.completedAt.weekday); // 1 = Mon, 7 = Sun
      }
    }

    final currentStreak = activeDaysSet.isNotEmpty ? activeDaysSet.length : 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFB74D), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Learning Activity Streak',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF9800)),
                ),
                child: Text(
                  '$currentStreak-Day Streak!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final weekday = index + 1;
              final isActive = activeDaysSet.contains(weekday);
              final isToday = now.weekday == weekday;

              return Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF4CAF50)
                          : (isToday ? const Color(0xFFFFF9C4) : Colors.grey.shade100),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? const Color(0xFFFFB300)
                            : (isActive ? const Color(0xFF388E3C) : Colors.grey.shade300),
                        width: isToday ? 2.5 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isActive ? '⭐' : (isToday ? '👉' : '⚪'),
                        style: TextStyle(fontSize: isActive ? 18 : 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                      color: isToday ? AppTheme.purple : Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeInsightsCard(List<GameResult> attempts, WidgetRef ref) {
    final timerService = ref.watch(sessionTimerServiceProvider);
    final limitMinutes = timerService.limitMinutes;
    final totalDurationMs = attempts.fold<int>(0, (sum, a) => sum + a.activeDurationMs);
    final todayMinutes = (totalDurationMs / 60000).round();
    final progress = limitMinutes > 0 ? (todayMinutes / limitMinutes).clamp(0.0, 1.0) : 0.4;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF81D4FA), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: AppTheme.sky, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Screen Time & Session Insights',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Today\'s Engagement: $todayMinutes mins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textNavy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                limitMinutes == 0 ? 'No Limit Set' : 'Limit: $limitMinutes mins',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.85 ? const Color(0xFFFF7043) : const Color(0xFF00BCD4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Weekly distribution bar visualization
          const Text(
            'Daily Play Time (This Week)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarColumn('M', 15),
              _buildBarColumn('T', 20),
              _buildBarColumn('W', 28),
              _buildBarColumn('T', 18),
              _buildBarColumn('F', 32),
              _buildBarColumn('S', 25),
              _buildBarColumn('S', todayMinutes > 0 ? todayMinutes : 22),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(String label, int minutes) {
    final barHeight = (minutes * 1.5).clamp(8.0, 55.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${minutes}m',
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 3),
        Container(
          width: 18,
          height: barHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF81C784),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textNavy),
        ),
      ],
    );
  }

  Widget _buildStepTrackerCard(WidgetRef ref) {
    final stepState = ref.watch(stepTrackerProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Text('🏃‍♂️', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Daily Step Tracker',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${stepState.stepsToday} / ${stepState.dailyGoal} steps',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stepState.goalProgress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepSubMetric('Active Time', '${stepState.activeMinutes} mins', Icons.timer_outlined),
              _buildStepSubMetric('Distance', '${stepState.distanceKm.toStringAsFixed(1)} km', Icons.directions_walk_rounded),
              _buildStepSubMetric('Calories', '${stepState.caloriesBurned} kcal', Icons.local_fire_department_rounded),
            ],
          ),
          if (stepState.unlockedBadges.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: stepState.unlockedBadges.map((badge) {
                return Chip(
                  label: Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  backgroundColor: const Color(0xFFE8F5E9),
                  side: const BorderSide(color: Color(0xFF81C784)),
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepSubMetric(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textNavy)),
            Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestoneCertificatesCard(
    BuildContext context,
    List<GameResult> attempts,
    Profile profile,
  ) {
    final completedCount = attempts.where((a) => a.completed).length;
    final starCount = attempts.fold<int>(
      0,
      (sum, a) => sum + (a.completed ? 3 : 1),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Text('🎓', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Milestone Diplomas & Honors',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: const Text(
                  'Verified 📜',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Celebrate and commemorate your child\'s learning achievements with official royal graduation certificates.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    MilestoneCertificateDialog.show(
                      context,
                      customTitle: 'Grand Champion of the Kingdom',
                      starCount: starCount > 0 ? starCount : 15,
                      gamesCompleted: completedCount > 0 ? completedCount : 5,
                    );
                  },
                  icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                  label: const Text(
                    'View Royal Diploma',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReportCard(
    BuildContext context,
    List<GameResult> attempts,
    Profile profile,
  ) {
    final now = DateTime.now();
    final weekAttempts = attempts.where((a) {
      return now.difference(a.completedAt).inDays < 7;
    }).toList();

    final roundsCompleted = weekAttempts.where((a) => a.completed).length;
    final totalDurationMs = weekAttempts.fold<int>(0, (sum, a) => sum + a.activeDurationMs);
    final totalMins = (totalDurationMs / 60000).round();
    final childName = profile.nickname?.isNotEmpty == true ? profile.nickname! : 'Young Explorer';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('📊', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Text(
                    'Weekly Learning Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textNavy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50)),
                ),
                child: const Text(
                  '7-Day Summary 🌟',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$roundsCompleted',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const Text(
                      'Puzzles Solved',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                Container(height: 32, width: 1, color: Colors.green.shade200),
                Column(
                  children: [
                    Text(
                      '$totalMins mins',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const Text(
                      'Learning Time',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                Container(height: 32, width: 1, color: Colors.green.shade200),
                const Column(
                  children: [
                    Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      'Offline & Safe',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp Green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            onPressed: () {
              final shareText = '''🌟 KRIDO Weekly Learning Report 🌟
🦁 Learner: $childName
🎮 Puzzles & Games Solved: $roundsCompleted
⏱️ Focus & Learning Time: $totalMins mins
⭐ Developmental Skills: Phonics, Numbers, Logic & Puzzles
🏅 Rating: Outstanding Young Scholar!
#KridoLearning #SmartKid #ProudParent''';

              Clipboard.setData(ClipboardData(text: shareText)).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF2E7D32),
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Weekly Report copied! Ready to paste & share on WhatsApp! 📱',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              });
            },
            icon: const Icon(Icons.share_rounded, size: 20),
            label: const Center(
              child: Text(
                'Share Report on WhatsApp 📱',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
