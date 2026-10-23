import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/procedural_sfx_engine.dart';
import '../../../core/widgets/alphabet_graphic_illustrations.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import '../../../domain/game_contract/game_action.dart';
import '../../../domain/game_contract/game_lifecycle.dart';
import 'g011_controller.dart';

enum AbcdLearnMode {
  flashcards, // 🔤 Letter-by-letter Flashcards with Graphic Images & Phonics Soundboard
  gallery,    // 🖼️ A-Z Visual Grid Gallery
  quiz,       // 🎯 Find the Letter Game Challenge
}

class G011View extends StatefulWidget {
  final G011Controller controller;

  const G011View({super.key, required this.controller});

  @override
  State<G011View> createState() => _G011ViewState();
}

class _G011ViewState extends State<G011View> with SingleTickerProviderStateMixin {
  AbcdLearnMode _currentMode = AbcdLearnMode.flashcards;
  int _flashcardIndex = 0;
  bool _isAutoPlaying = false;
  Timer? _autoPlayTimer;

  // Quiz auto-advance timer
  int _autoAdvanceCountdown = 2;
  Timer? _autoAdvanceTimer;
  Timer? _countdownTicker;
  bool _showPromptSpeechBubble = false;
  Timer? _speechBubbleTimer;

  // Flashcard graphic bounce animation
  late AnimationController _bounceAnimController;
  late Animation<double> _bounceAnimation;
  final ScrollController _alphabetStripScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerState);
    if (widget.controller.state == GameLifecycleState.introduction) {
      widget.controller.start();
    }

    _bounceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.16).chain(CurveTween(curve: Curves.easeOut)), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.16, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 55),
    ]).animate(_bounceAnimController);

    // Initial warm speech
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentFlashcard();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _countdownTicker?.cancel();
    _speechBubbleTimer?.cancel();
    _bounceAnimController.dispose();
    _alphabetStripScroll.dispose();
    widget.controller.removeListener(_onControllerState);
    super.dispose();
  }

  void _onControllerState() {
    if (widget.controller.state == GameLifecycleState.completed && _autoAdvanceTimer == null) {
      _startAutoAdvance();
    }
    if (mounted) setState(() {});
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _countdownTicker?.cancel();
    setState(() {
      _autoAdvanceCountdown = 2;
    });

    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _autoAdvanceCountdown > 0) {
        setState(() {
          _autoAdvanceCountdown--;
        });
      }
    });

    _autoAdvanceTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _advanceToNextLevelNow();
      }
    });
  }

  void _advanceToNextLevelNow() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
    _countdownTicker?.cancel();
    _countdownTicker = null;
    widget.controller.generateNextLevel();
  }

  void _triggerSpeakerPrompt() {
    _speechBubbleTimer?.cancel();
    setState(() {
      _showPromptSpeechBubble = true;
    });
    _speechBubbleTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showPromptSpeechBubble = false;
        });
      }
    });
  }

  // ===========================================================================
  // FLASHCARD ACTIONS & AUDIO
  // ===========================================================================

  void _speakCurrentFlashcard() {
    final letters = widget.controller.fullAlphabet;
    if (_flashcardIndex < 0 || _flashcardIndex >= letters.length) return;
    final letter = letters[_flashcardIndex];
    final phonics = widget.controller.getPhonics(letter);
    final isHindi = widget.controller.profile.uiLocale == 'hi';
    final word = isHindi ? phonics.wordHi : phonics.wordEn;

    ProceduralSfxEngine().speakPhonics(letter, word, isHindi: isHindi);
  }

  void _nextFlashcard() {
    final letters = widget.controller.fullAlphabet;
    if (letters.isEmpty) return;
    setState(() {
      _flashcardIndex = (_flashcardIndex + 1) % letters.length;
    });
    _triggerCardBounce();
    _scrollToActiveLetter();
    _speakCurrentFlashcard();
  }

  void _prevFlashcard() {
    final letters = widget.controller.fullAlphabet;
    if (letters.isEmpty) return;
    setState(() {
      _flashcardIndex = (_flashcardIndex - 1 + letters.length) % letters.length;
    });
    _triggerCardBounce();
    _scrollToActiveLetter();
    _speakCurrentFlashcard();
  }

  void _selectFlashcard(int index) {
    final letters = widget.controller.fullAlphabet;
    if (letters.isEmpty) return;
    ProceduralSfxEngine().playPop();
    setState(() {
      _flashcardIndex = index.clamp(0, letters.length - 1);
    });
    _triggerCardBounce();
    _scrollToActiveLetter();
    _speakCurrentFlashcard();
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });

    _autoPlayTimer?.cancel();
    if (_isAutoPlaying) {
      ProceduralSfxEngine().playSparkle();
      _speakCurrentFlashcard();
      _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
        if (!mounted || !_isAutoPlaying) {
          timer.cancel();
          return;
        }
        _nextFlashcard();
      });
    } else {
      ProceduralSfxEngine().playPop();
    }
  }

  void _triggerCardBounce() {
    _bounceAnimController.forward(from: 0.0);
  }

  void _scrollToActiveLetter() {
    if (!_alphabetStripScroll.hasClients) return;
    final targetOffset = (_flashcardIndex * 54.0) - 100.0;
    _alphabetStripScroll.animateTo(
      targetOffset.clamp(0.0, _alphabetStripScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  // ===========================================================================
  // BUILD METHOD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isHindi = widget.controller.profile.uiLocale == 'hi';

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Stack(
          children: [
            // 1. Scenic Cartoon Environment
            Positioned.fill(
              child: _buildScenicEnvironment(),
            ),

            // 2. Play Area Content
            Column(
              children: [
                const SizedBox(height: 4),

                // Top Navigation Header (Back button, Stars pill, Mode tabs)
                _buildHeaderRow(),

                const SizedBox(height: 4),

                // Mode Switcher Candy Bar
                _buildModeTabBar(isHindi),

                const SizedBox(height: 4),

                // Dynamic Body based on active mode
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildActiveModeContent(isHindi),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveModeContent(bool isHindi) {
    switch (_currentMode) {
      case AbcdLearnMode.flashcards:
        return _buildFlashcardsView(isHindi);
      case AbcdLearnMode.gallery:
        return _buildGalleryView(isHindi);
      case AbcdLearnMode.quiz:
        return _buildQuizView(isHindi);
    }
  }

  // ===========================================================================
  // MODE 1: ABCD FLASHCARD LEARNING (Graphic Images + Phonics Soundboard)
  // ===========================================================================

  Widget _buildFlashcardsView(bool isHindi) {
    final letters = widget.controller.fullAlphabet;
    if (letters.isEmpty) return const SizedBox.shrink();
    final safeIndex = _flashcardIndex.clamp(0, letters.length - 1);
    final letter = letters[safeIndex];
    final phonics = widget.controller.getPhonics(letter);
    final word = isHindi ? phonics.wordHi : phonics.wordEn;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        if (isLandscape) {
          return _buildLandscapeFlashcard(letter, word, phonics, isHindi, constraints);
        }

        return Column(
          children: [
            // Current progress counter e.g. "Letter 1 of 26"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBA68C8), width: 2),
                    ),
                    child: Text(
                      isHindi ? 'अक्षर ${_flashcardIndex + 1} / ${letters.length}' : 'Letter ${_flashcardIndex + 1} of ${letters.length}',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6A1B9A),
                      ),
                    ),
                  ),

                  // Auto-Play Slideshow button
                  GestureDetector(
                    onTap: _toggleAutoPlay,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isAutoPlaying
                              ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                              : [const Color(0xFF00E676), const Color(0xFF00C853)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            offset: const Offset(0, 3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAutoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAutoPlaying ? 'AUTO PLAYING' : 'AUTO PLAY',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Centerpiece: 3D Big Letter + Large Graphic Artwork Card
            GestureDetector(
              onTap: () {
                _triggerCardBounce();
                ProceduralSfxEngine().playBoing();
                ProceduralSfxEngine().speakWord(word, isHindi: isHindi);
              },
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _bounceAnimation.value,
                  child: child,
                ),
                child: Container(
                  width: constraints.maxWidth * 0.76,
                  height: constraints.maxWidth * 0.74,
                  constraints: const BoxConstraints(maxHeight: 270, maxWidth: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B1FA2).withOpacity(0.35),
                        offset: const Offset(0, 8),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background soft rays
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.15,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Color(0xFFFFD54F), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Large Graphic Artwork
                      AlphabetGraphicArtwork(
                        letter: letter,
                        size: (constraints.maxWidth * 0.44).clamp(110.0, 160.0),
                      ),

                      // Floating 3D Letter Badge (Top-Left)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF80AB), Color(0xFFE91E63)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Tap Hint Badge (Bottom-Right)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBA68C8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.touch_app_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                'TAP ME',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Phonics Title Banner: "A is for Apple 🍎"
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE082), Color(0xFFFFCA28)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      phonics.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHindi ? '$letter से $word' : '$letter is for $word',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4A148C),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Soundboard Buttons (Letter Voice, Word Voice, Phonics Sound)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSoundboardButton(
                    icon: Icons.volume_up_rounded,
                    label: 'Say "$letter"',
                    color: const Color(0xFF42A5F5),
                    onTap: () {
                      ProceduralSfxEngine().speakLetter(letter, isHindi: isHindi);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildSoundboardButton(
                    icon: Icons.record_voice_over_rounded,
                    label: 'Say "$word"',
                    color: const Color(0xFFFF7043),
                    onTap: () {
                      ProceduralSfxEngine().speakWord(word, isHindi: isHindi);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildSoundboardButton(
                    icon: Icons.music_note_rounded,
                    label: 'Phonics',
                    color: const Color(0xFFAB47BC),
                    onTap: () {
                      ProceduralSfxEngine().speakPhonics(letter, word, isHindi: isHindi);
                    },
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Navigation Controls: Prev Candy Button, Next Candy Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CandyPillButton(
                    width: 120,
                    height: 48,
                    color: const Color(0xFFFFB300),
                    borderRadius: 24,
                    onPressed: _prevFlashcard,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          'PREV',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Sound Replay button
                  GestureDetector(
                    onTap: () {
                      _triggerCardBounce();
                      _speakCurrentFlashcard();
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E676), Color(0xFF00C853)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                    ),
                  ),

                  CandyPillButton(
                    width: 120,
                    height: 48,
                    color: const Color(0xFF80C94A),
                    borderRadius: 24,
                    onPressed: _nextFlashcard,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NEXT',
                          style: GoogleFonts.bubblegumSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Horizontal A–Z Quick Scrubber Strip
            _buildAlphabetScrubberStrip(letters),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeFlashcard(
    String letter,
    String word,
    PhonicsInfo phonics,
    bool isHindi,
    BoxConstraints constraints,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Left: Big Graphic Card
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: () {
                _triggerCardBounce();
                ProceduralSfxEngine().playBoing();
                ProceduralSfxEngine().speakWord(word, isHindi: isHindi);
              },
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _bounceAnimation.value,
                  child: child,
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B1FA2).withOpacity(0.3),
                        offset: const Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AlphabetGraphicArtwork(
                        letter: letter,
                        size: (constraints.maxHeight * 0.65).clamp(100.0, 180.0),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE91E63),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right: Phonics Details, Soundboard & Navigation
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE082),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    isHindi ? '$letter से $word ${phonics.emoji}' : '$letter is for $word ${phonics.emoji}',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4A148C),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Soundboard Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSoundboardButton(
                      icon: Icons.volume_up_rounded,
                      label: 'Say "$letter"',
                      color: const Color(0xFF42A5F5),
                      onTap: () => ProceduralSfxEngine().speakLetter(letter, isHindi: isHindi),
                    ),
                    const SizedBox(width: 8),
                    _buildSoundboardButton(
                      icon: Icons.record_voice_over_rounded,
                      label: 'Say "$word"',
                      color: const Color(0xFFFF7043),
                      onTap: () => ProceduralSfxEngine().speakWord(word, isHindi: isHindi),
                    ),
                    const SizedBox(width: 8),
                    _buildSoundboardButton(
                      icon: Icons.music_note_rounded,
                      label: 'Phonics',
                      color: const Color(0xFFAB47BC),
                      onTap: () => ProceduralSfxEngine().speakPhonics(letter, word, isHindi: isHindi),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Navigation Prev / Next
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CandyPillButton(
                      width: 100,
                      height: 42,
                      color: const Color(0xFFFFB300),
                      borderRadius: 21,
                      onPressed: _prevFlashcard,
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleAutoPlay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isAutoPlaying ? Colors.redAccent : const Color(0xFF00C853),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isAutoPlaying ? 'PAUSE' : 'AUTO PLAY',
                          style: GoogleFonts.bubblegumSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CandyPillButton(
                      width: 100,
                      height: 42,
                      color: const Color(0xFF80C94A),
                      borderRadius: 21,
                      onPressed: _nextFlashcard,
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundboardButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        ProceduralSfxEngine().playPop();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.bubblegumSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetScrubberStrip(List<String> letters) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        controller: _alphabetStripScroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final isSelected = index == _flashcardIndex;
          final letter = letters[index];

          return GestureDetector(
            onTap: () => _selectFlashcard(index),
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6A1B9A) : Colors.white,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.2 : 0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: GoogleFonts.bubblegumSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFF5E35B1),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // MODE 2: A-Z VISUAL GALLERY (All 26 Letter Cards Grid)
  // ===========================================================================

  Widget _buildGalleryView(bool isHindi) {
    final letters = widget.controller.fullAlphabet;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              isHindi ? 'अक्षर को छुएं और सीखें! 🎨' : 'Tap any letter to hear & learn! 🎨',
              style: GoogleFonts.bubblegumSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  const Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 16, top: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: letters.length,
              itemBuilder: (context, index) {
                final letter = letters[index];
                final phonics = widget.controller.getPhonics(letter);
                final word = isHindi ? phonics.wordHi : phonics.wordEn;

                return GestureDetector(
                  onTap: () {
                    _selectFlashcard(index);
                    setState(() {
                      _currentMode = AbcdLearnMode.flashcards;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFBA68C8), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B1FA2).withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Letter badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE082),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            letter,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF6A1B9A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Graphic Image Artwork
                        Expanded(
                          child: AlphabetGraphicArtwork(
                            letter: letter,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Word label
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A148C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODE 3: FIND THE LETTER QUIZ GAME
  // ===========================================================================

  Widget _buildQuizView(bool isHindi) {
    final controller = widget.controller;
    final round = controller.currentRound;
    final phonics = controller.currentPhonics;
    final isCompleted = controller.state == GameLifecycleState.completed;

    return Column(
      children: [
        // 3D Bubble Title: "FIND THE B!"
        BubbleTitle(
          text: isHindi ? 'ढूंढें ${round.targetGlyph}!' : 'FIND THE ${round.targetGlyph}!',
          fontSize: 26,
        ),

        // Speech Bubble Prompt if triggered
        if (_showPromptSpeechBubble)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBA68C8), width: 2),
            ),
            child: Text(
              isHindi ? 'प्यारे बच्चे, अक्षर ${round.targetGlyph} को छुएं! 🌟' : 'Hey superstar, tap letter ${round.targetGlyph}! 🌟',
              style: GoogleFonts.bubblegumSans(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF6A1B9A),
              ),
            ),
          ),

        const Spacer(flex: 1),

        if (isCompleted)
          _buildLevelCompletedAutoAdvance(isHindi)
        else ...[
          // Living Target Character with Graphic Picture & Kawaii Face
          _buildTargetCharacter(round.targetGlyph),

          const SizedBox(height: 8),

          // Educational Phonics Companion Badge with Custom Graphic Artwork
          _buildPhonicsBadge(phonics, isHindi),

          const Spacer(flex: 2),

          // Chunky Glossy Candy Choice Cards (with Kawaii Faces!)
          _buildChoicesRow(round),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTargetCharacter(String targetGlyph) {
    return GestureDetector(
      onTap: () {
        ProceduralSfxEngine().playBoing();
        _triggerSpeakerPrompt();
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD54F),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              offset: const Offset(0, 8),
              blurRadius: 14,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Polka dots
            Positioned.fill(
              child: ClipOval(
                child: CustomPaint(
                  painter: PolkaDotPatternPainter(
                    dotColor: const Color(0xFFFF8F00),
                    spacing: 20,
                    radius: 4,
                  ),
                ),
              ),
            ),
            // Giant letter
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  targetGlyph,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6A1B9A),
                    shadows: [
                      const Shadow(color: Colors.white, offset: Offset(0, -2), blurRadius: 4),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: const KawaiiFace(size: 34, blushColor: Color(0xFFFF5252)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhonicsBadge(PhonicsInfo phonics, bool isHindi) {
    return GestureDetector(
      onTap: () {
        final word = isHindi ? phonics.wordHi : phonics.wordEn;
        ProceduralSfxEngine().speakPhonics(phonics.letter, word, isHindi: isHindi);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBA68C8), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AlphabetGraphicArtwork(letter: phonics.letter, size: 28),
            const SizedBox(width: 8),
            Text(
              isHindi ? '${phonics.letter} से ${phonics.wordHi}' : '${phonics.letter} is for ${phonics.wordEn}',
              style: GoogleFonts.bubblegumSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.volume_up_rounded, color: Color(0xFFAB47BC), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicesRow(LetterRound round) {
    final cardStyles = [
      {'bg': const Color(0xFFFFE066), 'border': const Color(0xFF7B1FA2), 'letterColor': const Color(0xFF29B6F6)},
      {'bg': const Color(0xFF9CCC65), 'border': const Color(0xFF7B1FA2), 'letterColor': const Color(0xFFFF4081)},
      {'bg': const Color(0xFFFF5252), 'border': const Color(0xFFFF8F00), 'letterColor': const Color(0xFFFFA726)},
      {'bg': const Color(0xFF80D8FF), 'border': const Color(0xFF0091EA), 'letterColor': const Color(0xFF651FFF)},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 24;
        final cardCount = round.choices.length;
        final cardWidth = (availableWidth / cardCount - 10).clamp(65.0, 96.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(round.choices.length, (index) {
              final choice = round.choices[index];
              final style = cardStyles[index % cardStyles.length];
              final isTarget = choice == round.targetGlyph;
              final isSelected = widget.controller.selectedChoice == choice;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CandyCardTile(
                  width: cardWidth,
                  height: cardWidth * 1.05,
                  borderRadius: 24,
                  backgroundColor: style['bg'] as Color,
                  borderColor: style['border'] as Color,
                  isSelected: isSelected,
                  showSparkles: isTarget && isSelected,
                  onTap: () {
                    if (isTarget) {
                      ProceduralSfxEngine().playDing();
                    } else {
                      ProceduralSfxEngine().playPop();
                    }
                    widget.controller.handleAction(GameAction.select(choice));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        choice,
                        style: GoogleFonts.bubblegumSans(
                          fontSize: cardWidth * 0.52,
                          fontWeight: FontWeight.w900,
                          color: style['letterColor'] as Color,
                          shadows: const [
                            Shadow(color: Colors.white, offset: Offset(0, 2), blurRadius: 2),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: KawaiiFace(
                          size: cardWidth * 0.28,
                          eyeColor: (style['letterColor'] as Color).withOpacity(0.9),
                          blushColor: const Color(0xFFFF4081),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TOP TABS & SCENIC MEADOW ENVIRONMENT
  // ===========================================================================

  Widget _buildModeTabBar(bool isHindi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildModeTabItem(
            mode: AbcdLearnMode.flashcards,
            label: isHindi ? '🔤 कार्ड्स' : '🔤 ABCD Cards',
          ),
          _buildModeTabItem(
            mode: AbcdLearnMode.gallery,
            label: isHindi ? '🖼️ गैलरी' : '🖼️ A-Z Gallery',
          ),
          _buildModeTabItem(
            mode: AbcdLearnMode.quiz,
            label: isHindi ? '🎯 खोजें' : '🎯 Letter Quiz',
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabItem({required AbcdLearnMode mode, required String label}) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ProceduralSfxEngine().playPop();
          if (mode != AbcdLearnMode.flashcards && _isAutoPlaying) {
            _autoPlayTimer?.cancel();
            _isAutoPlaying = false;
          }
          setState(() {
            _currentMode = mode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.bubblegumSans(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isSelected ? const Color(0xFF6A1B9A) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    final roundNumber = widget.controller.currentRoundIndex + 1;
    final total = widget.controller.totalRounds;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button + Learn ABCD pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) => CandyPillButton(
                  width: 36,
                  height: 36,
                  color: const Color(0xFF80C94A),
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 6),
              const PillBadge(
                backgroundColor: Color(0xFF7150B8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LEARN ABCD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right: Speaker trigger + Stars
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CandyPillButton(
                width: 36,
                height: 36,
                color: const Color(0xFFFFA726),
                onPressed: () {
                  if (_currentMode == AbcdLearnMode.flashcards) {
                    _speakCurrentFlashcard();
                  } else {
                    _triggerSpeakerPrompt();
                  }
                },
                child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 6),
              PillBadge(
                backgroundColor: const Color(0xFFFFB300),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                content: Text(
                  'ROUND $roundNumber/$total',
                  style: const TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCompletedAutoAdvance(bool isHindi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBA68C8), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟 🎉 🔤 🎉 🌟', style: TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              isHindi ? 'शानदार! अक्षर खोज स्तर पूरा हुआ!' : 'Super! Alphabet Level Complete!',
              textAlign: TextAlign.center,
              style: GoogleFonts.bubblegumSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Next letters in ${_autoAdvanceCountdown}s...',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CandyPillButton(
              width: 160,
              height: 44,
              color: const Color(0xFFBA68C8),
              borderColor: Colors.white,
              borderRadius: 22,
              onPressed: _advanceToNextLevelNow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXT LETTERS',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.skip_next_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenicEnvironment() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE040FB), // Vibrant candy magenta
            Color(0xFF7C4DFF), // Royal violet
            Color(0xFF69F0AE), // Meadow green bottom
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 10,
            child: Opacity(
              opacity: 0.85,
              child: Row(
                children: const [
                  Icon(Icons.cloud_rounded, color: Colors.white, size: 48),
                  SizedBox(width: 4),
                  Icon(Icons.cloud_rounded, color: Colors.white, size: 36),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Opacity(
              opacity: 0.8,
              child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 54),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 140,
            child: CustomPaint(
              painter: MeadowHillsPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class MeadowHillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFF00E676);
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.1, size.width * 0.7, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.7, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()..color = const Color(0xFF00C853);
    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.85, size.width * 0.75, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.4, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PolkaDotPatternPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double radius;

  PolkaDotPatternPainter({
    required this.dotColor,
    this.spacing = 20,
    this.radius = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    for (double x = radius; x < size.width; x += spacing) {
      for (double y = radius; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
