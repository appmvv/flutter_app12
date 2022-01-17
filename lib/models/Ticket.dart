
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Settings.dart';
import 'package:intl/intl.dart';

class Ticket {
  int id;
  final String name;
  final String content;
  final String tdate;
  final String recipient;
  final String entity;
  final int priority;
  final int urgency;
  final int status;
  final int impact;
  final Object resolvetime;
  final Object category;
  final Object solvedate;
  final int type;


  // "entities_id":0,"name":"name 1","date":"2021-02-13 12:00:00","closedate":null,"solvedate":null,"date_mod":"2021-02-13 11:33:52","users_id_lastupdater":6,"status":2,"users_id_recipient":6,"requesttypes_id":1,"content":"&lt;p&gt;test 1&lt;/p&gt;","urgency":3,"impact":3,"priority":3,"itilcategories_id":0,"type":1,

  Ticket(
      {this.id,
      this.name,
      this.content,
      this.tdate,
      this.recipient,
      this.entity,
      this.priority,
      this.urgency,
      this.status,
      this.impact,
      this.resolvetime,
      this.category,
      this.solvedate,
      this.type});

  factory Ticket.fromJson(Map<String, dynamic> json) {

    // Ticket ticket = Ticket(
    //   id: json['id'],
    //   name: json['name'],
    //   content: json['content'],
    //   tdate: json['date'],
    //   recipient: json['users_id_recipient'],
    //   entity: json['entities_id'],
    //   status: json['status'],
    //   priority: json['priority'],
    //   urgency: json['urgency'],
    //   impact: json['impact'],
    //   resolvetime: json['time_to_resolve'],
    //   category: json['itilcategories_id'],
    //   solvedate: json['solvedate'],
    //   type: json['type'],
    // );

    return
      Ticket(
      id: json['id'],
      name: json['name'],
      content: json['content'],
      tdate: json['date'],
      recipient: json['users_id_recipient'],
      entity: json['entities_id'],
      status: json['status'],
      priority: json['priority'],
      urgency: json['urgency'],
      impact: json['impact'],
      resolvetime: json['time_to_resolve'],
      category: json['itilcategories_id'],
      solvedate: json['solvedate'],
      type: json['type'],
    );
  }

  @override
  String toString() => 'Ticket { id: $id }';

  static Ticket getEmptyTicket(int id) {
    return Ticket(
      id: id,
      name: "",
      content: "",
      tdate: "",
      recipient: "",
      entity: "",
      status: 0,
      priority: 0,
      urgency: 0,
      impact: 0,
      resolvetime: "",
      category: "",
      solvedate: "",
      type: 0,
    );
  }

  String getEntity() {
    var names = entity.split(">");
    if (names.length>0) return names[names.length-1].trim();
    else return entity;
  }

  Color getColor () {

      if (!(solvedate == null || solvedate.toString().isEmpty)) return Colors.green;

      if (resolvetime == null)  return Colors.transparent;

      DateTime now = DateTime.now();
      DateTime resolve = DateFormat(Settings.glpiDateFormat).parse(resolvetime);
      if (resolve.isBefore(now)) return Colors.red;
//      else if (resolve.day == now.day && resolve.month==now.month && resolve.year==now.year) return Colors.amber;
      else if (resolve.difference(now).inDays==0) return Colors.amber;
      else return Colors.transparent;

  }


}
