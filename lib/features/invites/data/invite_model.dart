// lib/features/invites/data/models/invite_model.dart

class InviteMetadata {
  final bool watchAdBeforeJoin; // Defaulted to false for easier UI logic
  final String? joinAsRole;
  final String? description;

  InviteMetadata({
    this.watchAdBeforeJoin = false,
    this.joinAsRole,
    this.description,
  });

  factory InviteMetadata.fromJson(Map<String, dynamic>? json) {
    // If the whole metadata object is missing from backend
    if (json == null) return InviteMetadata();

    return InviteMetadata(
      watchAdBeforeJoin: json['watchAdBeforeJoin'] ?? false,
      joinAsRole: json['joinAsRole']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class InviteModel {
  final String matchId;
  final String name;
  final String token;
  final InviteMetadata metadata;

  InviteModel({
    required this.matchId,
    required this.name,
    required this.token,
    required this.metadata,
  });

  factory InviteModel.fromJson(Map<String, dynamic> json) {
    return InviteModel(
      // Ensure these exist or provide fallback to avoid '!' crashes
      matchId: json['matchId']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Match',
      // Safely handle the nested object
      metadata: InviteMetadata.fromJson(json['metadata'] as Map<String, dynamic>?),
    );
  }
}