import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models/profile.dart';
import '../hub/landscape_learning_hub_screen.dart';
import '../profile/profile_chooser_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();

    // Redundant fail-safe timer: unconditionally transitions to the hub after 1.4s
    _safetyTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!_hasNavigated && mounted) {
        debugPrint('SplashScreen: Safety timeout reached, navigating to Hub.');
        _ensureProfileAndNavigate();
      }
    });

    _checkInitialNavigation();
  }

  void _safeNavigate(Widget targetScreen) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _safetyTimer?.cancel();
    _safetyTimer = null;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _ensureProfileAndNavigate() {
    try {
      final current = ref.read(currentProfileProvider);
      if (current == null) {
        final fallbackProfile = Profile(
          id: const Uuid().v4(),
          avatarId: 'avatar_lion',
          nickname: 'Little King',
          ageBand: AgeBand.explorer,
          uiLocale: 'en',
        );
        ref.read(currentProfileProvider.notifier).selectProfile(fallbackProfile);
      }
    } catch (e) {
      debugPrint('SplashScreen: Fallback profile selection note: $e');
    }
    _safeNavigate(const LandscapeLearningHubScreen());
  }

  Future<void> _checkInitialNavigation() async {
    try {
      // Allow the opening brand animation to play smoothly
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted || _hasNavigated) return;

      final db = ref.read(databaseProvider);
      final profiles = await db.getProfiles();

      if (!mounted || _hasNavigated) return;

      if (profiles.isEmpty) {
        // Auto-provision default kid profile - zero passcode / parent gate on launch
        final defaultProfile = Profile(
          id: const Uuid().v4(),
          avatarId: 'avatar_lion',
          nickname: 'Little King',
          ageBand: AgeBand.explorer,
          uiLocale: 'en',
        );
        try {
          await db.saveProfile(defaultProfile);
        } catch (_) {}

        if (!mounted || _hasNavigated) return;
        ref.read(currentProfileProvider.notifier).selectProfile(defaultProfile);
        _safeNavigate(const LandscapeLearningHubScreen());
      } else if (profiles.length == 1) {
        ref.read(currentProfileProvider.notifier).selectProfile(profiles.first);
        _safeNavigate(const LandscapeLearningHubScreen());
      } else {
        _safeNavigate(const ProfileChooserScreen());
      }
    } catch (e, stack) {
      debugPrint('SplashScreen: Navigation exception handled: $e\n$stack');
      if (!mounted || _hasNavigated) return;
      _ensureProfileAndNavigate();
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _safetyTimer = null;
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_hasNavigated) {
          _ensureProfileAndNavigate();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.sky,
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('👑', style: TextStyle(fontSize: 74)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'KRIDO',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.sunGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Play • Learn • Discover',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
