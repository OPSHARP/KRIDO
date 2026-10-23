import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g081_controller.dart';

class G081View extends StatefulWidget {
  final G081Controller controller;

  const G081View({super.key, required this.controller});

  @override
  State<G081View> createState() => _G081ViewState();
}

class _G081ViewState extends State<G081View> with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isHindi = ctrl.profile.uiLocale == 'hi';
        final unsortedItems = ctrl.items.where((i) => !i.isSorted).toList();

        return CartoonGameScaffold(
          title: isHindi ? 'रंग छंटाई फैक्ट्री! 🏭' : 'Color Sorting Factory! 🏭',
          subtitle: isHindi
              ? 'वस्तुओं को सही रंग वाले डिब्बे में डालें!'
              : 'Sort each item into its matching colored bin!',
          onBack: () => Navigator.pop(context),
          child: Column(
            children: [
              // 1. Progress Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'बचे हुए सामान:' : 'Items to Sort:',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textNavy,
                      ),
                    ),
                    Text(
                      '${ctrl.items.length - unsortedItems.length} / ${ctrl.items.length} ⭐',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Conveyor Belt / Unsorted Items Carousel
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFB0BEC5), width: 3),
                  ),
                  child: unsortedItems.isEmpty
                      ? Center(
                          child: Text(
                            isHindi ? '🎉 सभी सामान छाँट दिए गए!' : '🎉 All Items Sorted!',
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        )
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.95,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: unsortedItems.length,
                          itemBuilder: (context, idx) {
                            final item = unsortedItems[idx];
                            final isSelected = ctrl.activeSelectedItem?.id == item.id;

                            final cardWidget = GestureDetector(
                              onTap: () {
                                ctrl.selectItem(item);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFFF9C4) : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFFFB300) : Colors.grey.shade300,
                                    width: isSelected ? 3.5 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(0xFFFFB300).withOpacity(0.35)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: isSelected ? 12 : 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item.emoji, style: const TextStyle(fontSize: 38)),
                                    const SizedBox(height: 4),
                                    Text(
                                      isHindi ? item.nameHi : item.nameEn,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textNavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            return Draggable<SortingItem>(
                              data: item,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Transform.scale(
                                  scale: 1.15,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(item.emoji, style: const TextStyle(fontSize: 42)),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: cardWidget,
                              ),
                              child: cardWidget,
                            );
                          },
                        ),
                ),
              ),

              // 3. Drop Target Bins
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: ctrl.bins.map((bin) {
                      final isHinted = ctrl.hintHighlightId == bin.id;

                      return Expanded(
                        child: DragTarget<SortingItem>(
                          onWillAcceptWithDetails: (_) => true,
                          onAcceptWithDetails: (details) {
                            ctrl.sortItemIntoBin(details.data, bin);
                          },
                          builder: (context, candidateData, rejectedData) {
                            final isHovered = candidateData.isNotEmpty;

                            return GestureDetector(
                              onTap: () {
                                if (ctrl.activeSelectedItem != null) {
                                  ctrl.sortItemIntoBin(ctrl.activeSelectedItem!, bin);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Color(bin.colorHex).withOpacity(isHovered ? 0.95 : 0.85),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isHinted || isHovered ? Colors.white : Colors.white.withOpacity(0.6),
                                    width: isHinted || isHovered ? 4.0 : 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(bin.colorHex).withOpacity(0.4),
                                      blurRadius: isHovered || isHinted ? 16 : 8,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(bin.emoji, style: const TextStyle(fontSize: 44)),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Text(
                                        isHindi ? bin.nameHi : bin.nameEn,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.bubblegumSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.3),
                                              offset: const Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isHindi ? 'यहाँ डालें' : 'Drop Here',
                                        style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
