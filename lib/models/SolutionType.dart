import 'package:flutter/cupertino.dart';

class SolutionType {

  final int id;
  final String name;

  SolutionType({@required this.id, this.name});

  factory SolutionType.fromJson(Map<String, dynamic> json) {
    return SolutionType(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  String toString() => name;



}