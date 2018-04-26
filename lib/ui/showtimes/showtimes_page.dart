import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inkinoRx/data/loading_status.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/model_provider.dart';
import 'package:inkinoRx/ui/common/info_message_view.dart';
import 'package:inkinoRx/ui/common/loading_view.dart';
import 'package:inkinoRx/ui/common/platform_adaptive_progress_indicator.dart';
import 'package:inkinoRx/ui/showtimes/showtime_date_selector.dart';
import 'package:inkinoRx/ui/showtimes/showtime_list.dart';

import 'package:rx_command/rx_command.dart';


class ShowtimesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return  StreamBuilder(stream: ModelProvider.of(context).updateShowTimesCommand,
                builder: (BuildContext context, AsyncSnapshot<CommandResult<List<Show>>> snapshot)
                {
                    if (snapshot.hasData)
                    {
                      LoadingStatus status = snapshot.hasError || snapshot.data.hasError ? LoadingStatus.error : 
                                                snapshot.data.isExecuting ? LoadingStatus.loading : LoadingStatus.success; 

                        return 
                        Column(
                            children: <Widget>
                            [
                              Expanded(child: 
                                  LoadingView(
                                    status: status,
                                    loadingContent: new PlatformAdaptiveProgressIndicator(),
                                    errorContent: new ErrorView(
                                      description: 'Error loading events.',
                                      onRetry: () => ModelProvider.of(context).updateShowTimesCommand(),
                                    ),
                                    successContent:  snapshot.data.data != null ? new ShowtimeList(snapshot.data.data ?? new List<Show>()) : null,
                                  )
                                ),
                            
                                ShowtimeDateSelector(),
                            ]);
                    }
                    else
                    {
                      return Container();
                    }
                });
          
  }
}
