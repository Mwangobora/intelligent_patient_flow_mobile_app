import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';
import 'network_info.dart';

class ApiClient {
  ApiClient({required this.networkInfo})
    : _cookieJar = CookieJar(),
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
    dio.interceptors.add(CookieManager(_cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
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
        onError: (error, handler) {
          handler.reject(_normalizeError(error));
        },
      ),
    );
  }

  final Dio dio;
  final NetworkInfo networkInfo;
  final CookieJar _cookieJar;

  DioException _normalizeError(DioException error) {
    final data = error.response?.data;
    final message = data is Map && data['detail'] is String
        ? data['detail'] as String
        : 'Request failed. Please try again.';

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
}
