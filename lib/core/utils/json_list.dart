List<dynamic> asJsonList(dynamic data) {
  if (data is List<dynamic>) return data;
  if (data is Map<String, dynamic> && data['results'] is List<dynamic>) {
    return data['results'] as List<dynamic>;
  }
  return <dynamic>[];
}

DateTime? parseOptionalDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

int parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

int? parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}

bool parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}
