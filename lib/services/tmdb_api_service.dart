import 'dart:async';
import 'dart:convert';



/// If this has a red underline, it means that the lib/tmdb_config.dart file
/// is not present on the project. Refer to the README for instructions
/// on how to do so.
import 'package:inkinoRx/tmdb_config.dart';
import 'package:inkinoRx/data/actor.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/services/http_utils.dart';


abstract class TMDBApiService {

  Future<List<Actor>> findAvatarsForActors(
      Event event, List<Actor> actors);

  Future<int> _findMovieId(String movieTitle);

  Future<List<Actor>> _getActorAvatars(int movieId);

  List<Actor> _parseActorAvatars(List<Map<String, dynamic>> movieCast);

  Future<List<Actor>> getActorsForEvent(event);


}

class TMDBApiServiceImplementation implements TMDBApiService {
  static final String baseUrl = 'api.themoviedb.org';

  Future<List<Actor>> findAvatarsForActors(
      Event event, List<Actor> actors) async {
    int movieId = await _findMovieId(event.originalTitle);

    if (movieId != null) {
      return _getActorAvatars(movieId);
    }

    return actors;
  }

  Future<int> _findMovieId(String movieTitle) async {
    var searchUri = new Uri.https(
      baseUrl,
      '3/search/movie',
      <String, String>{
        'api_key': TMDBConfig.apiKey,
        'query': movieTitle,
      },
    );

    var response = await getRequest(searchUri);
    var movieSearchJson = json.decode(response);
    var searchResults = movieSearchJson['results'];

    if (searchResults.isNotEmpty) {
      return searchResults.first['id'];
    }

    return null;
  }

  Future<List<Actor>> _getActorAvatars(int movieId) async {
    var actorUri = new Uri.https(
      baseUrl,
      '3/movie/$movieId/credits',
      <String, String>{'api_key': TMDBConfig.apiKey},
    );

    var response = await getRequest(actorUri);
    var movieActors = json.decode(response);

    return _parseActorAvatars(
        (movieActors['cast'] as List).cast<Map<String, dynamic>>());
  }

  List<Actor> _parseActorAvatars(List<Map<String, dynamic>> movieCast) {
    var actorsWithAvatars = <Actor>[];

    movieCast.forEach((castMember) {
      var pp = castMember['profile_path'];
      var profilePath =
          pp != null ? 'https://image.tmdb.org/t/p/w200$pp' : null;

      actorsWithAvatars.add(new Actor(
        name: castMember['name'],
        avatarUrl: profilePath,
      ));
    });

    return actorsWithAvatars;
  }

  Future<List<Actor>> getActorsForEvent(event) async { 
  
    print("getactors called");
    try {
      var actorsWithAvatars = await findAvatarsForActors(
        event,
        event.actors,
      );
  
      // TMDB API might have a more comprehensive list of actors than the
      // Finnkino API, so we update the event with the actors we get from
      // the TMDB API.
      event.actors = actorsWithAvatars;
      print("Reecived actors");
    } catch (e) {
      // We don't need to handle this. If fetching actor avatars
      // fails, we don't care: the UI just simply won't display
      // any actor avatars and falls back to placeholder icons
      // instead.
    }
    return event.actors;
  }


}
