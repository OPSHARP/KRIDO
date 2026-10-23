import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme.dart';
import '../../../domain/game_contract/game_action.dart';
import 'g061_controller.dart';

class G061View extends StatelessWidget {
  final G061Controller controller;

  const G061View({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final round = controller.currentRound;
        final isHindi = controller.profile.uiLocale == 'hi';

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Round progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(controller.totalRounds, (i) {
                    final isDone = i < controller.currentRoundIndex;
                    final isCurrent = i == controller.currentRoundIndex;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppTheme.green
                            : (isCurrent ? AppTheme.sunGold : Colors.grey.shade300),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Question Prompt Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.purple.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('🔍', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        isHindi ? round.categoryPromptHi : round.categoryPromptEn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHindi
                            ? 'जो अलग है उसे छुएं!'
                            : 'Tap the one that does not belong!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 2x2 Grid of Items
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: round.items.map((item) {
                    final isSelected = controller.selectedItem == item;
                    final isOdd = item == round.oddItem;
                    final isHinted = controller.hintHighlightId == item;

                    Color cardBg = AppTheme.cardWhite;
                    Color borderColor = isHinted ? AppTheme.sunGold : Colors.grey.shade300;
                    double borderWidth = isHinted ? 4.0 : 2.0;

                    if (isSelected) {
                      cardBg = isOdd ? AppTheme.green : AppTheme.coral;
                      borderColor = isOdd ? Colors.green : Colors.red;
                      borderWidth = 3.5;
                    }

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.handleAction(GameAction.select(item));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: borderColor, width: borderWidth),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? (isOdd ? AppTheme.green : AppTheme.coral).withOpacity(0.25)
                                  : Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Feedback Reason Card (Shown after selection)
                if (controller.selectedItem != null && controller.selectedItem == round.oddItem)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.green, width: 1.5),
                    ),
                    child: Text(
                      isHindi ? round.reasonHi : round.reasonEn,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
