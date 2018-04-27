import 'package:flutter/material.dart';
import 'package:inkinoRx/mainpage/app_model.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:intl/intl.dart';

class ShowtimeDateSelector extends StatelessWidget {
  ShowtimeDateSelector();

  Widget _buildDateItem(DateTime date, AppModel model) {
    var color = model.selectedDate == date ? Colors.white : Colors.white.withOpacity(0.4);

    var content = new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: new Text(
            new DateFormat('E').format(date),
            style: new TextStyle(
              fontSize: 12.0,
              color: color,
            ),
          ),
        ),
        new Text(
          date.day.toString(),
          style: new TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );

    return new Material(
      color: Colors.transparent,
      child: new InkWell(
        onTap: () => model.updateShowTimesCommand(date),
        radius: 56.0,
        child: new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var model = ModelProvider.of(context);
    return new Container(
      height: 56.0 + MediaQuery.of(context).padding.bottom,
      color: const Color(0xFF222222),
      child: new ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.showDates.length,
        itemBuilder: (BuildContext context, int index) {
          var date = model.showDates[index];
          return _buildDateItem(date, model );
        },
      ),
    );
  }
}
