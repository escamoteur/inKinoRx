import 'dart:io';

import 'package:flutter/services.dart';
import 'package:inkinoRx/services/finnkino_api.dart';

import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFile extends Mock implements File {}

class MockFinnkinoApi extends Mock implements FinnkinoApi {}
class MockAssetBundle extends Mock implements AssetBundle {}

class MockPreferences extends Mock implements SharedPreferences {}