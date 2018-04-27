import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/loading_status.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/widgets/common/info_message_view.dart';
import 'package:inkinoRx/widgets/common/loading_view.dart';
import 'package:inkinoRx/widgets/common/platform_adaptive_progress_indicator.dart';
import 'package:inkinoRx/widgets/events/event_grid.dart';
import 'package:rx_command/rx_command.dart';

typedef StreamProvider = Stream<CommandResult<List<Event>>> Function();

enum EvenListTypes {InTheater, Upcomming}

class EventsPage extends StatelessWidget {
  final EvenListTypes listType;

  EventsPage(this.listType);

  @override
  Widget build(BuildContext context) {
    var model = ModelProvider.of(context);

    Stream<CommandResult<List<Event>>> stream = listType == EvenListTypes.InTheater ? model.inTheaterEvents : model.upcommingEvents;
    return StreamBuilder(stream: stream,
                        builder: (BuildContext context, AsyncSnapshot<CommandResult<List<Event>>> snapshot)
                        {
                           if (snapshot.hasData)
                           {
                            LoadingStatus status = snapshot.hasError || snapshot.data.hasError ? LoadingStatus.error : 
                                                      snapshot.data.isExecuting ? LoadingStatus.loading : LoadingStatus.success; 
                            


                           return LoadingView(
                              status: status,
                              loadingContent: new PlatformAdaptiveProgressIndicator(),
                              errorContent: new ErrorView(
                                description: 'Error loading events.',
                                onRetry: () =>ModelProvider.of(context).updateEventsCommand(),
                              ),
                              successContent: new EventGrid(
                                // As LoadingView doesn't deal with null data values while loading
                                events:   snapshot.data.data ?? new List<Event>(), 
                                onReloadCallback: () =>ModelProvider.of(context).updateEventsCommand(),
                              ),
                            );
                           }
                           else
                           {
                             return Container();
                           }
                        });



  }
}
