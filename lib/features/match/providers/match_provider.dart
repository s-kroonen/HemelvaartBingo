import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client_provider.dart';
import '../../invites/data/invite_model.dart';
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
final matchInvitesProvider = FutureProvider.family<List<InviteModel>, String>((ref, matchId) async {
  return ref.watch(matchServiceProvider).fetchInvites(matchId);
});