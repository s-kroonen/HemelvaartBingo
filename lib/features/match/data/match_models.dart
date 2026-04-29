// lib/features/match/data/match_models.dart

import '../../card/models/card_model.dart';

class MatchModel {
  final String id;
  final String name;
  final int cardSize;
  final String status;
  final List<int> calledNumbers;

  MatchModel({
    required this.id,
    required this.name,
    required this.cardSize,
    required this.status,
    required this.calledNumbers,
  });

  factory MatchModel.fromJson(Map<String, dynamic>? json) {
    // If the entire match object is missing
    if (json == null) {
      return MatchModel(
        id: '',
        name: 'Unknown Match',
        cardSize: 0,
        status: 'unknown',
        calledNumbers: [],
      );
    }

    return MatchModel(
      // Use .toString() and ?? to prevent the _asString error
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Match',
      cardSize: json['cardSize'] is int ? json['cardSize'] : 0,
      status: json['status']?.toString() ?? 'ACTIVE',
      // Safely handle the list cast
      calledNumbers: (json['calledNumbers'] as List?)
          ?.map((e) => int.tryParse(e.toString()) ?? 0)
          .toList() ?? [],
    );
  }
}

class MatchContext {
  final MatchModel match;
  final List<CellModel>? cells;
  final String roleInMatch;

  MatchContext({required this.match, this.cells, required this.roleInMatch});

  factory MatchContext.fromJson(Map<String, dynamic> json) {
    return MatchContext(
      // Pass the nested map safely
      match: MatchModel.fromJson(json['match'] as Map<String, dynamic>?),
      cells: json['card'] != null && json['card']['cells'] != null
          ? (json['card']['cells'] as List)
          .map((i) => CellModel.fromJson(i))
          .toList()
          : null,
      // If roleInMatch is missing in the invite preview, default to "user"
      roleInMatch: json['roleInMatch']?.toString() ?? 'user',
    );
  }
}