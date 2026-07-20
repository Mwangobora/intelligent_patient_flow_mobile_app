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
    final normalized = error.error;
    if (normalized is ApiException) {
      if (normalized.statusCode == 401) return 'Please log in again.';
      if (normalized.statusCode == 403) return 'You do not have permission.';
      if (normalized.statusCode != null && normalized.statusCode! >= 500) {
        return 'Server is not reachable. Please try again.';
      }
      if (normalized.message.toLowerCase().contains('invalid credentials')) {
        return 'Invalid email, phone, or password.';
      }
      if (normalized.message.toLowerCase().contains('inactive')) {
        return 'This account is disabled. Please contact the hospital.';
      }
      return normalized.message;
    }
    final statusCode = error.response?.statusCode;
    if (error.type == DioExceptionType.connectionError) {
      return 'Server is not reachable. Please try again.';
    }
    if (statusCode == 401) return 'Please log in again.';
    if (statusCode == 403) return 'You do not have permission.';
    if (statusCode == 422 || statusCode == 400) {
      return 'Please check the information and try again.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server is not reachable. Please try again.';
    }
    return 'Network request failed. Please try again.';
  }
}
