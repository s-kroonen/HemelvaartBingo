import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: "https://bingo.kroon-en.nl/api/v1",
);

class ApiClient {
  final Dio dio;

  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          validateStatus: (status) => status != null && status < 500,
        ),
      ) {
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

        onError: (DioException e, handler) {
          final error = _mapDioError(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: error,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
  }
}
class AppError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic raw;

  AppError({
    required this.message,
    this.statusCode,
    this.raw,
  });
}
AppError _mapDioError(DioException e) {
  final status = e.response?.statusCode;

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return AppError(message: "Connection timed out. Please try again.");
  }

  if (e.type == DioExceptionType.connectionError) {
    return AppError(message: "No internet connection.");
  }

  switch (status) {
    case 400:
      return AppError(message: "Bad request.");
    case 401:
      return AppError(message: "Session expired. Please log in again.", statusCode: 401);
    case 402:
      return AppError(message: "Payment required or feature locked.", statusCode: 402);
    case 403:
      return AppError(message: "You don’t have permission.");
    case 404:
      return AppError(message: "Data not found.");
    case 500:
      return AppError(message: "Server error. Please try later.");
    default:
      return AppError(message: "Something went wrong.");
  }
}
Future<T> safeRequest<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on DioException catch (e) {
    throw e.error is AppError
        ? e
        : AppError(message: "Unexpected error", raw: e);
  }
}

void showAppError(BuildContext context, AppError error) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Something went wrong"),
      content: Text(error.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
        ElevatedButton(
          onPressed: () {
            _reportBug(error);
            Navigator.pop(context);
          },
          child: const Text("Report"),
        ),
      ],
    ),
  );
}
Future<void> _reportBug(AppError error) async {
  final user = FirebaseAuth.instance.currentUser;

  await Dio().post(
    "$apiBaseUrl/bug-report",
    data: {
      "message": error.message,
      "statusCode": error.statusCode,
      "userId": user?.uid,
      "timestamp": DateTime.now().toIso8601String(),
    },
  );
}