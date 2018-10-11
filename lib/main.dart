import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inkinoRx/app/main_page.dart';
import 'package:inkinoRx/managers/app_manager.dart';
import 'package:inkinoRx/service_locator.dart';

Future<Null> main() async {

  setUpServiceLocator(rootBundle);
  await sl.get<AppManager>().init();

  runApp(new InKinoApp());
}

class InKinoApp extends StatelessWidget {

  final AppManager model;

  const InKinoApp({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title: 'inKino MVVM RX',
        theme:  ThemeData(
          primaryColor: Color(0xFF1C306D),
          accentColor:  Color(0xFFFFAD32),
        ),
        home: MainPage(),
    );
  }
}
