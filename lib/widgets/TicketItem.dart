import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Settings.dart';
import 'package:flutter_app/models/Ticket.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:provider/provider.dart';



class TicketItem extends StatelessWidget {

  final Ticket _ticket;

  TicketItem(this._ticket);

  @override
  Widget build(BuildContext context) {

//    Widget page=context.read<TicketList>();
//    Settings.current_context=context;

    return (_ticket == null
        ? new Text(AppLocalizations.of(context).errorTicket)
        : new Container(
            margin: EdgeInsets.all(5),
            child: new Table(columnWidths: {
              0: FractionColumnWidth(.2),
              1: FractionColumnWidth(.8)
            }, children: [
              new TableRow(children: [
                new Padding(
                  padding: EdgeInsets.all(8.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Align(
                        //     alignment: Alignment.centerRight,
                        //     child: _ticket.solvedate == null || _ticket.solvedate.toString().isEmpty ? Text("") : Icon(Icons.done)
                        // ),
                        Row (
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new Text(_ticket.id.toString()),
                            Align(
                                alignment: Alignment.centerRight,
                                // child: new GestureDetector(
                                //     onTap: () {
                                //       ScaffoldMessenger.of(context).showSnackBar(
                                //         //         Scaffold.of(context).showSnackBar(
                                //           SnackBar(
                                //             content: Text("TAPPED !!"),
                                //             backgroundColor: Colors.red,
                                //             widget.paren
                                //           ));
                                //     },
                                    child: Container (
                                  color: _ticket.getColor(),
                                  width: 10,
                                  height: 10,
                                ))

                          ],

                        ),

                        new Text(
                          Settings.getAppDate(_ticket.tdate),
                          textScaleFactor: 0.8,
                        ),
                      ]),
                ),
                new Container(
                    constraints: new BoxConstraints(
                      minHeight: 50,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    decoration: Settings.itemDecoration,
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Table(columnWidths: {
                              0: FractionColumnWidth(.5),
                              1: FractionColumnWidth(.5)
                            }, children: [
                              new TableRow(children: [
                                Align (
                                  alignment: Alignment.centerLeft,
                                  child: new Text(
                                      Settings.users[_ticket.recipient] != null
                                          ? Settings.users[_ticket.recipient]
                                          .getUserName()
                                          : _ticket.recipient),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: new Text(_ticket.getEntity()),
                                )

                              ])
                            ]),
                          ),
                          new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(_ticket.name),
                          ),
                        ]))
              ])
            ])));
  }
}
