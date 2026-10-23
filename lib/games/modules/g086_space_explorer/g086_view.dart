import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g086_controller.dart';

class G086View extends StatefulWidget {
  final G086Controller controller;

  const G086View({super.key, required this.controller});

  @override
  State<G086View> createState() => _G086ViewState();
}

class _G086ViewState extends State<G086View> with TickerProviderStateMixin {
  late AnimationController _orbitCtrl;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
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
          title: isHindi ? 'अंतरिक्ष अन्वेषक! 🚀' : 'Space Explorer! 🚀',
          subtitle: isHindi
              ? 'ग्रहों की यात्रा करो और सीखो!'
              : 'Travel to planets and learn fun facts!',
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
                                isHindi ? 'ग्रह यात्रा:' : 'Planet Journey:',
                                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              Text(
                                '${ctrl.planets.where((p) => p.isVisited).length}/${ctrl.planets.length} ⭐',
                                style: GoogleFonts.bubblegumSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.amber),
                              ),
                            ],
                          ),
                        ),

                        // Planet display
                        if (!ctrl.showingFact && !ctrl.showingQuestion) ...[
                          // Planet row
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: ctrl.planets.length,
                              itemBuilder: (context, index) {
                                final planet = ctrl.planets[index];
                                final isCurrent = index == ctrl.currentPlanetIndex;
                                return GestureDetector(
                                  onTap: isCurrent && !planet.isVisited ? () => ctrl.visitPlanet() : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? Color(planet.colorHex).withOpacity(0.3)
                                          : Colors.white12,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isCurrent ? Colors.amber : Colors.white24,
                                        width: isCurrent ? 3 : 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(planet.emoji, style: TextStyle(fontSize: planet.isVisited ? 28 : 36)),
                                        const SizedBox(height: 4),
                                        Text(
                                          isHindi ? planet.nameHi : planet.nameEn,
                                          style: GoogleFonts.nunito(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (planet.isVisited)
                                          const Text('✅', style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Current planet highlight
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(ctrl.currentPlanet.colorHex).withOpacity(0.4),
                                  const Color(0xFF1A237E),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                            ),
                            child: Column(
                              children: [
                                Text(ctrl.currentPlanet.emoji, style: const TextStyle(fontSize: 64)),
                                const SizedBox(height: 8),
                                Text(
                                  isHindi ? ctrl.currentPlanet.nameHi : ctrl.currentPlanet.nameEn,
                                  style: GoogleFonts.bubblegumSans(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                if (!ctrl.currentPlanet.isVisited)
                                  CartoonButton(
                                    text: isHindi ? 'ग्रह पर जाओ! 🚀' : 'Visit Planet! 🚀',
                                    color: Colors.deepOrange,
                                    onPressed: () => ctrl.visitPlanet(),
                                  ),
                                if (ctrl.currentPlanet.isVisited)
                                  Text(
                                    isHindi ? '✅ यात्रा पूरी!' : '✅ Already Visited!',
                                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.greenAccent),
                                  ),
                              ],
                            ),
                          ),
                        ],

                        // Fact display
                        if (ctrl.showingFact) ...[
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.amber, width: 2),
                            ),
                            child: Column(
                              children: [
                                Text(ctrl.currentPlanet.emoji, style: const TextStyle(fontSize: 52)),
                                const SizedBox(height: 12),
                                Text(
                                  isHindi ? '📚 रोचक तथ्य:' : '📚 Fun Fact:',
                                  style: GoogleFonts.bubblegumSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.amber),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isHindi ? ctrl.currentPlanet.factHi : ctrl.currentPlanet.factEn,
                                  style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                CartoonButton(
                                  text: isHindi ? 'क्विज़ खेलो! 🧠' : 'Take the Quiz! 🧠',
                                  color: const Color(0xFF6C63FF),
                                  onPressed: () => ctrl.startQuestion(),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Question display
                        if (ctrl.showingQuestion && ctrl.currentQuestion != null) ...[
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF283593).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.amber, width: 2),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isHindi ? ctrl.currentQuestion!.questionHi : ctrl.currentQuestion!.questionEn,
                                  style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ...List.generate(ctrl.currentQuestion!.optionsEn.length, (i) {
                                  final isSelected = ctrl.selectedOptionIndex == i;
                                  final isCorrect = i == ctrl.currentQuestion!.correctIndex;
                                  final isHinted = ctrl.hintHighlightId == 'option_$i';

                                  Color bgColor = Colors.white12;
                                  if (ctrl.selectedOptionIndex != null) {
                                    if (isCorrect) {
                                      bgColor = const Color(0xFF66BB6A);
                                    } else if (isSelected) {
                                      bgColor = const Color(0xFFEF5350);
                                    }
                                  } else if (isHinted) {
                                    bgColor = Colors.greenAccent.withOpacity(0.3);
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: GestureDetector(
                                      onTap: ctrl.selectedOptionIndex == null
                                          ? () => ctrl.selectAnswer(i)
                                          : null,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white24, width: 1.5),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${String.fromCharCode(65 + i)}.',
                                              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                isHindi ? ctrl.currentQuestion!.optionsHi[i] : ctrl.currentQuestion!.optionsEn[i],
                                                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                                              ),
                                            ),
                                            if (ctrl.selectedOptionIndex != null && isCorrect)
                                              const Text('✅', style: TextStyle(fontSize: 18)),
                                            if (ctrl.selectedOptionIndex != null && isSelected && !isCorrect)
                                              const Text('❌', style: TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                if (ctrl.selectedOptionIndex != null) ...[
                                  const SizedBox(height: 8),
                                  CartoonButton(
                                    text: isHindi ? 'अगला ग्रह ▶️' : 'Next Planet ▶️',
                                    color: const Color(0xFF6C63FF),
                                    onPressed: () => ctrl.nextPlanet(),
                                  ),
                                ],
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
