import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Followup.dart';
import 'package:flutter_app/providers/FollowupsProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'FollowupItem.dart';
import 'package:provider/provider.dart';
import 'FollowupMessage.dart';

class FollowupList extends StatelessWidget {
  final int _ticketId;

  FollowupList(this._ticketId);

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Followup> _followups =
        Provider.of<FollowupsProvider>(context).followups;
    String _error = Provider.of<FollowupsProvider>(context).getError;

    return new Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Column(
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.60,
                child:
                    _error.isNotEmpty
                        ? AlertDialog(
                            title: Text(
                                AppLocalizations.of(context).errorFollowup),
                            content: Text(_error),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child:
                                      Text(AppLocalizations.of(context).close)),
                            ],
                          )
                        : RefreshIndicator(
                            onRefresh: () => Provider.of<FollowupsProvider>(
                                    context,
                                    listen: false)
                                .getFollowups(_ticketId),
                            child: DraggableScrollbar.rrect(
                                alwaysVisibleScrollThumb: true,
                                backgroundColor: Colors.grey,
                                controller: _scrollController,
                                child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    controller: _scrollController,
                                    itemCount: (_followups != null
                                        ? _followups.length
                                        : 0),
                                    itemBuilder: (context, i) {
                                      return new FollowupItem(_followups[i]);
                                    })))),
            FollowupMessage(_ticketId), //, this.callback),
          ],
        ));
  }
}
