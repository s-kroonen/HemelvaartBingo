import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_client_provider.dart';
import '../../match/providers/match_provider.dart';
import '../data/event_model.dart';
import '../data/event_service.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final dio = ref.read(dioProvider);
  return EventService(dio);
});
final eventProvider =
AsyncNotifierProvider<EventNotifier, List<EventModel>>(
  EventNotifier.new,
);
final latestEventProvider = FutureProvider.family<EventModel?, String>((ref, matchId) {
  return ref.watch(eventServiceProvider).getLatestEvent(matchId);
});

// We don't auto-fetch history because it's behind an AD wall
final historyEventsProvider = StateProvider<List<EventModel>>((ref) => []);

class EventNotifier extends AsyncNotifier<List<EventModel>> {
  late String matchId;

  @override
  Future<List<EventModel>> build() async {
    // 👇 get match from your existing provider
    final matchContext = await ref.watch(currentMatchProvider.future);

    if (matchContext == null) throw AppError(message: "MatchContext not found");
    final match = matchContext.match;
    if (match == null) throw AppError(message: "Match not found");
    matchId = match.id;

    return ref.read(eventServiceProvider).getEvents(matchId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => ref.read(eventServiceProvider).getEvents(matchId),
    );
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    await ref.read(eventServiceProvider).createEvent(matchId, data);
    await refresh();
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await ref.read(eventServiceProvider).updateEvent(matchId, id, data);
    await refresh();
  }

  Future<void> deleteEvent(String id) async {
    await ref.read(eventServiceProvider).deleteEvent(matchId, id);
    await refresh();
  }

  Future<void> callEvent(String id) async {
    await ref.read(eventServiceProvider).callEvent(matchId, id);
    await refresh();
  }

  Future<void> recallEvent(String id) async {
    await ref.read(eventServiceProvider).recallEvent(matchId, id);
    await refresh();
  }
}