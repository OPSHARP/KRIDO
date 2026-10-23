import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/widgets/interactive_prince_leo.dart';
import 'package:kids_king_pro/features/mascot/leo_mascot_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Interactive 3D Pixar Prince Leo Tests', () {
    testWidgets('InteractivePrinceLeo renders 3D Pixar lion asset and blocks',
        (tester) async {
      bool leoTapped = false;
      bool blockTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: InteractivePrinceLeo(
                  size: 240,
                  onLeoTapped: () => leoTapped = true,
                  onBlockTapped: () => blockTapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify lion pet avatar renders
      expect(find.byType(InteractivePrinceLeo), findsOneWidget);
      expect(find.text('PET ME!'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);

      // Tap on Leo to trigger pet response
      await tester.tap(find.byType(InteractivePrinceLeo));
      await tester.pump();
      expect(leoTapped, true);

      // Tap on Block B
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(blockTapped, true);
    });

    testWidgets('LeoMascotWidget on Home Screen renders 3D avatar & play actions',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: LeoMascotWidget(locale: 'en'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify LeoMascotWidget and play action buttons exist
      expect(find.byType(LeoMascotWidget), findsOneWidget);
      expect(find.text('Feed 🍎'), findsOneWidget);
      expect(find.text('Ball 🎾'), findsOneWidget);
      expect(find.text('Dress 👑'), findsOneWidget);

      // Tap on Feed button
      await tester.tap(find.text('Feed 🍎'));
      await tester.pump();

      // Verify speech bubble updates to delicious munch reaction
      expect(find.textContaining('delicious apple!'), findsOneWidget);

      // Tap on Ball button
      await tester.tap(find.text('Ball 🎾'));
      await tester.pump();

      // Verify speech bubble updates to bounce reaction
      expect(find.textContaining('High bounce!'), findsOneWidget);
    });
  });
}
