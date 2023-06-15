import 'package:flutter/material.dart';
import 'package:flutter_app/models/Followup.dart';
import 'package:flutter_app/models/Settings.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';

class FollowupItem extends StatelessWidget {

  final Followup _followup;

  FollowupItem(this._followup);

  @override
  Widget build(BuildContext context) {
    return (_followup == null
        ? new Text(AppLocalizations.of(context)!.errorFollowup)
        : new Container(
            margin: EdgeInsets.only(top:5, bottom:5, right: 15),
            child: new Table(columnWidths: {
              0: FractionColumnWidth(.2),
              1: FractionColumnWidth(.8)
            }, children: [
              new TableRow(children: [
                new Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: new Text(
                      Settings.getAppDate(_followup.date_creation),
                      textScaleFactor: 0.8,
                    ),
                  ),
                ),

                Container(
                    constraints: new BoxConstraints(
                      minHeight: 50,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    decoration: Settings.itemDecoration,
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Table(columnWidths: {
                            0: FractionColumnWidth(.9),
                            1: FractionColumnWidth(.1),

                          }, children: [
                            new TableRow(children: [
                              new Text(
                                  Settings.users[_followup.users_id] != null
                                      ? Settings.users[_followup.users_id]!
                                          .getUserName()
                                      : _followup.users_id!),
                              (_followup.is_private == 1
                                  ? new Icon(Icons.lock)
                                  : Text("")),
                            ])
                          ]),

                          Container(
                            // set height to % of the screen height
                            constraints: new BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                            ),

                            child: SingleChildScrollView(
                                child: Html(
                                    data: HtmlUnescape()
                                        .convert(_followup.content!))),
                          ),
                        ]))
              ])
            ])));
  }
}
