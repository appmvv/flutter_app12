import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'SolutionType.dart';
import 'User.dart';

import 'dart:io' as io show Platform ;

class Settings {
  static BuildContext current_context;

  ///// Consts
  static final String initUrl="https://<YOUR GLPI SERVER>/apirest.php/";
  static final String tokenAndroidPrefix = "FBT:";
  static final String tokenIosPrefix = "FTIOS:";
  static final String tokenPrefix = io.Platform.isIOS ? tokenIosPrefix : tokenAndroidPrefix;
  static final String dateModifiedField ="date_mod";
  static final String idField ="id";

  static final String glpiDateFormat = "yyyy-MM-dd HH:mm:ss";
  static final String appDateFormat = "dd.MM.yy HH:mm";

  ///// Current
  static bool notSolvedOnly = true;
  static bool sortByUpdate = true;
  static bool getMessages = false;
  static String tokenFCM="";
  static int userID=0;
  static String userName="";
  static String glpiUrl="";
  static String credentials="";

  //////////////// users
  static Map<String, User> users  = new Map<String, User>();
  static Map<String, User> usersById= new Map<String, User>();

  static setUsers(List<User> list) {
    list.forEach((user) {
      users[user.name] = user;
      usersById[user.id.toString()] = user;
    } );
    userID=users[Settings.userName].id;
  }

  static String getUserName(String name) {
    return users[name].getUserName();
  }

  //////////////// solution types
  static Map<String, SolutionType> SolutionTypesById = {"0": new SolutionType(id: 0, name: "-")};
  static Map<String, SolutionType> SolutionTypesByName = {"-":new SolutionType(id: 0, name: "-")};
  static List<String> SolutionTypes=["-"];

  static setSolutionTypes(List<SolutionType> list) {
    
    SolutionTypes=[];
      list.forEach((SolutionType) {
        SolutionTypesById[SolutionType.id.toString()] = SolutionType;
        SolutionTypesByName[SolutionType.name] = SolutionType;
        SolutionTypes.add(SolutionType.name);
      }

      );

  }

  static clearSettings () {

    users=new Map<String, User>();
    usersById=new Map<String, User>();

    SolutionTypesById = new Map<String, SolutionType>();
    SolutionTypesByName = new Map<String, SolutionType>();

  }

  //////// dictionaries

  static final ticket_priorities = [
    AppLocalizations
        .of(current_context)
        .ticket_priority0,
    AppLocalizations
        .of(current_context)
        .ticket_priority1,
    AppLocalizations
        .of(current_context)
        .ticket_priority2,
    AppLocalizations
        .of(current_context)
        .ticket_priority3,
    AppLocalizations
        .of(current_context)
        .ticket_priority4,
    AppLocalizations
        .of(current_context)
        .ticket_priority5,
    AppLocalizations
        .of(current_context)
        .ticket_priority6,
  ];

  static final ticket_statuses = [
    AppLocalizations
        .of(current_context)
        .ticket_status0,
    AppLocalizations
        .of(current_context)
        .ticket_status1,
    AppLocalizations
        .of(current_context)
        .ticket_status2,
    AppLocalizations
        .of(current_context)
        .ticket_status3,
    AppLocalizations
        .of(current_context)
        .ticket_status4,
    AppLocalizations
        .of(current_context)
        .ticket_status5,
    AppLocalizations
        .of(current_context)
        .ticket_status6,
  ];

  static final ticket_types = [
    AppLocalizations
        .of(current_context)
        .ticket_type0,
    AppLocalizations
        .of(current_context)
        .ticket_type1,
    AppLocalizations
        .of(current_context)
        .ticket_type2,
  ];

  static final ticket_impacts = [
    AppLocalizations
        .of(current_context)
        .ticket_impact0,
    AppLocalizations
        .of(current_context)
        .ticket_impact1,
    AppLocalizations
        .of(current_context)
        .ticket_impact2,
    AppLocalizations
        .of(current_context)
        .ticket_impact3,
    AppLocalizations
        .of(current_context)
        .ticket_impact4,
    AppLocalizations
        .of(current_context)
        .ticket_impact5,
  ];

  static final ticket_urgencies = [
    AppLocalizations
        .of(current_context)
        .ticket_urgency0,
    AppLocalizations
        .of(current_context)
        .ticket_urgency1,
    AppLocalizations
        .of(current_context)
        .ticket_urgency2,
    AppLocalizations
        .of(current_context)
        .ticket_urgency3,
    AppLocalizations
        .of(current_context)
        .ticket_urgency4,
    AppLocalizations
        .of(current_context)
        .ticket_urgency5,
  ];

  static getAppDate(Object date) {
    if (date == null || date
        .toString()
        .isEmpty) return "-";
    var d = new DateFormat(glpiDateFormat).parse(date);
    return DateFormat(appDateFormat).format(d);
//    return DateFormat(appDateFormat, Localizations.localeOf(current_context).toString()).format(d);
  }

  // error color
  static final ErrorColor=Colors.red;

  // list item decoration (tickets & followups)
  static BoxDecoration itemDecoration = BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        spreadRadius: 0,
        offset: Offset(
          0.5, // Move to right 10  horizontally
          0.5, // Move to bottom 5 Vertically
        ),
      ),
    ],
    borderRadius: BorderRadius.all(Radius.circular(
        6.0) //         <--- border radius here
    ),
  );


}
