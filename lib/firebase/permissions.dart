

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Requests & displays the current user permissions for this device.
class Permissions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Permissions();
}

class _Permissions extends State<Permissions> {
  bool _requested = false;
  bool _fetching = false;
  late NotificationSettings _settings;

  Future<void> requestPermissions() async {
    setState(() {
      _fetching = true;
    });

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    setState(() {
      _requested = true;
      _fetching = false;
      _settings = settings;
    });
  }

  Widget row(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (!_requested) {
      requestPermissions();
      return const CircularProgressIndicator();
    }

    if (_fetching) {
      return const CircularProgressIndicator();
    }

    if (_settings.authorizationStatus ==  AuthorizationStatus.authorized)
      return SizedBox(height: 10,);

    String _text="";

    if (_settings.authorizationStatus ==  AuthorizationStatus.denied)
      _text = AppLocalizations.of(context)!.pushnotifications + AppLocalizations.of(context)!.denied;

    if (_settings.authorizationStatus ==  AuthorizationStatus.notDetermined)
      _text = AppLocalizations.of(context)!.pushnotifications + AppLocalizations.of(context)!.notDetermined;

    if (_settings.authorizationStatus ==  AuthorizationStatus.provisional)
      _text = AppLocalizations.of(context)!.pushnotifications + AppLocalizations.of(context)!.provisional;

    return
      Padding(
        padding: EdgeInsets.only(
            left: 40, bottom: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text( _text),
        ),
      );

 //   return Text('Push notification status: ' +
 //       statusMap[_settings.authorizationStatus]);

  }
}

/// Maps a [AuthorizationStatus] to a string value.
const statusMap = {
  AuthorizationStatus.authorized: 'Authorized',
  AuthorizationStatus.denied: 'Denied',
  AuthorizationStatus.notDetermined: 'Not Determined',
  AuthorizationStatus.provisional: 'Provisional',
};

/// Maps a [AppleNotificationSetting] to a string value.
const settingsMap = {
  AppleNotificationSetting.disabled: 'Disabled',
  AppleNotificationSetting.enabled: 'Enabled',
  AppleNotificationSetting.notSupported: 'Not Supported',
};

/// Maps a [AppleShowPreviewSetting] to a string value.
const previewMap = {
  AppleShowPreviewSetting.always: 'Always',
  AppleShowPreviewSetting.never: 'Never',
  AppleShowPreviewSetting.notSupported: 'Not Supported',
  AppleShowPreviewSetting.whenAuthenticated: 'Only When Authenticated',
};
