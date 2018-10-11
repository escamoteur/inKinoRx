import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkinoRx/data/theater.dart';
import 'package:inkinoRx/app/app_model.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/widgets/theater_list/theater_list.dart';
import 'package:mockito/mockito.dart';
import 'package:rx_command/rx_command.dart';

class MockAppModel extends Mock implements AppManager {}

void main() {
  group('TheaterList', () {
    final List<Theater> theaters = <Theater>[
      new Theater(id: '1', name: 'Test Theater #1'),
      new Theater(id: '2', name: 'Test Theater #2'),
    ];

    MockAppModel mockAppModel;
    bool theaterTappedCallbackCalled;

    setUp(() {
      mockAppModel = new MockAppModel();
      when(mockAppModel.currentTheater).thenReturn(null);
      when(mockAppModel.allTheaters).thenReturn(<Theater>[]);

      theaterTappedCallbackCalled = false;
    });

    Future<Null> _buildTheaterList(WidgetTester tester) {
      final widget = new ModelProvider(
      model: mockAppModel,
      child: new MaterialApp(
              home: new TheaterList(
              header: new Container(),
              onTheaterTapped: () {
              theaterTappedCallbackCalled = true;
          },
        ),
      ));
      return tester.pumpWidget(widget);
    }

    testWidgets(
      'when theaters exist, should show theam in the UI',
      (WidgetTester tester) async {
        when(mockAppModel.currentTheater).thenReturn(theaters.first);
        when(mockAppModel.allTheaters).thenReturn(theaters);

        await _buildTheaterList(tester);

        expect(find.text('Test Theater #1'), findsOneWidget);
        expect(find.text('Test Theater #2'), findsOneWidget);
      },
    );

    testWidgets(
      'when theater tapped, should call both changeCurrentTheater and onTheaterTapped',
      (WidgetTester tester) async {
        final command = new MockCommand<Theater,Theater>();

        when(mockAppModel.currentTheater).thenReturn(theaters.first);
        when(mockAppModel.allTheaters).thenReturn(theaters);
        when(mockAppModel.changedCurrentTheatherCommand(typed(any))).thenAnswer((_)=> command(_.positionalArguments[0]));

        await _buildTheaterList(tester);

        await tester.tap(find.text('Test Theater #2'));

        var newTheater = command.lastPassedValueToExecute;

        expect(newTheater.id, '2');
        expect(newTheater.name, 'Test Theater #2');

        expect(theaterTappedCallbackCalled, isTrue);
      },
    );
  });
}
