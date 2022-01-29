import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Settings.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_app/firebase/permissions.dart';

import 'Tickets/TicketListPage.dart';

import 'package:flutter_app/providers/TicketsProvider.dart';

class SettingsPage_new extends StatefulWidget {
  @override
  SettingsPageState_new createState() {
    return SettingsPageState_new();
  }
}

class SettingsPageState_new extends State<SettingsPage_new> {

  String _url=Settings.initUrl ;
  String _url0;
  String _user=Settings.userName;
  String _password="";
  bool _notsolved=Settings.notSolvedOnly;
  bool _sortbyupdate=Settings.sortByUpdate;
  bool _getmessages=Settings.getMessages;

  bool _obscurePass = true;
  bool _changed = false;

  StreamController<bool> _streamController = StreamController<bool>();

  final _formKey = GlobalKey<FormState>();

  GlpiApi api = GlpiApi();

  @override
  void initState() {
    super.initState();
    _getdata();
  }

  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime _lastQuitTime;

    return WillPopScope(
        onWillPop: () async {
          if (_lastQuitTime == null && _changed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  AppLocalizations.of(context).notToSave),
              backgroundColor: Colors.redAccent,
            ));

            _lastQuitTime = DateTime.now();

            return false;
          } else {
//            Print ('exit ');
            Navigator.of(context).pop(true);
            return true;
          }
        },
        child: Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context).settings)),
            body: StreamBuilder<bool>(
                stream: _streamController.stream,
                initialData: false,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  bool preferences = snapshot.data;
                  if (!preferences) {
                    return Center (child: CircularProgressIndicator());
                  } else {
                    return SingleChildScrollView(
                        child: new Container(
                            padding: EdgeInsets.all(10.0),
                            child: new Form(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.always,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    // solved only
                                    padding: EdgeInsets.only(left: 40),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            //                                         width: MediaQuery.of(context).size.width*0.6,
                                            child: Text(
                                                AppLocalizations.of(context)
                                                    .notsolvedonly)),
                                        Switch(
                                          value: _notsolved,
                                          onChanged: (value) {
                                            setState(() {
                                              _changed = _changed ||
                                                  (_notsolved != value);
                                              _notsolved = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    // sort by
                                    padding: EdgeInsets.only(left: 40),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            child: Text(
                                                AppLocalizations.of(context)
                                                    .sortbyupdate)),
                                        Switch(
                                          value: _sortbyupdate,
                                          onChanged: (value) {
                                            setState(() {
                                              _changed = _changed ||
                                                  (_sortbyupdate != value);
                                              _sortbyupdate = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    // getmessged
                                    padding: EdgeInsets.only(left: 40),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(AppLocalizations.of(context)
                                            .getmessages),
                                        Switch(
                                          value: _getmessages,
                                          onChanged: (value) {
                                            setState(() {
                                              _changed = _changed ||
                                                  (_getmessages != value);
                                              _getmessages = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  _getmessages &&
                                          defaultTargetPlatform ==
                                              TargetPlatform.iOS
                                      ? Permissions()
                                      : SizedBox(
                                          height: 10,
                                        ),
                                  TextFormField(
                                    // URL
                                    autovalidateMode: AutovalidateMode.always,
                                    initialValue: _url,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.cloud),
                                      hintText:
                                          AppLocalizations.of(context).enterUrl,
                                      labelText:
                                          AppLocalizations.of(context).url +
                                              "*", //'Url *',
                                    ),
                                    validator: (String value) {
                                      _changed = _changed || (_url != value);

                                      if (value == null ||
                                          value.characters.length == 0 ||
                                          !Uri.parse(value).isAbsolute) {
                                        return AppLocalizations.of(context)
                                            .required; //errorUrl;
                                      } else {
                                        _url = value;
                                        if (!_url.endsWith("/")) _url += "/";
                                        return null;
                                      }
                                    },
                                  ),
                                  TextFormField(
                                    // NAME
                                    autovalidateMode: AutovalidateMode.always,
                                    initialValue: _user,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.person),
                                      hintText: AppLocalizations.of(context)
                                          .enterName,
                                      labelText:
                                          AppLocalizations.of(context).name +
                                              "*",
                                    ),
                                    validator: (String value) {
                                      _changed = _changed || (_user != value);

                                      if (value == null ||
                                          value.characters.length == 0) {
                                        return AppLocalizations.of(context)
                                            .required; //errorName;
                                      } else {
                                        _user = value;
                                        return null;
                                      }
                                    },
                                  ),
                                  TextFormField(
                                    // Password
                                    autovalidateMode: AutovalidateMode.always,
                                    initialValue: _password,
                                    obscureText: _obscurePass,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.security),
                                      hintText: AppLocalizations.of(context)
                                          .enterPassword,
                                      labelText: AppLocalizations.of(context)
                                              .password +
                                          "*",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.remove_red_eye,
                                          color: this._obscurePass
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() =>
                                              _obscurePass = !_obscurePass);
                                        },
                                      ),
                                    ),
                                    validator: (String value) {
                                      _changed =
                                          _changed || (_password != value);

                                      if (value == null ||
                                          value.characters.length == 0) {
                                        return AppLocalizations.of(context)
                                            .required; //errorPassword; //'Password is empty.';
                                      } else {
                                        _password = value;
                                        return null;
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    // Save
                                    onPressed: () {
                                      // Validate returns true if the form is valid, or false otherwise.
//                                      String text =AppLocalizations.of(context).saved;
//                                      Color color = Colors.green;
                                      if (_formKey.currentState.validate()) {
                                        // If the form is valid, display a snackbar. In the real world,
                                        // you'd often call a server or save the information in a database.
                                        _putdata(context);
                                      } else {

//                                       text = AppLocalizations.of(context).errorSettings;
//                                        color = Colors.red;

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(AppLocalizations.of(context)
                                              .errorSettings),
                                          backgroundColor: Colors.red,
                                        ));

                                      }
//                                      _scaffoldKey.currentState

                                    },
                                    child:
                                        Text(AppLocalizations.of(context).save),
                                  )
                                ],
                              ),
                            )));
                  }
                })));
  }

  _getdata() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    _url = preferences.getString("url") ?? _url;
    _url0 = _url;
    _user = preferences.getString("user") ?? _user;
    _password = preferences.getString("password") ?? _password;
    _notsolved = preferences.getBool("notsolvedonly") ?? _notsolved;
    _sortbyupdate = preferences.getBool("sortbyupdate") ?? _sortbyupdate;
    _getmessages = preferences.getBool("getmessages") ?? _getmessages;

