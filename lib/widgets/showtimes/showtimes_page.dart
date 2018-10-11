import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inkinoRx/data/loading_status.dart';
import 'package:inkinoRx/data/show.dart';
import 'package:inkinoRx/managers/app_manager.dart';
import 'package:inkinoRx/service_locator.dart';
import 'package:inkinoRx/widgets/common/info_message_view.dart';
import 'package:inkinoRx/widgets/common/loading_view.dart';
import 'package:inkinoRx/widgets/common/platform_adaptive_progress_indicator.dart';
import 'package:inkinoRx/widgets/showtimes/showtime_date_selector.dart';
import 'package:inkinoRx/widgets/showtimes/showtime_list.dart';

import 'package:rx_command/rx_command.dart';


class ShowtimesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appManager = sl.get<AppManager>();
    return  StreamBuilder(stream: appManager.showsToDisplay,
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
                                      //ToDO why pass the date that is a member of AppManager?
                                      onRetry: () => appManager.updateShowTimesCommand(appManager.selectedDate),
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
