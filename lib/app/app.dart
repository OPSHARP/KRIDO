import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/audio/procedural_sfx_engine.dart';
import '../features/break/break_screen.dart';
import '../features/splash/splash_screen.dart';
import 'providers.dart';
import 'theme.dart';

class KridoApp extends ConsumerStatefulWidget {
  const KridoApp({super.key});

  @override
  ConsumerState<KridoApp> createState() => _KridoAppState();
}

class _KridoAppState extends ConsumerState<KridoApp>
    with WidgetsBindingObserver {
  Timer? _bgmTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start gentle looping background music once UI frame is drawn and navigation settles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bgmTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          ref.read(audioServiceProvider).startBackgroundMusic();
        }
      });
    });
  }

  @override
  void dispose() {
    _bgmTimer?.cancel();
    _bgmTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(audioServiceProvider).pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(audioServiceProvider).resumeBackgroundMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionTimer = ref.watch(sessionTimerServiceProvider);

    return MaterialApp(
      title: 'KRIDO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            ProceduralSfxEngine().playPop();
          },
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              if (sessionTimer.isBreakTime)
                const Positioned.fill(child: BreakScreen()),
            ],
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
