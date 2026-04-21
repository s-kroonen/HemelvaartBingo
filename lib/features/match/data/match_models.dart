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

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      name: json['name'],
      cardSize: json['cardSize'],
      status: json['status'],
      calledNumbers: List<int>.from(json['calledNumbers']),
    );
  }
}

class MatchContext {
  final MatchModel match; // Full Match data
  final List<CellModel>? cells;
  final String roleInMatch; // "master" or "user"

  MatchContext({required this.match, this.cells, required this.roleInMatch});

  factory MatchContext.fromJson(Map<String, dynamic> json) {
    return MatchContext(
        match: MatchModel.fromJson(json['match']),
        cells: json['card'] != null
        ? (json['card']['cells'] as List)
        .map((i) => CellModel.fromJson(i))
        .toList(): null,
    roleInMatch: json['roleInMatch'],
    );
  }
}

