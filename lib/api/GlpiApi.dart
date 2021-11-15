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

/*Single<Response<List<Ticket>>> getTickets(@Query("order") String order,
    @Query("expand_dropdowns") boolean expand,
    @Query("range") String range,
    @Query("searchText[priority]") int priority,
    @Query("searchText[type]") int type,
    @Query("searchText[urgency]") int urgency,
    @Query("searchText[status]") int status,
    @Query("searchText[impact]") int impact,
    @Query("searchText[solvedate]") String solvedate,
    @Query("searchText[users_id_recipient]") int recipient,
    @Query("searchText[entities_id]") int entityid);*/

class GlpiApi {
  static String GLPI_URL;

  static String GLPI_SESSION = "";

  final String _sessionError = "Server session error";

//  final BuildContext _context;

//  GlpiApi(this._context);

  //GlpiApi api = GlpiApi();

  final HttpWithMiddleware _httpClient = HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  Future<String> requestSession() async {
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//     GLPI_URL = preferences.getString("url") ?? "";
//     String _user = preferences.getString("user") ?? "";
//     String _password = preferences.getString("password") ?? "";
//     Settings.notSolvedOnly = preferences.getBool("notsolved") ?? false;

    GLPI_URL = Settings.glpiUrl;
    String _credentials = Settings.credentials;

    if (GLPI_URL.isEmpty ||
        GLPI_URL == Settings.initUrl ||
        _credentials.isEmpty) return "Check your server url and credentials";

    // final credentials = '$_user:$_password';
    // final stringToBase64 = utf8.fuse(base64);
    // final encodedCredentials = stringToBase64.encode(credentials);

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

        return ""; //SessionToken.fromJson(jsonDecode(response.body)).toString();

      } else {
        print("Failed to get session: " + response.statusCode.toString());
        return "Failed to get session: " + response.body.toString();
      }
    } catch (error) {
      print("Failed to get session: " + error.toString());
      return "Failed to get session: " + error.toString();

      //         _showMessage(AppLocalizations.of(_context).errorSessionToken+": "+error.toString();
      //     _showToast("Session token failed 2: " + error.toString());
    }

//    return "";
  }

  Future<String> killSession() async {
    if (GLPI_SESSION.isNotEmpty) {
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
          print("Failed to kill session: " + response.statusCode.toString());
          return "Failed to kill session: " + response.statusCode.toString();
        }
      } catch (error) {
        print('Failed to kill session: ' + error.toString());
        return 'Failed to kill session: ' + error.toString();
//      _showToast("Get tickets failed 2: " + error.toString());
      }
    }

    return ""; //"";
  }

  Future<Object> getTickets() async {
    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {
      var queryParams = {
        'order': 'DESC',
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
          // If the server did not return a 200 OK response,
          // then throw an exception.
          print('Failed to get tickets ' + response.statusCode.toString());
          return 'Failed to get tickets ' + response.body.toString();
        }
      } catch (error) {
        print('Failed to get tickets ' + error.toString());
        return 'Failed to get tickets ' + error.toString();
//      _showToast("Get tickets failed 2: " + error.toString());
      }
    }

//    return List<Ticket>.empty();
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
          // If the server did not return a 200 OK response,
          // then throw an exception.
          print('Failed to get ticket $id ' + response.statusCode.toString());
          return 'Failed to get ticket $id ' + response.body.toString();
        }
      } catch (error) {
        print('Failed to get ticket $id ' + error.toString());
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
          // If the server did not return a 200 OK response,
          // then throw an exception.
          print('Failed to get followups for Ticket $ticketid ' +
              response.statusCode.toString());
          return 'Failed to get followups for Ticket $ticketid ' +
              response.body.toString();
        }
      } catch (error) {
        print(
            'Failed to get followups for Ticket $ticketid ' + error.toString());
        return 'Failed to get followups for Ticket $ticketid ' +
            error.toString();
      }
    }

