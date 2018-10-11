import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/app/app_model.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/widgets/showtimes/showtime_date_selector.dart';

import 'package:mockito/mockito.dart';
import 'package:rx_command/rx_command.dart';

class MockAppModel extends Mock implements AppManager {}


MockAppModel mockAppModel;

void main() {
  group('ShowtimeDateSelector', () {
    final List<DateTime> dates = <DateTime>[
      new DateTime(2018, 1, 1),
      new DateTime(2018, 1, 2),
    ];

    MockAppModel mockAppModel;

    setUp(() {
      mockAppModel = new MockAppModel();
    });

    Future<Null> _buildDateSelector(WidgetTester tester) {
      final widget = new ModelProvider(
      model: mockAppModel,
      child: new MaterialApp(
        home: new ShowtimeDateSelector(),
      ));
      return tester.pumpWidget(widget);
      
    }

    testWidgets(
      'when there are dates, should show them in UI',
      (WidgetTester tester) async {
        when(mockAppModel.showDates).thenReturn(dates);

        await _buildDateSelector(tester);

        // Monday is the first day of 2018.
        expect(find.text('Mon'), findsOneWidget);
        expect(find.text('Tue'), findsOneWidget);
      },
    );

    testWidgets(
      'when tapping a date, calls changeCurrentDate on the viewmodel with new date',
      (WidgetTester tester) async {
       final command = new MockCommand<DateTime,List<Show>>();

        when(mockAppModel.showDates).thenReturn(dates);

        when(mockAppModel.updateShowTimesCommand(typed(any))).thenAnswer((_)=> command(_.positionalArguments[0]));

        await _buildDateSelector(tester);

        await tester.tap(find.text('Tue'));

        expect(command.lastPassedValueToExecute, new DateTime(2018, 1,2));

      },
    );
  });
}
