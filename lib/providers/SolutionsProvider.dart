import 'package:flutter/cupertino.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Solution.dart';

class SolutionsProvider with ChangeNotifier {

  GlpiApi api = GlpiApi();

  List<Solution> _solutions = [];
  List<Solution> get solutions => _solutions;

  String _getError = "";

  String get getError => _getError;
  String _addError = "";

  String get addError => _addError;

  int getCount() {
    return _solutions.length;
  }

  Future<void> getSolutions(_ticketId) async {
    _getError = "";

    try {
      api.getSolutions(_ticketId).then((list) {
        if (list is List) {
          _solutions = list;
        } else {
          _solutions=[];
          _getError = list.toString();
        }
        notifyListeners();
      });
    } catch (e) {
      _getError = e.toString();
      _solutions=[];
      notifyListeners();
    }
  }

  Future<String> addSolution(int _ticketId, String _content, String _solutiontype) async {

    String string = await api.addSolution(_ticketId, _content, _solutiontype);

    return string;

  }

}
