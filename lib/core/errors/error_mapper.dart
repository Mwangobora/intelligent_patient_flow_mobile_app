import 'package:dio/dio.dart';

import '../network/api_exception.dart';
import 'failure.dart';

class ErrorMapper {
  const ErrorMapper._();

  static Failure fromObject(Object error) {
    if (error is ApiException) return Failure(error.message);
    if (error is DioException) return Failure(_messageForDio(error));
    return const Failure('Something went wrong. Please try again.');
  }

  static String _messageForDio(DioException error) {
    final statusCode = error.response?.statusCode;
    if (error.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }
    if (statusCode == 401) return 'Please sign in again.';
    if (statusCode == 403) return 'You do not have permission.';
    if (statusCode == 422 || statusCode == 400) {
      return 'Please check the information and try again.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server unavailable. Please try again later.';
    }
    return 'Network request failed. Please try again.';
  }
}
