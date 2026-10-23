import 'package:flutter_test/flutter_test.dart';
import 'package:kids_king_pro/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppDatabase getProfiles initialization test', () async {
    final db = AppDatabase.instance;
    final profiles = await db.getProfiles();
    expect(profiles, isA<List>());
  });
}
