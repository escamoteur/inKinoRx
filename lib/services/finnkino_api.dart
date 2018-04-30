import 'dart:async';


import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/data/theater.dart';
import 'package:inkinoRx/services/http_utils.dart';
import 'package:inkinoRx/utils/clock.dart';
import 'package:intl/intl.dart';

class FinnkinoApi {
  static final DateFormat ddMMyyyy = new DateFormat('dd.MM.yyyy');

  static final Uri kScheduleBaseUrl =
      new Uri.https('www.finnkino.fi', '/en/xml/Schedule');
  static final Uri kEventsBaseUrl =
      new Uri.https('www.finnkino.fi', '/en/xml/Events');

  Future<List<Show>> _getSchedule(Theater theater, DateTime date) async {
    var dt = ddMMyyyy.format(date ?? new DateTime.now());
    var response = await getRequest(
      kScheduleBaseUrl.replace(queryParameters: {
        'area': theater.id,
        'dt': dt,
      }),
    );

    return Show.parseAll(response);
  }

  Future<List<Event>> getNowInTheatersEvents(Theater theater) async {
    var response = await getRequest(
      kEventsBaseUrl.replace(queryParameters: {
        'area': theater.id,
        'listType': 'NowInTheatres',
      }),
    );

    return Event.parseAll(response);
  }

  Future<List<Event>> getUpcomingEvents() async {
    var response = await getRequest(
      kEventsBaseUrl.replace(queryParameters: {
        'listType': 'ComingSoon',
      }),
    );

    return Event.parseAll(response);
  }

  Future<List<Show>> getShows(date, Theater theater) async 
                                {
                                  var now = Clock.getCurrentTime();
                                  date == date ?? now;
                                  var shows = await _getSchedule(theater, date);
  
                                    // Return only show times that haven't started yet.
                                  return shows.where((show) => show.start.isAfter(now)).toList();
                                }

}
