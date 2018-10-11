import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/app/app_model.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/widgets/common/info_message_view.dart';
import 'package:inkinoRx/widgets/common/loading_view.dart';
import 'package:inkinoRx/widgets/showtimes/showtime_list.dart';
import 'package:inkinoRx/widgets/showtimes/showtimes_page.dart';
import 'package:mockito/mockito.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';

class MockAppModel extends Mock implements AppManager {}


void main() {
  group('ShowtimesPage', () {
    MockAppModel mockAppModel;


    setUp(() {
      mockAppModel = new MockAppModel();
      when(mockAppModel.showDates).thenReturn(<DateTime>[]);
      when(mockAppModel.selectedDate).thenReturn(new DateTime(2018));
      when(mockAppModel.showsToDisplay).thenAnswer((_) => <Show>[]);
    });

    Future<Null> _buildShowtimesPage(WidgetTester tester) {
      final widget = new ModelProvider(
      model: mockAppModel,
      child: new MaterialApp(
              home: new ShowtimesPage()
      ));
      return tester.pumpWidget(widget);
    }

    testWidgets(
      'when there are no shows, should show empty view',
      (WidgetTester tester) async {
        
        when(mockAppModel.showsToDisplay).thenAnswer((_)=> 
            new Observable<CommandResult<List<Show>>>.just(new CommandResult(<Show>[],null,false )));

        await _buildShowtimesPage(tester);
        await tester.pump(); // because of the Streambuilder we have to pump once more

        expect(find.byKey(ShowtimeList.emptyViewKey), findsOneWidget);
        expect(find.byKey(ShowtimeList.contentKey), findsNothing);

        LoadingViewState state = tester.state(find.byType(LoadingView));
        expect(state.errorContentVisible, isFalse);
      },
    );

    testWidgets('when shows exist, should show them',
        (WidgetTester tester) async {

        when(mockAppModel.showsToDisplay).thenAnswer((_)=> 
            new Observable<CommandResult<List<Show>>>.just(
              new CommandResult(<Show>[
                new Show(
                          title: 'Show title',
                          theaterAndAuditorium: 'Auditorium One',
                          presentationMethod: '2D',
                          start: new DateTime(2018),
                          end: new DateTime(2018),
                        ),
                ],
                null,false )));
          

      await _buildShowtimesPage(tester);
      await tester.pump(); // because of the Streambuilder we have to pump once more

      expect(find.byKey(ShowtimeList.contentKey), findsOneWidget);
      expect(find.byKey(ShowtimeList.emptyViewKey), findsNothing);
      expect(find.text('Show title'), findsOneWidget);

      LoadingViewState state = tester.state(find.byType(LoadingView));
      expect(state.errorContentVisible, isFalse);
    });

    testWidgets(
      'when clicking "try again" on the error view, should call refreshShowtimes on the view model',
      (WidgetTester tester) async {

        final command = new MockCommand<DateTime,List<Show>>();

        when(mockAppModel.updateShowTimesCommand(typed(any))).thenAnswer((_)=> command(_.positionalArguments[0]));


        when(mockAppModel.showsToDisplay).thenAnswer((_)=> 
            new Observable<CommandResult<List<Show>>>.just(new CommandResult(<Show>[],new Exception(),false )));

        await _buildShowtimesPage(tester);
        await tester.pump(); // because of the Streambuilder we have to pump once more

        LoadingViewState state = tester.state(find.byType(LoadingView));
        expect(state.errorContentVisible, isTrue);

        await tester.tap(find.byKey(ErrorView.tryAgainButtonKey));
        await tester.pump(); 

        expect(command.executionCount, 1);
        expect(command.lastPassedValueToExecute, new DateTime(2018));
      },
    );
  });
}
