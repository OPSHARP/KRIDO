import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/app/app.dart';
import 'package:kids_king_pro/app/providers.dart';
import 'package:kids_king_pro/core/session/session_timer_service.dart';

void main() {
  testWidgets('KRIDO app launches and renders splash brand',
      (WidgetTester tester) async {
    final timerService = SessionTimerService();
    // Do not start recurring timer in widget test

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionTimerServiceProvider.overrideWith((ref) => timerService),
        ],
        child: const KridoApp(),
      ),
    );

    expect(find.text('KRIDO'), findsOneWidget);
    expect(find.text('Play • Learn • Discover'), findsOneWidget);

    // Pump to complete splash animations and navigation timers
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
  });
}
