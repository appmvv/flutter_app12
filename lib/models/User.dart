import 'package:flutter/cupertino.dart';

class User {

  final int id;
  final String name;
  final String realname;
  final String firstname;
  final String mobile_notification;

  User({@required this.id, this.name, this.firstname, this.realname, this.mobile_notification});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      realname: json['realname'],
      firstname: json['firstname'],
      mobile_notification: json['mobile_notification'],
    );
  }

  String getUserName() {
    String answer="";
    if (!(firstname==null || firstname.isEmpty)) answer=firstname;
    if (!(realname==null || realname.isEmpty)) answer += (answer.isEmpty ? "" : " ") + realname;
    return (answer.isEmpty ? name : answer);
  }

  @override
  String toString() => name;

}