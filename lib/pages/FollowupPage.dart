import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/FollowupList.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../AppBloc.dart';

class FollowupPage extends StatefulWidget {
  final int _ticketid;

  FollowupPage(this._ticketid);

  @override
  FollowupPageState createState() {
    return FollowupPageState();
  }
}

class FollowupPageState extends State<FollowupPage> {

  AppBloc _appBloc;

  @override
  void initState() {
    super.initState();
    _appBloc = AppBloc();
  }

  @override
  void dispose() {
    _appBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
        value: _appBloc,
        child: Scaffold(
//            resizeToAvoidBottomInset: true,
            appBar: AppBar(
                title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<Object>(
                    stream: _appBloc.titleStream,
                    initialData: AppLocalizations.of(context).followups,
                    builder: (context, snapshot) {
                      return Text(snapshot.data);
                    }),
                Text(
                  AppLocalizations.of(context).ticket +
                      " " +
                      widget._ticketid.toString(),
                  textScaleFactor: 0.7,
//                style: TextStyle(
//                  fontSize: 10,
//               ),
                ),
              ],
            )),
            body: SingleChildScrollView(
                reverse: true,
                child: FollowupList(widget._ticketid),
            )));
  }
}
