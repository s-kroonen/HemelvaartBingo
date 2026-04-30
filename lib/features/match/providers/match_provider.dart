import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client_provider.dart';
import '../../user/providers/user_provider.dart';
import '../data/match_service.dart';
import '../data/match_models.dart';

// Provide the service first
final matchServiceProvider = Provider<MatchService>((ref) {
  final dio = ref.watch(dioProvider); // assuming you have this
  return MatchService(dio);
});

class CurrentMatchNotifier extends AsyncNotifier<MatchContext> {
  @override
  Future<MatchContext> build() async {
    return ref.read(matchServiceProvider).fetchCurrentMatchContext();
  }

  // Side effect: Change the match and refresh the UI
  Future<void> updateMatch(String matchId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Tell backend to update our 'currentMatchID'
      await ref.read(userServiceProvider).updateCurrentMatch(matchId);
      // 2. Fetch the new context
      return ref.read(matchServiceProvider).fetchMatchContext(matchId);
    });
  }

  Future<void> toggleCellCheck(String cellId, bool isChecked) async {
    final current = state.value;

    if (current == null || current.cells == null) return;

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

      final updatedCard = await ref.read(userServiceProvider).updateCellState(cellId, isChecked);

      // Replace with real backend state (source of truth)
      state = AsyncData(
        MatchContext(
          match: current.match,
          roleInMatch: current.roleInMatch,
          cells: updatedCard.cells,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final currentMatchProvider =
    AsyncNotifierProvider<CurrentMatchNotifier, MatchContext>(
      CurrentMatchNotifier.new,
    );

final allMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final service = ref.watch(matchServiceProvider);
  return service.fetchMyMatches();
});

final currentMatchIdProvider = Provider<String?>((ref) {
  final matchAsync = ref.watch(currentMatchProvider);
  return matchAsync.value?.match.id;
});