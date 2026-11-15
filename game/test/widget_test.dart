import 'package:flutter/material.dart';
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

  testWidgets('paying stages show balances bar, background, and event image',
      (WidgetTester tester) async {
    Future<void> tapVisible(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
    }

    await tester.pumpWidget(const RentDueApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tapVisible(find.text('Play — Run 1'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Week 1 payday'), findsOneWidget);
    expect(find.byType(BalancesBar), findsOneWidget);
    expect(find.text('Buffer Jar'), findsOneWidget);
    expect(find.text('Rent Tin'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);

    // Allocate $455: +$250 Rent Tin, +$50 Buffer Jar, rest to Week Cash.
    final plus50 = find.widgetWithText(OutlinedButton, '+50');
    for (var i = 0; i < 5; i++) {
      await tapVisible(plus50.at(0));
    }
    await tapVisible(plus50.at(1));
    for (var i = 0; i < 3; i++) {
      await tapVisible(plus50.at(2));
    }
    final plus10 = find.widgetWithText(OutlinedButton, '+10');
    await tapVisible(plus10.at(2));
    await tester.pump();

    await tapVisible(find.text('Split it'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Week 1 — the apartment'), findsOneWidget);

    await tapVisible(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Friday night'), findsOneWidget);
    expect(find.byType(BalancesBar), findsOneWidget);
    expect(find.byType(EventImageCard), findsOneWidget);
  });
}
