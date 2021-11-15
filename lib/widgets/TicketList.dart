import 'dart:async';

//import 'dart:html';
//import 'dart:html';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AppBloc.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Ticket.dart';
import 'package:flutter_app/pages/TicketPage.dart';
import 'package:flutter_app/widgets/TicketItem.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:provider/provider.dart';

import '../main.dart';

class TicketList extends StatefulWidget {
  @override
  createState() => new TicketListState();
}

class TicketListState extends State<TicketList> {

  StreamController<List<Ticket>> _streamController =
      StreamController<List<Ticket>>();

  final ScrollController _scrollController = ScrollController();

  GlpiApi api = GlpiApi();

  AppBloc appBloc;

//  List<Ticket> _tickets;

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  void initState() {

    super.initState();

    // application is off
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        int ticketid = int.tryParse(message.data["ticketid"]) ?? 0;

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TicketPage(ticketid, message.data["objecttype"])));
      }
    });

    // application is on
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      // create android notodocation
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }

      String _ticketid = message.data["ticketid"];
      String _type = message.data["objecttype"];

      String _txt = (_type == "ticket"
              ? AppLocalizations.of(context).newticket
              : AppLocalizations.of(context).newfollowup) +
          " " +
          _ticketid;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_txt), // AppLocalizations.of(context).errorTicketList
        backgroundColor: Colors.green,
      ));
    });

    // application is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message != null) {
        int ticketid = int.tryParse(message.data["ticketid"]) ?? 0;

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TicketPage(ticketid, message.data["objecttype"])));
      }

/*      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));*/
    });

    _pullRefresh();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = context.read<AppBloc>();
    return StreamBuilder<List<Ticket>>(
        stream: _streamController.stream,
        initialData: List<Ticket>.empty(),
        builder: (BuildContext context, AsyncSnapshot<List<Ticket>> snapshot) {
          List<Ticket> tickets = snapshot.data;

          return new RefreshIndicator(
              onRefresh: _pullRefresh,
              child: DraggableScrollbar.rrect(
                alwaysVisibleScrollThumb: true,
                backgroundColor: Colors.grey,
//                padding: EdgeInsets.only(right: 1.0, left: 3.0),
                //               isAlwaysShown: true,
                controller: _scrollController,
//                thickness: 10.0,
//                radius: Radius.circular(5.0),
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: (tickets != null ? tickets.length : 0),
                    itemBuilder: (context, i) {
                      return (tickets == null || tickets.length == 0
                          ? new Text(
                              AppLocalizations.of(context).errorTicketList)
                          : new GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TicketPage(tickets[i].id, ""))).then((val)=>_pullRefresh());
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: TicketItem(tickets[i]),
                              )));
                    }),
              ));
        });
  }

  Future<void> _pullRefresh() async {

      api.getTickets().then((list) {

        if (list is List) {
          _streamController.sink.add(list);

          appBloc.updateTitle(AppLocalizations.of(context).mainTitle +
              " [" + list.length.toString() +
              "]");

        } else {

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
            content: Text(list.toString()), //AppLocalizations.of(context).errorTicketList),
            backgroundColor: Colors.red,
          ));
        }
      });
  }
}
