import 'package:flutter/cupertino.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Ticket.dart';

class TicketsProvider with ChangeNotifier {

  GlpiApi api = GlpiApi();

  List<Ticket> _tickets;
  List<Ticket> get tickets => _tickets;

  String _getTicketsError="";
  String get ticketsError => _getTicketsError;
  void clearTicketsError() {
    _getTicketsError = "";
  }


    TicketsProvider () {
      getTickets();
    }

    int getTicketsCount() {
      return _tickets.length;
    }

    Future<void> getTickets() async {

      _getTicketsError="";

      try {
        api.getTickets().then((list) {

          if (list is List) {
            _tickets = list;
          } else {
            _tickets=null;
            _getTicketsError =list.toString();
          }
          notifyListeners();
        });
      } catch (e) {
        _getTicketsError =e.toString();
        _tickets=null;
        notifyListeners();
      }

    }
  }
