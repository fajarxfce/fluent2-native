import 'package:fluent_catalog/catalog.dart';
import 'package:fluent2_flutter/fluent2_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    testWidgets(
      'catalog renders and filters at width $width in all theme modes',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const FluentCatalog());
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull);
        for (var index = 0; index < 4; index++) {
          if (index == 1 || index == 3) {
            await tester.tap(
              find.byWidgetPredicate(
                (widget) =>
                    widget is FluentButton &&
                    (widget.semanticLabel == 'Switch to dark theme' ||
                        widget.semanticLabel == 'Switch to light theme'),
              ),
            );
          } else if (index == 2) {
            await tester.tap(
              find.byWidgetPredicate(
                (widget) =>
                    widget is FluentButton &&
                    widget.semanticLabel == 'Switch to Teams theme',
              ),
            );
          }
          await tester.pump(const Duration(milliseconds: 250));
          expect(tester.takeException(), isNull);
        }
        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is FluentSwitch && widget.label == 'Compact density',
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull);
        final search = find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is FluentInput && widget.label == 'Search components',
          ),
          matching: find.byType(EditableText),
        );
        await tester.enterText(search, 'Dropdown');
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.text('Button'), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is FluentCard && widget.title == 'Dropdown',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.enterText(search, 'no-such-component');
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          find.text('No matching components. Try another search.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
