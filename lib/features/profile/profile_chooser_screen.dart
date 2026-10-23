import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models/profile.dart';
import '../hub/landscape_learning_hub_screen.dart';

class ProfileChooserScreen extends ConsumerWidget {
  const ProfileChooserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesListProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Who is Playing?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.textNavy,
          ),
        ),
        centerTitle: true,
      ),
      body: profilesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.purple),
        ),
        error: (err, stack) => Center(child: Text('Error loading profiles: $err')),
        data: (profiles) {
          return Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      ...profiles.map((p) {
                        return GestureDetector(
                          onTap: () {
                            ref.read(currentProfileProvider.notifier).selectProfile(p);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LandscapeLearningHubScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardWhite,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppTheme.purple, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppTheme.sky,
                                  child: Text('🦊', style: TextStyle(fontSize: 44)),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  p.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.ageBand.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Add Profile card (capped at 4 profiles per PRD Section 1)
                      if (profiles.length < 4)
                        GestureDetector(
                          onTap: () async {
                            final avatars = ['avatar_fox', 'avatar_panda', 'avatar_bunny', 'avatar_lion'];
                            final newProfile = Profile(
                              id: const Uuid().v4(),
                              nickname: 'Player ${profiles.length + 1}',
                              avatarId: avatars[profiles.length % avatars.length],
                              ageBand: AgeBand.explorer,
                            );
                            await ref.read(currentProfileProvider.notifier).createOrUpdateProfile(newProfile);
                            ref.read(currentProfileProvider.notifier).selectProfile(newProfile);
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LandscapeLearningHubScreen(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 140,
                            height: 160,
                            decoration: BoxDecoration(
                              color: AppTheme.cardWhite.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 48,
                                  color: AppTheme.purple,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add Child',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textNavy,
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
            ),
          );
        },
      ),
    );
  }
}
