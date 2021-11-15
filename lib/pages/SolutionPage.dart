import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/SolutionForm.dart';
import 'package:flutter_app/widgets/SolutionList.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SolutionPage extends StatefulWidget {

  final int _ticketid;
  final Object _ticketSolvdate;

  SolutionPage(this._ticketid, this._ticketSolvdate);

  @override
  SolutionPageState createState() {
    return SolutionPageState();
  }
}

class SolutionPageState extends State<SolutionPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).solutions),
            Text(
              AppLocalizations.of(context).ticket + " " + widget._ticketid.toString(),
              textScaleFactor: 0.7,
//                style: TextStyle(
//                  fontSize: 10,
//               ),
            ),
          ],
        )),
        body: widget._ticketSolvdate == null || widget._ticketSolvdate.toString().isEmpty
            ? SolutionForm(widget._ticketid)
            : SingleChildScrollView(
                child: new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          // set height to 40% of the screen height
                          child: SolutionList(widget._ticketid),
                        ),
                      ],
                    ))));
  }
}
