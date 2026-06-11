import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:table_ordering_client/core/constants/app_constants.dart';
import 'package:table_ordering_client/core/errors/app_exception.dart';

// Simple debug logging helper to avoid depending on extra packages.
void _debugLog(Object? msg) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(msg);
  }
}

class ApiClient {
  ApiClient() : dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept'] = 'application/json';
          try {
            _debugLog('API Request -> ${options.method} ${options.baseUrl}${options.path}');
            _debugLog('  query: ${options.queryParameters}');
            _debugLog('  headers: ${options.headers}');
            _debugLog('  data: ${options.data}');
          } catch (_) {
            // ignore logging errors
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          try {
            _debugLog('API Response <- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
            _debugLog('  data: ${response.data}');
          } catch (_) {}
          return handler.next(response);
        },
        onError: (error, handler) {
          try {
            final req = error.requestOptions;
            _debugLog('API Error !! ${error.type} for ${req.method} ${req.baseUrl}${req.path}');
            _debugLog('  query: ${req.queryParameters}');
            _debugLog('  request headers: ${req.headers}');
            _debugLog('  request data: ${req.data}');
            _debugLog('  response status: ${error.response?.statusCode}');
            _debugLog('  response data: ${error.response?.data}');
          } catch (_) {}
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: mapDioException(error),
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  final Dio dio;
}
