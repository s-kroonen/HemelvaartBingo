import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hemelvaartbingo/features/card/data/card_model.dart';
import 'package:hemelvaartbingo/features/card/data/card_service.dart';
import '../../../core/network/api_client_provider.dart';
import '../../user/providers/user_provider.dart';

// Provide the service first
final cardServiceProvider = Provider<CardService>((ref) {
  final dio = ref.watch(dioProvider); // assuming you have this
  return CardService(dio);
});

class CurrentCardNotifier extends AsyncNotifier<CardModel> {
  @override
  Future<CardModel> build() async {
    return ref.read(cardServiceProvider).fetchMyCurrentCard();
  }

  Future<void> toggleCellCheck(String cellId, bool isChecked) async {
    final current = state.value;

    if (current == null) return;

    try {
      // OPTIONAL: optimistic update
      // final updatedCells = current.cells!.map((cell) {
      //   if (cell.id == cellId) {
      //     return cell.copyWith(isChecked: !cell.isChecked);
      //   }
      //   return cell;
      // }).toList();
      //
      // state = AsyncData(
      //   MatchContext(
      //     match: current.match,
      //     roleInMatch: current.roleInMatch,
      //     cells: updatedCells,
      //   ),
      // );

      // 🔥 Call backend

      final updatedCard = await ref
          .read(userServiceProvider)
          .updateCellState(cellId, isChecked);

      // Replace with real backend state (source of truth)
      state = AsyncData(updatedCard);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final currentCardProvider =
    AsyncNotifierProvider<CurrentCardNotifier, CardModel>(
      CurrentCardNotifier.new,
    );
