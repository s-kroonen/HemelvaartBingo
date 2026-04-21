// lib/core/network/api_client_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

// The global provider for the ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// A helper provider to get just the Dio instance
final dioProvider = Provider((ref) {
  return ref.watch(apiClientProvider).dio;
});