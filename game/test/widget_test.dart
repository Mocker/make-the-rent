import 'package:flutter_test/flutter_test.dart';
import 'package:rent_due/main.dart';

void main() {
  testWidgets('title screen shows the game and both entry points',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RentDueApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('RENT DUE!'), findsOneWidget);
    expect(find.text('Play — Run 1'), findsOneWidget);
    expect(find.text('Practice Week 1'), findsOneWidget);
  });
}
