class User {

  final int id;
  final String name;
  final String realname;
  final String firstname;
  final String mobile_notification;

  User({required this.id, required this.name, required this.firstname, required this.realname, required this.mobile_notification});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      realname: json['realname'] ?? '',
      firstname: json['firstname'] ?? '',
      mobile_notification: json['mobile_notification'] ?? '',
    );
  }

  String getUserName() {
    String answer="";
    if (firstname.isNotEmpty) answer=firstname;
    if (realname.isNotEmpty) answer += (answer.isEmpty ? "" : " ") + realname;
    return (answer.isEmpty ? name : answer);
  }

  @override
  String toString() => name;

}