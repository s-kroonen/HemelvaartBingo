import '../../award/award_model.dart';

class UserSettings {
  final bool emailNotifications;
  final bool newsletter;
  final bool testerProgram;

  UserSettings({
    required this.emailNotifications,
    required this.newsletter,
    required this.testerProgram,
  });
  factory UserSettings.fromJson(Map<String, dynamic>? json) {
    // If the whole metadata object is missing from backend
    if (json == null) return UserSettings(emailNotifications: false, testerProgram: false, newsletter: false);

    return UserSettings(
      emailNotifications: json['emailNotifications'] ?? false,
      newsletter: json['newsletter'] ?? false,
      testerProgram: json['testerProgram'] ?? false,
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String username;
  final List<String> roles;
  final String? currentMatchID;
  final int? score;
  final List<AwardModel>? awards;
  final UserSettings settings;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    this.currentMatchID,
    required this.score,
    required this.awards,
    required this.settings
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
      settings: UserSettings.fromJson(json['settings'])
    );
  }
}
