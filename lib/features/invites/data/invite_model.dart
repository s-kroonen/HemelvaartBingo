class InviteMetadata {
  final bool? watchAdBeforeJoin;
  final String? joinAsRole;
  final String? description;

  InviteMetadata({this.watchAdBeforeJoin, this.joinAsRole, this.description});

  factory InviteMetadata.fromJson(Map<String, dynamic> json) {
    return InviteMetadata(
      watchAdBeforeJoin: json['watchAdBeforeJoin'],
      joinAsRole: json['joinAsRole'],
      description: json['description'],
    );
  }
}

class InviteModel {
  final String id;
  final String name;
  final String token;
  final InviteMetadata metadata;

  InviteModel({
    required this.id,
    required this.name,
    required this.token,
    required this.metadata,
  });

  factory InviteModel.fromJson(Map<String, dynamic> json) {
    return InviteModel(
      id: json['id'],
      name: json['name'],
      token: json['token'],
      metadata: InviteMetadata.fromJson(json["metadata"]),
    );
  }
}
