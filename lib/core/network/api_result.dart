sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(String message) = ApiFailure<T>;
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.message);
  final String message;
}
