import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models/game_definition.dart';
import '../../games/registry.dart';
import '../game_shell/game_shell_screen.dart';

class GameShelfScreen extends ConsumerWidget {
  final WorldType world;

  const GameShelfScreen({super.key, required this.world});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final locale = profile?.uiLocale ?? 'en';
    final games = GameRegistry.getByWorld(world);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.purple, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          world.localizedTitle(locale),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textNavy,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: game.isFlagship
                    ? AppTheme.sunGold
                    : Colors.grey.shade200,
                width: game.isFlagship ? 2.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(world.colorValue).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    world.iconEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      game.localizedName(locale),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textNavy,
                      ),
                    ),
                  ),
                  if (game.isFlagship)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.sunGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '⭐ Flagship',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textNavy,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.localizedSummary(locale),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${game.id} • Ages ${game.minAge}-${game.maxAge}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: game.isPlayable ? AppTheme.green : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameShellScreen(gameId: game.id),
                    ),
                  );
                },
                child: Text(
                  game.isPlayable ? 'Play' : 'Play',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
