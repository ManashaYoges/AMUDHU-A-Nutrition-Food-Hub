import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amudhu/main.dart';

void main() {
  testWidgets('Welcome screen renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    expect(find.text('AMUDHU'), findsOneWidget);
    expect(find.text('Your AI Food & Nutrition Companion'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
