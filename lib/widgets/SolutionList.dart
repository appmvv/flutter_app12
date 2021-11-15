import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Solution.dart';

import 'SolutionItem.dart';

class SolutionList extends StatefulWidget {

  final int _ticketid;

  SolutionList(this._ticketid);

  @override
  createState() => new SolutionListState();
}

class SolutionListState extends State<SolutionList> {
//  final _formKey = GlobalKey<FormState>();

  StreamController<List<Solution>> _streamController =
  StreamController<List<Solution>>();

  GlpiApi api = GlpiApi();
  int _ticketid;

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ticketid=widget._ticketid;
    _pullRefresh();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<Solution>>(
        stream: _streamController.stream,
        initialData: List<Solution>.empty(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Solution>> snapshot) {
          List<Solution> items = snapshot.data;

          return new RefreshIndicator(
              onRefresh: _pullRefresh,
              child: new ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: (items != null ? items.length : 0),
                  itemBuilder: (context, i) {
                    return new SolutionItem(items[i]);
                  }));
        });
  }

  Future<void> _pullRefresh() async {

    api.getSolutions(_ticketid).then((list) {

      if (list is List) {
        _streamController.sink.add(list);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          //         Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(list.toString()), //AppLocalizations.of(context).errorTicketList),
              backgroundColor: Colors.red,
            ));
      }

    });

  }

}