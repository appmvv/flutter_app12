import 'package:flutter/material.dart';
import 'package:flutter_app/models/Solution.dart';
import 'package:flutter_app/providers/SolutionsProvider.dart';
import 'package:provider/provider.dart';
import 'SolutionItem.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SolutionList extends StatelessWidget {
  final int? _ticketId;

  SolutionList(this._ticketId);

  @override
  Widget build(BuildContext context) {
    return Consumer<SolutionsProvider>(builder: (context, value, child) {
      List<Solution> items = value.solutions;

      String _error = value.getError;

      return _error.isNotEmpty
          ? AlertDialog(
              title: Text(AppLocalizations.of(context)!.errorSolution),
              content: Text(_error),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.close)),
              ],
            )
          : (items == null || items.length == 0
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => value.getSolutions(_ticketId),
                  child: new ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: (items != null ? items.length : 0),
                      itemBuilder: (context, i) {
                        return new SolutionItem(items[i]);
                      })));
    });
  }
}
