import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hemelvaartbingo/features/event/data/event_service.dart';
import '../../../core/network/api_client_provider.dart';
import '../data/event_model.dart';

final eventServiceProvider = Provider((ref) => EventService(ref.watch(dioProvider)));

final eventProvider = AsyncNotifierProvider<EventNotifier, List<EventModel>>(
  EventNotifier.new,
);

class EventNotifier extends AsyncNotifier<List<EventModel>> {
  late String matchId;

  @override
  Future<List<EventModel>> build(String arg) async {
    matchId = arg;
    final service = ref.read(eventServiceProvider);
    return service.getEvents(matchId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(eventServiceProvider).getEvents(matchId));
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