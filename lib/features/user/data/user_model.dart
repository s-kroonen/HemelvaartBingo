import '../../award/award_model.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final List<String> roles;
  final String? currentMatchID;
  final int score;
  final List<AwardModel> awards;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    this.currentMatchID,
    required this.score,
    required this.awards,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      roles: List<String>.from(json['roles']),
      currentMatchID: json['currentMatchID'],
      score: json['score'],
      awards: (json['awards'] as List? ?? [])
          .map((a) => AwardModel.fromJson(a))
          .toList(),
    );
  }
}
