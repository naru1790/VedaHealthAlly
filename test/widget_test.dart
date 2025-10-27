// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:veda_ai/main.dart';

void main() {
  testWidgets('Veda AI app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VedaAIApp());

    // Verify that the app name appears
    expect(find.text('Veda AI'), findsOneWidget);
    
    // Verify that the tagline appears
    expect(find.text('Vitality Enhancing Digital Ally'), findsOneWidget);
  });
}
