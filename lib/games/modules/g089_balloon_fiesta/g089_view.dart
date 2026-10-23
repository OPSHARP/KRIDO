import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g089_controller.dart';

class G089View extends StatefulWidget {
  final G089Controller controller;

  const G089View({super.key, required this.controller});

  @override
  State<G089View> createState() => _G089ViewState();
}

class _G089ViewState extends State<G089View> with TickerProviderStateMixin {
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isHindi = ctrl.profile.uiLocale == 'hi';

        return CartoonGameScaffold(
          title: isHindi ? 'गुब्बारा पार्टी! 🎈' : 'Balloon Fiesta! 🎈',
          subtitle: isHindi
              ? 'सही संख्या वाला गुब्बारा फोड़ो!'
              : 'Pop the balloon with the right number!',
          onBack: () => Navigator.pop(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Progress and score
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
                                '🏆 ${ctrl.score}',
                                style: GoogleFonts.bubblegumSans(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.amber.shade800),
                              ),
                            ],
                          ),
                        ),

                        // Target number
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6F00), Color(0xFFFFC107)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10),
                            ],
                          ),
                          child: Text(
                            isHindi
                                ? '🎯 संख्या ${ctrl.currentRound.targetNumber} ढूंढो!'
                                : '🎯 Find number ${ctrl.currentRound.targetNumber}!',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [const Shadow(blurRadius: 2, color: Colors.black38)],
                            ),
                          ),
                        ),

                        // Balloons
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AnimatedBuilder(
                              animation: _floatCtrl,
                              builder: (context, child) {
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: ctrl.currentRound.balloons.map((balloon) {
                                    final isHinted = ctrl.hintHighlightId == balloon.id;
                                    final floatOffset = math.sin(
                                        _floatCtrl.value * math.pi + balloon.value * 0.5) * 6;

                                    return Transform.translate(
                                      offset: Offset(0, balloon.isPopped ? 0 : floatOffset),
                                      child: GestureDetector(
                                        onTap: balloon.isPopped
                                            ? null
                                            : () => ctrl.popBalloon(balloon.id),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 400),
                                          width: 80,
                                          height: balloon.isPopped ? 60 : 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: balloon.isPopped
                                                ? Colors.grey.shade200
                                                : Color(balloon.colorHex),
                                            border: Border.all(
                                              color: isHinted
                                                  ? Colors.greenAccent
                                                  : balloon.isPopped
                                                      ? Colors.grey.shade300
                                                      : Color(balloon.colorHex).withOpacity(0.7),
                                              width: isHinted ? 3 : 2,
                                            ),
                                            boxShadow: balloon.isPopped
                                                ? []
                                                : [
                                                    BoxShadow(
                                                      color: Color(balloon.colorHex).withOpacity(0.4),
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                    ),
                                                    if (isHinted)
                                                      BoxShadow(
                                                        color: Colors.greenAccent.withOpacity(0.5),
                                                        blurRadius: 12,
                                                      ),
                                                  ],
                                          ),
                                          child: Center(
                                            child: balloon.isPopped
                                                ? Text(
                                                    '💥',
                                                    style: const TextStyle(fontSize: 24),
                                                  )
                                                : Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text('🎈', style: TextStyle(fontSize: 22)),
                                                      Text(
                                                        '${balloon.value}',
                                                        style: GoogleFonts.bubblegumSans(
                                                          fontSize: 22,
                                                          fontWeight: FontWeight.w900,
                                                          color: Colors.white,
                                                          shadows: [const Shadow(blurRadius: 2, color: Colors.black54)],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ),

                        // Result
                        if (ctrl.showingResult) ...[
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ctrl.lastPopCorrect
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: ctrl.lastPopCorrect
                                    ? const Color(0xFF66BB6A)
                                    : const Color(0xFFEF5350),
                                width: 2.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  ctrl.lastPopCorrect
                                      ? (isHindi ? '🎉 सही गुब्बारा फोड़ा!' : '🎉 Correct Balloon!')
                                      : (isHindi ? '😅 गलत! फिर कोशिश करो!' : '😅 Wrong! Try Again!'),
                                  style: GoogleFonts.bubblegumSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: ctrl.lastPopCorrect
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CartoonButton(
                                  text: isHindi ? 'आगे ▶️' : 'Next ▶️',
                                  color: const Color(0xFF6C63FF),
                                  onPressed: () => ctrl.nextRound(),
                                ),
                              ],
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
