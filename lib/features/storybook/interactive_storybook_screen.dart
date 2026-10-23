import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../core/audio/procedural_sfx_engine.dart';
import '../../core/widgets/confetti_celebration.dart';

class StoryPageData {
  final int pageNumber;
  final String titleEn;
  final String titleHi;
  final String storyEn;
  final String storyHi;
  final List<String> sentenceListEn;
  final List<String> sentenceListHi;
  final String sceneEmoji;
  final List<Color> bgGradient;

  const StoryPageData({
    required this.pageNumber,
    required this.titleEn,
    required this.titleHi,
    required this.storyEn,
    required this.storyHi,
    required this.sentenceListEn,
    required this.sentenceListHi,
    required this.sceneEmoji,
    required this.bgGradient,
  });
}

class InteractiveStorybookScreen extends ConsumerStatefulWidget {
  const InteractiveStorybookScreen({super.key});

  @override
  ConsumerState<InteractiveStorybookScreen> createState() =>
      _InteractiveStorybookScreenState();
}

class _InteractiveStorybookScreenState
    extends ConsumerState<InteractiveStorybookScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  bool _isAutoReading = false;
  int _highlightedSentenceIndex = 0;
  Timer? _karaokeTimer;
  bool _showConfetti = false;

  final List<StoryPageData> _pages = const [
    StoryPageData(
      pageNumber: 1,
      titleEn: 'The Sunny Kingdom',
      titleHi: 'धूप से चमकता राज्य',
      storyEn:
          'Once upon a time in the Kingdom of Wonder, Prince Leo woke up with a joyful roar! Today was the day of the Great Golden Star Quest.',
      storyHi:
          'एक समय की बात है, अद्भुत राज्य में राजकुमार लियो एक खुशहाल दहाड़ के साथ जागे! आज महान स्वर्ण सितारा खोज का दिन था।',
      sentenceListEn: [
        'Once upon a time in the Kingdom of Wonder,',
        'Prince Leo woke up with a joyful roar!',
        'Today was the day of the Great Golden Star Quest.',
      ],
      sentenceListHi: [
        'एक समय की बात है, अद्भुत राज्य में,',
        'राजकुमार लियो एक खुशहाल दहाड़ के साथ जागे!',
        'आज महान स्वर्ण सितारा खोज का दिन था।',
      ],
      sceneEmoji: '🏰 🦁 ☀️ 🌿',
      bgGradient: [Color(0xFFE0F7FA), Color(0xFFFFF9C4)],
    ),
    StoryPageData(
      pageNumber: 2,
      titleEn: 'The Musical Waterfall',
      titleHi: 'संगीतमय झरना',
      storyEn:
          'At the crystal waterfall, rainbow light danced on the water. "Do, Re, Mi, Fa, Sol!" sang the stones as cool mist sparked with magic.',
      storyHi:
          'क्रिस्टल झरने पर, पानी पर इंद्रधनुषी रोशनी नाच रही थी। "सा, रे, गा, मा, पा!" गाते हुए पत्थरों से जादुई फुहारें उठ रही थीं।',
      sentenceListEn: [
        'At the crystal waterfall, rainbow light danced on the water.',
        '"Do, Re, Mi, Fa, Sol!" sang the stones,',
        'as cool mist sparked with magic.',
      ],
      sentenceListHi: [
        'क्रिस्टल झरने पर, पानी पर इंद्रधनुषी रोशनी नाच रही थी।',
        '"सा, रे, गा, मा, पा!" गाते हुए पत्थरों से,',
        'जादुई फुहारें उठ रही थीं।',
      ],
      sceneEmoji: '🌊 🌈 🎵 💎',
      bgGradient: [Color(0xFFE1F5FE), Color(0xFFD1C4E9)],
    ),
    StoryPageData(
      pageNumber: 3,
      titleEn: 'The Enchanted Orchard',
      titleHi: 'जादुई फलों का बगीचा',
      storyEn:
          'In the orchard, trees glowed with red apples. Leo and the friendly bunnies counted: One, Two, Three delicious apples for everyone!',
      storyHi:
          'बगीचे में पेड़ लाल सेबों से चमक रहे थे। लियो और प्यारे खरगोशों ने गिना: एक, दो, तीन स्वादिष्ट सेब सबके लिए!',
      sentenceListEn: [
        'In the orchard, trees glowed with red apples.',
        'Leo and the friendly bunnies counted together:',
        'One, Two, Three delicious apples for everyone!',
      ],
      sentenceListHi: [
        'बगीचे में पेड़ लाल सेबों से चमक रहे थे।',
        'लियो और प्यारे खरगोशों ने मिलकर गिना:',
        'एक, दो, तीन स्वादिष्ट सेब सबके लिए!',
      ],
      sceneEmoji: '🍎 🌳 🐰 🧺',
      bgGradient: [Color(0xFFE8F5E9), Color(0xFFFFF3E0)],
    ),
    StoryPageData(
      pageNumber: 4,
      titleEn: 'The Balloon Across the Stars',
      titleHi: 'सितारों के पार गुब्बारा',
      storyEn:
          'As twilight fell, a grand hot-air balloon lifted into the purple sky. Leo reached out his paw and caught a shooting star in his hand!',
      storyHi:
          'शाम ढलते ही, एक बड़ा गर्म हवा का गुब्बारा बैंगनी आसमान में उड़ा। लियो ने अपना पंजा बढ़ाया और टूटते तारे को अपनी हथेली में पकड़ लिया!',
      sentenceListEn: [
        'As twilight fell, a grand hot-air balloon lifted into the sky.',
        'Leo reached out his paw with wonder,',
        'and caught a sparkling shooting star in his hand!',
      ],
      sentenceListHi: [
        'शाम ढलते ही, एक बड़ा गुब्बारा आसमान में उड़ा।',
        'लियो ने हैरानी से अपना पंजा बढ़ाया,',
        'और चमकते तारे को अपनी हथेली में पकड़ लिया!',
      ],
      sceneEmoji: '🎈 🌙 ⭐ 🌌',
      bgGradient: [Color(0xFFEDE7F6), Color(0xFFC5CAE9)],
    ),
    StoryPageData(
      pageNumber: 5,
      titleEn: 'The Grand Royal Coronation',
      titleHi: 'भव्य राज्याभिषेक',
      storyEn:
          'Fireworks lit up the sky! Prince Leo smiled proudly and placed a golden crown on YOU. "You are the true Champion of Learning!"',
      storyHi:
          'आतिशबाजी से आसमान जगमगा उठा! राजकुमार लियो ने गर्व से मुस्कुराते हुए आप पर सोने का मुकुट रखा। "आप ही ज्ञान के सच्चे राजा हैं!"',
      sentenceListEn: [
        'Fireworks and sparkles lit up the royal castle sky!',
        'Prince Leo smiled proudly and placed a golden crown on YOU.',
        '"You are the true Champion of the Learning Kingdom!"',
      ],
      sentenceListHi: [
        'आतिशबाजी से शाही महल का आसमान जगमगा उठा!',
        'राजकुमार लियो ने गर्व से मुस्कुराते हुए आप पर मुकुट रखा।',
        '"आप ही ज्ञान के इस राज्य के सच्चे विजेता हैं!"',
      ],
      sceneEmoji: '👑 🏆 🎆 🎉',
      bgGradient: [Color(0xFFFFF9C4), Color(0xFFFFCC80)],
    ),
  ];

  int _autoReadSessionId = 0;

  @override
  void dispose() {
    _autoReadSessionId++;
    ProceduralSfxEngine().stopSpeech();
    _pageController.dispose();
    _karaokeTimer?.cancel();
    super.dispose();
  }

  Future<void> _startAutoRead(bool isHindi) async {
    _karaokeTimer?.cancel();
    ProceduralSfxEngine().stopSpeech();
    _autoReadSessionId++;
    final currentSession = _autoReadSessionId;

    setState(() {
      _isAutoReading = true;
      _highlightedSentenceIndex = 0;
    });

    ProceduralSfxEngine().playChime();

    await _readPageSequentially(_currentPageIndex, isHindi, currentSession);
  }

  Future<void> _readPageSequentially(int pageIdx, bool isHindi, int sessionId) async {
    if (!mounted || !_isAutoReading || _autoReadSessionId != sessionId) return;

    final sentences = isHindi
        ? _pages[pageIdx].sentenceListHi
        : _pages[pageIdx].sentenceListEn;

    for (int i = 0; i < sentences.length; i++) {
      if (!mounted || !_isAutoReading || _autoReadSessionId != sessionId) return;
      if (_currentPageIndex != pageIdx) return;

      setState(() {
        _highlightedSentenceIndex = i;
      });

      // Speak sentence aloud with child-friendly speech engine
      await ProceduralSfxEngine().speakSentence(sentences[i], isHindi: isHindi);

      // Duration estimate for sentence speech pause
      final wordCount = sentences[i].split(' ').length;
      final pauseDurationMs = (wordCount * 450).clamp(2800, 7500);
      await Future.delayed(Duration(milliseconds: pauseDurationMs));
    }

    if (!mounted || !_isAutoReading || _autoReadSessionId != sessionId) return;

    // Check if we reached the final page
    if (pageIdx >= _pages.length - 1) {
      ProceduralSfxEngine().playFanfare();
      ProceduralSfxEngine().playCheer();
      if (mounted) {
        setState(() {
          _isAutoReading = false;
          _showConfetti = true;
        });
      }
    } else {
      // Auto-advance to next page!
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted || !_isAutoReading || _autoReadSessionId != sessionId) return;

      ProceduralSfxEngine().playWhoosh();
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );

      // Continue reading the next page
      await _readPageSequentially(_currentPageIndex, isHindi, sessionId);
    }
  }

  void _stopAutoRead() {
    _autoReadSessionId++;
    _karaokeTimer?.cancel();
    ProceduralSfxEngine().stopSpeech();
    setState(() {
      _isAutoReading = false;
    });
  }

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      HapticFeedback.lightImpact().catchError((_) {});
      ProceduralSfxEngine().playWhoosh();
      _stopAutoRead();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentPageIndex > 0) {
      HapticFeedback.lightImpact().catchError((_) {});
      ProceduralSfxEngine().playWhoosh();
      _stopAutoRead();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final locale = profile?.uiLocale ?? 'en';
    final isHindi = locale == 'hi';

    return Scaffold(
      body: Stack(
        children: [
          // 1. PageView Illustrated Book
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (idx) {
              setState(() {
                _currentPageIndex = idx;
                _highlightedSentenceIndex = 0;
              });
              _stopAutoRead();
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              final sentences =
                  isHindi ? page.sentenceListHi : page.sentenceListEn;

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: page.bgGradient,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 54),

                        // Page Number Ribbon
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFFFB300), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            '${isHindi ? "पृष्ठ" : "Page"} ${page.pageNumber} / ${_pages.length}',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5D4037),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Chapter Title
                        Text(
                          isHindi ? page.titleHi : page.titleEn,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3E2723),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Interactive Illustrated Centerpiece
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick().catchError((_) {});
                              ProceduralSfxEngine().playMagic();
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  page.sceneEmoji,
                                  style: const TextStyle(
                                    fontSize: 56,
                                    letterSpacing: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Story Text Box with Karaoke Sentences
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: const Color(0xFFFFD54F), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(sentences.length, (sIdx) {
                                  final isHighlight =
                                      _isAutoReading &&
                                          sIdx == _highlightedSentenceIndex;

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: GestureDetector(
                                      onTap: () {
                                        ProceduralSfxEngine().playPop();
                                        ProceduralSfxEngine().speakSentence(sentences[sIdx], isHindi: isHindi);
                                        setState(() {
                                          _highlightedSentenceIndex = sIdx;
                                        });
                                      },
                                      child: AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        style: GoogleFonts.bubblegumSans(
                                          fontSize: isHighlight ? 20 : 18,
                                          fontWeight: isHighlight
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isHighlight
                                              ? const Color(0xFFD84315)
                                              : const Color(0xFF37474F),
                                          backgroundColor: isHighlight
                                              ? const Color(0xFFFFF9C4)
                                              : Colors.transparent,
                                        ),
                                        textAlign: TextAlign.center,
                                        child: Text(sentences[sIdx]),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Navigation Buttons Row
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Prev Button
                              IconButton(
                                onPressed: _currentPageIndex > 0 ? _prevPage : null,
                                icon: const Icon(Icons.arrow_back_ios_rounded,
                                    size: 28),
                                color: const Color(0xFF5D4037),
                              ),

                              // Read To Me Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_isAutoReading) {
                                    _stopAutoRead();
                                  } else {
                                    _startAutoRead(isHindi);
                                  }
                                },
                                icon: Icon(
                                  _isAutoReading
                                      ? Icons.pause_rounded
                                      : Icons.record_voice_over_rounded,
                                  size: 22,
                                ),
                                label: Text(
                                  _isAutoReading
                                      ? (isHindi ? 'रोकें' : 'Pause')
                                      : (isHindi
                                          ? 'मुझे पढ़कर सुनाओ 🔊'
                                          : 'Read To Me 🔊'),
                                  style: GoogleFonts.bubblegumSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isAutoReading
                                      ? const Color(0xFFE91E63)
                                      : const Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                              ),

                              // Next Button
                              IconButton(
                                onPressed: _currentPageIndex < _pages.length - 1
                                    ? _nextPage
                                    : null,
                                icon: const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 28),
                                color: const Color(0xFF5D4037),
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

          // 2. Top Bar Back Button
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Color(0xFF37474F), size: 26),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // 3. Victory Confetti
          if (_showConfetti) const ConfettiCelebration(),
        ],
      ),
    );
  }
}
