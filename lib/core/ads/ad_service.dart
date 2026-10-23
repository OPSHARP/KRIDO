import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends ChangeNotifier {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool _bannerEnabled = true;
  bool get isInitialized => _isInitialized;
  bool get bannerEnabled => _bannerEnabled;

  // Google AdMob Unit IDs
  // For production, replace with your own AdMob IDs via --dart-define or env config.
  // Below are Google's official TEST ad unit IDs (safe for public repos).
  static const String liveAppId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713', // Google test app ID
  );
  static const String liveBannerId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // Google test banner
  );
  static const String liveRewardedId = String.fromEnvironment(
    'ADMOB_REWARDED_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917', // Google test rewarded
  );
  static const String liveNativeAdvancedId = String.fromEnvironment(
    'ADMOB_NATIVE_ID',
    defaultValue: 'ca-app-pub-3940256099942544/2247696110', // Google test native
  );

  static bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String get bannerAdUnitId => liveBannerId;
  static String get rewardedAdUnitId => liveRewardedId;
  static String get nativeAdvancedAdUnitId => liveNativeAdvancedId;

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!isSupportedPlatform) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      // Set age-restricted treatment to child-directed using AgeRestrictedTreatment.child
      // before initializing the Mobile Ads SDK. Complies with Google Play Families & COPPA.
      final requestConfig = RequestConfiguration(
        ageRestrictedTreatment: AgeRestrictedTreatment.child,
        maxAdContentRating: MaxAdContentRating.g,
      );
      await MobileAds.instance.updateRequestConfiguration(requestConfig);
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (_) {
      _isInitialized = true; // Still allow app flow without breaking
    }
    notifyListeners();
  }

  void setBannerEnabled(bool enabled) {
    if (_bannerEnabled != enabled) {
      _bannerEnabled = enabled;
      notifyListeners();
    }
  }

  /// Generates a strictly child-directed, COPPA and Google Play Families compliant AdRequest
  static AdRequest createChildDirectedAdRequest() {
    return const AdRequest(
      nonPersonalizedAds: true,
    );
  }

  /// Load and present a live rewarded ad (e.g. for unlocking a bonus sticker in Parent Area)
  void showRewardedAd({
    required Function(int amount, String type) onRewarded,
    VoidCallback? onFailed,
  }) {
    if (!isSupportedPlatform) {
      onRewarded(1, 'bonus_sticker');
      return;
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: createChildDirectedAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onFailed?.call();
            },
          );
          ad.show(
            onUserEarnedReward: (adWithoutView, reward) {
              onRewarded(reward.amount.toInt(), reward.type);
            },
          );
        },
        onAdFailedToLoad: (error) {
          onFailed?.call();
        },
      ),
    );
  }

  /// Backward-compatible alias for existing callers
  void showRewardedTestAd({
    required Function(int amount, String type) onRewarded,
    VoidCallback? onFailed,
  }) => showRewardedAd(onRewarded: onRewarded, onFailed: onFailed);
}
