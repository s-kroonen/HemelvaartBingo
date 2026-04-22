// lib/features/card/data/card_models.dart

// lib/features/card/data/card_models.dart

class CellModel {
  final String id;
  final String value;
  final bool isChecked;
  final int position;

  CellModel({
    required this.id,
    required this.value,
    required this.isChecked,
    required this.position,
  });

  factory CellModel.fromJson(Map<String, dynamic> json) {
    return CellModel(
      id: json['id'] ?? '',
      value: json['value']?.toString() ?? '',
      isChecked: json['isChecked'] ?? false,
      position: json['position'] ?? 0,
    );
  }

  // Essential for updating state in Riverpod
  CellModel copyWith({bool? isChecked}) {
    return CellModel(
      id: id,
      value: value,
      isChecked: isChecked ?? this.isChecked,
      position: position,
    );
  }
}

class CardModel {
  final String id;
  final String matchId;
  final String userId;
  final List<CellModel> cells;

  CardModel({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.cells
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? '',
      matchId: json['matchId'] ?? '',
      userId: json['userId'] ?? '',
      cells: (json['cells'] as List? ?? [])
          .map((e) => CellModel.fromJson(e))
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position)), // Ensure grid order
    );
  }
}