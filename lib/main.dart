import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/ads/ad_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter framework errors gracefully and report to DevTools
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Catch asynchronous and platform errors to prevent abrupt app crashing
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('KRIDO Uncaught Async Error: $error');
    return true;
  };

  // Lock all screens to Vertical (Portrait) orientation as requested
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive edge-to-edge mode for kids gaming
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // Render first frame INSTANTLY (< 16ms) without blocking on network or audio synthesis
  runApp(
    const ProviderScope(
      child: KridoApp(),
    ),
  );

  // Asynchronous non-blocking background initialization
  _initServicesAsync();
}

void _initServicesAsync() {
  // Postpone secondary background tasks so UI rendering takes 100% priority
  Future.delayed(const Duration(milliseconds: 1500), () async {
    try {
      await AdService().initialize();
    } catch (_) {}
  });
}
