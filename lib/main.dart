import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inkinoRx/mainpage/main_page.dart';
import 'package:inkinoRx/mainpage/app_model.dart';

import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/services/finnkino_api.dart';
import 'package:inkinoRx/services/tmdb_api.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<Null> main() async {
  // ignore: deprecated_member_use
  MaterialPageRoute.debugEnableFadingRoutes = true;

  var tmdbApi = new TMDBApi();
  var finnkinoApi = new FinnkinoApi();
  var prefs = await SharedPreferences.getInstance();

  AppModel mainPageModel = new AppModel(rootBundle,prefs, tmdbApi,finnkinoApi);
  await mainPageModel.init();

  runApp(new InKinoApp( model: mainPageModel,));
}

class InKinoApp extends StatelessWidget {

  final AppModel model;

  const InKinoApp({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ModelProvider(
      model: model,
      child: new MaterialApp(
        title: 'inKino MVVM RX',
        theme: new ThemeData(
          primaryColor: new Color(0xFF1C306D),
          accentColor: new Color(0xFFFFAD32),
        ),
        home: new MainPage(),
      ),
    );
  }
}
