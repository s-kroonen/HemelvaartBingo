// lib/features/invites/providers/invite_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/network/api_client_provider.dart';
import '../data/invite_model.dart';

final pendingInviteTokenProvider = StateProvider<String?>((ref) => null);

final inviteMetadataProvider = FutureProvider.family<InviteModel, String>((ref, token) async {
  final service = ref.watch(inviteServiceProvider);
  final res = await service._dio.get('/invites/token/$token');
  return InviteModel.fromJson(res.data);
});

final inviteServiceProvider = Provider((ref) => InviteService(ref.watch(dioProvider)));

class InviteService {
  final Dio _dio;
  InviteService(this._dio);

  Future<void> joinMatch(String token) async {
    await _dio.post('/invites/join/$token');
  }
}

