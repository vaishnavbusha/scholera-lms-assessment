import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scholera_lms_assessment/app/scholera_app.dart';

void main() {
  testWidgets('shows the Scholera sign in screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ScholeraApp()));

    expect(find.text('Scholera'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
