class UserModel {
  final String id;
  final String email;
  final String username;
  final List<String> roles;
  final String? currentMatchID;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    this.currentMatchID,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      roles: List<String>.from(json['roles']),
      currentMatchID: json['currentMatchID'],
    );
  }
}