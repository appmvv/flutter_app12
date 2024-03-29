import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/models/Followup.dart';
import 'package:flutter_app/models/SessionToken.dart';
import 'package:flutter_app/models/Settings.dart';
import 'package:flutter_app/models/Solution.dart';
import 'package:flutter_app/models/SolutionType.dart';
import 'package:flutter_app/models/Ticket.dart';
import 'package:flutter_app/models/User.dart';
import 'package:http/http.dart' as http;

class GlpiApi {
  static String? GLPI_URL;

  static String GLPI_SESSION = "";

  final String _sessionError = "Server session error";

  final _httpClient = http.Client();

  // вызывается из всех  запросов, если GLPI_SESSION.isEmpty
  // GlpiApi.GLPI_SESSION = "" при выходе из SettingsPage с сохранением настроек
  //          поэтому последующий запрос getTickets() вызывает requestSession
  // после получении новой сессии вызывается getSolutionTypes()
  //          и getUsers() (из которого вызывается sendToken, после определения id текущего пользователя)
  Future<String> requestSession() async {
    GLPI_URL = Settings.glpiUrl;
    String _credentials = Settings.credentials;

    if (GLPI_URL!.isEmpty ||
        GLPI_URL == Settings.initUrl ||
        _credentials.isEmpty)
      return "Check your server url and credentials"; // на английском тк нет context

    GLPI_SESSION = "";

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json", // or whatever
      HttpHeaders.authorizationHeader: "Basic $_credentials",
    };

    try {
      var response = await http.get(
        Uri.parse(GLPI_URL! + "initSession/"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        GLPI_SESSION =
            SessionToken.fromJson(jsonDecode(response.body)).toString();
        getUsers();
        getSolutionTypes();

        return "";
      } else {
        return "Failed to get session: " + response.body.toString();
      }
    } catch (error) {
      return "Failed to get session: " + error.toString();
    }
  }

  // вызывается из SettingPage при сохранении настроек
//  Future<String> killSession(String session, String url, int userId) async {
  Future<String> killSession() async {
    String _session = GLPI_SESSION;
    String _url = Settings.glpiUrl;

    if (_session.isEmpty) return "Failed to kill session: no session";

    String _return = "";

    // await is necessary to do before new session open
    await sendToken(
        // session: session,
        // url: url,
        // userId: userId,
        token:
            ""); // сбрасываем токен текущего пользователя (= Settings.userId )

    GLPI_SESSION = "";

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json", // or whatever
      'Session-Token': _session,
    };

    try {
      var response = await _httpClient.get(
        Uri.parse(_url + "killSession"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        _return = "Failed to kill session: " + response.statusCode.toString();
      }
    } catch (error) {
      _return = 'Failed to kill session: ' + error.toString();
    }

    return _return;
  }

  // вызывается через TicketsProvider из main, при обновлении списка и из SettingsPage при сохранении
  Future<Object> getTickets() async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      var queryParams = {
        'order': 'DESC',
        'sort': (Settings.sortByUpdate
            ? Settings.dateModifiedField
            : Settings.idField),
        'expand_dropdowns': 'true',
        'range': '0-100',
        "searchText[priority]": "0",
        "searchText[type]": "0",
        "searchText[urgency]": "0",
        "searchText[status]": "0",
        "searchText[impact]": "0",
        "searchText[solvedate]": (Settings.notSolvedOnly ? "null" : ""),
        "searchText[users_id_recipient]": "0",
        "searchText[entities_id]": "0",
      };

