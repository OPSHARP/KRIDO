import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final AdService _adService = AdService();
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _initBanner();
  }

  Future<void> _initBanner() async {
    if (!AdService.isSupportedPlatform) return;

    try {
      if (!_adService.isInitialized) {
        await _adService.initialize();
      }
      if (!mounted) return;

      _bannerAd?.dispose();
      _bannerAd = null;

      _bannerAd = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: AdSize.banner,
        request: AdService.createChildDirectedAdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
            if (mounted) {
              setState(() {
                _isLoaded = false;
              });
              // Auto retry after 15 seconds
              _retryTimer?.cancel();
              _retryTimer = Timer(const Duration(seconds: 15), () {
                if (mounted && !_isLoaded) {
                  _initBanner();
                }
              });
            }
          },
        ),
      );

      await _bannerAd?.load();
    } catch (_) {}
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _adService,
      builder: (context, _) {
        if (!_adService.bannerEnabled) {
          return const SizedBox.shrink();
        }

        // On real mobile devices with loaded AdMob banner:
        if (AdService.isSupportedPlatform && _isLoaded && _bannerAd != null) {
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          );
        }

        // If banner is loading or failed, return empty box - never show test/mock ads
        return const SizedBox.shrink();
      },
    );
  }
}
