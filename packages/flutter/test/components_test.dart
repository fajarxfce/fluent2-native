import 'dart:async';
import 'dart:ui' show CheckedState;
import 'package:fluent2_flutter/fluent2_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {FluentTokens tokens = FluentTokens.light}) =>
    MaterialApp(
      builder: (context, child) => FluentTheme(
        data: FluentThemeData(tokens: tokens, motion: false),
        child: child!,
      ),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 500, child: child),
        ),
      ),
    );

void main() {
  test(
    'badge overflow and progress reject invalid values at the public boundary',
    () {
      expect(formatFluentCount(100), '99+');
      expect(formatFluentCount(1000, 999), '999+');
      expect(formatFluentCount(0), '0');
      expect(() => formatFluentCount(-1), throwsArgumentError);
      expect(() => formatFluentCount(1, 0), throwsArgumentError);
      expect(normalizeFluentPercent(-10), 0);
      expect(normalizeFluentPercent(110), 100);
      expect(() => normalizeFluentPercent(double.nan), throwsArgumentError);
      expect(
        () => normalizeFluentPercent(double.infinity),
        throwsArgumentError,
      );
    },
  );

  testWidgets(
    'button supports keyboard activation and suppresses loading submissions',
    (tester) async {
      var calls = 0;
      var loading = false;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return FluentButton(
                autofocus: true,
                loading: loading,
                onPressed: () => calls++,
                child: const FluentText('Save'),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 1);
      update(() => loading = true);
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(calls, 1);
      update(() => loading = false);
      await tester.pump();
      await tester.tap(find.text('Save'));
      expect(calls, 2);
    },
  );

  testWidgets('indeterminate checkbox exposes semantics and becomes checked', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    bool? checked;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => FluentCheckbox(
            value: checked,
            label: 'Choice',
            onChanged: (value) => setState(() => checked = value),
          ),
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.byType(FluentCheckbox))
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.mixed,
    );
    await tester.tap(find.text('Choice'));
    await tester.pump();
    expect(checked, isTrue);
    expect(
      tester
          .getSemantics(find.byType(FluentCheckbox))
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isTrue,
    );
    await tester.tap(find.text('Choice'));
    expect(checked, isFalse);
    semantics.dispose();
  });

  testWidgets('switch does not mutate when disabled or loading', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      host(
        Column(
          children: [
            FluentSwitch(
              value: true,
              enabled: false,
              label: 'Disabled',
              onChanged: (_) => changes++,
            ),
            FluentSwitch(
              value: false,
              loading: true,
              label: 'Busy',
              onChanged: (_) => changes++,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(FluentSwitch).first);
    await tester.tap(find.byType(FluentSwitch).last);
    expect(changes, 0);
  });

  testWidgets(
    'input emits clear, preserves external controllers and supports replacement',
    (tester) async {
      final first = TextEditingController(text: 'first@example.com');
      final second = TextEditingController(text: 'second@example.com');
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      TextEditingController controller = first;
      late StateSetter update;
      String? changed;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return FluentInput(
                controller: controller,
                label: 'Email',
                allowClear: true,
                onChanged: (value) => changed = value,
              );
            },
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Clear input'));
      await tester.pump();
      expect(first.text, '');
      expect(changed, '');
      update(() => controller = second);
      await tester.pump();
      expect(find.text('second@example.com'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      first.text = 'still alive';
      second.text = 'still alive';
    },
  );

  testWidgets('read-only input has no destructive clear affordance', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Read only');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        FluentInput(controller: controller, allowClear: true, readOnly: true),
      ),
    );
    expect(find.bySemanticsLabel('Clear input'), findsNothing);
    await tester.enterText(find.byType(TextField), 'changed');
    expect(controller.text, 'Read only');
  });

  testWidgets(
    'segmented keyboard navigation skips disabled options and wraps',
    (tester) async {
      var selected = 1;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => FluentToggleGroup(
              value: selected,
              options: const [
                FluentOption(1, 'One'),
                FluentOption(2, 'Two', enabled: false),
                FluentOption(3, 'Three'),
              ],
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(selected, 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(selected, 1);
    },
  );

  testWidgets('select opens in dark theme and commits only enabled options', (
    tester,
  ) async {
    var selected = 'a';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => FluentDropdown(
            value: selected,
            label: 'Role',
            options: const [
              FluentOption('a', 'Designer'),
              FluentOption('b', 'Developer'),
              FluentOption('c', 'Archived', enabled: false),
            ],
            onChanged: (value) => setState(() => selected = value),
          ),
        ),
        tokens: FluentTokens.dark,
      ),
    );
    await tester.tap(find.byType(FluentDropdown<String>));
    await tester.pumpAndSettle();
    final optionContext = tester.element(find.text('Developer'));
    expect(FluentTheme.tokensOf(optionContext).isDark, isTrue);
    await tester.tap(find.text('Archived'));
    expect(selected, 'a');
    await tester.tap(find.text('Developer'));
    await tester.pumpAndSettle();
    expect(selected, 'b');
    expect(find.text('Archived'), findsNothing);
  });

  testWidgets(
    'async modal prevents duplicate work and dismissal, then allows retry',
    (tester) async {
      final pending = Completer<void>();
      var attempts = 0;
      bool? result;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => FluentButton(
              onPressed: () async {
                result = await showFluentDialog(
                  context: context,
                  title: 'Confirm',
                  confirmText: 'Save',
                  builder: (_) => const FluentText('Workspace details'),
                  errorMessage: (_) => 'Please retry.',
                  onConfirm: () {
                    attempts++;
                    return attempts == 1
                        ? pending.future
                        : Future<void>.value();
                  },
                );
              },
              child: const FluentText('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.tapAt(const Offset(2, 2));
      await tester.pump();
      expect(attempts, 1);
      expect(find.byType(Dialog), findsOneWidget);
      pending.completeError(StateError('network'));
      await tester.pumpAndSettle();
      expect(find.text('Please retry.'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      expect(attempts, 2);
      expect(find.byType(Dialog), findsNothing);
    },
  );
}
