import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g085_controller.dart';

class G085View extends StatefulWidget {
  final G085Controller controller;

  const G085View({super.key, required this.controller});

  @override
  State<G085View> createState() => _G085ViewState();
}

class _G085ViewState extends State<G085View> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isHindi = ctrl.profile.uiLocale == 'hi';
        final currentCase = ctrl.currentCase;

        return CartoonGameScaffold(
          title: isHindi ? 'जासूस लियो! 🔍' : 'Detective Leo! 🔍',
          subtitle: isHindi
              ? 'सुराग इकट्ठा करो और रहस्य सुलझाओ!'
              : 'Gather clues and solve the mystery!',
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isHindi ? 'केस: ${ctrl.currentCaseIndex + 1}/${ctrl.cases.length}' : 'Case: ${ctrl.currentCaseIndex + 1}/${ctrl.cases.length}',
                                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                              ),
                              Text(
                                '${ctrl.cases.where((c) => c.isSolved).length} solved ⭐',
                                style: GoogleFonts.bubblegumSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ),

                        // Story Card
                        if (ctrl.showingStory) ...[
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFFFE082), width: 2.5),
                            ),
                            child: Column(
                              children: [
                                const Text('📜', style: TextStyle(fontSize: 40)),
                                const SizedBox(height: 8),
                                Text(
                                  isHindi ? currentCase.titleHi : currentCase.titleEn,
                                  style: GoogleFonts.bubblegumSans(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textNavy),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isHindi ? currentCase.storyHi : currentCase.storyEn,
                                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.brown.shade800),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                CartoonButton(
                                  text: isHindi ? 'जांच शुरू करो! 🔎' : 'Start Investigation! 🔎',
                                  color: const Color(0xFF6C63FF),
                                  onPressed: () => ctrl.dismissStory(),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Investigation Phase
                        if (!ctrl.showingStory) ...[
                          // Clue Reveal Area
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EAF6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF7986CB), width: 2),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isHindi ? '🔍 सुराग:' : '🔍 Clues:',
                                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                                ),
                                const SizedBox(height: 8),
                                ...ctrl.revealedClues.map((clue) {
                                  final clueObj = currentCase.clues.firstWhere(
                                    (c) => c.textEn == clue,
                                    orElse: () => currentCase.clues.first,
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.indigo.shade100),
                                      ),
                                      child: Text(
                                        isHindi ? clueObj.textHi : clueObj.textEn,
                                        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.indigo.shade800),
                                      ),
                                    ),
                                  );
                                }),
                                if (ctrl.revealedClues.length < currentCase.clues.length)
                                  CartoonButton(
                                    text: isHindi ? 'अगला सुराग खोजो! 🧩' : 'Find Next Clue! 🧩',
                                    color: const Color(0xFF5C6BC0),
                                    onPressed: () => ctrl.revealNextClue(),
                                  ),
                              ],
                            ),
                          ),

                          // Suspect selection
                          if (!ctrl.showingResult) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text(
                                isHindi ? '🕵️ किसने किया? चुनो:' : '🕵️ Who did it? Pick a suspect:',
                                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: currentCase.suspects.map((s) {
                                  final isHinted = ctrl.hintHighlightId == s.id;
                                  return GestureDetector(
                                    onTap: () => ctrl.accuseSuspect(s.id),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 100,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isHinted ? const Color(0xFFC8E6C9) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isHinted ? Colors.greenAccent : Colors.grey.shade300,
                                          width: isHinted ? 3 : 2,
                                        ),
                                        boxShadow: isHinted
                                            ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 8)]
                                            : [],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(s.emoji, style: const TextStyle(fontSize: 36)),
                                          const SizedBox(height: 4),
                                          Text(
                                            isHindi ? s.nameHi : s.nameEn,
                                            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ctrl.lastGuessCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: ctrl.lastGuessCorrect ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
                                  width: 2.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    ctrl.lastGuessCorrect ? '🎉' : '🤔',
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                  Text(
                                    ctrl.lastGuessCorrect
                                        ? (isHindi ? 'सही! केस सुलझा!' : 'Correct! Case Solved!')
                                        : (isHindi ? 'गलत! फिर कोशिश करो!' : 'Wrong! Try Again!'),
                                    style: GoogleFonts.bubblegumSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: ctrl.lastGuessCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  CartoonButton(
                                    text: isHindi ? 'आगे बढ़ो ▶️' : 'Continue ▶️',
                                    color: const Color(0xFF6C63FF),
                                    onPressed: () => ctrl.nextCase(),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
