import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(BaseOptions(
    baseUrl: "https://bingo.kroon-en.nl/api",
    connectTimeout: const Duration(seconds: 10),
  )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
      ),
    );
  }
}