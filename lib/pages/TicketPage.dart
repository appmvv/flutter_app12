import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Ticket.dart';
import 'package:flutter_app/widgets/TicketForm.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'FollowupPage.dart';
import 'SolutionPage.dart';

class TicketPage extends StatefulWidget {

  final int _ticketid; //= 0;
  final String _messagetype;

  TicketPage(this._ticketid, this._messagetype);

  @override
  createState() => new TicketPageState();
}

class TicketPageState extends State<TicketPage> {
  Ticket _ticket;
  int _id = 0;
  Icon _followupIcon;

  StreamController<Ticket> _streamController = StreamController<Ticket>();

  GlpiApi api = GlpiApi();

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _id = widget._ticketid;
    _ticket = Ticket.getEmptyTicket(_id);

    _followupIcon = widget._messagetype == "followup"
        ? Icon(Icons.error) // new followup
        : Icon(Icons.message);

    _pullRefresh();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_ticket == null
                ? AppLocalizations.of(context).newticket
                : AppLocalizations.of(context).ticket + " " + _id.toString()),
            Text(
              _ticket == null ? "" : _ticket.tdate,
              textScaleFactor: 0.7,
            ),
          ],
        )),
        body: StreamBuilder<Ticket>(
            stream: _streamController.stream,
            initialData: _ticket,
            builder: (BuildContext context, AsyncSnapshot<Ticket> snapshot) {
              _ticket = snapshot.data;
              return new RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: new TicketForm(_ticket),
                  ));

            }),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: FloatingActionButton(
                  heroTag: "btn1",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowupPage(_id)),
                    );
                  },
//            label: Text(AppLocalizations.of(context).followups),
                  child: _followupIcon,
                  //     backgroundColor: Colors.pink,
                )),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SolutionPage(_id, _ticket.solvedate),
                    )).then((val)=>val?_pullRefresh():null);
              },
//            label: Text(AppLocalizations.of(context).solutions),
              child: Icon(Icons.assignment_turned_in_outlined),
              //     backgroundColor: Colors.pink,
            ),
          ],
        ));
  }

  Future<void> _pullRefresh() async {

    api.getTicket(_id).then((ticket) {
      if (ticket is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ticket.toString()), //AppLocalizations.of(context).errorTicket),
          backgroundColor: Colors.red,
        ));
      } else {
        _streamController.sink.add(ticket);
      }
    });

  }
}
