import 'package:app/src/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given the app, when it starts, then it renders the MARQUEE home',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MarqueeApp()));

      expect(find.text('MARQUEE'), findsOneWidget);
    },
  );
}
