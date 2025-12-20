// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:usl_tutor_app/main.dart';

void main() {
  testWidgets('Splash shows app name and navigates to onboarding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const USLTutorApp());

    expect(find.text('USL Tutor'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.textContaining('Learn Sign Language'), findsOneWidget);
  });
}
