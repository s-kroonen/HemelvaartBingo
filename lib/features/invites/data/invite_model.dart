// lib/features/match/data/invite_model.dart

class InviteMetadata {
  final bool watchAdBeforeJoin;
  final String joinAsRole;
  final String? description;

  InviteMetadata({
    required this.watchAdBeforeJoin,
    required this.joinAsRole,
    this.description,
  });

  factory InviteMetadata.fromJson(Map<String, dynamic> json) => InviteMetadata(
    watchAdBeforeJoin: json['watchAdBeforeJoin'] ?? false,
    joinAsRole: json['joinAsRole'] ?? 'user',
    description: json['description'],
  );

  Map<String, dynamic> toJson() => {
    'watchAdBeforeJoin': watchAdBeforeJoin,
    'joinAsRole': joinAsRole,
    'description': description,
  };
}

class InviteModel {
  final String id;
  final String name;
  final String matchId;
  final String token;
  final bool isActive;
  final DateTime? expiresAt;
  final InviteMetadata metadata;

  InviteModel({
    required this.id,
    required this.name,
    required this.matchId,
    required this.token,
    required this.isActive,
    this.expiresAt,
    required this.metadata,
  });

  factory InviteModel.fromJson(Map<String, dynamic> json) => InviteModel(
    id: json['id'] ?? json['_id'],
    name: json['name'] ?? '',
    matchId: json['matchId'] ?? '',
    token: json['token'] ?? '',
    isActive: json['isActive'] ?? true,
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    metadata: InviteMetadata.fromJson(json['metadata'] ?? {}),
  );
}