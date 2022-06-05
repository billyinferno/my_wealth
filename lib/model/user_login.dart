class UserLoginModel {
  final String jwt;
  final UserLoginInfoModel user;

  UserLoginModel(this.jwt, this.user);

  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    UserLoginInfoModel user = UserLoginInfoModel.fromJson(json['user']);
    return UserLoginModel(json['jwt'], user);
  }

  Map<String, dynamic> toJson() {
    return {
      'jwt': jwt,
      'user': user.toJson()
    };
  }
}

class UserLoginInfoModel {
  final int id;
  final String username;
  final String email;
  final bool confirmed;
  final bool blocked;
  final int risk;
  final bool visibility;
  final bool showLots;
  final String bot;

  UserLoginInfoModel({required this.id, required this.username, required this.email, required this.confirmed, required this.blocked, required this.risk, required this.visibility, required this.showLots, required this.bot});

  factory UserLoginInfoModel.fromJson(Map<String, dynamic> json) {
    return UserLoginInfoModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      confirmed: json['confirmed'],
      blocked: json['blocked'],
      risk: json['risk'],
      visibility: (json['visibility'] ?? false),
      showLots: (json['show_lots'] ?? false),
      bot: (json['bot'] ?? '')
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'confirmed': confirmed,
      'blocked': blocked,
      'risk': risk,
      'visibility': visibility,
      'show_lots': showLots,
      'bot': bot
    };
  }
}