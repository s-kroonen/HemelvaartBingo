// lib/features/ads/data/ad_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import 'ad_model.dart';

final adServiceProvider = Provider((ref) => AdService(ref.watch(dioProvider)));

class AdService {
  final Dio _dio;
  AdService(this._dio);

  Future<AdModel?> fetchAd(String placement) async {
    try {
      final res = await _dio.get('/ads/random', queryParameters: {'placement': placement});
      return AdModel.fromJson(res.data);
    } catch (e) {
      return null; // Return null so UI can decide to bypass or show error
    }
  }
}

// Logic for your JoinMatchScreen:
// 1. Try to fetch Ad.
// 2. If Ad exists, show CustomAdWidget.
// 3. If Ad fails AND it's an invite flow, just show the "Join" button (Bypass).
// 4. If Ad fails AND it's "History" flow, show "Ads unavailable" error.