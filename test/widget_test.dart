import 'package:flutter_test/flutter_test.dart';

import 'package:torcav/core/di/injection.dart';
import 'package:torcav/main.dart';

void main() {
  testWidgets('app shell renders dashboard tab', (tester) async {
    configureDependencies();
    await tester.pumpWidget(const TorcavApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Torcav Command Center'), findsOneWidget);
  });
}
