import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g088_controller.dart';

class G088View extends StatefulWidget {
  final G088Controller controller;

  const G088View({super.key, required this.controller});

  @override
  State<G088View> createState() => _G088ViewState();
}

class _G088ViewState extends State<G088View> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isHindi = ctrl.profile.uiLocale == 'hi';

        return CartoonGameScaffold(
          title: isHindi ? 'डायनो हड्डी खोजो! 🦕' : 'Dino Bone Digger! 🦕',
          subtitle: isHindi
              ? 'ग्रिड में छिपी हड्डियां खोदो!'
              : 'Dig the grid to find hidden dinosaur bones!',
          onBack: () => Navigator.pop(context),
          child: Column(
            children: [
                        // Progress
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isHindi ? '🦴 मिली: ${ctrl.bonesFound}/${ctrl.totalBones}' : '🦴 Found: ${ctrl.bonesFound}/${ctrl.totalBones}',
                                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                              ),
                              Text(
                                '⛏️ ${ctrl.digCount}',
                                style: GoogleFonts.bubblegumSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.brown),
                              ),
                            ],
                          ),
                        ),

                        // Bone progress row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 6,
                            children: ctrl.bones.map((bone) {
                              return Chip(
                                avatar: Text(bone.isExcavated ? '✅' : '❓', style: const TextStyle(fontSize: 14)),
                                label: Text(
                                  isHindi ? bone.nameHi : bone.nameEn,
                                  style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                                backgroundColor: bone.isExcavated
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF8E1),
                                side: BorderSide(
                                  color: bone.isExcavated ? const Color(0xFF66BB6A) : const Color(0xFFFFE082),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Dig Grid
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7CCC8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF8D6E63), width: 3),
                            ),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: G088Controller.gridSize,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: G088Controller.gridSize * G088Controller.gridSize,
                              itemBuilder: (context, index) {
                                final row = index ~/ G088Controller.gridSize;
                                final col = index % G088Controller.gridSize;
                                final cell = ctrl.grid[row][col];
                                final isHinted = ctrl.hintHighlightId == '${row}_$col';

                                return GestureDetector(
                                  onTap: () => ctrl.digCell(row, col),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: cell.isDug
                                          ? (cell.hasBone
                                              ? const Color(0xFFFFF9C4)
                                              : const Color(0xFFEFEBE9))
                                          : isHinted
                                              ? Colors.greenAccent.withOpacity(0.5)
                                              : const Color(0xFFA1887F),
                                      border: Border.all(
                                        color: cell.isDug
                                            ? (cell.hasBone ? Colors.amber : Colors.brown.shade200)
                                            : isHinted
                                                ? Colors.greenAccent
                                                : Colors.brown.shade400,
                                        width: isHinted ? 2.5 : 1.5,
                                      ),
                                      boxShadow: isHinted
                                          ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 6)]
                                          : [],
                                    ),
                                    child: Center(
                                      child: cell.isDug
                                          ? (cell.hasBone
                                              ? const Text('🦴', style: TextStyle(fontSize: 24))
                                              : Text(
                                                  _getProximityEmoji(ctrl.getProximityHint(row, col)),
                                                  style: const TextStyle(fontSize: 16),
                                                ))
                                          : const Text('🟤', style: TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Instructions
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            isHindi
                                ? '⛏️ मिट्टी पर टैप करो खोदने के लिए! संख्या = पास की हड्डियां'
                                : '⛏️ Tap soil to dig! Number = nearby bones',
                            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  String _getProximityEmoji(int count) {
    if (count == 0) return '·';
    return '$count';
  }
}
