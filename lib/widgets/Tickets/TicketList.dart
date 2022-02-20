import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/Ticket.dart';
import 'package:flutter_app/providers/TicketsProvider.dart';
import 'package:flutter_app/widgets/Tickets/TicketPage.dart';
import 'package:flutter_app/widgets/Tickets/TicketItem.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../SettingsPage.dart';

class TicketList extends StatefulWidget {
  @override
  TicketListState createState() {
    return TicketListState();
  }
}

class TicketListState extends State {
  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    return Consumer<TicketsProvider>(builder: (context, value, child) {
      List<Ticket> tickets = value.tickets;

      String _error = value.ticketsError;

      return RefreshIndicator(
          onRefresh: value.getTickets,
          child: _error.isNotEmpty
              ? AlertDialog(
                  title: Text(AppLocalizations.of(context).errorTicketList),
                  content: Text(_error),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          setState(() {
                            value.clearTicketsError();
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()),
                          );
                        },
                        child: Text(AppLocalizations.of(context).settings)),
                    defaultTargetPlatform ==
                            TargetPlatform
                                .iOS // Apple requires not to close app
                        ? Text("")
                        : TextButton(
                            onPressed: () {
                              SystemNavigator.pop();
                            },
                            child: Text(AppLocalizations.of(context).close)),
                  ],
                )
              : (tickets == null // || tickets.length == 0
                  ? Center(child: CircularProgressIndicator())
                  : DraggableScrollbar.rrect(
                      alwaysVisibleScrollThumb: true,
                      backgroundColor: Colors.grey,
                      controller: _scrollController,
                      child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: (tickets != null ? tickets.length : 0),
                          itemBuilder: (context, i) {
                            return new GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TicketPage(tickets[i].id, "")));
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: TicketItem(tickets[i]),
                                ));
                          }))));
    });
//       });
  }
}
