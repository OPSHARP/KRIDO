import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/audio/audio_service.dart';
import '../../core/curriculum/age_curriculum_service.dart';

class ParentSettingsScreen extends ConsumerStatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  ConsumerState<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends ConsumerState<ParentSettingsScreen> {
  final _pinController = TextEditingController();
  bool _bedtimeMode = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _showChangePinDialog() {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Change Parent PIN', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New 4-Digit PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_pinController.text.length == 4) {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                final gate = ref.read(parentGateServiceProvider);
                await gate.updatePin(_pinController.text);
                if (mounted) {
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('PIN updated successfully!')),
                  );
                }
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProfile() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Active Profile?'),
        content: const Text(
          'This will permanently delete progress and sticker records for this child profile. Other profiles will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(currentProfileProvider.notifier).deleteCurrentProfile();
              if (mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: const Text('Delete Profile'),
          ),
        ],
      ),
    );
  }

  void _confirmFactoryReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Full App Data Reset'),
        content: const Text(
          'WARNING: This will erase all local child profiles, progress, and settings. The app will return to initial setup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(databaseProvider).fullFactoryReset();
              if (mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioServiceProvider);
    final sessionTimer = ref.watch(sessionTimerServiceProvider);
    final adService = ref.watch(adServiceProvider);

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
          'Parent Controls & Safety',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.textNavy,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section 1: Screen Time & Breaks
          _buildSectionHeader('Session & Screen Time Limit'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current limit: ${sessionTimer.limitMinutes == 0 ? "Unlimited" : "${sessionTimer.limitMinutes} minutes"}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: [5, 10, 15, 20, 0].map((mins) {
                    final isSelected = sessionTimer.limitMinutes == mins;
                    return ChoiceChip(
                      label: Text(mins == 0 ? 'No limit' : '$mins min'),
                      selected: isSelected,
                      selectedColor: AppTheme.sunGold,
                      onSelected: (_) {
                        sessionTimer.setLimitMinutes(mins);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Age Bracket Curriculum Preset
          _buildSectionHeader('Age Curriculum Preset'),
          _buildCurriculumPresetSelector(ref),

          const SizedBox(height: 24),

          // Section 2: Audio Multi-Bus Settings
          _buildSectionHeader('Audio Volume Controls'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildSlider(
                  'Master Volume',
                  audio.masterVolume,
                  (val) => audio.setVolume(AudioBus.master, val),
                ),
                _buildSlider(
                  'Background Music',
                  audio.musicVolume,
                  (val) => audio.setVolume(AudioBus.music, val),
                ),
                _buildSlider(
                  'Sound Effects',
                  audio.sfxVolume,
                  (val) => audio.setVolume(AudioBus.sfx, val),
                ),
                _buildSlider(
                  'Voice / Narration',
                  audio.narrationVolume,
                  (val) => audio.setVolume(AudioBus.narration, val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Bedtime Wind-Down Mode
          _buildSectionHeader('Bedtime & Sensory Care'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Text('🌙', style: TextStyle(fontSize: 24)),
                  title: const Text(
                    'Bedtime Wind-Down Mode',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Softens audio levels and tones down stimulation for calm evening play',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _bedtimeMode,
                  activeColor: AppTheme.purple,
                  onChanged: (val) {
                    setState(() {
                      _bedtimeMode = val;
                    });
                    if (val) {
                      audio.setVolume(AudioBus.master, 0.35);
                      audio.setVolume(AudioBus.sfx, 0.30);
                      audio.setVolume(AudioBus.music, 0.20);
                    } else {
                      audio.setVolume(AudioBus.master, 0.70);
                      audio.setVolume(AudioBus.sfx, 0.55);
                      audio.setVolume(AudioBus.music, 0.25);
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Text('🧸', style: TextStyle(fontSize: 24)),
                  title: const Text(
                    'Toddler / Gentle Sound Mode',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Soft acoustic chimes without loud buzzers, ideal for toddlers & sensitive ears',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: audio.isGentleMode,
                  activeColor: AppTheme.purple,
                  onChanged: (val) {
                    audio.setGentleMode(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 4: Child-Directed Ads Controls
          _buildSectionHeader('Child-Friendly Ads (Family Policy Compliant)'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Text('🏷️', style: TextStyle(fontSize: 24)),
                  title: const Text(
                    'Display Child-Friendly Banner Ads',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Show G-rated, child-directed banner ads on Home screen',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: adService.bannerEnabled,
                  activeColor: AppTheme.purple,
                  onChanged: (val) {
                    adService.setBannerEnabled(val);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('🎁', style: TextStyle(fontSize: 24)),
                  title: const Text(
                    'Unlock Bonus Sticker',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Watch a child-directed video to earn a bonus sticker',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.play_circle_fill_rounded,
                      color: AppTheme.purple, size: 28),
                  onTap: () {
                    final messenger = ScaffoldMessenger.of(context);
                    adService.showRewardedAd(
                      onRewarded: (amount, type) async {
                        final profile = ref.read(currentProfileProvider);
                        if (profile != null) {
                          final db = ref.read(databaseProvider);
                          await db.unlockSticker(
                            profileId: profile.id,
                            stickerId: 'stk_balloon',
                            sourceCompletionId: 'rewarded_ad_bonus',
                          );
                        }
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '🎉 Bonus Balloon sticker unlocked!'),
                            ),
                          );
                        }
                      },
                      onFailed: () {
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Ad is currently unavailable. Please check your connection.'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 5: Parent PIN
          _buildSectionHeader('Security & PIN'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.lock_rounded, color: AppTheme.purple),
              title: const Text('Change Parent PIN', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Update the 4-digit PIN protecting parental controls'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: _showChangePinDialog,
            ),
          ),

          const SizedBox(height: 24),

          // Section 4: Privacy & Offline Policy
          _buildSectionHeader('Child Safety & Privacy'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppTheme.green, size: 22),
                    SizedBox(width: 8),
                    Text(
                      '100% Offline & Private',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'KRIDO operates completely on-device. No child personal data, location, audio recordings, or telemetry are collected or transmitted to external servers. Full compliance with COPPA and Google Play Families Policy.',
                  style: TextStyle(fontSize: 13, height: 1.45, color: AppTheme.textNavy),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_rounded, size: 18, color: AppTheme.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Developer: drillmovies@gmail.com',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.purple,
                      side: const BorderSide(color: AppTheme.purple, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                    label: const Text('Read Full Privacy Policy', style: TextStyle(fontWeight: FontWeight.w800)),
                    onPressed: _showFullPrivacyPolicyDialog,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 5: Reset actions
          _buildSectionHeader('Data Management'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_remove_rounded, color: Colors.orange),
                  title: const Text('Delete Active Profile', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Erases progress for current child profile'),
                  onTap: _confirmDeleteProfile,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Full App Reset', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
                  subtitle: const Text('Wipes all profiles and resets app to factory setup'),
                  onTap: _confirmFactoryReset,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: AppTheme.textNavy,
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            activeColor: AppTheme.purple,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${(value * 100).round()}%',
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildCurriculumPresetSelector(WidgetRef ref) {
    final currentPreset = ref.watch(curriculumPresetProvider);
    final locale = ref.watch(currentProfileProvider)?.uiLocale ?? 'en';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.purple.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        children: CurriculumPreset.values.map((preset) {
          final isSelected = preset == currentPreset;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () {
                ref.read(curriculumPresetProvider.notifier).setPreset(preset);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.purple.withOpacity(0.08)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.purple
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(preset.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.title(locale),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? AppTheme.purple : AppTheme.textNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preset.subtitle(locale),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<CurriculumPreset>(
                      value: preset,
                      groupValue: currentPreset,
                      activeColor: AppTheme.purple,
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(curriculumPresetProvider.notifier).setPreset(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFullPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.privacy_tip_rounded, color: AppTheme.purple, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppTheme.textNavy),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'KRIDO - Kids Early Learning & Play',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.purple),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Last Updated: October 2026\nDeveloper Email: drillmovies@gmail.com',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'OUR PRIVACY COMMITMENT',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textNavy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'KRIDO is designed from the ground up to protect children and provide a completely safe, private learning environment. We do not collect, transmit, store, or sell any personal information from children or parents.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '100% ON-DEVICE OFFLINE EXPERIENCE',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textNavy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'All gameplay, progress milestones, sticker collections, and audio synthesize entirely on your local device. The application does not require internet connectivity for educational activities.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CHILDREN’S PRIVACY & COPPA COMPLIANCE',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textNavy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'We strictly adhere to the Children’s Online Privacy Protection Act (COPPA), GDPR-K, and Google Play Families Policy. We do not gather names, email addresses, precise geolocation, device identifiers, or microphone recordings.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'NO ADS & NO TRACKERS',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textNavy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'KRIDO contains zero behavioral advertising, zero marketing trackers, and zero analytics SDKs that profile your child.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PARENTAL CONTROLS',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textNavy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'All settings, daily play curfews, session timers, and profile resets are shielded behind a parent PIN gate to ensure children remain inside safe learning bounds.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'DEVELOPER CONTACT',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textNavy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'For any questions or feedback regarding this policy or child data safety, please contact us directly at:\ndrillmovies@gmail.com',
                    style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }
}
