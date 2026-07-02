import 'dart:ui' show Tristate;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SegmentedPills', () {
    Widget buildSubject({
      required String selected,
      required ValueChanged<String> onSelected,
    }) {
      return MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SegmentedPills<String>(
            selected: selected,
            onSelected: onSelected,
            options: const [
              SegmentOption(value: 'movies', label: 'Movies'),
              SegmentOption(value: 'series', label: 'Series'),
            ],
          ),
        ),
      );
    }

    testWidgets(
      'given a selected option, then it is marked as selected in semantics',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(selected: 'movies', onSelected: (_) {}),
        );

        final movies = tester.getSemantics(find.text('Movies'));
        final series = tester.getSemantics(find.text('Series'));

        expect(movies.flagsCollection.isSelected, Tristate.isTrue);
        expect(series.flagsCollection.isSelected, Tristate.isFalse);
      },
    );

    testWidgets(
      'given the inactive option, when tapped, then onSelected reports its '
      'value',
      (tester) async {
        String? selectedValue;
        await tester.pumpWidget(
          buildSubject(
            selected: 'movies',
            onSelected: (value) => selectedValue = value,
          ),
        );

        await tester.tap(find.text('Series'));

        expect(selectedValue, 'series');
      },
    );
  });
}
