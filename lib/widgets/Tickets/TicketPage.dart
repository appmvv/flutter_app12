import 'package:flutter/material.dart';
import 'package:flutter_app/models/Ticket.dart';
import 'package:flutter_app/providers/FollowupsProvider.dart';
import 'package:flutter_app/providers/SolutionsProvider.dart';
import 'package:flutter_app/providers/TicketProvider.dart';
import 'package:flutter_app/widgets/Tickets/TicketForm.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../Followups/FollowupPage.dart';
import '../Solutions/SolutionPage.dart';

class TicketPage extends StatelessWidget {
  final int _ticketId;
  final String _messagetype;

  Icon _followupIcon;

  TicketPage(this._ticketId, this._messagetype) {
    _followupIcon = _messagetype == "followup"
        ? Icon(Icons.announcement_outlined) // new followup
        : Icon(Icons.message);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TicketProvider>(context, listen: false).getTicket(_ticketId);

    Provider.of<FollowupsProvider>(context, listen: false)
        .getFollowups(_ticketId);

    Provider.of<SolutionsProvider>(context, listen: false)
        .getSolutions(_ticketId);

    return Consumer2<TicketProvider, SolutionsProvider>(
        builder: (context, ticketValue, SolutionValue, child) {
      Ticket _ticket = ticketValue.ticket;

      String _error = ticketValue.error;

      //     int _solutionCount = SolutionValue.getCount();

      return Scaffold(
          appBar: AppBar(
              title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).ticket +
                  " " +
                  (_ticket == null || _error.isNotEmpty
                      ? ""
                      : _ticketId.toString())),
              Text(
                _ticket == null || _error.isNotEmpty ? "" : _ticket.tdate,
                textScaleFactor: 0.7,
              ),
            ],
          )),
          body: RefreshIndicator(
              onRefresh: () => ticketValue.getTicket(_ticketId),
              child: _error.isNotEmpty
                  ? AlertDialog(
                      title: Text(AppLocalizations.of(context).errorTicket),
                      content: Text(_error),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context).close)),
                      ],
                    )
                  : (_ticket == null
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: new TicketForm(_ticket),
                        ))),
          floatingActionButton: _ticket == null
              ? Text("")
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Consumer<FollowupsProvider>(
                            builder: (context, value, child) {
                          //             value.getFollowups(_ticket.id);
                          return FloatingActionButton.extended(
                            icon: _followupIcon,
                            label: Text(value.getCount().toString()),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FollowupPage(_ticketId)),
                              );
                            },
                          );
                        })),
                    FloatingActionButton(
                        heroTag: "btn2",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SolutionPage(_ticketId, _ticket.solvedate),
                              ));
                        },
                        child: _ticket.solvedate == null ||
                                _ticket.solvedate.toString().isEmpty
                            ? Icon(Icons
                                .assignment_turned_in_outlined) //  .assignment_late_outlined)
                            : Icon(Icons.assignment_turned_in)),
                  ],
                ));
    });
  }
}
