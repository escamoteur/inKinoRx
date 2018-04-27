import 'dart:async';

import 'package:flutter/services.dart';
import 'package:inkinoRx/assets.dart';
import 'package:inkinoRx/data/actor.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/data/theater.dart';
import 'package:inkinoRx/services/finnkino_api.dart';
import 'package:inkinoRx/services/tmdb_api.dart';
import 'package:inkinoRx/utils/clock.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shared_preferences/shared_preferences.dart';




class AppModel {
   static const String kDefaultTheaterId = 'default_theater_id';

  final AssetBundle _bundle;
  final SharedPreferences _preferences;
  final FinnkinoApi _finnkinoApi;
  final  TMDBApi _tmdbApi;

  RxCommand<Theater,Theater> changedCurrentTheatherCommand;
  RxCommand<Null,List<Event>> updateEventsCommand;
  RxCommand<Null,List<Event>> updateUpcomingEventsCommand;
  RxCommand<DateTime,List<Show>> updateShowTimesCommand;
  RxCommand<Event,List<Actor>> getActorsForEventCommand;
  RxCommand<String,String> updateSearchStringCommand;
  
  List<Theater> allTheaters;
  Theater currentTheater;

  // Days for which we will displays Shows
  List<DateTime> showDates;
  DateTime selectedDate;

  // because Streams in Dart can only be single listened and Streambuilder always subscribe new, we have to create a new instance everytime 
  // which is only possible by using a function call or getter.
  Observable<CommandResult<List<Event>>> get inTheaterEvents {
    return Observable.combineLatest2<CommandResult<List<Event>>,String,CommandResult<List<Event>>>
                                    (updateEventsCommand, updateSearchStringCommand.results.startWith(""), 
                                        (result, s)
                                            => new CommandResult(result.data.where((event) => event.title.contains(s)).toList(), 
                                                                          result.error, result.isExecuting));}

  Observable<CommandResult<List<Event>>> get upcommingEvents {
    return Observable.combineLatest2<CommandResult<List<Event>>,String,CommandResult<List<Event>>>
                                    (updateUpcomingEventsCommand, updateSearchStringCommand.results.startWith(""), 
                                        (result, s)
                                            => new CommandResult(result.data.where((event) => event.title.contains(s)).toList(), 
                                                                          result.error, result.isExecuting));}

  Observable<CommandResult<List<Show>>> get showsToDisplay {
    return Observable.combineLatest2<CommandResult<List<Show>>,String,CommandResult<List<Show>>>
                                    (updateShowTimesCommand, updateSearchStringCommand.results.startWith(""), 
                                        (result, s)
                                            => new CommandResult(result.data.where((event) => event.title.contains(s)).toList(), 
                                                                          result.error, result.isExecuting));}

                                          

  AppModel(this._bundle,this._preferences,this._tmdbApi,this._finnkinoApi)
  {
     changedCurrentTheatherCommand = RxCommand.createSync3<Theater,Theater>((newTheater) => newTheater);

     // We handle this by listening to the command and not in the commands function iself 
     // because so others can listen to theater changes too
     changedCurrentTheatherCommand
       .results.listen((newDefaultTheater) {
          currentTheater = newDefaultTheater;
          updateEventsCommand.execute();
          updateUpcomingEventsCommand.execute();
          updateShowTimesCommand.execute(showDates[0]);
          _saveDefaultTheater(newDefaultTheater);
       });
         

    updateEventsCommand = RxCommand.createAsync2<List<Event>>( 
                                        () async => _finnkinoApi.getNowInTheatersEvents(currentTheater),emitLastResult: true); 

    updateUpcomingEventsCommand = RxCommand.createAsync2<List<Event>>( 
                                        () async => _finnkinoApi.getUpcomingEvents());                                                                             

    updateShowTimesCommand = RxCommand.createAsync3<DateTime,List<Show>>( _updateShowTimes, emitLastResult: true);

    getActorsForEventCommand = RxCommand.createAsync3(_getActorsForEvent);

    updateSearchStringCommand = RxCommand.createSync3((s)=>s);

    

  
  }

  Future init() async {
    await _bundle.loadString(OtherAssets.preloadedTheaters)
              .then( (theaterXml) => Theater.parseAll(theaterXml))
              .then( (theaters) {
                allTheaters = theaters;
                changedCurrentTheatherCommand.execute(_getDefaultTheater(theaters));
              });

    var now = Clock.getCurrentTime();
    showDates = new List.generate(7,(index) => now.add(new Duration(days: index)),);
  }



  Future<List<Actor>> _getActorsForEvent(event) async { 
  
    print("getactors called");
    try {
      var actorsWithAvatars = await _tmdbApi.findAvatarsForActors(
        event,
        event.actors,
      );
  
      // TMDB API might have a more comprehensive list of actors than the
      // Finnkino API, so we update the event with the actors we get from
      // the TMDB API.
      event.actors = actorsWithAvatars;
      print("Reecived actors");
    } catch (e) {
      // We don't need to handle this. If fetching actor avatars
      // fails, we don't care: the UI just simply won't display
      // any actor avatars and falls back to placeholder icons
      // instead.
    }
    return event.actors;
  }




  Future<List<Show>> _updateShowTimes(date) async 
                                {
                                  var now = Clock.getCurrentTime();
                                  date == date ?? now;
                                  var shows = await _finnkinoApi.getSchedule(currentTheater, date);
  
                                  selectedDate = date;    
                                  // Return only show times that haven't started yet.
                                  return shows.where((show) => show.start.isAfter(now)).toList();
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

  _saveDefaultTheater(Theater theater)
  {
    _preferences.setString(kDefaultTheaterId, theater.id);
  }

  
}




