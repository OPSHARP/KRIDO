import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/cartoon_ui_components.dart';
import 'g082_controller.dart';

class G082View extends StatefulWidget {
  final G082Controller controller;

  const G082View({super.key, required this.controller});

  @override
  State<G082View> createState() => _G082ViewState();
}

class _G082ViewState extends State<G082View> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isHindi = ctrl.profile.uiLocale == 'hi';
        final unmatchedAnimals = ctrl.animals.where((a) => !a.isMatched).toList();

        return CartoonGameScaffold(
          title: isHindi ? 'जानवर और उनके घर! 🏡' : 'Animal Habitat Match! 🏡',
          subtitle: isHindi
              ? 'प्रत्येक जानवर को उसके प्यारे घर तक पहुँचाएँ!'
              : 'Match each friendly animal to their cozy natural home!',
          onBack: () => Navigator.pop(context),
          child: Column(
            children: [
              // 1. Animals Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'जानवरों को चुनें: 🐾' : 'Pick an Animal: 🐾',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textNavy,
                      ),
                    ),
                    Text(
                      '${ctrl.animals.length - unmatchedAnimals.length} / ${ctrl.animals.length} ⭐',
                      style: GoogleFonts.bubblegumSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 2.5),
                  ),
                  child: unmatchedAnimals.isEmpty
                      ? Center(
                          child: Text(
                            isHindi ? '🎉 सभी जानवर अपने घर पहुँच गए!' : '🎉 All Animals Are Safe at Home!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.bubblegumSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: unmatchedAnimals.map((animal) {
                            final isSelected = ctrl.activeSelectedAnimal?.id == animal.id;

                            final animalCard = GestureDetector(
                              onTap: () => ctrl.selectAnimal(animal),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 72,
                                height: 95,
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
                                    Text(animal.emoji, style: const TextStyle(fontSize: 36)),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Text(
                                        isHindi ? animal.nameHi : animal.nameEn,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.nunito(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textNavy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            return Draggable<HabitatAnimal>(
                              data: animal,
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
                                      child: Text(animal.emoji, style: const TextStyle(fontSize: 42)),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: animalCard,
                              ),
                              child: animalCard,
                            );
                          }).toList(),
                        ),
                ),
              ),

              // 2. Habitats Grid
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isHindi ? 'उनके घर: 🏡' : 'Their Cozy Homes: 🏡',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textNavy,
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.25,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: ctrl.habitats.length,
                    itemBuilder: (context, idx) {
                      final habitat = ctrl.habitats[idx];
                      final isHinted = ctrl.hintHighlightId == habitat.id;
                      final matchedAnimal = ctrl.animals.cast<HabitatAnimal?>().firstWhere(
                            (a) => a?.targetHabitatId == habitat.id && a!.isMatched,
                            orElse: () => null,
                          );

                      return DragTarget<HabitatAnimal>(
                        onWillAcceptWithDetails: (_) => true,
                        onAcceptWithDetails: (details) {
                          ctrl.matchAnimalToHabitat(details.data, habitat);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovered = candidateData.isNotEmpty;

                          return GestureDetector(
                            onTap: () {
                              if (ctrl.activeSelectedAnimal != null) {
                                ctrl.matchAnimalToHabitat(ctrl.activeSelectedAnimal!, habitat);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: Color(habitat.colorHex).withOpacity(isHovered ? 0.95 : 0.85),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isHinted || isHovered ? Colors.white : Colors.white.withOpacity(0.6),
                                  width: isHinted || isHovered ? 4.0 : 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(habitat.colorHex).withOpacity(0.35),
                                    blurRadius: isHovered || isHinted ? 14 : 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(habitat.emoji, style: const TextStyle(fontSize: 34)),
                                      if (matchedAnimal != null) ...[
                                        const SizedBox(width: 6),
                                        Text(matchedAnimal.emoji, style: const TextStyle(fontSize: 30)),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isHindi ? habitat.nameHi : habitat.nameEn,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.bubblegumSans(
                                      fontSize: 15,
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
                                  if (matchedAnimal != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isHindi ? 'सुरक्षित! 💖' : 'Safe at Home! 💖',
                                        style: GoogleFonts.nunito(
                                          fontSize: 10,
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
                      );
                    },
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
