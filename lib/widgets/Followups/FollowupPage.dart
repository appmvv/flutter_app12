import 'package:flutter/material.dart';
import 'package:flutter_app/providers/FollowupsProvider.dart';
import 'package:flutter_app/widgets/Followups/FollowupList.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';


class FollowupPage extends StatelessWidget {

  final int _ticketId;

  FollowupPage(this._ticketId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).followups +
                " [" +
                Provider.of<FollowupsProvider>(context).getCount().toString() +
                "]"),
            Text(
              AppLocalizations.of(context).ticket + " " + _ticketId.toString(),
              textScaleFactor: 0.7,
            ),
          ],
        )),
        body: SingleChildScrollView(
          reverse: true,
          child: FollowupList(_ticketId),
        ));
  }
}
