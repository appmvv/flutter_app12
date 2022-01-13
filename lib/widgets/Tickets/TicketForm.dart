
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Settings.dart';
import 'package:flutter_app/models/Ticket.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';

//import 'package:flutter_html/flutter_html.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
//import 'package:html_unescape/html_unescape.dart';

import '../ReadFieldWidget.dart';

//import 'package:flutter_html/flutter_html.dart';
//import 'package:webview_flutter/webview_flutter.dart';

//import 'package:flutter_html_view/flutter_html_view.dart';
//import 'package:flutter_markdown/flutter_markdown.dart';

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class TicketForm extends StatefulWidget {

  final Ticket _ticket;

  TicketForm(this._ticket);

  @override
  createState() => new TicketFormState();
}

class TicketFormState extends State<TicketForm> {
  Ticket _ticket;

  @override
  Widget build(BuildContext context) {
    Settings.current_context = context;
    _ticket = widget._ticket;

    return (_ticket == null
        ? new Text(AppLocalizations.of(context).errorTicket)
        : new Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                new Text(Settings.users[_ticket.recipient] != null
                    ? Settings.users[_ticket.recipient].getUserName()
                    : _ticket.recipient),
                new Text(_ticket.getEntity()),

                ReadfieldWidget(
                    AppLocalizations.of(context).ticketName, _ticket.name),

                new Padding(
                  padding: EdgeInsets.only(top: 5, left: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context).ticketContent,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                Container(
                  // set height to % of the screen height
                  height: MediaQuery.of(context).size.height * 0.2,
                  padding: const EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(6.0) //         <--- border radius here
                        ),
                  ),
                  child: SingleChildScrollView(
                    //TODO uncaught exception when picture image url (ticket 321)
                      child: Html(
                          //  padding: EdgeInsets.all(12.0),
                          data: HtmlUnescape().convert(_ticket.content))),
                ),

                new Table(
                  columnWidths: {
                    0: FractionColumnWidth(.47),
                    1: FractionColumnWidth(.06),
                    2: FractionColumnWidth(.47)
                  },
                  children: [
                    TableRow(
                      children: [
                        ReadfieldWidget(AppLocalizations.of(context).ticketType,
                            _ticket.type >=0 && _ticket.type < Settings.ticket_types.length ? Settings.ticket_types[_ticket.type] : "-"
                        ),
                        Text(""),
                        ReadfieldWidget(
                          AppLocalizations.of(context).ticketResolveTime,
                          Settings.getAppDate(_ticket.resolvetime),
                        ),
                      ],
                    )
                  ],
                ),

                ReadfieldWidget(AppLocalizations.of(context).ticketStatus,
                    _ticket.status >=0 && _ticket.status < Settings.ticket_statuses.length ? Settings.ticket_statuses[_ticket.status] : "-"
                ),
                ReadfieldWidget(
                    AppLocalizations.of(context).ticketCategory,
                    _ticket.category is String
                        ? _ticket.category
                        : "-" //_ticket.category.toString()
                ),
              ],
            )));
  }
}
