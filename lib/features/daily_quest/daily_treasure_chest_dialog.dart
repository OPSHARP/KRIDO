import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/widgets/confetti_celebration.dart';
import '../../domain/models/daily_adventure.dart';
import '../../core/session/learning_streak_service.dart';
import '../../games/registry.dart';
import '../game_shell/game_shell_screen.dart';

class DailyTreasureChestDialog extends ConsumerStatefulWidget {
  const DailyTreasureChestDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const DailyTreasureChestDialog(),
    );
  }

  @override
  ConsumerState<DailyTreasureChestDialog> createState() =>
      _DailyTreasureChestDialogState();
}

class _DailyTreasureChestDialogState
    extends ConsumerState<DailyTreasureChestDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _wobbleController;
  bool _isOpening = false;
  bool _showRewardAnimation = false;

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  Future<void> _claimTreasure(DailyAdventure adventure) async {
    if (_isOpening || adventure.rewardClaimed || !adventure.isAllCompleted) {
      return;
    }

    setState(() {
      _isOpening = true;
    });

    HapticFeedback.heavyImpact().catchError((_) {});
    ProceduralSfxEngine().playDrumRoll();
    await Future.delayed(const Duration(milliseconds: 320));
    ProceduralSfxEngine().playTrumpet();
    ProceduralSfxEngine().playCheer();
    ProceduralSfxEngine().playCoin();

    // Award +3 pet treats
    final petNotifier = ref.read(virtualPetProvider.notifier);
    petNotifier.awardModuleCompletion();
    petNotifier.awardModuleCompletion();
    petNotifier.awardModuleCompletion();

    // Claim daily reward sticker
    await ref.read(dailyAdventureProvider.notifier).claimReward();

    if (mounted) {
      setState(() {
        _isOpening = false;
        _showRewardAnimation = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adventure = ref.watch(dailyAdventureProvider);
    final locale = ref.watch(currentProfileProvider)?.uiLocale ?? 'en';
    final isHindi = locale == 'hi';

    if (adventure == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isReadyToClaim =
        adventure.isAllCompleted && !adventure.rewardClaimed;
    final isClaimed = adventure.rewardClaimed;
    final completedCount =
        adventure.completionFlags.where((f) => f).length;
    final totalCount = adventure.challengeIds.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Card
          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF9E6), Color(0xFFFFF0B3)],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFFB300), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎁', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 8),
                            Text(
                              isHindi
                                  ? 'दैनिक रहस्यमयी खजाना'
                                  : 'Daily Mystery Chest',
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5D4037),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF795548), size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Animated Chest Centerpiece
                GestureDetector(
                  onTap: () {
                    if (isReadyToClaim) {
                      _claimTreasure(adventure);
                    } else if (!isClaimed) {
                      HapticFeedback.lightImpact().catchError((_) {});
                      ProceduralSfxEngine().playBoing();
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _wobbleController,
                    builder: (context, child) {
                      final wobble = isReadyToClaim
                          ? math.sin(_wobbleController.value * math.pi * 2) *
                              0.06
                          : 0.0;
                      final scale = isReadyToClaim
                          ? 1.0 + (_wobbleController.value * 0.08)
                          : 1.0;

                      return Transform.scale(
                        scale: scale,
                        child: Transform.rotate(
                          angle: wobble,
                          child: Container(
                            height: 130,
                            width: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  isReadyToClaim
                                      ? const Color(0xFFFFE082)
                                      : const Color(0xFFFFF3E0),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isClaimed
                                    ? '💎'
                                    : (isReadyToClaim ? '📦✨' : '🔒'),
                                style: TextStyle(
                                  fontSize: isClaimed ? 72 : 68,
                                  shadows: isReadyToClaim
                                      ? [
                                          const Shadow(
                                            color: Color(0xFFFFD54F),
                                            blurRadius: 24,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Status Message
                if (isReadyToClaim)
                  ElevatedButton.icon(
                    onPressed: () => _claimTreasure(adventure),
                    icon: const Icon(Icons.touch_app_rounded, size: 20),
                    label: Text(
                      isHindi ? 'खजाना खोलें! ✨' : 'Tap to Open Chest! ✨',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9100),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  )
                else if (isClaimed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isHindi
                          ? '🎉 आज का खजाना मिल चुका है! कल फिर आएं!'
                          : '🎉 Today\'s Chest Claimed! Come back tomorrow!',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  )
                else
                  Text(
                    isHindi
                        ? 'तीनों खेल पूरे करें और खजाना अनलॉक करें ($completedCount / $totalCount)'
                        : 'Complete all 3 quests to unlock! ($completedCount / $totalCount)',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 15,
                      color: const Color(0xFF8D6E63),
                    ),
                  ),

                const SizedBox(height: 14),

                // Daily Learning Streak Flame Meter
                _buildStreakCard(ref.watch(learningStreakProvider), isHindi),

                const SizedBox(height: 14),

                // Quest Steps List
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFFE082), width: 1.5),
                  ),
                  child: Column(
                    children: List.generate(adventure.challengeIds.length, (idx) {
                      final gId = adventure.challengeIds[idx];
                      final isDone = idx < adventure.completionFlags.length &&
                          adventure.completionFlags[idx];
                      final game = GameRegistry.getGame(gId);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              game?.world.iconEmoji ?? '🎯',
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ((locale == 'hi' ? game?.nameHi : game?.nameEn) ??
                                    'Quest ${idx + 1}'),
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDone
                                      ? const Color(0xFF388E3C)
                                      : const Color(0xFF424242),
                                  decoration:
                                      isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            if (isDone)
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF4CAF50), size: 24)
                            else
                              SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact()
                                        .catchError((_) {});
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            GameShellScreen(gameId: gId),
                                      ),
                                    ).then((_) {
                                      ref
                                          .read(dailyAdventureProvider.notifier)
                                          .refresh();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C4DFF),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isHindi ? 'खेलें' : 'Play',
                                    style: GoogleFonts.bubblegumSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),

          // Unboxing Celebration Overlay
          if (_showRewardAnimation) ...[
            const ConfettiCelebration(),
            Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFFFB300), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.35),
                    blurRadius: 36,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👑 ⭐ 🏆', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 8),
                    Text(
                      isHindi ? 'खजाना खुल गया!' : 'Treasure Unlocked!',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isHindi
                          ? 'आपको मिला एक चमचमाता ट्रॉफी स्टिकर और +3 पेट ट्रीट्स! 🍗🍎🧁'
                          : 'You earned a Golden Trophy Sticker & +3 Pet Treats! 🍗🍎🧁',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 16,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showRewardAnimation = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                      ),
                      child: Text(
                        isHindi ? 'शानदार!' : 'Awesome!',
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakCard(LearningStreakState streak, bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9800), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Text(
                isHindi
                    ? '${streak.currentStreak}-दिनों की लर्निंग स्ट्रीक!'
                    : '${streak.currentStreak}-Day Learning Streak!',
                style: GoogleFonts.bubblegumSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Day 3 Milestone
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: streak.isDay3Unlocked ? Colors.white : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: streak.isDay3Unlocked ? const Color(0xFFFFB300) : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        streak.day3RewardClaimed ? '⭐ Claimed' : '🥉 3-Day Bonus',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHindi ? '+5 पेट ट्रीट' : '+5 Treats',
                        style: const TextStyle(fontSize: 11, color: Colors.brown),
                      ),
                      if (streak.isDay3Unlocked && !streak.day3RewardClaimed)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: InkWell(
                            onTap: () async {
                              final claimed = await ref.read(learningStreakProvider.notifier).claimMilestoneReward(3);
                              if (claimed) {
                                ProceduralSfxEngine().playCheer();
                                ProceduralSfxEngine().playCoin();
                                for (int i = 0; i < 5; i++) {
                                  ref.read(virtualPetProvider.notifier).awardModuleCompletion();
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Claim 🎁', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Day 7 Milestone
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: streak.isDay7Unlocked ? Colors.white : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: streak.isDay7Unlocked ? const Color(0xFFFFB300) : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        streak.day7RewardClaimed ? '👑 Claimed' : '🥇 7-Day Royal',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHindi ? 'रॉयल क्राउन' : 'Royal Crown',
                        style: const TextStyle(fontSize: 11, color: Colors.brown),
                      ),
                      if (streak.isDay7Unlocked && !streak.day7RewardClaimed)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: InkWell(
                            onTap: () async {
                              final claimed = await ref.read(learningStreakProvider.notifier).claimMilestoneReward(7);
                              if (claimed) {
                                ProceduralSfxEngine().playTrumpet();
                                ProceduralSfxEngine().playCheer();
                                for (int i = 0; i < 10; i++) {
                                  ref.read(virtualPetProvider.notifier).awardModuleCompletion();
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Claim 👑', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
