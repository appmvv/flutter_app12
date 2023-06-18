import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/TicketsProvider.dart';
import 'package:flutter_app/widgets/Tickets/TicketList.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../SettingsPage.dart';
import 'TicketPage.dart';

class TicketListPage extends StatefulWidget {
  @override
  createState() => new TicketListPageState();
}

class TicketListPageState extends State<TicketListPage> {
  @override
  void initState() {
    super.initState();

    /////// listenig to  firebase pushes

    // application is off
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
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
      String _ticketid = message.data["ticketid"] ?? '';
      String _type = message.data["objecttype"] ?? '';

      String _txt = '';

      switch (_type) {
        case 'ticket':
          _txt = AppLocalizations.of(context)!.newticket;
          break;
        case 'followup':
          _txt = '${AppLocalizations.of(context)!.newfollowup} $_ticketid';
          break;
        default:
          _txt = '';
      }

      if (_txt.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_txt),
          backgroundColor: Colors.green,
        ));
      }
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

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mainTitle +
            (Provider.of<TicketsProvider>(context).tickets == null
                ? ""
                : " [" +
                    Provider.of<TicketsProvider>(context)
                        .getTicketsCount()
                        .toString() +
                    "]")),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: TicketList(),
    );
  }
}
