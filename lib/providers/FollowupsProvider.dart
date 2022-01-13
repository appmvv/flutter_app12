import 'package:flutter/cupertino.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Followup.dart';

class FollowupsProvider with ChangeNotifier {
  GlpiApi api = GlpiApi();

  List<Followup> _followups = [];

  List<Followup> get followups => _followups;

  String _getError = "";

  String get getError => _getError;
  String _addError = "";

  String get addError => _addError;

  int getCount() {
    return _followups.length;
  }

  Future<void> getFollowups(int _ticketId) async {
    _getError = "";

    try {
      api.getFollowups(_ticketId).then((list) {
        if (list is List) {
          _followups = list;
          notifyListeners();
        } else {
          _followups = [];
          _getError = list.toString();
        }
        notifyListeners();
      });
    } catch (e) {
      _getError = e.toString();
      _followups = [];
      notifyListeners();
    }
  }

  Future<String> addFollowup(
      int _ticketId, String _content, bool _isPrivate) async {
    String string = await api.addFollowup(_ticketId, _content, _isPrivate);

    if (string.isEmpty) getFollowups(_ticketId);
    return string;
  }
}
