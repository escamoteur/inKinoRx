import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkinoRx/data/actor.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/mainpage/app_model.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/widgets/event_details/event_details_page.dart';
import 'package:inkinoRx/widgets/event_details/showtime_information.dart';
import 'package:inkinoRx/widgets/events/event_poster.dart';

import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';

import '../../test_utils.dart';


class MockAppModel extends Mock implements AppModel {}


void main() {
  group('EventDetailsPage', () {
    String lastLaunchedTicketsUrl;
    String lastLaunchedTrailerUrl;

    MockAppModel mockAppModel;

    setUp(() {
      mockAppModel = new MockAppModel();
      io.HttpOverrides.global = new TestHttpOverrides();

      launchTicketsUrl = (url) => lastLaunchedTicketsUrl = url;
      launchTrailerVideo = (url) => lastLaunchedTrailerUrl = url;
    });

    tearDown(() {
      lastLaunchedTicketsUrl = null;
      lastLaunchedTrailerUrl = null;
    });

    Future<Null> _buildEventDetailsPage(
      WidgetTester tester, {
      @required List<String> trailers,
      @required Show show,
    }) {
      final widget = new ModelProvider(
      model: mockAppModel,
      child: new MaterialApp(
        home: new EventDetailsPage(
          new Event(
            id: '1',
            title: 'Test Title',
            genres: 'Test Genres',
            directors: <String>[],
            actors: <Actor>[],
            images: new EventImageData.empty(),
            youtubeTrailers: trailers,
          ),
          show: show,
        ),
      ));
      return tester.pumpWidget(widget);
    }

    testWidgets(
      'when navigated to with a null show, should not display showtime information widget in the UI',
      (WidgetTester tester) async {
        await _buildEventDetailsPage(tester, trailers: <String>[], show: null);

        expect(find.byType(ShowtimeInformation), findsNothing);
      },
    );

    testWidgets(
      'when navigated to with a non-null show, should display the showtime information in the UI',
      (WidgetTester tester) async {
        await _buildEventDetailsPage(
          tester,
          trailers: <String>[],
          show: new Show(
            start: new DateTime(2018),
            theaterAndAuditorium: 'Test theater',
          ),
        );

        var showtimeInfoFinder = find.byType(ShowtimeInformation);
        expect(showtimeInfoFinder, findsOneWidget);
        expect(
          find.descendant(
            of: showtimeInfoFinder,
            matching: find.text('Test theater'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'when pressing tickets button, should open the tickets link',
      (WidgetTester tester) async {
        await _buildEventDetailsPage(
          tester,
          trailers: <String>[],
          show: new Show(
            start: new DateTime(2018),
            theaterAndAuditorium: 'Test theater',
            url: 'https://finnkino.fi/test-tickets-url',
          ),
        );

        await tester.tap(find.byKey(ShowtimeInformation.ticketsButtonKey));
        expect(lastLaunchedTicketsUrl, 'https://finnkino.fi/test-tickets-url');
      },
    );

    testWidgets(
      'when pressing the play trailer button, should open the trailer link',
      (WidgetTester tester) async {
        await _buildEventDetailsPage(
          tester,
          trailers: <String>['https://youtube.com/?v=test-trailer'],
          show: new Show(
            start: new DateTime(2018),
            theaterAndAuditorium: 'Test theater',
          ),
        );

        await tester.tap(find.byKey(EventPoster.playButtonKey));
        await tester.pumpAndSettle();

        expect(lastLaunchedTrailerUrl, 'https://youtube.com/?v=test-trailer');
      },
    );
  });
}
