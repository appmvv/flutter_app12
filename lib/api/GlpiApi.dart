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
import 'package:http_logger_library/log_level.dart';
import 'package:http_logger_library/logging_middleware.dart';
import 'package:http_middleware_library/http_with_middleware.dart';

class GlpiApi {
  static String GLPI_URL;

  static String GLPI_SESSION = "";

  final String _sessionError = "Server session error";

  // для подробного догирования запросов
  final HttpWithMiddleware _httpClient = HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  // вызывается из всех  запросов, если GLPI_SESSION.isEmpty
  // GlpiApi.GLPI_SESSION = "" при выходе из SettingsPage с сохранением настроек
  //          поэтому последующий запрос getTickets() вызывает requestSession
  // после получении новой сессии вызывается getSolutionTypes()
  //          и getUsers() (из которого вызывается sendToken, после определения id текущего пользователя)
  Future<String> requestSession() async {
    GLPI_URL = Settings.glpiUrl;
    String _credentials = Settings.credentials;

    if (GLPI_URL.isEmpty ||
        GLPI_URL == Settings.initUrl ||
        _credentials.isEmpty)
      return "Check your server url and credentials"; // на английском тк нет context

    GLPI_SESSION = "";

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json", // or whatever
      HttpHeaders.authorizationHeader: "Basic $_credentials",
    };

    try {
      var response = await _httpClient.get(
        GLPI_URL + "initSession/",
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
  Future<String> killSession() async {
    if (GLPI_SESSION.isNotEmpty) {
      String _return = "";

      sendToken(
          token:
              ""); // сбрасываем токен текущего пользователя (= Settings.userId )

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.get(
          GLPI_URL + "killSession",
          headers: headers,
        );

        if (response.statusCode != 200) {
          _return = "Failed to kill session: " + response.statusCode.toString();
        }
      } catch (error) {
        _return = 'Failed to kill session: ' + error.toString();
      }

      GLPI_SESSION = "";
      return _return;
    }

    return "";
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
          GLPI_URL + "Ticket" + '?' + queryString,
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

  Future<Object> getTicket(int id) async {
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
          GLPI_URL + "Ticket/" + id.toString() + '?' + queryString,
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

  Future<Object> getFollowups(int ticketid) async {
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
          GLPI_URL + "Ticket/$ticketid/ITILFollowup" + '?' + queryString,
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
      int ticketid, String content, bool is_private) async {
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
          GLPI_URL + "ITILFollowup/",
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

  Future<Object> getSolutions(int ticketid) async {
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
          GLPI_URL + "Ticket/$ticketid/ITILSolution" + '?' + queryString,
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
      int _ticketid, String _content, String _solutiontype) async {
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
              : Settings.SolutionTypesByName[_solutiontype].id;

      Map<String, Object> _input = {'input': _solution};

      var body = jsonEncode(_input);

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json",
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.post(
          GLPI_URL + "ITILSolution/",
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
          GLPI_URL + "User" + '?' + queryString,
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
          GLPI_URL + "SolutionType",
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

  // @GET("SolutionType")
// Single<Response<List<SolutionType>>> getSolutionTypes();

/*
  Future<List<Entity>> getEnteties() async {

    if (GLPI_SESSION.isEmpty) {
      GLPI_SESSION = await _requestSession();
    }

    if (!GLPI_SESSION.isEmpty) {
      var queryParams = {
        'is_recursive': "true",
      };

      String queryString = Uri(queryParameters: queryParams).query;

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.get(
          GLPI_URL + "getMyEntities"+'?' + queryString,
          headers: headers,
        );

        if (response.statusCode == 200 )  {

          final data = json.decode(response.body) as Map;

          List<Entity> answer =data["myentities"];

          return answer;

        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          throw Exception('Failed to get Users');
        }
      } catch (error) {
//      _showToast("Get tickets failed 2: " + error.toString());
      }
    }

    return new List<Entity>();
  }
*/

  // FCM token
  //      в main
  //            при входе записывается из preferencies в Settings.tokenFCM
  //            при получении токена из FCM
  //                  записывается в preferencies и в Settings.tokenFCM
  //      в SettingsPage
  //            убрано ? при входе записывается из preferencies в Settings.tokenFCM
  //
  // sendToken вызывается
  //    ? нет из main каждый раз при получении токена из FCM
  //    из getUsers после получения users и определения Id текущего пользователя (чтобы не дублировать и не ждать  обновления users)
  //    из SettingsPage -> killSession, чтобы очистить token в бд
  // SendToken пишет токен в бд
  //        если Settings.tokenFCM отличается от того который есть в поле mobile_notification текущего пользователя
  //        если Settings.getMessage == false то в бд пишет пустой FCM

  Future<String> sendToken({String token}) async {

    if (Settings.userID > 0) {
      String _token = token != null
          ? token
          : (Settings.getMessages ? Settings.tokenFCM : "");

      // если token отличается от того что на сервере - то пишем на сервер
      // if (Settings.users[Settings.userName] != null &&
      //     Settings.tokenPrefix + _token !=
      //         Settings.users[Settings.userName].mobile_notification) {

      Map<String, String> input = new Map<String, String>();

      input["mobile_notification"] =
          _token.isEmpty ? _token : Settings.tokenPrefix + _token;

      Map<String, Object> _input = {'input': input};

      var body = jsonEncode(_input);

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
          var response = await _httpClient.put(
            GLPI_URL + "User/${Settings.userID}",
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
    }

    return _sessionError;
  }
}
