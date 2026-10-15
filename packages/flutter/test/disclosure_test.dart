import 'package:fluent2_flutter/fluent2_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => MaterialApp(
  home: FluentTheme(
    data: const FluentThemeData(motion: false),
    child: Scaffold(body: SizedBox(width: 320, child: child)),
  ),
);
void main() {
  testWidgets(
    'accordion skips disabled headers and maintains single expansion',
    (tester) async {
      var expanded = <String>{'a'};
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => FluentAccordion(
              items: const [
                FluentAccordionItem(
                  id: 'a',
                  title: 'First',
                  child: FluentText('First details'),
                ),
                FluentAccordionItem(
                  id: 'b',
                  title: 'Unavailable',
                  enabled: false,
                  child: FluentText('Unavailable details'),
                ),
                FluentAccordionItem(
                  id: 'c',
                  title: 'Last',
                  child: FluentText('Last details'),
                ),
              ],
              expanded: expanded,
              onChanged: (value) => setState(() => expanded = value),
            ),
          ),
        ),
      );
      final first = tester.widget<FluentButton>(
        find.ancestor(
          of: find.text('First'),
          matching: find.byType(FluentButton),
        ),
      );
      first.focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      final last = tester.widget<FluentButton>(
        find.ancestor(
          of: find.text('Last'),
          matching: find.byType(FluentButton),
        ),
      );
      expect(last.focusNode!.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(expanded, {'c'});
      expect(find.text('First details'), findsNothing);
      expect(find.text('Last details'), findsOneWidget);
      await tester.tap(find.text('Last'));
      await tester.pump();
      expect(expanded, isEmpty);
    },
  );
  testWidgets(
    'textarea preserves line breaks and external controller ownership',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(FluentTextarea(controller: controller, label: 'Notes')),
      );
      await tester.enterText(
        find.byType(EditableText),
        'First line\nSecond line',
      );
      expect(controller.text, 'First line\nSecond line');
      await tester.pumpWidget(const SizedBox.shrink());
      controller.text = 'Still owned by the host';
      expect(controller.text, 'Still owned by the host');
    },
  );
  testWidgets('breadcrumb invokes ancestors while current page stays static', (
    tester,
  ) async {
    var destination = '';
    await tester.pumpWidget(
      host(
        FluentBreadcrumb(
          items: const [
            FluentBreadcrumbItem('home', 'Home'),
            FluentBreadcrumbItem('here', 'Components'),
          ],
          onNavigate: (id) => destination = id,
        ),
      ),
    );
    await tester.tap(find.text('Home'));
    expect(destination, 'home');
    expect(
      find.ancestor(
        of: find.text('Components'),
        matching: find.byType(FluentLink),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
