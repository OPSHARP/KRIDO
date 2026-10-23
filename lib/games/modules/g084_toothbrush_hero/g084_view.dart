import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g084_controller.dart';

class G084View extends StatefulWidget {
  final G084Controller controller;

  const G084View({super.key, required this.controller});

  @override
  State<G084View> createState() => _G084ViewState();
}

class _G084ViewState extends State<G084View> with TickerProviderStateMixin {
  late AnimationController _sparkleCtrl;

  @override
  void initState() {
    super.initState();
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparkleCtrl.dispose();
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
          title: isHindi ? 'टूथब्रश हीरो! 🪥' : 'Toothbrush Hero! 🪥',
          subtitle: isHindi
              ? 'हर दांत को पिकपिक साफ करो!'
              : 'Brush every tooth zone sparkling clean!',
          onBack: () => Navigator.pop(context),
          child: Column(
            children: [
                        // Progress bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isHindi ? 'साफ किए: ${ctrl.totalBrushed}/${ctrl.zones.length}' : 'Cleaned: ${ctrl.totalBrushed}/${ctrl.zones.length}',
                                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textNavy),
                              ),
                              Row(
                                children: List.generate(ctrl.zones.length, (i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      i < ctrl.totalBrushed ? Icons.star_rounded : Icons.star_border_rounded,
                                      color: i < ctrl.totalBrushed ? Colors.amber : Colors.grey.shade300,
                                      size: 22,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                        // Mouth visualization
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: const Color(0xFFFFCC02), width: 3),
                            ),
                            child: Column(
                              children: [
                                // Title
                                Text(
                                  '😬',
                                  style: const TextStyle(fontSize: 36),
                                ),
                                const SizedBox(height: 8),
                                // Tooth Grid (2 rows x 3 cols)
                                Expanded(
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 1.05,
                                    ),
                                    itemCount: ctrl.zones.length,
                                    itemBuilder: (context, index) {
                                      final zone = ctrl.zones[index];
                                      final progress = ctrl.getZoneProgress(zone.id);
                                      final isActive = ctrl.activeZoneId == zone.id;
                                      final isHinted = ctrl.hintHighlightId == zone.id;

                                      return GestureDetector(
                                        onTap: () => ctrl.brushZone(zone.id),
                                        onPanUpdate: (_) => ctrl.brushZone(zone.id),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            color: zone.isBrushed
                                                ? const Color(0xFFE8F5E9)
                                                : isActive
                                                    ? const Color(0xFFE3F2FD)
                                                    : Colors.white,
                                            border: Border.all(
                                              color: zone.isBrushed
                                                  ? const Color(0xFF66BB6A)
                                                  : isActive
                                                      ? const Color(0xFF42A5F5)
                                                      : isHinted
                                                          ? Colors.greenAccent
                                                          : const Color(0xFFE0E0E0),
                                              width: isActive || isHinted ? 3 : 2,
                                            ),
                                            boxShadow: isActive
                                                ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)]
                                                : [],
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  AnimatedBuilder(
                                                    animation: _sparkleCtrl,
                                                    builder: (context, child) {
                                                      if (!zone.isBrushed) return child!;
                                                      return Transform.scale(
                                                        scale: 1.0 + 0.1 * _sparkleCtrl.value,
                                                        child: child,
                                                      );
                                                    },
                                                    child: Text(
                                                      zone.isBrushed ? '✨' : '🦷',
                                                      style: const TextStyle(fontSize: 26),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    isHindi ? zone.nameHi : zone.nameEn,
                                                    style: GoogleFonts.nunito(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppTheme.textNavy,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  if (!zone.isBrushed) ...[
                                                    const SizedBox(height: 3),
                                                    SizedBox(
                                                      width: 48,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(4),
                                                        child: LinearProgressIndicator(
                                                          value: progress,
                                                          backgroundColor: Colors.grey.shade200,
                                                          valueColor: AlwaysStoppedAnimation<Color>(
                                                            isActive ? Colors.blue : Colors.grey,
                                                          ),
                                                          minHeight: 5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Instruction
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            isHindi
                                ? '🪥 चमकते दांत पर बार-बार टैप/स्वाइप करो!'
                                : '🪥 Tap or swipe on the glowing tooth!',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}
