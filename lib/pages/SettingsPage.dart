import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_app/firebase/permissions.dart';

import 'TicketListPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  String _url = Settings.initUrl;
  String _url0 = Settings.initUrl;
  String _user = "";
  String _password = "";
  bool _notsolved = true;
  bool _getmessages = false;

  bool _obscurePass = true;

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
    //  _context = context;

    return WillPopScope(
        onWillPop: () async {
          _streamController.close();

          Navigator.of(context).pop();

          return false;
        },
        child: Scaffold(
          //           key: _scaffoldKey,
          appBar: AppBar(title: Text(AppLocalizations.of(context).settings)),
          body: SingleChildScrollView(
            reverse: true,
            child: StreamBuilder<bool>(
                stream: _streamController.stream,
                initialData: false,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  bool preferences = snapshot.data;

                  if (!preferences) {
                    return CircularProgressIndicator();
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
                                              _notsolved = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
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
//                                      ? MetaCard('Permissions', Permissions())
                                      ? Padding(
                                          // getmessged
                                          padding: EdgeInsets.only(left: 40),
                                          child: Permissions(),
                                        )
                                      : SizedBox(
                                          height: 10,
                                        ),
//                                    _getmessages ? MetaCard('Permissions', Permissions()) : SizedBox(height: 10,),

                                  // SizedBox(
                                  //   height: 10,
                                  // ),

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
                                      String text =
                                          AppLocalizations.of(context).saved;
                                      Color color = Colors.green;
                                      if (_formKey.currentState.validate()) {
                                        // If the form is valid, display a snackbar. In the real world,
                                        // you'd often call a server or save the information in a database.
                                        _putdata();
                                      } else {
                                        text = AppLocalizations.of(context)
                                            .errorSettings;
                                        color = Colors.red;
                                      }
//                                      _scaffoldKey.currentState
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(text),
                                        backgroundColor: color,
                                      ));
                                    },
                                    child:
                                        Text(AppLocalizations.of(context).save),
                                  )
                                ],
                              ),
                            )));
                  }
                }),
          ),
        ));
  }

  _getdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _url = preferences.getString("url") ?? _url;
    _url0 = _url;
    _user = preferences.getString("user") ?? _user;
    _password = preferences.getString("password") ?? _password;
    _notsolved = preferences.getBool("notsolved") ?? _notsolved;
    _getmessages = preferences.getBool("getmessages") ?? _getmessages;

    Settings.tokenFCM = preferences.getString("FCMtoken") ?? "";

    _streamController.sink.add(true);
  }

  _putdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("url", _url);
    preferences.setString("user", _user);
    preferences.setString("password", _password);
    preferences.setBool("notsolved", _notsolved);
    preferences.setBool("getmessages", _getmessages);
    String _credentials = utf8.fuse(base64).encode('$_user:$_password');
    preferences.setString("credentials", _credentials);

    Settings.notSolvedOnly = _notsolved;
    Settings.getMessages = _getmessages;
    Settings.userName = _user;
    Settings.glpiUrl = _url;
    Settings.credentials = _credentials;

//    if (GlpiApi.GLPI_SESSION.isNotEmpty) {
    await api.killSession();
//    }

    GlpiApi.GLPI_SESSION = "";
    api.requestSession();

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

/// UI Widget for displaying metadata.
class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  // ignore: public_member_api_docs
  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Text(_title, style: const TextStyle(fontSize: 18)),
              ),
              _children,
            ],
          ),
        ),
      ),
    );
  }
}
