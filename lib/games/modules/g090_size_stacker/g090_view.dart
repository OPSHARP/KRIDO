import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g090_controller.dart';

class G090View extends StatefulWidget {
  final G090Controller controller;

  const G090View({super.key, required this.controller});

  @override
  State<G090View> createState() => _G090ViewState();
}

class _G090ViewState extends State<G090View> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isHindi = ctrl.profile.uiLocale == 'hi';

        return CartoonGameScaffold(
          title: isHindi ? 'साइज़ स्टैकर! 📏' : 'Size Stacker! 📏',
          subtitle: isHindi
              ? 'चीजों को सही क्रम में सजाओ!'
              : 'Arrange items in the right size order!',
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
                                '${isHindi ? 'दौर' : 'Round'}: ${ctrl.currentRoundIndex + 1}/${ctrl.rounds.length}',
                                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                              ),
                              Text(
                                '${ctrl.rounds.where((r) => r.isComplete).length}/${ctrl.rounds.length} ⭐',
                                style: GoogleFonts.bubblegumSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ),

                        // Instruction
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFFAB47BC)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            isHindi
                                ? ctrl.currentRound.instructionHi
                                : ctrl.currentRound.instructionEn,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Placed items (stacking area)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(minHeight: 80),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFA5D6A7), width: 2.5),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isHindi ? '📦 क्रम:' : '📦 Stack:',
                                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                              ),
                              const SizedBox(height: 8),
                              ctrl.placedItems.isEmpty
                                  ? Text(
                                      isHindi ? 'नीचे से चुनो!' : 'Pick from below!',
                                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      children: ctrl.placedItems.map((item) {
                                        final scaleFactor = 0.6 + (item.relativeSize * 0.6);
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              item.emoji,
                                              style: TextStyle(fontSize: 28 * scaleFactor),
                                            ),
                                            Text(
                                              isHindi ? item.nameHi : item.nameEn,
                                              style: GoogleFonts.nunito(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textNavy,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),

                        // Available items
                        if (!ctrl.showingResult) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Text(
                              isHindi ? '👇 अगला चुनो:' : '👇 Pick next:',
                              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: ctrl.unplacedItems.map((item) {
                                  final isHinted = ctrl.hintHighlightId == item.id;
                                  final scaleFactor = 0.6 + (item.relativeSize * 0.6);
                                  return GestureDetector(
                                    onTap: () => ctrl.placeItem(item.id),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 80,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isHinted
                                            ? const Color(0xFFC8E6C9)
                                            : Colors.white,
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
                                          Text(
                                            item.emoji,
                                            style: TextStyle(fontSize: 30 * scaleFactor),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isHindi ? item.nameHi : item.nameEn,
                                            style: GoogleFonts.nunito(
                                              fontSize: 11,
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
                          ),
                        ],

                        // Round complete result
                        if (ctrl.showingResult) ...[
                          Expanded(
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFF66BB6A), width: 2.5),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🎉', style: TextStyle(fontSize: 48)),
                                    const SizedBox(height: 8),
                                    Text(
                                      isHindi ? 'बिल्कुल सही क्रम!' : 'Perfect Order!',
                                      style: GoogleFonts.bubblegumSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CartoonButton(
                                      text: isHindi ? 'अगला दौर ▶️' : 'Next Round ▶️',
                                      color: const Color(0xFF6C63FF),
                                      onPressed: () => ctrl.nextRound(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
