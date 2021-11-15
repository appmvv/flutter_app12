import 'dart:async';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Followup.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../AppBloc.dart';
import 'FollowupItem.dart';

import 'package:provider/provider.dart';

import 'FollowupMessage.dart';

class FollowupList extends StatefulWidget {
  final int _ticketid;

  FollowupList(this._ticketid);

  @override
  createState() => new FollowupListState();
}

class FollowupListState extends State<FollowupList> {

  StreamController<List<Followup>> _streamController =
      StreamController<List<Followup>>();

  final ScrollController _scrollController = ScrollController();

  AppBloc appBloc;

  GlpiApi api = GlpiApi();
  int _ticketid;

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ticketid = widget._ticketid;
    _pullRefresh();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = context.read<AppBloc>();

    return new Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.60,
              child: StreamBuilder<List<Followup>>(
                  stream: _streamController.stream,
                  initialData: List<Followup>.empty(),
                  builder:
                      (BuildContext context, AsyncSnapshot<List<Followup>> snapshot) {
                    List<Followup> followups = snapshot.data;

                    return new RefreshIndicator(
                        onRefresh: _pullRefresh,
                        child: DraggableScrollbar.rrect(
                            alwaysVisibleScrollThumb: true,
                            backgroundColor: Colors.grey,
                            controller: _scrollController,
                            child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                itemCount: (followups != null ? followups.length : 0),
                                itemBuilder: (context, i) {
                                  return new FollowupItem(followups[i]);
                                })));
                  }),

            ),
            FollowupMessage(widget._ticketid, this.callback),
          ],
        ));

  }

  void callback() {
    setState(() {
      _pullRefresh();
    });
  }

  Future<void> _pullRefresh() async {

    api.getFollowups(_ticketid).then((list) {

      if (list is List) {
        _streamController.sink.add(list);

        appBloc.updateTitle(AppLocalizations
            .of(context)
            .followups +
            " [" + list.length.toString() + "]");

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          //         Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(list.toString()), //AppLocalizations.of(context).errorTicketList),
              backgroundColor: Colors.red,
            ));
      }

    });
  }
}
