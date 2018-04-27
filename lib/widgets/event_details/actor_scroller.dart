import 'package:flutter/material.dart';

import 'package:inkinoRx/assets.dart';
import 'package:inkinoRx/data/actor.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/model_provider.dart';


class ActorScroller extends StatelessWidget {
  final Event event;
  final List<Actor> actors;

  ActorScroller(this.event): actors = event.actors;
   
  @override
  Widget build(BuildContext context) {
    return 
    new StreamBuilder(initialData: event.actors, stream: ModelProvider.of(context).getActorsForEventCommand.results,
        builder: (context, AsyncSnapshot<List<Actor>> snapshot){
        var actors = snapshot.hasData && (snapshot.data != null) ? snapshot.data : new List<Actor>(); // just to be save

    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: new Text(
              'Cast',
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new SizedBox.fromSize(
              size: new Size.fromHeight(110.0),
              child: _buildActorList(context, actors),
            ),
          ),
        ],
      ),
    );
  });
  }


  Widget _buildActorList(BuildContext context, actors) {
    return new ListView.builder(
      padding: const EdgeInsets.only(left: 16.0),
      scrollDirection: Axis.horizontal,
      itemCount: actors.length,
      itemBuilder: (BuildContext context, int index) {
        var actor = actors[index];
        return _buildActorListItem(context, actor);
      },
    );
  }

  Widget _buildActorListItem(BuildContext context, Actor actor) {
    var actorName = new Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: new Text(
        actor.name,
        style: new TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    );

    return new Container(
      width: 90.0,
      padding: const EdgeInsets.only(right: 16.0),
      child: new Column(
        children: <Widget>[
          _buildActorAvatar(context, actor),
          actorName,
        ],
      ),
    );
  }

  Widget _buildActorAvatar(BuildContext context, Actor actor) {
    var fallbackIcon = new Icon(
      Icons.person,
      color: Colors.white,
      size: 26.0,
    );

    var avatarImage = new ClipOval(
      child: new FadeInImage.assetNetwork(
        placeholder: ImageAssets.transparentImage,
        image: actor.avatarUrl ?? '',
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 250),
      ),
    );

    return new Container(
      width: 56.0,
      height: 56.0,
      decoration: new BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: new Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          fallbackIcon,
          avatarImage,
        ],
      ),
    );
  }

}
