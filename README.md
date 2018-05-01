# inKinoRx - a refactored version of inKino

This is the attempt to refactor the original [inKino](https://github.com/roughike/inKino) by [Iiro Krankka](https://github.com/roughike) from an Redux to a RxCommand based architecture.

More details in this blog post [https://www.burkharts.net/apps/blog/redux-the-ideal-flutter-pattern/](http://www.burkharts.net/apps/blog/redux-the-ideal-flutter-pattern/)


## Building the project

Before you build: Inside the `/lib` folder, there's a file called **tmdb_config_sample.dart**. Rename it to **tmdb_config.dart** and you'll get rid of the build error.

The project is currently built using the [latest Flutter Beta 2](https://medium.com/flutter-io/https-medium-com-flutter-io-announcing-flutters-beta-2-c85ba1557d5e), with Dart 2 enabled.

## Thanks

Special thanks to Iiro Krankka for the original project and [Brian Egan](https://github.com/brianegan) for reviewing and discussing the source code.
