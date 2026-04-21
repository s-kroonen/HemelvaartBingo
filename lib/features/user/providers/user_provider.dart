import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client_provider.dart';
import '../data/user_model.dart';
import '../data/user_service.dart';

final userProvider = FutureProvider<UserModel>((ref) async {
  final service = UserService(ref.watch(dioProvider));
  return service.getMe();
});
final userServiceProvider = Provider((ref) => UserService(ref.watch(dioProvider)));
