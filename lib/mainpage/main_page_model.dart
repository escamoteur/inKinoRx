import 'dart:async';

import 'package:flutter/services.dart';
import 'package:inkinoRx/assets.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/data/theater.dart';
import 'package:inkinoRx/services/finnkino_api.dart';
import 'package:inkinoRx/services/tmdb_api.dart';
import 'package:inkinoRx/utils/clock.dart';
import 'package:rx_command/rx_command.dart';


import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';




class MainPageModel {
   static const String kDefaultTheaterId = 'default_theater_id';

  final AssetBundle _bundle;
  final SharedPreferences _preferences;
  final FinnkinoApi _finnkinoApi;
  final  TMDBApi _tmdbApi;

  RxCommand<Theater,Theater> changedDefaultTheatherCommand;
  RxCommand<Null,List<Event>> updateEventsCommand;
  RxCommand<Null,List<Event>> updateUpcomingEventsCommand;
  RxCommand<DateTime,List<Show>> updateShowTimesCommand;
  
  List<Theater> allTheaters;
  Theater defaultTheater;

  List<DateTime> showDates;
  DateTime selectedDate;

  

  MainPageModel(this._bundle,this._preferences,this._tmdbApi,this._finnkinoApi)
  {
     changedDefaultTheatherCommand = RxCommand.createSync3<Theater,Theater>((x)=>x);
     changedDefaultTheatherCommand
       .results.listen((newDefaultTheater) {
          defaultTheater = newDefaultTheater;
          updateEventsCommand.execute();
          updateUpcomingEventsCommand.execute();
          updateShowTimesCommand.execute(showDates[0]);
       });
         

    updateEventsCommand = RxCommand.createAsync2<List<Event>>( 
                                        () async => _finnkinoApi.getNowInTheatersEvents(defaultTheater)); 

    updateUpcomingEventsCommand = RxCommand.createAsync2<List<Event>>( 
                                        () async => _finnkinoApi.getUpcomingEvents());                                                                             



    updateShowTimesCommand = RxCommand.createAsync3<DateTime,List<Show>>( (date) async 
                                  {
                                    var now = Clock.getCurrentTime();
                                    date == date ?? now;
                                    var shows = await _finnkinoApi.getSchedule(defaultTheater, date);

                                    selectedDate = date;    
                                    // Return only show times that haven't started yet.
                                    return shows.where((show) => show.start.isAfter(now)).toList();
                                  }, emitLastResult: true);
                                  
  }

  Future init() async {
    await _bundle.loadString(OtherAssets.preloadedTheaters)
              .then( (theaterXml) => Theater.parseAll(theaterXml))
              .then( (theaters) {
                allTheaters = theaters;
                changedDefaultTheatherCommand.execute(_getDefaultTheater(theaters));
              });

    var now = Clock.getCurrentTime();
    showDates = new List.generate(7,(index) => now.add(new Duration(days: index)),);


  }

 
 Event getEventForShow(Show show)
 {
    var currentEvents = updateEventsCommand.lastResult;
    if (currentEvents == null)
    { 
      return null;
    }
    return currentEvents.where( (event) => event.id == show.eventId).first;
 }

 
  Theater _getDefaultTheater(List<Theater> allTheaters) {
    var persistedTheaterId = _preferences.getString(kDefaultTheaterId);

    if (persistedTheaterId != null) {
      return allTheaters.singleWhere((theater) {
        return theater.id == persistedTheaterId;
      });
    }

    return allTheaters.first;
  }
  
}




