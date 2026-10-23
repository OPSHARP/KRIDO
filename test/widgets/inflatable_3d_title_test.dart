import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/widgets/inflatable_3d_title.dart';

void main() {
  testWidgets('Inflatable3DTitle renders KRIDO letters and crown', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Inflatable3DTitle(scale: 1.0, showSubtitle: true),
          ),
        ),
      ),
    );

    // Verify all 5 KRIDO balloon letters
    expect(find.text('K'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
    expect(find.text('I'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('O'), findsOneWidget);

    // Verify royal crown and subtitle
    expect(find.text('👑'), findsOneWidget);
    expect(find.text('Play • Learn • Discover'), findsOneWidget);
  });
}
