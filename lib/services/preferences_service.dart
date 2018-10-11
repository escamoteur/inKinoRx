import 'package:flutter/services.dart';
import 'package:inkinoRx/assets.dart';
import 'package:inkinoRx/data/theater.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesService {
  Future<Theater> getDefaultTheater(List<Theater> allTheaters);

  Future<void> saveDefaultTheater(Theater theater);

  Future<List<Theater>> loadTheaters();
}

class PreferencesServiceImplementation implements PreferencesService {
  static const String kDefaultTheaterId = 'default_theater_id';

  final AssetBundle _bundle;

  PreferencesServiceImplementation(this._bundle);

  @override
  Future<Theater> getDefaultTheater(List<Theater> allTheaters) async {
    var persistedTheaterId = (await SharedPreferences.getInstance())?.getString(kDefaultTheaterId);

    if (persistedTheaterId != null) {
      return allTheaters.singleWhere((theater) {
        return theater.id == persistedTheaterId;
      });
    }

    return allTheaters.first;
  }

  @override
  saveDefaultTheater(Theater theater) async {
    (await SharedPreferences.getInstance()).setString(kDefaultTheaterId, theater.id);
  }

  @override
  Future<List<Theater>> loadTheaters() async {
    return await _bundle
        .loadString(OtherAssets.preloadedTheaters)
        .then((theaterXml) => Theater.parseAll(theaterXml));
  }
}
