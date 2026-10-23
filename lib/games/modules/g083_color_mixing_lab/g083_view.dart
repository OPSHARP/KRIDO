import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g083_controller.dart';

class G083View extends StatefulWidget {
  final G083Controller controller;

  const G083View({super.key, required this.controller});

  @override
  State<G083View> createState() => _G083ViewState();
}

class _G083ViewState extends State<G083View> with TickerProviderStateMixin {
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bubbleController.dispose();
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
          title: isHindi ? 'रंग मिश्रण प्रयोगशाला! 🎨' : 'Color Mixing Lab! 🎨',
          subtitle: isHindi
              ? 'दो रंग चुनकर नया रंग बनाओ!'
              : 'Pick two colors and mix them to create a new color!',
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
                                isHindi ? 'लक्ष्य रंग:' : 'Target Color:',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textNavy,
                                ),
                              ),
                              Text(
                                '${ctrl.targetMixes.where((m) => m.isMixed).length} / ${ctrl.targetMixes.length} ⭐',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Target Color Display
                        AnimatedBuilder(
                          animation: _bubbleController,
                          builder: (context, child) {
                            final scale = 1.0 + 0.05 * _bubbleController.value;
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(ctrl.currentTarget.colorHex),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(ctrl.currentTarget.colorHex).withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🎯', style: TextStyle(fontSize: 28)),
                                  Text(
                                    isHindi ? ctrl.currentTarget.nameHi : ctrl.currentTarget.nameEn,
                                    style: GoogleFonts.bubblegumSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      shadows: [const Shadow(blurRadius: 4, color: Colors.black54)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Primary Color Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: ctrl.primaryColors.map((pc) {
                              final isSelected = ctrl.selectedPrimaries.contains(pc.id);
                              final isHinted = ctrl.hintHighlightId == pc.id;
                              return GestureDetector(
                                onTap: () => ctrl.togglePrimary(pc.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(pc.colorHex),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.amber
                                          : isHinted
                                              ? Colors.greenAccent
                                              : Colors.white70,
                                      width: isSelected ? 4 : 2.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 12)]
                                        : isHinted
                                            ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.6), blurRadius: 12)]
                                            : [],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(pc.emoji, style: const TextStyle(fontSize: 22)),
                                        Text(
                                          isHindi ? pc.nameHi : pc.nameEn,
                                          style: GoogleFonts.nunito(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: pc.id == 'white' ? Colors.black87 : Colors.white,
                                            shadows: pc.id == 'white'
                                                ? []
                                                : [const Shadow(blurRadius: 2, color: Colors.black54)],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Mix Button
                        if (!ctrl.showResult)
                          CartoonButton(
                            text: isHindi ? 'रंग मिलाओ! 🧪' : 'Mix Colors! 🧪',
                            color: ctrl.selectedPrimaries.length == 2
                                ? const Color(0xFF6C63FF)
                                : Colors.grey,
                            onPressed: ctrl.selectedPrimaries.length == 2
                                ? () => ctrl.mixColors()
                                : null,
                          ),

                        // Result Display
                        if (ctrl.showResult) ...[
                          const SizedBox(height: 8),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ctrl.lastMixCorrect
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: ctrl.lastMixCorrect
                                    ? const Color(0xFF66BB6A)
                                    : const Color(0xFFEF5350),
                                width: 2.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(ctrl.resultColorHex),
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ctrl.lastMixCorrect
                                      ? (isHindi ? '🎉 बिल्कुल सही!' : '🎉 Perfect Mix!')
                                      : (isHindi ? '😅 फिर कोशिश करो!' : '😅 Try Again!'),
                                  style: GoogleFonts.bubblegumSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: ctrl.lastMixCorrect
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CartoonButton(
                                  text: isHindi ? 'आगे बढ़ो ▶️' : 'Continue ▶️',
                                  color: const Color(0xFF6C63FF),
                                  onPressed: () => ctrl.nextRound(),
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
