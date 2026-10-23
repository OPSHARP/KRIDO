import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models/profile.dart';
import '../home/home_kingdom_screen.dart';

class ParentSetupScreen extends ConsumerStatefulWidget {
  const ParentSetupScreen({super.key});

  @override
  ConsumerState<ParentSetupScreen> createState() => _ParentSetupScreenState();
}

class _ParentSetupScreenState extends ConsumerState<ParentSetupScreen> {
  final _nicknameController = TextEditingController();
  final _pinController = TextEditingController(text: '1234');
  String _selectedLocale = 'en';
  AgeBand _selectedAgeBand = AgeBand.builder;
  String _selectedAvatar = 'avatar_fox';

  final List<Map<String, String>> _avatarChoices = [
    {'id': 'avatar_fox', 'emoji': '🦊'},
    {'id': 'avatar_lion', 'emoji': '🦁'},
    {'id': 'avatar_bear', 'emoji': '🐻'},
    {'id': 'avatar_rabbit', 'emoji': '🐰'},
    {'id': 'avatar_panda', 'emoji': '🐼'},
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitSetup() async {
    final profile = Profile(
      id: const Uuid().v4(),
      avatarId: _selectedAvatar,
      nickname: _nicknameController.text.trim(),
      ageBand: _selectedAgeBand,
      uiLocale: _selectedLocale,
    );

    // Save profile to database
    await ref.read(currentProfileProvider.notifier).createOrUpdateProfile(profile);

    // Save parent PIN if changed
    if (_pinController.text.length == 4) {
      await ref.read(parentGateServiceProvider).updatePin(_pinController.text);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeKingdomScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Parent Setup',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.textNavy,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Text('👋', style: TextStyle(fontSize: 36)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Welcome! Let\'s customize a cheerful, safe learning experience for your child.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textNavy,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 1. Language Choice
            const Text(
              'Primary Language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('English (US/UK)'),
                    selected: _selectedLocale == 'en',
                    selectedColor: AppTheme.sunGold,
                    onSelected: (_) => setState(() => _selectedLocale = 'en'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('हिन्दी (Hindi)'),
                    selected: _selectedLocale == 'hi',
                    selectedColor: AppTheme.sunGold,
                    onSelected: (_) => setState(() => _selectedLocale = 'hi'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Avatar Selection
            const Text(
              'Choose an Avatar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _avatarChoices.map((av) {
                final isSelected = _selectedAvatar == av['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = av['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.sunGold : AppTheme.cardWhite,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey.shade300,
                        width: isSelected ? 3 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(av['emoji']!, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 3. Child Nickname (Optional)
            const Text(
              'Child\'s Nickname (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: 'e.g. Leo, Tara, Sunny',
                filled: true,
                fillColor: AppTheme.cardWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4. Age Band Recommendation
            const Text(
              'Age Band',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
            ),
            const SizedBox(height: 8),
            Column(
              children: AgeBand.values.map((band) {
                return RadioListTile<AgeBand>(
                  value: band,
                  groupValue: _selectedAgeBand,
                  activeColor: AppTheme.purple,
                  title: Text(band.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  tileColor: AppTheme.cardWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAgeBand = val);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 5. Parent PIN
            const Text(
              'Parent Gate PIN (4 digits)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '1234',
                filled: true,
                fillColor: AppTheme.cardWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Start Adventure Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitSetup,
                icon: const Icon(Icons.rocket_launch_rounded, size: 28),
                label: const Text(
                  'Enter KRIDO!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
