import 'dart:async';

import 'package:inkinoRx/data/actor.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/data/theater.dart';
import 'package:inkinoRx/service_locator.dart';
import 'package:inkinoRx/services/finnkino_service.dart';
import 'package:inkinoRx/services/preferences_service.dart';
import 'package:inkinoRx/services/tmdb_api_service.dart';
import 'package:inkinoRx/helpers/clock.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';

abstract class AppManager {

  RxCommand<Theater, Theater> changedCurrentTheatherCommand;
  RxCommand<void, List<Event>> updateEventsCommand;
  RxCommand<void, List<Event>> updateUpcomingEventsCommand;
  RxCommand<DateTime, List<Show>> updateShowTimesCommand;
  RxCommand<Event, List<Actor>> getActorsForEventCommand;
  RxCommand<String, String> updateSearchStringCommand;

  List<Theater> allTheaters;
  Theater get currentTheater => changedCurrentTheatherCommand.lastResult;

  // Days for which we will displays Shows
  List<DateTime> showDates;
  DateTime selectedDate;

  Observable<CommandResult<List<Event>>> get inTheaterEvents;

  Observable<CommandResult<List<Event>>> get upcommingEvents;

  Observable<CommandResult<List<Show>>> get showsToDisplay;


  Future init();

}

class AppManagerImplementation implements AppManager {

  @override
  RxCommand<Theater, Theater> changedCurrentTheatherCommand;
  @override
  RxCommand<void, List<Event>> updateEventsCommand;
  @override
  RxCommand<void, List<Event>> updateUpcomingEventsCommand;
  @override
  RxCommand<DateTime, List<Show>> updateShowTimesCommand;
  @override
  RxCommand<Event, List<Actor>> getActorsForEventCommand;
  @override
  RxCommand<String, String> updateSearchStringCommand;

  @override
  List<Theater> allTheaters;
  @override
  Theater get currentTheater => changedCurrentTheatherCommand.lastResult;

  // TODO check
  // Days for which we will displays Shows
  @override
  List<DateTime> showDates;
  @override
  DateTime selectedDate;

  /// The following is a bit of Rx magic ;-)  this three getters create Observables that will issue
  /// a new item either when the context of the search field changes OR if the Commands produce new data

  // because Streams in Dart can only be single listened and Streambuilder always subscribe new, we have to create a new instance everytime
  // which is only possible by using a function call or getter.
  @override
  Observable<CommandResult<List<Event>>> get inTheaterEvents {
    return Observable.combineLatest2<CommandResult<List<Event>>, String,
            CommandResult<List<Event>>>(
        updateEventsCommand.results,
        updateSearchStringCommand.startWith(""),
        (result, s) => new CommandResult(
            result.data != null
                ? result.data
                    .where((event) => event.title.contains(s))
                    ?.toList()
                : null,
            result.error,
            result.isExecuting));
  }

  @override
  Observable<CommandResult<List<Event>>> get upcommingEvents {
    return Observable.combineLatest2<CommandResult<List<Event>>, String,
            CommandResult<List<Event>>>(
        updateUpcomingEventsCommand.results,
        updateSearchStringCommand.startWith(""),
        (result, s) => new CommandResult(
            result.data != null
                ? result.data
                    .where((event) => event.title.contains(s))
                    ?.toList()
                : null,
            result.error,
            result.isExecuting));
  }

  @override
  Observable<CommandResult<List<Show>>> get showsToDisplay {
    return Observable.combineLatest2<CommandResult<List<Show>>, String,
            CommandResult<List<Show>>>(
        updateShowTimesCommand.results,
        updateSearchStringCommand.startWith(""),
        (result, s) => new CommandResult(
            result.data != null
                ? result.data
                    .where((event) => event.title.contains(s))
                    ?.toList()
                : null,
            result.error,
            result.isExecuting));
  }

  AppManagerImplementation() {
    changedCurrentTheatherCommand =
        RxCommand.createSync<Theater, Theater>((newTheater) => newTheater);

    // We handle this by listening to the command and not in the commands function iself
    // because so others can listen to theater changes too
    changedCurrentTheatherCommand.listen((newDefaultTheater) {
      updateEventsCommand.execute();
      updateUpcomingEventsCommand.execute();
      updateShowTimesCommand.execute(showDates[0]);
      sl.get<PreferencesService>().saveDefaultTheater(newDefaultTheater);
    });

    updateEventsCommand = RxCommand.createAsyncNoParam<List<Event>>(
        () async => sl.get<FinnKinoService>().getNowInTheatersEvents(currentTheater),
        emitLastResult: true);

    updateUpcomingEventsCommand = RxCommand.createAsyncNoParam<List<Event>>(
        () async => sl.get<FinnKinoService>().getUpcomingEvents());

    updateShowTimesCommand =
        RxCommand.createAsync<DateTime, List<Show>>((newDate) async {
      selectedDate = newDate;
      return await sl.get<FinnKinoService>().getShows(newDate, currentTheater);
    }, emitLastResult: true);

    getActorsForEventCommand = RxCommand.createAsync(
        (event) async => sl.get<TMDBApiService>().getActorsForEvent(event));

    updateSearchStringCommand = RxCommand.createSync((s) => s);

    //updateEventsCommand.listen((data) => print("Has data: ${data.hasData}  has error:   ${data.hasError}, ${data.isExecuting}"));
  }

  Future init() async {
    var _preferences = sl.get<PreferencesService>();
      allTheaters = await _preferences.loadTheaters();

      changedCurrentTheatherCommand
          .execute(await _preferences.getDefaultTheater(allTheaters));

    var now = Clock.getCurrentTime();
    showDates = new List.generate(
      7,
      (index) => now.add(new Duration(days: index)),
    );
  }
}
