import '../../award/award_model.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final List<String> roles;
  final String? currentMatchID;
  final int? score;
  final List<AwardModel>? awards;
  final UserSettings settings;

  Tutorials tutorials;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    this.currentMatchID,
    required this.score,
    required this.awards,
    required this.settings,
    required this.tutorials,
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
      settings: UserSettings.fromJson(json['settings']),
      tutorials: Tutorials.fromJson(json['tutorials']),
    );
  }
}

class Tutorials {
  final bool playerSeen;
  final bool masterSeen;

  Tutorials({required this.playerSeen, required this.masterSeen});

  factory Tutorials.fromJson(Map<String, dynamic>? json) {
    return Tutorials(
      playerSeen: json?['playerSeen'] ?? false,
      masterSeen: json?['masterSeen'] ?? false,
    );
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool newsletter;
  final bool testerProgram;

  UserSettings({
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.newsletter,
    required this.testerProgram,
  });

  factory UserSettings.fromJson(Map<String, dynamic>? json) {
    // If the whole metadata object is missing from backend
    if (json == null) {
      return UserSettings(
        notificationsEnabled: false,
        emailNotifications: false,
        testerProgram: false,
        newsletter: false,
      );
    }

    return UserSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      emailNotifications: json['emailNotifications'] ?? false,
      newsletter: json['newsletter'] ?? false,
      testerProgram: json['testerProgram'] ?? false,
    );
  }
}
