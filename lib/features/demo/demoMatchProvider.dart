import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../card/models/card_model.dart';
import '../match/data/match_models.dart';

final demoMatchProvider = Provider<MatchContext>((ref) {
  return MatchContext(
    match: MatchModel(
      id: "demo",
      calledNumbers: [12, 34, 56],
      name: '',
      cardSize: 5,
      status: '',
    ),
    roleInMatch: "player",
    cells: List.generate(
      25,
      (i) =>
          CellModel(id: "$i", position: i, value: "$i", isChecked: i % 3 == 0),
    ),
  );
});
