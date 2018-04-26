import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inkinoRx/data/event.dart';
import 'package:inkinoRx/data/loading_status.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/ui/common/info_message_view.dart';
import 'package:inkinoRx/ui/common/loading_view.dart';
import 'package:inkinoRx/ui/common/platform_adaptive_progress_indicator.dart';
import 'package:inkinoRx/ui/events/event_grid.dart';
import 'package:rx_command/rx_command.dart';

class EventsPage extends StatelessWidget {
  final Stream<CommandResult<List<Event>>> source;

  EventsPage(this.source);

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder(stream: source,
                        builder: (BuildContext context, AsyncSnapshot<CommandResult<List<Event>>> snapshot)
                        {
                           if (snapshot.hasData)
                           {
                            LoadingStatus status = snapshot.hasError || snapshot.data.hasError ? LoadingStatus.error : 
                                                      snapshot.data.isExecuting ? LoadingStatus.loading : LoadingStatus.success; 
                            

                           // As LoadingView doesn't deal with null data values while loading
                           if (snapshot.data.data == null)
                           {
                             status = LoadingStatus.loading;
                           }

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
