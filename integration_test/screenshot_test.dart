import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quietspace/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture screenshots', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Capture Home (Breathing) Screen
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    // Note: To save this screenshot to disk, you'd typically use a driver script.
    // However, for this simplified test, we are just navigating.
    // The user can run "flutter screenshot" manually at these pauses if running interactively,
    // or we can use the binding to save to device.

    // We'll just pause briefly to ensure UI is rendered
    await Future.delayed(const Duration(seconds: 2));

    // 2. Navigate to Grow Page
    final growTab = find.byIcon(Icons.local_florist);
    await tester.tap(growTab);
    await tester.pumpAndSettle();

    // Allow animation to finish
    await Future.delayed(const Duration(seconds: 2));

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  });
}
