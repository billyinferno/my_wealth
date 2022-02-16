class UserLoginModel {
  final String jwt;
  final UserLoginInfoModel user;

  UserLoginModel(this.jwt, this.user);

  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    UserLoginInfoModel _user = UserLoginInfoModel.fromJson(json['user']);
    return UserLoginModel(json['jwt'], _user);
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

  UserLoginInfoModel({required this.id, required this.username, required this.email, required this.confirmed, required this.blocked, required this.risk});

  factory UserLoginInfoModel.fromJson(Map<String, dynamic> json) {
    return UserLoginInfoModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      confirmed: json['confirmed'],
      blocked: json['blocked'],
      risk: json['risk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'confirmed': confirmed,
      'blocked': blocked,
      'risk': risk
    };
  }
}