import 'package:flutter/services.dart';
import 'package:inkinoRx/managers/app_manager.dart';
import 'package:inkinoRx/services/finnkino_service.dart';
import 'package:inkinoRx/services/preferences_service.dart';
import 'package:inkinoRx/services/tmdb_api_service.dart';
import 'package:get_it/get_it.dart';

GetIt sl = new GetIt();

void setUpServiceLocator(AssetBundle bundle)
 {
  sl.registerLazySingleton<FinnKinoService>(() => new FinnKinoServiceImplementation());

  sl.registerLazySingleton<TMDBApiService>(() => new TMDBApiServiceImplementation());

  sl.registerLazySingleton<PreferencesService>(()  => new PreferencesServiceImplementation(bundle));

// Managers

  sl.registerSingleton<AppManager>(new AppManagerImplementation());

}
