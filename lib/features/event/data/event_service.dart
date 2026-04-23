import 'package:dio/dio.dart';

import 'event_model.dart';

class EventService {
  final Dio _dio;

  EventService(this._dio);

  Future<List<EventModel>> getEvents(String matchId) async {
    final res = await _dio.get('/master/matches/$matchId/events');
    return (res.data as List)
        .map((e) => EventModel.fromJson(e))
        .toList();
  }

  Future<void> createEvent(String matchId, Map<String, dynamic> data) async {
    await _dio.post('/master/matches/$matchId/events', data: data);
  }

  Future<void> updateEvent(String matchId, String eventId, Map<String, dynamic> data) async {
    await _dio.put('/master/matches/$matchId/events/$eventId', data: data);
  }

  Future<void> deleteEvent(String matchId, String eventId) async {
    await _dio.delete('/master/matches/$matchId/events/$eventId');
  }

  Future<void> callEvent(String matchId, String eventId) async {
    await _dio.post('/master/matches/$matchId/events/$eventId/call');
  }

  Future<void> recallEvent(String matchId, String eventId) async {
    await _dio.post('/master/matches/$matchId/events/$eventId/recall');
  }
}