//    Settings.tokenFCM = preferences.getString("FCMtoken") ?? "";

    _streamController.sink.add(true);

  }


  _putdata(BuildContext context) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("url", _url);
    preferences.setString("user", _user);
    preferences.setString("password", _password);
    preferences.setBool("notsolvedonly", _notsolved);
    preferences.setBool("sortbyupdate", _sortbyupdate);
    preferences.setBool("getmessages", _getmessages);
    String _credentials = utf8.fuse(base64).encode('$_user:$_password');
    preferences.setString("credentials", _credentials);

    /*
    Settings.userId не трогаем, чтобы сборсить fcm токен из killSession
    */
    Settings.notSolvedOnly = _notsolved;
    Settings.sortByUpdate = _sortbyupdate;
    Settings.getMessages = _getmessages;
    Settings.userName = _user;
    Settings.glpiUrl = _url;
    Settings.credentials = _credentials;

    if (GlpiApi.GLPI_SESSION.isNotEmpty) {

      await api.killSession();
    }

//    GlpiApi.GLPI_SESSION = ""; // перенесено в killSession
//    api.requestSession();

    _changed = false;

    // начинаем все снова
    Provider.of<TicketsProvider>(context, listen: false).getTickets();


    if (_url0 == Settings.initUrl) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TicketListPage()),
      );
    } else {
      Navigator.pop(context);
    }


  }

}