      String queryString = Uri(queryParameters: queryParams).query;

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.get(
          Uri.parse(GLPI_URL! + "Ticket" + '?' + queryString),
          headers: headers,
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          final data = json.decode(response.body) as List;

          return data.map((rawTicket) {
            return Ticket.fromJson(rawTicket);
          }).toList();
        } else {
          return 'Failed to get tickets ' + response.body.toString();
        }
      } catch (error) {
        return 'Failed to get tickets ' + error.toString();
      }
    }

    return _sessionError;
  }

  Future<Object> getTicket(int? id) async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      var queryParams = {
        'expand_dropdowns': 'true',
      };

      String queryString = Uri(queryParameters: queryParams).query;

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.get(
          Uri.parse(GLPI_URL! + "Ticket/" + id.toString() + '?' + queryString),
          headers: headers,
        );

        if (response.statusCode == 200) {
          Ticket ticket = Ticket.fromJson(jsonDecode(response.body));

          return ticket;
        } else {
          return 'Failed to get ticket $id ' + response.body.toString();
        }
      } catch (error) {
        return 'Failed to get ticket $id ' + error.toString();
      }
    }

    return _sessionError;
  }

  Future<Object> getFollowups(int? ticketid) async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      var queryParams = {
        'order': 'DESC',
        'expand_dropdowns': 'true',
        'range': '0-100',
      };

      String queryString = Uri(queryParameters: queryParams).query;

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.get(
          Uri.parse(
              GLPI_URL! + "Ticket/$ticketid/ITILFollowup" + '?' + queryString),
          headers: headers,
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          final data = json.decode(response.body) as List;

          List<Followup> answer = data.map((rawFollowup) {
            return Followup.fromJson(rawFollowup);
          }).toList();

          return answer;
        } else {
          return 'Failed to get followups for Ticket $ticketid ' +
              response.body.toString();
        }
      } catch (error) {
        return 'Failed to get followups for Ticket $ticketid ' +
            error.toString();
      }
    }
    return _sessionError;
  }

  Future<String> addFollowup(
      int? ticketid, String content, bool is_private) async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      Followup _followup = new Followup();
      _followup.is_private = is_private ? 1 : 0;
      _followup.content = content;
      _followup.items_id = ticketid;

      Map<String, Object> _input = {'input': _followup};

      var body =
          jsonEncode(_input); //   _followup.toJson(); json.encode(_followup),

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.post(
          Uri.parse(GLPI_URL! + "ITILFollowup/"),
          headers: headers,
          body: body,
        );

        if (response.statusCode == 201 || response.statusCode == 207) {
          return ""; //data.values.first.toString();
        } else {
          return response.body.toString();
        }
      } catch (error) {
        return error.toString();
      }
    }

    return _sessionError;
  }

  Future<Object> getSolutions(int? ticketid) async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      var queryParams = {
        'order': 'DESC',
      };

      String queryString = Uri(queryParameters: queryParams).query;

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.get(
          Uri.parse(
              GLPI_URL! + "Ticket/$ticketid/ITILSolution" + '?' + queryString),
          headers: headers,
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          final data = json.decode(response.body) as List;

          List<Solution> answer = data.map((raw) {
            return Solution.fromJson(raw);
          }).toList();

          return answer;
        } else {
          return 'Failed to get solutions for Ticket $ticketid ' +
              response.body.toString();
        }
      } catch (error) {
        return 'Failed to get solutions for Ticket $ticketid ' +
            error.toString();
      }
    }

    return _sessionError;
  }

  Future<String> addSolution(
      int? _ticketid, String? _content, String? _solutiontype) async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      Solution _solution = new Solution();
      _solution.content = _content;
      _solution.items_id = _ticketid;
      _solution.solutiontypes_id =
          Settings.SolutionTypesByName[_solutiontype] == null
              ? 0
              : Settings.SolutionTypesByName[_solutiontype]!.id;

      Map<String, Object> _input = {'input': _solution};

      var body = jsonEncode(_input);

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json",
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.post(
          Uri.parse(GLPI_URL! + "ITILSolution/"),
          headers: headers,
          body: body,
        );

        if (response.statusCode == 201 || response.statusCode == 207) {
          return ""; //data.values.first.toString();
        } else {
          return response.body.toString();
        }
      } catch (error) {
        return error.toString();
      }
    }

    return _sessionError;
  }

  // вызывается из requestSession
  // вызывает sendToken, после получения users определения id текущего gользователя
  Future<String> getUsers() async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      var queryParams = {
        'range': "0-10000",
      };

      String queryString = Uri(queryParameters: queryParams).query;

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.get(
          Uri.parse(GLPI_URL! + "User" + '?' + queryString),
          headers: headers,
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          final data = json.decode(response.body) as List;

          List<User> users = data.map((raw) {
            return User.fromJson(raw);
          }).toList();

          Settings.setUsers(users);
          sendToken();

          return "";
        } else {
          return "Failed to get User " + response.body.toString();
        }
      } catch (error) {
        return "Failed to get User " + error.toString();
      }
    }

    return _sessionError;
  }

  Future<String> getSolutionTypes() async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.get(
          Uri.parse(GLPI_URL! + "SolutionType"),
          headers: headers,
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          final data = json.decode(response.body) as List;

          List<SolutionType> solutiontypes = data.map((raw) {
            return SolutionType.fromJson(raw);
          }).toList();

          Settings.setSolutionTypes(solutiontypes);

          return "OK";
        } else {
          return 'Failed to get SolutionTypes ' + response.body.toString();
        }
      } catch (error) {
        return 'Failed to get SolutionTypes ' + error.toString();
      }
    }

    return _sessionError;
  }

  Future<String> sendToken({String? token}) async {
    String _session = GLPI_SESSION;
    String? _url = GLPI_URL;
    int _userId = Settings.userID!;

    String? _token =
        token != null ? token : (Settings.getMessages ? Settings.tokenFCM : "");

    if (_userId > 0 && _url!.isNotEmpty && _session.isNotEmpty) {
      Map<String, String?> input = new Map<String, String?>();

      input["mobile_notification"] =
          _token!.isEmpty ? _token : Settings.tokenPrefix + _token;

      Map<String, Object> _input = {'input': input};

      var body = jsonEncode(_input);

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': _session,
      };

      try {
        var response = await _httpClient.put(
          Uri.parse(_url + "User/${_userId}"),
          headers: headers,
          body: body,
        );

        if (response.statusCode != 200 && response.statusCode != 207) {
          return response.body.toString();
        }
      } catch (error) {
        return error.toString();
      }
    }

    return _sessionError;
  }
}
