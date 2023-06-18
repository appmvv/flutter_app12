import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/providers/SolutionsProvider.dart';
import 'package:flutter_app/providers/TicketProvider.dart';

import 'package:flutter_app/widgets/SettingsPage.dart';
import 'package:flutter_app/widgets/Tickets/TicketListPage.dart';
import 'package:flutter_app/providers/TicketsProvider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'api/AppLocator.dart';
import 'models/Settings.dart';

import 'package:flutter_app/providers/FollowupsProvider.dart';

/// Define a top-level named FCM handler which background/terminated messages will call.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // initial settingd
  SharedPreferences preferences = await SharedPreferences.getInstance();
  Settings.tokenFCM = preferences.getString("FCMtoken") ?? "";
  Settings.userName = preferences.getString("user") ?? "";
  Settings.glpiUrl = preferences.getString("url") ?? Settings.initUrl;
  Settings.getMessages = preferences.getBool("getmessages") ?? false;
  Settings.notSolvedOnly = preferences.getBool("notsolvedonly") ?? true;
  Settings.sortByUpdate = preferences.getBool("sortbyupdate") ?? true;
  Settings.credentials = preferences.getString("credentials") ?? "";

  Stream<String> _tokenStream;

  void setToken(String? token) async {
    preferences.setString("FCMtoken", token!);
    Settings.tokenFCM = token;
    // sendToken будет выполнен в initSession после определения userId
  }

  FirebaseMessaging.instance.getToken().then(setToken);
  _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
  _tokenStream.listen(setToken);

  AppLocator.init();

  runApp(GlpiApp());
}

class GlpiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<TicketsProvider>(
              create: (context) => TicketsProvider()),
          ChangeNotifierProvider<TicketProvider>(
              create: (context) => TicketProvider()),
          ChangeNotifierProvider<SolutionsProvider>(
              create: (context) => SolutionsProvider()),
          ChangeNotifierProvider<FollowupsProvider>(
              create: (context) => FollowupsProvider()),
        ],
        child: MaterialApp(
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
          home: Settings.glpiUrl == Settings.initUrl
              ? SettingsPage()
              : TicketListPage(),
        ));
  }
}
