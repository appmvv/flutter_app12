import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/TicketList.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../AppBloc.dart';
import 'SettingsPage.dart';

class TicketListPage extends StatefulWidget {
  @override
  TicketListPageState createState() {
    return TicketListPageState();
  }
}

class TicketListPageState extends State<TicketListPage> {
  AppBloc _appBloc = AppBloc();

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
          appBar: AppBar(
            title: StreamBuilder<Object>(
                stream: _appBloc.titleStream,
                initialData: AppLocalizations.of(context).mainTitle,
                builder: (context, snapshot) {
                  return Text(snapshot.data);
                }),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  ); //.then((val)=>setState((){}));
                  // TODO start tisketlist _pullrefresh after saving settings
                },
              ),
            ],
          ),
          body: new TicketList(),
        ));
  }
}
