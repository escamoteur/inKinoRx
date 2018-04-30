import 'dart:async';

import 'package:flutter/services.dart';
import 'package:inkinoRx/assets.dart';
import 'package:inkinoRx/data/actor.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/data/theater.dart';
import 'package:inkinoRx/services/finnkino_api.dart';
import 'package:inkinoRx/services/preferences.dart';
import 'package:inkinoRx/services/tmdb_api.dart';
import 'package:inkinoRx/utils/clock.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';






class AppModel {
 
  final AssetBundle _bundle;
  final Preferences _preferences;
  final FinnkinoApi _finnkinoApi;
  final  TMDBApi _tmdbApi;

  RxCommand<Theater,Theater> changedCurrentTheatherCommand;
  RxCommand<Null,List<Event>> updateEventsCommand;
  RxCommand<Null,List<Event>> updateUpcomingEventsCommand;
  RxCommand<DateTime,List<Show>> updateShowTimesCommand;
  RxCommand<Event,List<Actor>> getActorsForEventCommand;
  RxCommand<String,String> updateSearchStringCommand;
  
  List<Theater> allTheaters;
  Theater get currentTheater => changedCurrentTheatherCommand.lastResult; 

  // Days for which we will displays Shows
  List<DateTime> showDates;
  DateTime selectedDate;

  /// The following is a bit of Rx magic ;-)  this three getters create Observables that will issue 
  /// a new item either when the context of the search field changes OR if the Commands produce new data

  // because Streams in Dart can only be single listened and Streambuilder always subscribe new, we have to create a new instance everytime 
  // which is only possible by using a function call or getter.
  Observable<CommandResult<List<Event>>> get inTheaterEvents {
    return Observable
              .combineLatest2<CommandResult<List<Event>>,String,CommandResult<List<Event>>>(updateEventsCommand, updateSearchStringCommand.results.startWith(""), 
                      (result, s) => new CommandResult( result.data != null ? result.data.where((event) => event.title.contains(s))?.toList() : null, 
                                                        result.error, result.isExecuting));}

  Observable<CommandResult<List<Event>>> get upcommingEvents {
    return Observable
              .combineLatest2<CommandResult<List<Event>>,String,CommandResult<List<Event>>>(updateUpcomingEventsCommand, updateSearchStringCommand.results.startWith(""), 
                      (result, s) => new CommandResult(result.data != null ? result.data.where((event) => event.title.contains(s))?.toList() : null, 
                                                       result.error, result.isExecuting));}

  Observable<CommandResult<List<Show>>> get showsToDisplay {
    return Observable
              .combineLatest2<CommandResult<List<Show>>,String,CommandResult<List<Show>>>(updateShowTimesCommand, updateSearchStringCommand.results.startWith(""), 
                      (result, s) => new CommandResult(result.data != null ? result.data.where((event) => event.title.contains(s))?.toList() : null, 
                                                        result.error, result.isExecuting));}

                                          

  AppModel(this._bundle,this._preferences,this._tmdbApi,this._finnkinoApi)
  {
     changedCurrentTheatherCommand = RxCommand.createSync3<Theater,Theater>((newTheater) => newTheater);

     // We handle this by listening to the command and not in the commands function iself 
     // because so others can listen to theater changes too
     changedCurrentTheatherCommand
       .results.listen((newDefaultTheater) {
          updateEventsCommand.execute();
          updateUpcomingEventsCommand.execute();
          updateShowTimesCommand.execute(showDates[0]);
          _preferences.saveDefaultTheater(newDefaultTheater);
       });
         

    updateEventsCommand = RxCommand.createAsync2<List<Event>>( 
                                        () async => _finnkinoApi.getNowInTheatersEvents(currentTheater),emitLastResult: true); 

    updateUpcomingEventsCommand = RxCommand.createAsync2<List<Event>>( 
                                        () async => _finnkinoApi.getUpcomingEvents());                                                                             

    updateShowTimesCommand = RxCommand.createAsync3<DateTime,List<Show>>( 
                                        (newDate) async 
                                          { 
                                            selectedDate = newDate; 
                                            return await  _finnkinoApi.getShows(newDate, currentTheater);
                                          } , emitLastResult: true);

    getActorsForEventCommand = RxCommand.createAsync3((event) async => _tmdbApi.getActorsForEvent(event));

    updateSearchStringCommand = RxCommand.createSync3((s)=>s);

    
    //updateEventsCommand.listen((data) => print("Has data: ${data.hasData}  has error:   ${data.hasError}, ${data.isExecuting}"));
  
  }

  Future init() async {
    await _bundle.loadString(OtherAssets.preloadedTheaters)
              .then( (theaterXml) => Theater.parseAll(theaterXml))
              .then( (theaters) {
                allTheaters = theaters;
                changedCurrentTheatherCommand.execute(_preferences.getDefaultTheater(theaters));
              });

    var now = Clock.getCurrentTime();
    showDates = new List.generate(7,(index) => now.add(new Duration(days: index)),);
  }



 
 


  
}




