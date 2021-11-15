// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/SettingsPage.dart';
import 'package:flutter_app/pages/TicketListPage.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/Settings.dart';

/*
Future<void> main() async {
//  debugPrintRebuildDirtyWidgets = true;
  return runApp(
      BlocProvider<ApplicationBloc>(
        bloc: ApplicationBloc(),
          child: GlpiApp(),

      )
  );
}
*/

///////////// firebase start

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/*

// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}


 */

////////////// firebase end

Future<void> main() async {


  //////////////////////////////////

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  //
  SharedPreferences preferences = await SharedPreferences.getInstance();
  Settings.tokenFCM = preferences.getString("FCMtoken") ?? "";
  Settings.userName = preferences.getString("user") ?? "";
  Settings.glpiUrl = preferences.getString("url") ?? Settings.initUrl;
  Settings.getMessages=preferences.getBool("getmessages") ?? false;
  Settings.notSolvedOnly=preferences.getBool("notsolvedonly") ?? true;
  Settings.credentials=preferences.getString("credentials") ?? "";

  ////////////////////////////////// token & users

  Stream<String> _tokenStream;

  void setToken(String token) async {

//    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("FCMtoken", token);
    Settings.tokenFCM=token;
//    if (token != Settings.tokenFCM)  GlpiApi().sendToken(token);

//    GlpiApi().sendToken(token);

  }


/*
  ///////////// other settings /////////////////////
  void setSettings() async {
    // get user to determine current user id
    api.getEntities().then((list) {
      if (!list.isEmpty) {
        Settings.setEntities(list);
      }
    });
    api.getCategories().then((list) {
      if (!list.isEmpty) {
        Settings.setCategories(list);
      }
    });
  }*/


//  setSettings();

  FirebaseMessaging.instance.getToken().then(setToken);
  _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
  _tokenStream.listen(setToken);

  runApp(GlpiApp());

//  runApp(MessagingExampleApp());
}

class GlpiApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
//    Settings.current_context=context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ru', ''),
      ],
//      title: 'Tickets',
      // TODO - start page when application first launch
      home:  Settings.glpiUrl==Settings.initUrl ? SettingsPage() : TicketListPage(),
    );
  }

}

