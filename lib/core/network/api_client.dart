import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';
import 'network_info.dart';

class ApiClient {
  ApiClient({required this.networkInfo, CookieJar? cookieJar})
    : _cookieJar = cookieJar ?? CookieJar(),
      dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(
            seconds: AppConstants.connectTimeoutSeconds,
          ),
          receiveTimeout: const Duration(
            seconds: AppConstants.receiveTimeoutSeconds,
          ),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    _debugLog('baseUrl=${AppConstants.apiBaseUrl}');
    dio.interceptors.add(CookieManager(_cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _debugLog('request ${options.method} ${options.uri}');
          if (!await networkInfo.isConnected) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: 'No internet connection.',
              ),
            );
            return;
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          _debugLog(
            'response ${response.statusCode} ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _debugLog(
            'error ${error.response?.statusCode ?? error.type.name} '
            '${error.requestOptions.uri}',
          );
          handler.reject(_normalizeError(error));
        },
      ),
    );
  }

  final Dio dio;
  final NetworkInfo networkInfo;
  final CookieJar _cookieJar;

  Future<void> clearSession() => _cookieJar.deleteAll();

  Future<String> cookieHeaderFor(Uri uri) async {
    final cookies = await _cookieJar.loadForRequest(uri);
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  DioException _normalizeError(DioException error) {
    final data = error.response?.data;
    final message = _extractErrorMessage(error);

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: ApiException(
        message: message,
        statusCode: error.response?.statusCode,
        details: data,
      ),
    );
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      final firstFieldError = data.entries
          .where(
            (entry) => entry.value is List && (entry.value as List).isNotEmpty,
          )
          .map((entry) => '${entry.key}: ${(entry.value as List).first}')
          .firstOrNull;
      if (firstFieldError != null) return firstFieldError;
    }
    if (data is String && data.toLowerCase().contains('disallowedhost')) {
      return 'The hospital server rejected this device address. Please check the API server address.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Could not connect to the hospital server. Please check your network.';
    }
    return 'Request failed. Please try again.';
  }

  void _debugLog(String message) {
    if (kDebugMode) debugPrint('[api] $message');
  }
}
