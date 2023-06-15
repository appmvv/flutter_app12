class SessionToken  {

  final String? token;

  SessionToken({required this.token});

  factory SessionToken.fromJson(Map<String, dynamic> json) {
    return SessionToken(
      token: json['session_token'],
    );
  }

  @override
  String toString() => token!;
}