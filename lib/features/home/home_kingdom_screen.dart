import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/ads/ad_banner_widget.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/cartoon_ui_components.dart';
import '../../core/widgets/confetti_celebration.dart';
import '../../core/widgets/interactive_floating_island.dart';
import '../../core/widgets/interactive_island_map_view.dart';
import '../../core/widgets/pixar_3d_icons.dart';
import '../../games/registry.dart';
import '../game_shell/game_shell_screen.dart';
import '../mascot/leo_mascot_widget.dart';
import '../parent/parent_dashboard_screen.dart';
import '../parent/parent_gate_dialog.dart';
import '../profile/profile_chooser_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pet/virtual_pet_screen.dart';
import '../stickers/sticker_book_screen.dart';
import '../daily_quest/daily_treasure_chest_dialog.dart';
import '../wardrobe/mascot_wardrobe_dialog.dart';
import '../storybook/interactive_storybook_screen.dart';
import '../world_builder/kingdom_world_builder_screen.dart';
import '../worlds/worlds_screen.dart';

class HomeKingdomScreen extends ConsumerStatefulWidget {
  const HomeKingdomScreen({super.key});

  @override
  ConsumerState<HomeKingdomScreen> createState() => _HomeKingdomScreenState();
}

class _HomeKingdomScreenState extends ConsumerState<HomeKingdomScreen> {
  bool _showCelebrationConfetti = false;

