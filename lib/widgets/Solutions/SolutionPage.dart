import 'package:flutter/material.dart';
import 'package:flutter_app/providers/SolutionsProvider.dart';
import 'package:flutter_app/widgets/Solutions/SolutionForm.dart';
import 'package:flutter_app/widgets/Solutions/SolutionList.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SolutionPage extends StatelessWidget {

  final int _ticketId;
  Object _solvedate;

  SolutionPage(this._ticketId, this._solvedate);

  @override
  Widget build(BuildContext context) {
    return Consumer<SolutionsProvider>(builder: (context, value, child) {

      return Scaffold(
        appBar: AppBar(
            title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).solutions),
            Text(
              AppLocalizations.of(context).ticket + " " + _ticketId.toString(),
              textScaleFactor: 0.7,
            ),
          ],
        )),
        body: _solvedate == null || _solvedate.toString().isEmpty
            ? SolutionForm(_ticketId)
            : SingleChildScrollView(
                child: new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          // set height to 40% of the screen height
                          child: SolutionList(_ticketId),
                        ),
                      ],
                    ))),
      );
    });
  }
}
