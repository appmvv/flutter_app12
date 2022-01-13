import 'package:flutter/cupertino.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Ticket.dart';

class TicketProvider with ChangeNotifier {

  GlpiApi api = GlpiApi();

  Ticket _ticket;
  Ticket get ticket => _ticket;

  String _getError="";
  String get error => _getError;

  Future<void> getTicket(int _ticketId) async {

    _getError="";

    try {
      api.getTicket(_ticketId).then((ticket) {

        if (ticket is Ticket) {

          _ticket=ticket;

        } else {
          _getError = ticket.toString();
          _ticket=null;
        }
        notifyListeners();

      });
    } catch (e) {
      _getError =e.toString();
      _ticket=null;
      notifyListeners();

    }
  }



}