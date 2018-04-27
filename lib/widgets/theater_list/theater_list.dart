import 'package:flutter/material.dart';
import 'package:inkinoRx/model_provider.dart';

import 'package:meta/meta.dart';

class TheaterList extends StatelessWidget {
  TheaterList({
    @required this.header,
    @required this.onTheaterTapped,
  });

  final Widget header;
  final VoidCallback onTheaterTapped;

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.vertical;
    var model = ModelProvider.of(context);
    return new Transform(
      // FIXME: A hack for drawing behind the status bar, find a proper solution.
      transform: new Matrix4.translationValues(0.0, -statusBarHeight, 0.0),
      child: new ListView.builder(
      itemCount: model.allTheaters.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return header;
        }

        var theater = model.allTheaters[index - 1];
        var isSelected = model.currentTheater.id == theater.id;
        var backgroundColor = isSelected
            ? const Color(0xFFEEEEEE)
            : Theme.of(context).canvasColor;

        return new Material(
          color: backgroundColor,
          child: new ListTile(
            onTap: () {
              model.changedCurrentTheatherCommand(theater);
              onTheaterTapped();
            },
            selected: isSelected,
            title: new Text(theater.name),
          ),
        );
      },
    ),

      );
  }
}

