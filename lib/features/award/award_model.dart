// lib/features/user/data/models/award_model.dart
enum AwardType { BINGO, FULL_CARD, FIRST_BINGO, SPECIAL }

class AwardModel {
  final AwardType type;
  final String title;
  final String? description;
  final String earnedAt;

  AwardModel({required this.type, required this.title, this.description, required this.earnedAt});

  factory AwardModel.fromJson(Map<String, dynamic> json) => AwardModel(
    type: AwardType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
    title: json['title'],
    description: json['description'],
    earnedAt: json['earnedAt'],
  );
}