//    return List<Followup>.empty();
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
//          final data = json.decode(response.body) as Map;

          return ""; //data.values.first.toString();

        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          return response.body.toString();
          //         throw Exception('response.statusCode=' + response.statusCode.toString());
        }
      } catch (error) {
        return error.toString();
//      _showToast("Get tickets failed 2: " + error.toString());
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
//        'expand_dropdowns': 'true',
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
          // If the server did not return a 200 OK response,
          // then throw an exception.

          print('Failed to get solutions for Ticket $ticketid ' +
              response.statusCode.toString());

          return 'Failed to get solutions for Ticket $ticketid ' + response.body.toString();
        }
      } catch (error) {
        print(
            'Failed to get solutions for Ticket $ticketid ' + error.toString());
        return 'Failed to get solutions for Ticket $ticketid ' + error.toString();
//      _showToast("Get tickets failed 2: " + error.toString());
      }
    }

    return _sessionError;
  }

  Future<String> addSolution(Solution solution) async {
    Map<String, Object> _input = {'input': solution};

    if (GLPI_SESSION.isEmpty) {
      String _answer = await requestSession();
      if (_answer.isNotEmpty) return _answer;
    }

    if (GLPI_SESSION.isNotEmpty) {

      var body =
      jsonEncode(_input); //   _followup.toJson(); json.encode(_followup),

      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json", // or whatever
        'Session-Token': GLPI_SESSION,
      };

      try {
        var response = await _httpClient.post(
          GLPI_URL + "ITILSolution/",
          headers: headers,
          body: body,
        );

        if (response.statusCode == 201 || response.statusCode == 207) {
//          final data = json.decode(response.body) as Map;

          return ""; //data.values.first.toString();

        } else {
          return response.body.toString();
          // If the server did not return a 200 OK response,
          // then throw an exception.
          //         throw Exception('response.statusCode=' + response.statusCode.toString());
        }
      } catch (error) {
        return error.toString();
//      _showToast("Get tickets failed 2: " + error.toString());
      }
    }

    return _sessionError;
  }

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
          // If the server did not return a 200 OK response,
          // then throw an exception.
          print("Failed to get User " + response.statusCode.toString());
          return "Failed to get User " + response.body.toString();
        }
      } catch (error) {
        print("Failed to get User " + error.toString());
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
          print( 'Failed to get SolutionTypes ' + response.statusCode.toString());
          return 'Failed to get SolutionTypes ' + response.body.toString();
        }
      } catch (error) {
        print('Failed to get SolutionTypes ' + error.toString());
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

  // в main каждый раз при получении FCM token записывается в preferencies и устанвливается Settings.tokenFCM
  // при входпе в settingPage также Settings.tokenFCM устанвливается из preferencies

  // sendToken вызывается из getUsers каждый раз после получения users (чтобы не дублировать и не ждать  обновление users)
  // или из SettingPage при сохранении установок

  Future<String> sendToken() async {

    String token = Settings.getMessages ? Settings.tokenFCM : "";

    // если token отличаетсч от того что на сервере - то пишем на сервер
    if (Settings.users[Settings.userName] != null &&
        Settings.tokenPrefix + token !=
            Settings.users[Settings.userName].mobile_notification) {
      Map<String, String> input = new Map<String, String>();
      input["mobile_notification"] =
          token.isEmpty ? token : Settings.tokenPrefix + token;

      Map<String, Object> _input = {'input': input};

      int userid = Settings.userID;

      var body =
          jsonEncode(_input); //   _followup.toJson(); json.encode(_followup),

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
            GLPI_URL + "User/$userid",
            headers: headers,
            body: body,
          );

          if (response.statusCode != 200 && response.statusCode != 207) {
            print(response.statusCode.toString());
            return response.body.toString();
          }
        } catch (error) {
          print(error.toString());
          return error.toString();
        }
      }

    }

    return _sessionError;
  }

}
