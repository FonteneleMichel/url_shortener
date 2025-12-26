import 'package:flutter_test/flutter_test.dart';
import 'package:url_shortener/src/app.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('URL Shortener'), findsOneWidget);
  });
}