  void _triggerCelebration() {
    setState(() {
      _showCelebrationConfetti = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final locale = profile?.uiLocale ?? 'en';
    final isHindi = locale == 'hi';

    final dailyAdventure = ref.watch(dailyAdventureProvider);
    final petState = ref.watch(virtualPetProvider);
    final audioService = ref.watch(audioServiceProvider);
    final flagshipGames = GameRegistry.getFlagships();

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Stack(
        children: [
          // Cartoon Sky Gradient & Ambient Clouds & Sun
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF81D4FA),
                    Color(0xFFE1F5FE),
                    Color(0xFFFFF9E6),
                  ],
                  stops: [0.0, 0.35, 0.75],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 25,
            right: 85,
            child: CartoonSun(size: 48),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              width: 80,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Profile button / avatar
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(audioServiceProvider).playCue(SoundCue.press);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileChooserScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.cardWhite,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.sky,
                                  child: Text('🦊',
                                      style: TextStyle(fontSize: 20)),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  profile?.displayName ?? 'Adventurer',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textNavy,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down_rounded,
                                    color: AppTheme.purple),
                              ],
                            ),
                          ),
                        ),

                        // Actions: Pet Quick Access + Global Sound Mute Toggle + Parent Gate
                        Row(
                          children: [
                            // Pet Quick Badge
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact().catchError((_) {});
                                ref.read(audioServiceProvider).playCue(SoundCue.bubble);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const VirtualPetScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(petState.stage.emoji, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '🍎 ${petState.treatsAvailable}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quick Audio Mute Toggle
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick().catchError((_) {});
                                audioService.toggleMute();
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.cardWhite,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  audioService.isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  color: audioService.isMuted
                                      ? Colors.grey
                                      : AppTheme.purple,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Parental Controls Gate Button
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact().catchError((_) {});
                                ParentGateDialog.show(
                                  context,
                                  onSuccess: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ParentDashboardScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.cardWhite,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.purple.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shield_rounded,
                                  color: AppTheme.purple,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Welcome Hero Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.purple, Color(0xFF8B68DE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.purple.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isHindi
                                      ? 'नमस्ते, ${profile?.displayName ?? "मित्र"}! 👑'
                                      : 'Hello, ${profile?.displayName ?? "Friend"}! 👑',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isHindi
                                      ? 'आज आप कौन सा नया खेल खेलेंगे?'
                                      : 'What would you like to play today?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text('🏰', style: TextStyle(fontSize: 52)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Interactive Crowned Lion Mascot Leo
                  LeoMascotWidget(locale: locale),

                  const SizedBox(height: 12),

                  // Hero Card: Today's Adventure Quests
                  if (dailyAdventure != null)
                    _buildDailyAdventureCard(
                      context,
                      dailyAdventure: dailyAdventure,
                      isHindi: isHindi,
                      locale: locale,
                    ),

                  const SizedBox(height: 16),

                  // Quick Discovery Ribbon: Wardrobe, Chest, Storybook, World Builder, Xylophone
                  _buildQuickDiscoveryRibbon(context, isHindi),

                  const SizedBox(height: 16),

                  // Photo-Matched Cartoon Flagship Games
                  _buildCartoonFlagshipRow(context, isHindi),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi
                              ? 'पसंदीदा खेल (Featured)'
                              : 'Featured Adventures',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textNavy,
                          ),
                        ),
                        Text(
                          '${flagshipGames.length} Flagships',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 232,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: flagshipGames.length,
                      itemBuilder: (context, index) {
                        final game = flagshipGames[index];
                        final islandColor = Color(game.world.colorValue);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: InteractiveFloatingIsland(
                            islandData: {
                              'id': game.id,
                              'title': game.localizedName(locale),
                              'tag': game.world.name.toUpperCase(),
                              'islandColor': islandColor,
                              'accent': const Color(0xFFFFD54F),
                              'pixarType': _getPixarTypeForGame(game.id),
                              'stars': 3,
                            },
                            index: index,
                            width: 156,
                            height: 226,
                            onTap: () {
                              ref.read(audioServiceProvider).playCue(SoundCue.press);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GameShellScreen(gameId: game.id),
                                ),
                              ).then((_) {
                                ref
                                    .read(dailyAdventureProvider.notifier)
                                    .refresh();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigation Action Cards: Explore Worlds & Sticker Book
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Worlds Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(audioServiceProvider).playCue(SoundCue.press);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WorldsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppTheme.green,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.green.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🌍',
                                      style: TextStyle(fontSize: 36)),
                                  const SizedBox(height: 8),
                                  Text(
                                    isHindi ? '12 दुनिया' : 'Explore Worlds',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '120 Games',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Sticker Book Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(audioServiceProvider).playCue(SoundCue.magic);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StickerBookScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppTheme.sunGold,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.sunGold.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('📚',
                                      style: TextStyle(fontSize: 36)),
                                  const SizedBox(height: 8),
                                  Text(
                                    isHindi ? 'स्टिकर बुक' : 'Sticker Book',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isHindi ? 'उपलब्धियां' : 'Achievements',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textNavy.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Virtual Pet Garden Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VirtualPetScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  petState.stage.emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isHindi ? 'मेरा जादुई पालतू' : 'My Virtual Pet Garden',
                                        style: GoogleFonts.bubblegumSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          isHindi ? petState.stage.nameHi : petState.stage.name,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isHindi
                                        ? '🍎 ${petState.treatsAvailable} स्नैक्स • खिलाने और बड़ा करने के लिए टैप करें!'
                                        : '🍎 ${petState.treatsAvailable} Treats • Tap to feed, care & grow your pet!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom AdMob Test Banner (Child-Directed)
                  const AdBannerWidget(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Confetti celebration overlay on claiming daily reward
          if (_showCelebrationConfetti)
            Positioned.fill(
              child: ConfettiCelebration(
                onComplete: () {
                  setState(() {
                    _showCelebrationConfetti = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyAdventureCard(
    BuildContext context, {
    required dynamic dailyAdventure,
    required bool isHindi,
    required String locale,
  }) {
    final challengeIds = dailyAdventure.challengeIds as List<String>;
    final completionFlags = dailyAdventure.completionFlags as List<bool>;
    final completedCount = completionFlags.where((f) => f).length;
    final totalCount = challengeIds.length;
    final isAllDone = dailyAdventure.isAllCompleted as bool;
    final isRewardClaimed = dailyAdventure.rewardClaimed as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isAllDone ? AppTheme.sunGold : AppTheme.sky.withOpacity(0.5),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isAllDone
                  ? AppTheme.sunGold.withOpacity(0.2)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quest Header Row with interactive treasure chest button
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact().catchError((_) {});
                ref.read(audioServiceProvider).playCue(SoundCue.drumRoll);
                DailyTreasureChestDialog.show(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🎁', style: TextStyle(fontSize: 26)),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'दैनिक साहसिक खजाना' : "Today's Quest & Chest",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textNavy,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAllDone
                                ? AppTheme.green.withOpacity(0.15)
                                : AppTheme.purple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$completedCount / $totalCount ⭐',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isAllDone ? AppTheme.green : AppTheme.purple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppTheme.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Linear Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalCount > 0 ? completedCount / totalCount : 0.0,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isAllDone ? AppTheme.green : AppTheme.sunGold,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Quests List
            ...List.generate(challengeIds.length, (idx) {
              final gId = challengeIds[idx];
              final isDone =
                  idx < completionFlags.length ? completionFlags[idx] : false;
              final game = GameRegistry.getGame(gId);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppTheme.green.withOpacity(0.08)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDone
                        ? AppTheme.green.withOpacity(0.3)
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      game?.world.iconEmoji ?? '🎮',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game?.localizedName(locale) ?? gId,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDone
                                  ? AppTheme.textNavy
                                  : AppTheme.textNavy,
                              decoration: isDone
                                  ? TextDecoration.none
                                  : TextDecoration.none,
                            ),
                          ),
                          Text(
                            game?.world.localizedTitle(locale) ?? 'Adventure',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.green,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          isHindi ? 'पूर्ण ✓' : 'Done ✓',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(audioServiceProvider).playCue(SoundCue.bubble);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameShellScreen(gameId: gId),
                            ),
                          ).then((_) {
                            ref
                                .read(dailyAdventureProvider.notifier)
                                .refresh();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(60, 44),
                        ),
                        child: Text(
                          isHindi ? 'खेलें ▶' : 'Play ▶',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 6),

            // Reward Action / Claimed Notification
            if (isAllDone && !isRewardClaimed)
              GestureDetector(
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  final claimed = await ref
                      .read(dailyAdventureProvider.notifier)
                      .claimReward();
                  if (claimed) {
                    ref
                        .read(audioServiceProvider)
                        .playCue(SoundCue.trumpet);
                    ref
                        .read(audioServiceProvider)
                        .playCue(SoundCue.cheer);
                    ref
                        .read(audioServiceProvider)
                        .playCue(SoundCue.coin);
                    _triggerCelebration();

                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          title: Text(
                            isHindi ? 'बधाई हो! 👑' : 'Quest Conquered! 👑',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textNavy,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 12),
                              Text(
                                isHindi
                                    ? 'आपने आज के तीनों साहसिक कार्य पूरे कर लिए हैं और "राजा का मुकुट" स्टिकर प्राप्त किया है!'
                                    : "You completed all 3 adventures today and unlocked the special King Crown trophy sticker!",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textNavy,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            Center(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.sunGold,
                                  foregroundColor: AppTheme.textNavy,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  isHindi ? 'शानदार!' : 'Hooray!',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.sunGold, Color(0xFFFF9F1A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.sunGold.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        isHindi
                            ? 'दैनिक इनाम प्राप्त करें!'
                            : 'Claim Daily Reward!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (isRewardClaimed)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      isHindi
                          ? 'आज का इनाम प्राप्त किया जा चुका है!'
                          : "Today's Crown claimed! Great job!",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDiscoveryRibbon(BuildContext context, bool isHindi) {
    final items = [
      {
        'emoji': '👑',
        'title': isHindi ? 'लियो का पहनावा' : 'Dress Up Leo',
        'subtitle': isHindi ? 'शाही वार्डरोब' : 'Royal Wardrobe',
        'color': const Color(0xFFFFB300),
        'onTap': () => MascotWardrobeDialog.show(context),
      },
      {
        'emoji': '🎁',
        'title': isHindi ? 'दैनिक खजाना' : 'Daily Chest',
        'subtitle': isHindi ? 'रहस्यमयी संदूक' : 'Mystery Unbox',
        'color': const Color(0xFFFF7043),
        'onTap': () => DailyTreasureChestDialog.show(context),
      },
      {
        'emoji': '📖',
        'title': isHindi ? 'कहानी की किताब' : 'Storybook',
        'subtitle': isHindi ? 'सुनो और पढ़ो' : 'Read-To-Me',
        'color': const Color(0xFFAB47BC),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InteractiveStorybookScreen()),
            ),
      },
      {
        'emoji': '🏰',
        'title': isHindi ? 'वर्ल्ड बिल्डर' : 'World Builder',
        'subtitle': isHindi ? 'स्टिकर सैंडबॉक्स' : 'Sticker Diorama',
        'color': const Color(0xFF26A69A),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const KingdomWorldBuilderScreen()),
            ),
      },
      {
        'emoji': '🎵',
        'title': isHindi ? 'इंद्रधनुषी जाइलोफोन' : 'Rainbow Xylo',
        'subtitle': isHindi ? 'संगीत की धुन' : 'Musical Melodies',
        'color': const Color(0xFF42A5F5),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const GameShellScreen(gameId: 'G080', tier: 1)),
            ),
      },
    ];

    return SizedBox(
      height: 98,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final color = item['color'] as Color;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact().catchError((_) {});
                ref.read(audioServiceProvider).playCue(SoundCue.coin);
                (item['onTap'] as VoidCallback)();
              },
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 148,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: color.withOpacity(0.45), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(item['emoji'] as String,
                        style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textNavy,
                            ),
                          ),
                          Text(
                            item['subtitle'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartoonFlagshipRow(BuildContext context, bool isHindi) {
    final photoGames = [
      {
        'id': 'G001',
        'title': isHindi ? '1-1000 मोज़ेक' : '1-1000 Mosaic',
        'subtitle': isHindi ? '1 से 1000 यात्रा' : '1 to 1000 Journey',
        'emoji': '🔢',
        'pixarType': PixarIconType.mosaic,
        'color': const Color(0xFF1E88E5),
        'borderColor': const Color(0xFFFF5252),
      },
      {
        'id': 'G011',
        'title': isHindi ? 'ABCD सीखें' : 'Learn ABCD',
        'subtitle': isHindi ? 'चित्र और आवाज़' : 'Cards & Phonics SFX',
        'emoji': '🔤',
        'pixarType': PixarIconType.letter,
        'color': const Color(0xFFFFB300),
        'borderColor': const Color(0xFF6A1B9A),
      },
      {
        'id': 'G012',
        'title': isHindi ? 'अल्फा ग्रिड' : 'Alpha Grid',
        'subtitle': 'A-Z Grid Tap',
        'emoji': '🔲',
        'pixarType': PixarIconType.alphaGrid,
        'color': const Color(0xFF1565C0),
        'borderColor': const Color(0xFF69F0AE),
      },
      {
        'id': 'G072',
        'title': isHindi ? 'वर्ड बिल्डर' : 'Word Builder',
        'subtitle': 'Spell CAT, DOG',
        'emoji': '🧱',
        'pixarType': PixarIconType.wordBuilder,
        'color': const Color(0xFF00897B),
        'borderColor': const Color(0xFFFFCA28),
      },
      {
        'id': 'G073',
        'title': isHindi ? 'स्पेलिंग पहेली' : 'Spelling Puzzle',
        'subtitle': 'Word Tiles',
        'emoji': '🧩',
        'pixarType': PixarIconType.spellingPuzzle,
        'color': const Color(0xFFE91E63),
        'borderColor': const Color(0xFFFFEB3B),
      },
      {
        'id': 'G002',
        'title': isHindi ? 'फल गिनें!' : 'Count Fruits!',
        'subtitle': 'Living Orchard',
        'emoji': '🍎',
        'pixarType': PixarIconType.apple,
        'color': const Color(0xFF66BB6A),
        'borderColor': const Color(0xFF2E7D32),
      },
      {
        'id': 'G051',
        'title': isHindi ? 'पशु पहेली' : 'Animal Puzzle!',
        'subtitle': 'Jigsaw Board',
        'emoji': '🐶',
        'pixarType': PixarIconType.doggy,
        'color': const Color(0xFFC89658),
        'borderColor': const Color(0xFF8D5B28),
      },
      {
        'id': 'G031',
        'title': isHindi ? 'आकार मिलान' : 'Shape Match!',
        'subtitle': 'Living Shapes',
        'emoji': '🔺',
        'pixarType': PixarIconType.shapes,
        'color': const Color(0xFF81D4FA),
        'borderColor': const Color(0xFF0288D1),
      },
      {
        'id': 'G041',
        'title': isHindi ? 'जोड़ी मिलान' : 'Memory Match',
        'subtitle': 'Smiling Suns',
        'emoji': '☀️',
        'pixarType': PixarIconType.memory,
        'color': const Color(0xFFAB47BC),
        'borderColor': const Color(0xFF7B1FA2),
      },
      {
        'id': 'G074',
        'title': isHindi ? 'किड गणित' : 'Kid Math',
        'subtitle': 'Count & Add',
        'emoji': '➕',
        'pixarType': PixarIconType.star,
        'color': const Color(0xFF43A047),
        'borderColor': const Color(0xFFFFD54F),
      },
      {
        'id': 'G075',
        'title': isHindi ? 'पैटर्न पथ' : 'Pattern Path',
        'subtitle': 'Sequencing',
        'emoji': '🔷',
        'pixarType': PixarIconType.mosaic,
        'color': const Color(0xFF00ACC1),
        'borderColor': const Color(0xFFFF7043),
      },
      {
        'id': 'G076',
        'title': isHindi ? 'जानवरों की आवाज़' : 'Animal Sounds',
        'subtitle': 'Listen & Find',
        'emoji': '🔊',
        'pixarType': PixarIconType.speaker,
        'color': const Color(0xFFFF7043),
        'borderColor': const Color(0xFF81D4FA),
      },
      {
        'id': 'G077',
        'title': isHindi ? 'जानवर क्विज़' : 'Animal Quiz',
        'subtitle': 'Name The Animal',
        'emoji': '🦁',
        'pixarType': PixarIconType.animalQuiz,
        'color': const Color(0xFFFFA000),
        'borderColor': const Color(0xFF00E5FF),
      },
      {
        'id': 'G080',
        'title': isHindi ? 'इंद्रधनुष जाइलोफोन' : 'Rainbow Xylo',
        'subtitle': 'Musical Chimes',
        'emoji': '🎹',
        'pixarType': PixarIconType.star,
        'color': const Color(0xFFAB47BC),
        'borderColor': const Color(0xFFE91E63),
      },
      {
        'id': 'G081',
        'title': isHindi ? 'रंग छंटाई फैक्ट्री' : 'Sorting Factory',
        'subtitle': 'Colors & Shapes',
        'emoji': '🏭',
        'pixarType': PixarIconType.shapes,
        'color': const Color(0xFF26A69A),
        'borderColor': const Color(0xFF004D40),
      },
      {
        'id': 'G082',
        'title': isHindi ? 'जानवर और उनके घर' : 'Habitat Match',
        'subtitle': 'Kennel, Nest & Sea',
        'emoji': '🐾',
        'pixarType': PixarIconType.animalQuiz,
        'color': const Color(0xFF66BB6A),
        'borderColor': const Color(0xFF1B5E20),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                isHindi ? 'विशेष कार्टून खेल' : 'Photo-Themed Cartoon Games',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textNavy,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: InteractiveIslandMapView(
            islands: photoGames.map((g) {
              return {
                'id': g['id'],
                'title': g['title'],
                'subtitle': g['subtitle'],
                'pixarType': g['pixarType'],
                'tag': (g['subtitle'] as String).toUpperCase(),
                'islandColor': g['color'],
                'accent': g['borderColor'],
                'stars': 3,
              };
            }).toList(),
            isLandscape: true,
            onLaunchGame: (gameId) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameShellScreen(gameId: gameId),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  PixarIconType _getPixarTypeForGame(String id) {
    switch (id) {
      case 'G001':
        return PixarIconType.mosaic;
      case 'G002':
        return PixarIconType.apple;
      case 'G011':
        return PixarIconType.letter;
      case 'G012':
        return PixarIconType.alphaGrid;
      case 'G021':
        return PixarIconType.letter;
      case 'G031':
        return PixarIconType.shapes;
      case 'G041':
        return PixarIconType.memory;
      case 'G051':
        return PixarIconType.doggy;
      case 'G061':
        return PixarIconType.mosaic;
      case 'G072':
        return PixarIconType.wordBuilder;
      case 'G073':
        return PixarIconType.spellingPuzzle;
      case 'G074':
        return PixarIconType.star;
      case 'G075':
        return PixarIconType.mosaic;
      case 'G076':
        return PixarIconType.speaker;
      case 'G077':
        return PixarIconType.animalQuiz;
      case 'G080':
        return PixarIconType.star;
      case 'G081':
        return PixarIconType.shapes;
      case 'G082':
        return PixarIconType.animalQuiz;
      case 'G091':
        return PixarIconType.art;
      default:
        return PixarIconType.star;
    }
  }
}
