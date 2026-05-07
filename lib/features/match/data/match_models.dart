// lib/features/match/data/match_models.dart
enum BingoMode {
  BINGO_75,
  BINGO_90;

  static BingoMode fromString(String? value) {
    return BingoMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BingoMode.BINGO_75, // Safe fallback
    );
  }
}

extension BingoModeExtension on BingoMode {
  String get label {
    switch (this) {
      case BingoMode.BINGO_75:
        return '75 Ball (5x5 Grid)';
      case BingoMode.BINGO_90:
        return '90 Ball (3x9 Grid)';
    }
  }
}

class MatchModel {
  final String id;
  final String name;
  final BingoMode mode;
  final String status;
  final List<int> calledNumbers;
  final String roleInMatch;
  final int? numbersPerEvent;
  final bool? autoNumberDistribution;

  MatchModel({
    required this.id,
    required this.name,
    required this.mode,
    required this.status,
    required this.calledNumbers,
    required this.roleInMatch,
    required this.numbersPerEvent,
    required this.autoNumberDistribution,
  });

  factory MatchModel.fromJson(Map<String, dynamic>? json) {
    // If the entire match object is missing
    if (json == null) {
      return MatchModel(
        id: '',
        name: 'Unknown Match',
        mode: BingoMode.BINGO_75,
        status: 'unknown',
        calledNumbers: [],
        roleInMatch: 'player',
        numbersPerEvent: 1,
        autoNumberDistribution: false,
      );
    }

    return MatchModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Match',
      mode: BingoMode.fromString(json['mode']?.toString()),
      status: json['status']?.toString() ?? 'ACTIVE',
      // Safely handle the list cast
      calledNumbers:
          (json['calledNumbers'] as List?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
      roleInMatch: json['roleInMatch']?.toString() ?? 'player',
      numbersPerEvent: json['numbersPerEvent'] is int
          ? json['numbersPerEvent']
          : 1,
      autoNumberDistribution: json['autoNumberDistribution'] is bool
          ? json['autoNumberDistribution']
          : false,
    );
  }
}

class MatchContext {
  final MatchModel match;
  final String roleInMatch;

  MatchContext({required this.match, required this.roleInMatch});

  factory MatchContext.fromJson(Map<String, dynamic> json) {
    return MatchContext(
      // Pass the nested map safely
      match: MatchModel.fromJson(json['match'] as Map<String, dynamic>?),
      // cells: json['card'] != null && json['card']['cells'] != null
      //     ? (json['card']['cells'] as List)
      //     .map((i) => CellModel.fromJson(i))
      //     .toList()
      //     : null,
      // If roleInMatch is missing in the invite preview, default to "user"
      roleInMatch: json['roleInMatch']?.toString() ?? 'user',
    );
  }
}

class BingoResultDto {
  final bool isValid;
  final String message;
  final String? prize;

  BingoResultDto({required this.isValid, required this.message, this.prize});

  factory BingoResultDto.fromJson(Map<String, dynamic> json) => BingoResultDto(
    isValid: json['isValid'] ?? false,
    message: json['message'] ?? '',
    prize: json['prize'],
  );
}
