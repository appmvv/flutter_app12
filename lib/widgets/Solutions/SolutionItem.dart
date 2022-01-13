import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Settings.dart';
import 'package:flutter_app/models/Solution.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';

class SolutionItem extends StatelessWidget {

  final Solution _solution;

  SolutionItem(this._solution);

  @override
  Widget build(BuildContext context) {
    return (_solution == null
        ? new Text(AppLocalizations.of(context).errorFollowup)
        : new Container(
        margin: EdgeInsets.only(top:5, bottom:5),
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
                  Settings.getAppDate(_solution.date_creation),
                  textScaleFactor: 0.8,
                ),
              ),
            ),

            Container(
                constraints: new BoxConstraints(
                  minHeight: 50,
                ),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 0,
                      offset: Offset(
                        0.5, // Move to right 10  horizontally
                        0.5, // Move to bottom 5 Vertically
                      ),),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(
                      6.0) //         <--- border radius here
                  ),
                ),
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      new Text(
                              Settings.usersById[_solution.users_id.toString()] != null
                                  ? Settings.usersById[_solution.users_id.toString()]
                                  .getUserName()
                                  : _solution.users_id.toString()),
                      SizedBox(
                        height: 10,
                      ),

                      new Text(
                          Settings.SolutionTypesById[_solution.solutiontypes_id.toString()] != null
                              ? Settings.SolutionTypesById[_solution.solutiontypes_id.toString()].name
                              : "-"),

                      SizedBox(
                        height: 10,
                      ),

                      Container(
                        // set height to % of the screen height
                        constraints: new BoxConstraints(
                          maxHeight:
                          MediaQuery.of(context).size.height * 0.5,
                        ),

                        child: SingleChildScrollView(
                            child: Html(
                              //                        padding: EdgeInsets.all(12.0),
                                data: HtmlUnescape()
                                    .convert(_solution.content))),
                      ),
                    ]))
          ])
        ])));
  }
}
