import 'package:inkinoRx/data/theater.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Preferences {

 static const String kDefaultTheaterId = 'default_theater_id';

 SharedPreferences prefs;

 Preferences(this.prefs);

 Theater getDefaultTheater(List<Theater> allTheaters) {
    var persistedTheaterId = prefs.getString(kDefaultTheaterId);

    if (persistedTheaterId != null) {
      return allTheaters.singleWhere((theater) {
        return theater.id == persistedTheaterId;
      });
    }

    return allTheaters.first;
  }

  saveDefaultTheater(Theater theater)
  {
    prefs.setString(kDefaultTheaterId, theater.id);
  }  

}