import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inkinoRx/mainpage/main_page_model.dart';



// InheritedWidgets allow you to propagate values down the Widget Tree.
// it can then be accessed by just writing  TheViewModel.of(context)
class ModelProvider extends InheritedWidget {
  final MainPageModel model;

  const ModelProvider({Key key, @required this.model, @required Widget child})
      : assert(model != null),
        assert(child != null),
        super(key: key, child: child);

  static MainPageModel of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ModelProvider) as ModelProvider)
          .model;

  @override
  bool updateShouldNotify(ModelProvider oldWidget) => model != oldWidget.model;
}
