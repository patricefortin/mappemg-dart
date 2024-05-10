// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // testWidgets('Toggle Debug mode', (WidgetTester tester) async {
  //   await tester.runAsync(() async {
  //     String searchStr = 'Vibration';
  //     await tester.pumpWidget(makeApp());
  //     expect(find.textContaining(searchStr), findsNothing);

  //     await tester.tap(find.byIcon(toggleFullModeIcon));
  //     await tester.pump();
  //     expect(find.textContaining(searchStr), findsOneWidget);

  //     await tester.tap(find.byIcon(toggleFullModeIcon));
  //     await tester.pump();
  //     expect(find.textContaining(searchStr), findsNothing);
  //   });
  // });

  // testWidgets('Rotate in Debug screens', (WidgetTester tester) async {
  //   await tester.runAsync(() async {
  //     String searchStr = 'uuid';
  //     await tester.pumpWidget(makeApp());

  //     // Enable Debug mode
  //     await tester.tap(find.byIcon(toggleFullModeIcon));
  //     await tester.pump();

  //     // Tap Debug tool icon
  //     await tester.tap(find.byIcon(
  //         Icons.vibration)); // This should target a container, not an icon
  //     await tester.pump();

  //     // Check we have the second screen
  //     expect(find.textContaining(searchStr), findsOneWidget);
  //   });
  // });
}
