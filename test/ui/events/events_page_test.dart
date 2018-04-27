import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkinoRx/data/actor.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/mainpage/app_model.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/widgets/common/info_message_view.dart';
import 'package:inkinoRx/widgets/common/loading_view.dart';
import 'package:inkinoRx/widgets/event_details/event_details_page.dart';
import 'package:inkinoRx/widgets/events/event_grid.dart';
import 'package:inkinoRx/widgets/events/events_page.dart';
import 'package:mockito/mockito.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';

import '../../test_utils.dart';

class MockAppModel extends Mock implements AppModel {}

class NavigatorPushObserver extends NavigatorObserver {
  Route<dynamic> lastPushedRoute;

  void reset() => lastPushedRoute = null;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    lastPushedRoute = route;
  }
}

void main() {
  group('EventGrid', () {
    final List<Event> events = <Event>[
      new Event(
        id: '1',
        title: 'Test Title',
        genres: 'Test Genres',
        directors: <String>[],
        actors: <Actor>[],
        images: new EventImageData.empty(),
        youtubeTrailers: <String>[],
      ),
    ];

    NavigatorPushObserver observer;
    MockAppModel mockAppModel;

    setUp(() {
      io.HttpOverrides.global = new TestHttpOverrides();

      observer = new NavigatorPushObserver();
      mockAppModel = new MockAppModel();
    });

    Future<Null> _buildEventsPage(WidgetTester tester) {
      final widget = new ModelProvider(
      model: mockAppModel,
      child: new MaterialApp(
        home: new EventsPage(EvenListTypes.InTheater),
        navigatorObservers: <NavigatorObserver>[observer],
      ));
      return tester.pumpWidget(widget);
    }

    testWidgets(
      'when there are no events, should show empty view',
      (WidgetTester tester) async {
        when(mockAppModel.inTheaterEvents).thenAnswer((_)=> 
            new Observable<CommandResult<List<Event>>>.just(new CommandResult(<Event>[],null,false )));

        await _buildEventsPage(tester);
        await tester.pump(); // because of the Streambuilder we have to pump once more
        

        expect(find.byKey(EventGrid.emptyViewKey), findsOneWidget);
        expect(find.byKey(EventGrid.contentKey), findsNothing);

        LoadingViewState state = tester.state(find.byType(LoadingView));
        expect(state.errorContentVisible, isFalse);
      },
    );

    testWidgets(
      'when events exist, should show them',
      (WidgetTester tester) async {
        when(mockAppModel.inTheaterEvents).thenAnswer((_)=> 
            new Observable<CommandResult<List<Event>>>.just(new CommandResult(events,null,false )));

        await _buildEventsPage(tester);
        await tester.pump(); // because of the Streambuilder we have to pump once more

        expect(find.byKey(EventGrid.contentKey), findsOneWidget);
        expect(find.byKey(EventGrid.emptyViewKey), findsNothing);
        expect(find.text('Test Title'), findsOneWidget);

        LoadingViewState state = tester.state(find.byType(LoadingView));
        expect(state.errorContentVisible, isFalse);
      },
    );

    testWidgets(
      'when tapping on an event poster, should navigate to event details',
      (WidgetTester tester) async {
        when(mockAppModel.inTheaterEvents).thenAnswer((_)=> 
            new Observable<CommandResult<List<Event>>>.just(new CommandResult(events,null,false )));

        await _buildEventsPage(tester);
        await tester.pump(); // because of the Streambuilder we have to pump once more

        // Building the events page makes the last pushed route non-null,
        // so we'll reset at this point.
        observer.reset();
        expect(observer.lastPushedRoute, isNull);

        await tester.tap(find.text('Test Title'));
        await tester.pumpAndSettle();

        expect(observer.lastPushedRoute, isNotNull);
        expect(find.byType(EventDetailsPage), findsOneWidget);
      },
    );

    testWidgets(
      'when clicking "try again" on the error view, should call refreshEvents on the view model',
      (WidgetTester tester) async {
        final command = new MockCommand<Null,List<Event>>();

        when(mockAppModel.updateEventsCommand()).thenAnswer((_)=> command());
        
        when(mockAppModel.inTheaterEvents).thenAnswer((_)=> 
            new Observable<CommandResult<List<Event>>>.just(new CommandResult(null,new Exception(),false )));

        await _buildEventsPage(tester);
        await tester.pump(); // because of the Streambuilder we have to pump once more
        await tester.pump();

        LoadingViewState state = tester.state(find.byType(LoadingView));
        expect(state.errorContentVisible, isTrue);

        await tester.tap(find.byKey(ErrorView.tryAgainButtonKey));
        await tester.pump(); 
        
        expect(command.executionCount, 1);
      },
    );
  });
}
