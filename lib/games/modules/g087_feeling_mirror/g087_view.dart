import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g087_controller.dart';

class G087View extends StatefulWidget {
  final G087Controller controller;

  const G087View({super.key, required this.controller});

  @override
  State<G087View> createState() => _G087ViewState();
}

class _G087ViewState extends State<G087View> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isHindi = ctrl.profile.uiLocale == 'hi';

        return CartoonGameScaffold(
          title: isHindi ? 'भावना दर्पण! 🪞' : 'Feeling Mirror! 🪞',
          subtitle: isHindi
              ? 'कहानी पढ़ो और सही भावना चुनो!'
              : 'Read the story and pick the right emotion!',
          onBack: () => Navigator.pop(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Progress
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isHindi ? 'स्थिति:' : 'Scenario:',
                                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                              ),
                              Text(
                                '${ctrl.scenarios.where((s) => s.isSolved).length}/${ctrl.scenarios.length} ⭐',
                                style: GoogleFonts.bubblegumSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ),

                        // Scenario card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8EAF6), Color(0xFFF3E5F5)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFCE93D8), width: 2.5),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isHindi ? ctrl.currentScenario.scenarioHi : ctrl.currentScenario.scenarioEn,
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textNavy,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isHindi ? 'तुम कैसा महसूस करोगे?' : 'How would you feel?',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Emotion Grid
                        if (!ctrl.showingResult) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: ctrl.emotions.map((emotion) {
                                final isHinted = ctrl.hintHighlightId == emotion.id;
                                return GestureDetector(
                                  onTap: () => ctrl.selectEmotion(emotion.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 100,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isHinted
                                          ? Color(emotion.colorHex).withOpacity(0.3)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isHinted ? Colors.greenAccent : Color(emotion.colorHex).withOpacity(0.5),
                                        width: isHinted ? 3 : 2,
                                      ),
                                      boxShadow: isHinted
                                          ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 8)]
                                          : [],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(emotion.emoji, style: const TextStyle(fontSize: 36)),
                                        const SizedBox(height: 4),
                                        Text(
                                          isHindi ? emotion.nameHi : emotion.nameEn,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textNavy,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        // Result
                        if (ctrl.showingResult) ...[
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ctrl.lastAnswerCorrect
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: ctrl.lastAnswerCorrect
                                    ? const Color(0xFF66BB6A)
                                    : const Color(0xFFEF5350),
                                width: 2.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  ctrl.lastAnswerCorrect ? '🎉' : '🤗',
                                  style: const TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ctrl.lastAnswerCorrect
                                      ? (isHindi ? 'बिल्कुल सही!' : 'That\'s right!')
                                      : (isHindi ? 'सही जवाब: ${ctrl.emotions.firstWhere((e) => e.id == ctrl.currentScenario.correctEmotionId).nameHi}'
                                          : 'Correct answer: ${ctrl.emotions.firstWhere((e) => e.id == ctrl.currentScenario.correctEmotionId).nameEn}'),
                                  style: GoogleFonts.bubblegumSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: ctrl.lastAnswerCorrect
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                CartoonButton(
                                  text: isHindi ? 'आगे बढ़ो ▶️' : 'Continue ▶️',
                                  color: const Color(0xFF6C63FF),
                                  onPressed: () => ctrl.nextScenario(),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
